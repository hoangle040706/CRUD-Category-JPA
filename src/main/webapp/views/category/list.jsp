<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh Sách Danh Mục</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f4f6f9; }
        .container { background: #fff; padding: 30px; border-radius: 8px; max-width: 850px; margin: 0 auto; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .user-badge { display: inline-block; padding: 4px 8px; border-radius: 4px; font-size: 13px; font-weight: bold; }
        .badge-admin { background-color: #d1ecf1; color: #0c5460; }
        .badge-user { background-color: #e2e3e5; color: #383d41; }
        .btn { display: inline-block; padding: 8px 14px; text-decoration: none; border-radius: 4px; font-weight: bold; font-size: 14px; }
        .btn-success { background: #28a745; color: #fff; }
        .btn-success:hover { background: #218838; }
        .btn-warning { background: #ffc107; color: #212529; }
        .btn-warning:hover { background: #e0a800; }
        .btn-danger { background: #dc3545; color: #fff; }
        .btn-danger:hover { background: #c82333; }
        .btn-secondary { background: #6c757d; color: #fff; }
        .btn-secondary:hover { background: #5a6268; }
        .alert-danger { background-color: #f8d7da; color: #721c24; padding: 12px; border-radius: 4px; margin-bottom: 16px; border: 1px solid #f5c6cb; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th, td { border: 1px solid #dee2e6; padding: 12px; text-align: left; }
        th { background-color: #e9ecef; font-weight: bold; }
        tr:nth-child(even) { background-color: #f8f9fa; }
        .action-cell { white-space: nowrap; width: 140px; text-align: center; }
        .empty-row { text-align: center; color: #888; font-style: italic; }
    </style>
</head>
<body>
    <div class="container">
        <c:if test="${not empty sessionScope.permissionError}">
            <div class="alert-danger">${sessionScope.permissionError}</div>
            <c:remove var="permissionError" scope="session"/>
        </c:if>

        <div class="header">
            <div>
                <h2 style="margin-bottom: 5px;">Quản Lý Danh Mục (Category)</h2>
                <div>
                    Xin chào <b>${sessionScope.account.username}</b> 
                    <span class="user-badge ${sessionScope.account.admin ? 'badge-admin' : 'badge-user'}">
                        ${sessionScope.account.role}
                    </span>
                </div>
            </div>
            <div>
                <c:if test="${sessionScope.account.admin}">
                    <a href="${pageContext.request.contextPath}/category/add" class="btn btn-success">+ Thêm Mới</a>
                </c:if>
                <a href="${pageContext.request.contextPath}/home" class="btn btn-secondary">Về Trang Chủ</a>
            </div>
        </div>

        <table>
            <thead>
                <tr>
                    <th style="width: 60px;">ID</th>
                    <th>Tên Danh Mục</th>
                    <th>Mô Tả</th>
                    <c:if test="${sessionScope.account.admin}">
                        <th class="action-cell">Hành Động</th>
                    </c:if>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${not empty categoryList}">
                        <c:forEach var="cat" items="${categoryList}">
                            <tr>
                                <td>${cat.id}</td>
                                <td><b>${cat.name}</b></td>
                                <td>${cat.description}</td>
                                <c:if test="${sessionScope.account.admin}">
                                    <td class="action-cell">
                                        <a href="${pageContext.request.contextPath}/category/edit?id=${cat.id}" class="btn btn-warning">Sửa</a>
                                        <a href="${pageContext.request.contextPath}/category/delete?id=${cat.id}" 
                                           class="btn btn-danger" 
                                           onclick="return confirm('Bạn có chắc chắn muốn xóa danh mục &quot;${cat.name}&quot;?');">Xóa</a>
                                    </td>
                                </c:if>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="${sessionScope.account.admin ? 4 : 3}" class="empty-row">Chưa có danh mục nào trong cơ sở dữ liệu.</td>
                        </tr>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
</body>
</html>
