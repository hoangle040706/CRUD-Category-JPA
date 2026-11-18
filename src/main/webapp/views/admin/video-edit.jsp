<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chỉnh Sửa Video - Admin Dashboard</title>
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
        .content { flex-grow: 1; padding: 25px 30px; }
        .card { max-width: 800px; background: #fff; border-radius: 8px; padding: 30px; box-shadow: 0 1px 4px rgba(0,0,0,0.08); }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 8px; font-weight: 600; font-size: 14px; color: #495057; }
        input[type="text"], select, textarea { width: 100%; padding: 10px 14px; border: 1px solid #ced4da; border-radius: 4px; font-size: 14px; outline: none; }
        input[type="text"]:focus, select:focus, textarea:focus { border-color: #80bdff; }
        .radio-group { display: flex; gap: 20px; align-items: center; padding: 6px 0; }
        .radio-label { display: flex; align-items: center; gap: 6px; font-weight: normal; cursor: pointer; }
        .btn-group { display: flex; gap: 12px; margin-top: 25px; }
        .btn { padding: 10px 20px; border-radius: 4px; font-weight: bold; font-size: 14px; cursor: pointer; border: none; text-decoration: none; }
        .btn-warning { background: #ffc107; color: #212529; }
        .btn-secondary { background: #6c757d; color: #fff; }
        .alert-danger { background-color: #f8d7da; color: #721c24; padding: 12px; border-radius: 4px; margin-bottom: 20px; }
        .current-preview { display: flex; gap: 12px; align-items: center; margin-top: 8px; }
        .current-thumb { width: 120px; height: 70px; object-fit: cover; border-radius: 4px; border: 1px solid #ccc; }
    </style>
</head>
<body>
    <div class="topbar">
        <h2>🎬 Quản Trị Video - Chỉnh Sửa</h2>
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
            <div class="card">
                <h3 style="margin-bottom: 20px; border-bottom: 1px solid #dee2e6; padding-bottom: 10px;">Chỉnh Sửa Video (ID: <c:out value="${video.videoId}" />)</h3>

                <c:if test="${not empty error}">
                    <div class="alert-danger"><c:out value="${error}" /></div>
                </c:if>

                <form method="post" action="${pageContext.request.contextPath}/admin/video/update" enctype="multipart/form-data">
                    <input type="hidden" name="csrfToken" value="${sessionScope.CSRF_TOKEN}">
                    <input type="hidden" name="videoId" value="${video.videoId}">

                    <div class="form-group">
                        <label for="title">Tiêu đề Video <span style="color:red;">*</span></label>
                        <input type="text" id="title" name="title" required value="<c:out value="${video.title}" />" maxlength="500">
                    </div>

                    <div class="form-group">
                        <label for="categoryId">Danh mục</label>
                        <select id="categoryId" name="categoryId">
                            <option value="">-- Chọn danh mục --</option>
                            <c:forEach items="${categories}" var="cat">
                                <option value="${cat.categoryid}" ${video.category != null && video.category.categoryid == cat.categoryid ? 'selected' : ''}>
                                    <c:out value="${cat.categoryname}" />
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="description">Mô tả</label>
                        <textarea id="description" name="description" rows="3"><c:out value="${video.description}" /></textarea>
                    </div>

                    <div class="form-group">
                        <label for="poster">Ảnh bìa (Poster)</label>
                        <c:if test="${not empty video.poster}">
                            <div class="current-preview">
                                <c:choose>
                                    <c:when test="${video.poster.startsWith('http')}">
                                        <img src="${video.poster}" class="current-thumb" alt="Poster Hiện Tại">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="${pageContext.request.contextPath}/image?type=poster&fname=${video.poster}" class="current-thumb" alt="Poster Hiện Tại">
                                    </c:otherwise>
                                </c:choose>
                                <span style="font-size: 12px; color: #666;">Tên file: <c:out value="${video.poster}" /></span>
                            </div>
                        </c:if>
                        <input type="file" id="poster" name="poster" accept="image/*" style="margin-top: 8px;">
                    </div>

                    <div class="form-group">
                        <label>Nguồn Video</label>
                        <div class="radio-group">
                            <label class="radio-label">
                                <input type="radio" name="sourceType" value="LOCAL" ${video.sourceType == 'LOCAL' ? 'checked' : ''} onchange="toggleSource()">
                                Tải file video lên (MP4, WEBM)
                            </label>
                            <label class="radio-label">
                                <input type="radio" name="sourceType" value="YOUTUBE" ${video.sourceType == 'YOUTUBE' ? 'checked' : ''} onchange="toggleSource()">
                                Link YouTube
                            </label>
                        </div>
                    </div>

                    <div class="form-group" id="localGroup" style="${video.sourceType == 'LOCAL' ? 'display:block;' : 'display:none;'}">
                        <label for="videoFile">File Video (Tối đa 200MB)</label>
                        <c:if test="${video.sourceType == 'LOCAL'}">
                            <div style="font-size: 12px; color: #666; margin-bottom: 6px;">File hiện tại: <b><c:out value="${video.videoPath}" /></b></div>
                        </c:if>
                        <input type="file" id="videoFile" name="videoFile" accept="video/mp4,video/webm,video/ogg">
                    </div>

                    <div class="form-group" id="ytGroup" style="${video.sourceType == 'YOUTUBE' ? 'display:block;' : 'display:none;'}">
                        <label for="youtubeUrl">Đường dẫn YouTube</label>
                        <input type="text" id="youtubeUrl" name="youtubeUrl" value="<c:out value="${video.sourceType == 'YOUTUBE' ? video.videoPath : ''}" />">
                    </div>

                    <div class="form-group">
                        <label class="radio-label">
                            <input type="checkbox" name="active" value="1" ${video.active == 1 ? 'checked' : ''}>
                            Đã phê duyệt / Công khai (Active = 1)
                        </label>
                    </div>

                    <div class="btn-group">
                        <button type="submit" class="btn btn-warning">Lưu Thay Đổi</button>
                        <a href="${pageContext.request.contextPath}/admin/videos" class="btn btn-secondary">Hủy bỏ</a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        function toggleSource() {
            var isLocal = document.querySelector('input[name="sourceType"]:checked').value === 'LOCAL';
            document.getElementById('localGroup').style.display = isLocal ? 'block' : 'none';
            document.getElementById('ytGroup').style.display = isLocal ? 'none' : 'block';
        }
    </script>
</body>
</html>
