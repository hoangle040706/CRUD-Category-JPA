## 1. Tổng Quan Dự Án

**MyVideo Platform** là ứng dụng web quản lý nội dung đa phương tiện và danh mục sản phẩm hoàn chỉnh, xây dựng theo mô hình kiến trúc đa tầng **MVC (Model - View - Controller)** kết hợp **DAO - Service Pattern**, công nghệ ánh xạ quan hệ đối tượng **JPA 3.0 (Jakarta Persistence)**, hệ thống giao diện trang trí **SiteMesh Decorator 3** trên nền tảng **Bootstrap 5.3**, cùng cơ chế **Validation 2 lớp (Client & Server)** toàn diện.

---

## 2. Các Phân Hệ Chức Năng Chính

### 2.1. Phân hệ Giao Diện Chuẩn Hóa: SiteMesh Decorator 3 & Bootstrap 5
- **Công nghệ Decorator:** Sử dụng thư viện `org.sitemesh:sitemesh:3.2.2` tương thích chuẩn với không gian tên `jakarta.servlet.*` trên Apache Tomcat 10.1 và 11.0.
- **Bộ lọc trang trí (`MySiteMeshFilter.java`):**
  - Kế thừa `ConfigurableSiteMeshFilter`, ánh xạ toàn bộ các yêu cầu `/*` tới Master Decorator `/views/decorators/web.jsp`.
  - Thiết lập loại trừ (`addExcludedPath`) cho các endpoint nhị phân và dữ liệu thô: streaming video cục bộ (`/video/stream*`), phục vụ hình ảnh (`/image*`), tài nguyên tĩnh (`/assets/*`), và các decorator views nội bộ (`/views/decorators/*`).
- **Master Decorator Template (`web.jsp`):**
  - Tích hợp **Bootstrap 5.3.3 CDN** (CSS và JavaScript Bundle).
  - Kiến trúc Flexbox dạng cột cố định (`flex-direction: column`, `min-height: 100vh`) với `<main class="site-main-content">` co giãn tự động (`flex: 1 0 auto`), loại bỏ hoàn toàn hiện tượng vỡ layout hoặc xô lệch hàng ngang trên các màn hình xác thực.
  - **Thanh Navbar Master responsive:** Tông màu xanh dương thương hiệu (`#1e3a8a`, `#2563eb`), tự động nhận diện và làm nổi bật (active) route hiện tại, hiển thị điều hướng chuyên biệt theo 3 vai trò:
    - *Khách:* Xem Trang chủ, Tất cả Video, Danh mục, Nút Đăng nhập / Đăng ký.
    - *Người dùng đã đăng nhập:* Bổ sung menu "Video của tôi", "Đăng Video", Họ tên người dùng, Huy hiệu quyền và nút Đăng xuất.
    - *Quản trị viên (Admin):* Bổ sung nút tắt "Quản trị Admin", "Duyệt Video".
    - *Quản lý (Manager):* Bổ sung nút tắt "Bảng điều khiển Manager".
  - **Chân trang (Footer) HCMUTE:** Cố định bám đáy (`mt-auto`), hiển thị thông tin Khoa Công nghệ Thông tin - Trường Đại học Sư phạm Kỹ thuật TP.HCM.

---

### 2.2. Phân hệ Kiểm Tra Dữ Liệu 2 Lớp (Form Validation)

Hệ thống thiết lập cơ chế kiểm tra tính hợp lệ đa tầng, kết hợp trải nghiệm phản hồi nhanh tức thì ở phía Client (HTML5 + Bootstrap 5) cùng sự an toàn dữ liệu tuyệt đối ở phía Server:

```
[Người dùng nhập FORM]
         │
         ▼ (Client-side: form-validation.js)
┌────────────────────────────────────────────────────────┐
│ - Bootstrap 5 was-validated                           │
│ - Pattern Regex: Email, Số điện thoại VN, Username    │
│ - Độ dài: Mật khẩu 6–72 ký tự, Tiêu đề, Tên danh mục  │
│ - File size check: Video <= 200MB, Poster <= 5MB       │
│ - So khớp mật khẩu xác nhận thời gian thực            │
└────────────────────────────────────────────────────────┘
         │ Hợp lệ (SUBMIT)
         ▼
┌────────────────────────────────────────────────────────┐
│ Server Controller (ValidationUtil.java)                │
│ - Kiểm tra Regex chuẩn phía Server                    │
│ - BCrypt UTF-8 Byte Length <= 72 bytes                │
│ - Kiểm tra trùng lặp Email / Username trong CSDL      │
│ - Kiểm tra MIME type và dung lượng tệp Multipart      │
│ - Lưu giữ giá trị form (Re-population) khi có lỗi     │
└────────────────────────────────────────────────────────┘
         │
         ├─── Không hợp lệ ──► Forward lại JSP + Hiển thị invalid-feedback / alert
         └─── Hợp lệ ───────► Thực thi nghiệp vụ Service & Chuyển hướng
```

