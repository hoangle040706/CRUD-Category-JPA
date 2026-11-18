package vn.iotstar.controllers;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.iotstar.entity.Video;
import vn.iotstar.service.IVideoService;
import vn.iotstar.service.VideoServiceImpl;

@WebServlet(urlPatterns = { "/home", "/trang-chu" })
public class HomeController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final IVideoService videoService = new VideoServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<Video> top10Videos = videoService.findTop10Latest();
        req.setAttribute("top10Videos", top10Videos);
        req.getRequestDispatcher("/views/home.jsp").forward(req, resp);
    }
}
