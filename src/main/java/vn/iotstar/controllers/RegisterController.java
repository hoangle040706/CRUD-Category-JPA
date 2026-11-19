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
import vn.iotstar.util.ValidationUtil;

@WebServlet(urlPatterns = { "/register" })
public class RegisterController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final IUserService userService = new UserServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher(Constant.Path.REGISTER).forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        String rawUsername = req.getParameter("username");
        String rawPassword = req.getParameter("password");
        String rawEmail    = req.getParameter("email");
        String rawFullname = req.getParameter("fullname");
        String rawPhone    = req.getParameter("phone");

        String username = rawUsername != null ? rawUsername.trim() : "";
        String password = rawPassword != null ? rawPassword.trim() : "";
        String email    = rawEmail != null ? rawEmail.trim() : "";
        String fullname = rawFullname != null ? rawFullname.trim() : "";
        String phone    = rawPhone != null ? rawPhone.trim() : "";

        if (username.isEmpty() || password.isEmpty() || email.isEmpty()) {
            setFormAttributes(req, username, fullname, email, phone);
            req.setAttribute("alert", "Vui lòng nhập đầy đủ các thông tin bắt buộc!");
            req.getRequestDispatcher(Constant.Path.REGISTER).forward(req, resp);
            return;
        }

        // Validate username format
        if (!ValidationUtil.isValidUsername(username)) {
            req.setAttribute("alert", "Tên tài khoản 3–50 ký tự, chỉ chứa chữ cái, số và dấu gạch dưới!");
            setFormAttributes(req, username, fullname, email, phone);
            req.getRequestDispatcher(Constant.Path.REGISTER).forward(req, resp);
            return;
        }

        // Validate email format
        if (!ValidationUtil.isValidEmail(email)) {
            req.setAttribute("alert", "Địa chỉ email không hợp lệ!");
            setFormAttributes(req, username, fullname, email, phone);
            req.getRequestDispatcher(Constant.Path.REGISTER).forward(req, resp);
            return;
        }

        // Validate phone (required)
        if (!phone.isEmpty() && !ValidationUtil.isValidPhone(phone)) {
            req.setAttribute("alert", "Số điện thoại không hợp lệ! Vui lòng nhập 10 chữ số VN bắt đầu bằng 0.");
            setFormAttributes(req, username, fullname, email, phone);
            req.getRequestDispatcher(Constant.Path.REGISTER).forward(req, resp);
            return;
        }

        // Validate password byte length
        if (!ValidationUtil.isValidPassword(password)) {
            req.setAttribute("alert", "Mật khẩu phải từ 6 đến 72 bytes UTF-8!");
            setFormAttributes(req, username, fullname, email, phone);
            req.getRequestDispatcher(Constant.Path.REGISTER).forward(req, resp);
            return;
        }

        // Check username uniqueness
        if (userService.checkExistUsername(username)) {
            req.setAttribute("alert", "Tên đăng nhập đã tồn tại!");
            setFormAttributes(req, username, fullname, email, phone);
            req.getRequestDispatcher(Constant.Path.REGISTER).forward(req, resp);
            return;
        }

        // Check email uniqueness
        if (userService.checkExistEmail(email)) {
            req.setAttribute("alert", "Email đã tồn tại!");
            setFormAttributes(req, username, fullname, email, phone);
            req.getRequestDispatcher(Constant.Path.REGISTER).forward(req, resp);
            return;
        }

        boolean isSuccess = userService.register(email, password, username, fullname, phone);
        if (isSuccess) {
            HttpSession session = req.getSession(true);
            session.setAttribute(Constant.SESSION_PENDING_REGISTER_EMAIL, email);
            resp.sendRedirect(req.getContextPath() + "/verify-otp");
        } else {
            req.setAttribute("alert", "Đăng ký thất bại, hệ thống đang bận. Vui lòng thử lại sau!");
            setFormAttributes(req, username, fullname, email, phone);
            req.getRequestDispatcher(Constant.Path.REGISTER).forward(req, resp);
        }
    }

    private void setFormAttributes(HttpServletRequest req, String username, String fullname, String email, String phone) {
        req.setAttribute("username", username);
        req.setAttribute("fullname", fullname);
        req.setAttribute("email", email);
        req.setAttribute("phone", phone);
    }
}
