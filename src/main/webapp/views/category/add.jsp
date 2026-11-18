<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thêm Danh Mục Mới - MyVideo Platform</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', system-ui, -apple-system, BlinkMacSystemFont, Roboto, sans-serif; }
        body { background-color: #f8fafc; color: #0f172a; line-height: 1.5; padding: 40px 20px; }
        .box { background: #fff; padding: 32px; border-radius: 12px; max-width: 520px; margin: 0 auto; border: 1px solid #e2e8f0; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); }
        h2 { margin-top: 0; color: #1e3a8a; font-size: 20px; font-weight: 700; margin-bottom: 22px; border-bottom: 2px solid #eff6ff; padding-bottom: 12px; }
        .form-group { margin-bottom: 18px; }
        label { display: block; margin-bottom: 6px; font-weight: 600; color: #334155; font-size: 14px; }
        input[type="text"], textarea { width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; outline: none; transition: all 0.15s; color: #0f172a; }
        input[type="text"]:focus, textarea:focus { border-color: #2563eb; box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.18); }
        textarea { height: 100px; resize: vertical; }
        .btn-group { display: flex; gap: 10px; margin-top: 24px; }
        .btn-submit { padding: 10px 20px; background: #2563eb; color: #fff; border: none; border-radius: 6px; font-size: 14px; cursor: pointer; font-weight: 600; transition: all 0.15s; }
        .btn-submit:hover { background: #1d4ed8; }
        .btn-cancel { display: inline-block; padding: 10px 18px; background: #64748b; color: #fff; text-decoration: none; border-radius: 6px; font-size: 14px; font-weight: 600; transition: all 0.15s; }
        .btn-cancel:hover { background: #475569; }
        .alert-danger { background-color: #fef2f2; color: #991b1b; padding: 12px 14px; border-radius: 6px; margin-bottom: 18px; border: 1px solid #fecaca; font-size: 14px; }
    </style>
</head>
<body>
    <div class="box">
        <h2>Thêm Danh Mục Mới</h2>

        <c:if test="${not empty alert}">
            <div class="alert-danger">${alert}</div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/category/add">
            <div class="form-group">
                <label for="name">Tên danh mục <span style="color:#ef4444;">*</span></label>
                <input type="text" id="name" name="name" required autofocus placeholder="Ví dụ: Điện thoại, Laptop...">
            </div>
            <div class="form-group">
                <label for="description">Mô tả:</label>
                <textarea id="description" name="description" placeholder="Nhập mô tả ngắn gọn về danh mục"></textarea>
            </div>
            <div class="btn-group">
                <button type="submit" class="btn-submit">Lưu lại</button>
                <a href="${pageContext.request.contextPath}/category/list" class="btn-cancel">Hủy bỏ</a>
            </div>
        </form>
    </div>
</body>
</html>