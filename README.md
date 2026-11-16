## 1. Mục tiêu & Các chức năng hoàn thành

Dự án hiện thực trọn vẹn và an toàn 3 yêu cầu trọng tâm của buổi học ngày 16/11/2026:

1. **Bổ sung chức năng kích hoạt tài khoản bằng OTP gửi qua email khi đăng ký tài khoản:**
   - Người dùng đăng ký tài khoản mới (`/register`): tài khoản được tạo ở trạng thái chưa kích hoạt (`status = 0`).
   - Mã OTP 6 chữ số ngẫu nhiên được sinh bằng bộ sinh số an toàn mật mã `SecureRandom`.
   - Gửi email OTP bất đồng bộ (`sendOtpAsync`) qua `ThreadPoolExecutor` có bounded queue, không làm nghẽn luồng xử lý web request.
   - Thời hạn sử dụng mã OTP (5 phút) được worker cập nhật ngay trước khi gửi email, tránh hao hụt thời gian do xếp hàng hoặc race condition.
   - Khi hàng đợi đầy (`RejectedExecutionException`) hoặc gửi SMTP lỗi, hệ thống tự động giải phóng cooldown và hủy triệt để OTP mồ côi (`cancelOtp`).
   - Giao diện xác thực `/verify-otp` hỗ trợ đếm ngược 60s cho nút gửi lại mã OTP.
   - Giới hạn nhập sai tối đa 5 lần: lần sai 1..4 tăng biến đếm cảnh báo; lần sai thứ 5 hủy mã ngay lập tức.
   - Câu lệnh cập nhật nguyên tử (`consumeRegisterOtp`) ngăn chặn race condition khi nhiều request xác thực đồng thời.

2. **Chức năng đăng nhập với mật khẩu mã hóa BCrypt & Đăng xuất:**
   - Mã hóa mật khẩu một chiều bằng **BCrypt** (cost factor = 10) với `jbcrypt:0.4`.
   - Kiểm tra giới hạn độ dài mật khẩu nghiêm ngặt $\le 72$ byte UTF-8 theo tiêu chuẩn BCrypt.
   - Cơ chế nâng cấp mật khẩu tự động (**Lazy re-hash**): tài khoản cũ dạng plaintext khi đăng nhập thành công sẽ tự động được băm lại thành chuẩn BCrypt trong cơ sở dữ liệu.
   - Kiểm tra trạng thái tài khoản: từ chối và yêu cầu xác thực OTP nếu `status != 1`.
   - Cơ chế **Remember Me** bảo mật cao (Single Active Device Session): sinh token ngẫu nhiên 32-byte, băm SHA-256 lưu DB, xoay token nguyên tử (Token Rotation) tại mỗi phiên làm việc, chống Replay Attack và kiểm tra điều kiện `status = 1`.
   - Đăng xuất (`/logout`): thu hồi và xóa sạch token trong DB, xóa session và hủy cookie trình duyệt.
   - Phòng chống **Session Fixation** bằng `req.changeSessionId()` khi đăng nhập thành công.

3. **Chức năng quên mật khẩu & đặt lại mật khẩu mới qua OTP Email:**
   - Người dùng nhập email tại `/forgot-password`: phản hồi timing-safe không để lộ sự tồn tại của tài khoản.
   - Cơ chế cooldown 60 giây (`otpCooldownAt`) nguyên tử chống spam gửi yêu cầu.
   - Giao diện đặt lại mật khẩu `/reset-password`: tiếp nhận mã OTP, mật khẩu mới và xác nhận mật khẩu.
   - Cập nhật mật khẩu mới băm BCrypt nguyên tử (`consumeForgotPasswordOtp`), tiêu thụ OTP và giữ nguyên trạng thái tài khoản.

---

## 2. Công nghệ sử dụng

- **Java Version:** OpenJDK 17 / 21
- **JPA & ORM Framework:** Hibernate ORM 7.4.6.Final (JPA 3.0 - `jakarta.persistence.*`)
- **Mã hóa & Bảo mật:** `org.mindrot:jbcrypt:0.4`, SHA-256 (`HashUtil`), `SecureRandom`
- **Gửi Email Bất đồng bộ:** `org.eclipse.angus:jakarta.mail:2.0.3` (Jakarta Mail), Java `ThreadPoolExecutor`
- **Web Platform:** Jakarta Servlet 6.1, JSP 4.0, JSTL 3.0.1 (Tomcat 11)
- **Database:** MySQL 8.x / 8.4 (`mysql-connector-j:8.4.0`)
- **Kiểm thử tự động:** JUnit 5 (`junit-jupiter:5.10.2`), Maven Surefire Plugin 3.2.5
- **Build Tool:** Apache Maven 3.x

---

## 3. Cấu trúc Dự án (Checklist 25 File)

