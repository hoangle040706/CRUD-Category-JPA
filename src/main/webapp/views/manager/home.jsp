<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang Quản Lý - Manager Dashboard</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Arial, sans-serif; }
        body { background-color: #f0f2f5; color: #333; }
        .topbar { background: #fd7e14; color: #fff; padding: 12px 25px; display: flex; justify-content: space-between; align-items: center; }
        .topbar h2 { font-size: 20px; font-weight: 600; }
        .topbar-right a { color: #fff; text-decoration: none; background: #dc3545; padding: 6px 14px; border-radius: 4px; font-size: 13px; font-weight: bold; margin-left: 10px; }
        .main-container { display: flex; min-height: calc(100vh - 54px); }
        .sidebar { width: 240px; background: #2c3e50; color: #ecf0f1; padding: 20px 0; flex-shrink: 0; }
        .user-panel { padding: 12px 20px; display: flex; align-items: center; border-bottom: 1px solid #34495e; margin-bottom: 15px; }
        .user-panel img { width: 45px; height: 45px; border-radius: 50%; object-fit: cover; margin-right: 12px; }
        .sidebar-menu { list-style: none; }
        .sidebar-menu li a { display: block; padding: 12px 20px; color: #bdc3c7; text-decoration: none; font-size: 14px; }
        .sidebar-menu li a:hover, .sidebar-menu li.active a { background: #1a252f; color: #fff; border-left: 3px solid #fd7e14; }
        .content { flex-grow: 1; padding: 25px 30px; }
        .welcome-card { background: #fff; border-radius: 8px; padding: 30px; box-shadow: 0 1px 4px rgba(0,0,0,0.08); margin-bottom: 25px; }
        .stat-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 20px; }
        .stat-card { background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 1px 4px rgba(0,0,0,0.08); border-left: 4px solid #fd7e14; }
        .stat-card.blue { border-left-color: #007bff; }
        .stat-card.green { border-left-color: #28a745; }
        .stat-card h3 { font-size: 18px; color: #2c3e50; margin-bottom: 8px; }
        .stat-card p { color: #7f8c8d; font-size: 13px; line-height: 1.5; margin-bottom: 10px; }
        .stat-card a { font-size: 13px; color: #007bff; text-decoration: none; font-weight: bold; }
        .btn-group-welcome { display: flex; gap: 12px; margin-top: 18px; flex-wrap: wrap; }
        .btn { display: inline-block; padding: 9px 18px; color: #fff; text-decoration: none; border-radius: 4px; font-weight: bold; font-size: 13px; }
        .btn-orange { background: #fd7e14; }
        .btn-green { background: #28a745; }
        .btn-blue { background: #007bff; }
        .btn:hover { opacity: 0.9; }
    </style>
</head>
<body>
    <div class="topbar">
        <h2>📊 Khu Vực Điều Hành Quản Lý (Manager Dashboard)</h2>
        <div class="topbar-right">
            <span>Xin chào: <b><c:out value="${sessionScope.account != null ? sessionScope.account.fullName : 'Manager'}" /></b></span>
            <a href="${pageContext.request.contextPath}/logout">Đăng xuất</a>
        </div>
    </div>

    <div class="main-container">
        <div class="sidebar">
            <div class="user-panel">
                <c:url value="/image?fname=${sessionScope.account != null && not empty sessionScope.account.avatar ? sessionScope.account.avatar : 'manager.png'}" var="userAvatar" />
                <img src="${userAvatar}" alt="Manager Avatar">
                <div>
                    <div style="font-size: 13px; font-weight: bold; color: #fff;"><c:out value="${sessionScope.account != null ? sessionScope.account.userName : 'manager'}" /></div>
                    <small style="color: #fd7e14;">● Quản lý (Role ID: 2)</small>
                </div>
            </div>
            <ul class="sidebar-menu">
                <li class="active"><a href="${pageContext.request.contextPath}/manager/home">📊 Tổng Quan Manager</a></li>
                <li><a href="${pageContext.request.contextPath}/admin/category/list">📁 Giám Sát Danh Mục Sản Phẩm</a></li>
                <li><a href="${pageContext.request.contextPath}/video">🎬 Xem Kho Video Hệ Thống</a></li>
                <li><a href="${pageContext.request.contextPath}/home">🌐 Về Trang Chủ Web</a></li>
            </ul>
        </div>

        <div class="content">
            <div class="welcome-card">
                <h1 style="font-size: 24px; color: #2c3e50;">Khu Vực Quản Lý & Giám Sát Nghiệp Vụ</h1>
                <p style="color: #6c757d; margin-top: 8px;">
                    Dành riêng cho vai trò Quản lý cửa hàng (Role ID: 2). Bạn có quyền theo dõi danh mục hàng hóa, giám sát video review sản phẩm của người dùng và hệ thống.
                </p>
                <div class="btn-group-welcome">
                    <a href="${pageContext.request.contextPath}/admin/category/list" class="btn btn-orange">📁 Giám Sát Danh Mục Sản Phẩm &rarr;</a>
                    <a href="${pageContext.request.contextPath}/video" class="btn btn-green">🎬 Xem Kho Video (6 video/trang) &rarr;</a>
                    <a href="${pageContext.request.contextPath}/home" class="btn btn-blue">🌐 Xem Trang Chủ &rarr;</a>
                </div>
            </div>

            <div class="stat-grid">
                <div class="stat-card">
                    <h3>Quản Lý Cửa Hàng</h3>
                    <p>Vai trò MANAGER (Role ID: 2) phụ trách kiểm soát hàng hóa và hoạt động chung của cửa hàng.</p>
                </div>
                <div class="stat-card blue">
                    <h3>Danh Mục Sản Phẩm</h3>
                    <p>Theo dõi các nhóm ngành hàng (iPhone, Laptop MacBook, Thời trang Nam/Nữ).</p>
                    <a href="${pageContext.request.contextPath}/admin/category/list">Xem Danh mục &rarr;</a>
                </div>
                <div class="stat-card green">
                    <h3>Kho Video Trực Tuyến</h3>
                    <p>Giám sát toàn bộ các clip unboxing, review sản phẩm và hướng dẫn công nghệ.</p>
                    <a href="${pageContext.request.contextPath}/video">Xem Kho Video &rarr;</a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
