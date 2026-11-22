## 1. Tổng Quan Dự Án

**MyVideo Platform** là ứng dụng web quản lý nội dung đa phương tiện, danh mục sản phẩm và hồ sơ tài khoản người dùng hoàn chỉnh. Ứng dụng được thiết kế và triển khai tuân thủ nghiêm ngặt các tiêu chuẩn kỹ thuật phần mềm doanh nghiệp:
- **Kiến trúc đa tầng:** Tách biệt rõ ràng **MVC (Model - View - Controller)** kết hợp **DAO - Service Pattern**.
- **Cơ chế trang trí giao diện:** Ứng dụng **SiteMesh 3.2.2** trên nền tảng **Bootstrap 5.3.3**, tự động áp dụng Master Decorator thống nhất, responsive và linh hoạt.
- **Bảo mật đa tầng:** Quy trình **Validate-First**, chống **CSRF** qua Token, chống **XSS** qua `<c:out>`, chống **Brute-Force OTP & Mật khẩu**, bảo vệ phiên làm việc chống **Session Fixation**, mã hóa **BCrypt (cost 10)** và xoay token **Remember-Me**.
- **Đổi Email & Xác thực OTP:** Quản lý phiên đổi email cách ly an toàn, OTP 6 số sinh qua `SecureRandom`, băm SHA-256 byte array, cooldown 60s server-side, cập nhật CSDL nguyên tử qua ràng buộc `UNIQUE`.
- **Tải ảnh đại diện Cloudinary:** Xử lý Multipart (`@MultipartConfig`), kiểm tra **Magic Bytes** nhị phân (JPEG, PNG, WebP), tự động fallback lưu trữ cục bộ (Local Storage) khi chưa cấu hình API Cloudinary.

---

## 2. Các Phân Hệ Chức Năng Chính

### 2.1. Quản Lý Hồ Sơ Người Dùng (Profile), Đổi Email OTP & Tải Avatar Cloudinary

Phân hệ quản lý hồ sơ tài khoản cá nhân được bảo vệ chặt chẽ bởi `AuthFilter` tại route `/profile`:

1. **Cập nhật Thông tin Cá nhân (Fullname & Phone):**
   - Quy trình **Validate-First**: Kiểm tra tính hợp lệ toàn bộ dữ liệu trước khi ghi vào CSDL.
   - `fullname`: Bắt buộc, tối đa 100 ký tự, hỗ trợ tiếng Việt có dấu chuẩn UTF-8 qua `CharacterEncodingFilter`.
   - `phone`: Bắt buộc, kiểm tra định dạng số điện thoại di động Việt Nam 10 chữ số (`^0[3-9][0-9]{8}$`).
   - Cập nhật trực tiếp vào CSDL qua `userDao.updateProfile`.

2. **Tải lên Ảnh đại diện (Cloudinary & Multipart):**
   - Upload file qua form Multipart (`enctype="multipart/form-data"`), giới hạn tối đa **5MB** và tổng request **10MB**.
   - Bắt ngoại lệ kích thước file tại Servlet chống crash lỗi 500.
   - **Xác thực Magic Bytes nhị phân:** Đọc header file thực tế để chặn đứng file giả mạo:
     - JPEG: `FF D8 FF`
     - PNG: `89 50 4E 47`
     - WebP: `RIFF....WEBP` (bỏ qua 4 bytes độ dài)
   - Tải lên Cloudinary thông qua SDK `com.cloudinary:cloudinary-http44:1.39.0` với định danh `public_id = avatars/user_{id}`, `overwrite = true`.
   - **Cơ chế Fallback thông minh:** Khi môi trường chưa thiết lập key Cloudinary hoặc gặp sự cố mạng, hệ thống **tự động lưu ảnh an toàn vào Local Storage** (`uploads/avatars/user_{id}.{ext}`) và phân phối qua servlet `/image?type=avatar&fname=...`, không bao giờ làm gián đoạn trải nghiệm người dùng.

