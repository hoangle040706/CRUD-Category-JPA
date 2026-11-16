<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xác Thực Mã OTP</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Arial, sans-serif; }
        body { background-color: #f4f6f9; display: flex; justify-content: center; align-items: center; min-height: 100vh; padding: 20px; }
        .box { background: #fff; padding: 35px 30px; border-radius: 8px; width: 100%; max-width: 440px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
        h2 { text-align: center; color: #2c3e50; margin-bottom: 15px; font-size: 24px; font-weight: 600; }
        .subtitle { text-align: center; color: #6c757d; font-size: 14px; margin-bottom: 25px; line-height: 1.5; }
        .alert-danger { background-color: #f8d7da; color: #721c24; padding: 10px 14px; border-radius: 4px; margin-bottom: 20px; font-size: 14px; border: 1px solid #f5c6cb; text-align: center; }
        .alert-success { background-color: #d4edda; color: #155724; padding: 10px 14px; border-radius: 4px; margin-bottom: 20px; font-size: 14px; border: 1px solid #c3e6cb; text-align: center; }
        .form-group { margin-bottom: 20px; text-align: center; }
        .otp-input { width: 100%; padding: 12px 15px; font-size: 24px; text-align: center; letter-spacing: 8px; font-weight: bold; border: 2px solid #ced4da; border-radius: 6px; }
        .otp-input:focus { outline: none; border-color: #28a745; box-shadow: 0 0 0 3px rgba(40,167,69,0.15); }
        .btn-submit { width: 100%; padding: 12px; background: #28a745; color: #fff; border: none; border-radius: 4px; font-size: 15px; font-weight: bold; cursor: pointer; transition: 0.2s; }
        .btn-submit:hover { background: #218838; }
        .resend-box { margin-top: 25px; text-align: center; font-size: 14px; color: #6c757d; }
        .btn-resend { color: #007bff; text-decoration: none; font-weight: 600; }
        .btn-resend.disabled { color: #aaa; pointer-events: none; cursor: default; }
        .extra-links { margin-top: 20px; text-align: center; font-size: 14px; }
        .extra-links a { color: #6c757d; text-decoration: none; }
        .extra-links a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="box">
        <h2>Xác Thực Tài Khoản</h2>
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
