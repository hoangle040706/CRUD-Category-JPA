package vn.iotstar.filter;

import java.io.IOException;
import java.net.URI;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import vn.iotstar.entity.User;

@WebFilter(filterName = "AuthFilter", urlPatterns = {
        "/admin", "/admin/*", "/manager/*", "/category/*", "/category", "/video", "/video/*",
        "/profile", "/profile/*"
})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String path = req.getServletPath();
        String method = req.getMethod();

        // 1. Phân loại Route bằng EXACT MATCH cho public video routes
        boolean isPublicVideoRoute = path.equals("/video")
                || path.equals("/video/detail")
                || path.equals("/video/stream");

        boolean isUserVideoMutation = path.equals("/video/upload")
                || path.equals("/video/insert")
                || path.equals("/video/edit")
                || path.equals("/video/update")
                || path.equals("/video/delete");

        boolean isAdminVideoRoute = path.startsWith("/admin/video") || path.startsWith("/admin/videos");
        boolean isAdminCategoryRoute = path.startsWith("/admin/category") || path.startsWith("/admin/categories");
        boolean isAdminGeneralRoute = path.equals("/admin") || path.equals("/admin/home");

        // 2. Kiểm tra Same-Origin chuẩn RFC qua java.net.URI cho các thao tác POST mutation
        if ("POST".equalsIgnoreCase(method) && (isUserVideoMutation || isAdminVideoRoute || isAdminCategoryRoute)) {
            if (!isSameOriginValid(req)) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Yêu cầu bị từ chối do vi phạm quy tắc Same-Origin!");
                return;
            }
        }

        // 3. Khách vãng lai và người dùng truy cập tự do các trang Public Video (/video, /video/detail, /video/stream)
        if (isPublicVideoRoute) {
            chain.doFilter(request, response);
            return;
        }

        // 4. Các route còn lại bắt buộc phải đăng nhập
        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("account") : null;

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // 5. Phân quyền Admin cho Quản lý Video của Admin
        if ((isAdminVideoRoute || isAdminGeneralRoute) && currentUser.getRoleid() != 1) {
            req.getSession().setAttribute("permissionError", "Chỉ tài khoản ADMIN mới có quyền truy cập trang Quản lý Admin!");
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        // 6. Phân quyền Manager
        if (path.startsWith("/manager") && currentUser.getRoleid() != 1 && currentUser.getRoleid() != 2) {
            req.getSession().setAttribute("permissionError", "Bạn không có quyền truy cập trang Quản lý Manager!");
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        // 7. Phân quyền chỉnh sửa Category cho Admin
        boolean isCategoryModify = path.startsWith("/admin/category/add")
                || path.startsWith("/admin/category/insert")
                || path.startsWith("/admin/category/edit")
                || path.startsWith("/admin/category/update")
                || path.startsWith("/admin/category/delete");

        if (isCategoryModify && currentUser.getRoleid() != 1) {
            req.getSession().setAttribute("permissionError", "Chỉ tài khoản ADMIN mới có quyền thực hiện thao tác này!");
            resp.sendRedirect(req.getContextPath() + "/admin/categories");
            return;
        }

        chain.doFilter(request, response);
    }

    private boolean isSameOriginValid(HttpServletRequest req) {
        String origin = req.getHeader("Origin");
        String target = (origin != null && !origin.trim().isEmpty()) ? origin : req.getHeader("Referer");
        if (target == null || target.trim().isEmpty()) {
            return false;
        }
        try {
            URI uri = new URI(target);
            String targetHost = uri.getHost();
            int targetPort = uri.getPort();
            if (targetPort == -1) {
                targetPort = "https".equalsIgnoreCase(uri.getScheme()) ? 443 : 80;
            }

            String serverHost = req.getServerName();
            int serverPort = req.getServerPort();

            return serverHost.equalsIgnoreCase(targetHost) && serverPort == targetPort;
        } catch (Exception e) {
            return false;
        }
    }
}
