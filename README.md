# Nền Tảng Quản Lý Video & Danh Mục Sản Phẩm (MyVideo Platform)
> **Môn học:** Lập trình Web với Java & Jakarta EE  
> **Giảng viên hướng dẫn:** ThS. Nguyễn Hữu Trung - HCMUTE  
> **Sinh viên thực hiện:** Lê Minh Hoàng  
> **Công nghệ:** Jakarta EE 10 (Servlet 6.1, JSP 4.0), Hibernate ORM 7.x (JPA 3.0), MySQL 8.x, Apache Tomcat 10/11

---

## 1. Tổng Quan Dự Án

**MyVideo Platform** là ứng dụng web quản lý nội dung đa phương tiện và danh mục sản phẩm, xây dựng theo mô hình **MVC (Model - View - Controller)** kết hợp **DAO - Service Pattern** và công nghệ ánh xạ quan hệ đối tượng **JPA 3.0 (Jakarta Persistence)**.

Hệ thống tích hợp đầy đủ 3 giai đoạn bài tập trọng tâm:
1. **Bài tập 02:** Kiến trúc ORM JPA 3.0, CRUD Category & Video cơ bản.
2. **Bài tập 16/11:** Xác thực bảo mật người dùng, mã hóa mật khẩu BCrypt, kích hoạt tài khoản & quên mật khẩu bằng OTP Email bất đồng bộ, Remember Me Token Rotation.
3. **Mục 4 Bài tập (Hạn 19/11):** Nâng cấp toàn diện quan hệ bảng `videos` (1-N với `users`, N-1 với `categories`), CRUD Video hoàn chỉnh, phân trang 6 video/trang, Top 10 video trang chủ, Video Player (YouTube iframe & Local Stream MP4), upload file chuẩn Multipart và hệ thống giao diện xanh dương đồng bộ cho 3 nhóm quyền.

---

## 2. Các Phân Hệ Chức Năng Chính

### 2.1. Phân hệ Xác thực & Bảo mật (Authentication & Security)
- **Đăng ký tài khoản (`/register`):** Tài khoản mới có `status = 0`, hệ thống sinh mã OTP 6 chữ số an toàn qua `SecureRandom` và gửi email kích hoạt bất đồng bộ.
- **Kích hoạt tài khoản bằng OTP Email (`/verify-otp`):** 
  - Giao diện đếm ngược 60s cho nút gửi lại mã OTP (`/resend-otp`).
  - Giới hạn nhập sai tối đa 5 lần (lần thứ 5 tự động hủy mã).
  - Cập nhật nguyên tử (`consumeRegisterOtp`) ngăn chặn race condition khi xác thực đồng thời.
- **Mã hóa mật khẩu BCrypt & Lazy Re-hash:**
  - Băm mật khẩu một chiều chuẩn **BCrypt** (cost factor = 10), giới hạn $\le 72$ byte UTF-8.
  - Tự động nâng cấp mật khẩu cũ (plaintext) sang chuẩn băm BCrypt ngay khi người dùng đăng nhập thành công.
- **Cơ chế Remember Me an toàn cao:**
  - Sinh token ngẫu nhiên 32-byte lưu cookie, băm SHA-256 lưu cơ sở dữ liệu.
  - Xoay token nguyên tử (Token Rotation) tại mỗi phiên làm việc, chống Replay Attack và kiểm tra nghiêm ngặt `status = 1`.
- **Quên mật khẩu & Đặt lại mật khẩu (`/forgot-password`, `/reset-password`):**
  - Cơ chế timing-safe response chống rò rỉ sự tồn tại của email.
  - Rate limiting / Cooldown 60 giây chống spam OTP.
- **Bảo vệ phiên làm việc:** Đổi `sessionId` (`req.changeSessionId()`) khi đăng nhập thành công chống Session Fixation.

---

### 2.2. Phân hệ Quản lý Danh mục (Category Management)
- CRUD danh mục sản phẩm theo JPA chuẩn (`ICategoryDao`, `ICategoryService`).
- Hỗ trợ tải lên ảnh minh họa cho danh mục.
- Tìm kiếm danh mục theo tên.
- Phân quyền Admin quản lý danh mục tại `/admin/category/list`, `/admin/category/add`, `/admin/category/edit`.

---

