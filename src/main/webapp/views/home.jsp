<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang Chủ - Video & Danh Mục</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Arial, sans-serif; }
        body { background-color: #f4f6f9; color: #333; }
        .topbar { background: #343a40; color: #fff; padding: 12px 30px; display: flex; justify-content: space-between; align-items: center; }
        .topbar .nav-links { display: flex; gap: 18px; align-items: center; }
        .topbar a { color: #f8f9fa; text-decoration: none; font-size: 14px; font-weight: 500; }
        .topbar a:hover { color: #007bff; }
        .container { max-width: 1140px; margin: 30px auto; padding: 0 15px; }
        .card { background: #fff; padding: 30px; border-radius: 8px; box-shadow: 0 4px 15px rgba(0,0,0,0.08); margin-bottom: 30px; }
        h1 { color: #2c3e50; font-size: 24px; margin-bottom: 15px; }
        h2 { color: #2c3e50; font-size: 20px; margin-bottom: 20px; display: flex; align-items: center; justify-content: space-between; }
        .user-card { background: #e9ecef; padding: 20px; border-radius: 6px; margin: 15px 0; display: flex; gap: 20px; align-items: center; }
        .avatar-img { width: 65px; height: 65px; border-radius: 50%; object-fit: cover; border: 2px solid #007bff; }
        .user-info h3 { margin-bottom: 6px; font-size: 17px; }
        .user-badge { display: inline-block; padding: 3px 8px; border-radius: 4px; font-size: 12px; font-weight: bold; }
        .badge-admin { background: #d1ecf1; color: #0c5460; }
        .badge-manager { background: #fff3cd; color: #856404; }
        .badge-user { background: #e2e3e5; color: #383d41; }
        .btn-group { margin-top: 20px; display: flex; gap: 12px; flex-wrap: wrap; }
        .btn { display: inline-block; padding: 8px 16px; text-decoration: none; border-radius: 4px; font-weight: bold; font-size: 13px; text-align: center; }
        .btn-primary { background: #007bff; color: #fff; }
        .btn-primary:hover { background: #0056b3; }
        .btn-success { background: #28a745; color: #fff; }
        .btn-success:hover { background: #218838; }
        .btn-info { background: #17a2b8; color: #fff; }
        .btn-info:hover { background: #117a8b; }
        .btn-danger { background: #dc3545; color: #fff; }
        .btn-danger:hover { background: #c82333; }
        .alert-danger { background-color: #f8d7da; color: #721c24; padding: 12px; border-radius: 4px; margin-bottom: 20px; }

        /* Video Grid Layout */
        .video-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 20px; }
        .video-card { background: #fff; border-radius: 8px; border: 1px solid #e0e0e0; overflow: hidden; display: flex; flex-direction: column; transition: transform 0.2s, box-shadow 0.2s; }
        .video-card:hover { transform: translateY(-3px); box-shadow: 0 6px 16px rgba(0,0,0,0.1); }
        .video-poster-box { position: relative; width: 100%; padding-top: 56.25%; background: #000; }
        .video-poster-box img { position: absolute; top: 0; left: 0; width: 100%; height: 100%; object-fit: cover; }
        .video-info { padding: 12px; display: flex; flex-direction: column; flex-grow: 1; }
        .video-title { font-size: 14px; font-weight: bold; color: #1a0dab; text-decoration: none; margin-bottom: 8px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; line-height: 1.3; }
        .video-title:hover { color: #d93025; text-decoration: underline; }
        .video-meta { font-size: 12px; color: #666; margin-top: auto; display: flex; justify-content: space-between; }
        .badge-source { font-size: 10px; padding: 2px 5px; border-radius: 3px; font-weight: bold; }
        .source-youtube { background: #fee2e2; color: #b91c1c; }
        .source-local { background: #e0e7ff; color: #3730a3; }
    </style>
</head>
<body>
    <div class="topbar">
        <div class="nav-links">
            <a href="${pageContext.request.contextPath}/home" style="font-size: 16px; font-weight: bold;">🎬 MyVideo Platform</a>
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <a href="${pageContext.request.contextPath}/video">Tất cả Video</a>
            <c:if test="${not empty sessionScope.account}">
                <a href="${pageContext.request.contextPath}/video?filter=my">Video của tôi</a>
                <a href="${pageContext.request.contextPath}/video/upload">➕ Đăng Video</a>
            </c:if>
        </div>
        <div>
            <c:choose>
                <c:when test="${sessionScope.account == null}">
                    <a href="${pageContext.request.contextPath}/login">Đăng nhập</a> |
                    <a href="${pageContext.request.contextPath}/register">Đăng ký</a>
                </c:when>
                <c:otherwise>
                    <span>Xin chào: <b><c:out value="${sessionScope.account.fullName}" /></b></span> |
                    <a href="${pageContext.request.contextPath}/logout">Đăng Xuất</a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

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
                            <p><b>Username:</b> <c:out value="${sessionScope.account.userName}" /> | <b>Email:</b> <c:out value="${sessionScope.account.email}" /></p>
                        </div>
                    </div>

                    <div class="btn-group">
                        <a href="${pageContext.request.contextPath}/video" class="btn btn-primary">🎬 Xem Danh mục Video (Phân trang)</a>
                        <a href="${pageContext.request.contextPath}/video?filter=my" class="btn btn-info">📁 Video của tôi</a>
                        <a href="${pageContext.request.contextPath}/video/upload" class="btn btn-success">➕ Tải lên Video mới</a>
                        <a href="${pageContext.request.contextPath}/admin/category/list" class="btn btn-primary">📂 Danh mục Sản phẩm</a>
                        <c:if test="${sessionScope.account.roleid == 1}">
                            <a href="${pageContext.request.contextPath}/admin/videos" class="btn btn-danger">⚙️ Quản lý Video Admin</a>
                            <a href="${pageContext.request.contextPath}/admin/home" class="btn btn-success">Trang Quản Trị Admin</a>
                        </c:if>
                    </div>
                </c:when>

                <c:otherwise>
                    <p style="margin: 15px 0;">Đăng nhập để đăng tải và quản lý bộ sưu tập video của bạn.</p>
                    <div class="btn-group">
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-primary">Đăng nhập</a>
                        <a href="${pageContext.request.contextPath}/register" class="btn btn-success">Đăng ký tài khoản</a>
                        <a href="${pageContext.request.contextPath}/video" class="btn btn-info">🎬 Xem kho Video</a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- 10 Video Mới Nhất -->
        <div class="card">
            <h2>
                <span>🔥 10 Video Mới Nhất Trên Hệ Thống</span>
                <a href="${pageContext.request.contextPath}/video" style="font-size: 13px; color: #007bff; text-decoration: none;">Xem tất cả &rarr;</a>
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
                                        <span>👁️ <c:out value="${v.views}" /> lượt xem</span>
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
                    <p style="color: #888; text-align: center; padding: 30px;">Chưa có video nào được công bố.</p>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</body>
</html>
