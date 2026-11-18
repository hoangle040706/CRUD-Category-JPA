<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản Lý Video - Admin Dashboard</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', system-ui, -apple-system, BlinkMacSystemFont, Roboto, sans-serif; }
        body { background-color: #f8fafc; color: #0f172a; line-height: 1.5; }

        /* Unified Topbar */
        .topbar { background: linear-gradient(135deg, #1e3a8a 0%, #1d4ed8 50%, #2563eb 100%); color: #fff; box-shadow: 0 2px 10px rgba(30, 58, 138, 0.15); position: sticky; top: 0; z-index: 100; }
        .topbar-container { max-width: 100%; margin: 0 auto; padding: 0 25px; height: 60px; display: flex; justify-content: space-between; align-items: center; }
        .nav-brand-group { display: flex; align-items: center; gap: 28px; }
        .brand-logo { color: #ffffff; font-size: 18px; font-weight: 700; text-decoration: none; letter-spacing: -0.3px; }
        .nav-subtitle { color: #bfdbfe; font-size: 13px; font-weight: 500; padding-left: 15px; border-left: 1px solid rgba(255, 255, 255, 0.25); }

        .nav-user-group { display: flex; align-items: center; gap: 14px; }
        .user-greeting { display: flex; align-items: center; gap: 8px; }
        .user-name { color: #ffffff; font-weight: 600; font-size: 14px; }
        .user-role-pill { background: rgba(255, 255, 255, 0.2); color: #ffffff; padding: 2px 8px; border-radius: 12px; font-size: 11px; font-weight: 600; }
        .btn-logout { background: rgba(239, 68, 68, 0.9); color: #ffffff; padding: 6px 14px; border-radius: 6px; font-size: 13px; font-weight: 600; text-decoration: none; transition: background 0.15s; }
        .btn-logout:hover { background: #dc2626; }

        /* Main Container */
        .main-container { display: flex; min-height: calc(100vh - 60px); }
        .sidebar { width: 250px; background: #0f172a; color: #94a3b8; padding: 20px 0; flex-shrink: 0; display: flex; flex-direction: column; }
        .user-panel { padding: 15px 20px; display: flex; align-items: center; border-bottom: 1px solid #1e293b; margin-bottom: 15px; }
        .user-panel img { width: 44px; height: 44px; border-radius: 50%; object-fit: cover; margin-right: 12px; border: 2px solid #3b82f6; }
        .online-dot { display: inline-block; width: 8px; height: 8px; border-radius: 50%; background: #10b981; margin-right: 4px; }
        .user-role-text { font-size: 12px; color: #93c5fd; display: flex; align-items: center; margin-top: 3px; }

        .sidebar-menu { list-style: none; }
        .sidebar-menu li a { display: block; padding: 12px 22px; color: #94a3b8; text-decoration: none; font-size: 14px; font-weight: 500; transition: all 0.15s ease; border-left: 4px solid transparent; }
        .sidebar-menu li a:hover { background: #1e293b; color: #60a5fa; }
        .sidebar-menu li.active a { background: #2563eb; color: #ffffff; font-weight: 600; border-left-color: #93c5fd; }

        /* Content Area */
        .content { flex-grow: 1; padding: 30px; background-color: #f8fafc; overflow-x: auto; }
        .card { background: #fff; border-radius: 12px; padding: 26px; border: 1px solid #e2e8f0; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); }
        .card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 22px; flex-wrap: wrap; gap: 16px; }
        .card-header h2 { font-size: 18px; color: #1e3a8a; font-weight: 700; }
        .btn-add { background: #2563eb; color: #fff; padding: 9px 18px; border-radius: 6px; text-decoration: none; font-weight: 600; font-size: 14px; transition: background 0.15s; }
        .btn-add:hover { background: #1d4ed8; }

        /* Table */
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { padding: 13px 14px; text-align: left; border-bottom: 1px solid #e2e8f0; font-size: 14px; vertical-align: middle; }
        th { background-color: #f1f5f9; color: #334155; font-weight: 600; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px; }
        tr:hover { background-color: #f8fafc; }
        .poster-thumb { width: 80px; height: 48px; object-fit: cover; border-radius: 6px; background: #0f172a; }
        
        .badge { display: inline-block; padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 600; }
        .badge-active { background: #ecfdf5; color: #047857; border: 1px solid #a7f3d0; cursor: pointer; }
        .badge-locked { background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; cursor: pointer; }
        
        .btn-sm { padding: 5px 12px; font-size: 12px; border-radius: 4px; text-decoration: none; font-weight: 600; border: none; cursor: pointer; transition: all 0.15s; }
        .btn-edit { background: #f59e0b; color: #fff; }
        .btn-edit:hover { background: #d97706; }
        .btn-del { background: #ef4444; color: #fff; }
        .btn-del:hover { background: #dc2626; }
        
        .pagination { display: flex; justify-content: center; gap: 6px; margin-top: 25px; }
        .page-link { display: inline-block; padding: 7px 13px; background: #fff; border: 1px solid #cbd5e1; color: #2563eb; text-decoration: none; border-radius: 6px; font-size: 13px; font-weight: 600; transition: all 0.15s; }
        .page-link:hover { background: #eff6ff; }
        .page-link.active { background: #2563eb; color: #fff; border-color: #2563eb; }
        .alert-success { background: #ecfdf5; color: #047857; padding: 12px 16px; border-radius: 8px; margin-bottom: 20px; border: 1px solid #a7f3d0; font-size: 14px; }
    </style>
</head>
<body>
    <header class="topbar">
        <div class="topbar-container">
            <div class="nav-brand-group">
                <a href="${pageContext.request.contextPath}/home" class="brand-logo">MyVideo Platform</a>
                <span class="nav-subtitle">Quản Lý Video Hệ Thống</span>
            </div>
            <div class="nav-user-group">
                <div class="user-greeting">
                    <span class="user-name"><c:out value="${sessionScope.account != null ? sessionScope.account.fullName : 'Admin'}" /></span>
                    <span class="user-role-pill">Admin</span>
                </div>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Đăng xuất</a>
            </div>
        </div>
    </header>

    <div class="main-container">
        <aside class="sidebar">
            <div class="user-panel">
                <c:url value="/image?fname=${sessionScope.account != null && not empty sessionScope.account.avatar ? sessionScope.account.avatar : 'admin.png'}" var="userAvatar" />
                <img src="${userAvatar}" alt="Admin Avatar">
                <div>
                    <div style="font-size: 14px; font-weight: 600; color: #ffffff;"><c:out value="${sessionScope.account != null ? sessionScope.account.userName : 'admin'}" /></div>
                    <div class="user-role-text"><span class="online-dot"></span> Quản trị viên (Role: 1)</div>
                </div>
            </div>
            <ul class="sidebar-menu">
                <li><a href="${pageContext.request.contextPath}/admin/home">Tổng quan Dashboard</a></li>
                <li class="active"><a href="${pageContext.request.contextPath}/admin/videos">Quản lý Video</a></li>
                <li><a href="${pageContext.request.contextPath}/admin/category/list">Quản lý Danh mục</a></li>
                <li><a href="${pageContext.request.contextPath}/video">Kho Video người dùng</a></li>
                <li><a href="${pageContext.request.contextPath}/home">Trang chủ Web</a></li>
            </ul>
        </aside>

        <main class="content">
            <c:if test="${not empty param.msg}">
                <div class="alert-success">Thao tác dữ liệu video thành công!</div>
            </c:if>

            <div class="card">
                <div class="card-header">
                    <h2>Danh Sách Tất Cả Video (${totalVideos})</h2>
                    <a href="${pageContext.request.contextPath}/admin/video/add" class="btn-add">Thêm Video Mới</a>
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
                                    <a href="${pageContext.request.contextPath}/video/detail?id=${v.videoId}" target="_blank" style="font-weight: 600; color: #2563eb; text-decoration: none;">
                                        <c:out value="${v.title}" />
                                    </a>
                                    <div style="font-size: 12px; color: #64748b; margin-top: 2px;">ID: <c:out value="${v.videoId}" /></div>
                                </td>
                                <td><c:out value="${v.category != null ? v.category.categoryname : 'Chung'}" /></td>
                                <td><span class="badge" style="background:#eff6ff; color:#1d4ed8; border:1px solid #bfdbfe;"><c:out value="${v.sourceType}" /></span></td>
                                <td><c:out value="${v.user != null ? v.user.fullName : 'Admin'}" /></td>
                                <td><c:out value="${v.views}" /></td>
                                <td>
                                    <form method="post" action="${pageContext.request.contextPath}/admin/video/toggle-active" style="display:inline;">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.CSRF_TOKEN}">
                                        <input type="hidden" name="id" value="${v.videoId}">
                                        <input type="hidden" name="active" value="${v.active == 1 ? 0 : 1}">
                                        <button type="submit" class="btn-sm ${v.active == 1 ? 'badge-active' : 'badge-locked'}" title="Nhấn để đổi trạng thái">
                                            ${v.active == 1 ? 'Đã duyệt' : 'Chờ duyệt / Khóa'}
                                        </button>
                                    </form>
                                </td>
                                <td>
                                    <div style="display: flex; gap: 8px;">
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
        </main>
    </div>
</body>
</html>