### 2.3. Phân hệ Quản lý Video (Mục 4 - Hạn 19/11)
- **Thiết kế quan hệ dữ liệu:**
  - Bảng `videos` liên kết N-1 với `users` (người đăng tải) và N-1 với `categories` (danh mục nội dung).
- **Hỗ trợ 2 nguồn video linh hoạt:**
  - **YouTube:** Tự động nhận diện và chuẩn hóa tất cả định dạng URL YouTube (`youtube.com/watch?v=...`, `youtu.be/...`, embed URL) thành chuẩn nhúng phát trực tiếp.
  - **Local Upload (MP4):** Tải file video trực tiếp lên máy chủ qua chuẩn Multipart Servlet (`@MultipartConfig`, `Part.write(...)`).
- **Phát video (Streaming Player):**
  - Xem chi tiết video tại `/video/detail?id=...`, tăng lượt xem (`views`) tự động.
  - Trình phát video cục bộ hỗ trợ stream phân đoạn HTTP Partial Content / Range Requests (`/video/stream?id=...`).
  - Gợi ý danh sách video mới nhất liên quan tại cột bên phải.
- **Phân trang & Bộ lọc:**
  - Phân trang chuẩn 6 video/trang tại `/video`.
  - Bộ lọc **"Video của tôi"** (`/video?filter=my`) cho người dùng quản lý riêng kho video do chính mình đăng tải.
  - Hiển thị **10 video mới nhất** tại Trang chủ (`/home`).
- **Quy trình kiểm duyệt nội dung (Moderation Workflow):**
  - Video người dùng đăng tải mặc định ở trạng thái chờ duyệt (`active = 0`).
  - Khi người dùng chỉnh sửa video cá nhân, trạng thái tự động đưa về `active = 0` để Admin kiểm duyệt lại.
  - Admin có quyền duyệt nhanh / khóa video bằng 1 nút bấm (`/admin/video/toggle-active`).

---

### 2.4. Phân Quyền & Luồng Điều Hướng 3 Vai Trò (RBAC)

| Vai trò | Role ID | Dashboard mặc định | Quyền hạn chính |
| :--- | :---: | :--- | :--- |
| **ADMIN** | `1` | `/admin/home` | Quản trị toàn hệ thống; Duyệt, khóa, sửa, xóa toàn bộ video (`/admin/videos`); CRUD danh mục sản phẩm (`/admin/category/list`). |
| **MANAGER** | `2` | `/manager/home` | Dashboard tổng quan theo dõi hệ sinh thái, truy cập kho video và danh mục. |
| **USER** | `3` | `/home` | Xem kho video công khai, tải lên video mới (`/video/upload`), quản lý và chỉnh sửa video cá nhân (`/video?filter=my`). |

- Bộ lọc bảo vệ `AuthFilter` ngăn chặn truy cập trái phép vào các route quản trị (`/admin/*`, `/manager/*`).

---

### 2.5. Tối Ưu Giao Diện Người Dùng (UI/UX)
- **Tông màu chủ đạo:** Xanh dương hiện đại, chuyên nghiệp, dịu mắt (Primary: `#2563eb`, `#1e3a8a`; Nền: `#f8fafc`; Thẻ: `#ffffff` đổ bóng tinh tế).
- **Thiết kế phẳng & Tối giản:** Loại bỏ toàn bộ icon/emoji rườm rà, tập trung vào khả năng đọc lướt và thẩm mỹ doanh nghiệp.
- **Thanh điều hướng (Topbar) ngay ngắn:** Áp dụng `white-space: nowrap` và flexbox căn chuẩn, đảm bảo không bao giờ bị rớt dòng trên mọi kích thước màn hình.

---

## 3. Kiến Trúc & Công Nghệ Sử Dụng

```
[Client Browser]
       │ HTTP / HTTPS
       ▼
[Filter Chain] ── RememberMeFilter ── AuthFilter
       │
       ▼
[Controllers] ── HomeController, VideoController, AdminVideoController, AuthControllers...
       │
       ▼
[Services] ──── UserService, VideoService, CategoryService
       │
       ▼
[DAOs] ──────── UserDao, VideoDao, CategoryDao
       │
       ▼
[Hibernate 7 JPA] ── EntityManagerFactory (JpaConfig)
       │
       ▼
[MySQL Database] ── servletjpa (users, categories, videos, schema_version)
```

