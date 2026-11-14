<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang Chủ</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Arial, sans-serif; }
        body { background-color: #f4f6f9; color: #333; }
        .topbar { background: #343a40; color: #fff; padding: 10px 30px; display: flex; justify-content: space-between; align-items: center; }
        .topbar a { color: #f8f9fa; text-decoration: none; font-size: 14px; font-weight: 500; }
        .topbar a:hover { color: #007bff; }
        .container { max-width: 900px; margin: 40px auto; background: #fff; padding: 35px; border-radius: 8px; box-shadow: 0 4px 15px rgba(0,0,0,0.08); }
        h1 { color: #2c3e50; font-size: 26px; margin-bottom: 20px; }
        .user-card { background: #e9ecef; padding: 20px; border-radius: 6px; margin: 20px 0; display: flex; gap: 20px; align-items: center; }
        .avatar-img { width: 70px; height: 70px; border-radius: 50%; object-fit: cover; border: 2px solid #007bff; }
        .user-info h3 { margin-bottom: 6px; font-size: 18px; }
        .user-badge { display: inline-block; padding: 3px 8px; border-radius: 4px; font-size: 12px; font-weight: bold; }
        .badge-admin { background: #d1ecf1; color: #0c5460; }
        .badge-manager { background: #fff3cd; color: #856404; }
        .badge-user { background: #e2e3e5; color: #383d41; }
        .btn-group { margin-top: 25px; display: flex; gap: 12px; }
        .btn { display: inline-block; padding: 10px 20px; text-decoration: none; border-radius: 4px; font-weight: bold; font-size: 14px; }
        .btn-primary { background: #007bff; color: #fff; }
        .btn-primary:hover { background: #0056b3; }
        .btn-success { background: #28a745; color: #fff; }
        .btn-success:hover { background: #218838; }
        .btn-danger { background: #dc3545; color: #fff; }
        .btn-danger:hover { background: #c82333; }
        .alert-danger { background-color: #f8d7da; color: #721c24; padding: 12px; border-radius: 4px; margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="topbar">
        <div><b>Hệ Thống Web MVC 3 Tầng</b></div>
        <div>
            <c:choose>
                <c:when test="${sessionScope.account == null}">
                    <a href="${pageContext.request.contextPath}/login">Đăng nhập</a> |
                    <a href="${pageContext.request.contextPath}/register">Đăng ký</a>
                </c:when>
                <c:otherwise>
                    <span>Xin chào: <b>${sessionScope.account.fullName}</b></span> |
                    <a href="${pageContext.request.contextPath}/logout">Đăng Xuất</a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <div class="container">
        <c:if test="${not empty sessionScope.permissionError}">
            <div class="alert-danger">${sessionScope.permissionError}</div>
            <c:remove var="permissionError" scope="session"/>
        </c:if>

        <h1>Hệ Thống Quản Lý Danh Mục</h1>

        <c:choose>
            <c:when test="${not empty sessionScope.account}">
                <div class="user-card">
                    <c:url value="/image?fname=${not empty sessionScope.account.avatar ? sessionScope.account.avatar : 'default.png'}" var="avatarUrl" />
                    <img class="avatar-img" src="${avatarUrl}" alt="Avatar">
                    <div class="user-info">
                        <h3>
                            ${sessionScope.account.fullName} 
                            <span class="user-badge ${sessionScope.account.roleid == 1 ? 'badge-admin' : (sessionScope.account.roleid == 2 ? 'badge-manager' : 'badge-user')}">
                                ${sessionScope.account.roleName} (Role ID: ${sessionScope.account.roleid})
                            </span>
                        </h3>
                        <p><b>Username:</b> ${sessionScope.account.userName} | <b>Email:</b> ${sessionScope.account.email}</p>
                        <c:if test="${not empty sessionScope.account.phone}">
                            <p><b>Số điện thoại:</b> ${sessionScope.account.phone}</p>
                        </c:if>
                    </div>
                </div>

                <div class="btn-group">
                    <c:if test="${sessionScope.account.roleid == 1}">
                        <a href="${pageContext.request.contextPath}/admin/category/list" class="btn btn-primary">Quản lý Danh mục</a>
                        <a href="${pageContext.request.contextPath}/admin/home" class="btn btn-success">Trang Quản Trị (Admin Dashboard)</a>
                    </c:if>
                    <c:if test="${sessionScope.account.roleid != 1}">
                        <a href="${pageContext.request.contextPath}/admin/category/list" class="btn btn-primary">Xem Danh sách Danh mục</a>
                    </c:if>
                    <a href="${pageContext.request.contextPath}/logout" class="btn btn-danger">Đăng xuất</a>
                </div>
            </c:when>

            <c:otherwise>
                <div style="margin: 25px 0;">
                    <p>Bạn chưa đăng nhập vào hệ thống. Vui lòng đăng nhập hoặc đăng ký tài khoản để tiếp tục.</p>
                </div>
                <div class="btn-group">
                    <a href="${pageContext.request.contextPath}/login" class="btn btn-primary">Đăng nhập</a>
                    <a href="${pageContext.request.contextPath}/register" class="btn btn-success">Đăng ký tài khoản</a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</body>
</html>