#### Phạm vi áp dụng chi tiết cho các chức năng có FORM:

| Chức năng Form | Client-Side Validation | Server-Side Controller | File Controller & JSP |
| :--- | :--- | :--- | :--- |
| **Đăng nhập (`/login`)** | `required`, `minlength="3"`, `minlength="6"`, hiển thị `.invalid-feedback`. | Kiểm tra rỗng, kiểm tra giới hạn 72 bytes, giữ lại username đã nhập. | `LoginController.java`<br>`views/login.jsp` |
| **Đăng ký (`/register`)** | `pattern="[a-zA-Z0-9_]{3,50}"`, email HTML5, phone 10 số `0[3-9]\d{8}`, password 6-72 ký tự. | Kiểm tra trùng email, trùng username, độ dài UTF-8 an toàn BCrypt, re-populate mọi trường. | `RegisterController.java`<br>`views/register.jsp` |
| **Quên mật khẩu (`/forgot-password`)** | `type="email"`, `required`, kiểm tra định dạng email. | `ValidationUtil.isValidEmail`, timing-safe response chống leak email. | `ForgotPasswordController.java`<br>`views/auth/forgot-password.jsp` |
| **Xác thực OTP (`/verify-otp`)** | `pattern="[0-9]{6}"`, `maxlength="6"`, `autofocus`, đếm ngược 60s. | `otp.matches("\\d{6}")`, kiểm tra hết hạn 5 phút, giới hạn 5 lần thử. | `VerifyOtpController.java`<br>`views/auth/verify-otp.jsp` |
| **Đặt lại MK (`/reset-password`)** | OTP 6 số, Mật khẩu mới 6-72 ký tự, so khớp `#confirmPassword`. | Kiểm tra khớp mật khẩu, băm BCrypt mật khẩu mới, hủy mã OTP. | `ResetPasswordController.java`<br>`views/auth/reset-password.jsp` |
| **Thêm / Sửa Danh mục** | `categoryname` từ 2–255 ký tự, `required`, file ảnh minh họa $\le$ 5MB. | Kiểm tra null/empty, độ dài chuỗi, kiểm tra dung lượng `Part.getSize()`. | `CategoryController.java`<br>`views/admin/category-add.jsp`<br>`views/admin/category-edit.jsp` |
| **Đăng tải / Sửa Video** | `title` bắt buộc, `categoryId` bắt buộc, YouTube URL regex hoặc MP4 $\le$ 200MB, Poster $\le$ 5MB. | `ValidationUtil.isValidYouTubeUrl`, kiểm tra ràng buộc `Title NOT NULL`, kiểm tra kích thước file tải lên. | `UserVideoController.java`<br>`AdminVideoController.java`<br>`views/video/upload.jsp`<br>`views/video/edit.jsp` |

---

### 2.3. Phân hệ Xác thực & Bảo mật (Authentication & Security)
- **Kích hoạt tài khoản bằng OTP Email:** Sinh mã 6 chữ số ngẫu nhiên mật mã (`SecureRandom`), gửi bất đồng bộ qua Gmail SMTP với ExecutorService.
- **Mã hóa mật khẩu BCrypt & Lazy Re-hash:**
  - Băm mật khẩu chuẩn **BCrypt** (cost factor = 10), giới hạn an toàn $\le 72$ byte UTF-8.
  - Tự động phát hiện và nâng cấp mật khẩu cũ (plaintext) sang chuẩn BCrypt ngay khi người dùng đăng nhập.
- **Remember Me Token Rotation:**
  - Token ngẫu nhiên 32-byte lưu ở cookie, băm SHA-256 lưu cơ sở dữ liệu.
  - Xoay token nguyên tử tại mỗi phiên, chống tấn công Replay Attack.
