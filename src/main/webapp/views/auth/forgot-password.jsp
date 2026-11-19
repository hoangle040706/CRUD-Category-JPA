<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quên Mật Khẩu - MyVideo Platform</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', system-ui, -apple-system, BlinkMacSystemFont, Roboto, sans-serif; }
        body { background-color: #f8fafc; color: #0f172a; }
        .auth-wrapper { display: flex; justify-content: center; align-items: center; min-height: calc(100vh - 160px); padding: 36px 16px; width: 100%; }
        .box { background: #fff; padding: 36px 32px; border-radius: 12px; width: 100%; max-width: 440px; border: 1px solid #e2e8f0; box-shadow: 0 10px 25px -5px rgba(37, 99, 235, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.05); }
        .brand-header { text-align: center; margin-bottom: 20px; }
        .brand-title { color: #1e3a8a; font-size: 20px; font-weight: 700; letter-spacing: -0.3px; }
        .subtitle { text-align: center; color: #64748b; font-size: 13px; margin-bottom: 24px; line-height: 1.5; }

        .alert-danger { background-color: #fef2f2; color: #991b1b; padding: 11px 14px; border-radius: 6px; margin-bottom: 20px; font-size: 13px; border: 1px solid #fecaca; text-align: center; }
        .alert-success { background-color: #ecfdf5; color: #047857; padding: 11px 14px; border-radius: 6px; margin-bottom: 20px; font-size: 13px; border: 1px solid #a7f3d0; text-align: center; }

        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 6px; font-weight: 600; color: #334155; font-size: 14px; }
        .form-control { width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; outline: none; transition: all 0.15s; color: #0f172a; }
        .form-control:focus { border-color: #2563eb; box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.18); }
        .form-control.is-invalid, .was-validated .form-control:invalid { border-color: #ef4444; }
        .invalid-feedback { display: none; color: #ef4444; font-size: 12px; margin-top: 4px; }
        .was-validated .form-control:invalid ~ .invalid-feedback,
        .form-control.is-invalid ~ .invalid-feedback { display: block; }

        .btn-submit { width: 100%; padding: 11px; background: #2563eb; color: #fff; border: none; border-radius: 6px; font-size: 14px; font-weight: 600; cursor: pointer; transition: background 0.15s; }
        .btn-submit:hover { background: #1d4ed8; }

        .extra-links { margin-top: 24px; text-align: center; font-size: 13px; }
        .extra-links a { color: #2563eb; text-decoration: none; font-weight: 600; }
        .extra-links a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="auth-wrapper">
    <div class="box">
        <div class="brand-header">
            <div class="brand-title">Quên Mật Khẩu</div>
        </div>
        <p class="subtitle">
            Nhập địa chỉ email tài khoản của bạn để nhận mã OTP thiết lập lại mật khẩu mới.
        </p>

        <c:if test="${message != null}">
            <div class="alert-success">${message}</div>
        </c:if>

        <c:if test="${alert != null}">
            <div class="alert-danger">${alert}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/forgot-password" method="post"
              class="needs-validation" novalidate>
            <div class="form-group">
                <label for="email">Địa chỉ Email:</label>
                <input type="email" id="email" name="email"
                       class="form-control"
                       value="<c:out value='${not empty email ? email : param.email}' />"
                       placeholder="example@email.com"
                       required maxlength="150"
                       autofocus />
                <div class="invalid-feedback">Vui lòng nhập địa chỉ email hợp lệ.</div>
            </div>

            <button type="submit" class="btn-submit">Gửi mã xác nhận</button>
        </form>

        <div class="extra-links">
            <a href="${pageContext.request.contextPath}/login">&larr; Quay lại trang đăng nhập</a>
        </div>
    </div>
    </div>
    <script src="${pageContext.request.contextPath}/assets/js/form-validation.js"></script>
</body>
</html>
