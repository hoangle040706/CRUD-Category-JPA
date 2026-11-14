<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chỉnh Sửa Danh Mục</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f4f6f9; }
        .box { background: #fff; padding: 30px; border-radius: 8px; max-width: 500px; margin: 0 auto; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
        h2 { margin-top: 0; color: #333; }
        .form-group { margin-bottom: 16px; }
        label { display: block; margin-bottom: 6px; font-weight: bold; color: #495057; }
        input[type="text"], textarea { width: 100%; padding: 10px; border: 1px solid #ced4da; border-radius: 4px; box-sizing: border-box; }
        textarea { height: 100px; resize: vertical; }
        .btn-submit { padding: 10px 20px; background: #007bff; color: #fff; border: none; border-radius: 4px; font-size: 15px; cursor: pointer; font-weight: bold; }
        .btn-submit:hover { background: #0056b3; }
        .btn-cancel { display: inline-block; padding: 10px 18px; background: #6c757d; color: #fff; text-decoration: none; border-radius: 4px; font-size: 15px; margin-left: 10px; }
        .btn-cancel:hover { background: #5a6268; }
        .alert-danger { background-color: #f8d7da; color: #721c24; padding: 10px; border-radius: 4px; margin-bottom: 16px; border: 1px solid #f5c6cb; }
    </style>
</head>
<body>
    <div class="box">
        <h2>Chỉnh Sửa Danh Mục</h2>

        <c:if test="${not empty alert}">
            <div class="alert-danger">${alert}</div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/category/edit">
            <input type="hidden" name="id" value="${category.id}">

            <div class="form-group">
                <label>Mã ID:</label>
                <input type="text" value="${category.id}" disabled style="background-color: #e9ecef;">
            </div>

            <div class="form-group">
                <label for="name">Tên danh mục (*):</label>
                <input type="text" id="name" name="name" value="${category.name}" required autofocus>
            </div>

            <div class="form-group">
                <label for="description">Mô tả:</label>
                <textarea id="description" name="description">${category.description}</textarea>
            </div>

            <div>
                <button type="submit" class="btn-submit">Cập nhật</button>
                <a href="${pageContext.request.contextPath}/category/list" class="btn-cancel">Hủy bỏ</a>
            </div>
        </form>
    </div>
</body>
</html>
