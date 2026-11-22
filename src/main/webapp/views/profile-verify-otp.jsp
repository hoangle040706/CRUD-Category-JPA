<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Xác thực OTP đổi Email - MyVideo Platform</title>
</head>
<body>
<div class="container py-5" style="max-width: 520px;">
    <!-- Thông báo lỗi / thành công -->
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show shadow-sm mb-3" role="alert">
            <strong>Lỗi:</strong> <c:out value="${errorMessage}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${not empty successMessage}">
        <div class="alert alert-success alert-dismissible fade show shadow-sm mb-3" role="alert">
            <strong>Thành công:</strong> <c:out value="${successMessage}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <div class="card shadow border-0 rounded-4">
        <div class="card-body p-4 text-center">
            <!-- Icon bảo mật -->
            <div class="rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width: 64px; height: 64px; background-color: #eff6ff; color: #2563eb;">
                <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="currentColor" class="bi bi-shield-lock" viewBox="0 0 16 16">
                    <path d="M5.338 1.59a61.44 61.44 0 0 0-2.837.856.481.481 0 0 0-.328.39c-.554 4.157.726 7.19 2.253 9.188a10.725 10.725 0 0 0 2.287 2.233c.346.244.652.42.893.533.12.057.218.095.293.118a.55.55 0 0 0 .101.025.615.615 0 0 0 .1-.025c.076-.023.174-.061.294-.118.24-.113.547-.29.893-.533a10.726 10.726 0 0 0 2.287-2.233c1.527-1.997 2.807-5.031 2.253-9.188a.48.48 0 0 0-.328-.39c-.651-.213-1.75-.56-2.837-.855C9.552 1.29 8.531 1.067 8 1.067c-.53 0-1.552.223-2.662.524zM5.072.56C6.157.265 7.31 0 8 0s1.843.265 2.928.56c1.11.3 2.229.655 2.887.87a1.54 1.54 0 0 1 1.044 1.262c.599 4.497-.84 7.75-2.484 9.895a12.24 12.24 0 0 1-2.624 2.56c-.4.282-.78.502-1.111.65-.17.076-.32.14-.443.18-.063.02-.124.037-.179.05a1.88 1.88 0 0 1-.274.025h-.002a1.88 1.88 0 0 1-.274-.025c-.055-.013-.116-.03-.179-.05a5.534 5.534 0 0 1-.443-.18c-.33-.148-.71-.368-1.111-.65a12.24 12.24 0 0 1-2.624-2.56C3.076 10.465 1.637 7.213 2.236 2.716A1.54 1.54 0 0 1 3.28 1.455c.658-.215 1.777-.57 2.887-.876z"/>
                    <path d="M9.5 6.5a1.5 1.5 0 0 1-1 1.415l.385 1.99a.5.5 0 0 1-.491.595h-.788a.5.5 0 0 1-.49-.595l.384-1.99A1.5 1.5 0 1 1 9.5 6.5z"/>
                </svg>
            </div>

            <h4 class="fw-bold mb-2" style="color: #1e3a8a;">Xác thực thay đổi Email</h4>
            <p class="text-muted mb-3" style="font-size: 14px;">
                Mã OTP 6 chữ số đã được gửi tới địa chỉ email mới:<br>
                <strong class="text-primary" style="font-size: 15px;"><c:out value="${pending.newEmail}"/></strong>
            </p>
            <p class="text-muted small mb-4">Mã có hiệu lực trong vòng <strong>5 phút</strong>. Bạn có tối đa 5 lần nhập.</p>

            <!-- Form nhập OTP -->
            <form action="${pageContext.request.contextPath}/profile/verify-otp" method="post" class="mb-3">
                <input type="hidden" name="csrfToken" value="${sessionScope.CSRF_TOKEN}">
                <div class="mb-3">
                    <input type="text" name="otp" class="form-control form-control-lg text-center fw-bold"
                           maxlength="6" pattern="[0-9]{6}" inputmode="numeric" placeholder="------"
                           style="letter-spacing: 8px; font-size: 26px;" required autofocus autocomplete="one-time-code">
                </div>
                <button type="submit" class="btn btn-primary w-100 py-2 fw-semibold shadow-sm" style="background-color: #2563eb; border-color: #2563eb;">
                    Xác nhận đổi Email
                </button>
            </form>

            <!-- Form Gửi lại mã OTP (Có cooldown 60s) -->
            <form action="${pageContext.request.contextPath}/profile/resend-otp" method="post" class="mb-2">
                <input type="hidden" name="csrfToken" value="${sessionScope.CSRF_TOKEN}">
                <button type="submit" id="btnResend" class="btn btn-outline-secondary w-100 py-2 btn-sm fw-medium">
                    Gửi lại mã OTP (<span id="countdown">60</span>s)
                </button>
            </form>

            <!-- Form Hủy đổi email -->
            <form action="${pageContext.request.contextPath}/profile/cancel-otp" method="post" class="m-0">
                <input type="hidden" name="csrfToken" value="${sessionScope.CSRF_TOKEN}">
                <button type="submit" class="btn btn-link text-decoration-none text-danger small p-0 mt-2">
                    Hủy yêu cầu đổi email và quay lại
                </button>
            </form>
        </div>
    </div>
</div>

<script>
    (function() {
        const lastSent = ${pending.lastSentAtMillis};
        const now = Date.now();
        const elapsed = Math.floor((now - lastSent) / 1000);
        let remaining = Math.max(0, 60 - elapsed);

        const btn = document.getElementById('btnResend');
        const countSpan = document.getElementById('countdown');

        function updateTimer() {
            if (remaining > 0) {
                btn.disabled = true;
                if (countSpan) countSpan.textContent = remaining;
                remaining--;
                setTimeout(updateTimer, 1000);
            } else {
                btn.disabled = false;
                btn.textContent = 'Gửi lại mã OTP';
            }
        }
        updateTimer();
    })();
</script>
</body>
</html>
