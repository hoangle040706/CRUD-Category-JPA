package vn.iotstar.controllers;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.file.Path;

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
        String type = req.getParameter("type"); // "poster" hoặc avatar/category

        if (fileName == null || fileName.trim().isEmpty()) {
            fileName = Constant.DEFAULT_FILENAME;
        }

        // Loại bỏ ký tự độc hại / path traversal trong tên file
        fileName = new File(fileName).getName();

        File targetDir = "poster".equalsIgnoreCase(type)
                ? new File(Constant.getPosterDir()).getCanonicalFile()
                : new File(Constant.getUploadDir()).getCanonicalFile();

        File requestedFile = new File(targetDir, fileName);
        if (!requestedFile.exists() && "poster".equalsIgnoreCase(type)) {
            // Thử tìm trong upload dir chung
            File fallback = new File(Constant.getUploadDir(), fileName);
            if (fallback.exists()) {
                requestedFile = fallback;
                targetDir = new File(Constant.getUploadDir()).getCanonicalFile();
            }
        } else if (!requestedFile.exists()) {
            // Thử tìm trong posters
            File fallback = new File(Constant.getPosterDir(), fileName);
            if (fallback.exists()) {
                requestedFile = fallback;
                targetDir = new File(Constant.getPosterDir()).getCanonicalFile();
            }
        }

        Path realPath;
        try {
            realPath = requestedFile.toPath().toRealPath();
        } catch (IOException e) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy hình ảnh!");
            return;
        }

        // Kiểm tra an toàn Path Traversal
        if (!realPath.startsWith(targetDir.toPath()) && !realPath.startsWith(new File(Constant.getUploadDir()).getCanonicalFile().toPath())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Truy cập bị từ chối!");
            return;
        }

        File imageFile = realPath.toFile();
        if (!imageFile.exists() || !imageFile.isFile()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "File hình ảnh không tồn tại!");
            return;
        }

        String lowerName = imageFile.getName().toLowerCase();
        if (lowerName.endsWith(".png")) {
            resp.setContentType("image/png");
        } else if (lowerName.endsWith(".gif")) {
            resp.setContentType("image/gif");
        } else if (lowerName.endsWith(".webp")) {
            resp.setContentType("image/webp");
        } else {
            resp.setContentType("image/jpeg");
        }

        resp.setHeader("X-Content-Type-Options", "nosniff");
        resp.setHeader("Cache-Control", "public, max-age=86400");

        try (FileInputStream fis = new FileInputStream(imageFile)) {
            IOUtils.copy(fis, resp.getOutputStream());
        }
    }
}
