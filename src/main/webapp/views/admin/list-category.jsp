<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý Danh mục - JPA 3.0</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Arial, sans-serif; }
        body { background-color: #f8f9fa; color: #333; }
        .topbar { background: #007bff; color: #fff; padding: 12px 25px; display: flex; justify-content: space-between; align-items: center; }
        .topbar h2 { font-size: 20px; font-weight: 600; }
        .topbar-right a { color: #fff; text-decoration: none; background: #dc3545; padding: 6px 14px; border-radius: 4px; font-size: 13px; font-weight: bold; margin-left: 10px; }
        .container { max-width: 1100px; margin: 30px auto; background: #fff; padding: 25px 30px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
        .header-actions { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .btn-add { background: #28a745; color: #fff; padding: 9px 18px; text-decoration: none; border-radius: 4px; font-weight: bold; }
        .search-box { display: flex; gap: 8px; }
        .search-box input { padding: 8px 12px; border: 1px solid #ced4da; border-radius: 4px; width: 250px; }
        .search-box button { background: #007bff; color: #fff; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer; font-weight: bold; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th, td { padding: 12px; text-align: left; border: 1px solid #dee2e6; vertical-align: middle; }
        th { background: #e9ecef; color: #495057; font-weight: 600; }
        tr:hover { background: #f8f9fa; }
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
        <h2>Hệ Thống Quản Lý Danh Mục (CRUD Category - JPA 3.0)</h2>
        <div class="topbar-right">
            <span>Xin chào, <strong>${sessionScope.account != null ? sessionScope.account.username : 'User'}</strong></span>
            <a href="<c:url value='/logout' />">Đăng xuất</a>
        </div>
    </div>

    <div class="container">
        <c:if test="${sessionScope.permissionError != null}">
            <div class="alert-error">${sessionScope.permissionError}</div>
            <c:remove var="permissionError" scope="session"/>
        </c:if>

        <div class="header-actions">
            <c:if test="${sessionScope.account == null || sessionScope.account.roleid == 1}">
                <a class="btn-add" href="<c:url value='/admin/category/add'/>">+ Add Category</a>
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
                    <th style="width: 140px; text-align: center;">Images</th>
                    <th>Category name</th>
                    <th style="width: 130px; text-align: center;">Status</th>
                    <th style="width: 160px; text-align: center;">Action</th>
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
                            <img height="80" width="100" style="object-fit: cover; border-radius: 4px;" src="${imgUrl}" alt="${cate.categoryname}" />
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
</body>
</html>