- **Bảo vệ phiên làm việc:** Đổi `sessionId` (`req.changeSessionId()`) khi đăng nhập thành công chống Session Fixation.

---

### 2.4. Phân hệ Quản lý & Phát Video
- **Quan hệ thực thể:** `videos` liên kết N-1 với `users` (người đăng tải) và N-1 với `categories` (danh mục). Ràng buộc `title NOT NULL` nghiêm ngặt.
- **Hỗ trợ 2 nguồn video:**
  - **YouTube:** Nhận diện và chuẩn hóa tất cả định dạng URL YouTube, tự động trích xuất Thumbnail chất lượng cao từ YouTube làm poster đại diện.
  - **Local Upload (MP4):** Tải file video lên máy chủ, hỗ trợ phát trực tiếp dạng HTTP Range / Partial Content 206 (`VideoStreamController`).
- **Phân trang & Kiểm duyệt:**
  - Phân trang chuẩn 6 video/trang tại `/video`.
  - Bộ lọc video cá nhân tại `/video?filter=my`.
  - Hiển thị 10 video mới nhất trên Trang chủ (`/home`).
  - Video người dùng đăng tải mặc định ở trạng thái chờ duyệt (`active = 0`); Admin có quyền duyệt nhanh / khóa video bằng 1 nút bấm (`/admin/video/toggle-active`).

---

### 2.5. Phân Quyền 3 Vai Trò (Role-Based Access Control)

| Vai trò | Role ID | Route mặc định | Quyền hạn chính |
| :--- | :---: | :--- | :--- |
| **ADMIN** | `1` | `/admin/home` | Toàn quyền hệ thống: Duyệt/Khóa/Sửa/Xóa video (`/admin/videos`); CRUD danh mục sản phẩm (`/admin/category/list`). |
| **MANAGER** | `2` | `/manager/home` | Dashboard tổng quan theo dõi dữ liệu sản phẩm, duyệt danh mục và xem thống kê. |
| **USER** | `3` | `/home` | Xem kho video, tải lên video mới (`/video/upload`), quản lý và chỉnh sửa video cá nhân (`/video?filter=my`). |

---

## 3. Kiến Trúc & Công Nghệ Sử Dụng

```
[Client Browser] (Bootstrap 5.3 + form-validation.js)
       │ HTTP / HTTPS
       ▼
[SiteMesh 3 Filter] ── MySiteMeshFilter (web.jsp Decorator: Navbar + Content + Footer)
       │
       ▼
[Filter Chain] ─────── RememberMeFilter ── AuthFilter
       │
       ▼
[Controllers] ──────── HomeController, VideoController, AdminVideoController, AuthControllers...
       │                (Server Validation: ValidationUtil)
       ▼
[Services] ─────────── UserService, VideoService, CategoryService
       │
       ▼
[DAOs] ─────────────── UserDao, VideoDao, CategoryDao
       │
       ▼
[Hibernate 7 JPA] ──── EntityManagerFactory (JpaConfig)
       │
       ▼
[MySQL Database] ───── servletjpa (users, categories, videos, schema_version)
```

- **Java Version:** OpenJDK 17 / 21
- **Servlet Container:** Apache Tomcat 10.1.61 / 11.0.27 (Jakarta EE 10)
- **Decorator Engine:** SiteMesh 3.2.2 (`org.sitemesh:sitemesh:3.2.2`)
- **Frontend UI Framework:** Bootstrap 5.3.3 (CSS + JS Bundle CDN)
- **ORM & JPA Framework:** Hibernate ORM 7.4.6.Final (`jakarta.persistence.*`)
- **Database:** MySQL 8.x (`mysql-connector-j:8.4.0`)
- **Mã hóa & Hash:** `jbcrypt:0.4`, SHA-256 (`HashUtil`), `SecureRandom`
- **Email:** Jakarta Mail 2.0.3 kết hợp `ThreadPoolExecutor`
- **Kiểm thử tự động:** JUnit 5 (`junit-jupiter:5.10.2`), Surefire Plugin 3.2.5

---

## 4. Cấu Trúc Thư Mục Dự Án

