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
        "/admin/videos", "/admin/video/add", "/admin/video/insert",
        "/admin/video/edit", "/admin/video/update", "/admin/video/delete",
        "/admin/video/toggle-active"
})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 4,  // 4MB
        maxFileSize = 1024 * 1024 * 200,      // 200MB
        maxRequestSize = 1024 * 1024 * 250    // 250MB
)
public class AdminVideoController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final IVideoService videoService = new VideoServiceImpl();
    private final ICategoryService categoryService = new CategoryServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        HttpSession session = req.getSession(false);
        CsrfUtil.getToken(session);

        if ("/admin/video/add".equals(path)) {
            List<Category> categories = categoryService.findAll();
            req.setAttribute("categories", categories);
            req.getRequestDispatcher("/views/admin/video-add.jsp").forward(req, resp);
        } else if ("/admin/video/edit".equals(path)) {
            String videoId = req.getParameter("id");
            if (videoId == null || videoId.trim().isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/admin/videos");
                return;
            }
            Video video = videoService.findById(videoId.trim());
            if (video == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy video!");
                return;
            }
            List<Category> categories = categoryService.findAll();
            req.setAttribute("video", video);
            req.setAttribute("categories", categories);
            req.getRequestDispatcher("/views/admin/video-edit.jsp").forward(req, resp);
        } else {
            // Danh sách tất cả video
            String pageRaw = req.getParameter("page");
            int page = 1;
            int pageSize = 10;
            if (pageRaw != null && !pageRaw.trim().isEmpty()) {
                try {
                    page = Integer.parseInt(pageRaw.trim());
                    if (page < 1) page = 1;
                } catch (NumberFormatException ignored) {
                }
            }
            int total = videoService.count();
            int totalPages = (int) Math.ceil((double) total / pageSize);
            if (totalPages < 1) totalPages = 1;
            if (page > totalPages) page = totalPages;

            List<Video> videos = videoService.findAll(page, pageSize);
            req.setAttribute("videos", videos);
            req.setAttribute("currentPage", page);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("totalVideos", total);
            req.getRequestDispatcher("/views/admin/video-list.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Kiểm tra CSRF Token ngay tại dòng đầu tiên
        if (!CsrfUtil.isValid(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "CSRF Token không hợp lệ hoặc đã hết hạn!");
            return;
        }

        String path = req.getServletPath();
        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("account") : null;

        if ("/admin/video/insert".equals(path)) {
            handleInsert(req, resp, currentUser);
        } else if ("/admin/video/update".equals(path)) {
            handleUpdate(req, resp);
        } else if ("/admin/video/delete".equals(path)) {
            handleDelete(req, resp);
        } else if ("/admin/video/toggle-active".equals(path)) {
            handleToggleActive(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/videos");
        }
    }

    private void handleInsert(HttpServletRequest req, HttpServletResponse resp, User currentUser)
            throws ServletException, IOException {
        String title = req.getParameter("title");
        String description = req.getParameter("description");
        String categoryIdRaw = req.getParameter("categoryId");
        String sourceTypeStr = req.getParameter("sourceType");
        String youtubeUrl = req.getParameter("youtubeUrl");
        String activeRaw = req.getParameter("active");

        if (title == null || title.trim().isEmpty()) {
            req.setAttribute("error", "Tiêu đề video không được để trống!");
            req.setAttribute("categories", categoryService.findAll());
            req.getRequestDispatcher("/views/admin/video-add.jsp").forward(req, resp);
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
            Part posterPart = req.getPart("poster");
            if (posterPart != null && posterPart.getSize() > 0) {
                if (posterPart.getSize() > Constant.MAX_POSTER_SIZE) {
                    req.setAttribute("error", "Ảnh bìa poster không được vượt quá 5MB!");
                    req.setAttribute("categories", categoryService.findAll());
                    req.getRequestDispatcher("/views/admin/video-add.jsp").forward(req, resp);
                    return;
                }
                String origName = getFileName(posterPart);
                savedPosterName = UUID.randomUUID().toString() + "_" + sanitizeFileName(origName);
                writtenPosterFile = new File(Constant.getPosterDir(), savedPosterName);
                posterPart.write(writtenPosterFile.getAbsolutePath());
            }

            if (sourceType == VideoSourceType.LOCAL) {
                Part videoPart = req.getPart("videoFile");
                if (videoPart == null || videoPart.getSize() == 0) {
                    req.setAttribute("error", "Vui lòng chọn file video!");
                    req.setAttribute("categories", categoryService.findAll());
                    req.getRequestDispatcher("/views/admin/video-add.jsp").forward(req, resp);
                    return;
                }
                if (videoPart.getSize() > Constant.MAX_VIDEO_SIZE) {
                    req.setAttribute("error", "File video không được vượt quá 200MB!");
                    req.setAttribute("categories", categoryService.findAll());
                    req.getRequestDispatcher("/views/admin/video-add.jsp").forward(req, resp);
                    return;
                }
                String origVideoName = getFileName(videoPart);
                savedVideoPath = UUID.randomUUID().toString() + "_" + sanitizeFileName(origVideoName);
                writtenVideoFile = new File(Constant.getVideoDir(), savedVideoPath);
                videoPart.write(writtenVideoFile.getAbsolutePath());
            } else {
                savedVideoPath = videoService.normalizeYouTubeEmbedUrl(youtubeUrl);
                if (savedVideoPath == null || savedVideoPath.trim().isEmpty()) {
                    req.setAttribute("error", "Đường dẫn YouTube không hợp lệ!");
                    req.setAttribute("categories", categoryService.findAll());
                    req.getRequestDispatcher("/views/admin/video-add.jsp").forward(req, resp);
                    return;
                }
                if (savedPosterName == null || savedPosterName.trim().isEmpty()) {
                    savedPosterName = videoService.extractYouTubeThumbnailUrl(savedVideoPath);
                }
            }

            Video video = new Video();
            video.setVideoId(UUID.randomUUID().toString().replace("-", "").substring(0, 12));
            video.setTitle(title.trim());
            video.setDescription(description != null ? description.trim() : "");
            video.setPoster(savedPosterName);
            video.setVideoPath(savedVideoPath);
            video.setSourceType(sourceType);
            video.setActive("1".equals(activeRaw) ? 1 : 0);
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

            videoService.insert(video);
            resp.sendRedirect(req.getContextPath() + "/admin/videos?msg=insert_success");

        } catch (Exception e) {
            if (writtenPosterFile != null && writtenPosterFile.exists()) {
                writtenPosterFile.delete();
            }
            if (writtenVideoFile != null && writtenVideoFile.exists()) {
                writtenVideoFile.delete();
            }
            req.setAttribute("error", "Lỗi thêm video: " + e.getMessage());
            req.setAttribute("categories", categoryService.findAll());
            req.getRequestDispatcher("/views/admin/video-add.jsp").forward(req, resp);
        }
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String videoId = req.getParameter("videoId");
        String title = req.getParameter("title");
        String description = req.getParameter("description");
        String categoryIdRaw = req.getParameter("categoryId");
        String sourceTypeStr = req.getParameter("sourceType");
        String youtubeUrl = req.getParameter("youtubeUrl");
        String activeRaw = req.getParameter("active");

        if (videoId == null || videoId.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/videos");
            return;
        }

        Video existing = videoService.findById(videoId.trim());
        if (existing == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Video không tồn tại!");
            return;
        }

        if (title == null || title.trim().isEmpty()) {
            req.setAttribute("error", "Tiêu đề video không được để trống!");
            req.setAttribute("video", existing);
            req.setAttribute("categories", categoryService.findAll());
            req.getRequestDispatcher("/views/admin/video-edit.jsp").forward(req, resp);
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
                    req.getRequestDispatcher("/views/admin/video-edit.jsp").forward(req, resp);
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
                        req.getRequestDispatcher("/views/admin/video-edit.jsp").forward(req, resp);
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
                if (newPosterName == null || newPosterName.trim().isEmpty()) {
                    String finalPath = newVideoPath != null ? newVideoPath : existing.getVideoPath();
                    if (existing.getPoster() == null || existing.getPoster().trim().isEmpty() || existing.getPoster().startsWith("http")) {
                        newPosterName = videoService.extractYouTubeThumbnailUrl(finalPath);
                    }
                }
            }

            existing.setTitle(title.trim());
            existing.setDescription(description != null ? description.trim() : "");
            if (newPosterName != null) {
                existing.setPoster(newPosterName);
            }
            if (newVideoPath != null) {
                existing.setVideoPath(newVideoPath);
                existing.setSourceType(newSourceType);
            }
            if (activeRaw != null) {
                existing.setActive("1".equals(activeRaw) ? 1 : 0);
            }

            if (categoryIdRaw != null && !categoryIdRaw.trim().isEmpty()) {
                try {
                    int catId = Integer.parseInt(categoryIdRaw.trim());
                    Category cat = categoryService.findById(catId);
                    existing.setCategory(cat);
                } catch (Exception ignored) {
                }
            }

            videoService.update(existing);

            // Xóa file cũ sau khi cập nhật thành công
            if (newPosterName != null && oldPoster != null && !oldPoster.startsWith("http")) {
                File f = new File(Constant.getPosterDir(), oldPoster);
                if (f.exists()) f.delete();
            }
            if (newVideoPath != null && oldSourceType == VideoSourceType.LOCAL && oldVideoPath != null && !oldVideoPath.startsWith("http")) {
                File f = new File(Constant.getVideoDir(), oldVideoPath);
                if (f.exists()) f.delete();
            }

            resp.sendRedirect(req.getContextPath() + "/admin/videos?msg=update_success");

        } catch (Exception e) {
            if (writtenPosterFile != null && writtenPosterFile.exists()) {
                writtenPosterFile.delete();
            }
            if (writtenVideoFile != null && writtenVideoFile.exists()) {
                writtenVideoFile.delete();
            }
            req.setAttribute("error", "Lỗi cập nhật video: " + e.getMessage());
            req.setAttribute("video", existing);
            req.setAttribute("categories", categoryService.findAll());
            req.getRequestDispatcher("/views/admin/video-edit.jsp").forward(req, resp);
        }
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String videoId = req.getParameter("id");
        if (videoId != null && !videoId.trim().isEmpty()) {
            Video video = videoService.findById(videoId.trim());
            if (video != null) {
                String poster = video.getPoster();
                String videoPath = video.getVideoPath();
                VideoSourceType sourceType = video.getSourceType();
                try {
                    videoService.delete(videoId.trim());
                    if (poster != null && !poster.startsWith("http")) {
                        File f = new File(Constant.getPosterDir(), poster);
                        if (f.exists()) f.delete();
                    }
                    if (sourceType == VideoSourceType.LOCAL && videoPath != null && !videoPath.startsWith("http")) {
                        File f = new File(Constant.getVideoDir(), videoPath);
                        if (f.exists()) f.delete();
                    }
                } catch (Exception ignored) {
                }
            }
        }
        resp.sendRedirect(req.getContextPath() + "/admin/videos?msg=delete_success");
    }

    private void handleToggleActive(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String videoId = req.getParameter("id");
        String activeRaw = req.getParameter("active");
        if (videoId != null && activeRaw != null) {
            int newActive = "1".equals(activeRaw.trim()) ? 1 : 0;
            videoService.adminUpdateActive(videoId.trim(), newActive);
        }
        resp.sendRedirect(req.getContextPath() + "/admin/videos?msg=toggle_success");
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
