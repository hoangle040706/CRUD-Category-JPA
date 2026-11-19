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
        .container { max-width: 1200px; margin: 30px auto; padding: 0 20px; display: grid; grid-template-columns: 2.2fr 1fr; gap: 28px; }
        @media (max-width: 900px) { .container { grid-template-columns: 1fr; } }
        
        .main-col { background: #fff; padding: 25px; border-radius: 12px; border: 1px solid #e2e8f0; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); }
        .side-col { background: #fff; padding: 22px; border-radius: 12px; border: 1px solid #e2e8f0; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); height: fit-content; }
        
        .player-wrapper { width: 100%; border-radius: 8px; overflow: hidden; background: #000; margin-bottom: 20px; }
        video { width: 100%; max-height: 520px; display: block; outline: none; }
        .iframe-container { position: relative; width: 100%; padding-top: 56.25%; }
        .iframe-container iframe { position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: none; }

        h1.video-title { font-size: 20px; color: #0f172a; margin-bottom: 12px; line-height: 1.4; font-weight: 700; }
        .meta-bar { display: flex; justify-content: space-between; align-items: center; padding-bottom: 15px; border-bottom: 1px solid #e2e8f0; font-size: 13px; color: #64748b; flex-wrap: wrap; gap: 10px; }
        .uploader-box { display: flex; align-items: center; gap: 14px; margin: 18px 0; padding: 14px; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; }
        .uploader-avatar { width: 48px; height: 48px; border-radius: 50%; object-fit: cover; border: 2px solid #bfdbfe; }
        .uploader-name { font-weight: 700; font-size: 14px; color: #0f172a; }
        .desc-box { font-size: 14px; line-height: 1.6; color: #334155; white-space: pre-wrap; padding: 15px 0; }
        .desc-title { font-weight: 700; color: #1e3a8a; margin-bottom: 6px; }

        .side-title { font-size: 16px; font-weight: 700; margin-bottom: 18px; color: #1e3a8a; border-bottom: 2px solid #eff6ff; padding-bottom: 10px; }
        .related-item { display: flex; gap: 12px; margin-bottom: 16px; text-decoration: none; color: inherit; padding-bottom: 12px; border-bottom: 1px solid #f1f5f9; transition: background 0.15s; }
        .related-item:last-child { border-bottom: none; margin-bottom: 0; padding-bottom: 0; }
        .related-item:hover .related-title { color: #2563eb; }
        .related-thumb { width: 110px; height: 65px; border-radius: 6px; overflow: hidden; background: #0f172a; flex-shrink: 0; }
        .related-thumb img { width: 100%; height: 100%; object-fit: cover; }
        .related-info { display: flex; flex-direction: column; justify-content: space-between; }
        .related-title { font-size: 13px; font-weight: 600; line-height: 1.35; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; color: #0f172a; }
        .related-views { font-size: 12px; color: #64748b; margin-top: 4px; }
        .badge { display: inline-block; padding: 3px 8px; border-radius: 4px; font-size: 11px; font-weight: 600; }
        .badge-pending { background: #fffbeb; color: #b45309; border: 1px solid #fde68a; }
    </style>
</head>
<body>
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
                    <span><b><c:out value="${video.views}" /></b> lượt xem</span>
                    <span style="color: #cbd5e1; margin: 0 8px;">|</span>
                    <span>Danh mục: <b><c:out value="${video.category != null ? video.category.categoryname : 'Chung'}" /></b></span>
                    <c:if test="${video.active != 1}">
                        <span class="badge badge-pending" style="margin-left: 8px;">Video đang chờ duyệt</span>
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
                <p class="desc-title">Mô tả nội dung:</p>
                <c:out value="${not empty video.description ? video.description : 'Không có mô tả chi tiết cho video này.'}" />
            </div>
        </div>

        <!-- Cột Video Gợi Ý / Mới Nhất -->
        <div class="side-col">
            <div class="side-title">Video đề xuất</div>
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
                            <div class="related-views"><c:out value="${rv.views}" /> lượt xem</div>
                        </div>
                    </a>
                </c:if>
            </c:forEach>
        </div>
    </div>
</body>
</html>