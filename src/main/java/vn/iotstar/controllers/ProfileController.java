package vn.iotstar.controllers;

import java.io.IOException;
import java.io.InputStream;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import vn.iotstar.dto.PendingEmailUpdate;
import vn.iotstar.entity.User;
import vn.iotstar.enums.ResendResult;
import vn.iotstar.enums.VerifyResult;
import vn.iotstar.service.IEmailChangeService;
import vn.iotstar.service.IImageStorageService;
import vn.iotstar.service.IUserService;
import vn.iotstar.service.UserServiceImpl;
import vn.iotstar.service.impl.CloudinaryStorageServiceImpl;
import vn.iotstar.service.impl.EmailChangeServiceImpl;
import vn.iotstar.util.Constant;
import vn.iotstar.util.CsrfUtil;
import vn.iotstar.util.ValidationUtil;

@WebServlet(urlPatterns = {"/profile", "/profile/verify-otp", "/profile/resend-otp", "/profile/cancel-otp"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 10 * 1024 * 1024
)
public class ProfileController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private IUserService userService;
    private IEmailChangeService emailChangeService;
    private IImageStorageService imageStorageService;

    public ProfileController() {
        this.userService = new UserServiceImpl();
        this.emailChangeService = new EmailChangeServiceImpl();
        this.imageStorageService = new CloudinaryStorageServiceImpl();
    }

    public ProfileController(IUserService userService, IEmailChangeService emailChangeService, IImageStorageService imageStorageService) {
        this.userService = userService;
        this.emailChangeService = emailChangeService;
        this.imageStorageService = imageStorageService;
    }

    @Override
    public void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User sessionUser = (session != null) ? (User) session.getAttribute("account") : null;
        if (sessionUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Chuyển Flash Messages từ Session sang Request Scope
        String flashSuccess = (String) session.getAttribute(Constant.SESSION_FLASH_SUCCESS);
        if (flashSuccess != null) {
            req.setAttribute("successMessage", flashSuccess);
            session.removeAttribute(Constant.SESSION_FLASH_SUCCESS);
        }
        String flashError = (String) session.getAttribute(Constant.SESSION_FLASH_ERROR);
        if (flashError != null) {
            req.setAttribute("errorMessage", flashError);
            session.removeAttribute(Constant.SESSION_FLASH_ERROR);
        }

        CsrfUtil.getToken(session);
        String path = req.getServletPath();

        if ("/profile/verify-otp".equals(path)) {
            PendingEmailUpdate pending = (PendingEmailUpdate) session.getAttribute(Constant.SESSION_PENDING_EMAIL_UPDATE);
            if (pending == null) {
                session.setAttribute(Constant.SESSION_FLASH_ERROR, "Không có yêu cầu đổi email nào đang chờ xác thực.");
                resp.sendRedirect(req.getContextPath() + "/profile");
                return;
            }
            req.setAttribute("pending", pending);
            req.getRequestDispatcher("/views/profile-verify-otp.jsp").forward(req, resp);
            return;
        }

        // Mặc định hoặc /profile: Tải dữ liệu mới nhất từ CSDL
        User dbUser = userService.get(sessionUser.getId());
        if (dbUser != null) {
            session.setAttribute("account", dbUser);
            req.setAttribute("user", dbUser);
        } else {
            req.setAttribute("user", sessionUser);
        }
        req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
    }

    @Override
    public void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Xử lý ngoại lệ Multipart khi dung lượng vượt quá 5MB
        if (req.getContentType() != null && req.getContentType().toLowerCase().startsWith("multipart/")) {
            try {
                req.getParts();
            } catch (IllegalStateException | ServletException e) {
                HttpSession session = req.getSession(false);
                if (session != null) {
                    session.setAttribute(Constant.SESSION_FLASH_ERROR, "Dung lượng file tải lên vượt quá giới hạn cho phép (tối đa 5MB)!");
                }
                resp.sendRedirect(req.getContextPath() + "/profile");
                return;
            }
        }

        // 1. Kiểm tra CSRF Token
        if (!CsrfUtil.isValid(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "CSRF Token không hợp lệ hoặc đã hết hạn!");
            return;
        }

        HttpSession session = req.getSession(false);
        User sessionUser = (session != null) ? (User) session.getAttribute("account") : null;
        if (sessionUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String path = req.getServletPath();

        // 2. Xử lý Hủy yêu cầu đổi email
        if ("/profile/cancel-otp".equals(path)) {
            session.removeAttribute(Constant.SESSION_PENDING_EMAIL_UPDATE);
            session.setAttribute(Constant.SESSION_FLASH_SUCCESS, "Đã hủy yêu cầu thay đổi địa chỉ email.");
            resp.sendRedirect(req.getContextPath() + "/profile");
            return;
        }

        // 3. Xử lý Gửi lại mã OTP
        if ("/profile/resend-otp".equals(path)) {
            PendingEmailUpdate pending = (PendingEmailUpdate) session.getAttribute(Constant.SESSION_PENDING_EMAIL_UPDATE);
            if (pending == null) {
                session.setAttribute(Constant.SESSION_FLASH_ERROR, "Không tìm thấy yêu cầu đổi email đang chờ.");
                resp.sendRedirect(req.getContextPath() + "/profile");
                return;
            }

            ResendResult result = emailChangeService.resendOtp(pending, sessionUser.getId());
            switch (result) {
                case SENT:
                    session.setAttribute(Constant.SESSION_FLASH_SUCCESS, "Mã OTP mới đã được gửi tới email: " + pending.getNewEmail());
                    resp.sendRedirect(req.getContextPath() + "/profile/verify-otp");
                    break;
                case COOLDOWN_ACTIVE:
                    session.setAttribute(Constant.SESSION_FLASH_ERROR, "Vui lòng chờ 60 giây trước khi yêu cầu gửi lại OTP.");
                    resp.sendRedirect(req.getContextPath() + "/profile/verify-otp");
                    break;
                case MAX_RESENDS_EXCEEDED:
                    session.removeAttribute(Constant.SESSION_PENDING_EMAIL_UPDATE);
                    session.setAttribute(Constant.SESSION_FLASH_ERROR, "Bạn đã vượt quá số lần gửi lại mã OTP tối đa (3 lần). Yêu cầu đổi email đã bị hủy.");
                    resp.sendRedirect(req.getContextPath() + "/profile");
                    break;
                default:
                    resp.sendRedirect(req.getContextPath() + "/login");
                    break;
            }
            return;
        }

        // 4. Xử lý Xác nhận mã OTP
        if ("/profile/verify-otp".equals(path)) {
            PendingEmailUpdate pending = (PendingEmailUpdate) session.getAttribute(Constant.SESSION_PENDING_EMAIL_UPDATE);
            if (pending == null) {
                session.setAttribute(Constant.SESSION_FLASH_ERROR, "Không có yêu cầu đổi email nào đang chờ xác thực.");
                resp.sendRedirect(req.getContextPath() + "/profile");
                return;
            }

            String otpInput = req.getParameter("otp");
            VerifyResult vResult = emailChangeService.verifyOtp(pending, sessionUser.getId(), otpInput);

            switch (vResult) {
                case SUCCESS:
                    boolean confirmed = emailChangeService.confirmEmailUpdate(sessionUser.getId(), pending.getNewEmail(), sessionUser.getEmail());
                    session.removeAttribute(Constant.SESSION_PENDING_EMAIL_UPDATE);
                    if (confirmed) {
                        sessionUser.setEmail(pending.getNewEmail());
                        session.setAttribute("account", sessionUser);
                        session.setAttribute(Constant.SESSION_FLASH_SUCCESS, "Cập nhật địa chỉ email thành công!");
                    } else {
                        session.setAttribute(Constant.SESSION_FLASH_ERROR, "Đổi email thất bại: Địa chỉ email mới đã được sử dụng bởi tài khoản khác trong hệ thống!");
                    }
                    resp.sendRedirect(req.getContextPath() + "/profile");
                    break;
                case INVALID_OTP:
                    int remaining = EmailChangeServiceImpl.MAX_ATTEMPTS - pending.getAttempts();
                    session.setAttribute(Constant.SESSION_FLASH_ERROR, "Mã OTP không chính xác! Bạn còn " + remaining + " lần thử.");
                    resp.sendRedirect(req.getContextPath() + "/profile/verify-otp");
                    break;
                case ATTEMPTS_EXCEEDED:
                    session.removeAttribute(Constant.SESSION_PENDING_EMAIL_UPDATE);
                    session.setAttribute(Constant.SESSION_FLASH_ERROR, "Bạn đã nhập sai mã OTP quá 5 lần. Yêu cầu đổi email đã bị hủy để đảm bảo an toàn.");
                    resp.sendRedirect(req.getContextPath() + "/profile");
                    break;
                case EXPIRED:
                    session.removeAttribute(Constant.SESSION_PENDING_EMAIL_UPDATE);
                    session.setAttribute(Constant.SESSION_FLASH_ERROR, "Mã OTP đã hết hạn (quá 5 phút). Yêu cầu đổi email đã bị hủy.");
                    resp.sendRedirect(req.getContextPath() + "/profile");
                    break;
                default:
                    resp.sendRedirect(req.getContextPath() + "/login");
                    break;
            }
            return;
        }

        // 5. Xử lý Cập nhật Profile (POST /profile) theo quy trình Validate-First
        if ("/profile".equals(path)) {
            // 5.1. Kiểm tra khóa mật khẩu 15 phút do nhập sai nhiều lần
            Long lockUntil = (Long) session.getAttribute(Constant.SESSION_PASSWORD_LOCK_UNTIL);
            if (lockUntil != null) {
                if (System.currentTimeMillis() < lockUntil) {
                    long remMins = Math.max(1, (lockUntil - System.currentTimeMillis()) / 60000);
                    req.setAttribute("errorMessage", "Tài khoản bị tạm khóa chức năng đổi mật khẩu/email do nhập sai mật khẩu quá 5 lần. Vui lòng thử lại sau " + remMins + " phút.");
                    req.setAttribute("user", sessionUser);
                    req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
                    return;
                } else {
                    session.removeAttribute(Constant.SESSION_PASSWORD_LOCK_UNTIL);
                    session.removeAttribute(Constant.SESSION_PASSWORD_FAIL_COUNT);
                }
            }

            // 5.2. Đọc các tham số gửi lên
            String fullname = req.getParameter("fullname");
            String phone = req.getParameter("phone");
            String newEmail = req.getParameter("email");
            String currentPassword = req.getParameter("currentPassword");
            Part imagePart = null;
            try {
                imagePart = req.getPart("image");
            } catch (Exception ignored) {
            }

            // 5.3. Kiểm tra tính hợp lệ dữ liệu cơ bản (Fullname, Phone)
            if (fullname == null || fullname.isBlank() || fullname.trim().length() > 100) {
                req.setAttribute("errorMessage", "Họ và tên không được để trống và tối đa 100 ký tự!");
                req.setAttribute("user", sessionUser);
                req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
                return;
            }

            if (!ValidationUtil.isValidPhone(phone)) {
                req.setAttribute("errorMessage", "Số điện thoại không hợp lệ! Vui lòng nhập số điện thoại Việt Nam gồm 10 chữ số (bắt đầu bằng 03, 05, 07, 08, 09).");
                req.setAttribute("user", sessionUser);
                req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
                return;
            }

            // 5.4. Kiểm tra file ảnh avatar (Magic Bytes, Extension, Size)
            boolean hasNewAvatar = false;
            if (imagePart != null && imagePart.getSize() > 0) {
                if (imagePart.getSize() > 5 * 1024 * 1024) {
                    req.setAttribute("errorMessage", "Kích thước ảnh đại diện không được vượt quá 5MB!");
                    req.setAttribute("user", sessionUser);
                    req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
                    return;
                }
                String submittedName = imagePart.getSubmittedFileName();
                if (!ValidationUtil.hasValidImageExtension(submittedName)) {
                    req.setAttribute("errorMessage", "Định dạng file không hỗ trợ! Chỉ chấp nhận .jpg, .jpeg, .png, .webp.");
                    req.setAttribute("user", sessionUser);
                    req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
                    return;
                }
                byte[] header = new byte[16];
                try (InputStream is = imagePart.getInputStream()) {
                    int readBytes = is.read(header);
                    if (readBytes < 4 || !ValidationUtil.isValidImageMagicBytes(header)) {
                        req.setAttribute("errorMessage", "Nội dung tệp không phải là định dạng hình ảnh hợp lệ (Magic Bytes không khớp)!");
                        req.setAttribute("user", sessionUser);
                        req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
                        return;
                    }
                }
                hasNewAvatar = true;
            }

            // 5.5. Kiểm tra trường hợp thay đổi email
            String currentEmail = sessionUser.getEmail() != null ? sessionUser.getEmail().trim().toLowerCase() : "";
            String normalizedNewEmail = newEmail != null ? newEmail.trim().toLowerCase() : "";
            boolean isEmailChanging = !normalizedNewEmail.isEmpty() && !normalizedNewEmail.equalsIgnoreCase(currentEmail);

            if (isEmailChanging) {
                if (!ValidationUtil.isValidEmail(normalizedNewEmail)) {
                    req.setAttribute("errorMessage", "Định dạng địa chỉ email mới không hợp lệ!");
                    req.setAttribute("user", sessionUser);
                    req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
                    return;
                }

                if (currentPassword == null || currentPassword.isEmpty()) {
                    req.setAttribute("errorMessage", "Vui lòng nhập mật khẩu hiện tại để xác nhận thay đổi địa chỉ email!");
                    req.setAttribute("user", sessionUser);
                    req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
                    return;
                }

                User dbUser = userService.get(sessionUser.getId());
                User userForCheck = dbUser != null ? dbUser : sessionUser;
                if (!userService.verifyPassword(userForCheck, currentPassword)) {
                    Integer failCount = (Integer) session.getAttribute(Constant.SESSION_PASSWORD_FAIL_COUNT);
                    failCount = (failCount == null) ? 1 : failCount + 1;
                    if (failCount >= 5) {
                        session.setAttribute(Constant.SESSION_PASSWORD_LOCK_UNTIL, System.currentTimeMillis() + 15 * 60_000L);
                        session.removeAttribute(Constant.SESSION_PASSWORD_FAIL_COUNT);
                        req.setAttribute("errorMessage", "Bạn đã nhập sai mật khẩu 5 lần. Chức năng đổi email tạm khóa trong 15 phút.");
                    } else {
                        session.setAttribute(Constant.SESSION_PASSWORD_FAIL_COUNT, failCount);
                        int remaining = 5 - failCount;
                        req.setAttribute("errorMessage", "Mật khẩu hiện tại không chính xác! Bạn còn " + remaining + " lần thử.");
                    }
                    req.setAttribute("user", sessionUser);
                    req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
                    return;
                }

                if (userService.checkExistEmail(normalizedNewEmail)) {
                    req.setAttribute("errorMessage", "Địa chỉ email này đã được sử dụng bởi một tài khoản khác trong hệ thống!");
                    req.setAttribute("user", sessionUser);
                    req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
                    return;
                }
            }

            // 5.6. Validate-First hoàn tất thành công -> Bắt đầu ghi dữ liệu
            session.removeAttribute(Constant.SESSION_PASSWORD_FAIL_COUNT);

            if (hasNewAvatar) {
                try {
                    String uploadedAvatarUrl = imageStorageService.uploadAvatar(imagePart, sessionUser.getId());
                    sessionUser.setAvatar(uploadedAvatarUrl);
                } catch (Exception e) {
                    req.setAttribute("errorMessage", "Tải ảnh đại diện thất bại: " + e.getMessage());
                    req.setAttribute("user", sessionUser);
                    req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
                    return;
                }
            }

            sessionUser.setFullname(fullname.trim());
            sessionUser.setPhone(phone.trim());
            userService.updateProfile(sessionUser);
            session.setAttribute("account", sessionUser);

            if (isEmailChanging) {
                PendingEmailUpdate existingPending = (PendingEmailUpdate) session.getAttribute(Constant.SESSION_PENDING_EMAIL_UPDATE);
                try {
                    PendingEmailUpdate newPending = emailChangeService.initiate(sessionUser, normalizedNewEmail, existingPending);
                    session.setAttribute(Constant.SESSION_PENDING_EMAIL_UPDATE, newPending);
                    session.setAttribute(Constant.SESSION_FLASH_SUCCESS, "Thông tin hồ sơ đã được lưu. Mã OTP xác thực đã được gửi tới email mới: " + normalizedNewEmail);
                    resp.sendRedirect(req.getContextPath() + "/profile/verify-otp");
                    return;
                } catch (IllegalStateException ise) {
                    req.setAttribute("errorMessage", ise.getMessage());
                    req.setAttribute("user", sessionUser);
                    req.getRequestDispatcher("/views/profile.jsp").forward(req, resp);
                    return;
                }
            }

            session.setAttribute(Constant.SESSION_FLASH_SUCCESS, "Cập nhật hồ sơ cá nhân thành công!");
            resp.sendRedirect(req.getContextPath() + "/profile");
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/profile");
    }
}
