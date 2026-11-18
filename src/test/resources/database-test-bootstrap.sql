DROP DATABASE IF EXISTS servletjpa_test;
CREATE DATABASE servletjpa_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE servletjpa_test;

CREATE TABLE schema_version (
  version INT PRIMARY KEY,
  description VARCHAR(255) NOT NULL,
  applied_at DATETIME NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE categories (
  CategoryId INT AUTO_INCREMENT PRIMARY KEY,
  CategoryName VARCHAR(255) NOT NULL,
  Images VARCHAR(500) NULL,
  status INT DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  fullname VARCHAR(100) NULL,
  avatar VARCHAR(255) NULL,
  roleid INT NOT NULL DEFAULT 5,
  phone VARCHAR(20) NULL,
  status INT NOT NULL DEFAULT 0,
  code VARCHAR(10) NULL,
  otpExpired DATETIME NULL,
  otpAttempts INT NOT NULL DEFAULT 0,
  otpType VARCHAR(20) NULL,
  otpCooldownAt DATETIME NULL,
  rememberTokenHash VARCHAR(64) NULL,
  rememberTokenExpiry DATETIME NULL,
  createdDate DATE NULL,
  INDEX idx_users_rememberTokenHash (rememberTokenHash)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE videos (
  VideoId VARCHAR(50) PRIMARY KEY,
  Title VARCHAR(500) NOT NULL,
  Description VARCHAR(500) NULL,
  Poster VARCHAR(500) NULL,
  Views INT DEFAULT 0,
  Active INT DEFAULT 1,
  CategoryId INT NULL,
  VideoPath VARCHAR(500) NULL,
  SourceType VARCHAR(20) NOT NULL DEFAULT 'LOCAL',
  UserId INT NULL,
  CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT FK_Video_Category FOREIGN KEY (CategoryId) REFERENCES categories (CategoryId) ON DELETE SET NULL,
  CONSTRAINT FK_Video_User FOREIGN KEY (UserId) REFERENCES users (id) ON DELETE SET NULL,
  INDEX idx_videos_active_created (Active, CreatedDate DESC, VideoId DESC),
  INDEX idx_videos_user_created (UserId, CreatedDate DESC, VideoId DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO schema_version (version, description, applied_at) 
VALUES 
  (1, 'Initial schema', NOW()),
  (2, 'Activate lab seed accounts', NOW()),
  (5, 'Add VideoPath, SourceType, UserId, CreatedDate, Title NOT NULL and indexes', NOW());

INSERT INTO categories (CategoryId, CategoryName, Images, status)
VALUES
  (1, 'Iphone', 'abc.jpg', 1),
  (2, 'Laptop Macbook', 'laptop.png', 1),
  (3, 'Quần Áo Nam', 'shirt.png', 1),
  (4, 'Quần Áo Nữ', 'dress.png', 1);

INSERT INTO users (id, username, password, email, fullname, roleid, status, createdDate)
VALUES
  (1, 'lmh', '$2a$10$i6FvFB59yCjCp4.klNrUIOX.UmN08gTgxSmsj/XH1Xs6EyUd3Hcge', 'lehoang22kk66@gmail.com', 'Le Minh Hoang', 1, 1, CURDATE()),
  (2, 'manager', '$2a$10$Gs2G/Jjilz6ARWlXjVeO.OsFnDnw724AHUSh/KJK8wrHnThzy/hTG', 'manager@iotstar.vn', 'Store Manager', 2, 1, CURDATE()),
  (3, 'user', '$2a$10$EyNsSTZhp6xUrPw5ZKH3NOhhOMp66u3PgTcYunv5cwgZoxWETgCTG', 'user@example.com', 'Normal User', 5, 1, CURDATE()),
  (4, 'legacy_user', '$2a$10$/xGduHs9zp1eI4KSFpZRkuJ7MMp7itYfUn982V3USKBrq2bN87Hl.', 'legacy@example.com', 'Legacy User', 5, 1, CURDATE());