3. **Quy trình Thay đổi Địa chỉ Email & Xác thực OTP:**
   - **Bảo mật danh tính:** Yêu cầu nhập mật khẩu hiện tại khi đổi email. Nhập sai 5 lần sẽ kích hoạt khóa chức năng đổi email trong **15 phút**.
   - **Kiểm tra trùng lặp:** Kiểm tra email mới chưa tồn tại trong hệ thống (chuẩn hóa `trim().toLowerCase()`).
   - **Tầng dịch vụ độc lập `IEmailChangeService`:**
     - Sinh mã OTP 6 chữ số ngẫu nhiên mật mã (`SecureRandom`).
     - Lưu trữ băm SHA-256 dạng byte array, so khớp timing-safe `MessageDigest.isEqual`.
     - Phiên OTP hết hạn sau **5 phút**.
     - **Chống brute-force lũy kế:** Giới hạn tối đa **5 lần nhập sai tích lũy** (không bị reset về 0 khi gửi lại mã OTP).
     - **Chống spam email:** Cooldown server-side **60 giây** cho cả hành động gửi lần đầu (`initiate`) và gửi lại (`resend`), giới hạn tối đa **3 lần gửi lại** và trần **10 email/giờ/user** qua `UserThrottle`.
     - Miễn trừ cooldown an toàn khi dịch vụ gửi mail báo lỗi vận chuyển.
   - **Cập nhật CSDL nguyên tử:** Cập nhật email trực tiếp dựa vào ràng buộc `UNIQUE` trên bảng `users` (bắt ngoại lệ `PersistenceException`), phòng tránh hoàn toàn race condition và lỗi MySQL 1093.
   - Gửi email thông báo bảo mật đến địa chỉ email cũ sau khi đổi email thành công.

---

### 2.2. Phân Hệ Giao Diện Chuẩn Hóa: SiteMesh Decorator 3 & Bootstrap 5

- **Công nghệ Decorator:** Sử dụng thư viện `org.sitemesh:sitemesh:3.2.2` tương thích hoàn toàn với không gian tên `jakarta.servlet.*` trên Tomcat 10.1 và 11.0.
- **Bộ lọc trang trí (`MySiteMeshFilter.java`):**
  - Kế thừa `ConfigurableSiteMeshFilter`, ánh xạ toàn bộ request `/*` tới Master Decorator `/views/decorators/web.jsp`.
  - Loại trừ các endpoint nhị phân: streaming video (`/video/stream*`), phục vụ hình ảnh (`/image*`), tài nguyên tĩnh (`/assets/*`), và các decorator con.
- **Master Decorator Template (`web.jsp`):**
  - Tích hợp **Bootstrap 5.3.3 CDN**.
  - Bố cục Flexbox dạng cột cố định (`flex-direction: column`, `min-height: 100vh`), thẻ `<main class="site-main-content">` co giãn tự động (`flex: 1 0 auto`), loại bỏ triệt để hiện tượng vỡ layout hay scroll ngang.
  - **Thanh điều hướng Navbar:** Tông màu xanh dương thương hiệu (`#1e3a8a`, `#2563eb`), tự động active menu theo URI, hiển thị Avatar tròn (hỗ trợ cả Cloudinary HTTPS và Local URL), Tên người dùng và nút truy cập nhanh "Hồ sơ".
  - **Chân trang (Footer):** Cố định bám đáy (`mt-auto`), hiển thị thông tin Khoa Công nghệ Thông tin - Trường Đại học Sư phạm Kỹ thuật TP.HCM (HCMUTE).

---

### 2.3. Phân Hệ Kiểm Tra Dữ Liệu 2 Lớp (Validation 2 Lớp)

