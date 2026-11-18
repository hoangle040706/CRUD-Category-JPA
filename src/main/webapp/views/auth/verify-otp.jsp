<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xác Thực Mã OTP - MyVideo Platform</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', system-ui, -apple-system, BlinkMacSystemFont, Roboto, sans-serif; }
        body { background-color: #f8fafc; color: #0f172a; display: flex; justify-content: center; align-items: center; min-height: 100vh; padding: 20px; }
        .box { background: #fff; padding: 36px 32px; border-radius: 12px; width: 100%; max-width: 440px; border: 1px solid #e2e8f0; box-shadow: 0 10px 25px -5px rgba(37, 99, 235, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.05); }
        .brand-header { text-align: center; margin-bottom: 15px; }
        .brand-title { color: #1e3a8a; font-size: 20px; font-weight: 700; letter-spacing: -0.3px; }
        .subtitle { text-align: center; color: #64748b; font-size: 13px; margin-bottom: 24px; line-height: 1.5; }
        
        .alert-danger { background-color: #fef2f2; color: #991b1b; padding: 11px 14px; border-radius: 6px; margin-bottom: 20px; font-size: 13px; border: 1px solid #fecaca; text-align: center; }
        .alert-success { background-color: #ecfdf5; color: #047857; padding: 11px 14px; border-radius: 6px; margin-bottom: 20px; font-size: 13px; border: 1px solid #a7f3d0; text-align: center; }
        
        .form-group { margin-bottom: 22px; text-align: center; }
        .otp-input { width: 100%; padding: 12px 15px; font-size: 24px; text-align: center; letter-spacing: 8px; font-weight: 700; border: 2px solid #cbd5e1; border-radius: 8px; outline: none; transition: all 0.15s; color: #1e3a8a; }
        .otp-input:focus { border-color: #2563eb; box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.18); }
        
        .btn-submit { width: 100%; padding: 11px; background: #2563eb; color: #fff; border: none; border-radius: 6px; font-size: 14px; font-weight: 600; cursor: pointer; transition: background 0.15s; }
        .btn-submit:hover { background: #1d4ed8; }
        
        .resend-box { margin-top: 24px; text-align: center; font-size: 13px; color: #64748b; }
        .btn-resend { color: #2563eb; text-decoration: none; font-weight: 600; }
        .btn-resend.disabled { color: #94a3b8; pointer-events: none; cursor: default; }
        
        .extra-links { margin-top: 20px; text-align: center; font-size: 13px; }
        .extra-links a { color: #64748b; text-decoration: none; }
        .extra-links a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="box">
        <div class="brand-header">
            <div class="brand-title">Xác Thực Tài Khoản</div>
        </div>
        <p class="subtitle">
            Mã OTP gồm 6 chữ số đã được gửi tới email:<br/>
            <strong><c:out value="${email != null ? email : sessionScope.PENDING_REGISTER_EMAIL}" /></strong>
        </p>

        <c:if test="${message != null}">
            <div class="alert-success">${message}</div>
        </c:if>

        <c:if test="${alert != null}">
            <div class="alert-danger">${alert}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/verify-otp" method="post">
            <div class="form-group">
                <input type="text" name="otp" class="otp-input" maxlength="6" pattern="[0-9]{6}" placeholder="------" required autofocus />
            </div>

            <button type="submit" class="btn-submit">Xác nhận kích hoạt</button>
        </form>

        <div class="resend-box">
            <span>Chưa nhận được mã? </span>
            <a id="resendBtn" href="${pageContext.request.contextPath}/resend-otp" class="btn-resend disabled">
                Gửi lại mã (<span id="timer">60</span>s)
            </a>
        </div>

        <div class="extra-links">
            <a href="${pageContext.request.contextPath}/login">&larr; Quay lại trang đăng nhập</a>
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