## 1. Giới thiệu & Yêu cầu đề bài

1. **Cấu hình & Test JPA:**
   - Cấu hình file `persistence.xml` chuẩn JPA 3.0 (`jakarta.persistence`) kết nối MySQL (`servletjpa`).
   - Xây dựng Entity `Category` (Quan hệ `@OneToMany` với `Video`) và `Video` (Quan hệ `@ManyToOne` với `Category`).
   - Class tiện ích `JpaConfig` / `JPAConfig` quản lý `EntityManagerFactory` & cấp phát `EntityManager`.
   - Lớp kiểm thử `vn.iotstar.config.Test` tự động sinh bảng (`hibernate.hbm2ddl.auto = update`) và thêm dữ liệu kiểm thử.
2. **CRUD Category bằng JPA:**
   - Tầng DAO: `ICategoryDao` và `CategoryDao` thực thi các hàm `insert`, `update`, `delete`, `findById`, `findByCategoryname`, `findAll()`, `searchByName()`, `findAll(page, pagesize)`, `count()` bằng JPQL và EntityManager.
   - Tầng Service: `ICategoryService` và `CategoryServiceImpl` xử lý nghiệp vụ, kiểm tra tên trùng lặp, tự động xóa file ảnh cũ khi cập nhật hoặc xóa danh mục.
   - Tầng Controller: `CategoryController` với các URL mappings `/admin/categories`, `/admin/category/add`, `/admin/category/insert`, `/admin/category/edit`, `/admin/category/update`, `/admin/category/delete`.
   - Hỗ trợ cả 2 hình thức ảnh: tải file trực tiếp từ máy tính (`@MultipartConfig`, lưu tại thư mục hệ thống `Constant.DIR`) hoặc nhập trực tiếp URL ảnh online (`https://...`).
   - Quản trị bảo mật: Giữ nguyên tính năng xác thực đăng nhập, mã hóa, rẽ nhánh theo quyền (`roleid = 1`: Admin, `roleid = 2`: Manager, `roleid = 5`: User) qua `AuthFilter` và `WaitingController`.

---

## 2. Công nghệ sử dụng

- **Java Version:** OpenJDK 17 / 21
- **JPA & ORM Framework:** Hibernate ORM 7.4.6.Final (JPA 3.0 - `jakarta.persistence.*`)
- **Validation:** Hibernate Validator 8.0.5.Final, Jakarta EL 4.0.2
- **Web Platform:** Jakarta Servlet 6.1, JSP 4.0, JSTL 3.0.1 (Chạy trên Tomcat 11)
- **Database:** MySQL 8.x (`mysql-connector-j:8.4.0`)
- **Tiện ích:** Project Lombok 1.18.36, Apache Commons IO 2.16.1
- **Build Tool:** Apache Maven 3.x

---

## 3. Cấu trúc dự án