```
[Người dùng nhập FORM]
         │
         ▼ (Client-Side: Bootstrap 5 + form-validation.js)
┌────────────────────────────────────────────────────────┐
│ - Bootstrap 5 was-validated                           │
│ - Pattern Regex: Email, Số điện thoại VN, Username    │
│ - Độ dài: Mật khẩu 6–72 ký tự, Họ tên, Tiêu đề video   │
│ - Client File Size: Video <= 200MB, Ảnh <= 5MB         │
│ - Preview Avatar tức thì bằng JavaScript URL.createObjectURL
└────────────────────────────────────────────────────────┘
         │ Hợp lệ (SUBMIT kèm CSRF Token)
         ▼
┌────────────────────────────────────────────────────────┐
│ Server-Side Controller (ValidationUtil.java)           │
│ - Ép chuẩn ký tự UTF-8 (CharacterEncodingFilter)      │
│ - Kiểm tra Regex chuẩn RFC phía Server                 │
│ - BCrypt UTF-8 Byte Length <= 72 bytes                 │
│ - Kiểm tra Magic Bytes nhị phân file upload            │
│ - Kiểm tra trùng lặp Email / Username trong CSDL       │
│ - Kiểm tra tính hợp lệ của CSRF Token (CsrfUtil)       │
│ - Giữ lại giá trị form (Re-population) khi có lỗi      │
└────────────────────────────────────────────────────────┘
         │
         ├─── Không hợp lệ ──► Forward lại JSP + Alert thông báo lỗi
         └─── Hợp lệ ───────► Thực thi Service & Redirect (Flash Message)
```

#### Bảng tổng hợp kiểm tra dữ liệu tại các form:

| Chức năng Form | Client-Side Validation | Server-Side Validation | Controller & View |
| :--- | :--- | :--- | :--- |
| **Hồ sơ cá nhân (`/profile`)** | Họ tên $\le 100$ ký tự, Phone 10 số, File ảnh $\le 5$MB, preview ảnh tức thì. | Kiểm tra Magic Bytes ảnh, kiểm tra mật khẩu hiện tại, kiểm tra trùng email, bắt ngoại lệ Multipart. | `ProfileController.java`<br>`views/profile.jsp` |
| **Xác thực OTP đổi Email (`/profile/verify-otp`)** | Ô nhập 6 số căn giữa, pattern `[0-9]{6}`, đếm ngược 60s, nút hủy. | So khớp SHA-256 byte array, kiểm tra hết hạn 5 phút, giới hạn 5 lần thử tích lũy, trần resend 3 lần. | `ProfileController.java`<br>`views/profile-verify-otp.jsp` |
| **Đăng nhập (`/login`)** | `required`, minlength 3 và 6, hiển thị `.invalid-feedback`. | Kiểm tra rỗng, BCrypt check, giới hạn 72 bytes, giữ lại username. | `LoginController.java`<br>`views/login.jsp` |
| **Đăng ký (`/register`)** | Pattern username `[a-zA-Z0-9_]{3,50}`, email HTML5, phone 10 số. | Kiểm tra trùng email/username, độ dài UTF-8 an toàn BCrypt, re-populate form. | `RegisterController.java`<br>`views/register.jsp` |
| **Quên MK (`/forgot-password`)** | Email HTML5, `required`. | `ValidationUtil.isValidEmail`, timing-safe response chống leak email. | `ForgotPasswordController.java`<br>`views/auth/forgot-password.jsp` |
| **Đặt lại MK (`/reset-password`)** | OTP 6 số, Mật khẩu mới 6-72 ký tự, so khớp confirm password. | Kiểm tra khớp mật khẩu, băm BCrypt mật khẩu mới, hủy mã OTP. | `ResetPasswordController.java`<br>`views/auth/reset-password.jsp` |
| **Danh mục (`/category/*`)** | Tên danh mục 2–255 ký tự, file ảnh minh họa $\le 5$MB. | Kiểm tra rỗng, độ dài chuỗi, dung lượng multipart. | `CategoryController.java`<br>`views/admin/category-*.jsp` |
| **Đăng / Sửa Video (`/video/*`)** | Tiêu đề bắt buộc, danh mục bắt buộc, link YouTube hoặc MP4 $\le 200$MB. | `ValidationUtil.isValidYouTubeUrl`, ràng buộc `Title NOT NULL`, kiểm tra kích thước file tải lên. | `UserVideoController.java`<br>`views/video/upload.jsp` |

---

### 2.4. Phân Hệ Xác Thực & Bảo Mật Nâng Cao

