<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh Sách Danh Mục - MyVideo Platform</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', system-ui, -apple-system, BlinkMacSystemFont, Roboto, sans-serif; }
        body { background-color: #f8fafc; color: #0f172a; line-height: 1.5; padding: 30px 20px; }
        .container { background: #fff; padding: 30px; border-radius: 12px; max-width: 900px; margin: 0 auto; border: 1px solid #e2e8f0; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; flex-wrap: wrap; gap: 16px; border-bottom: 2px solid #eff6ff; padding-bottom: 16px; }
        h1 { color: #1e3a8a; font-size: 20px; font-weight: 700; margin-bottom: 4px; }
        .user-status { font-size: 13px; color: #64748b; }
        .user-badge { display: inline-block; padding: 2px 8px; border-radius: 12px; font-size: 11px; font-weight: 600; margin-left: 6px; }
        .badge-admin { background-color: #eff6ff; color: #1d4ed8; border: 1px solid #bfdbfe; }
        .badge-user { background-color: #f1f5f9; color: #334155; border: 1px solid #cbd5e1; }
        
        .header-actions { display: flex; gap: 10px; }
        .btn { display: inline-block; padding: 8px 16px; text-decoration: none; border-radius: 6px; font-weight: 600; font-size: 13px; transition: all 0.15s; }
        .btn-primary { background: #2563eb; color: #fff; }
        .btn-primary:hover { background: #1d4ed8; }
        .btn-warning { background: #f59e0b; color: #fff; }
        .btn-warning:hover { background: #d97706; }
        .btn-danger { background: #ef4444; color: #fff; }
        .btn-danger:hover { background: #dc2626; }
        .btn-secondary { background: #64748b; color: #fff; }
        .btn-secondary:hover { background: #475569; }
        
        .alert-danger { background-color: #fef2f2; color: #991b1b; padding: 12px 16px; border-radius: 8px; margin-bottom: 20px; border: 1px solid #fecaca; font-size: 14px; }
        
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { border-bottom: 1px solid #e2e8f0; padding: 12px 14px; text-align: left; font-size: 14px; vertical-align: middle; }
        th { background-color: #f1f5f9; color: #334155; font-weight: 600; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px; }
        tr:hover { background-color: #f8fafc; }
        .action-cell { white-space: nowrap; width: 150px; text-align: center; }
        .empty-row { text-align: center; color: #64748b; padding: 30px; font-style: italic; }
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
                <h1>Quản Lý Danh Mục</h1>
                <div class="user-status">
                    Xin chào <b><c:out value="${sessionScope.account.username}" /></b> 
                    <span class="user-badge ${sessionScope.account.admin ? 'badge-admin' : 'badge-user'}">
                        <c:out value="${sessionScope.account.role}" />
                    </span>
                </div>
            </div>
            <div class="header-actions">
                <c:if test="${sessionScope.account.admin}">
                    <a href="${pageContext.request.contextPath}/category/add" class="btn btn-primary">Thêm Mới</a>
                </c:if>
                <a href="${pageContext.request.contextPath}/home" class="btn btn-secondary">Về Trang Chủ</a>
            </div>
        </div>

        <table>
            <thead>
                <tr>
                    <th style="width: 70px;">ID</th>
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
                                <td><c:out value="${cat.id}" /></td>
                                <td><b><c:out value="${cat.name}" /></b></td>
                                <td><c:out value="${cat.description}" /></td>
                                <c:if test="${sessionScope.account.admin}">
                                    <td class="action-cell">
                                        <a href="${pageContext.request.contextPath}/category/edit?id=${cat.id}" class="btn btn-warning" style="padding: 5px 10px; font-size: 12px;">Sửa</a>
                                        <a href="${pageContext.request.contextPath}/category/delete?id=${cat.id}" 
                                           class="btn btn-danger" style="padding: 5px 10px; font-size: 12px;"
                                           onclick="return confirm('Bạn có chắc chắn muốn xóa danh mục này?');">Xóa</a>
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