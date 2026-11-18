USE servletjpa;

INSERT INTO videos (VideoId, Title, Description, Poster, Views, Active, CategoryId, VideoPath, SourceType, UserId, CreatedDate)
VALUES
('vid01', 'Đánh giá iPhone 15 Pro Max chi tiết', 'Video trải nghiệm và đánh giá toàn diện iPhone 15 Pro Max sau 6 tháng sử dụng.', 'https://img.youtube.com/vi/UYXz1j0RUWQ/hqdefault.jpg', 1520, 1, 1, 'https://www.youtube.com/embed/UYXz1j0RUWQ', 'YOUTUBE', 1, '2026-11-10 08:00:00'),
('vid02', 'Trên tay MacBook Pro M3 Max', 'Sức mạnh chip Apple Silicon M3 Max trên MacBook Pro 16 inch.', 'https://img.youtube.com/vi/ZWgr7qP6yhY/hqdefault.jpg', 3200, 1, 2, 'https://www.youtube.com/embed/ZWgr7qP6yhY', 'YOUTUBE', 1, '2026-11-11 09:15:00'),
('vid03', 'Hướng dẫn phối đồ Nam công sở lịch lãm', 'Tips phối áo sơ mi và quần tây chuẩn phong cách hiện đại.', 'https://img.youtube.com/vi/ZDLk62IFr_0/hqdefault.jpg', 890, 1, 3, 'https://www.youtube.com/embed/ZDLk62IFr_0', 'YOUTUBE', 3, '2026-11-12 10:30:00'),
('vid04', 'Bộ sưu tập Đầm dạ hội Nữ 2026', 'Tổng hợp xu hướng thời trang dạ hội cao cấp mới nhất.', 'https://img.youtube.com/vi/YL-OmE84Kn0/hqdefault.jpg', 2100, 1, 4, 'https://www.youtube.com/embed/YL-OmE84Kn0', 'YOUTUBE', 3, '2026-11-13 14:20:00'),
('vid05', 'Mẹo lập trình Spring Boot & Hibernate', 'Tối ưu hiệu năng ứng dụng Jakarta EE với Hibernate ORM và HikariCP.', 'https://img.youtube.com/vi/4Ico2HjRTCE/hqdefault.jpg', 4500, 1, 2, 'https://www.youtube.com/embed/4Ico2HjRTCE', 'YOUTUBE', 1, '2026-11-14 11:00:00'),
('vid06', 'Top 5 Smartphone đáng mua nhất năm', 'So sánh camera, thời lượng pin và hiệu năng các flagship.', 'https://img.youtube.com/vi/sfyL4BswUeE/hqdefault.jpg', 1780, 1, 1, 'https://www.youtube.com/embed/sfyL4BswUeE', 'YOUTUBE', 1, '2026-11-15 15:45:00'),
('vid07', 'Setup góc làm việc Minimalism', 'Chia sẻ kinh nghiệm decor bàn làm việc công nghệ gọn gàng, hiệu quả.', 'https://img.youtube.com/vi/OxVXy3FmVAM/hqdefault.jpg', 980, 1, 2, 'https://www.youtube.com/embed/OxVXy3FmVAM', 'YOUTUBE', 3, '2026-11-16 08:30:00'),
('vid08', 'Thời trang đường phố Streetwear năng động', 'Phong cách trẻ trung cho mùa thu đông.', 'https://img.youtube.com/vi/kOFBvIx96mU/hqdefault.jpg', 640, 1, 3, 'https://www.youtube.com/embed/kOFBvIx96mU', 'YOUTUBE', 3, '2026-11-16 16:00:00'),
('vid09', 'Review Áo khoác Blazer nữ cao cấp', 'Chất liệu vải cao cấp và form dáng tôn dáng người mặc.', 'https://img.youtube.com/vi/2vjPBrBU-TM/hqdefault.jpg', 1250, 1, 4, 'https://www.youtube.com/embed/2vjPBrBU-TM', 'YOUTUBE', 3, '2026-11-17 09:00:00'),
('vid10', 'Tìm hiểu kiến trúc Microservices & Docker', 'Containerization cho ứng dụng backend doanh nghiệp.', 'https://img.youtube.com/vi/jPdIRX6q4jA/hqdefault.jpg', 3800, 1, 2, 'https://www.youtube.com/embed/jPdIRX6q4jA', 'YOUTUBE', 1, '2026-11-17 13:30:00'),
('vid11', 'So sánh iPhone 15 và MacBook Air M3', 'Nên đầu tư thiết bị nào cho công việc sáng tạo nội dung?', 'https://img.youtube.com/vi/cBpGq-vDr2Y/hqdefault.jpg', 520, 1, 1, 'https://www.youtube.com/embed/cBpGq-vDr2Y', 'YOUTUBE', 1, '2026-11-17 17:00:00'),
('vid12', 'Video mẫu đang chờ duyệt (Pending)', 'Video do người dùng tải lên đang ở trạng thái chờ duyệt active = 0.', 'https://img.youtube.com/vi/zOjov-2OZ0E/hqdefault.jpg', 10, 0, 1, 'https://www.youtube.com/embed/zOjov-2OZ0E', 'YOUTUBE', 3, '2026-11-18 07:00:00')
ON DUPLICATE KEY UPDATE
  Title = VALUES(Title),
  Description = VALUES(Description),
  Poster = VALUES(Poster),
  Views = VALUES(Views),
  Active = VALUES(Active),
  CategoryId = VALUES(CategoryId),
  VideoPath = VALUES(VideoPath),
  SourceType = VALUES(SourceType),
  UserId = VALUES(UserId),
  CreatedDate = VALUES(CreatedDate);