- **Mã hóa BCrypt & Tự động nâng cấp:** Mật khẩu lưu trữ dạng băm BCrypt (cost factor = 10). Tự động nhận diện mật khẩu cũ (plaintext) và nâng cấp sang BCrypt ngay khi đăng nhập thành công.
- **Xoay Token Remember-Me (Token Rotation):** Token 32-byte ngẫu nhiên lưu cookie, băm SHA-256 lưu CSDL. Xoay token mới tại mỗi phiên đăng nhập tự động, thu hồi ngay lập tức nếu phát hiện bất thường.
- **Chống CSRF Toàn diện:** Lớp tiện ích `CsrfUtil` sinh token ngẫu nhiên mật mã và kiểm tra trên tất cả các thao tác POST đột biến dữ liệu.
- **Chống Session Fixation:** Làm mới Session ID (`req.changeSessionId()`) ngay sau khi người dùng đăng nhập thành công.

---

### 2.5. Phân Hệ Quản Lý & Phát Video

- **Quan hệ CSDL:** Thực thể `Video` liên kết N-1 với `User` (tác giả) và N-1 với `Category` (chủ đề).
- **Hỗ trợ 2 nguồn phát:**
  - **YouTube:** Nhận diện và chuẩn hóa mọi biến thể URL YouTube (`watch?v=`, `youtu.be/`, `shorts/`, `embed/`), tự động lấy ảnh Thumbnail chất lượng cao từ YouTube.
  - **Local Video (MP4):** Tải video trực tiếp lên máy chủ, hỗ trợ phát chuẩn **HTTP 206 Partial Content / HTTP Range** (`VideoStreamController`) giúp người xem tua nhanh video mượt mà.
- **Phân trang & Phân quyền:**
  - Phân trang 6 video/trang tại `/video`.
  - Bộ lọc video cá nhân tại `/video?filter=my`.
  - Top 10 video nổi bật trên Trang chủ (`/home`).
  - Kiểm duyệt video: Video người dùng tải lên ở trạng thái chờ duyệt (`active = 0`); Admin có nút bật/tắt duyệt video nhanh (`/admin/video/toggle-active`).

---

### 2.6. Phân Quyền 3 Vai Trò (Role-Based Access Control)

| Vai trò | Role ID | Route mặc định | Quyền hạn chính |
| :--- | :---: | :--- | :--- |
| **ADMIN** | `1` | `/admin/home` | Toàn quyền quản trị hệ thống: Duyệt/Khóa/Sửa/Xóa video (`/admin/videos`); CRUD danh mục sản phẩm (`/admin/category/list`). |
| **MANAGER** | `2` | `/manager/home` | Bảng điều khiển quản lý: Xem thống kê, theo dõi dữ liệu sản phẩm và video. |
| **USER** | `3` | `/home` | Xem video, xem chi tiết, đăng video mới (`/video/upload`), quản lý video cá nhân (`/video?filter=my`), cập nhật hồ sơ cá nhân và đổi email (`/profile`). |

---

## 3. Kiến Trúc Hệ Thống & Công Nghệ

```
[Client Browser] (Bootstrap 5.3 + form-validation.js + CSRF Token)
       │ HTTP / HTTPS
       ▼
[CharacterEncodingFilter] ── Ép chuẩn UTF-8 toàn bộ Request & Response
       │
       ▼
[SiteMesh 3 Filter] ──────── MySiteMeshFilter (Master Decorator: web.jsp)
       │
       ▼
[Security Filters] ───────── RememberMeFilter ── AuthFilter (Bảo vệ /admin, /manager, /profile)
       │
       ▼
[Controllers] ────────────── ProfileController, HomeController, VideoController, AuthControllers...
       │                     (Server Validation: ValidationUtil, CsrfUtil)
       ▼
[Services] ───────────────── EmailChangeService, ImageStorageService, UserService, VideoService...
       │
       ▼
[DAOs] ───────────────────── UserDao, VideoDao, CategoryDao
       │
       ▼
[Hibernate 7 JPA] ────────── EntityManagerFactory (JpaConfig)
       │
       ▼
[MySQL Database] ─────────── servletjpa (users, categories, videos, schema_version)
```

