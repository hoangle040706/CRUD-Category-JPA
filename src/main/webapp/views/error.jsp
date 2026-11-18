<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông Báo Lỗi - MyVideo Platform</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', system-ui, -apple-system, BlinkMacSystemFont, Roboto, sans-serif; }
        body { background-color: #f8fafc; color: #0f172a; display: flex; justify-content: center; align-items: center; min-height: 100vh; padding: 20px; }
        .box { background: #fff; padding: 36px 32px; border-radius: 12px; max-width: 460px; width: 100%; border: 1px solid #e2e8f0; box-shadow: 0 10px 25px -5px rgba(239, 68, 68, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.05); border-left: 5px solid #ef4444; }
        h2 { color: #1e3a8a; font-size: 20px; font-weight: 700; margin-bottom: 12px; }
        .error-msg { color: #991b1b; background: #fef2f2; padding: 12px 14px; border-radius: 6px; font-size: 14px; margin-bottom: 24px; border: 1px solid #fecaca; }
        .btn-group { display: flex; gap: 10px; }
        .btn { display: inline-block; padding: 10px 18px; border-radius: 6px; text-decoration: none; font-size: 14px; font-weight: 600; text-align: center; transition: all 0.15s; }
        .btn-primary { background: #2563eb; color: #fff; }
        .btn-primary:hover { background: #1d4ed8; }
        .btn-secondary { background: #64748b; color: #fff; }
        .btn-secondary:hover { background: #475569; }
    </style>
</head>
<body>
    <div class="box">
        <h2>Thông Báo Lỗi</h2>
        <p class="error-msg">Đăng nhập thất bại! Sai tên tài khoản hoặc mật khẩu.</p>
        <div class="btn-group">
            <a href="${pageContext.request.contextPath}/login" class="btn btn-primary">Thử lại</a>
            <a href="${pageContext.request.contextPath}/home" class="btn btn-secondary">Về trang chủ</a>
        </div>
    </div>
</body>
</html>