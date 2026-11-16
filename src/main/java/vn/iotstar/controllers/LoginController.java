package vn.iotstar.controllers;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import vn.iotstar.entity.User;
import vn.iotstar.service.IUserService;
import vn.iotstar.service.UserServiceImpl;
import vn.iotstar.util.Constant;

@WebServlet(urlPatterns = { "/login" })
public class LoginController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final IUserService userService = new UserServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("account") != null) {
            resp.sendRedirect(req.getContextPath() + "/waiting");
            return;
        }

        if (session != null && session.getAttribute("message") != null) {
            req.setAttribute("message", session.getAttribute("message"));
            session.removeAttribute("message");
        }

        req.getRequestDispatcher(Constant.Path.LOGIN).forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String remember = req.getParameter("remember");

        boolean isRememberMe = "on".equals(remember) || "true".equalsIgnoreCase(remember);

        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            req.setAttribute("alert", "Tài khoản hoặc mật khẩu không được rỗng!");
            req.getRequestDispatcher(Constant.Path.LOGIN).forward(req, resp);
            return;
        }

        User user = userService.login(username.trim(), password.trim());
        if (user == null) {
            req.setAttribute("alert", "Tài khoản hoặc mật khẩu không chính xác!");
            req.getRequestDispatcher(Constant.Path.LOGIN).forward(req, resp);
            return;
        }

        if (user.getStatus() != 1) {
            HttpSession session = req.getSession(true);
            session.setAttribute(Constant.SESSION_PENDING_REGISTER_EMAIL, user.getEmail());
            session.setAttribute("alert", "Tài khoản chưa được kích hoạt. Vui lòng xác thực mã OTP đã gửi qua email!");
            resp.sendRedirect(req.getContextPath() + "/verify-otp");
            return;
        }

        try {
            req.changeSessionId();
        } catch (IllegalStateException ignored) {
        }

        HttpSession session = req.getSession(true);
        session.setAttribute("account", user);
        session.setAttribute(Constant.SESSION_USER, user);
        session.setAttribute(Constant.SESSION_USERNAME, user.getUsername());

        if (isRememberMe) {
            String rawToken = userService.createRememberToken(user.getId());
            if (rawToken != null) {
                Cookie cookie = new Cookie(Constant.COOKIE_REMEMBER, rawToken);
                cookie.setMaxAge(30 * 24 * 3600);
                String cookiePath = req.getContextPath();
                cookie.setPath(cookiePath == null || cookiePath.isEmpty() ? "/" : cookiePath);
                cookie.setHttpOnly(true);
                if (req.isSecure()) {
                    cookie.setSecure(true);
                }
                resp.addCookie(cookie);
            }
        }

        resp.sendRedirect(req.getContextPath() + "/waiting");
    }
}
