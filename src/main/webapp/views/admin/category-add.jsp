<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thêm Danh Mục Mới - Admin Dashboard</title>
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
        .card { max-width: 650px; background: #fff; border-radius: 8px; padding: 30px; box-shadow: 0 1px 4px rgba(0,0,0,0.08); }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 8px; font-weight: 600; font-size: 14px; color: #495057; }
        input[type="text"], input[type="file"] { width: 100%; padding: 10px 14px; border: 1px solid #ced4da; border-radius: 4px; font-size: 14px; outline: none; }
        .radio-group { display: flex; gap: 20px; align-items: center; padding: 6px 0; }
        .btn-group { display: flex; gap: 12px; margin-top: 25px; }
        .btn { padding: 10px 20px; border-radius: 4px; font-weight: bold; font-size: 14px; cursor: pointer; border: none; text-decoration: none; }
        .btn-success { background: #28a745; color: #fff; }
        .btn-secondary { background: #6c757d; color: #fff; }
    </style>
</head>
<body>
    <div class="topbar">
        <h2>📁 Quản Trị Danh Mục - Thêm Mới</h2>
        <div class="topbar-right">
            <span>Xin chào, <strong>${sessionScope.account != null ? sessionScope.account.username : 'Admin'}</strong></span>
            <a href="<c:url value='/logout' />">Đăng xuất</a>
        </div>
    </div>

    <div class="main-container">
        <div class="sidebar">
            <div class="user-panel">
                <c:url value="/image?fname=${sessionScope.account != null && not empty sessionScope.account.avatar ? sessionScope.account.avatar : 'admin.png'}" var="userAvatar" />
                <img src="${userAvatar}" alt="User Avatar">
                <div>
                    <div style="font-size: 13px; font-weight: bold; color: #fff;"><c:out value="${sessionScope.account != null ? sessionScope.account.userName : 'admin'}" /></div>
                    <small style="color: #28a745;">● Trực tuyến</small>
                </div>
            </div>
            <ul class="sidebar-menu">
                <li><a href="${pageContext.request.contextPath}/admin/home">📊 Tổng Quan Dashboard</a></li>
                <li><a href="${pageContext.request.contextPath}/admin/videos">🎬 Quản Lý Video & Duyệt Clip</a></li>
                <li class="active"><a href="${pageContext.request.contextPath}/admin/category/list">📁 Quản Lý Danh Mục</a></li>
                <li><a href="${pageContext.request.contextPath}/video">🎥 Kho Video Người Dùng</a></li>
                <li><a href="${pageContext.request.contextPath}/home">🌐 Về Trang Chủ Web</a></li>
            </ul>
        </div>

        <div class="content">
            <div class="card">
                <h3 style="margin-bottom: 20px; border-bottom: 1px solid #dee2e6; padding-bottom: 10px;">Thêm Danh Mục Sản Phẩm Mới</h3>
                <form action="<c:url value='/admin/category/insert'/>" method="post" enctype="multipart/form-data">
                    <div class="form-group">
                        <label for="categoryname">Tên Danh Mục <span style="color:red;">*</span></label>
                        <input type="text" id="categoryname" name="categoryname" required placeholder="Nhập tên danh mục..." />
                    </div>

                    <div class="form-group">
                        <label for="images">Đường dẫn ảnh Online (URL):</label>
                        <input type="text" id="images" name="images" placeholder="https://example.com/image.jpg" />
                    </div>

                    <div class="form-group">
                        <label for="images1">Hoặc tải file ảnh lên:</label>
                        <input type="file" id="images1" name="images1" accept="image/*" />
                    </div>

                    <div class="form-group">
                        <label>Trạng thái:</label>
                        <div class="radio-group">
                            <label><input type="radio" id="ston" name="status" value="1" checked /> Hoạt động</label>
                            <label><input type="radio" id="stoff" name="status" value="0" /> Khóa</label>
                        </div>
                    </div>

                    <div class="btn-group">
                        <button type="submit" class="btn btn-success">Lưu Danh Mục</button>
                        <a href="<c:url value='/admin/category/list'/>" class="btn btn-secondary">Hủy bỏ</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</body>
</html>
