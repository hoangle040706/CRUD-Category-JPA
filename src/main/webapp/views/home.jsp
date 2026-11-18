<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang Chủ - MyVideo Platform</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', system-ui, -apple-system, BlinkMacSystemFont, Roboto, sans-serif; }
        body { background-color: #f8fafc; color: #0f172a; line-height: 1.5; }

        /* Unified Topbar */
        .topbar { background: linear-gradient(135deg, #1e3a8a 0%, #1d4ed8 50%, #2563eb 100%); color: #fff; box-shadow: 0 2px 10px rgba(30, 58, 138, 0.15); position: sticky; top: 0; z-index: 100; }
        .topbar-container { max-width: 1200px; margin: 0 auto; padding: 0 20px; height: 60px; display: flex; justify-content: space-between; align-items: center; }
        .nav-brand-group { display: flex; align-items: center; gap: 28px; }
        .brand-logo { color: #ffffff; font-size: 18px; font-weight: 700; text-decoration: none; letter-spacing: -0.3px; }
        .nav-menu { display: flex; gap: 6px; align-items: center; }
        .nav-link { color: #e0e7ff; text-decoration: none; font-size: 14px; font-weight: 500; padding: 7px 12px; border-radius: 6px; transition: all 0.15s ease; }
        .nav-link:hover { background: rgba(255, 255, 255, 0.14); color: #ffffff; }
        .nav-link.active { background: rgba(255, 255, 255, 0.22); color: #ffffff; font-weight: 600; }
        .nav-link-badge { border: 1px solid rgba(255, 255, 255, 0.3); }

        .nav-user-group { display: flex; align-items: center; gap: 14px; }
        .user-greeting { display: flex; align-items: center; gap: 8px; }
        .user-name { color: #ffffff; font-weight: 600; font-size: 14px; }
        .user-role-pill { background: rgba(255, 255, 255, 0.2); color: #ffffff; padding: 2px 8px; border-radius: 12px; font-size: 11px; font-weight: 600; }
        .btn-nav { color: #ffffff; text-decoration: none; padding: 6px 12px; font-weight: 600; font-size: 14px; border-radius: 6px; transition: all 0.15s; }
        .btn-nav:hover { background: rgba(255, 255, 255, 0.14); }
        .btn-nav-primary { background: #ffffff; color: #1d4ed8; }
        .btn-nav-primary:hover { background: #eff6ff; color: #1e3a8a; }
        .btn-logout { background: rgba(239, 68, 68, 0.9); color: #ffffff; padding: 6px 14px; border-radius: 6px; font-size: 13px; font-weight: 600; text-decoration: none; transition: background 0.15s; }
        .btn-logout:hover { background: #dc2626; }

        /* Container & Cards */
        .container { max-width: 1200px; margin: 30px auto; padding: 0 20px; }
        .card { background: #ffffff; padding: 28px; border-radius: 12px; border: 1px solid #e2e8f0; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05), 0 2px 4px -2px rgba(0,0,0,0.05); margin-bottom: 30px; }
        h1 { color: #1e3a8a; font-size: 22px; font-weight: 700; margin-bottom: 12px; letter-spacing: -0.3px; }
        h2 { color: #1e3a8a; font-size: 18px; font-weight: 700; margin-bottom: 20px; display: flex; align-items: center; justify-content: space-between; border-bottom: 2px solid #eff6ff; padding-bottom: 12px; }
        .card-desc { color: #475569; font-size: 14px; margin-bottom: 20px; }

        /* User Info Box */
        .user-card { background: #f8fafc; border: 1px solid #e2e8f0; padding: 20px; border-radius: 10px; margin: 18px 0; display: flex; gap: 20px; align-items: center; }
        .avatar-img { width: 68px; height: 68px; border-radius: 50%; object-fit: cover; border: 3px solid #bfdbfe; }
        .user-info h3 { margin-bottom: 6px; font-size: 16px; color: #0f172a; font-weight: 700; }
        .user-badge { display: inline-block; padding: 3px 10px; border-radius: 12px; font-size: 12px; font-weight: 600; margin-left: 6px; }
        .badge-admin { background: #eff6ff; color: #1d4ed8; border: 1px solid #bfdbfe; }
        .badge-manager { background: #fef3c7; color: #92400e; border: 1px solid #fde68a; }
        .badge-user { background: #f1f5f9; color: #334155; border: 1px solid #cbd5e1; }
        .user-meta { font-size: 13px; color: #64748b; }

        /* Buttons */
        .btn-group { margin-top: 20px; display: flex; gap: 10px; flex-wrap: wrap; }
        .btn { display: inline-flex; align-items: center; padding: 9px 18px; text-decoration: none; border-radius: 6px; font-weight: 600; font-size: 13px; border: none; cursor: pointer; transition: all 0.15s ease; }
        .btn-primary { background: #2563eb; color: #fff; }
        .btn-primary:hover { background: #1d4ed8; }
        .btn-outline-primary { background: #eff6ff; color: #1d4ed8; border: 1px solid #bfdbfe; }
        .btn-outline-primary:hover { background: #dbeafe; color: #1e3a8a; }
        .btn-secondary { background: #64748b; color: #fff; }
        .btn-secondary:hover { background: #475569; }
        .btn-danger { background: #ef4444; color: #fff; }
        .btn-danger:hover { background: #dc2626; }
        .alert-danger { background-color: #fef2f2; color: #991b1b; padding: 12px 16px; border-radius: 8px; margin-bottom: 20px; border: 1px solid #fecaca; font-size: 14px; }

        /* Video Grid Layout */
        .video-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(210px, 1fr)); gap: 22px; }
        .video-card { background: #fff; border-radius: 10px; border: 1px solid #e2e8f0; overflow: hidden; display: flex; flex-direction: column; transition: transform 0.18s, box-shadow 0.18s; }
        .video-card:hover { transform: translateY(-3px); box-shadow: 0 10px 18px -3px rgba(37, 99, 235, 0.12); border-color: #bfdbfe; }
        .video-poster-box { position: relative; width: 100%; padding-top: 56.25%; background: #0f172a; }
        .video-poster-box img { position: absolute; top: 0; left: 0; width: 100%; height: 100%; object-fit: cover; }
        .video-info { padding: 14px; display: flex; flex-direction: column; flex-grow: 1; }
        .video-title { font-size: 14px; font-weight: 600; color: #0f172a; text-decoration: none; margin-bottom: 8px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; line-height: 1.4; }
        .video-title:hover { color: #2563eb; }
        .video-meta { font-size: 12px; color: #64748b; margin-top: auto; display: flex; justify-content: space-between; align-items: center; padding-top: 8px; }
        .badge-source { font-size: 11px; padding: 2px 7px; border-radius: 4px; font-weight: 600; }
        .source-youtube { background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; }
        .source-local { background: #eff6ff; color: #1d4ed8; border: 1px solid #bfdbfe; }
        .view-all-link { font-size: 13px; color: #2563eb; text-decoration: none; font-weight: 600; }
        .view-all-link:hover { color: #1d4ed8; text-decoration: underline; }
    </style>
</head>
<body>
    <header class="topbar">
        <div class="topbar-container">
            <div class="nav-brand-group">
                <a href="${pageContext.request.contextPath}/home" class="brand-logo">MyVideo Platform</a>
                <nav class="nav-menu">
                    <a href="${pageContext.request.contextPath}/home" class="nav-link active">Trang chủ</a>
                    <a href="${pageContext.request.contextPath}/video" class="nav-link">Tất cả Video</a>
                    <a href="${pageContext.request.contextPath}/admin/category/list" class="nav-link">Danh mục</a>
                    <c:if test="${not empty sessionScope.account}">
                        <a href="${pageContext.request.contextPath}/video?filter=my" class="nav-link">Video của tôi</a>
                        <a href="${pageContext.request.contextPath}/video/upload" class="nav-link">Đăng Video</a>
                    </c:if>
                    <c:if test="${sessionScope.account.roleid == 1}">
                        <a href="${pageContext.request.contextPath}/admin/home" class="nav-link nav-link-badge">Quản trị Admin</a>
                        <a href="${pageContext.request.contextPath}/admin/videos" class="nav-link nav-link-badge">Duyệt Video</a>
                    </c:if>
                    <c:if test="${sessionScope.account.roleid == 2}">
                        <a href="${pageContext.request.contextPath}/manager/home" class="nav-link nav-link-badge">Bảng điều khiển Manager</a>
                    </c:if>
                </nav>
            </div>
            <div class="nav-user-group">
                <c:choose>
                    <c:when test="${sessionScope.account == null}">
                        <a href="${pageContext.request.contextPath}/login" class="btn-nav">Đăng nhập</a>
                        <a href="${pageContext.request.contextPath}/register" class="btn-nav btn-nav-primary">Đăng ký</a>
                    </c:when>
                    <c:otherwise>
                        <div class="user-greeting">
                            <span class="user-name"><c:out value="${sessionScope.account.fullName}" /></span>
                            <span class="user-role-pill">
                                <c:choose>
                                    <c:when test="${sessionScope.account.roleid == 1}">Admin</c:when>
                                    <c:when test="${sessionScope.account.roleid == 2}">Manager</c:when>
                                    <c:otherwise>Thành viên</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Đăng xuất</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </header>

    <div class="container">
        <c:if test="${not empty sessionScope.permissionError}">
            <div class="alert-danger"><c:out value="${sessionScope.permissionError}"/></div>
            <c:remove var="permissionError" scope="session"/>
        </c:if>

        <div class="card">
            <h1>Hệ Thống Quản Lý Video & Danh Mục</h1>
            <c:choose>
                <c:when test="${not empty sessionScope.account}">
                    <div class="user-card">
                        <c:url value="/image?fname=${not empty sessionScope.account.avatar ? sessionScope.account.avatar : 'default.png'}" var="avatarUrl" />
                        <img class="avatar-img" src="${avatarUrl}" alt="Avatar">
                        <div class="user-info">
                            <h3>
                                <c:out value="${sessionScope.account.fullName}" />
                                <span class="user-badge ${sessionScope.account.roleid == 1 ? 'badge-admin' : (sessionScope.account.roleid == 2 ? 'badge-manager' : 'badge-user')}">
                                    <c:out value="${sessionScope.account.roleName}" /> (Role ID: <c:out value="${sessionScope.account.roleid}" />)
                                </span>
                            </h3>
                            <div class="user-meta">
                                <span>Tài khoản: <b><c:out value="${sessionScope.account.userName}" /></b></span>
                                <span style="color: #cbd5e1; margin: 0 8px;">|</span>
                                <span>Email: <b><c:out value="${sessionScope.account.email}" /></b></span>
                            </div>
                        </div>
                    </div>

                    <div class="btn-group">
                        <a href="${pageContext.request.contextPath}/video" class="btn btn-primary">Xem kho video</a>
                        <a href="${pageContext.request.contextPath}/video?filter=my" class="btn btn-outline-primary">Video của tôi</a>
                        <a href="${pageContext.request.contextPath}/video/upload" class="btn btn-primary">Tải lên video mới</a>
                        <a href="${pageContext.request.contextPath}/admin/category/list" class="btn btn-outline-primary">Danh mục sản phẩm</a>
                        <c:if test="${sessionScope.account.roleid == 1}">
                            <a href="${pageContext.request.contextPath}/admin/videos" class="btn btn-secondary">Quản lý video Admin</a>
                            <a href="${pageContext.request.contextPath}/admin/home" class="btn btn-outline-primary">Trang quản trị Admin</a>
                        </c:if>
                        <c:if test="${sessionScope.account.roleid == 2}">
                            <a href="${pageContext.request.contextPath}/manager/home" class="btn btn-outline-primary">Bảng điều khiển Manager</a>
                        </c:if>
                    </div>
                </c:when>

                <c:otherwise>
                    <p class="card-desc">Nền tảng chia sẻ và lưu trữ video trực tuyến. Đăng nhập để tải lên, quản lý kho video và theo dõi các sản phẩm nổi bật.</p>
                    <div class="btn-group">
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-primary">Đăng nhập</a>
                        <a href="${pageContext.request.contextPath}/register" class="btn btn-outline-primary">Đăng ký tài khoản</a>
                        <a href="${pageContext.request.contextPath}/video" class="btn btn-secondary">Xem kho video</a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- 10 Video Mới Nhất -->
        <div class="card">
            <h2>
                <span>10 Video mới nhất trên hệ thống</span>
                <a href="${pageContext.request.contextPath}/video" class="view-all-link">Xem tất cả</a>
            </h2>

            <c:choose>
                <c:when test="${not empty top10Videos}">
                    <div class="video-grid">
                        <c:forEach items="${top10Videos}" var="v">
                            <div class="video-card">
                                <div class="video-poster-box">
                                    <c:choose>
                                        <c:when test="${not empty v.poster && v.poster.startsWith('http')}">
                                            <img src="${v.poster}" alt="Poster">
                                        </c:when>
                                        <c:when test="${not empty v.poster}">
                                            <img src="${pageContext.request.contextPath}/image?type=poster&fname=${v.poster}" alt="Poster">
                                        </c:when>
                                        <c:otherwise>
                                            <img src="${pageContext.request.contextPath}/image?fname=default.png" alt="Poster">
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="video-info">
                                    <a href="${pageContext.request.contextPath}/video/detail?id=${v.videoId}" class="video-title" title="<c:out value="${v.title}" />">
                                        <c:out value="${v.title}" />
                                    </a>
                                    <div class="video-meta">
                                        <span><c:out value="${v.views}" /> lượt xem</span>
                                        <span class="badge-source ${v.sourceType == 'YOUTUBE' ? 'source-youtube' : 'source-local'}">
                                            <c:out value="${v.sourceType}" />
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <p style="color: #64748b; text-align: center; padding: 40px;">Chưa có video nào được công bố.</p>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</body>
</html>