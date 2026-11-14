package vn.iotstar.filter;

import java.io.IOException;

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

@WebFilter(filterName = "AuthFilter", urlPatterns = { "/admin/*", "/manager/*", "/category/*", "/category" })
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);
        User currentUser = null;
        if (session != null) {
            currentUser = (User) session.getAttribute("account");
        }

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String path = req.getServletPath();

        if (path.startsWith("/manager") && currentUser.getRoleid() != 1 && currentUser.getRoleid() != 2) {
            req.getSession().setAttribute("permissionError", "Bạn không có quyền truy cập trang Quản lý Manager!");
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        boolean isModifyAction = path.startsWith("/admin/category/add")
                || path.startsWith("/admin/category/insert")
                || path.startsWith("/admin/category/edit")
                || path.startsWith("/admin/category/update")
                || path.startsWith("/admin/category/delete")
                || path.equals("/admin/home")
                || path.equals("/admin");

        if (isModifyAction && currentUser.getRoleid() != 1) {
            req.getSession().setAttribute("permissionError", "Chỉ tài khoản ADMIN mới có quyền thực hiện thao tác này!");
            resp.sendRedirect(req.getContextPath() + "/admin/categories");
            return;
        }

        chain.doFilter(request, response);
    }
}
