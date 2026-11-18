package vn.iotstar.controllers;

import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import java.io.RandomAccessFile;
import java.nio.file.Path;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import vn.iotstar.entity.User;
import vn.iotstar.entity.Video;
import vn.iotstar.entity.VideoSourceType;
import vn.iotstar.service.IVideoService;
import vn.iotstar.service.VideoServiceImpl;
import vn.iotstar.util.Constant;

@WebServlet(urlPatterns = { "/video/stream" })
public class VideoStreamController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final IVideoService videoService = new VideoServiceImpl();

    @Override
    public void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String videoId = req.getParameter("id");
        if (videoId == null || videoId.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu tham số video id!");
            return;
        }

        Video video = videoService.findById(videoId.trim());
        if (video == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Video không tồn tại!");
            return;
        }

        // NPE-safe inactive video check
        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("account") : null;
        boolean isOwner = currentUser != null
                && video.getUser() != null
                && video.getUser().getId() == currentUser.getId();
        boolean isAdmin = currentUser != null && currentUser.getRoleid() == 1;

        if (video.getActive() != 1 && !isOwner && !isAdmin) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Video chưa được phê duyệt!");
            return;
        }

        if (video.getSourceType() != VideoSourceType.LOCAL) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Video không phải định dạng stream cục bộ!");
            return;
        }

        String videoFileName = video.getVideoPath();
        if (videoFileName == null || videoFileName.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy file video trên hệ thống!");
            return;
        }

        File rootDir = new File(Constant.getVideoDir()).getCanonicalFile();
        File requestedFile = new File(rootDir, videoFileName);
        Path realPath;
        try {
            realPath = requestedFile.toPath().toRealPath();
        } catch (IOException e) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "File video không tồn tại trên ổ đĩa!");
            return;
        }

        if (!realPath.startsWith(rootDir.toPath())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Truy cập bị từ chối: Path Traversal!");
            return;
        }

        File videoFile = realPath.toFile();
        if (!videoFile.exists() || !videoFile.isFile()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "File video không tồn tại!");
            return;
        }

        long fileLength = videoFile.length();
        String contentType = determineVideoContentType(videoFile.getName());
        resp.setContentType(contentType);
        resp.setHeader("Accept-Ranges", "bytes");

        String rangeHeader = req.getHeader("Range");

        // RFC 9110: Unknown range unit hoặc không có Range -> bỏ qua và trả 200 OK toàn bộ file
        if (rangeHeader == null || !rangeHeader.startsWith("bytes=")) {
            resp.setStatus(HttpServletResponse.SC_OK);
            resp.setHeader("Content-Length", String.valueOf(fileLength));
            try (RandomAccessFile raf = new RandomAccessFile(videoFile, "r");
                 OutputStream out = resp.getOutputStream()) {
                byte[] buffer = new byte[8192];
                int read;
                while ((read = raf.read(buffer)) != -1) {
                    out.write(buffer, 0, read);
                }
            } catch (IOException ignored) {
                // Client đóng kết nối sớm khi xem trước
            }
            return;
        }

        // Bắt đầu bytes= nhưng có dấu phẩy (multi-range bị từ chối)
        String rangeValue = rangeHeader.substring(6).trim();
        if (rangeValue.contains(",")) {
            send416(resp, fileLength);
            return;
        }

        long start = 0;
        long end = fileLength - 1;

        try {
            if (rangeValue.startsWith("-")) {
                // Suffix byte range: e.g. -500
                long suffix = Long.parseLong(rangeValue.substring(1));
                if (suffix <= 0) {
                    send416(resp, fileLength);
                    return;
                }
                start = Math.max(0, fileLength - suffix);
                end = fileLength - 1;
            } else if (rangeValue.endsWith("-")) {
                // Open end byte range: e.g. 500-
                start = Long.parseLong(rangeValue.substring(0, rangeValue.length() - 1));
                end = fileLength - 1;
            } else {
                // Range with start and end: e.g. 500-1000
                String[] parts = rangeValue.split("-");
                if (parts.length != 2) {
                    send416(resp, fileLength);
                    return;
                }
                start = Long.parseLong(parts[0]);
                end = Long.parseLong(parts[1]);
            }
        } catch (NumberFormatException e) {
            send416(resp, fileLength);
            return;
        }

        // Kiểm tra hợp lệ theo RFC 9110
        if (start < 0 || start >= fileLength || start > end) {
            send416(resp, fileLength);
            return;
        }

        if (end >= fileLength) {
            end = fileLength - 1;
        }

        long contentLength = end - start + 1;
        resp.setStatus(HttpServletResponse.SC_PARTIAL_CONTENT);
        resp.setHeader("Content-Range", "bytes " + start + "-" + end + "/" + fileLength);
        resp.setHeader("Content-Length", String.valueOf(contentLength));

        try (RandomAccessFile raf = new RandomAccessFile(videoFile, "r");
             OutputStream out = resp.getOutputStream()) {
            raf.seek(start);
            byte[] buffer = new byte[8192];
            long bytesRemaining = contentLength;
            while (bytesRemaining > 0) {
                int toRead = (int) Math.min(buffer.length, bytesRemaining);
                int read = raf.read(buffer, 0, toRead);
                if (read == -1) break;
                out.write(buffer, 0, read);
                bytesRemaining -= read;
            }
        } catch (IOException ignored) {
            // Client đóng kết nối sớm
        }
    }

    private void send416(HttpServletResponse resp, long fileLength) throws IOException {
        resp.setStatus(HttpServletResponse.SC_REQUESTED_RANGE_NOT_SATISFIABLE);
        resp.setHeader("Content-Range", "bytes */" + fileLength);
    }

    private String determineVideoContentType(String fileName) {
        String lower = fileName.toLowerCase();
        if (lower.endsWith(".mp4")) return "video/mp4";
        if (lower.endsWith(".webm")) return "video/webm";
        if (lower.endsWith(".ogg") || lower.endsWith(".ogv")) return "video/ogg";
        if (lower.endsWith(".mov")) return "video/quicktime";
        if (lower.endsWith(".mkv")) return "video/x-matroska";
        return "video/mp4";
    }
}
