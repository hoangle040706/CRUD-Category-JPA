<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang Quản Lý - Manager Dashboard</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', system-ui, -apple-system, BlinkMacSystemFont, Roboto, sans-serif; }
        body { background-color: #f8fafc; color: #0f172a; line-height: 1.5; }

        /* Unified Topbar */
        .topbar { background: linear-gradient(135deg, #1e3a8a 0%, #1d4ed8 50%, #2563eb 100%); color: #fff; box-shadow: 0 2px 10px rgba(30, 58, 138, 0.15); position: sticky; top: 0; z-index: 100; }
        .topbar-container { max-width: 100%; margin: 0 auto; padding: 0 25px; height: 60px; display: flex; justify-content: space-between; align-items: center; }
        .nav-brand-group { display: flex; align-items: center; gap: 28px; }
        .brand-logo { color: #ffffff; font-size: 18px; font-weight: 700; text-decoration: none; letter-spacing: -0.3px; }
        .nav-subtitle { color: #bfdbfe; font-size: 13px; font-weight: 500; padding-left: 15px; border-left: 1px solid rgba(255, 255, 255, 0.25); }

        .nav-user-group { display: flex; align-items: center; gap: 14px; }
        .user-greeting { display: flex; align-items: center; gap: 8px; }
        .user-name { color: #ffffff; font-weight: 600; font-size: 14px; }
        .user-role-pill { background: rgba(255, 255, 255, 0.2); color: #ffffff; padding: 2px 8px; border-radius: 12px; font-size: 11px; font-weight: 600; }
        .btn-logout { background: rgba(239, 68, 68, 0.9); color: #ffffff; padding: 6px 14px; border-radius: 6px; font-size: 13px; font-weight: 600; text-decoration: none; transition: background 0.15s; }
        .btn-logout:hover { background: #dc2626; }

        /* Main Container */
        .main-container { display: flex; min-height: calc(100vh - 60px); }
        .sidebar { width: 250px; background: #0f172a; color: #94a3b8; padding: 20px 0; flex-shrink: 0; display: flex; flex-direction: column; }
        .user-panel { padding: 15px 20px; display: flex; align-items: center; border-bottom: 1px solid #1e293b; margin-bottom: 15px; }
        .user-panel img { width: 44px; height: 44px; border-radius: 50%; object-fit: cover; margin-right: 12px; border: 2px solid #3b82f6; }
        .online-dot { display: inline-block; width: 8px; height: 8px; border-radius: 50%; background: #f59e0b; margin-right: 4px; }
        .user-role-text { font-size: 12px; color: #fed7aa; display: flex; align-items: center; margin-top: 3px; }

        .sidebar-menu { list-style: none; }
        .sidebar-menu li a { display: block; padding: 12px 22px; color: #94a3b8; text-decoration: none; font-size: 14px; font-weight: 500; transition: all 0.15s ease; border-left: 4px solid transparent; }
        .sidebar-menu li a:hover { background: #1e293b; color: #60a5fa; }
        .sidebar-menu li.active a { background: #2563eb; color: #ffffff; font-weight: 600; border-left-color: #93c5fd; }

        /* Content */
        .content { flex-grow: 1; padding: 30px; background-color: #f8fafc; }
        .welcome-card { background: #ffffff; border-radius: 12px; padding: 30px; border: 1px solid #e2e8f0; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); margin-bottom: 28px; }
        .welcome-card h1 { font-size: 22px; color: #1e3a8a; font-weight: 700; margin-bottom: 8px; letter-spacing: -0.3px; }
        .welcome-card p { color: #475569; font-size: 14px; line-height: 1.6; }
        .btn-group-welcome { display: flex; gap: 12px; margin-top: 20px; flex-wrap: wrap; }
        .btn { display: inline-flex; align-items: center; padding: 9px 18px; color: #fff; text-decoration: none; border-radius: 6px; font-weight: 600; font-size: 13px; transition: all 0.15s; }
        .btn-primary { background: #2563eb; }
        .btn-primary:hover { background: #1d4ed8; }
        .btn-secondary { background: #475569; }
        .btn-secondary:hover { background: #334155; }
        .btn-outline { background: #eff6ff; color: #1d4ed8; border: 1px solid #bfdbfe; }
        .btn-outline:hover { background: #dbeafe; color: #1e3a8a; }

        /* Stat Grid */
        .stat-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; }
        .stat-card { background: #ffffff; padding: 22px; border-radius: 10px; border: 1px solid #e2e8f0; box-shadow: 0 2px 4px rgba(0,0,0,0.04); border-left: 4px solid #2563eb; display: flex; flex-direction: column; }
        .stat-card.accent-emerald { border-left-color: #059669; }
        .stat-card.accent-amber { border-left-color: #d97706; }
        .stat-card h3 { font-size: 16px; color: #1e3a8a; margin-bottom: 8px; font-weight: 700; }
        .stat-card p { color: #64748b; font-size: 13px; line-height: 1.5; margin-bottom: 14px; flex-grow: 1; }
        .stat-card a { font-size: 13px; color: #2563eb; text-decoration: none; font-weight: 600; }
        .stat-card a:hover { color: #1d4ed8; text-decoration: underline; }
    </style>
</head>
<body>
    <header class="topbar">
        <div class="topbar-container">
            <div class="nav-brand-group">
                <a href="${pageContext.request.contextPath}/home" class="brand-logo">MyVideo Platform</a>
                <span class="nav-subtitle">Khu Vực Quản Lý (Manager)</span>
            </div>
            <div class="nav-user-group">
                <div class="user-greeting">
                    <span class="user-name"><c:out value="${sessionScope.account != null ? sessionScope.account.fullName : 'Manager'}" /></span>
                    <span class="user-role-pill">Manager</span>
                </div>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Đăng xuất</a>
            </div>
        </div>
    </header>

    <div class="main-container">
        <aside class="sidebar">
            <div class="user-panel">
                <c:url value="/image?fname=${sessionScope.account != null && not empty sessionScope.account.avatar ? sessionScope.account.avatar : 'manager.png'}" var="userAvatar" />
                <img src="${userAvatar}" alt="Manager Avatar">
                <div>
                    <div style="font-size: 14px; font-weight: 600; color: #ffffff;"><c:out value="${sessionScope.account != null ? sessionScope.account.userName : 'manager'}" /></div>
                    <div class="user-role-text"><span class="online-dot"></span> Quản lý (Role ID: 2)</div>
                </div>
            </div>
            <ul class="sidebar-menu">
                <li class="active"><a href="${pageContext.request.contextPath}/manager/home">Tổng quan Manager</a></li>
                <li><a href="${pageContext.request.contextPath}/admin/category/list">Giám sát Danh mục</a></li>
                <li><a href="${pageContext.request.contextPath}/video">Kho Video hệ thống</a></li>
                <li><a href="${pageContext.request.contextPath}/home">Trang chủ Web</a></li>
            </ul>
        </aside>

        <main class="content">
            <div class="welcome-card">
                <h1>Khu Vực Quản Lý & Giám Sát Nghiệp Vụ</h1>
                <p>
                    Dành riêng cho vai trò Quản lý cửa hàng (Role ID: 2). Bạn có quyền theo dõi danh mục hàng hóa, giám sát video review sản phẩm của người dùng và hệ thống.
                </p>
                <div class="btn-group-welcome">
                    <a href="${pageContext.request.contextPath}/admin/category/list" class="btn btn-primary">Giám sát Danh mục &rarr;</a>
                    <a href="${pageContext.request.contextPath}/video" class="btn btn-secondary">Xem Kho Video &rarr;</a>
                    <a href="${pageContext.request.contextPath}/home" class="btn btn-outline">Trang chủ Web &rarr;</a>
                </div>
            </div>

            <div class="stat-grid">
                <div class="stat-card">
                    <h3>Quản Lý Nghiệp Vụ</h3>
                    <p>Vai trò Manager phụ trách kiểm soát hàng hóa và hoạt động vận hành chung của cửa hàng trực tuyến.</p>
                </div>
                <div class="stat-card accent-amber">
                    <h3>Danh Mục Sản Phẩm</h3>
                    <p>Theo dõi và giám sát các nhóm ngành hàng (iPhone, Laptop MacBook, Phụ kiện, Thời trang).</p>
                    <a href="${pageContext.request.contextPath}/admin/category/list">Xem Danh mục &rarr;</a>
                </div>
                <div class="stat-card accent-emerald">
                    <h3>Kho Video Trực Tuyến</h3>
                    <p>Giám sát toàn bộ các clip unboxing, review sản phẩm và hướng dẫn công nghệ do cộng đồng đăng tải.</p>
                    <a href="${pageContext.request.contextPath}/video">Xem Kho Video &rarr;</a>
                </div>
            </div>
        </main>
    </div>
</body>
</html>