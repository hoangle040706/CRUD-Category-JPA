<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tải Lên Video Mới - MyVideo Platform</title>
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

        /* Form Card */
        .container { max-width: 760px; margin: 35px auto; padding: 0 20px; }
        .card { background: #fff; padding: 32px; border-radius: 12px; border: 1px solid #e2e8f0; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); }
        h1 { font-size: 20px; font-weight: 700; color: #1e3a8a; margin-bottom: 22px; border-bottom: 2px solid #eff6ff; padding-bottom: 12px; letter-spacing: -0.3px; }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 7px; font-weight: 600; font-size: 14px; color: #334155; }
        input[type="text"], select, textarea { width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; outline: none; transition: all 0.15s; color: #0f172a; background: #ffffff; }
        input[type="text"]:focus, select:focus, textarea:focus { border-color: #2563eb; box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.18); }
        .radio-group { display: flex; gap: 24px; align-items: center; padding: 6px 0; }
        .radio-label { display: flex; align-items: center; gap: 8px; font-weight: normal; cursor: pointer; font-size: 14px; color: #334155; }
        .help-text { font-size: 12px; color: #64748b; margin-top: 5px; }
        .btn-group { display: flex; gap: 12px; margin-top: 28px; }
        .btn { padding: 10px 22px; border-radius: 6px; font-weight: 600; font-size: 14px; cursor: pointer; border: none; text-decoration: none; text-align: center; transition: all 0.15s; }
        .btn-primary { background: #2563eb; color: #fff; }
        .btn-primary:hover { background: #1d4ed8; }
        .btn-secondary { background: #64748b; color: #fff; }
        .btn-secondary:hover { background: #475569; }
        .alert-danger { background-color: #fef2f2; color: #991b1b; padding: 12px 16px; border-radius: 8px; margin-bottom: 20px; border: 1px solid #fecaca; font-size: 14px; }
    </style>
</head>
<body>
    <header class="topbar">
        <div class="topbar-container">
            <div class="nav-brand-group">
                <a href="${pageContext.request.contextPath}/home" class="brand-logo">MyVideo Platform</a>
                <nav class="nav-menu">
                    <a href="${pageContext.request.contextPath}/home" class="nav-link">Trang chủ</a>
                    <a href="${pageContext.request.contextPath}/video" class="nav-link">Tất cả Video</a>
                    <a href="${pageContext.request.contextPath}/admin/category/list" class="nav-link">Danh mục</a>
                    <a href="${pageContext.request.contextPath}/video?filter=my" class="nav-link">Video của tôi</a>
                    <a href="${pageContext.request.contextPath}/video/upload" class="nav-link active">Đăng Video</a>
                    <c:if test="${sessionScope.account.roleid == 1}">
                        <a href="${pageContext.request.contextPath}/admin/home" class="nav-link nav-link-badge">Quản trị Admin</a>
                    </c:if>
                    <c:if test="${sessionScope.account.roleid == 2}">
                        <a href="${pageContext.request.contextPath}/manager/home" class="nav-link nav-link-badge">Bảng điều khiển Manager</a>
                    </c:if>
                </nav>
            </div>
            <div class="nav-user-group">
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
            </div>
        </div>
    </header>

    <div class="container">
        <div class="card">
            <h1>Tải Lên Video Mới</h1>

            <c:if test="${not empty error}">
                <div class="alert-danger"><c:out value="${error}" /></div>
            </c:if>

            <form method="post" action="${pageContext.request.contextPath}/video/insert" enctype="multipart/form-data">
                <input type="hidden" name="csrfToken" value="${sessionScope.CSRF_TOKEN}">

                <div class="form-group">
                    <label for="title">Tiêu đề Video <span style="color:#ef4444;">*</span></label>
                    <input type="text" id="title" name="title" required placeholder="Nhập tiêu đề video..." maxlength="500">
                </div>

                <div class="form-group">
                    <label for="categoryId">Danh mục</label>
                    <select id="categoryId" name="categoryId">
                        <option value="">-- Chọn Danh mục --</option>
                        <c:forEach items="${categories}" var="cat">
                            <option value="${cat.categoryid}"><c:out value="${cat.categoryname}" /></option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group">
                    <label for="description">Mô tả chi tiết</label>
                    <textarea id="description" name="description" rows="4" placeholder="Nhập mô tả nội dung video..."></textarea>
                </div>

                <div class="form-group">
                    <label for="poster">Ảnh bìa (Poster) (Tối đa 5MB)</label>
                    <input type="file" id="poster" name="poster" accept="image/*">
                    <div class="help-text">Định dạng hỗ trợ: JPG, PNG, WEBP (Tối đa 5MB).</div>
                </div>

                <div class="form-group">
                    <label>Nguồn Video</label>
                    <div class="radio-group">
                        <label class="radio-label">
                            <input type="radio" name="sourceType" value="LOCAL" checked onchange="toggleSource()">
                            Tải file video lên (MP4, WEBM, max 200MB)
                        </label>
                        <label class="radio-label">
                            <input type="radio" name="sourceType" value="YOUTUBE" onchange="toggleSource()">
                            Nhúng link YouTube
                        </label>
                    </div>
                </div>

                <div class="form-group" id="localVideoGroup">
                    <label for="videoFile">File Video <span style="color:#ef4444;">*</span> (Tối đa 200MB)</label>
                    <input type="file" id="videoFile" name="videoFile" accept="video/mp4,video/webm,video/ogg">
                    <div class="help-text">Định dạng khuyến nghị: MP4 chuẩn H.264 / AAC.</div>
                </div>

                <div class="form-group" id="youtubeGroup" style="display: none;">
                    <label for="youtubeUrl">Đường dẫn Video YouTube <span style="color:#ef4444;">*</span></label>
                    <input type="text" id="youtubeUrl" name="youtubeUrl" placeholder="Ví dụ: https://www.youtube.com/watch?v=dQw4w9WgXcQ">
                </div>

                <div class="btn-group">
                    <button type="submit" class="btn btn-primary">Tải Lên Video</button>
                    <a href="${pageContext.request.contextPath}/video?filter=my" class="btn btn-secondary">Hủy bỏ</a>
                </div>
            </form>
        </div>
    </div>

    <script>
        function toggleSource() {
            var isLocal = document.querySelector('input[name="sourceType"]:checked').value === 'LOCAL';
            document.getElementById('localVideoGroup').style.display = isLocal ? 'block' : 'none';
            document.getElementById('youtubeGroup').style.display = isLocal ? 'none' : 'block';
        }
    </script>
</body>
</html>