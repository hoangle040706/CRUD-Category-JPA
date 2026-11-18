package vn.iotstar.controllers;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import vn.iotstar.entity.Category;
import vn.iotstar.entity.User;
import vn.iotstar.entity.Video;
import vn.iotstar.entity.VideoSourceType;
import vn.iotstar.service.CategoryServiceImpl;
import vn.iotstar.service.ICategoryService;
import vn.iotstar.service.IVideoService;
import vn.iotstar.service.VideoServiceImpl;
import vn.iotstar.util.Constant;
import vn.iotstar.util.CsrfUtil;

@WebServlet(urlPatterns = {
        "/video/upload", "/video/insert", "/video/edit", "/video/update", "/video/delete"
})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 4,  // 4MB bộ nhớ đệm
        maxFileSize = 1024 * 1024 * 200,      // Trần 200MB cho 1 file
        maxRequestSize = 1024 * 1024 * 250    // Trần 250MB cho cả request
)
public class UserVideoController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final IVideoService videoService = new VideoServiceImpl();
    private final ICategoryService categoryService = new CategoryServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("account") : null;

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        if ("/video/upload".equals(path)) {
            List<Category> categories = categoryService.findAll();
            req.setAttribute("categories", categories);
            CsrfUtil.getToken(session);
            req.getRequestDispatcher("/views/video/upload.jsp").forward(req, resp);
        } else if ("/video/edit".equals(path)) {
            String videoId = req.getParameter("id");
            if (videoId == null || videoId.trim().isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/video?filter=my");
                return;
            }
            Video video = videoService.findById(videoId.trim());
            if (video == null || video.getUser() == null || video.getUser().getId() != currentUser.getId()) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền chỉnh sửa video này!");
                return;
            }
            List<Category> categories = categoryService.findAll();
            req.setAttribute("video", video);
            req.setAttribute("categories", categories);
            CsrfUtil.getToken(session);
            req.getRequestDispatcher("/views/video/edit.jsp").forward(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/video?filter=my");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 1. Kiểm tra CSRF Token ngay tại dòng đầu tiên
        if (!CsrfUtil.isValid(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "CSRF Token không hợp lệ hoặc đã hết hạn!");
            return;
        }

        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("account") : null;
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String path = req.getServletPath();

        if ("/video/insert".equals(path)) {
            handleInsert(req, resp, currentUser);
        } else if ("/video/update".equals(path)) {
            handleUpdate(req, resp, currentUser);
        } else if ("/video/delete".equals(path)) {
            handleDelete(req, resp, currentUser);
        } else {
            resp.sendRedirect(req.getContextPath() + "/video?filter=my");
        }
    }

    private void handleInsert(HttpServletRequest req, HttpServletResponse resp, User currentUser)
            throws ServletException, IOException {
        String title = req.getParameter("title");
        String description = req.getParameter("description");
        String categoryIdRaw = req.getParameter("categoryId");
        String sourceTypeStr = req.getParameter("sourceType");
        String youtubeUrl = req.getParameter("youtubeUrl");

        if (title == null || title.trim().isEmpty()) {
            req.setAttribute("error", "Tiêu đề video không được để trống!");
            req.setAttribute("categories", categoryService.findAll());
            req.getRequestDispatcher("/views/video/upload.jsp").forward(req, resp);
            return;
        }

        VideoSourceType sourceType = "YOUTUBE".equalsIgnoreCase(sourceTypeStr)
                ? VideoSourceType.YOUTUBE
                : VideoSourceType.LOCAL;

        String savedPosterName = null;
        String savedVideoPath = null;
        File writtenPosterFile = null;
        File writtenVideoFile = null;

        try {
            // Upload Poster nếu có
            Part posterPart = req.getPart("poster");
            if (posterPart != null && posterPart.getSize() > 0) {
                if (posterPart.getSize() > Constant.MAX_POSTER_SIZE) {
                    req.setAttribute("error", "Ảnh bìa poster không được vượt quá 5MB!");
                    req.setAttribute("categories", categoryService.findAll());
                    req.getRequestDispatcher("/views/video/upload.jsp").forward(req, resp);
                    return;
                }
                String origName = getFileName(posterPart);
                savedPosterName = UUID.randomUUID().toString() + "_" + sanitizeFileName(origName);
                String posterDir = Constant.getPosterDir();
                writtenPosterFile = new File(posterDir, savedPosterName);
                posterPart.write(writtenPosterFile.getAbsolutePath());
            }

            // Upload Video hoặc xử lý link YouTube
            if (sourceType == VideoSourceType.LOCAL) {
                Part videoPart = req.getPart("videoFile");
                if (videoPart == null || videoPart.getSize() == 0) {
                    req.setAttribute("error", "Vui lòng chọn file video cần upload!");
                    req.setAttribute("categories", categoryService.findAll());
                    req.getRequestDispatcher("/views/video/upload.jsp").forward(req, resp);
                    return;
                }
                if (videoPart.getSize() > Constant.MAX_VIDEO_SIZE) {
                    req.setAttribute("error", "File video không được vượt quá 200MB!");
                    req.setAttribute("categories", categoryService.findAll());
                    req.getRequestDispatcher("/views/video/upload.jsp").forward(req, resp);
                    return;
                }
                String origVideoName = getFileName(videoPart);
                savedVideoPath = UUID.randomUUID().toString() + "_" + sanitizeFileName(origVideoName);
                String videoDir = Constant.getVideoDir();
                writtenVideoFile = new File(videoDir, savedVideoPath);
                videoPart.write(writtenVideoFile.getAbsolutePath());
            } else {
                savedVideoPath = videoService.normalizeYouTubeEmbedUrl(youtubeUrl);
                if (savedVideoPath == null || savedVideoPath.trim().isEmpty()) {
                    req.setAttribute("error", "Đường dẫn YouTube không hợp lệ!");
                    req.setAttribute("categories", categoryService.findAll());
                    req.getRequestDispatcher("/views/video/upload.jsp").forward(req, resp);
                    return;
                }
            }

            Video video = new Video();
            video.setVideoId(UUID.randomUUID().toString().replace("-", "").substring(0, 12));
            video.setTitle(title.trim());
            video.setDescription(description != null ? description.trim() : "");
            video.setPoster(savedPosterName);
            video.setVideoPath(savedVideoPath);
            video.setSourceType(sourceType);
            video.setActive(0); // Mặc định chờ Admin duyệt
            video.setViews(0);
            video.setUser(currentUser);

            if (categoryIdRaw != null && !categoryIdRaw.trim().isEmpty()) {
                try {
                    int catId = Integer.parseInt(categoryIdRaw.trim());
                    Category cat = categoryService.findById(catId);
                    video.setCategory(cat);
                } catch (Exception ignored) {
                }
            }

            // Ghi dữ liệu vào DB
            videoService.insert(video);
            resp.sendRedirect(req.getContextPath() + "/video?filter=my&msg=upload_success");

        } catch (Exception e) {
            // Compensating rollback: xóa file đã ghi đĩa nếu DB insert lỗi
            if (writtenPosterFile != null && writtenPosterFile.exists()) {
                writtenPosterFile.delete();
            }
            if (writtenVideoFile != null && writtenVideoFile.exists()) {
                writtenVideoFile.delete();
            }
            req.setAttribute("error", "Lỗi trong quá trình upload video: " + e.getMessage());
            req.setAttribute("categories", categoryService.findAll());
            req.getRequestDispatcher("/views/video/upload.jsp").forward(req, resp);
        }
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp, User currentUser)
            throws ServletException, IOException {
        String videoId = req.getParameter("videoId");
        String title = req.getParameter("title");
        String description = req.getParameter("description");
        String categoryIdRaw = req.getParameter("categoryId");
        String sourceTypeStr = req.getParameter("sourceType");
        String youtubeUrl = req.getParameter("youtubeUrl");

        if (videoId == null || videoId.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/video?filter=my");
            return;
        }

        Video existing = videoService.findById(videoId.trim());
        if (existing == null || existing.getUser() == null || existing.getUser().getId() != currentUser.getId()) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền chỉnh sửa video này!");
            return;
        }

        if (title == null || title.trim().isEmpty()) {
            req.setAttribute("error", "Tiêu đề video không được để trống!");
            req.setAttribute("video", existing);
            req.setAttribute("categories", categoryService.findAll());
            req.getRequestDispatcher("/views/video/edit.jsp").forward(req, resp);
            return;
        }

        String oldPoster = existing.getPoster();
        String oldVideoPath = existing.getVideoPath();
        VideoSourceType oldSourceType = existing.getSourceType();

        VideoSourceType newSourceType = "YOUTUBE".equalsIgnoreCase(sourceTypeStr)
                ? VideoSourceType.YOUTUBE
                : VideoSourceType.LOCAL;

        String newPosterName = null;
        String newVideoPath = null;
        File writtenPosterFile = null;
        File writtenVideoFile = null;

        try {
            Part posterPart = req.getPart("poster");
            if (posterPart != null && posterPart.getSize() > 0) {
                if (posterPart.getSize() > Constant.MAX_POSTER_SIZE) {
                    req.setAttribute("error", "Ảnh bìa poster không được vượt quá 5MB!");
                    req.setAttribute("video", existing);
                    req.setAttribute("categories", categoryService.findAll());
                    req.getRequestDispatcher("/views/video/edit.jsp").forward(req, resp);
                    return;
                }
                String origName = getFileName(posterPart);
                newPosterName = UUID.randomUUID().toString() + "_" + sanitizeFileName(origName);
                writtenPosterFile = new File(Constant.getPosterDir(), newPosterName);
                posterPart.write(writtenPosterFile.getAbsolutePath());
            }

            if (newSourceType == VideoSourceType.LOCAL) {
                Part videoPart = req.getPart("videoFile");
                if (videoPart != null && videoPart.getSize() > 0) {
                    if (videoPart.getSize() > Constant.MAX_VIDEO_SIZE) {
                        req.setAttribute("error", "File video không được vượt quá 200MB!");
                        req.setAttribute("video", existing);
                        req.setAttribute("categories", categoryService.findAll());
                        req.getRequestDispatcher("/views/video/edit.jsp").forward(req, resp);
                        return;
                    }
                    String origVideoName = getFileName(videoPart);
                    newVideoPath = UUID.randomUUID().toString() + "_" + sanitizeFileName(origVideoName);
                    writtenVideoFile = new File(Constant.getVideoDir(), newVideoPath);
                    videoPart.write(writtenVideoFile.getAbsolutePath());
                }
            } else {
                if (youtubeUrl != null && !youtubeUrl.trim().isEmpty()) {
                    newVideoPath = videoService.normalizeYouTubeEmbedUrl(youtubeUrl);
                }
            }

            Video toUpdate = new Video();
            toUpdate.setVideoId(existing.getVideoId());
            toUpdate.setTitle(title.trim());
            toUpdate.setDescription(description != null ? description.trim() : "");
            toUpdate.setPoster(newPosterName != null ? newPosterName : oldPoster);
            toUpdate.setVideoPath(newVideoPath != null ? newVideoPath : oldVideoPath);
            toUpdate.setSourceType(newVideoPath != null ? newSourceType : oldSourceType);

            if (categoryIdRaw != null && !categoryIdRaw.trim().isEmpty()) {
                try {
                    int catId = Integer.parseInt(categoryIdRaw.trim());
                    Category cat = categoryService.findById(catId);
                    toUpdate.setCategory(cat);
                } catch (Exception ignored) {
                }
            }

            boolean updated = videoService.updateByUser(toUpdate, currentUser.getId());
            if (updated) {
                // Xóa file cũ nếu đã thay thế file mới thành công
                if (newPosterName != null && oldPoster != null && !oldPoster.startsWith("http")) {
                    File oldFile = new File(Constant.getPosterDir(), oldPoster);
                    if (oldFile.exists()) oldFile.delete();
                }
                if (newVideoPath != null && oldSourceType == VideoSourceType.LOCAL && oldVideoPath != null && !oldVideoPath.startsWith("http")) {
                    File oldFile = new File(Constant.getVideoDir(), oldVideoPath);
                    if (oldFile.exists()) oldFile.delete();
                }
                resp.sendRedirect(req.getContextPath() + "/video?filter=my&msg=update_success");
            } else {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Cập nhật video thất bại!");
            }

        } catch (Exception e) {
            // Compensating rollback: xóa file mới ghi nếu cập nhật thất bại
            if (writtenPosterFile != null && writtenPosterFile.exists()) {
                writtenPosterFile.delete();
            }
            if (writtenVideoFile != null && writtenVideoFile.exists()) {
                writtenVideoFile.delete();
            }
            req.setAttribute("error", "Lỗi trong quá trình cập nhật video: " + e.getMessage());
            req.setAttribute("video", existing);
            req.setAttribute("categories", categoryService.findAll());
            req.getRequestDispatcher("/views/video/edit.jsp").forward(req, resp);
        }
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp, User currentUser)
            throws IOException {
        String videoId = req.getParameter("id");
        if (videoId == null || videoId.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/video?filter=my");
            return;
        }

        Video video = videoService.findById(videoId.trim());
        if (video != null && video.getUser() != null && video.getUser().getId() == currentUser.getId()) {
            String poster = video.getPoster();
            String videoPath = video.getVideoPath();
            VideoSourceType sourceType = video.getSourceType();

            boolean deleted = videoService.deleteByUser(videoId.trim(), currentUser.getId());
            if (deleted) {
                if (poster != null && !poster.startsWith("http")) {
                    File f = new File(Constant.getPosterDir(), poster);
                    if (f.exists()) f.delete();
                }
                if (sourceType == VideoSourceType.LOCAL && videoPath != null && !videoPath.startsWith("http")) {
                    File f = new File(Constant.getVideoDir(), videoPath);
                    if (f.exists()) f.delete();
                }
            }
        }
        resp.sendRedirect(req.getContextPath() + "/video?filter=my&msg=delete_success");
    }

    private String getFileName(Part part) {
        for (String content : part.getHeader("content-disposition").split(";")) {
            if (content.trim().startsWith("filename")) {
                return content.substring(content.indexOf("=") + 2, content.length() - 1);
            }
        }
        return Constant.DEFAULT_FILENAME;
    }

    private String sanitizeFileName(String fileName) {
        if (fileName == null) return Constant.DEFAULT_FILENAME;
        return new File(fileName).getName().replaceAll("[^a-zA-Z0-9._-]", "_");
    }
}
