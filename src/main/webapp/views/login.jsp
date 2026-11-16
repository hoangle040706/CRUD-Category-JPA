<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng Nhập Vào Hệ Thống</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Arial, sans-serif; }
        body { background-color: #f4f6f9; display: flex; justify-content: center; align-items: center; min-height: 100vh; padding: 20px; }
        .box { background: #fff; padding: 35px 30px; border-radius: 8px; width: 100%; max-width: 420px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
        h2 { text-align: center; color: #2c3e50; margin-bottom: 25px; font-size: 24px; font-weight: 600; }
        .alert-danger { background-color: #f8d7da; color: #721c24; padding: 10px 14px; border-radius: 4px; margin-bottom: 20px; font-size: 14px; border: 1px solid #f5c6cb; text-align: center; }
        .alert-success { background-color: #d4edda; color: #155724; padding: 10px 14px; border-radius: 4px; margin-bottom: 20px; font-size: 14px; border: 1px solid #c3e6cb; text-align: center; }
        .form-group { margin-bottom: 18px; }
        label { display: block; margin-bottom: 6px; font-weight: 600; color: #495057; font-size: 14px; }
        .form-control { width: 100%; padding: 11px 13px; border: 1px solid #ced4da; border-radius: 4px; font-size: 14px; }
        .form-control:focus { outline: none; border-color: #007bff; box-shadow: 0 0 0 3px rgba(0,123,255,0.15); }
        .form-check-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 22px; font-size: 14px; }
        .form-check { display: flex; align-items: center; gap: 8px; }
        .form-check label { margin-bottom: 0; font-weight: normal; cursor: pointer; }
        .btn-submit { width: 100%; padding: 12px; background: #007bff; color: #fff; border: none; border-radius: 4px; font-size: 15px; font-weight: bold; cursor: pointer; transition: 0.2s; }
        .btn-submit:hover { background: #0056b3; }
        .extra-links { margin-top: 22px; text-align: center; font-size: 14px; color: #6c757d; }
        .extra-links a, .form-check-row a { color: #007bff; text-decoration: none; font-weight: 600; }
        .extra-links a:hover, .form-check-row a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="box">
        <h2>Đăng Nhập Vào Hệ Thống</h2>

        <c:if test="${message != null}">
            <div class="alert-success">${message}</div>
        </c:if>

        <c:if test="${alert != null}">
            <div class="alert-danger">${alert}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/login" method="post">
            <div class="form-group">
                <label for="username">Tài khoản:</label>
                <input type="text" id="username" name="username" placeholder="Tài khoản" class="form-control" required autofocus />
            </div>

            <div class="form-group">
                <label for="password">Mật khẩu:</label>
                <input type="password" id="password" name="password" placeholder="Mật khẩu" class="form-control" required />
            </div>

            <div class="form-check-row">
                <div class="form-check">
                    <input type="checkbox" id="remember" name="remember" value="on" />
                    <label for="remember">Nhớ tôi (Remember me)</label>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/forgot-password">Quên mật khẩu?</a>
                </div>
            </div>

            <button type="submit" class="btn-submit">Đăng nhập</button>
        </form>

        <div class="extra-links">
            <p>Nếu bạn chưa có tài khoản trên hệ thống, thì hãy <a href="${pageContext.request.contextPath}/register">Đăng ký</a></p>
            <p style="margin-top: 8px;"><a href="${pageContext.request.contextPath}/home">&larr; Quay lại trang chủ</a></p>
        </div>
    </div>
</body>
</html>
