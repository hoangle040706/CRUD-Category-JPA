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
import vn.iotstar.util.Constant;

@WebServlet(urlPatterns = { "/video" })
public class VideoController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final IVideoService videoService = new VideoServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String filter = req.getParameter("filter");
        String pageRaw = req.getParameter("page");

        int page = 1;
        if (pageRaw != null && !pageRaw.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageRaw.trim());
                if (page < 1) {
                    page = 1;
                }
            } catch (NumberFormatException ignored) {
                page = 1;
            }
        }

        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("account") : null;

        int pageSize = Constant.PAGE_SIZE_VIDEO; // 6 video / page
        int totalVideos;
        List<Video> videos;

        if ("my".equalsIgnoreCase(filter)) {
            if (currentUser == null) {
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }
            totalVideos = videoService.countVideosByUserId(currentUser.getId());
            int totalPages = (int) Math.ceil((double) totalVideos / pageSize);
            if (totalPages < 1) totalPages = 1;
            if (page > totalPages) page = totalPages;

            videos = videoService.findVideosByUserIdWithPaging(page, pageSize, currentUser.getId());
            req.setAttribute("filter", "my");
            req.setAttribute("totalPages", totalPages);
        } else {
            totalVideos = videoService.countPublicVideos();
            int totalPages = (int) Math.ceil((double) totalVideos / pageSize);
            if (totalPages < 1) totalPages = 1;
            if (page > totalPages) page = totalPages;

            videos = videoService.findPublicVideosWithPaging(page, pageSize);
            req.setAttribute("filter", "all");
            req.setAttribute("totalPages", totalPages);
        }

        req.setAttribute("videos", videos);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalVideos", totalVideos);

        req.getRequestDispatcher("/views/video/list.jsp").forward(req, resp);
    }
}
