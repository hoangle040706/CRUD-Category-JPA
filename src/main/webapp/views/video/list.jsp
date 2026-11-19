<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${filter == 'my' ? 'Video của tôi' : 'Danh Sách Video'} - MyVideo Platform</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', system-ui, -apple-system, BlinkMacSystemFont, Roboto, sans-serif; }
        body { background-color: #f8fafc; color: #0f172a; line-height: 1.5; }

        /* Unified Topbar - Clean, No-wrap, Single-line */
        .topbar { background: linear-gradient(135deg, #1e3a8a 0%, #1d4ed8 50%, #2563eb 100%); color: #fff; box-shadow: 0 2px 10px rgba(30, 58, 138, 0.15); position: sticky; top: 0; z-index: 100; width: 100%; }
        .topbar-container { max-width: 100%; margin: 0 auto; padding: 0 24px; height: 60px; display: flex; justify-content: space-between; align-items: center; gap: 16px; overflow-x: auto; scrollbar-width: none; }
        .topbar-container::-webkit-scrollbar { display: none; }
        .nav-brand-group { display: flex; align-items: center; gap: 18px; flex-shrink: 0; white-space: nowrap; }
        .brand-logo { color: #ffffff; font-size: 18px; font-weight: 700; text-decoration: none; letter-spacing: -0.3px; white-space: nowrap; flex-shrink: 0; }
        .nav-subtitle { color: #bfdbfe; font-size: 13px; font-weight: 500; padding-left: 14px; border-left: 1px solid rgba(255, 255, 255, 0.25); white-space: nowrap; }
        .nav-menu { display: flex; gap: 4px; align-items: center; flex-wrap: nowrap; white-space: nowrap; }
        .nav-link { color: #e0e7ff; text-decoration: none; font-size: 13.5px; font-weight: 500; padding: 6px 11px; border-radius: 6px; white-space: nowrap; display: inline-flex; align-items: center; transition: all 0.15s ease; flex-shrink: 0; }
        .nav-link:hover { background: rgba(255, 255, 255, 0.14); color: #ffffff; }
        .nav-link.active { background: rgba(255, 255, 255, 0.22); color: #ffffff; font-weight: 600; }
        .nav-link-badge { border: 1px solid rgba(255, 255, 255, 0.35); background: rgba(255, 255, 255, 0.08); }
        .nav-user-group { display: flex; align-items: center; gap: 12px; flex-shrink: 0; white-space: nowrap; }
        .user-greeting { display: flex; align-items: center; gap: 8px; white-space: nowrap; flex-shrink: 0; }
        .user-name { color: #ffffff; font-weight: 600; font-size: 13.5px; white-space: nowrap; }
        .user-role-pill { background: rgba(255, 255, 255, 0.22); color: #ffffff; padding: 3px 9px; border-radius: 12px; font-size: 11px; font-weight: 600; white-space: nowrap; display: inline-block; }
        .btn-nav { color: #ffffff; text-decoration: none; padding: 6px 12px; font-weight: 600; font-size: 13.5px; border-radius: 6px; transition: all 0.15s; white-space: nowrap; display: inline-flex; align-items: center; flex-shrink: 0; }
        .btn-nav:hover { background: rgba(255, 255, 255, 0.14); }
        .btn-nav-primary { background: #ffffff; color: #1d4ed8; }
        .btn-nav-primary:hover { background: #eff6ff; color: #1e3a8a; }
        .btn-logout { background: #ef4444; color: #ffffff; padding: 6px 14px; border-radius: 6px; font-size: 13px; font-weight: 600; text-decoration: none; transition: background 0.15s; white-space: nowrap; display: inline-flex; align-items: center; flex-shrink: 0; }
        .btn-logout:hover { background: #dc2626; }

        /* Container */
        .container { max-width: 1200px; margin: 30px auto; padding: 0 20px; }
        .header-box { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; flex-wrap: wrap; gap: 16px; }
        h1 { color: #1e3a8a; font-size: 22px; font-weight: 700; letter-spacing: -0.3px; }
        .btn-upload { background: #2563eb; color: #fff; padding: 9px 18px; border-radius: 6px; text-decoration: none; font-weight: 600; font-size: 14px; transition: background 0.15s; }
        .btn-upload:hover { background: #1d4ed8; }

        /* Tabs */
        .tabs { display: flex; gap: 8px; margin-bottom: 25px; border-bottom: 2px solid #e2e8f0; }
        .tab-item { padding: 10px 18px; text-decoration: none; font-weight: 600; font-size: 14px; color: #64748b; border-bottom: 3px solid transparent; margin-bottom: -2px; transition: all 0.15s; }
        .tab-item:hover { color: #2563eb; }
        .tab-item.active { color: #2563eb; border-bottom-color: #2563eb; }

        /* Video Grid (6 videos / page) */
        .video-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; margin-bottom: 35px; }
        @media (max-width: 900px) { .video-grid { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 560px) { .video-grid { grid-template-columns: 1fr; } }

        .video-card { background: #fff; border-radius: 10px; border: 1px solid #e2e8f0; overflow: hidden; display: flex; flex-direction: column; box-shadow: 0 2px 4px rgba(0,0,0,0.04); transition: transform 0.18s, box-shadow 0.18s; }
        .video-card:hover { transform: translateY(-3px); box-shadow: 0 10px 18px -3px rgba(37, 99, 235, 0.12); border-color: #bfdbfe; }
        .video-poster { position: relative; width: 100%; padding-top: 56.25%; background: #0f172a; }
        .video-poster img { position: absolute; top: 0; left: 0; width: 100%; height: 100%; object-fit: cover; }
        .video-body { padding: 16px; display: flex; flex-direction: column; flex-grow: 1; }
        .video-title { font-size: 15px; font-weight: 600; color: #0f172a; text-decoration: none; margin-bottom: 8px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; line-height: 1.4; }
        .video-title:hover { color: #2563eb; }
        .video-desc { font-size: 13px; color: #64748b; margin-bottom: 12px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; line-height: 1.45; }
        .video-footer { margin-top: auto; display: flex; justify-content: space-between; align-items: center; font-size: 12px; color: #64748b; border-top: 1px solid #f1f5f9; padding-top: 10px; }
        
        .badge { display: inline-block; padding: 3px 8px; border-radius: 4px; font-size: 11px; font-weight: 600; }
        .badge-success { background: #ecfdf5; color: #047857; border: 1px solid #a7f3d0; }
        .badge-warning { background: #fffbeb; color: #b45309; border: 1px solid #fde68a; }
        .badge-source { background: #eff6ff; color: #1d4ed8; border: 1px solid #bfdbfe; }
        
        .actions { margin-top: 12px; display: flex; gap: 8px; padding-top: 10px; border-top: 1px dashed #e2e8f0; }
        .btn-sm { padding: 6px 12px; font-size: 12px; border-radius: 4px; text-decoration: none; font-weight: 600; cursor: pointer; border: none; }
        .btn-edit { background: #f59e0b; color: #fff; }
        .btn-edit:hover { background: #d97706; }
        .btn-del { background: #ef4444; color: #fff; }
        .btn-del:hover { background: #dc2626; }

        /* Pagination */
        .pagination { display: flex; justify-content: center; gap: 6px; margin: 30px 0; }
        .page-link { display: inline-block; padding: 8px 14px; background: #fff; border: 1px solid #cbd5e1; color: #2563eb; text-decoration: none; border-radius: 6px; font-weight: 600; font-size: 13px; transition: all 0.15s; }
        .page-link:hover { background: #eff6ff; border-color: #93c5fd; }
        .page-link.active { background: #2563eb; color: #fff; border-color: #2563eb; }
        .alert-success { background: #ecfdf5; color: #047857; padding: 12px 16px; border-radius: 8px; margin-bottom: 20px; border: 1px solid #a7f3d0; font-size: 14px; }
        .empty-box { background: #fff; padding: 50px 20px; text-align: center; border-radius: 12px; border: 1px solid #e2e8f0; color: #64748b; }
    </style>
</head>
<body>
<div class="container">
        <c:if test="${not empty param.msg}">
            <div class="alert-success">Thao tác thành công!</div>
        </c:if>

        <div class="header-box">
            <h1>${filter == 'my' ? 'Video của tôi' : 'Tất cả Video'} (Tổng cộng: ${totalVideos})</h1>
            <c:if test="${not empty sessionScope.account}">
                <a href="${pageContext.request.contextPath}/video/upload" class="btn-upload">Đăng Video Mới</a>
            </c:if>
        </div>

        <div class="tabs">
            <a href="${pageContext.request.contextPath}/video" class="tab-item ${filter != 'my' ? 'active' : ''}">Tất cả Video công khai</a>
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
                                    <span><c:out value="${v.views}" /> lượt xem</span>
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
                            <a href="${pageContext.request.contextPath}/video?page=${currentPage - 1}&filter=${filter}" class="page-link">Trước</a>
                        </c:if>
                        <c:forEach begin="1" end="${totalPages}" var="p">
                            <a href="${pageContext.request.contextPath}/video?page=${p}&filter=${filter}" class="page-link ${p == currentPage ? 'active' : ''}">${p}</a>
                        </c:forEach>
                        <c:if test="${currentPage < totalPages}">
                            <a href="${pageContext.request.contextPath}/video?page=${currentPage + 1}&filter=${filter}" class="page-link">Sau</a>
                        </c:if>
                    </div>
                </c:if>
            </c:when>
            <c:otherwise>
                <div class="empty-box">
                    <p style="font-size: 15px; margin-bottom: 16px;">Chưa có video nào hiển thị ở mục này.</p>
                    <c:if test="${not empty sessionScope.account}">
                        <a href="${pageContext.request.contextPath}/video/upload" class="btn-upload">Tải lên video đầu tiên</a>
                    </c:if>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</body>
</html>