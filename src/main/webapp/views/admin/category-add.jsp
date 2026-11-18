<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thêm Danh Mục Mới - Admin Dashboard</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', system-ui, -apple-system, BlinkMacSystemFont, Roboto, sans-serif; }
        body { background-color: #f8fafc; color: #0f172a; line-height: 1.5; }

        /* Unified Topbar - Clean, No-wrap, Single-line */
        .topbar { background: linear-gradient(135deg, #1e3a8a 0%, #1d4ed8 50%, #2563eb 100%); color: #fff; box-shadow: 0 2px 10px rgba(30, 58, 138, 0.15); position: sticky; top: 0; z-index: 100; width: 100%; }
        .topbar-container { max-width: 100%; margin: 0 auto; padding: 0 24px; height: 60px; display: flex; justify-content: space-between; align-items: center; gap: 16px; overflow-x: auto; scrollbar-width: none; }
        .topbar-container::-webkit-scrollbar { display: none; }
        .nav-brand-group { display: flex; align-items: center; gap: 18px; flex-shrink: 0; white-space: nowrap; }
        .brand-logo { color: #ffffff; font-size: 18px; font-weight: 700; text-decoration: none; letter-spacing: -0.3px; white-space: nowrap; flex-shrink: 0; }
        .nav-subtitle { color: #bfdbfe; font-size: 13px; font-weight: 500; padding-left: 14px; border-left: 1px solid rgba(255, 255, 255, 0.25); white-space: nowrap; }
        .nav-menu { display: flex; gap: 4px; align-items: center; flex-wrap: nowrap; white-space: nowrap; }
        .nav-link { color: #e0e7ff; text-decoration: none; font-size: 13.5px; font-weight: 500; padding: 6px 11px; border-radius: 6px; white-space: nowrap; display: inline-flex; align-items: center; transition: all 0.15s ease; flex-shrink: 0; }
        .nav-link:hover { background: rgba(255, 255, 255, 0.14); color: #ffffff; }
        .nav-link.active { background: rgba(255, 255, 255, 0.22); color: #ffffff; font-weight: 600; }
        .nav-link-badge { border: 1px solid rgba(255, 255, 255, 0.35); background: rgba(255, 255, 255, 0.08); }
        .nav-user-group { display: flex; align-items: center; gap: 12px; flex-shrink: 0; white-space: nowrap; }
        .user-greeting { display: flex; align-items: center; gap: 8px; white-space: nowrap; flex-shrink: 0; }
        .user-name { color: #ffffff; font-weight: 600; font-size: 13.5px; white-space: nowrap; }
        .user-role-pill { background: rgba(255, 255, 255, 0.22); color: #ffffff; padding: 3px 9px; border-radius: 12px; font-size: 11px; font-weight: 600; white-space: nowrap; display: inline-block; }
        .btn-nav { color: #ffffff; text-decoration: none; padding: 6px 12px; font-weight: 600; font-size: 13.5px; border-radius: 6px; transition: all 0.15s; white-space: nowrap; display: inline-flex; align-items: center; flex-shrink: 0; }
        .btn-nav:hover { background: rgba(255, 255, 255, 0.14); }
        .btn-nav-primary { background: #ffffff; color: #1d4ed8; }
        .btn-nav-primary:hover { background: #eff6ff; color: #1e3a8a; }
        .btn-logout { background: #ef4444; color: #ffffff; padding: 6px 14px; border-radius: 6px; font-size: 13px; font-weight: 600; text-decoration: none; transition: background 0.15s; white-space: nowrap; display: inline-flex; align-items: center; flex-shrink: 0; }
        .btn-logout:hover { background: #dc2626; }

        /* Main Container */
        .main-container { display: flex; min-height: calc(100vh - 60px); }
        .sidebar { width: 250px; background: #0f172a; color: #94a3b8; padding: 20px 0; flex-shrink: 0; display: flex; flex-direction: column; }
        .user-panel { padding: 15px 20px; display: flex; align-items: center; border-bottom: 1px solid #1e293b; margin-bottom: 15px; }
        .user-panel img { width: 44px; height: 44px; border-radius: 50%; object-fit: cover; margin-right: 12px; border: 2px solid #3b82f6; }
        .online-dot { display: inline-block; width: 8px; height: 8px; border-radius: 50%; background: #10b981; margin-right: 4px; }
        .user-role-text { font-size: 12px; color: #93c5fd; display: flex; align-items: center; margin-top: 3px; }

        .sidebar-menu { list-style: none; }
        .sidebar-menu li a { display: block; padding: 12px 22px; color: #94a3b8; text-decoration: none; font-size: 14px; font-weight: 500; transition: all 0.15s ease; border-left: 4px solid transparent; }
        .sidebar-menu li a:hover { background: #1e293b; color: #60a5fa; }
        .sidebar-menu li.active a { background: #2563eb; color: #ffffff; font-weight: 600; border-left-color: #93c5fd; }

        /* Content Area */
        .content { flex-grow: 1; padding: 30px; background-color: #f8fafc; }
        .card { max-width: 680px; background: #fff; border-radius: 12px; padding: 32px; border: 1px solid #e2e8f0; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); }
        .card h2 { font-size: 18px; color: #1e3a8a; font-weight: 700; margin-bottom: 22px; border-bottom: 2px solid #eff6ff; padding-bottom: 12px; }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 7px; font-weight: 600; font-size: 14px; color: #334155; }
        input[type="text"], input[type="file"] { width: 100%; padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; outline: none; transition: all 0.15s; color: #0f172a; background: #ffffff; }
        input[type="text"]:focus { border-color: #2563eb; box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.18); }
        .radio-group { display: flex; gap: 24px; align-items: center; padding: 6px 0; }
        .radio-label { display: flex; align-items: center; gap: 8px; font-weight: normal; cursor: pointer; font-size: 14px; color: #334155; }
        .btn-group { display: flex; gap: 12px; margin-top: 28px; }
        .btn { padding: 10px 22px; border-radius: 6px; font-weight: 600; font-size: 14px; cursor: pointer; border: none; text-decoration: none; transition: all 0.15s; }
        .btn-primary { background: #2563eb; color: #fff; }
        .btn-primary:hover { background: #1d4ed8; }
        .btn-secondary { background: #64748b; color: #fff; }
        .btn-secondary:hover { background: #475569; }
    </style>
</head>
<body>
    <header class="topbar">
        <div class="topbar-container">
            <div class="nav-brand-group">
                <a href="${pageContext.request.contextPath}/home" class="brand-logo">MyVideo Platform</a>
                <span class="nav-subtitle">Quản Trị Danh Mục - Thêm Mới</span>
            </div>
            <div class="nav-user-group">
                <div class="user-greeting">
                    <span class="user-name"><c:out value="${sessionScope.account != null ? sessionScope.account.username : 'Admin'}" /></span>
                    <span class="user-role-pill">Admin</span>
                </div>
                <a href="<c:url value='/logout' />" class="btn-logout">Đăng xuất</a>
            </div>
        </div>
    </header>

    <div class="main-container">
        <aside class="sidebar">
            <div class="user-panel">
                <c:url value="/image?fname=${sessionScope.account != null && not empty sessionScope.account.avatar ? sessionScope.account.avatar : 'admin.png'}" var="userAvatar" />
                <img src="${userAvatar}" alt="Admin Avatar">
                <div>
                    <div style="font-size: 14px; font-weight: 600; color: #ffffff;"><c:out value="${sessionScope.account != null ? sessionScope.account.userName : 'admin'}" /></div>
                    <div class="user-role-text"><span class="online-dot"></span> Trực tuyến</div>
                </div>
            </div>
            <ul class="sidebar-menu">
                <li><a href="${pageContext.request.contextPath}/admin/home">Tổng quan Dashboard</a></li>
                <li><a href="${pageContext.request.contextPath}/admin/videos">Quản lý Video</a></li>
                <li class="active"><a href="${pageContext.request.contextPath}/admin/category/list">Quản lý Danh mục</a></li>
                <li><a href="${pageContext.request.contextPath}/video">Kho Video người dùng</a></li>
                <li><a href="${pageContext.request.contextPath}/home">Trang chủ Web</a></li>
            </ul>
        </aside>

        <main class="content">
            <div class="card">
                <h2>Thêm Danh Mục Sản Phẩm Mới</h2>
                <form action="<c:url value='/admin/category/insert'/>" method="post" enctype="multipart/form-data">
                    <div class="form-group">
                        <label for="categoryname">Tên Danh Mục <span style="color:#ef4444;">*</span></label>
                        <input type="text" id="categoryname" name="categoryname" required placeholder="Nhập tên danh mục..." />
                    </div>

                    <div class="form-group">
                        <label for="images">Đường dẫn ảnh Online (URL):</label>
                        <input type="text" id="images" name="images" placeholder="https://example.com/image.jpg" />
                    </div>

                    <div class="form-group">
                        <label for="images1">Hoặc tải file ảnh lên:</label>
                        <input type="file" id="images1" name="images1" accept="image/*" />
                    </div>

                    <div class="form-group">
                        <label>Trạng thái:</label>
                        <div class="radio-group">
                            <label class="radio-label"><input type="radio" id="ston" name="status" value="1" checked /> Hoạt động</label>
                            <label class="radio-label"><input type="radio" id="stoff" name="status" value="0" /> Khóa</label>
                        </div>
                    </div>

                    <div class="btn-group">
                        <button type="submit" class="btn btn-primary">Lưu Danh Mục</button>
                        <a href="<c:url value='/admin/category/list'/>" class="btn btn-secondary">Hủy bỏ</a>
                    </div>
                </form>
            </div>
        </main>
    </div>
</body>
</html>