CREATE DATABASE IF NOT EXISTS servletjpa CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE servletjpa;

DROP TABLE IF EXISTS videos;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS users;

CREATE TABLE categories (
  CategoryId INT AUTO_INCREMENT PRIMARY KEY,
  CategoryName VARCHAR(255) NOT NULL,
  Images VARCHAR(500) NULL,
  status INT DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE videos (
  VideoId VARCHAR(50) PRIMARY KEY,
  Title VARCHAR(500) NULL,
  Description VARCHAR(500) NULL,
  Poster VARCHAR(500) NULL,
  Views INT DEFAULT 0,
  Active INT DEFAULT 1,
  CategoryId INT NULL,
  CONSTRAINT FK_Video_Category FOREIGN KEY (CategoryId) REFERENCES categories (CategoryId) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(100),
  username VARCHAR(50) UNIQUE NOT NULL,
  fullname VARCHAR(100),
  password VARCHAR(100) NOT NULL,
  avatar VARCHAR(255) NULL,
  roleid INT NOT NULL DEFAULT 5,
  phone VARCHAR(20) NULL,
  createdDate DATE NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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

INSERT INTO users (username, password, email, fullname, avatar, roleid, phone, createdDate) VALUES 
('lmh', '123456', 'lehoang22kk66@gmail.com', 'Lê Minh Hoàng', 'admin.png', 1, '0987654321', CURDATE()),
('manager', '123456', 'manager@iotstar.vn', 'Store Manager', 'manager.png', 2, '0912345678', CURDATE()),
('user', '123456', 'user@example.com', 'Người Dùng Mẫu', 'user.png', 5, '0901234567', CURDATE())
ON DUPLICATE KEY UPDATE roleid=VALUES(roleid);
