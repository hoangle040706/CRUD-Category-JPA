<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${filter == 'my' ? 'Video của tôi' : 'Danh Sách Video'} - MyVideo Platform</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Arial, sans-serif; }
        body { background-color: #f4f6f9; color: #333; }
        .topbar { background: #343a40; color: #fff; padding: 12px 30px; display: flex; justify-content: space-between; align-items: center; }
        .topbar .nav-links { display: flex; gap: 18px; align-items: center; }
        .topbar a { color: #f8f9fa; text-decoration: none; font-size: 14px; font-weight: 500; }
        .topbar a:hover { color: #007bff; }
        .container { max-width: 1140px; margin: 30px auto; padding: 0 15px; }
        .header-box { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; flex-wrap: wrap; gap: 15px; }
        h1 { color: #2c3e50; font-size: 24px; }
        .tabs { display: flex; gap: 10px; margin-bottom: 25px; border-bottom: 2px solid #e0e0e0; }
        .tab-item { padding: 10px 20px; text-decoration: none; font-weight: 600; font-size: 14px; color: #666; border-bottom: 3px solid transparent; margin-bottom: -2px; }
        .tab-item.active { color: #007bff; border-bottom-color: #007bff; }
        .btn-upload { background: #28a745; color: #fff; padding: 8px 16px; border-radius: 4px; text-decoration: none; font-weight: bold; font-size: 14px; }
        .btn-upload:hover { background: #218838; }

        /* Video Grid (6 videos / page) */
        .video-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; margin-bottom: 30px; }
        @media (max-width: 900px) { .video-grid { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 560px) { .video-grid { grid-template-columns: 1fr; } }

        .video-card { background: #fff; border-radius: 8px; border: 1px solid #e0e0e0; overflow: hidden; display: flex; flex-direction: column; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
        .video-poster { position: relative; width: 100%; padding-top: 56.25%; background: #000; }
        .video-poster img { position: absolute; top: 0; left: 0; width: 100%; height: 100%; object-fit: cover; }
        .video-body { padding: 15px; display: flex; flex-direction: column; flex-grow: 1; }
        .video-title { font-size: 15px; font-weight: bold; color: #1a0dab; text-decoration: none; margin-bottom: 8px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; line-height: 1.35; }
        .video-title:hover { color: #d93025; text-decoration: underline; }
        .video-desc { font-size: 12px; color: #666; margin-bottom: 12px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
        .video-footer { margin-top: auto; display: flex; justify-content: space-between; align-items: center; font-size: 12px; color: #888; border-top: 1px solid #f0f0f0; padding-top: 10px; }
        .badge { display: inline-block; padding: 2px 6px; border-radius: 4px; font-size: 11px; font-weight: bold; }
        .badge-success { background: #d4edda; color: #155724; }
        .badge-warning { background: #fff3cd; color: #856404; }
        .badge-source { background: #e2e3e5; color: #383d41; }
        .actions { margin-top: 10px; display: flex; gap: 8px; }
        .btn-sm { padding: 4px 10px; font-size: 12px; border-radius: 3px; text-decoration: none; font-weight: bold; cursor: pointer; border: none; }
        .btn-edit { background: #ffc107; color: #212529; }
        .btn-del { background: #dc3545; color: #fff; }

        /* Pagination */
        .pagination { display: flex; justify-content: center; gap: 6px; margin: 30px 0; }
        .page-link { display: inline-block; padding: 8px 14px; background: #fff; border: 1px solid #dee2e6; color: #007bff; text-decoration: none; border-radius: 4px; font-weight: 500; }
        .page-link:hover { background: #e9ecef; }
        .page-link.active { background: #007bff; color: #fff; border-color: #007bff; }
        .page-link.disabled { color: #6c757d; pointer-events: none; background: #f8f9fa; }
        .alert-success { background: #d4edda; color: #155724; padding: 12px; border-radius: 4px; margin-bottom: 20px; }
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
        <c:if test="${not empty param.msg}">
            <div class="alert-success">Thao tác thành công!</div>
        </c:if>

        <div class="header-box">
            <h1>${filter == 'my' ? '📁 Video Của Tôi' : '🎬 Danh Sách Tất Cả Video'} (Tổng cộng: ${totalVideos})</h1>
            <c:if test="${not empty sessionScope.account}">
                <a href="${pageContext.request.contextPath}/video/upload" class="btn-upload">➕ Đăng Video Mới</a>
            </c:if>
        </div>

        <div class="tabs">
            <a href="${pageContext.request.contextPath}/video" class="tab-item ${filter != 'my' ? 'active' : ''}">Tất cả Video Công Khai</a>
            <c:if test="${not empty sessionScope.account}">
                <a href="${pageContext.request.contextPath}/video?filter=my" class="tab-item ${filter == 'my' ? 'active' : ''}">Video của tôi</a>
            </c:if>
        </div>

        <c:choose>
            <c:when test="${not empty videos}">
                <div class="video-grid">
                    <c:forEach items="${videos}" var="v">
                        <div class="video-card">
                            <div class="video-poster">
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
                            <div class="video-body">
                                <a href="${pageContext.request.contextPath}/video/detail?id=${v.videoId}" class="video-title" title="<c:out value="${v.title}" />">
                                    <c:out value="${v.title}" />
                                </a>
                                <p class="video-desc"><c:out value="${v.description}" /></p>

                                <c:if test="${filter == 'my'}">
                                    <div style="margin-bottom: 8px;">
                                        <span class="badge ${v.active == 1 ? 'badge-success' : 'badge-warning'}">
                                            ${v.active == 1 ? 'Đã duyệt' : 'Chờ duyệt'}
                                        </span>
                                    </div>
                                </c:if>

                                <div class="video-footer">
                                    <span>👁️ <c:out value="${v.views}" /> lượt xem</span>
                                    <span class="badge badge-source"><c:out value="${v.sourceType}" /></span>
                                </div>

                                <c:if test="${filter == 'my'}">
                                    <div class="actions">
                                        <a href="${pageContext.request.contextPath}/video/edit?id=${v.videoId}" class="btn-sm btn-edit">Sửa</a>
                                        <form method="post" action="${pageContext.request.contextPath}/video/delete" onsubmit="return confirm('Bạn có chắc chắn muốn xóa video này?');" style="display:inline;">
                                            <input type="hidden" name="csrfToken" value="${sessionScope.CSRF_TOKEN}">
                                            <input type="hidden" name="id" value="${v.videoId}">
                                            <button type="submit" class="btn-sm btn-del">Xóa</button>
                                        </form>
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <!-- Phân trang (6 video / trang) -->
                <c:if test="${totalPages > 1}">
                    <div class="pagination">
                        <c:if test="${currentPage > 1}">
                            <a href="${pageContext.request.contextPath}/video?page=${currentPage - 1}&filter=${filter}" class="page-link">&laquo; Trước</a>
                        </c:if>
                        <c:forEach begin="1" end="${totalPages}" var="p">
                            <a href="${pageContext.request.contextPath}/video?page=${p}&filter=${filter}" class="page-link ${p == currentPage ? 'active' : ''}">${p}</a>
                        </c:forEach>
                        <c:if test="${currentPage < totalPages}">
                            <a href="${pageContext.request.contextPath}/video?page=${currentPage + 1}&filter=${filter}" class="page-link">Sau &raquo;</a>
                        </c:if>
                    </div>
                </c:if>
            </c:when>
            <c:otherwise>
                <div style="background: #fff; padding: 40px; text-align: center; border-radius: 8px; color: #777;">
                    <p style="font-size: 16px; margin-bottom: 15px;">Chưa có video nào hiển thị ở mục này.</p>
                    <c:if test="${not empty sessionScope.account}">
                        <a href="${pageContext.request.contextPath}/video/upload" class="btn-upload">Tải lên video đầu tiên</a>
                    </c:if>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</body>
</html>
