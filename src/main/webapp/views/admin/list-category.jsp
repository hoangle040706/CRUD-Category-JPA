<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Danh Mục - Admin Dashboard</title>
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
        .content { flex-grow: 1; padding: 25px 30px; overflow-x: auto; }
        .card { background: #fff; border-radius: 8px; padding: 25px; box-shadow: 0 1px 4px rgba(0,0,0,0.08); }
        .header-actions { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; flex-wrap: wrap; gap: 15px; }
        .btn-add { background: #28a745; color: #fff; padding: 9px 18px; text-decoration: none; border-radius: 4px; font-weight: bold; font-size: 14px; }
        .btn-add:hover { background: #218838; }
        .search-box { display: flex; gap: 8px; }
        .search-box input { padding: 8px 12px; border: 1px solid #ced4da; border-radius: 4px; width: 240px; }
        .search-box button { background: #007bff; color: #fff; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer; font-weight: bold; }

        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #dee2e6; vertical-align: middle; font-size: 14px; }
        th { background: #f8f9fa; color: #495057; font-weight: 600; }
        tr:hover { background: #f8fafc; }
        .badge { padding: 4px 10px; border-radius: 12px; font-size: 12px; font-weight: bold; }
        .badge-success { background: #d4edda; color: #155724; }
        .badge-danger { background: #f8d7da; color: #721c24; }
        .btn-action { padding: 5px 12px; border-radius: 4px; text-decoration: none; font-size: 13px; font-weight: bold; margin-right: 5px; }
        .btn-edit { background: #ffc107; color: #212529; }
        .btn-delete { background: #dc3545; color: #fff; }
        .alert-error { background: #f8d7da; color: #721c24; padding: 12px 15px; border-radius: 4px; margin-bottom: 20px; border: 1px solid #f5c6cb; }
    </style>
</head>
<body>
    <div class="topbar">
        <h2>📁 Quản Lý Danh Mục Sản Phẩm</h2>
        <div class="topbar-right">
            <span>Xin chào, <strong>${sessionScope.account != null ? sessionScope.account.username : 'User'}</strong></span>
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
                <c:if test="${sessionScope.permissionError != null}">
                    <div class="alert-error">${sessionScope.permissionError}</div>
                    <c:remove var="permissionError" scope="session"/>
                </c:if>

                <div class="header-actions">
                    <c:if test="${sessionScope.account == null || sessionScope.account.roleid == 1}">
                        <a class="btn-add" href="<c:url value='/admin/category/add'/>">➕ Thêm Danh Mục Mới</a>
                    </c:if>
                    <form action="<c:url value='/admin/categories'/>" method="get" class="search-box">
                        <input type="text" name="keyword" placeholder="Tìm theo tên danh mục..." value="${param.keyword}" />
                        <button type="submit">Tìm kiếm</button>
                    </form>
                </div>

                <table>
                    <thead>
                        <tr>
                            <th style="width: 60px; text-align: center;">STT</th>
                            <th style="width: 140px; text-align: center;">Hình ảnh</th>
                            <th>Tên Danh Mục</th>
                            <th style="width: 130px; text-align: center;">Trạng thái</th>
                            <th style="width: 160px; text-align: center;">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${listcate}" var="cate" varStatus="STT">
                            <tr>
                                <td style="text-align: center;">${STT.index + 1}</td>
                                <td style="text-align: center;">
                                    <c:choose>
                                        <c:when test="${cate.images != null && cate.images.startsWith('http')}">
                                            <c:set var="imgUrl" value="${cate.images}" />
                                        </c:when>
                                        <c:otherwise>
                                            <c:url value="/image?fname=${cate.images != null && not empty cate.images ? cate.images : 'default.png'}" var="imgUrl" />
                                        </c:otherwise>
                                    </c:choose>
                                    <img height="60" width="80" style="object-fit: cover; border-radius: 4px;" src="${imgUrl}" alt="${cate.categoryname}" />
                                </td>
                                <td><strong>${cate.categoryname}</strong></td>
                                <td style="text-align: center;">
                                    <c:if test="${cate.status == 1}">
                                        <span class="badge badge-success">Hoạt động</span>
                                    </c:if>
                                    <c:if test="${cate.status != 1}">
                                        <span class="badge badge-danger">Khóa</span>
                                    </c:if>
                                </td>
                                <td style="text-align: center;">
                                    <c:if test="${sessionScope.account == null || sessionScope.account.roleid == 1}">
                                        <a class="btn-action btn-edit" href="<c:url value='/admin/category/edit?id=${cate.categoryid}'/>">Sửa</a>
                                        <a class="btn-action btn-delete" href="<c:url value='/admin/category/delete?id=${cate.categoryid}'/>" onclick="return confirm('Bạn có chắc muốn xóa danh mục này?');">Xóa</a>
                                    </c:if>
                                    <c:if test="${sessionScope.account != null && sessionScope.account.roleid != 1}">
                                        <span style="color: #6c757d; font-size: 13px;">Chỉ xem</span>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
