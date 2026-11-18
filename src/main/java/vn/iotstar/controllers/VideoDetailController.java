package vn.iotstar.controllers;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import vn.iotstar.entity.User;
import vn.iotstar.entity.Video;
import vn.iotstar.service.IVideoService;
import vn.iotstar.service.VideoServiceImpl;

@WebServlet(urlPatterns = { "/video/detail" })
public class VideoDetailController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final IVideoService videoService = new VideoServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String videoId = req.getParameter("id");
        if (videoId == null || videoId.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/video");
            return;
        }

        Video video = videoService.findById(videoId.trim());
        if (video == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy video yêu cầu!");
            return;
        }

        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("account") : null;

        // NPE-safe inactive check
        boolean isOwner = currentUser != null
                && video.getUser() != null
                && video.getUser().getId() == currentUser.getId();
        boolean isAdmin = currentUser != null && currentUser.getRoleid() == 1;

        if (video.getActive() != 1 && !isOwner && !isAdmin) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Video này chưa được phê duyệt hoặc đang bị khóa!");
            return;
        }

        // Tăng lượt xem video
        videoService.incrementViews(video.getVideoId());
        video.setViews(video.getViews() + 1);

        // Lấy danh sách video gợi ý
        List<Video> relatedVideos = videoService.findTop10Latest();

        req.setAttribute("video", video);
        req.setAttribute("relatedVideos", relatedVideos);
        req.getRequestDispatcher("/views/video/detail.jsp").forward(req, resp);
    }
}
