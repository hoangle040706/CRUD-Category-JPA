<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Hồ sơ cá nhân - MyVideo Platform</title>
</head>
<body>
<div class="container py-4" style="max-width: 800px;">
    <!-- Tiêu đề trang -->
    <div class="d-flex align-items-center justify-content-between mb-4 border-bottom pb-3">
        <div>
            <h3 class="fw-bold mb-1" style="color: #1e3a8a;">Hồ sơ cá nhân</h3>
            <p class="text-muted mb-0">Quản lý và cập nhật thông tin tài khoản của bạn</p>
        </div>
        <a href="${pageContext.request.contextPath}/home" class="btn btn-outline-secondary btn-sm">Quay lại Trang chủ</a>
    </div>

    <!-- Thông báo lỗi / thành công -->
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show shadow-sm" role="alert">
            <strong>Lỗi:</strong> <c:out value="${errorMessage}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>
    <c:if test="${not empty successMessage}">
        <div class="alert alert-success alert-dismissible fade show shadow-sm" role="alert">
            <strong>Thành công:</strong> <c:out value="${successMessage}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <!-- Cảnh báo nếu có OTP đổi email đang chờ xác thực -->
    <c:if test="${not empty sessionScope.PENDING_EMAIL_UPDATE}">
        <div class="alert alert-warning d-flex align-items-center justify-content-between shadow-sm mb-4">
            <div>
                <strong>Lưu ý:</strong> Bạn đang có yêu cầu đổi email sang <strong><c:out value="${sessionScope.PENDING_EMAIL_UPDATE.newEmail}"/></strong> chưa xác thực.
            </div>
            <div class="d-flex gap-2">
                <a href="${pageContext.request.contextPath}/profile/verify-otp" class="btn btn-sm btn-primary">Xác thực OTP</a>
                <form action="${pageContext.request.contextPath}/profile/cancel-otp" method="post" class="d-inline m-0">
                    <input type="hidden" name="csrfToken" value="${sessionScope.CSRF_TOKEN}">
                    <button type="submit" class="btn btn-sm btn-outline-danger">Hủy yêu cầu</button>
                </form>
            </div>
        </div>
    </c:if>

    <!-- Thẻ Form thông tin cá nhân -->
    <div class="card shadow-sm border-0 rounded-3">
        <div class="card-body p-4">
            <form action="${pageContext.request.contextPath}/profile" method="post" enctype="multipart/form-data" class="needs-validation" novalidate>
                <input type="hidden" name="csrfToken" value="${sessionScope.CSRF_TOKEN}">

                <!-- Khu vực Avatar -->
                <div class="text-center mb-4">
                    <div class="position-relative d-inline-block">
                        <c:choose>
                            <c:when test="${not empty user.avatar}">
                                <c:choose>
                                    <c:when test="${user.avatar.startsWith('http')}">
                                        <img id="avatarPreview" src="${user.avatar}" alt="Avatar" class="rounded-circle shadow-sm border border-3 border-primary" style="width: 120px; height: 120px; object-fit: cover;">
                                    </c:when>
                                    <c:otherwise>
                                        <img id="avatarPreview" src="${pageContext.request.contextPath}/image?type=avatar&fname=${user.avatar}" alt="Avatar" class="rounded-circle shadow-sm border border-3 border-primary" style="width: 120px; height: 120px; object-fit: cover;">
                                    </c:otherwise>
                                </c:choose>
                            </c:when>
                            <c:otherwise>
                                <img id="avatarPreview" src="https://ui-avatars.com/api/?name=${user.username}&background=2563eb&color=fff&size=120" alt="Avatar" class="rounded-circle shadow-sm border border-3 border-primary" style="width: 120px; height: 120px; object-fit: cover;">
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="mt-3">
                        <label for="avatarInput" class="btn btn-sm btn-outline-primary px-3">
                            Chọn ảnh đại diện mới
                        </label>
                        <input type="file" id="avatarInput" name="image" class="d-none" accept=".jpg,.jpeg,.png,.webp">
                        <div class="form-text text-muted">Hỗ trợ JPG, PNG, WebP (Tối đa 5MB)</div>
                    </div>
                </div>

                <div class="row g-3">
                    <!-- Tên tài khoản (Readonly) -->
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Tên tài khoản</label>
                        <input type="text" class="form-control bg-light" value="<c:out value="${user.username}"/>" readonly disabled>
                        <div class="form-text">Tên đăng nhập không thể thay đổi</div>
                    </div>

                    <!-- Vai trò (Readonly) -->
                    <div class="col-md-6">
                        <label class="form-label fw-semibold">Vai trò</label>
                        <input type="text" class="form-control bg-light" value="<c:choose><c:when test="${user.roleid == 1}">Quản trị viên (Admin)</c:when><c:when test="${user.roleid == 2}">Quản lý (Manager)</c:when><c:otherwise>Thành viên</c:otherwise></c:choose>" readonly disabled>
                        <div class="form-text">Phân quyền hệ thống</div>
                    </div>

                    <!-- Họ và tên -->
                    <div class="col-md-6">
                        <label for="fullname" class="form-label fw-semibold">Họ và tên <span class="text-danger">*</span></label>
                        <input type="text" id="fullname" name="fullname" class="form-control" required maxlength="100" value="<c:out value="${user.fullname}"/>">
                        <div class="invalid-feedback">Vui lòng nhập họ và tên (tối đa 100 ký tự).</div>
                    </div>

                    <!-- Số điện thoại -->
                    <div class="col-md-6">
                        <label for="phone" class="form-label fw-semibold">Số điện thoại <span class="text-danger">*</span></label>
                        <input type="tel" id="phone" name="phone" class="form-control" required pattern="^0[3-9][0-9]{8}$" placeholder="0912345678" value="<c:out value="${user.phone}"/>">
                        <div class="invalid-feedback">Vui lòng nhập số điện thoại Việt Nam gồm 10 chữ số (bắt đầu bằng 03, 05, 07, 08, 09).</div>
                    </div>

                    <!-- Địa chỉ Email -->
                    <div class="col-12">
                        <label for="email" class="form-label fw-semibold">Địa chỉ Email <span class="text-danger">*</span></label>
                        <input type="email" id="email" name="email" class="form-control" required value="<c:out value="${user.email}"/>">
                        <div class="form-text text-muted">Nếu bạn đổi sang email mới, hệ thống sẽ gửi mã OTP để xác thực trước khi cập nhật chính thức.</div>
                    </div>

                    <!-- Xác nhận Mật khẩu hiện tại (Chỉ khi đổi email) -->
                    <div class="col-12">
                        <div class="p-3 bg-light rounded-3 border">
                            <label for="currentPassword" class="form-label fw-semibold mb-1">Mật khẩu hiện tại</label>
                            <input type="password" id="currentPassword" name="currentPassword" class="form-control bg-white" placeholder="Chỉ bắt buộc nhập khi bạn thay đổi địa chỉ Email">
                            <div class="form-text text-muted">Bảo mật tài khoản: Nhập mật khẩu hiện tại để xác thực thao tác đổi địa chỉ email. Nhập sai 5 lần sẽ tạm khóa 15 phút.</div>
                        </div>
                    </div>
                </div>

                <div class="d-flex justify-content-end gap-2 mt-4 pt-3 border-top">
                    <a href="${pageContext.request.contextPath}/home" class="btn btn-secondary px-3">Hủy bỏ</a>
                    <button type="submit" class="btn btn-primary px-4 fw-semibold" style="background-color: #2563eb; border-color: #2563eb;">Lưu thay đổi</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    // Preview avatar tức thì khi người dùng chọn file
    const avatarInput = document.getElementById('avatarInput');
    const avatarPreview = document.getElementById('avatarPreview');

    if (avatarInput && avatarPreview) {
        avatarInput.addEventListener('change', function(e) {
            const file = e.target.files[0];
            if (file) {
                if (file.size > 5 * 1024 * 1024) {
                    alert('Kích thước ảnh vượt quá giới hạn 5MB!');
                    avatarInput.value = '';
                    return;
                }
                avatarPreview.src = URL.createObjectURL(file);
            }
        });
    }

    // Client-side validation Bootstrap 5
    (function () {
        'use strict'
        var forms = document.querySelectorAll('.needs-validation')
        Array.prototype.slice.call(forms).forEach(function (form) {
            form.addEventListener('submit', function (event) {
                if (!form.checkValidity()) {
                    event.preventDefault()
                    event.stopPropagation()
                }
                form.classList.add('was-validated')
            }, false)
        })
    })()
</script>
</body>
</html>
