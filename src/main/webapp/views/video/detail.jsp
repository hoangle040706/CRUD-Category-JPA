<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${video.title}" /> - MyVideo Platform</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Arial, sans-serif; }
        body { background-color: #f4f6f9; color: #333; }
        .topbar { background: #343a40; color: #fff; padding: 12px 30px; display: flex; justify-content: space-between; align-items: center; }
        .topbar .nav-links { display: flex; gap: 18px; align-items: center; }
        .topbar a { color: #f8f9fa; text-decoration: none; font-size: 14px; font-weight: 500; }
        .topbar a:hover { color: #007bff; }
        .container { max-width: 1200px; margin: 30px auto; padding: 0 15px; display: grid; grid-template-columns: 2.2fr 1fr; gap: 30px; }
        @media (max-width: 900px) { .container { grid-template-columns: 1fr; } }
        .main-col { background: #fff; padding: 25px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.06); }
        .side-col { background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.06); height: fit-content; }
        
        .player-wrapper { width: 100%; border-radius: 8px; overflow: hidden; background: #000; margin-bottom: 20px; }
        video { width: 100%; max-height: 540px; display: block; outline: none; }
        .iframe-container { position: relative; width: 100%; padding-top: 56.25%; }
        .iframe-container iframe { position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: none; }

        h1.video-title { font-size: 22px; color: #1a202c; margin-bottom: 12px; line-height: 1.4; }
        .meta-bar { display: flex; justify-content: space-between; align-items: center; padding-bottom: 15px; border-bottom: 1px solid #edf2f7; font-size: 13px; color: #718096; flex-wrap: wrap; gap: 10px; }
        .uploader-box { display: flex; align-items: center; gap: 12px; margin: 18px 0; padding: 12px; background: #f8fafc; border-radius: 6px; }
        .uploader-avatar { width: 45px; height: 45px; border-radius: 50%; object-fit: cover; border: 1px solid #cbd5e1; }
        .uploader-name { font-weight: bold; font-size: 14px; color: #334155; }
        .desc-box { font-size: 14px; line-height: 1.6; color: #475569; white-space: pre-wrap; padding: 15px 0; }

        .side-title { font-size: 16px; font-weight: bold; margin-bottom: 15px; color: #1e293b; border-bottom: 2px solid #007bff; padding-bottom: 8px; }
        .related-item { display: flex; gap: 12px; margin-bottom: 15px; text-decoration: none; color: inherit; }
        .related-item:hover .related-title { color: #007bff; }
        .related-thumb { width: 110px; height: 65px; border-radius: 4px; overflow: hidden; background: #000; flex-shrink: 0; }
        .related-thumb img { width: 100%; height: 100%; object-fit: cover; }
        .related-info { display: flex; flex-direction: column; justify-content: space-between; }
        .related-title { font-size: 13px; font-weight: 600; line-height: 1.3; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
        .related-views { font-size: 11px; color: #94a3b8; }
        .badge { display: inline-block; padding: 3px 8px; border-radius: 4px; font-size: 11px; font-weight: bold; }
        .badge-pending { background: #fef3c7; color: #92400e; }
    </style>
</head>
<body>
    <div class="topbar">
        <div class="nav-links">
            <a href="${pageContext.request.contextPath}/home" style="font-size: 16px; font-weight: bold;">🎬 MyVideo Platform</a>
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <a href="${pageContext.request.contextPath}/video">Tất cả Video</a>
            <a href="${pageContext.request.contextPath}/admin/category/list">📁 Danh mục Sản phẩm</a>
            <c:if test="${not empty sessionScope.account}">
                <a href="${pageContext.request.contextPath}/video?filter=my">Video của tôi</a>
                <a href="${pageContext.request.contextPath}/video/upload">➕ Đăng Video</a>
            </c:if>
            <c:if test="${sessionScope.account.roleid == 1}">
                <a href="${pageContext.request.contextPath}/admin/home" style="color: #ffc107; font-weight: bold;">⚙️ Quản Trị Admin</a>
                <a href="${pageContext.request.contextPath}/admin/videos" style="color: #28a745; font-weight: bold;">🎬 Duyệt Video Admin</a>
            </c:if>
            <c:if test="${sessionScope.account.roleid == 2}">
                <a href="${pageContext.request.contextPath}/manager/home" style="color: #fd7e14; font-weight: bold;">📊 Dashboard Manager</a>
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
        <!-- Cột Xem Video Chính -->
        <div class="main-col">
            <div class="player-wrapper">
                <c:choose>
                    <c:when test="${video.sourceType == 'LOCAL'}">
                        <video controls autoplay preload="metadata">
                            <source src="${pageContext.request.contextPath}/video/stream?id=${video.videoId}" type="video/mp4">
                            Trình duyệt của bạn không hỗ trợ phát thẻ video HTML5.
                        </video>
                    </c:when>
                    <c:otherwise>
                        <div class="iframe-container">
                            <iframe src="${video.videoPath}" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <h1 class="video-title"><c:out value="${video.title}" /></h1>

            <div class="meta-bar">
                <div>
                    <span>👁️ <b><c:out value="${video.views}" /></b> lượt xem</span> &bull;
                    <span>Danh mục: <b><c:out value="${video.category != null ? video.category.categoryname : 'Chung'}" /></b></span>
                    <c:if test="${video.active != 1}">
                        <span class="badge badge-pending">⚠️ Video đang chờ Admin duyệt</span>
                    </c:if>
                </div>
                <div>
                    <span>Nguồn: <b><c:out value="${video.sourceType}" /></b></span>
                </div>
            </div>

            <div class="uploader-box">
                <img class="uploader-avatar" src="${pageContext.request.contextPath}/image?fname=${video.user != null && not empty video.user.avatar ? video.user.avatar : 'default.png'}" alt="Avatar">
                <div>
                    <div class="uploader-name"><c:out value="${video.user != null ? video.user.fullName : 'Quản trị viên'}" /></div>
                    <div style="font-size: 12px; color: #64748b;">Người đăng tải</div>
                </div>
            </div>

            <div class="desc-box">
                <p><b>Mô tả nội dung:</b></p>
                <c:out value="${not empty video.description ? video.description : 'Không có mô tả chi tiết cho video này.'}" />
            </div>
        </div>

        <!-- Cột Video Gợi Ý / Mới Nhất -->
        <div class="side-col">
            <div class="side-title">🔥 Video Đề Xuất</div>
            <c:forEach items="${relatedVideos}" var="rv">
                <c:if test="${rv.videoId != video.videoId}">
                    <a href="${pageContext.request.contextPath}/video/detail?id=${rv.videoId}" class="related-item">
                        <div class="related-thumb">
                            <c:choose>
                                <c:when test="${not empty rv.poster && rv.poster.startsWith('http')}">
                                    <img src="${rv.poster}" alt="Thumb">
                                </c:when>
                                <c:when test="${not empty rv.poster}">
                                    <img src="${pageContext.request.contextPath}/image?type=poster&fname=${rv.poster}" alt="Thumb">
                                </c:when>
                                <c:otherwise>
                                    <img src="${pageContext.request.contextPath}/image?fname=default.png" alt="Thumb">
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="related-info">
                            <div class="related-title" title="<c:out value="${rv.title}" />"><c:out value="${rv.title}" /></div>
                            <div class="related-views">👁️ <c:out value="${rv.views}" /> lượt xem</div>
                        </div>
                    </a>
                </c:if>
            </c:forEach>
        </div>
    </div>
</body>
</html>
