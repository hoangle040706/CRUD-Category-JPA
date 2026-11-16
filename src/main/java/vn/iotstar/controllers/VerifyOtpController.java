package vn.iotstar.controllers;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import vn.iotstar.service.IUserService;
import vn.iotstar.service.UserServiceImpl;
import vn.iotstar.util.Constant;

@WebServlet(urlPatterns = { "/verify-otp", "/resend-otp" })
public class VerifyOtpController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final IUserService userService = new UserServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        String email = (session != null) ? (String) session.getAttribute(Constant.SESSION_PENDING_REGISTER_EMAIL) : null;

        if (email == null || email.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String path = req.getServletPath();
        if ("/resend-otp".equals(path)) {
            boolean resent = userService.resendOtp(email, "REGISTER");
            if (resent) {
                req.setAttribute("message", "Mã xác thực mới đã được gửi tới email của bạn.");
            } else {
                req.setAttribute("alert", "Vui lòng đợi 60 giây trước khi yêu cầu mã mới.");
            }
        }

        req.setAttribute("email", email);
        req.getRequestDispatcher(Constant.Path.VERIFY_OTP).forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        String email = (session != null) ? (String) session.getAttribute(Constant.SESSION_PENDING_REGISTER_EMAIL) : null;

        if (email == null || email.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String otp = req.getParameter("otp");
        if (otp == null || otp.trim().isEmpty()) {
            req.setAttribute("email", email);
            req.setAttribute("alert", "Vui lòng nhập mã OTP!");
            req.getRequestDispatcher(Constant.Path.VERIFY_OTP).forward(req, resp);
            return;
        }

        int result = userService.verifyOtp(email, otp.trim(), "REGISTER");
        if (result == IUserService.OTP_SUCCESS) {
            session.removeAttribute(Constant.SESSION_PENDING_REGISTER_EMAIL);
            session.setAttribute("message", "Kích hoạt tài khoản thành công! Vui lòng đăng nhập.");
            resp.sendRedirect(req.getContextPath() + "/login");
        } else {
            req.setAttribute("email", email);
            if (result == IUserService.OTP_ATTEMPTS_EXCEEDED) {
                req.setAttribute("alert", "Bạn đã nhập sai 5 lần. Mã OTP đã bị vô hiệu hóa vì lý do bảo mật. Vui lòng yêu cầu mã mới.");
            } else if (result == IUserService.OTP_INVALID) {
                req.setAttribute("alert", "Mã OTP không chính xác. Vui lòng thử lại.");
            } else {
                req.setAttribute("alert", "Mã OTP đã hết hạn hoặc không tồn tại. Vui lòng yêu cầu mã mới.");
            }
            req.getRequestDispatcher(Constant.Path.VERIFY_OTP).forward(req, resp);
        }
    }
}
