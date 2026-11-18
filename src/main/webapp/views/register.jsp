<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tạo Tài Khoản Mới - MyVideo Platform</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', system-ui, -apple-system, BlinkMacSystemFont, Roboto, sans-serif; }
        body { background-color: #f8fafc; color: #0f172a; display: flex; justify-content: center; align-items: center; min-height: 100vh; padding: 20px; }
        .box { background: #fff; padding: 36px 32px; border-radius: 12px; width: 100%; max-width: 440px; border: 1px solid #e2e8f0; box-shadow: 0 10px 25px -5px rgba(37, 99, 235, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.05); }
        .brand-header { text-align: center; margin-bottom: 22px; }
        .brand-title { color: #1e3a8a; font-size: 20px; font-weight: 700; letter-spacing: -0.3px; }
        .brand-subtitle { color: #64748b; font-size: 13px; margin-top: 4px; }
        
        .alert-danger { background-color: #fef2f2; color: #991b1b; padding: 11px 14px; border-radius: 6px; margin-bottom: 20px; font-size: 13px; border: 1px solid #fecaca; text-align: center; }
        .form-group { margin-bottom: 16px; }
        label { display: block; margin-bottom: 6px; font-weight: 600; color: #334155; font-size: 14px; }
        .form-control { width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; outline: none; transition: all 0.15s; color: #0f172a; }
        .form-control:focus { border-color: #2563eb; box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.18); }
        
        .btn-submit { width: 100%; padding: 11px; background: #2563eb; color: #fff; border: none; border-radius: 6px; font-size: 14px; font-weight: 600; cursor: pointer; transition: background 0.15s; margin-top: 8px; }
        .btn-submit:hover { background: #1d4ed8; }
        
        .extra-links { margin-top: 22px; text-align: center; font-size: 13px; color: #64748b; }
        .extra-links a { color: #2563eb; text-decoration: none; font-weight: 600; }
        .extra-links a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="box">
        <div class="brand-header">
            <div class="brand-title">MyVideo Platform</div>
            <div class="brand-subtitle">Đăng ký tài khoản thành viên mới</div>
        </div>

        <c:if test="${alert != null}">
            <div class="alert-danger">${alert}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/register" method="post">
            <div class="form-group">
                <label for="username">Tên tài khoản:</label>
                <input type="text" id="username" placeholder="Nhập tên tài khoản" name="username" class="form-control" required autofocus />
            </div>

            <div class="form-group">
                <label for="fullname">Họ và tên:</label>
                <input type="text" id="fullname" placeholder="Nhập họ và tên" name="fullname" class="form-control" required />
            </div>

            <div class="form-group">
                <label for="email">Địa chỉ Email:</label>
                <input type="email" id="email" placeholder="Nhập địa chỉ email" name="email" class="form-control" required />
            </div>

            <div class="form-group">
                <label for="phone">Số điện thoại:</label>
                <input type="text" id="phone" placeholder="Nhập số điện thoại" name="phone" class="form-control" required />
            </div>

            <div class="form-group">
                <label for="password">Mật khẩu:</label>
                <input type="password" id="password" placeholder="Nhập mật khẩu" name="password" class="form-control" required />
            </div>

            <button type="submit" class="btn-submit">Tạo tài khoản</button>
        </form>

        <div class="extra-links">
            <p>Đã có tài khoản? <a href="${pageContext.request.contextPath}/login">Đăng nhập</a></p>
            <p style="margin-top: 10px;"><a href="${pageContext.request.contextPath}/home">&larr; Quay lại trang chủ</a></p>
        </div>
    </div>
</body>
</html>