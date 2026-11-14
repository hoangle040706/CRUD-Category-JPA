<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chỉnh Sửa Category - JPA 3.0</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Arial, sans-serif; }
        body { background-color: #f8f9fa; color: #333; }
        .container { max-width: 600px; margin: 40px auto; background: #fff; padding: 30px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
        h2 { margin-bottom: 20px; color: #007bff; }
        .form-group { margin-bottom: 18px; }
        label { display: block; font-weight: 600; margin-bottom: 6px; }
        input[type="text"], input[type="file"] { width: 100%; padding: 10px; border: 1px solid #ced4da; border-radius: 4px; }
        .preview-img { margin-top: 8px; margin-bottom: 8px; }
        .radio-group { display: flex; gap: 20px; margin-top: 6px; }
        .btn-group { display: flex; gap: 10px; margin-top: 25px; }
        .btn-submit { background: #ffc107; color: #212529; padding: 10px 22px; border: none; border-radius: 4px; font-weight: bold; cursor: pointer; }
        .btn-back { background: #6c757d; color: #fff; padding: 10px 22px; text-decoration: none; border-radius: 4px; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h2>Cập Nhật Danh Mục (JPA 3.0)</h2>
        <form action="<c:url value='/admin/category/update'/>" method="post" enctype="multipart/form-data">
            <input type="hidden" name="categoryid" value="${cate.categoryid}" />

            <div class="form-group">
                <label for="categoryname">Category name:</label>
                <input type="text" id="categoryname" name="categoryname" value="${cate.categoryname}" required />
            </div>

            <div class="form-group">
                <label for="images">Link images:</label>
                <input type="text" id="images" name="images" value="${cate.images}" />
            </div>

            <div class="form-group">
                <label>Hình ảnh hiện tại:</label>
                <div class="preview-img">
                    <c:choose>
                        <c:when test="${cate.images != null && cate.images.startsWith('http')}">
                            <c:set var="imgUrl" value="${cate.images}" />
                        </c:when>
                        <c:otherwise>
                            <c:url value="/image?fname=${cate.images != null && not empty cate.images ? cate.images : 'default.png'}" var="imgUrl" />
                        </c:otherwise>
                    </c:choose>
                    <img height="120" width="160" style="object-fit: cover; border-radius: 4px; border: 1px solid #dee2e6;" src="${imgUrl}" alt="${cate.categoryname}" />
                </div>
            </div>

            <div class="form-group">
                <label for="images1">Upload images (chọn nếu muốn đổi ảnh):</label>
                <input type="file" id="images1" name="images1" accept="image/*" />
            </div>

            <div class="form-group">
                <label>Status:</label>
                <div class="radio-group">
                    <label><input type="radio" id="ston" name="status" value="1" ${cate.status == 1 ? 'checked' : ''} /> Hoạt động</label>
                    <label><input type="radio" id="stoff" name="status" value="0" ${cate.status != 1 ? 'checked' : ''} /> Khóa</label>
                </div>
            </div>

            <div class="btn-group">
                <input type="submit" class="btn-submit" value="Update" />
                <a href="<c:url value='/admin/categories'/>" class="btn-back">Hủy</a>
            </div>
        </form>
    </div>
</body>
</html>