```
my-project/
├── pom.xml                                     # Maven dependencies: jbcrypt, jakarta.mail, junit-jupiter
├── database.sql                                # DDL schema_version, users, Stored Procedure migration có lock
├── database-lab-seed.sql                       # Fixtures kiểm thử lab (lmh, manager, user, legacy_user)
├── src/main/java/vn/iotstar/
│   ├── config/
│   │   ├── JpaConfig.java                      # Cấu hình EntityManagerFactory
│   │   └── AppContextListener.java             # Quản lý ThreadPoolExecutor gửi mail
│   ├── entity/
│   │   ├── User.java                           # Entity User (status, code, otpExpired, otpAttempts, ...)
│   │   ├── Category.java & Video.java          # Entity Category & Video (Bài tập trước)
│   ├── util/
│   │   ├── PasswordUtil.java                   # Pure utility băm BCrypt cost 10, kiểm tra <= 72 bytes
│   │   ├── HashUtil.java                       # Tiện ích băm SHA-256, sinh token SecureRandom
│   │   ├── EmailUtil.java                      # Jakarta Mail async, DEV_MODE logger, orphan cleanup
│   │   └── Constant.java                       # Cấu hình DEV_MODE, SMTP, Session keys, Cookie names
│   ├── dao/
│   │   ├── IUserDao.java & UserDao.java        # Atomic queries: lockOtpRequest, consumeOtp, rotateToken
│   │   └── ICategoryDao.java & CategoryDao.java
│   ├── service/
│   │   ├── IUserService.java & UserServiceImpl.java # Nghiệp vụ OTP, re-hash, Remember Me rotation
│   │   └── ICategoryService.java & CategoryServiceImpl.java
│   ├── filter/
│   │   ├── RememberMeFilter.java               # Auto login qua cookie remember-me & xoay token mới
│   │   └── AuthFilter.java                     # Phân quyền truy cập các đường dẫn quản trị
│   └── controllers/
│       ├── RegisterController.java             # Tiếp nhận đăng ký, băm mật khẩu, sinh OTP
│       ├── VerifyOtpController.java            # Xác thực OTP kích hoạt (/verify-otp, /resend-otp)
│       ├── LoginController.java                # Đăng nhập BCrypt, Remember Me, changeSessionId
│       ├── LogoutController.java               # Đăng xuất an toàn, xóa cookie, clear token DB
│       ├── ForgotPasswordController.java       # Quên mật khẩu (/forgot-password)
│       ├── ResetPasswordController.java        # Đặt lại mật khẩu (/reset-password, /resend-reset-otp)
│       └── WaitingController.java, CategoryController.java, HomeController.java...
├── src/test/java/vn/iotstar/
│   └── AuthIntegrationTest.java                # Bộ kiểm thử 8 kịch bản tự động (TC-01 -> TC-08)
└── src/main/webapp/views/
    ├── login.jsp & register.jsp                # View đăng nhập (link quên mk, remember me) & đăng ký
    └── auth/
        ├── verify-otp.jsp                      # Giao diện nhập OTP kích hoạt 6 số & đếm ngược 60s
        ├── forgot-password.jsp                 # Giao diện gửi yêu cầu OTP quên mật khẩu
        └── reset-password.jsp                  # Giao diện nhập OTP và mật khẩu mới
```

---

## 4. Hướng dẫn Triển khai & Kiểm thử

### Bước 1: Cấu hình Cơ sở dữ liệu MySQL
1. Khởi chạy MySQL Server (port 3306).
2. Chạy migration cơ sở dữ liệu:
   ```bash
   mysql -u root -p123456 servletjpa < database.sql
   ```
3. Nạp dữ liệu seed kiểm thử lab:
   ```bash
   mysql -u root -p123456 servletjpa < database-lab-seed.sql
   ```

### Bước 2: Chạy Toàn bộ 8 Kịch bản Kiểm thử Tự động (JUnit 5)
Chạy lệnh kiểm thử tự động của Maven:
```bash
mvn test
```
Kết quả kiểm thử thực tế:
- **TC-01: BCrypt Hashing & Password Limits**: Kiểm tra băm BCrypt cost 10 và chặn mật khẩu quá 72 bytes UTF-8.
- **TC-02: Instant Verification**: Xác thực thành công ngay khi nhận mail (thời hạn OTP đã được worker ghi nhận trước).
- **TC-03: Expired OTP**: Từ chối mã OTP đã quá hạn 5 phút.
- **TC-04: Fifth Attempt Cancellation**: Lần sai 1..4 tăng biến đếm; lần sai thứ 5 hủy mã tức thì.
- **TC-05: Concurrency Race on Same OTP**: 2 luồng cạnh tranh cùng 1 mã OTP, duy nhất 1 luồng thành công.
- **TC-06: OTP Orphan Cleanup**: Hủy OTP và giải phóng cooldown khi gặp lỗi gửi hoặc hàng đợi đầy.
- **TC-07: Remember Me Token Rotation & Status = 1**: Xoay token SHA-256 nguyên tử, chống replay, từ chối tài khoản chưa kích hoạt.
- **TC-08: Legacy Plaintext Re-hash**: Tài khoản plaintext cũ tự động băm lại BCrypt khi đăng nhập.

### Bước 3: Đóng gói WAR & Triển khai Tomcat
```bash
mvn clean package
cp target/my-project.war /home/lmh/tools/apache-tomcat-11.0.27/webapps/
/home/lmh/tools/apache-tomcat-11.0.27/bin/startup.sh
```

### Bước 4: Chế độ Phát triển (DEV_MODE)
Khi chưa có thông tin SMTP Gmail thật, biến môi trường hoặc cờ JVM `-DAPP_DEV_MODE=true` sẽ tự động:
- Bật ghi nhận mã OTP ra terminal / `catalina.out` để tester dễ dàng lấy mã xác thực.
- Bỏ qua lệnh gửi SMTP thực tế khi không có `SMTP_PASS`.