- **Ngôn ngữ & Nền tảng:** Java (OpenJDK 17 / 21), Jakarta EE 10 (Servlet 6.0, JSP 4.0).
- **Web Server & Container:** Apache Tomcat 10.1.61 / 11.0.27.
- **ORM & Database:** Hibernate ORM 7.4.6.Final, MySQL Connector/J 8.4.0, MySQL 8.x.
- **Giao diện:** SiteMesh 3.2.2, Bootstrap 5.3.3, CSS Flexbox responsive.
- **Lưu trữ Đám mây:** Cloudinary Java SDK `com.cloudinary:cloudinary-http44:1.39.0`.
- **Mã hóa & Bảo mật:** `jbcrypt:0.4`, SHA-256 (`HashUtil`), `SecureRandom`.
- **Gửi Mail:** Jakarta Mail 2.0.3 kết hợp `ThreadPoolExecutor` (AppContextListener).
- **Kiểm thử tự động:** JUnit 5 (`junit-jupiter:5.10.2`), Mockito 5.11.0, Apache Maven Surefire Plugin 3.2.5.

---

## 4. Cấu Trúc Thư Mục Dự Án

```
my-project/
├── pom.xml                                     # Cấu hình Maven, Cloudinary SDK, SiteMesh 3, Hibernate 7, JUnit 5
├── database.sql                                # DDL toàn diện: schema_version, users, categories, videos
├── database-video-seed.sql                     # Dữ liệu mẫu 12 video YouTube kèm thumbnail thực tế
├── database-test-bootstrap.sql                 # DDL phục vụ bộ kiểm thử tự động
├── src/main/java/vn/iotstar/
│   ├── config/
│   │   ├── JpaConfig.java                      # Cấu hình EntityManagerFactory JPA 3.0
│   │   └── AppContextListener.java             # Quản lý vòng đời luồng gửi email bất đồng bộ
│   ├── entity/
│   │   ├── User.java                           # Entity User (quan hệ 1-N với videos, avatar, otp...)
│   │   ├── Category.java                       # Entity Category (quan hệ 1-N với videos)
│   │   └── Video.java                          # Entity Video (N-1 User, N-1 Category, Title NOT NULL)
│   ├── dto/
│   │   └── PendingEmailUpdate.java             # DTO lưu phiên đổi email (userId, newEmail, otpHashBytes...)
│   ├── enums/
│   │   ├── VerifyResult.java                   # Enum kết quả xác thực: SUCCESS, INVALID_OTP, EXPIRED...
│   │   └── ResendResult.java                   # Enum kết quả gửi lại OTP: SENT, COOLDOWN_ACTIVE...
│   ├── filter/
│   │   ├── CharacterEncodingFilter.java        # Filter đầu chuỗi ép UTF-8 cho Multipart & Parameter
│   │   ├── MySiteMeshFilter.java               # Cấu hình SiteMesh 3 Decorator Filter
│   │   ├── RememberMeFilter.java               # Tự động đăng nhập qua cookie & xoay token
│   │   └── AuthFilter.java                     # Bảo vệ route /admin/*, /manager/*, /profile, /profile/*
│   ├── util/
│   │   ├── Constant.java                       # Hằng số hệ thống, DEV_MODE, session keys, đường dẫn upload
│   │   ├── CsrfUtil.java                       # Tiện ích tạo và kiểm tra CSRF Token hai chiều
│   │   ├── ValidationUtil.java                 # Regex Email, Phone VN, Password, Magic Bytes ảnh
│   │   ├── PasswordUtil.java                   # Băm BCrypt cost 10, kiểm tra <= 72 bytes UTF-8
│   │   ├── HashUtil.java                       # Băm SHA-256 hex và byte array, sinh secure token
│   │   └── EmailUtil.java                      # Gửi email HTML bất đồng bộ
│   ├── dao/
│   │   ├── IUserDao.java & UserDao.java        # Xử lý CSDL User, updateProfile, updateEmail nguyên tử
│   │   ├── ICategoryDao.java & CategoryDao.java# CRUD Category
│   │   └── IVideoDao.java & VideoDao.java      # CRUD Video, phân trang, lọc theo user, top 10
│   ├── service/
│   │   ├── IEmailChangeService.java            # Interface nghiệp vụ đổi email và xác thực OTP
│   │   ├── IImageStorageService.java           # Interface lưu trữ ảnh đại diện
│   │   ├── IOtpMailer.java                     # Interface gửi mail OTP và thông báo bảo mật
│   │   ├── IUserService.java & UserServiceImpl.java
│   │   ├── ICategoryService.java & CategoryServiceImpl.java
│   │   └── IVideoService.java & VideoServiceImpl.java
│   ├── service/impl/
│   │   ├── EmailChangeServiceImpl.java         # Triển khai đổi email, throttle 10 mail/h, cooldown 60s
│   │   ├── CloudinaryStorageServiceImpl.java   # Upload avatar lên Cloudinary & Local Fallback
│   │   └── AsyncOtpMailerImpl.java             # Gửi OTP bất đồng bộ qua ExecutorService
│   └── controllers/
│       ├── ProfileController.java              # Điều hướng /profile, /profile/verify-otp, resend, cancel
│       ├── HomeController.java                 # Trang chủ hiển thị top 10 video mới nhất
│       ├── WaitingController.java              # Điều hướng người dùng sau đăng nhập theo vai trò
│       ├── LoginController.java & LogoutController.java
│       ├── RegisterController.java & VerifyOtpController.java
│       ├── ForgotPasswordController.java & ResetPasswordController.java
│       ├── CategoryController.java             # Quản trị danh mục (Admin)
│       ├── VideoController.java                # Xem danh sách video phân trang 6 video/trang
│       ├── VideoDetailController.java          # Chi tiết và phát video
│       ├── VideoStreamController.java          # Streaming partial-content file video cục bộ
│       ├── UserVideoController.java            # Người dùng đăng tải và chỉnh sửa video cá nhân
│       ├── AdminVideoController.java           # Quản trị viên duyệt, khóa, sửa, xóa video
│       ├── AdminHomeController.java            # Dashboard quản trị
│       ├── ManagerHomeController.java          # Dashboard quản lý
│       └── DownloadImageController.java        # Phục vụ hiển thị avatar, poster và ảnh tĩnh
├── src/test/java/vn/iotstar/
│   ├── MutableClock.java                       # Đồng hồ giả lập điều khiển thời gian trong test
│   ├── TestBootstrapHelper.java                # Bootstrap schema test an toàn thread-safe
│   ├── ValidationTest.java                     # 86 bài test kiểm tra Validation biên (Email, Phone...)
│   ├── AuthIntegrationTest.java                # 8 kịch bản kiểm thử bảo mật & xác thực OTP/BCrypt
│   ├── VideoIntegrationTest.java               # 8 kịch bản kiểm thử Video & phân quyền
│   └── ProfileIntegrationTest.java             # 21 kịch bản kiểm thử Profile, OTP đổi email & Cloudinary
└── src/main/webapp/
    ├── WEB-INF/
    │   └── web.xml                             # Cấu hình Servlet 6.0, CharacterEncodingFilter, SiteMesh
    ├── assets/
    │   └── js/
    │       └── form-validation.js              # Script kích hoạt Bootstrap needs-validation & size check
    └── views/
        ├── decorators/
        │   └── web.jsp                         # Master Decorator Template Bootstrap 5.3 (Navbar & Footer)
        ├── profile.jsp                         # Giao diện xem và cập nhật hồ sơ cá nhân
        ├── profile-verify-otp.jsp              # Giao diện nhập OTP xác nhận đổi email mới
        ├── home.jsp                            # Trang chủ
        ├── login.jsp & register.jsp            # Trang đăng nhập, đăng ký
        ├── error.jsp                           # Trang thông báo lỗi
        ├── auth/
        │   ├── verify-otp.jsp                  # Xác thực kích hoạt tài khoản
        │   ├── forgot-password.jsp             # Quên mật khẩu
        │   └── reset-password.jsp              # Đặt lại mật khẩu mới
        ├── video/
        │   ├── list.jsp, detail.jsp, upload.jsp, edit.jsp
        ├── admin/
        │   ├── home.jsp, video-list.jsp, video-add.jsp, video-edit.jsp, category-*.jsp
        └── manager/
            └── home.jsp                        # Dashboard Manager
```

