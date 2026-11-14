<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tạo tài khoản mới</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Arial, sans-serif; }
        body { background-color: #f4f6f9; display: flex; justify-content: center; align-items: center; min-height: 100vh; padding: 20px; }
        .box { background: #fff; padding: 35px 30px; border-radius: 8px; width: 100%; max-width: 440px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
        h2 { text-align: center; color: #2c3e50; margin-bottom: 25px; font-size: 24px; font-weight: 600; }
        .alert-danger { background-color: #f8d7da; color: #721c24; padding: 10px 14px; border-radius: 4px; margin-bottom: 20px; font-size: 14px; border: 1px solid #f5c6cb; text-align: center; }
        .form-group { margin-bottom: 16px; }
        label { display: block; margin-bottom: 6px; font-weight: 600; color: #495057; font-size: 14px; }
        .form-control { width: 100%; padding: 10px 12px; border: 1px solid #ced4da; border-radius: 4px; font-size: 14px; }
        .form-control:focus { outline: none; border-color: #007bff; box-shadow: 0 0 0 3px rgba(0,123,255,0.15); }
        .btn-submit { width: 100%; padding: 12px; background: #28a745; color: #fff; border: none; border-radius: 4px; font-size: 15px; font-weight: bold; cursor: pointer; transition: 0.2s; margin-top: 10px; }
        .btn-submit:hover { background: #218838; }
        .extra-links { margin-top: 20px; text-align: center; font-size: 14px; color: #6c757d; }
        .extra-links a { color: #007bff; text-decoration: none; font-weight: 600; }
        .extra-links a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="box">
        <h2>Tạo tài khoản mới</h2>

        <c:if test="${alert != null}">
            <div class="alert-danger">${alert}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/register" method="post">
            <div class="form-group">
                <label for="username">Tài khoản:</label>
                <input type="text" id="username" placeholder="Tài khoản" name="username" class="form-control" required autofocus />
            </div>

            <div class="form-group">
                <label for="fullname">Họ tên:</label>
                <input type="text" id="fullname" placeholder="Họ tên" name="fullname" class="form-control" required />
            </div>

            <div class="form-group">
                <label for="email">Nhập Email:</label>
                <input type="email" id="email" placeholder="Nhập Email" name="email" class="form-control" required />
            </div>

            <div class="form-group">
                <label for="phone">Số điện thoại:</label>
                <input type="text" id="phone" placeholder="Số điện thoại" name="phone" class="form-control" required />
            </div>

            <div class="form-group">
                <label for="password">Mật khẩu:</label>
                <input type="password" id="password" placeholder="Mật khẩu" name="password" class="form-control" required />
            </div>

            <button type="submit" class="btn-submit">Tạo tài khoản</button>
        </form>

        <div class="extra-links">
            <p>Nếu bạn đã có tài khoản? <a href="${pageContext.request.contextPath}/login">Đăng nhập</a></p>
            <p style="margin-top: 8px;"><a href="${pageContext.request.contextPath}/home">&larr; Quay lại trang chủ</a></p>
        </div>
    </div>
</body>
</html>
