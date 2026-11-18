<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tải Lên Video Mới - MyVideo Platform</title>
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
        .btn-success { background: #28a745; color: #fff; }
        .btn-success:hover { background: #218838; }
        .btn-secondary { background: #6c757d; color: #fff; }
        .btn-secondary:hover { background: #5a6268; }
        .alert-danger { background-color: #f8d7da; color: #721c24; padding: 12px; border-radius: 4px; margin-bottom: 20px; }
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
            <h1>➕ Tải Lên Video Mới</h1>

            <c:if test="${not empty error}">
                <div class="alert-danger"><c:out value="${error}" /></div>
            </c:if>

            <form method="post" action="${pageContext.request.contextPath}/video/insert" enctype="multipart/form-data">
                <input type="hidden" name="csrfToken" value="${sessionScope.CSRF_TOKEN}">

                <div class="form-group">
                    <label for="title">Tiêu đề Video <span style="color:red;">*</span></label>
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
                    <label for="videoFile">File Video <span style="color:red;">*</span> (Tối đa 200MB)</label>
                    <input type="file" id="videoFile" name="videoFile" accept="video/mp4,video/webm,video/ogg">
                    <div class="help-text">Định dạng khuyến nghị: MP4 chuẩn H.264 / AAC.</div>
                </div>

                <div class="form-group" id="youtubeGroup" style="display: none;">
                    <label for="youtubeUrl">Đường dẫn Video YouTube <span style="color:red;">*</span></label>
                    <input type="text" id="youtubeUrl" name="youtubeUrl" placeholder="Ví dụ: https://www.youtube.com/watch?v=dQw4w9WgXcQ">
                </div>

                <div class="btn-group">
                    <button type="submit" class="btn btn-success">Tải Lên Video</button>
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
