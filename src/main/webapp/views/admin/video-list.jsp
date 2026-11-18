<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Video - Admin Dashboard</title>
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
        .content { flex-grow: 1; padding: 25px 30px; overflow-x: auto; }
        .card { background: #fff; border-radius: 8px; padding: 25px; box-shadow: 0 1px 4px rgba(0,0,0,0.08); }
        .card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; flex-wrap: wrap; gap: 15px; }
        .btn-add { background: #28a745; color: #fff; padding: 9px 18px; border-radius: 4px; text-decoration: none; font-weight: bold; font-size: 14px; }
        .btn-add:hover { background: #218838; }

        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { padding: 12px 14px; text-align: left; border-bottom: 1px solid #dee2e6; font-size: 14px; vertical-align: middle; }
        th { background-color: #f8f9fa; color: #495057; font-weight: 600; }
        tr:hover { background-color: #f8fafc; }
        .poster-thumb { width: 80px; height: 48px; object-fit: cover; border-radius: 4px; background: #000; }
        .badge { display: inline-block; padding: 4px 8px; border-radius: 4px; font-size: 11px; font-weight: bold; }
        .badge-active { background: #d4edda; color: #155724; }
        .badge-locked { background: #f8d7da; color: #721c24; }
        .btn-sm { padding: 4px 10px; font-size: 12px; border-radius: 3px; text-decoration: none; font-weight: bold; border: none; cursor: pointer; }
        .btn-edit { background: #ffc107; color: #212529; }
        .btn-del { background: #dc3545; color: #fff; }
        .btn-toggle { background: #6c757d; color: #fff; }
        .pagination { display: flex; justify-content: center; gap: 6px; margin-top: 25px; }
        .page-link { display: inline-block; padding: 7px 12px; background: #fff; border: 1px solid #dee2e6; color: #007bff; text-decoration: none; border-radius: 4px; font-size: 13px; }
        .page-link.active { background: #007bff; color: #fff; border-color: #007bff; }
        .alert-success { background: #d4edda; color: #155724; padding: 12px; border-radius: 4px; margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="topbar">
        <h2>🎬 Quản Lý Video Hệ Thống</h2>
        <div class="topbar-right">
            <span>Xin chào <b><c:out value="${sessionScope.account != null ? sessionScope.account.fullName : 'Admin'}" /></b></span>
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
                    <small style="color: #28a745;">Trực tuyến</small>
                </div>
            </div>
            <ul class="sidebar-menu">
                <li><a href="${pageContext.request.contextPath}/admin/home">📊 Dashboard</a></li>
                <li class="active"><a href="${pageContext.request.contextPath}/admin/videos">🎬 Quản lý Video</a></li>
                <li><a href="${pageContext.request.contextPath}/admin/category/list">📁 Quản lý Danh mục</a></li>
                <li><a href="${pageContext.request.contextPath}/home">🌐 Về Trang Chủ Web</a></li>
            </ul>
        </div>

        <div class="content">
            <c:if test="${not empty param.msg}">
                <div class="alert-success">Thao tác dữ liệu video thành công!</div>
            </c:if>

            <div class="card">
                <div class="card-header">
                    <h3>Danh Sách Tất Cả Video (${totalVideos})</h3>
                    <a href="${pageContext.request.contextPath}/admin/video/add" class="btn-add">➕ Thêm Video Mới</a>
                </div>

                <table>
                    <thead>
                        <tr>
                            <th>Ảnh bìa</th>
                            <th>Tiêu đề & ID</th>
                            <th>Danh mục</th>
                            <th>Nguồn</th>
                            <th>Người đăng</th>
                            <th>Lượt xem</th>
                            <th>Trạng thái</th>
                            <th>Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${videos}" var="v">
                            <tr>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty v.poster && v.poster.startsWith('http')}">
                                            <img src="${v.poster}" class="poster-thumb" alt="Poster">
                                        </c:when>
                                        <c:when test="${not empty v.poster}">
                                            <img src="${pageContext.request.contextPath}/image?type=poster&fname=${v.poster}" class="poster-thumb" alt="Poster">
                                        </c:when>
                                        <c:otherwise>
                                            <img src="${pageContext.request.contextPath}/image?fname=default.png" class="poster-thumb" alt="Poster">
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/video/detail?id=${v.videoId}" target="_blank" style="font-weight: bold; color: #007bff; text-decoration: none;">
                                        <c:out value="${v.title}" />
                                    </a>
                                    <div style="font-size: 11px; color: #888;">ID: <c:out value="${v.videoId}" /></div>
                                </td>
                                <td><c:out value="${v.category != null ? v.category.categoryname : 'Chung'}" /></td>
                                <td><span class="badge" style="background:#e9ecef;"><c:out value="${v.sourceType}" /></span></td>
                                <td><c:out value="${v.user != null ? v.user.fullName : 'Admin'}" /></td>
                                <td><c:out value="${v.views}" /></td>
                                <td>
                                    <form method="post" action="${pageContext.request.contextPath}/admin/video/toggle-active" style="display:inline;">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.CSRF_TOKEN}">
                                        <input type="hidden" name="id" value="${v.videoId}">
                                        <input type="hidden" name="active" value="${v.active == 1 ? 0 : 1}">
                                        <button type="submit" class="btn-sm ${v.active == 1 ? 'badge-active' : 'badge-locked'}" title="Nhấn để đổi trạng thái">
                                            ${v.active == 1 ? '✅ Đã Duyệt' : '🔒 Khóa/Chờ'}
                                        </button>
                                    </form>
                                </td>
                                <td>
                                    <div style="display: flex; gap: 6px;">
                                        <a href="${pageContext.request.contextPath}/admin/video/edit?id=${v.videoId}" class="btn-sm btn-edit">Sửa</a>
                                        <form method="post" action="${pageContext.request.contextPath}/admin/video/delete" onsubmit="return confirm('Bạn có chắc chắn muốn xóa vĩnh viễn video này?');" style="display:inline;">
                                            <input type="hidden" name="csrfToken" value="${sessionScope.CSRF_TOKEN}">
                                            <input type="hidden" name="id" value="${v.videoId}">
                                            <button type="submit" class="btn-sm btn-del">Xóa</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>

                <c:if test="${totalPages > 1}">
                    <div class="pagination">
                        <c:forEach begin="1" end="${totalPages}" var="p">
                            <a href="${pageContext.request.contextPath}/admin/videos?page=${p}" class="page-link ${p == currentPage ? 'active' : ''}">${p}</a>
                        </c:forEach>
                    </div>
                </c:if>
            </div>
        </div>
    </div>
</body>
</html>
