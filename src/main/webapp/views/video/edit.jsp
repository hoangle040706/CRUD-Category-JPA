<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chỉnh Sửa Video - MyVideo Platform</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Arial, sans-serif; }
        body { background-color: #f4f6f9; color: #333; }
        .topbar { background: #343a40; color: #fff; padding: 12px 30px; display: flex; justify-content: space-between; align-items: center; }
        .topbar .nav-links { display: flex; gap: 18px; align-items: center; }
        .topbar a { color: #f8f9fa; text-decoration: none; font-size: 14px; font-weight: 500; }
        .topbar a:hover { color: #007bff; }
        .container { max-width: 760px; margin: 35px auto; padding: 0 15px; }
        .card { background: #fff; padding: 35px; border-radius: 8px; box-shadow: 0 4px 15px rgba(0,0,0,0.08); }
        h1 { font-size: 22px; color: #2c3e50; margin-bottom: 25px; border-bottom: 2px solid #e9ecef; padding-bottom: 12px; }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 8px; font-weight: 600; font-size: 14px; color: #495057; }
        input[type="text"], select, textarea { width: 100%; padding: 10px 14px; border: 1px solid #ced4da; border-radius: 4px; font-size: 14px; outline: none; transition: border-color 0.15s; }
        input[type="text"]:focus, select:focus, textarea:focus { border-color: #80bdff; box-shadow: 0 0 0 3px rgba(0,123,255,0.15); }
        .radio-group { display: flex; gap: 20px; align-items: center; padding: 6px 0; }
        .radio-label { display: flex; align-items: center; gap: 6px; font-weight: normal; cursor: pointer; }
        .help-text { font-size: 12px; color: #6c757d; margin-top: 5px; }
        .btn-group { display: flex; gap: 12px; margin-top: 30px; }
        .btn { padding: 10px 22px; border-radius: 4px; font-weight: bold; font-size: 14px; cursor: pointer; border: none; text-decoration: none; text-align: center; }
        .btn-warning { background: #ffc107; color: #212529; }
        .btn-warning:hover { background: #e0a800; }
        .btn-secondary { background: #6c757d; color: #fff; }
        .btn-secondary:hover { background: #5a6268; }
        .alert-danger { background-color: #f8d7da; color: #721c24; padding: 12px; border-radius: 4px; margin-bottom: 20px; }
        .alert-info { background-color: #d1ecf1; color: #0c5460; padding: 12px; border-radius: 4px; margin-bottom: 20px; }
        .current-preview { display: flex; gap: 15px; align-items: center; margin-top: 8px; }
        .current-thumb { width: 120px; height: 70px; object-fit: cover; border-radius: 4px; border: 1px solid #ddd; }
    </style>
</head>
<body>
    <div class="topbar">
        <div class="nav-links">
            <a href="${pageContext.request.contextPath}/home" style="font-size: 16px; font-weight: bold;">🎬 MyVideo Platform</a>
            <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
            <a href="${pageContext.request.contextPath}/video">Tất cả Video</a>
            <a href="${pageContext.request.contextPath}/admin/category/list">📁 Danh mục Sản phẩm</a>
            <a href="${pageContext.request.contextPath}/video?filter=my">Video của tôi</a>
            <c:if test="${sessionScope.account.roleid == 1}">
                <a href="${pageContext.request.contextPath}/admin/home" style="color: #ffc107; font-weight: bold;">⚙️ Quản Trị Admin</a>
            </c:if>
            <c:if test="${sessionScope.account.roleid == 2}">
                <a href="${pageContext.request.contextPath}/manager/home" style="color: #fd7e14; font-weight: bold;">📊 Dashboard Manager</a>
            </c:if>
        </div>
        <div>
            <span>Xin chào: <b><c:out value="${sessionScope.account.fullName}" /></b></span> |
            <a href="${pageContext.request.contextPath}/logout">Đăng Xuất</a>
        </div>
    </div>

    <div class="container">
        <div class="card">
            <h1>✏️ Chỉnh Sửa Video</h1>

            <div class="alert-info">
                ℹ️ Lưu ý: Khi bạn cập nhật video, hệ thống sẽ tự động chuyển trạng thái về <b>Chờ duyệt</b> để Admin kiểm duyệt lại nội dung.
            </div>

            <c:if test="${not empty error}">
                <div class="alert-danger"><c:out value="${error}" /></div>
            </c:if>

            <form method="post" action="${pageContext.request.contextPath}/video/update" enctype="multipart/form-data">
                <input type="hidden" name="csrfToken" value="${sessionScope.CSRF_TOKEN}">
                <input type="hidden" name="videoId" value="${video.videoId}">

                <div class="form-group">
                    <label for="title">Tiêu đề Video <span style="color:red;">*</span></label>
                    <input type="text" id="title" name="title" required value="<c:out value="${video.title}" />" maxlength="500">
                </div>

                <div class="form-group">
                    <label for="categoryId">Danh mục</label>
                    <select id="categoryId" name="categoryId">
                        <option value="">-- Chọn Danh mục --</option>
                        <c:forEach items="${categories}" var="cat">
                            <option value="${cat.categoryid}" ${video.category != null && video.category.categoryid == cat.categoryid ? 'selected' : ''}>
                                <c:out value="${cat.categoryname}" />
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group">
                    <label for="description">Mô tả chi tiết</label>
                    <textarea id="description" name="description" rows="4"><c:out value="${video.description}" /></textarea>
                </div>

                <div class="form-group">
                    <label for="poster">Thay đổi Ảnh bìa (Poster)</label>
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
                            <span class="help-text">Ảnh hiện tại: <c:out value="${video.poster}" /></span>
                        </div>
                    </c:if>
                    <input type="file" id="poster" name="poster" accept="image/*" style="margin-top: 8px;">
                    <div class="help-text">Chọn ảnh mới nếu muốn thay đổi (Tối đa 5MB). Để trống nếu giữ nguyên.</div>
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
                            Nhúng link YouTube
                        </label>
                    </div>
                </div>

                <div class="form-group" id="localVideoGroup" style="${video.sourceType == 'LOCAL' ? 'display:block;' : 'display:none;'}">
                    <label for="videoFile">Thay đổi File Video (Tối đa 200MB)</label>
                    <c:if test="${video.sourceType == 'LOCAL'}">
                        <div class="help-text" style="margin-bottom: 6px;">File hiện tại: <b><c:out value="${video.videoPath}" /></b></div>
                    </c:if>
                    <input type="file" id="videoFile" name="videoFile" accept="video/mp4,video/webm,video/ogg">
                    <div class="help-text">Chọn file mới nếu muốn cập nhật video. Để trống nếu giữ nguyên video cũ.</div>
                </div>

                <div class="form-group" id="youtubeGroup" style="${video.sourceType == 'YOUTUBE' ? 'display:block;' : 'display:none;'}">
                    <label for="youtubeUrl">Đường dẫn Video YouTube</label>
                    <input type="text" id="youtubeUrl" name="youtubeUrl" value="<c:out value="${video.sourceType == 'YOUTUBE' ? video.videoPath : ''}" />" placeholder="https://www.youtube.com/watch?v=...">
                </div>

                <div class="btn-group">
                    <button type="submit" class="btn btn-warning">Lưu Thay Đổi</button>
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
