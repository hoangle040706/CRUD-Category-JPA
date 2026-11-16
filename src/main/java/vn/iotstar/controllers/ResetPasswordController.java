package vn.iotstar.controllers;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import vn.iotstar.service.IUserService;
import vn.iotstar.service.UserServiceImpl;
import vn.iotstar.util.Constant;

@WebServlet(urlPatterns = { "/reset-password", "/resend-reset-otp" })
public class ResetPasswordController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final IUserService userService = new UserServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        String email = (session != null) ? (String) session.getAttribute(Constant.SESSION_PENDING_RESET_EMAIL) : null;

        if (email == null || email.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/forgot-password");
            return;
        }

        String path = req.getServletPath();
        if ("/resend-reset-otp".equals(path)) {
            boolean resent = userService.resendOtp(email, "FORGOT_PASSWORD");
            if (resent) {
                req.setAttribute("message", "Mã xác thực mới đã được gửi tới email của bạn.");
            } else {
                req.setAttribute("alert", "Vui lòng đợi 60 giây trước khi yêu cầu mã mới.");
            }
        }

        if (session != null && session.getAttribute("message") != null) {
            req.setAttribute("message", session.getAttribute("message"));
            session.removeAttribute("message");
        }

        req.setAttribute("email", email);
        req.getRequestDispatcher(Constant.Path.RESET_PASSWORD).forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        String email = (session != null) ? (String) session.getAttribute(Constant.SESSION_PENDING_RESET_EMAIL) : null;

        if (email == null || email.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/forgot-password");
            return;
        }

        String otp = req.getParameter("otp");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        req.setAttribute("email", email);

        if (otp == null || otp.trim().isEmpty()
                || password == null || password.trim().isEmpty()
                || confirmPassword == null || confirmPassword.trim().isEmpty()) {
            req.setAttribute("alert", "Vui lòng điền đầy đủ các thông tin!");
            req.getRequestDispatcher(Constant.Path.RESET_PASSWORD).forward(req, resp);
            return;
        }

        otp = otp.trim();
        password = password.trim();
        confirmPassword = confirmPassword.trim();

        if (!password.equals(confirmPassword)) {
            req.setAttribute("alert", "Xác nhận mật khẩu không khớp!");
            req.getRequestDispatcher(Constant.Path.RESET_PASSWORD).forward(req, resp);
            return;
        }

        if (password.getBytes(StandardCharsets.UTF_8).length > 72) {
            req.setAttribute("alert", "Mật khẩu không được vượt quá 72 bytes!");
            req.getRequestDispatcher(Constant.Path.RESET_PASSWORD).forward(req, resp);
            return;
        }

        int result = userService.resetPassword(email, otp, password);
        if (result == IUserService.OTP_SUCCESS) {
            session.removeAttribute(Constant.SESSION_PENDING_RESET_EMAIL);
            session.setAttribute("message", "Đặt lại mật khẩu thành công! Vui lòng đăng nhập bằng mật khẩu mới.");
            resp.sendRedirect(req.getContextPath() + "/login");
        } else {
            if (result == IUserService.OTP_ATTEMPTS_EXCEEDED) {
                req.setAttribute("alert", "Bạn đã nhập sai 5 lần. Mã OTP đã bị vô hiệu hóa vì lý do bảo mật. Vui lòng yêu cầu mã mới.");
            } else if (result == IUserService.OTP_INVALID) {
                req.setAttribute("alert", "Mã OTP không chính xác. Vui lòng thử lại.");
            } else if (result == IUserService.PASSWORD_TOO_LONG) {
                req.setAttribute("alert", "Mật khẩu không được vượt quá 72 bytes!");
            } else {
                req.setAttribute("alert", "Mã OTP đã hết hạn hoặc không tồn tại. Vui lòng yêu cầu mã mới.");
            }
            req.getRequestDispatcher(Constant.Path.RESET_PASSWORD).forward(req, resp);
        }
    }
}