- **Java Version:** OpenJDK 17 / 21
- **Servlet Container:** Apache Tomcat 10.1.61 / 11.0.27 (Jakarta EE 10)
- **JPA & ORM Framework:** Hibernate ORM 7.4.6.Final (`jakarta.persistence.*`)
- **Database:** MySQL 8.x (`mysql-connector-j:8.4.0`)
- **Mã hóa:** `jbcrypt:0.4`, SHA-256 (`HashUtil`), `SecureRandom`
- **Email:** Jakarta Mail 2.0.3 kết hợp `ThreadPoolExecutor` (hàng đợi có chặn)
- **Kiểm thử tự động:** JUnit 5 (`junit-jupiter:5.10.2`), Maven Surefire Plugin 3.2.5
- **Build Tool:** Apache Maven 3.x

---

## 4. Cấu Trúc Thư Mục Dự Án

```
my-project/
├── pom.xml                                     # Cấu hình Maven, dependencies và test plugin
├── database.sql                                # DDL toàn diện: schema_version, users, categories, videos
├── database-video-seed.sql                     # Dữ liệu seed 12 video YouTube thực tế theo đúng tiêu đề
├── database-test-bootstrap.sql                 # DDL deterministic phục vụ test suite tự động
├── src/main/java/vn/iotstar/
│   ├── config/
│   │   ├── JpaConfig.java                      # Cấu hình EntityManagerFactory JPA 3.0
│   │   └── AppContextListener.java             # Quản lý vòng đời luồng gửi email bất đồng bộ
│   ├── entity/
│   │   ├── User.java                           # Entity User (quan hệ 1-N với videos)
│   │   ├── Category.java                       # Entity Category (quan hệ 1-N với videos)
│   │   └── Video.java                          # Entity Video (N-1 User, N-1 Category, Title NOT NULL)
│   ├── util/
│   │   ├── Constant.java                       # Hằng số hệ thống, thư mục upload, session keys
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
│   ├── filter/
│   │   ├── RememberMeFilter.java               # Tự động đăng nhập qua cookie & xoay token
│   │   └── AuthFilter.java                     # Kiểm tra quyền truy cập route /admin/*, /manager/*
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
│   ├── AuthIntegrationTest.java                # 8 kịch bản kiểm thử bảo mật & xác thực
│   └── VideoIntegrationTest.java               # 8 kịch bản kiểm thử Mục 4 Video & phân quyền
└── src/main/webapp/
    ├── index.jsp                               # Chuyển hướng về /home
    └── views/
        ├── home.jsp                            # Trang chủ giao diện xanh dương (Top 10 Video)
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

### Bước 2: Chạy Toàn Bộ Kiểm Thử Tự Động (16 Test Cases)
```bash
mvn clean test
```
Tất cả **16 bài test** đều được thực thi tự động và đạt **BUILD SUCCESS**:
- **8 Tests Xác thực (`AuthIntegrationTest`):** BCrypt cost 10, chặn mật khẩu > 72 bytes, xác thực OTP tức thời, từ chối OTP hết hạn, hủy sau 5 lần nhập sai, chống race condition trên cùng OTP, dọn dẹp OTP mồ côi khi lỗi hàng đợi, Remember Me Token Rotation.
- **8 Tests Video (`VideoIntegrationTest`):** CRUD Video đầy đủ, kiểm tra ràng buộc `Title NOT NULL`, phân trang 6 video/trang, Top 10 trang chủ, chuẩn hóa link YouTube, stream HTTP Range cục bộ, duyệt và phân quyền video theo role.

### Bước 3: Đóng Gói & Triển Khai Lên Tomcat
```bash
mvn package -DskipTests
cp target/my-project.war /home/lmh/tools/apache-tomcat-10.1.61/webapps/
```

Truy cập ứng dụng tại:
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

## 7. Lịch Sử Nhánh & Quản Lý Mã Nguồn (Git Branches)

- **`main`**: Nhánh chính chứa toàn bộ mã nguồn hoàn chỉnh mới nhất (Bài tập Mục 4 - hạn 19/11).
- **`baitap03_16-11`**: Nhánh lưu trữ độc lập bài tập ngày 16/11 (OTP Email, BCrypt, Remember Me).
- **`baitap02`**: Nhánh lưu trữ bài tập ngày 14/11 (CRUD Category & Video JPA cơ bản).
