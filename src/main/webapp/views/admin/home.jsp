<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang Quản Trị - Admin Dashboard</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Arial, sans-serif; }
        body { background-color: #f0f2f5; color: #333; }
        .topbar { background: #007bff; color: #fff; padding: 12px 25px; display: flex; justify-content: space-between; align-items: center; }
        .topbar h2 { font-size: 20px; font-weight: 600; }
        .topbar-right a { color: #fff; text-decoration: none; background: #dc3545; padding: 6px 14px; border-radius: 4px; font-size: 13px; font-weight: bold; margin-left: 10px; }
        .main-container { display: flex; min-height: calc(100vh - 54px); }
        .sidebar { width: 240px; background: #1e282c; color: #b8c7ce; padding: 20px 0; flex-shrink: 0; }
        .user-panel { padding: 12px 20px; display: flex; align-items: center; border-bottom: 1px solid #374850; margin-bottom: 15px; }
        .user-panel img { width: 45px; height: 45px; border-radius: 50%; object-fit: cover; margin-right: 12px; }
        .sidebar-menu { list-style: none; }
        .sidebar-menu li a { display: block; padding: 12px 20px; color: #b8c7ce; text-decoration: none; font-size: 14px; }
        .sidebar-menu li a:hover, .sidebar-menu li.active a { background: #1a2226; color: #fff; border-left: 3px solid #007bff; }
        .content { flex-grow: 1; padding: 25px 30px; }
        .welcome-card { background: #fff; border-radius: 8px; padding: 30px; box-shadow: 0 1px 4px rgba(0,0,0,0.08); margin-bottom: 25px; }
        .stat-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 20px; }
        .stat-card { background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 1px 4px rgba(0,0,0,0.08); border-left: 4px solid #007bff; }
        .stat-card.green { border-left-color: #28a745; }
        .stat-card.orange { border-left-color: #fd7e14; }
        .stat-card.teal { border-left-color: #20c997; }
        .stat-card h3 { font-size: 18px; color: #2c3e50; margin-bottom: 8px; display: flex; align-items: center; gap: 8px; }
        .stat-card p { color: #6c757d; font-size: 13px; line-height: 1.5; margin-bottom: 12px; }
        .stat-card a { font-size: 13px; color: #007bff; text-decoration: none; font-weight: bold; }
        .stat-card a:hover { text-decoration: underline; }
        .btn-group-welcome { display: flex; gap: 12px; margin-top: 18px; flex-wrap: wrap; }
        .btn { display: inline-block; padding: 9px 18px; color: #fff; text-decoration: none; border-radius: 4px; font-weight: bold; background: #007bff; font-size: 13px; }
        .btn:hover { opacity: 0.9; }
        .btn-video { background: #28a745; }
        .btn-cate { background: #007bff; }
        .btn-home { background: #17a2b8; }
    </style>
</head>
<body>
    <div class="topbar">
        <h2>🛠️ Bảng Điều Khiển Quản Trị (Admin Dashboard)</h2>
        <div class="topbar-right">
            <span>Xin chào: <b><c:out value="${sessionScope.account != null ? sessionScope.account.fullName : 'Admin'}" /></b></span>
            <a href="${pageContext.request.contextPath}/logout">Đăng xuất</a>
        </div>
    </div>

    <div class="main-container">
        <div class="sidebar">
            <div class="user-panel">
                <c:url value="/image?fname=${sessionScope.account != null && not empty sessionScope.account.avatar ? sessionScope.account.avatar : 'admin.png'}" var="userAvatar" />
                <img src="${userAvatar}" alt="User Avatar">
                <div>
                    <div style="font-size: 13px; font-weight: bold; color: #fff;"><c:out value="${sessionScope.account != null ? sessionScope.account.userName : 'admin'}" /></div>
                    <small style="color: #28a745;">● Quản trị viên (Role: 1)</small>
                </div>
            </div>
            <ul class="sidebar-menu">
                <li class="active"><a href="${pageContext.request.contextPath}/admin/home">📊 Tổng Quan Dashboard</a></li>
                <li><a href="${pageContext.request.contextPath}/admin/videos">🎬 Quản Lý Video & Duyệt Clip</a></li>
                <li><a href="${pageContext.request.contextPath}/admin/category/list">📁 Quản Lý Danh Mục</a></li>
                <li><a href="${pageContext.request.contextPath}/video">🎥 Kho Video Người Dùng</a></li>
                <li><a href="${pageContext.request.contextPath}/home">🌐 Về Trang Chủ Web</a></li>
            </ul>
        </div>

        <div class="content">
            <div class="welcome-card">
                <h1 style="font-size: 24px; color: #2c3e50;">Trung Tâm Quản Trị Hệ Thống Toàn Diện</h1>
                <p style="color: #6c757d; margin-top: 8px;">
                    Chào mừng bạn đến với khu vực điều hành chung. Tại đây bạn quản lý toàn bộ <b>Kho Video</b> (duyệt/khóa clip người dùng, tải video lên) và <b>Danh Mục Sản Phẩm</b>.
                </p>
                <div class="btn-group-welcome">
                    <a href="${pageContext.request.contextPath}/admin/videos" class="btn btn-video">🎬 Quản Lý & Phê Duyệt Video &rarr;</a>
                    <a href="${pageContext.request.contextPath}/admin/category/list" class="btn btn-cate">📁 Quản Lý Danh Mục &rarr;</a>
                    <a href="${pageContext.request.contextPath}/home" class="btn btn-home">🌐 Xem Trang Chủ (Top 10 Video) &rarr;</a>
                </div>
            </div>

            <div class="stat-grid">
                <div class="stat-card green">
                    <h3>🎬 Quản Lý Video</h3>
                    <p>Kiểm duyệt clip người dùng tải lên (Active/Inactive), thêm video mới, phát và chỉnh sửa thông tin.</p>
                    <a href="${pageContext.request.contextPath}/admin/videos">Mở Quản lý Video &rarr;</a>
                </div>
                <div class="stat-card">
                    <h3>📁 Quản Lý Danh Mục</h3>
                    <p>Thực hiện thêm, sửa, xóa, tìm kiếm danh mục sản phẩm theo công nghệ JPA Hibernate.</p>
                    <a href="${pageContext.request.contextPath}/admin/category/list">Mở Quản lý Danh mục &rarr;</a>
                </div>
                <div class="stat-card orange">
                    <h3>🎥 Kho Video Công Khai</h3>
                    <p>Xem danh sách video của khách hàng và cộng đồng (phân trang chuẩn 6 video/trang).</p>
                    <a href="${pageContext.request.contextPath}/video">Xem Kho Video &rarr;</a>
                </div>
                <div class="stat-card teal">
                    <h3>👥 Phân Quyền Hệ Thống</h3>
                    <p>Admin (toàn quyền) &bull; Manager (quản lý kho/danh mục) &bull; User (xem và tải video).</p>
                    <a href="${pageContext.request.contextPath}/home">Xem phân quyền người dùng &rarr;</a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