```
my-project/
├── pom.xml                                     # Cấu hình Maven, SiteMesh 3, Hibernate 7, JUnit 5
├── database.sql                                # DDL toàn diện: schema_version, users, categories, videos
├── database-video-seed.sql                     # Dữ liệu mẫu 12 video YouTube kèm thumbnail thực tế
├── database-test-bootstrap.sql                 # DDL phục vụ bộ kiểm thử tự động
├── src/main/java/vn/iotstar/
│   ├── config/
│   │   ├── JpaConfig.java                      # Cấu hình EntityManagerFactory JPA 3.0
│   │   └── AppContextListener.java             # Quản lý vòng đời luồng gửi email bất đồng bộ
│   ├── entity/
│   │   ├── User.java                           # Entity User (quan hệ 1-N với videos)
│   │   ├── Category.java                       # Entity Category (quan hệ 1-N với videos)
│   │   └── Video.java                          # Entity Video (N-1 User, N-1 Category, Title NOT NULL)
│   ├── filter/
│   │   ├── MySiteMeshFilter.java               # Cấu hình SiteMesh 3 Decorator Filter
│   │   ├── RememberMeFilter.java               # Tự động đăng nhập qua cookie & xoay token
│   │   └── AuthFilter.java                     # Kiểm tra quyền truy cập route /admin/*, /manager/*
│   ├── util/
│   │   ├── Constant.java                       # Hằng số hệ thống, thư mục upload, session keys
│   │   ├── ValidationUtil.java                 # Regex & quy tắc kiểm tra Email, Phone, Pass, YouTube
│   │   ├── PasswordUtil.java                   # Băm BCrypt cost 10, kiểm tra <= 72 bytes
│   │   ├── HashUtil.java                       # Băm SHA-256, sinh token an toàn
│   │   └── EmailUtil.java                      # Gửi email bất đồng bộ, dọn dẹp OTP mồ côi
│   ├── dao/
│   │   ├── IUserDao.java & UserDao.java        # Xử lý dữ liệu User và câu truy vấn nguyên tử
│   │   ├── ICategoryDao.java & CategoryDao.java# CRUD Category
│   │   └── IVideoDao.java & VideoDao.java      # CRUD Video, phân trang, lọc theo user, top 10
│   ├── service/
│   │   ├── IUserService.java & UserServiceImpl.java
│   │   ├── ICategoryService.java & CategoryServiceImpl.java
│   │   └── IVideoService.java & VideoServiceImpl.java # Nghiệp vụ Video, chuẩn hóa URL YouTube
│   └── controllers/
│       ├── HomeController.java                 # Trang chủ hiển thị top 10 video mới nhất
│       ├── WaitingController.java              # Điều hướng người dùng sau đăng nhập theo vai trò
│       ├── LoginController.java & LogoutController.java
│       ├── RegisterController.java & VerifyOtpController.java
│       ├── ForgotPasswordController.java & ResetPasswordController.java
│       ├── CategoryController.java             # Quản trị danh mục (Admin)
│       ├── VideoController.java                # Xem danh sách video phân trang 6 video/trang
│       ├── VideoDetailController.java          # Xem chi tiết và phát video
│       ├── VideoStreamController.java          # Streaming partial-content file video cục bộ
│       ├── UserVideoController.java            # Người dùng đăng tải và chỉnh sửa video cá nhân
│       ├── AdminVideoController.java           # Quản trị viên duyệt, khóa, sửa, xóa video
│       ├── AdminHomeController.java            # Dashboard quản trị
│       ├── ManagerHomeController.java          # Dashboard quản lý
│       └── ImageController.java                # Phục vụ hiển thị avatar, poster và ảnh tĩnh
├── src/test/java/vn/iotstar/
│   ├── TestBootstrapHelper.java                # Helper bootstrap schema test an toàn thread-safe
│   ├── ValidationTest.java                     # 86 bài test kiểm tra Validation biên (Email, Phone, ...)
│   ├── AuthIntegrationTest.java                # 8 kịch bản kiểm thử bảo mật & xác thực OTP/BCrypt
│   └── VideoIntegrationTest.java               # 8 kịch bản kiểm thử Mục 4 Video & phân quyền
└── src/main/webapp/
    ├── WEB-INF/
    │   └── web.xml                             # Cấu hình Servlet 6.0, SiteMesh filter mapping
    ├── assets/
    │   └── js/
    │       └── form-validation.js              # Script kích hoạt Bootstrap needs-validation & file size check
    └── views/
        ├── decorators/
        │   └── web.jsp                         # Master Decorator Template Bootstrap 5.3 (Navbar & Footer)
        ├── home.jsp                            # Trang chủ (Top 10 Video)
        ├── login.jsp & register.jsp            # Trang đăng nhập, đăng ký
        ├── error.jsp                           # Trang thông báo lỗi
        ├── auth/
        │   ├── verify-otp.jsp                  # Giao diện xác thực mã OTP kích hoạt
        │   ├── forgot-password.jsp             # Giao diện gửi yêu cầu quên mật khẩu
        │   └── reset-password.jsp              # Giao diện đặt lại mật khẩu mới
        ├── video/
        │   ├── list.jsp                        # Danh sách video phân trang 6/trang và tab cá nhân
        │   ├── detail.jsp                      # Trình phát video & danh sách video đề xuất
        │   ├── upload.jsp                      # Form đăng tải video mới (YouTube / Multipart file)
        │   └── edit.jsp                        # Form cập nhật thông tin video cá nhân
        ├── admin/
        │   ├── home.jsp                        # Tổng quan Dashboard Admin
        │   ├── video-list.jsp                  # Bảng quản lý & duyệt nhanh trạng thái video
        │   ├── video-add.jsp & video-edit.jsp  # Thêm và chỉnh sửa video cho Admin
        │   ├── category-list.jsp               # Quản lý danh mục sản phẩm
        │   └── category-add.jsp & category-edit.jsp
        └── manager/
            └── home.jsp                        # Dashboard tổng quan Manager
```