---

## 5. Hướng Dẫn Cài Đặt & Chạy Ứng Dụng

### Bước 1: Khởi tạo Cơ sở dữ liệu MySQL
1. Khởi động MySQL Server (port `3306`).
2. Thực thi script tạo cấu trúc bảng:
   ```bash
   mysql -u root -p123456 servletjpa < database.sql
   ```
3. Nạp dữ liệu 12 video mẫu:
   ```bash
   mysql -u root -p123456 servletjpa < database-video-seed.sql
   ```

### Bước 2: Chạy Toàn Bộ Kiểm Thử Tự Động (123 Test Cases)
```bash
mvn clean test
```
Tất cả **123 bài test** được thực thi tự động và đạt **BUILD SUCCESS (100% PASS)**:
- **86 Tests Validation (`ValidationTest`):** Kiểm tra toàn bộ giá trị biên hợp lệ/không hợp lệ cho Email (chuẩn RFC), Số điện thoại Việt Nam (10 số, đầu 03/05/07/08/09), Tên tài khoản, Mật khẩu BCrypt ($\le 72$ bytes UTF-8), và tất cả các định dạng liên kết YouTube.
- **8 Tests Xác thực (`AuthIntegrationTest`):** BCrypt cost 10, chặn mật khẩu $> 72$ bytes, xác thực OTP tức thời, từ chối OTP hết hạn, hủy sau 5 lần nhập sai, chống race condition trên cùng OTP, Remember Me Token Rotation.
- **8 Tests Video (`VideoIntegrationTest`):** CRUD Video, ràng buộc `Title NOT NULL`, phân trang 6 video/trang, Top 10 trang chủ, stream HTTP Range cục bộ, duyệt và phân quyền video theo role.
- **21 Tests Profile & OTP (`ProfileIntegrationTest`):** Kiểm thử quy trình Validate-First, đổi mật khẩu và khóa 15 phút sau 5 lần sai, xác thực OTP 6 số, giới hạn 5 lần thử tích lũy, cooldown 60s server-side cho initiate và resend, tối đa 3 lần resend, hết hạn 5 phút, miễn trừ cooldown khi lỗi gửi mail, chống race condition CSDL qua ràng buộc UNIQUE, tải avatar multipart Cloudinary và kiểm tra Magic Bytes (JPEG/PNG/WebP), kiểm tra CSRF token và `AuthFilter`.

