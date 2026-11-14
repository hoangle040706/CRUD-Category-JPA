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
        .sidebar { width: 230px; background: #1e282c; color: #b8c7ce; padding: 20px 0; flex-shrink: 0; }
        .user-panel { padding: 12px 20px; display: flex; align-items: center; border-bottom: 1px solid #374850; margin-bottom: 15px; }
        .user-panel img { width: 45px; height: 45px; border-radius: 50%; object-fit: cover; margin-right: 12px; }
        .sidebar-menu { list-style: none; }
        .sidebar-menu li a { display: block; padding: 12px 20px; color: #b8c7ce; text-decoration: none; font-size: 14px; }
        .sidebar-menu li a:hover, .sidebar-menu li.active a { background: #1a2226; color: #fff; border-left: 3px solid #007bff; }
        .content { flex-grow: 1; padding: 25px 30px; }
        .welcome-card { background: #fff; border-radius: 8px; padding: 30px; box-shadow: 0 1px 4px rgba(0,0,0,0.08); margin-bottom: 25px; }
        .stat-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 20px; }
        .stat-card { background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 1px 4px rgba(0,0,0,0.08); border-left: 4px solid #007bff; }
        .stat-card.green { border-left-color: #28a745; }
        .stat-card.orange { border-left-color: #fd7e14; }
        .stat-card h3 { font-size: 24px; color: #2c3e50; margin-bottom: 5px; }
        .stat-card p { color: #7f8c8d; font-size: 14px; }
        .btn { display: inline-block; padding: 9px 18px; color: #fff; text-decoration: none; border-radius: 4px; font-weight: bold; background: #007bff; margin-top: 15px; }
        .btn:hover { background: #0056b3; }
    </style>
</head>
<body>
    <div class="topbar">
        <h2>Dashboard</h2>
        <div class="topbar-right">
            <span>Xin chào <b>${sessionScope.account != null ? sessionScope.account.fullName : 'Admin'}</b></span>
            <a href="${pageContext.request.contextPath}/logout">Đăng xuất</a>
        </div>
    </div>

    <div class="main-container">
        <div class="sidebar">
            <div class="user-panel">
                <c:url value="/image?fname=${sessionScope.account != null && not empty sessionScope.account.avatar ? sessionScope.account.avatar : 'admin.png'}" var="userAvatar" />
                <img src="${userAvatar}" alt="User Avatar">
                <div>
                    <div style="font-size: 13px; font-weight: bold; color: #fff;">${sessionScope.account != null ? sessionScope.account.userName : 'admin'}</div>
                    <small style="color: #28a745;">Trực tuyến</small>
                </div>
            </div>
            <ul class="sidebar-menu">
                <li class="active"><a href="${pageContext.request.contextPath}/admin/home">📊 Dashboard</a></li>
                <li><a href="${pageContext.request.contextPath}/admin/category/list">📁 Quản lý Danh mục</a></li>
                <li><a href="${pageContext.request.contextPath}/home">🌐 Về Trang Chủ Web</a></li>
            </ul>
        </div>

        <div class="content">
            <div class="welcome-card">
                <h1>Hệ Thống Quản Trị</h1>
                <p style="color: #6c757d; margin-top: 8px;">Chào mừng bạn đến với trang quản trị hệ thống</p>
                <a href="${pageContext.request.contextPath}/admin/category/list" class="btn">Đi đến Quản lý Danh mục &rarr;</a>
            </div>

            <div class="stat-grid">
                <div class="stat-card">
                    <h3>Quản Trị Viên</h3>
                    <p>Vai trò hiện tại: ADMIN (Role ID: 1)</p>
                </div>
                <div class="stat-card green">
                    <h3>Toàn Quyền</h3>
                    <p>Thêm, Sửa, Xóa và Upload Ảnh Danh mục</p>
                </div>
                <div class="stat-card orange">
                    <h3>Lưu Trữ Ảnh</h3>
                    <p>DownloadImageController</p>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
