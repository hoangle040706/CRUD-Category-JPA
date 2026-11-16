<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thiết Lập Lại Mật Khẩu</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Arial, sans-serif; }
        body { background-color: #f4f6f9; display: flex; justify-content: center; align-items: center; min-height: 100vh; padding: 20px; }
        .box { background: #fff; padding: 35px 30px; border-radius: 8px; width: 100%; max-width: 440px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
        h2 { text-align: center; color: #2c3e50; margin-bottom: 12px; font-size: 24px; font-weight: 600; }
        .subtitle { text-align: center; color: #6c757d; font-size: 14px; margin-bottom: 25px; line-height: 1.5; }
        .alert-danger { background-color: #f8d7da; color: #721c24; padding: 10px 14px; border-radius: 4px; margin-bottom: 20px; font-size: 14px; border: 1px solid #f5c6cb; text-align: center; }
        .alert-success { background-color: #d4edda; color: #155724; padding: 10px 14px; border-radius: 4px; margin-bottom: 20px; font-size: 14px; border: 1px solid #c3e6cb; text-align: center; }
        .form-group { margin-bottom: 18px; }
        label { display: block; margin-bottom: 6px; font-weight: 600; color: #495057; font-size: 14px; }
        .form-control { width: 100%; padding: 11px 13px; border: 1px solid #ced4da; border-radius: 4px; font-size: 14px; }
        .form-control:focus { outline: none; border-color: #007bff; box-shadow: 0 0 0 3px rgba(0,123,255,0.15); }
        .otp-input { text-align: center; font-size: 20px; letter-spacing: 6px; font-weight: bold; }
        .btn-submit { width: 100%; padding: 12px; background: #007bff; color: #fff; border: none; border-radius: 4px; font-size: 15px; font-weight: bold; cursor: pointer; transition: 0.2s; margin-top: 6px; }
        .btn-submit:hover { background: #0056b3; }
        .resend-box { margin-top: 20px; text-align: center; font-size: 14px; color: #6c757d; }
        .btn-resend { color: #007bff; text-decoration: none; font-weight: 600; }
        .btn-resend.disabled { color: #aaa; pointer-events: none; cursor: default; }
        .extra-links { margin-top: 20px; text-align: center; font-size: 14px; }
        .extra-links a { color: #6c757d; text-decoration: none; }
        .extra-links a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="box">
        <h2>Đặt Lại Mật Khẩu</h2>
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