### Bước 3: Đóng Gói & Triển Khai Lên Apache Tomcat
1. Đóng gói ứng dụng thành file WAR:
   ```bash
   mvn clean package -DskipTests
   ```
2. Sao chép file WAR vào thư mục `webapps` của Apache Tomcat:
   ```bash
   cp target/my-project.war /home/lmh/tools/apache-tomcat-10.1.61/webapps/
   ```
3. (Tùy chọn) Cấu hình Cloudinary để tải ảnh lên Cloudinary thật:
   - Đặt biến môi trường:
     ```bash
     export CLOUDINARY_URL=cloudinary://<api_key>:<api_secret>@<cloud_name>
     ```
   - *Lưu ý:* Nếu không cấu hình Cloudinary, hệ thống sẽ tự động chuyển sang chế độ **Local Storage Fallback** lưu ảnh trên máy chủ nội bộ mà không xảy ra bất kỳ lỗi nào.
4. Khởi động Tomcat và truy cập ứng dụng tại:
   ```
   http://localhost:8080/my-project/home
   ```

---

## 6. Danh Sách Tài Khoản Thử Nghiệm

| Tài khoản (Username) | Mật khẩu | Phân quyền (Role) | Chức năng kiểm thử chính |
| :--- | :--- | :---: | :--- |
| `lmh` | `123456` | **ADMIN** (1) | Xem Dashboard `/admin/home`, duyệt/khóa video `/admin/videos`, CRUD danh mục, xem & đổi thông tin hồ sơ `/profile`. |
| `manager` | `123456` | **MANAGER** (2) | Xem Dashboard `/manager/home`, quản lý dữ liệu sản phẩm, cập nhật hồ sơ `/profile`. |
| `user` | `123456` | **USER** (3) | Xem video, đăng video mới `/video/upload`, quản lý video cá nhân `/video?filter=my`, cập nhật họ tên, số điện thoại, đổi avatar Cloudinary và xác thực OTP đổi email `/profile`. |
| `legacy_user` | `123456` | **USER** (3) | Kiểm thử tính năng tự động nâng cấp mật khẩu từ plaintext sang BCrypt khi đăng nhập. |
