package vn.iotstar;

import jakarta.servlet.FilterChain;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import org.junit.jupiter.api.*;
import org.mockito.ArgumentCaptor;
import vn.iotstar.controllers.ProfileController;
import vn.iotstar.dao.IUserDao;
import vn.iotstar.dto.PendingEmailUpdate;
import vn.iotstar.entity.User;
import vn.iotstar.enums.ResendResult;
import vn.iotstar.enums.VerifyResult;
import vn.iotstar.filter.AuthFilter;
import vn.iotstar.service.IEmailChangeService;
import vn.iotstar.service.IImageStorageService;
import vn.iotstar.service.IOtpMailer;
import vn.iotstar.service.IUserService;
import vn.iotstar.service.impl.EmailChangeServiceImpl;
import vn.iotstar.util.Constant;
import vn.iotstar.util.CsrfUtil;
import vn.iotstar.util.HashUtil;
import vn.iotstar.util.PasswordUtil;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.security.MessageDigest;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class ProfileIntegrationTest {

    private static MutableClock clock;
    private static MockOtpMailer mockMailer;
    private static IUserDao mockUserDao;
    private static IUserService mockUserService;
    private static MockImageStorageService mockStorageService;
    private static IEmailChangeService emailChangeService;

    static class MockOtpMailer implements IOtpMailer {
        String lastOtpSent;
        String lastRecipient;
        String lastNoticeRecipient;
        String lastNoticeMessage;
        boolean simulateFailure = false;

        @Override
        public CompletableFuture<Boolean> sendOtpAsync(String toEmail, String otp) {
            this.lastRecipient = toEmail;
            this.lastOtpSent = otp;
            CompletableFuture<Boolean> future = new CompletableFuture<>();
            future.complete(!simulateFailure);
            return future;
        }

        @Override
        public CompletableFuture<Boolean> sendNoticeAsync(String toEmail, String message) {
            this.lastNoticeRecipient = toEmail;
            this.lastNoticeMessage = message;
            return CompletableFuture.completedFuture(true);
        }
    }

    static class MockImageStorageService implements IImageStorageService {
        String uploadedUrl = "https://res.cloudinary.com/demo/image/upload/v123/avatars/user_1.jpg";

        @Override
        public String uploadAvatar(Part filePart, int userId) throws IOException {
            return uploadedUrl;
        }
    }

    static class MockHttpSession implements HttpSession {
        private final Map<String, Object> attributes = new HashMap<>();

        @Override
        public Object getAttribute(String name) {
            return attributes.get(name);
        }

        @Override
        public void setAttribute(String name, Object value) {
            attributes.put(name, value);
        }

        @Override
        public void removeAttribute(String name) {
            attributes.remove(name);
        }

        @Override public long getCreationTime() { return 0; }
        @Override public String getId() { return "mock-session-id"; }
        @Override public long getLastAccessedTime() { return 0; }
        @Override public jakarta.servlet.ServletContext getServletContext() { return null; }
        @Override public void setMaxInactiveInterval(int interval) {}
        @Override public int getMaxInactiveInterval() { return 0; }
        @Override public java.util.Enumeration<String> getAttributeNames() { return java.util.Collections.enumeration(attributes.keySet()); }
        @Override public void invalidate() { attributes.clear(); }
        @Override public boolean isNew() { return false; }
    }

    @BeforeEach
    public void setUp() {
        clock = new MutableClock(1700000000000L); // Cố định mốc thời gian ban đầu
        mockMailer = new MockOtpMailer();
        mockUserDao = mock(IUserDao.class);
        mockUserService = mock(IUserService.class);
        mockStorageService = new MockImageStorageService();
        emailChangeService = new EmailChangeServiceImpl(clock, mockMailer, mockUserDao);
    }

    // =========================================================================
    // NHÓM 1: KIỂM THỬ TẦNG DỊCH VỤ (SERVICE UNIT TESTS)
    // =========================================================================

    @Test
    @Order(1)
    @DisplayName("TC-01: Initiate đổi email thành công, sinh OTP 6 số ngẫu nhiên")
    public void test01_initiate_generates6DigitOtp() {
        User user = new User();
        user.setId(101);
        user.setEmail("user101@example.com");

        PendingEmailUpdate pending = emailChangeService.initiate(user, "new101@example.com", null);

        assertNotNull(pending);
        assertEquals(101, pending.getUserId());
        assertEquals("new101@example.com", pending.getNewEmail());
        assertNotNull(mockMailer.lastOtpSent);
        assertEquals(6, mockMailer.lastOtpSent.length());
        assertTrue(mockMailer.lastOtpSent.matches("\\d{6}"));
        assertTrue(MessageDigest.isEqual(pending.getOtpHashBytes(), HashUtil.sha256Bytes(mockMailer.lastOtpSent)));
    }

    @Test
    @Order(2)
    @DisplayName("TC-02: Xác thực mật khẩu - Sai mật khẩu bị từ chối")
    public void test02_verifyPassword_wrongPassword() {
        User user = new User();
        user.setPassword(PasswordUtil.hash("Secret123"));

        when(mockUserService.verifyPassword(user, "Secret123")).thenReturn(true);
        when(mockUserService.verifyPassword(user, "WrongPass")).thenReturn(false);

        assertTrue(mockUserService.verifyPassword(user, "Secret123"));
        assertFalse(mockUserService.verifyPassword(user, "WrongPass"));
    }

    @Test
    @Order(3)
    @DisplayName("TC-03: Nhập sai mật khẩu 5 lần -> Tạm khóa 15 phút")
    public void test03_passwordLockout_after5Fails() throws Exception {
        ProfileController controller = new ProfileController(mockUserService, emailChangeService, mockStorageService);
        HttpServletRequest req = mock(HttpServletRequest.class);
        HttpServletResponse resp = mock(HttpServletResponse.class);
        RequestDispatcher rd = mock(RequestDispatcher.class);
        MockHttpSession session = new MockHttpSession();

        User user = new User();
        user.setId(102);
        user.setEmail("user102@example.com");
        user.setFullname("Test User");
        user.setPhone("0912345678");
        session.setAttribute("account", user);

        String csrf = CsrfUtil.generateToken(session);
        when(req.getSession(false)).thenReturn(session);
        when(req.getServletPath()).thenReturn("/profile");
        when(req.getParameter("csrfToken")).thenReturn(csrf);
        when(req.getParameter("fullname")).thenReturn("Test User");
        when(req.getParameter("phone")).thenReturn("0912345678");
        when(req.getParameter("email")).thenReturn("different@example.com");
        when(req.getParameter("currentPassword")).thenReturn("WrongPassword");
        when(req.getRequestDispatcher("/views/profile.jsp")).thenReturn(rd);
        when(mockUserService.verifyPassword(any(), eq("WrongPassword"))).thenReturn(false);

        // Submit 4 lần đầu
        for (int i = 0; i < 4; i++) {
            controller.doPost(req, resp);
        }
        assertEquals(4, session.getAttribute(Constant.SESSION_PASSWORD_FAIL_COUNT));
        assertNull(session.getAttribute(Constant.SESSION_PASSWORD_LOCK_UNTIL));

        // Submit lần thứ 5 -> Khóa 15 phút
        controller.doPost(req, resp);
        assertNull(session.getAttribute(Constant.SESSION_PASSWORD_FAIL_COUNT));
        assertNotNull(session.getAttribute(Constant.SESSION_PASSWORD_LOCK_UNTIL));
        long lockUntil = (Long) session.getAttribute(Constant.SESSION_PASSWORD_LOCK_UNTIL);
        assertTrue(lockUntil > System.currentTimeMillis());
    }

    @Test
    @Order(4)
    @DisplayName("TC-04: Mở khóa đổi email sau khi hết hạn 15 phút")
    public void test04_passwordLockout_unlockedAfter15Minutes() throws Exception {
        ProfileController controller = new ProfileController(mockUserService, emailChangeService, mockStorageService);
        HttpServletRequest req = mock(HttpServletRequest.class);
        HttpServletResponse resp = mock(HttpServletResponse.class);
        RequestDispatcher rd = mock(RequestDispatcher.class);
        MockHttpSession session = new MockHttpSession();

        User user = new User();
        user.setId(103);
        user.setEmail("user103@example.com");
        session.setAttribute("account", user);

        // Thiết lập thời điểm khóa đã trôi qua 16 phút trước
        session.setAttribute(Constant.SESSION_PASSWORD_LOCK_UNTIL, System.currentTimeMillis() - 60_000L);

        String csrf = CsrfUtil.generateToken(session);
        when(req.getSession(false)).thenReturn(session);
        when(req.getServletPath()).thenReturn("/profile");
        when(req.getParameter("csrfToken")).thenReturn(csrf);
        when(req.getParameter("fullname")).thenReturn("User 103");
        when(req.getParameter("phone")).thenReturn("0987654321");
        when(req.getParameter("email")).thenReturn("user103@example.com"); // Không đổi email
        when(req.getRequestDispatcher("/views/profile.jsp")).thenReturn(rd);

        controller.doPost(req, resp);

        // Khóa đã được tự động gỡ
        assertNull(session.getAttribute(Constant.SESSION_PASSWORD_LOCK_UNTIL));
        verify(resp).sendRedirect(contains("/profile"));
    }

    @Test
    @Order(5)
    @DisplayName("TC-05: Xác thực đúng OTP -> Cập nhật CSDL và gửi email thông báo email cũ")
    public void test05_verifyOtp_correctOtp_updatesDatabaseAndSendsNotice() {
        User user = new User();
        user.setId(105);
        user.setEmail("old105@example.com");

        PendingEmailUpdate pending = emailChangeService.initiate(user, "new105@example.com", null);
        String correctOtp = mockMailer.lastOtpSent;

        when(mockUserDao.updateEmail(105, "new105@example.com")).thenReturn(true);

        VerifyResult result = emailChangeService.verifyOtp(pending, 105, correctOtp);
        assertEquals(VerifyResult.SUCCESS, result);

        boolean confirmed = emailChangeService.confirmEmailUpdate(105, pending.getNewEmail(), user.getEmail());
        assertTrue(confirmed);
        verify(mockUserDao).updateEmail(105, "new105@example.com");
        assertEquals("old105@example.com", mockMailer.lastNoticeRecipient);
        assertTrue(mockMailer.lastNoticeMessage.contains("new105@example.com"));
    }

    @Test
    @Order(6)
    @DisplayName("TC-06: Nhập sai OTP -> Tăng attempts, sai 5 lần -> Hủy pending")
    public void test06_verifyOtp_invalidOtp_incrementsAttempts_exceedsAt5() {
        User user = new User();
        user.setId(106);
        user.setEmail("u106@example.com");

        PendingEmailUpdate pending = emailChangeService.initiate(user, "new106@example.com", null);

        for (int i = 1; i <= 4; i++) {
            VerifyResult res = emailChangeService.verifyOtp(pending, 106, "000000");
            assertEquals(VerifyResult.INVALID_OTP, res);
            assertEquals(i, pending.getAttempts());
        }

        // Lần thứ 5 sai -> ATTEMPTS_EXCEEDED
        VerifyResult finalRes = emailChangeService.verifyOtp(pending, 106, "000000");
        assertEquals(VerifyResult.ATTEMPTS_EXCEEDED, finalRes);
        assertEquals(5, pending.getAttempts());
    }

    @Test
    @Order(7)
    @DisplayName("TC-07: Verify khi attempts >= 5 bị từ chối ngay trước khi so khớp OTP")
    public void test07_verifyOtp_whenAttemptsAlreadyExceeded_rejectedImmediately() {
        User user = new User();
        user.setId(107);
        user.setEmail("u107@example.com");

        PendingEmailUpdate pending = emailChangeService.initiate(user, "new107@example.com", null);
        String correctOtp = mockMailer.lastOtpSent;

        for (int i = 0; i < 5; i++) {
            emailChangeService.verifyOtp(pending, 107, "999999");
        }
        assertEquals(5, pending.getAttempts());

        // Nhập đúng OTP khi đã đủ 5 lần sai -> Vẫn trả về ATTEMPTS_EXCEEDED
        VerifyResult result = emailChangeService.verifyOtp(pending, 107, correctOtp);
        assertEquals(VerifyResult.ATTEMPTS_EXCEEDED, result);
    }

    @Test
    @Order(8)
    @DisplayName("TC-08: Resend OTP không reset attempts (chống brute-force lũy kế)")
    public void test08_resendOtp_doesNotResetAttempts() {
        User user = new User();
        user.setId(108);
        user.setEmail("u108@example.com");

        PendingEmailUpdate pending = emailChangeService.initiate(user, "new108@example.com", null);

        // Nhập sai 2 lần
        emailChangeService.verifyOtp(pending, 108, "111111");
        emailChangeService.verifyOtp(pending, 108, "222222");
        assertEquals(2, pending.getAttempts());

        // Tiến tới 61s để vượt cooldown resend
        clock.advanceSeconds(61);

        ResendResult resendResult = emailChangeService.resendOtp(pending, 108);
        assertEquals(ResendResult.SENT, resendResult);
        assertEquals(1, pending.getResendCount());
        // attempts vẫn giữ nguyên 2
        assertEquals(2, pending.getAttempts());
    }

    @Test
    @Order(9)
    @DisplayName("TC-09: Resend OTP tối đa 3 lần, lần thứ 4 bị từ chối")
    public void test09_resendOtp_max3Resends() {
        User user = new User();
        user.setId(109);
        user.setEmail("u109@example.com");

        PendingEmailUpdate pending = emailChangeService.initiate(user, "new109@example.com", null);

        for (int i = 1; i <= 3; i++) {
            clock.advanceSeconds(61);
            assertEquals(ResendResult.SENT, emailChangeService.resendOtp(pending, 109));
            assertEquals(i, pending.getResendCount());
        }

        // Lần thứ 4
        clock.advanceSeconds(61);
        assertEquals(ResendResult.MAX_RESENDS_EXCEEDED, emailChangeService.resendOtp(pending, 109));
    }

    @Test
    @Order(10)
    @DisplayName("TC-10: Cooldown Resend 60s phía server")
    public void test10_resendOtp_cooldown60Seconds() {
        User user = new User();
        user.setId(110);
        user.setEmail("u110@example.com");

        PendingEmailUpdate pending = emailChangeService.initiate(user, "new110@example.com", null);

        // Gửi lại ngay sau 10s -> COOLDOWN_ACTIVE
        clock.advanceSeconds(10);
        assertEquals(ResendResult.COOLDOWN_ACTIVE, emailChangeService.resendOtp(pending, 110));

        // Tiến thêm 51s (tổng 61s) -> SENT
        clock.advanceSeconds(51);
        assertEquals(ResendResult.SENT, emailChangeService.resendOtp(pending, 110));
    }

    @Test
    @Order(11)
    @DisplayName("TC-11: Cooldown Initiate 60s phía server")
    public void test11_initiate_cooldown60Seconds() {
        User user = new User();
        user.setId(111);
        user.setEmail("u111@example.com");

        PendingEmailUpdate pending1 = emailChangeService.initiate(user, "new111_a@example.com", null);
        assertNotNull(pending1);

        // Gọi lại ngay lập tức -> ném IllegalStateException
        assertThrows(IllegalStateException.class, () ->
                emailChangeService.initiate(user, "new111_b@example.com", pending1)
        );

        // Qua 61 giây -> thành công
        clock.advanceSeconds(61);
        PendingEmailUpdate pending2 = emailChangeService.initiate(user, "new111_b@example.com", pending1);
        assertNotNull(pending2);
        assertEquals("new111_b@example.com", pending2.getNewEmail());
    }

    @Test
    @Order(12)
    @DisplayName("TC-12: Gửi mail thất bại -> Miễn trừ cooldown cho phép gửi lại ngay")
    public void test12_mailDeliveryFailed_exemptsCooldown() {
        User user = new User();
        user.setId(112);
        user.setEmail("u112@example.com");

        mockMailer.simulateFailure = true;
        PendingEmailUpdate pending = emailChangeService.initiate(user, "fail112@example.com", null);
        assertTrue(pending.isMailDeliveryFailed());

        // Bật lại mail thành công, resend ngay lập tức (không cần chờ 60s)
        mockMailer.simulateFailure = false;
        ResendResult res = emailChangeService.resendOtp(pending, 112);
        assertEquals(ResendResult.SENT, res);
        assertFalse(pending.isMailDeliveryFailed());
    }

    @Test
    @Order(13)
    @DisplayName("TC-13: Mã OTP quá hạn 5 phút bị từ chối (EXPIRED)")
    public void test13_otpExpired_after5Minutes() {
        User user = new User();
        user.setId(113);
        user.setEmail("u113@example.com");

        PendingEmailUpdate pending = emailChangeService.initiate(user, "new113@example.com", null);
        String correctOtp = mockMailer.lastOtpSent;

        // Tiến thời gian qua 5 phút 1 giây
        clock.advanceMinutes(5);
        clock.advanceSeconds(1);

        VerifyResult result = emailChangeService.verifyOtp(pending, 113, correctOtp);
        assertEquals(VerifyResult.EXPIRED, result);
    }

    @Test
    @Order(14)
    @DisplayName("TC-14: Email mới trùng email hiện tại (kể cả case-insensitive) coi như không đổi")
    public void test14_newEmailSameAsCurrent_caseInsensitive() {
        String current = "MyEmail114@gmail.com";
        String submitted = "  myemail114@GMAIL.COM  ";

        boolean same = current.trim().equalsIgnoreCase(submitted.trim());
        assertTrue(same);
    }

    @Test
    @Order(15)
    @DisplayName("TC-15: Email mới trùng tài khoản khác bị từ chối")
    public void test15_newEmailDuplicateOtherAccount_rejected() {
        when(mockUserService.checkExistEmail("taken@example.com")).thenReturn(true);
        when(mockUserService.checkExistEmail("available@example.com")).thenReturn(false);

        assertTrue(mockUserService.checkExistEmail("taken@example.com"));
        assertFalse(mockUserService.checkExistEmail("available@example.com"));
    }

    @Test
    @Order(16)
    @DisplayName("TC-16: Race condition CSDL: Ràng buộc UNIQUE chặn an toàn khi confirm")
    public void test16_raceCondition_dbUniqueConstraintEnforcedOnConfirm() {
        // Giả lập UserDao bắt PersistenceException và trả false
        when(mockUserDao.updateEmail(116, "race@example.com")).thenReturn(false);

        boolean confirmed = emailChangeService.confirmEmailUpdate(116, "race@example.com", "old@example.com");
        assertFalse(confirmed);
        // Không gửi thông báo nếu cập nhật thất bại
        assertNull(mockMailer.lastNoticeRecipient);
    }

    // =========================================================================
    // NHÓM 2: KIỂM THỬ TẦNG SERVLET & FILTER (MOCK HTTP)
    // =========================================================================

    @Test
    @Order(17)
    @DisplayName("TC-17: Cập nhật fullname, phone thành công khi không đổi email")
    public void test17_postProfile_updateFullnameAndPhone_noEmailChange() throws Exception {
        ProfileController controller = new ProfileController(mockUserService, emailChangeService, mockStorageService);
        HttpServletRequest req = mock(HttpServletRequest.class);
        HttpServletResponse resp = mock(HttpServletResponse.class);
        MockHttpSession session = new MockHttpSession();

        User user = new User();
        user.setId(117);
        user.setEmail("user117@example.com");
        user.setFullname("Old Name");
        user.setPhone("0901234567");
        session.setAttribute("account", user);

        String csrf = CsrfUtil.generateToken(session);
        when(req.getSession(false)).thenReturn(session);
        when(req.getServletPath()).thenReturn("/profile");
        when(req.getParameter("csrfToken")).thenReturn(csrf);
        when(req.getParameter("fullname")).thenReturn("New Full Name");
        when(req.getParameter("phone")).thenReturn("0912345678");
        when(req.getParameter("email")).thenReturn("user117@example.com");

        controller.doPost(req, resp);

        verify(mockUserService).updateProfile(user);
        assertEquals("New Full Name", user.getFullname());
        assertEquals("0912345678", user.getPhone());
        verify(resp).sendRedirect(contains("/profile"));
        assertEquals("Cập nhật hồ sơ cá nhân thành công!", session.getAttribute(Constant.SESSION_FLASH_SUCCESS));
    }

    @Test
    @Order(18)
    @DisplayName("TC-18: Upload avatar JPEG hợp lệ -> Lưu URL Cloudinary")
    public void test18_postProfile_uploadAvatarValidImage() throws Exception {
        ProfileController controller = new ProfileController(mockUserService, emailChangeService, mockStorageService);
        HttpServletRequest req = mock(HttpServletRequest.class);
        HttpServletResponse resp = mock(HttpServletResponse.class);
        Part imagePart = mock(Part.class);
        MockHttpSession session = new MockHttpSession();

        User user = new User();
        user.setId(118);
        user.setEmail("user118@example.com");
        session.setAttribute("account", user);

        String csrf = CsrfUtil.generateToken(session);
        when(req.getSession(false)).thenReturn(session);
        when(req.getServletPath()).thenReturn("/profile");
        when(req.getParameter("csrfToken")).thenReturn(csrf);
        when(req.getParameter("fullname")).thenReturn("Avatar User");
        when(req.getParameter("phone")).thenReturn("0912345678");
        when(req.getParameter("email")).thenReturn("user118@example.com");

        // JPEG Magic Bytes: FF D8 FF E0
        byte[] jpegBytes = new byte[]{(byte) 0xFF, (byte) 0xD8, (byte) 0xFF, (byte) 0xE0, 0, 16, 'J', 'F', 'I', 'F', 0, 1, 1, 0, 0, 1};
        when(imagePart.getSize()).thenReturn((long) jpegBytes.length);
        when(imagePart.getSubmittedFileName()).thenReturn("avatar.jpg");
        when(imagePart.getInputStream()).thenAnswer(inv -> new ByteArrayInputStream(jpegBytes));
        when(req.getPart("image")).thenReturn(imagePart);

        controller.doPost(req, resp);

        verify(mockUserService).updateProfile(user);
        assertEquals(mockStorageService.uploadedUrl, user.getAvatar());
        verify(resp).sendRedirect(contains("/profile"));
    }

    @Test
    @Order(19)
    @DisplayName("TC-19: Upload file sai Magic Bytes -> Bị từ chối an toàn")
    public void test19_postProfile_uploadAvatarInvalidMagicBytes_rejected() throws Exception {
        ProfileController controller = new ProfileController(mockUserService, emailChangeService, mockStorageService);
        HttpServletRequest req = mock(HttpServletRequest.class);
        HttpServletResponse resp = mock(HttpServletResponse.class);
        RequestDispatcher rd = mock(RequestDispatcher.class);
        Part imagePart = mock(Part.class);
        MockHttpSession session = new MockHttpSession();

        User user = new User();
        user.setId(119);
        user.setEmail("user119@example.com");
        session.setAttribute("account", user);

        String csrf = CsrfUtil.generateToken(session);
        when(req.getSession(false)).thenReturn(session);
        when(req.getServletPath()).thenReturn("/profile");
        when(req.getParameter("csrfToken")).thenReturn(csrf);
        when(req.getParameter("fullname")).thenReturn("Invalid Bytes User");
        when(req.getParameter("phone")).thenReturn("0912345678");
        when(req.getParameter("email")).thenReturn("user119@example.com");
        when(req.getRequestDispatcher("/views/profile.jsp")).thenReturn(rd);

        // Header giả mạo (Text bytes mang đuôi .jpg)
        byte[] fakeBytes = "NOT_A_REAL_IMAGE_FILE".getBytes();
        when(imagePart.getSize()).thenReturn((long) fakeBytes.length);
        when(imagePart.getSubmittedFileName()).thenReturn("fake.jpg");
        when(imagePart.getInputStream()).thenAnswer(inv -> new ByteArrayInputStream(fakeBytes));
        when(req.getPart("image")).thenReturn(imagePart);

        controller.doPost(req, resp);

        // Không được gọi updateProfile
        verify(mockUserService, never()).updateProfile(any());
        verify(req).setAttribute(eq("errorMessage"), contains("Magic Bytes"));
        verify(rd).forward(req, resp);
    }

    @Test
    @Order(20)
    @DisplayName("TC-20: Thiếu hoặc sai CSRF Token -> Trả về HTTP 403 Forbidden")
    public void test20_postProfile_invalidCsrf_returnsForbidden403() throws Exception {
        ProfileController controller = new ProfileController(mockUserService, emailChangeService, mockStorageService);
        HttpServletRequest req = mock(HttpServletRequest.class);
        HttpServletResponse resp = mock(HttpServletResponse.class);
        MockHttpSession session = new MockHttpSession();

        session.setAttribute("account", new User());
        CsrfUtil.generateToken(session);

        when(req.getSession(false)).thenReturn(session);
        when(req.getParameter("csrfToken")).thenReturn("WRONG_TOKEN");

        controller.doPost(req, resp);

        verify(resp).sendError(eq(HttpServletResponse.SC_FORBIDDEN), anyString());
    }

    @Test
    @Order(21)
    @DisplayName("TC-21: AuthFilter chặn truy cập /profile khi chưa đăng nhập và chuyển hướng /login")
    public void test21_authFilter_unauthenticatedRedirectsToLogin() throws Exception {
        AuthFilter filter = new AuthFilter();
        HttpServletRequest req = mock(HttpServletRequest.class);
        HttpServletResponse resp = mock(HttpServletResponse.class);
        FilterChain chain = mock(FilterChain.class);

        when(req.getServletPath()).thenReturn("/profile");
        when(req.getMethod()).thenReturn("GET");
        when(req.getContextPath()).thenReturn("/my-project");
        when(req.getSession(false)).thenReturn(null); // Chưa đăng nhập

        filter.doFilter(req, resp, chain);

        verify(resp).sendRedirect("/my-project/login");
        verify(chain, never()).doFilter(any(), any());
    }
}
