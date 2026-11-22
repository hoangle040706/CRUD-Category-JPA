<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="uri" value="${not empty requestScope['jakarta.servlet.forward.request_uri'] ? requestScope['jakarta.servlet.forward.request_uri'] : pageContext.request.requestURI}" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><sitemesh:write property="title"/></title>

    <!-- Bootstrap 5.3 CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">

    <style>
        :root {
            --primary-dark:  #1e3a8a;
            --primary:       #2563eb;
            --primary-mid:   #1d4ed8;
            --bg-light:      #f8fafc;
        }

        html, body {
            min-height: 100vh;
        }

        body {
            display: flex !important;
            flex-direction: column !important;
            min-height: 100vh !important;
            margin: 0 !important;
            padding: 0 !important;
            background-color: var(--bg-light) !important;
            color: #0f172a;
            font-family: 'Segoe UI', system-ui, -apple-system, BlinkMacSystemFont, Roboto, sans-serif;
        }

        main.site-main-content {
            flex: 1 0 auto;
            width: 100%;
            display: flex;
            flex-direction: column;
        }

        /* ───────── Navbar ───────── */
        .navbar-brand-custom {
            font-size: 18px;
            font-weight: 700;
            letter-spacing: -0.3px;
            color: #fff !important;
            white-space: nowrap;
        }
        .navbar-nav-custom .nav-link {
            color: #e0e7ff;
            font-size: 13.5px;
            font-weight: 500;
            border-radius: 6px;
            padding: 6px 11px;
            transition: background .15s, color .15s;
            white-space: nowrap;
        }
        .navbar-nav-custom .nav-link:hover,
        .navbar-nav-custom .nav-link.active {
            background: rgba(255,255,255,.18);
            color: #fff;
        }
        .nav-link-badge {
            border: 1px solid rgba(255,255,255,.35);
            background: rgba(255,255,255,.08);
        }
        .user-role-pill {
            background: rgba(255,255,255,.22);
            color: #fff;
            padding: 3px 9px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 600;
            white-space: nowrap;
        }
        .btn-nav-login {
            color: #e0e7ff;
            font-size: 13.5px;
            font-weight: 500;
            text-decoration: none;
            padding: 6px 12px;
            border-radius: 6px;
            transition: background .15s;
            white-space: nowrap;
        }
        .btn-nav-login:hover, .btn-nav-login.active {
            background: rgba(255,255,255,.14);
            color: #fff;
        }
        .btn-nav-register {
            background: #fff;
            color: #1d4ed8 !important;
            padding: 6px 14px;
            border-radius: 6px;
            font-size: 13.5px;
            font-weight: 600;
            text-decoration: none;
            transition: background .15s;
            white-space: nowrap;
        }
        .btn-nav-register:hover {
            background: #eff6ff;
            color: #1e3a8a !important;
        }
        .btn-logout-nav {
            background: #ef4444;
            color: #fff !important;
            padding: 6px 14px;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 600;
            text-decoration: none;
            transition: background .15s;
            white-space: nowrap;
        }
        .btn-logout-nav:hover { background: #dc2626; color: #fff; }

        /* ───────── Footer ───────── */
        footer {
            background: linear-gradient(135deg, var(--primary-dark) 0%, var(--primary-mid) 50%, var(--primary) 100%);
            color: #bfdbfe;
            font-size: 13px;
            width: 100%;
        }
        footer a { color: #bfdbfe; text-decoration: none; }
        footer a:hover { color: #fff; text-decoration: underline; }
        footer .footer-brand { color: #fff; font-weight: 700; font-size: 15px; }
        footer .divider { color: rgba(255,255,255,.3); margin: 0 8px; }
    </style>

    <!-- Page-specific head content -->
    <sitemesh:write property="head"/>
</head>
<body>

    <!-- ═══════════════════════════ NAVBAR ═══════════════════════════ -->
    <nav class="navbar sticky-top w-100"
         style="background: linear-gradient(135deg, #1e3a8a 0%, #1d4ed8 50%, #2563eb 100%);
                box-shadow: 0 2px 10px rgba(30,58,138,.15);">
        <div class="container-fluid px-4 d-flex align-items-center justify-content-between flex-nowrap"
             style="height:60px; gap:16px; overflow-x:auto; scrollbar-width:none;">

            <!-- Brand + Nav links -->
            <div class="d-flex align-items-center gap-3 flex-shrink-0 flex-nowrap">
                <a href="${pageContext.request.contextPath}/home" class="navbar-brand-custom text-decoration-none">
                    MyVideo Platform
                </a>
                <nav class="d-flex navbar-nav-custom gap-1 flex-nowrap">
                    <a href="${pageContext.request.contextPath}/home"
                       class="nav-link ${uri.endsWith('/home') || uri.endsWith('/') || uri.endsWith('/my-project') || uri.endsWith('/my-project/') ? 'active' : ''}">Trang chủ</a>
                    <a href="${pageContext.request.contextPath}/video"
                       class="nav-link ${uri.contains('/video') && !uri.contains('/upload') && param.filter != 'my' ? 'active' : ''}">Tất cả Video</a>
                    <a href="${pageContext.request.contextPath}/admin/category/list"
                       class="nav-link ${uri.contains('/category') ? 'active' : ''}">Danh mục</a>

                    <c:if test="${not empty sessionScope.account}">
                        <a href="${pageContext.request.contextPath}/video?filter=my"
                           class="nav-link ${uri.contains('/video') && param.filter == 'my' ? 'active' : ''}">Video của tôi</a>
                        <a href="${pageContext.request.contextPath}/video/upload"
                           class="nav-link ${uri.contains('/video/upload') ? 'active' : ''}">Đăng Video</a>
                    </c:if>

                    <%-- Admin links (roleid == 1) --%>
                    <c:if test="${sessionScope.account.roleid == 1}">
                        <a href="${pageContext.request.contextPath}/admin/home"
                           class="nav-link nav-link-badge ${uri.contains('/admin/home') ? 'active' : ''}">Quản trị Admin</a>
                        <a href="${pageContext.request.contextPath}/admin/videos"
                           class="nav-link nav-link-badge ${uri.contains('/admin/video') ? 'active' : ''}">Duyệt Video</a>
                    </c:if>

                    <%-- Manager links (roleid == 2) --%>
                    <c:if test="${sessionScope.account.roleid == 2}">
                        <a href="${pageContext.request.contextPath}/manager/home"
                           class="nav-link nav-link-badge ${uri.contains('/manager/home') ? 'active' : ''}">Bảng điều khiển Manager</a>
                    </c:if>
                </nav>
            </div>

            <!-- User area -->
            <div class="d-flex align-items-center gap-3 flex-shrink-0 flex-nowrap">
                <c:choose>
                    <c:when test="${sessionScope.account == null}">
                        <a href="${pageContext.request.contextPath}/login"
                           class="btn-nav-login ${uri.contains('/login') ? 'active' : ''}">Đăng nhập</a>
                        <a href="${pageContext.request.contextPath}/register"
                           class="btn-nav-register ${uri.contains('/register') ? 'active' : ''}">Đăng ký</a>
                    </c:when>
                    <c:otherwise>
                        <div class="d-flex align-items-center gap-2 flex-nowrap">
                            <a href="${pageContext.request.contextPath}/profile" class="d-flex align-items-center gap-2 text-decoration-none" title="Xem hồ sơ cá nhân">
                                <c:choose>
                                    <c:when test="${not empty sessionScope.account.avatar}">
                                        <c:choose>
                                            <c:when test="${sessionScope.account.avatar.startsWith('http')}">
                                                <img src="${sessionScope.account.avatar}" alt="Avatar" class="rounded-circle" style="width:34px; height:34px; object-fit:cover; border:2px solid rgba(255,255,255,.8);" />
                                            </c:when>
                                            <c:otherwise>
                                                <img src="${pageContext.request.contextPath}/image?type=avatar&fname=${sessionScope.account.avatar}" alt="Avatar" class="rounded-circle" style="width:34px; height:34px; object-fit:cover; border:2px solid rgba(255,255,255,.8);" />
                                            </c:otherwise>
                                        </c:choose>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="rounded-circle d-flex align-items-center justify-content-center bg-white text-primary fw-bold" style="width:34px; height:34px; font-size:14px; border:2px solid rgba(255,255,255,.8);">
                                            <c:out value="${sessionScope.account.username != null ? sessionScope.account.username.substring(0, 1).toUpperCase() : 'U'}" />
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                                <span style="color:#fff; font-weight:600; font-size:13.5px; white-space:nowrap;">
                                    <c:out value="${not empty sessionScope.account.fullname ? sessionScope.account.fullname : sessionScope.account.username}"/>
                                </span>
                            </a>
                            <span class="user-role-pill">
                                <c:choose>
                                    <c:when test="${sessionScope.account.roleid == 1}">Admin</c:when>
                                    <c:when test="${sessionScope.account.roleid == 2}">Manager</c:when>
                                    <c:otherwise>Thành viên</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        <a href="${pageContext.request.contextPath}/profile" class="btn-nav-login ${uri.contains('/profile') ? 'active' : ''}">Hồ sơ</a>
                        <a href="${pageContext.request.contextPath}/logout" class="btn-logout-nav">Đăng xuất</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </nav>

    <!-- ═══════════════════════════ PAGE BODY ═══════════════════════════ -->
    <main class="site-main-content">
        <sitemesh:write property="body"/>
    </main>

    <!-- ═══════════════════════════ FOOTER ═══════════════════════════ -->
    <footer class="mt-auto py-4">
        <div class="container text-center">
            <div class="mb-2">
                <span class="footer-brand">MyVideo Platform</span>
                <span class="divider">|</span>
                <span>HCMUTE – Khoa Công nghệ Thông tin</span>
            </div>
            <div>
                Môn học: <strong style="color:#fff;">Lập trình Web</strong>
                <span class="divider">·</span>
                Trường Đại học Sư phạm Kỹ thuật TP. Hồ Chí Minh
            </div>
            <div class="mt-2" style="color: rgba(191,219,254,.6); font-size:12px;">
                &copy; 2024 MyVideo. Sử dụng Bootstrap 5.3 &amp; SiteMesh 3.
            </div>
        </div>
    </footer>

    <!-- Bootstrap 5.3 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
