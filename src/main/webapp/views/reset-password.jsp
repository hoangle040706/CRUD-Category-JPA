<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thiết Lập Lại Mật Khẩu - MyVideo Platform</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', system-ui, -apple-system, BlinkMacSystemFont, Roboto, sans-serif; }
        body { background-color: #f8fafc; color: #0f172a; }
        .auth-wrapper { display: flex; justify-content: center; align-items: center; min-height: calc(100vh - 160px); padding: 36px 16px; width: 100%; }
        .box { background: #fff; padding: 36px 32px; border-radius: 12px; width: 100%; max-width: 440px; border: 1px solid #e2e8f0; box-shadow: 0 10px 25px -5px rgba(37, 99, 235, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.05); }
        .brand-header { text-align: center; margin-bottom: 12px; }
        .brand-title { color: #1e3a8a; font-size: 20px; font-weight: 700; letter-spacing: -0.3px; }
        .subtitle { text-align: center; color: #64748b; font-size: 13px; margin-bottom: 24px; line-height: 1.5; }
        
        .alert-danger { background-color: #fef2f2; color: #991b1b; padding: 11px 14px; border-radius: 6px; margin-bottom: 20px; font-size: 13px; border: 1px solid #fecaca; text-align: center; }
        .alert-success { background-color: #ecfdf5; color: #047857; padding: 11px 14px; border-radius: 6px; margin-bottom: 20px; font-size: 13px; border: 1px solid #a7f3d0; text-align: center; }
        
        .form-group { margin-bottom: 18px; }
        label { display: block; margin-bottom: 6px; font-weight: 600; color: #334155; font-size: 14px; }
        .form-control { width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; outline: none; transition: all 0.15s; color: #0f172a; }
        .form-control:focus { border-color: #2563eb; box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.18); }
        .otp-input { text-align: center; font-size: 20px; letter-spacing: 6px; font-weight: 700; color: #1e3a8a; }
        
        .btn-submit { width: 100%; padding: 11px; background: #2563eb; color: #fff; border: none; border-radius: 6px; font-size: 14px; font-weight: 600; cursor: pointer; transition: background 0.15s; margin-top: 6px; }
        .btn-submit:hover { background: #1d4ed8; }
        
        .resend-box { margin-top: 22px; text-align: center; font-size: 13px; color: #64748b; }
        .btn-resend { color: #2563eb; text-decoration: none; font-weight: 600; }
        .btn-resend.disabled { color: #94a3b8; pointer-events: none; cursor: default; }
        
        .extra-links { margin-top: 20px; text-align: center; font-size: 13px; }
        .extra-links a { color: #64748b; text-decoration: none; }
        .extra-links a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="auth-wrapper">
    <div class="box">
        <div class="brand-header">
            <div class="brand-title">Đặt Lại Mật Khẩu</div>
        </div>
        <p class="subtitle">
            Nhập mã OTP gửi tới email:<br/>
            <strong><c:out value="${email != null ? email : sessionScope.PENDING_RESET_EMAIL}" /></strong>
        </p>

        <c:if test="${message != null}">
            <div class="alert-success">${message}</div>
        </c:if>

        <c:if test="${alert != null}">
            <div class="alert-danger">${alert}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/reset-password" method="post">
            <div class="form-group">
                <label for="otp">Mã xác thực OTP (6 chữ số):</label>
                <input type="text" id="otp" name="otp" class="form-control otp-input" maxlength="6" pattern="[0-9]{6}" placeholder="------" required autofocus />
            </div>

            <div class="form-group">
                <label for="password">Mật khẩu mới:</label>
                <input type="password" id="password" name="password" class="form-control" maxlength="72" placeholder="Nhập mật khẩu mới" required />
            </div>

            <div class="form-group">
                <label for="confirmPassword">Xác nhận mật khẩu mới:</label>
                <input type="password" id="confirmPassword" name="confirmPassword" class="form-control" maxlength="72" placeholder="Nhập lại mật khẩu mới" required />
            </div>

            <button type="submit" class="btn-submit">Đổi mật khẩu</button>
        </form>

        <div class="resend-box">
            <span>Chưa nhận được mã? </span>
            <a id="resendBtn" href="${pageContext.request.contextPath}/resend-reset-otp" class="btn-resend disabled">
                Gửi lại mã (<span id="timer">60</span>s)
            </a>
        </div>

        <div class="extra-links">
            <a href="${pageContext.request.contextPath}/login">&larr; Quay lại trang đăng nhập</a>
        </div>
    </div>
    </div>

    <script>
        let timeLeft = 60;
        const timerElem = document.getElementById('timer');
        const resendBtn = document.getElementById('resendBtn');

        const countdown = setInterval(function() {
            timeLeft--;
            if (timeLeft <= 0) {
                clearInterval(countdown);
                resendBtn.classList.remove('disabled');
                resendBtn.innerHTML = 'Gửi lại mã OTP';
            } else {
                timerElem.textContent = timeLeft;
            }
        }, 1000);
    </script>
</body>
</html>