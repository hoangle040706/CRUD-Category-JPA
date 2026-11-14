package vn.iotstar.controllers;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

import org.apache.commons.io.IOUtils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import vn.iotstar.util.Constant;

@WebServlet(urlPatterns = { "/image" })
public class DownloadImageController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String fileName = req.getParameter("fname");
        if (fileName == null || fileName.trim().isEmpty()) {
            fileName = Constant.DEFAULT_FILENAME;
        }

        File file = new File(Constant.DIR + File.separator + fileName);
        if (!file.exists()) {
            file = new File(Constant.DIR + File.separator + Constant.DEFAULT_FILENAME);
        }

        if (file.exists()) {
            String lowerName = file.getName().toLowerCase();
            if (lowerName.endsWith(".png")) {
                resp.setContentType("image/png");
            } else if (lowerName.endsWith(".gif")) {
                resp.setContentType("image/gif");
            } else {
                resp.setContentType("image/jpeg");
            }
            try (FileInputStream fis = new FileInputStream(file)) {
                IOUtils.copy(fis, resp.getOutputStream());
            }
        }
    }
}
