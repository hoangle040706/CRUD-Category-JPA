<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quên Mật Khẩu</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Arial, sans-serif; }
        body { background-color: #f4f6f9; display: flex; justify-content: center; align-items: center; min-height: 100vh; padding: 20px; }
        .box { background: #fff; padding: 35px 30px; border-radius: 8px; width: 100%; max-width: 440px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
        h2 { text-align: center; color: #2c3e50; margin-bottom: 12px; font-size: 24px; font-weight: 600; }
        .subtitle { text-align: center; color: #6c757d; font-size: 14px; margin-bottom: 25px; line-height: 1.5; }
        .alert-danger { background-color: #f8d7da; color: #721c24; padding: 10px 14px; border-radius: 4px; margin-bottom: 20px; font-size: 14px; border: 1px solid #f5c6cb; text-align: center; }
        .alert-success { background-color: #d4edda; color: #155724; padding: 10px 14px; border-radius: 4px; margin-bottom: 20px; font-size: 14px; border: 1px solid #c3e6cb; text-align: center; }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 6px; font-weight: 600; color: #495057; font-size: 14px; }
        .form-control { width: 100%; padding: 11px 13px; border: 1px solid #ced4da; border-radius: 4px; font-size: 14px; }
        .form-control:focus { outline: none; border-color: #007bff; box-shadow: 0 0 0 3px rgba(0,123,255,0.15); }
        .btn-submit { width: 100%; padding: 12px; background: #007bff; color: #fff; border: none; border-radius: 4px; font-size: 15px; font-weight: bold; cursor: pointer; transition: 0.2s; }
        .btn-submit:hover { background: #0056b3; }
        .extra-links { margin-top: 25px; text-align: center; font-size: 14px; }
        .extra-links a { color: #007bff; text-decoration: none; font-weight: 600; }
        .extra-links a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="box">
        <h2>Quên Mật Khẩu</h2>
        <p class="subtitle">
            Nhập địa chỉ email tài khoản của bạn để nhận mã OTP thiết lập lại mật khẩu mới.
        </p>

        <c:if test="${message != null}">
            <div class="alert-success">${message}</div>
        </c:if>

        <c:if test="${alert != null}">
            <div class="alert-danger">${alert}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/forgot-password" method="post">
            <div class="form-group">
                <label for="email">Địa chỉ Email:</label>
                <input type="email" id="email" name="email" class="form-control" placeholder="example@email.com" required autofocus />
            </div>

            <button type="submit" class="btn-submit">Gửi mã xác nhận</button>
        </form>

        <div class="extra-links">
            <a href="${pageContext.request.contextPath}/login">&larr; Quay lại trang đăng nhập</a>
        </div>
    </div>
</body>
</html>