---

## 5. Hướng Dẫn Cài Đặt & Triển Khai

### Bước 1: Thiết lập Cơ sở dữ liệu MySQL
1. Khởi động MySQL Server (port `3306`).
2. Chạy tệp script tạo cấu trúc bảng và migration:
   ```bash
   mysql -u root -p123456 servletjpa < database.sql
   ```
3. Nạp dữ liệu 12 video mẫu kèm poster YouTube thực tế:
   ```bash
   mysql -u root -p123456 servletjpa < database-video-seed.sql
   ```

### Bước 2: Chạy Toàn Bộ Kiểm Thử Tự Động (102 Test Cases)
```bash
mvn clean test
```
Tất cả **102 bài test** được thực thi tự động và đạt **BUILD SUCCESS (100% PASS)**:
- **86 Tests Validation (`ValidationTest`):** Kiểm tra tất cả giá trị biên hợp lệ/không hợp lệ cho Email (RFC standard), Số điện thoại Việt Nam (10 số, đầu 03/05/07/08/09), Tên tài khoản (ký tự đặc biệt, độ dài), Mật khẩu BCrypt (chặn > 72 bytes UTF-8), và tất cả các dạng link YouTube (`watch?v=`, `youtu.be/`, `shorts/`, `embed/`).
- **8 Tests Xác thực (`AuthIntegrationTest`):** BCrypt cost 10, chặn mật khẩu > 72 bytes, xác thực OTP tức thời, từ chối OTP hết hạn, hủy sau 5 lần nhập sai, chống race condition trên cùng OTP, Remember Me Token Rotation.
- **8 Tests Video (`VideoIntegrationTest`):** CRUD Video, ràng buộc `Title NOT NULL`, phân trang 6 video/trang, Top 10 trang chủ, stream HTTP Range cục bộ, duyệt và phân quyền video theo role.

### Bước 3: Đóng Gói & Triển Khai Lên Apache Tomcat
```bash
mvn package -DskipTests
cp target/my-project.war /home/lmh/tools/apache-tomcat-10.1.61/webapps/
```

Khởi động Tomcat và truy cập ứng dụng tại:
```
http://localhost:8080/my-project/home
```

---

## 6. Danh Sách Tài Khoản Thử Nghiệm

| Tài khoản (Username) | Mật khẩu | Phân quyền (Role) | Chức năng kiểm thử chính |
| :--- | :--- | :---: | :--- |
| `lmh` | `123456` | **ADMIN** (1) | Xem Dashboard `/admin/home`, duyệt/khóa video `/admin/videos`, CRUD danh mục. |
| `manager` | `123456` | **MANAGER** (2) | Xem Dashboard `/manager/home`, quản lý dữ liệu sản phẩm. |
| `user` | `123456` | **USER** (3) | Đăng video mới `/video/upload`, quản lý video cá nhân `/video?filter=my`. |
| `legacy_user` | `123456` | **USER** (3) | Kiểm thử tính năng tự động nâng cấp mật khẩu từ plaintext sang BCrypt. |

---
