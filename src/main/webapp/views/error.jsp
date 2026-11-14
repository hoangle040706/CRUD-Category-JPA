<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đăng Nhập Thất Bại</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f9f9f9; }
        .box { background: #fff; padding: 30px; border-radius: 8px; max-width: 450px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); border-left: 5px solid #dc3545; }
        .error-msg { color: #dc3545; font-size: 16px; margin-bottom: 20px; font-weight: bold; }
        .btn { display: inline-block; padding: 8px 16px; background: #007bff; color: #fff; text-decoration: none; border-radius: 4px; margin-right: 10px; }
    </style>
</head>
<body>
    <div class="box">
        <h2>Thông Báo Lỗi</h2>
        <p class="error-msg">Đăng nhập thất bại! Sai tên tài khoản hoặc mật khẩu.</p>
        <p>
            <a href="${pageContext.request.contextPath}/login" class="btn">Thử lại (Login)</a>
            <a href="${pageContext.request.contextPath}/home">Về trang chủ</a>
        </p>
    </div>
</body>
</html>
