CREATE DATABASE IF NOT EXISTS servletjpa CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE servletjpa;

CREATE TABLE IF NOT EXISTS schema_version (
  version INT PRIMARY KEY,
  description VARCHAR(255) NOT NULL,
  applied_at DATETIME NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS categories (
  CategoryId INT AUTO_INCREMENT PRIMARY KEY,
  CategoryName VARCHAR(255) NOT NULL,
  Images VARCHAR(500) NULL,
  status INT DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS videos (
  VideoId VARCHAR(50) PRIMARY KEY,
  Title VARCHAR(500) NULL,
  Description VARCHAR(500) NULL,
  Poster VARCHAR(500) NULL,
  Views INT DEFAULT 0,
  Active INT DEFAULT 1,
  CategoryId INT NULL,
  CONSTRAINT FK_Video_Category FOREIGN KEY (CategoryId) REFERENCES categories (CategoryId) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS users (
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

DROP PROCEDURE IF EXISTS run_schema_migration;

DELIMITER //
CREATE PROCEDURE run_schema_migration()
BEGIN
  DECLARE lock_acquired INT DEFAULT 0;
  DECLARE v2_applied INT DEFAULT 0;
  DECLARE col_exists INT DEFAULT 0;
  DECLARE single_uq_user INT DEFAULT 0;
  DECLARE single_uq_email INT DEFAULT 0;
  DECLARE idx_token INT DEFAULT 0;

  SELECT GET_LOCK('db_migration_lock', 10) INTO lock_acquired;
  IF lock_acquired != 1 THEN
    SIGNAL SQLSTATE '45000' 
      SET MESSAGE_TEXT = 'Migration aborted: Failed to acquire db_migration_lock within 10 seconds.';
  END IF;

  SELECT COUNT(*) INTO col_exists FROM information_schema.columns 
  WHERE table_schema = DATABASE() AND table_name = 'users' AND column_name = 'status';
  IF col_exists = 0 THEN
    ALTER TABLE users ADD COLUMN status INT NOT NULL DEFAULT 0;
  END IF;

  SELECT COUNT(*) INTO col_exists FROM information_schema.columns 
  WHERE table_schema = DATABASE() AND table_name = 'users' AND column_name = 'code';
  IF col_exists = 0 THEN
    ALTER TABLE users ADD COLUMN code VARCHAR(10) NULL;
  END IF;

  SELECT COUNT(*) INTO col_exists FROM information_schema.columns 
  WHERE table_schema = DATABASE() AND table_name = 'users' AND column_name = 'otpExpired';
  IF col_exists = 0 THEN
    ALTER TABLE users ADD COLUMN otpExpired DATETIME NULL;
  END IF;

  SELECT COUNT(*) INTO col_exists FROM information_schema.columns 
  WHERE table_schema = DATABASE() AND table_name = 'users' AND column_name = 'otpAttempts';
  IF col_exists = 0 THEN
    ALTER TABLE users ADD COLUMN otpAttempts INT NOT NULL DEFAULT 0;
  END IF;

  SELECT COUNT(*) INTO col_exists FROM information_schema.columns 
  WHERE table_schema = DATABASE() AND table_name = 'users' AND column_name = 'otpType';
  IF col_exists = 0 THEN
    ALTER TABLE users ADD COLUMN otpType VARCHAR(20) NULL;
  END IF;

  SELECT COUNT(*) INTO col_exists FROM information_schema.columns 
  WHERE table_schema = DATABASE() AND table_name = 'users' AND column_name = 'otpCooldownAt';
  IF col_exists = 0 THEN
    ALTER TABLE users ADD COLUMN otpCooldownAt DATETIME NULL;
  END IF;

  SELECT COUNT(*) INTO col_exists FROM information_schema.columns 
  WHERE table_schema = DATABASE() AND table_name = 'users' AND column_name = 'rememberTokenHash';
  IF col_exists = 0 THEN
    ALTER TABLE users ADD COLUMN rememberTokenHash VARCHAR(64) NULL;
  END IF;

  SELECT COUNT(*) INTO col_exists FROM information_schema.columns 
  WHERE table_schema = DATABASE() AND table_name = 'users' AND column_name = 'rememberTokenExpiry';
  IF col_exists = 0 THEN
    ALTER TABLE users ADD COLUMN rememberTokenExpiry DATETIME NULL;
  END IF;

  SELECT COUNT(*) INTO v2_applied FROM schema_version WHERE version = 2;
  IF v2_applied = 0 THEN
    UPDATE users SET status = 1 
    WHERE (username = 'lmh' AND email = 'lehoang22kk66@gmail.com')
       OR (username = 'manager' AND email = 'manager@iotstar.vn')
       OR (username = 'user' AND email = 'user@example.com');
       
    INSERT INTO schema_version (version, description, applied_at) 
    VALUES (2, 'Activate lab seed accounts', NOW());
  END IF;

  SELECT COUNT(*) INTO single_uq_user FROM information_schema.statistics s1
  WHERE s1.table_schema = DATABASE() AND s1.table_name = 'users' 
    AND s1.column_name = 'username' AND s1.non_unique = 0
    AND (SELECT COUNT(*) FROM information_schema.statistics s2 
         WHERE s2.table_schema = DATABASE() AND s2.table_name = 'users' AND s2.index_name = s1.index_name) = 1;
  IF single_uq_user = 0 THEN
    ALTER TABLE users ADD UNIQUE INDEX uq_users_username (username);
  END IF;

  SELECT COUNT(*) INTO single_uq_email FROM information_schema.statistics s1
  WHERE s1.table_schema = DATABASE() AND s1.table_name = 'users' 
    AND s1.column_name = 'email' AND s1.non_unique = 0
    AND (SELECT COUNT(*) FROM information_schema.statistics s2 
         WHERE s2.table_schema = DATABASE() AND s2.table_name = 'users' AND s2.index_name = s1.index_name) = 1;
  IF single_uq_email = 0 THEN
    ALTER TABLE users ADD UNIQUE INDEX uq_users_email (email);
  END IF;

  SELECT COUNT(*) INTO idx_token FROM information_schema.statistics 
  WHERE table_schema = DATABASE() AND table_name = 'users' AND column_name = 'rememberTokenHash';
  IF idx_token = 0 THEN
    ALTER TABLE users ADD INDEX idx_users_rememberTokenHash (rememberTokenHash);
  END IF;

  SELECT RELEASE_LOCK('db_migration_lock');
END //
DELIMITER ;

CALL run_schema_migration();
DROP PROCEDURE IF EXISTS run_schema_migration;