```
my-project/
├── pom.xml                                     # Cấu hình Maven: Jakarta EE, Hibernate 7, MySQL, Lombok
├── database.sql                                # Script khởi tạo MySQL database & dữ liệu mẫu
├── src/main/resources/
│   └── META-INF/
│       └── persistence.xml                     # Cấu hình Persistence Unit jpa-hibernate-mysql
├── src/main/java/vn/iotstar/
│   ├── config/
│   │   ├── JpaConfig.java & JPAConfig.java     # Quản lý EntityManagerFactory
│   │   └── Test.java                           # Hàm main kiểm thử cấu hình & sinh schema JPA
│   ├── entity/
│   │   ├── Category.java                       # Entity Category (@OneToMany Video)
│   │   ├── Video.java                          # Entity Video (@ManyToOne Category)
│   │   └── User.java                           # Entity User (@Id, roleid, email, ...)
│   ├── dao/
│   │   ├── ICategoryDao.java & CategoryDao.java# CRUD Category bằng JPA EntityManager / JPQL
│   │   └── IUserDao.java & UserDao.java        # DAO User phục vụ Login/Register/Auth
│   ├── service/
│   │   ├── ICategoryService.java & CategoryServiceImpl.java # Xử lý nghiệp vụ & xóa file ảnh cũ
│   │   └── IUserService.java & UserServiceImpl.java         # Xác thực & phân quyền người dùng
│   ├── controllers/
│   │   ├── CategoryController.java             # Quản lý CRUD Category (/admin/categories, /admin/category/*)
│   │   ├── DownloadImageController.java        # Stream hiển thị ảnh từ thư mục lưu trữ (/image?fname=...)
│   │   ├── HomeController.java                 # Trang chủ (/home)
│   │   ├── LoginController.java                # Đăng nhập (/login)
│   │   ├── RegisterController.java             # Đăng ký (/register)
│   │   ├── WaitingController.java              # Rẽ nhánh theo quyền sau khi đăng nhập (/waiting)
│   │   ├── LogoutController.java               # Đăng xuất (/logout)
│   │   ├── AdminHomeController.java            # Trang quản trị (/admin/home)
│   │   └── ManagerHomeController.java          # Trang quản lý (/manager/home)
│   ├── filter/
│   │   └── AuthFilter.java                     # Bộ lọc phân quyền (Chỉ roleid = 1 được sửa đổi Category)
│   └── util/
│       └── Constant.java                       # Cấu hình đường dẫn lưu file ảnh (Constant.DIR)
└── src/main/webapp/
    ├── WEB-INF/
    │   └── web.xml                             # Web descriptor (tracking-mode COOKIE)
    ├── index.jsp                               # Trang đích chuyển hướng tự động về /home
    └── views/
        ├── login.jsp & register.jsp            # Giao diện Đăng nhập / Đăng ký
        ├── home.jsp                            # Giao diện Trang chủ người dùng
        └── admin/
            ├── home.jsp                        # Giao diện Trang quản trị Admin
            ├── category-list.jsp               # Danh sách danh mục, tìm kiếm, nút Thêm/Sửa/Xóa
            ├── category-add.jsp                # Form thêm mới danh mục (File upload & URL online)
            └── category-edit.jsp               # Form cập nhật danh mục kèm xem trước ảnh cũ
```

---

## 4. Hướng dẫn cài đặt & Thực thi

### Bước 1: Chuẩn bị Cơ sở dữ liệu MySQL
1. Khởi động MySQL Server (port 3306).
2. Tạo database hoặc import file `database.sql`:
   ```bash
   mysql -u root -p < database.sql
   ```
   *(Mặc định cấu hình user `root`, mật khẩu `123456`, tên database `servletjpa` trong file `persistence.xml`)*.

### Bước 2: Kiểm thử JPA độc lập (Test.java)
Chạy lệnh Maven để kiểm tra Hibernate tự động tạo/cập nhật bảng và thực thi Transaction lưu Category & Video:
```bash
mvn compile exec:java -Dexec.mainClass="vn.iotstar.config.Test"
```
Kết quả thành công sẽ xuất dòng:
```
SUCCESS: Persisted Category and Video into database via JPA!
```

### Bước 3: Đóng gói và Deploy lên Tomcat 11
1. Build file WAR:
   ```bash
   mvn clean package
   ```
2. Copy file `target/my-project.war` vào thư mục `webapps` của Apache Tomcat 11:
   ```bash
   cp target/my-project.war /path/to/apache-tomcat-11.x/webapps/
   ```
3. Khởi động Tomcat:
   ```bash
   /path/to/apache-tomcat-11.x/bin/catalina.sh run
   ```
4. Mở trình duyệt và truy cập:
   ```
   http://localhost:8080/my-project/
   ```

---

## 5. Tài khoản kiểm thử & Phân quyền

| Tài khoản | Mật khẩu | Quyền hạn (roleid) | Luồng chuyển hướng | Quyền hạn thao tác |
| :--- | :--- | :--- | :--- | :--- |
| **lmh** | `123456` | **1 (Admin)** | `/waiting` ➔ `/admin/categories` | Toàn quyền Thêm / Sửa / Xóa Category, Upload ảnh |
| **manager** | `123456` | **2 (Manager)** | `/waiting` ➔ `/manager/home` | Quản lý nghiệp vụ |
| **user** | `123456` | **5 (User)** | `/waiting` ➔ `/home` | Người dùng thông thường, xem dữ liệu |

---
