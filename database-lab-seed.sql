USE servletjpa;

INSERT INTO categories (CategoryId, CategoryName, Images, status) VALUES
(1, 'Iphone', 'phone.png', 1),
(2, 'Laptop Macbook', 'laptop.png', 1),
(3, 'Quần Áo Nam', 'shirt.png', 1),
(4, 'Quần Áo Nữ', 'dress.png', 1)
ON DUPLICATE KEY UPDATE CategoryName=VALUES(CategoryName);

INSERT INTO videos (VideoId, Title, Description, Poster, Views, Active, CategoryId) VALUES
('v01', 'Review iPhone 16 Pro Max', 'Đánh giá chi tiết iPhone 16', 'phone.png', 1500, 1, 1),
('v02', 'MacBook Pro M3 Max Unboxing', 'Mở hộp MacBook Pro M3', 'laptop.png', 3200, 1, 2)
ON DUPLICATE KEY UPDATE Title=VALUES(Title);

INSERT IGNORE INTO users (username, password, email, fullname, avatar, roleid, phone, status, createdDate) VALUES 
('lmh', '$2a$10$ZJcT7XGjUtPCWEw1GZBF0uS1IvjQ6Rwx0JY6Bz2RFWzXud.PY9Fdi', 'lehoang22kk66@gmail.com', 'Lê Minh Hoàng', 'admin.png', 1, '0987654321', 1, CURDATE()),
('manager', '$2a$10$ZJcT7XGjUtPCWEw1GZBF0uS1IvjQ6Rwx0JY6Bz2RFWzXud.PY9Fdi', 'manager@iotstar.vn', 'Store Manager', 'manager.png', 2, '0912345678', 1, CURDATE()),
('user', '$2a$10$ZJcT7XGjUtPCWEw1GZBF0uS1IvjQ6Rwx0JY6Bz2RFWzXud.PY9Fdi', 'user@example.com', 'Người Dùng Mẫu', 'user.png', 5, '0901234567', 1, CURDATE()),
('legacy_user', '123456', 'legacy@example.com', 'Tài Khoản Test Plaintext', 'legacy.png', 5, '0909999999', 1, CURDATE());
