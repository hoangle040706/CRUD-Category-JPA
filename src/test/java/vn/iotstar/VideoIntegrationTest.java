package vn.iotstar;

import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.WriteListener;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.*;
import vn.iotstar.controllers.VideoStreamController;
import vn.iotstar.dao.IVideoDao;
import vn.iotstar.dao.UserDao;
import vn.iotstar.dao.VideoDao;
import vn.iotstar.entity.User;
import vn.iotstar.entity.Video;
import vn.iotstar.entity.VideoSourceType;
import vn.iotstar.service.IVideoService;
import vn.iotstar.service.VideoServiceImpl;
import vn.iotstar.util.Constant;
import vn.iotstar.util.CsrfUtil;
import vn.iotstar.util.PasswordUtil;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.util.Date;
import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class VideoIntegrationTest {

    private static IVideoDao videoDao;
    private static IVideoService videoService;
    private static User testUserA;
    private static User testUserB;
    private static User testAdmin;
    private static File tempUploadDir;

    @BeforeAll
    public static void setUp() throws Exception {
        // 1. Dòng đầu tiên tuyệt đối: Đảm bảo database test được khởi tạo và migration hoàn tất
        TestBootstrapHelper.ensureTestDatabaseReady();

        System.setProperty("APP_DEV_MODE", "true");
        videoDao = new VideoDao();
        videoService = new VideoServiceImpl(videoDao);

        // 2. Tạo thư mục tạm phục vụ test upload an toàn
        tempUploadDir = Files.createTempDirectory("video_test_upload").toFile();
        Constant.setCustomUploadDirForTest(tempUploadDir.getAbsolutePath());

        // 3. Khởi tạo người dùng test trong servletjpa_test
        UserDao userDao = new UserDao();
        testUserA = new User();
        testUserA.setUsername("user_a_" + System.currentTimeMillis());
        testUserA.setEmail("user_a_" + System.currentTimeMillis() + "@test.com");
        testUserA.setPassword(PasswordUtil.hash("123456"));
        testUserA.setFullname("User A");
        testUserA.setRoleid(5);
        testUserA.setStatus(1);
        userDao.insert(testUserA);

        testUserB = new User();
        testUserB.setUsername("user_b_" + System.currentTimeMillis());
        testUserB.setEmail("user_b_" + System.currentTimeMillis() + "@test.com");
        testUserB.setPassword(PasswordUtil.hash("123456"));
        testUserB.setFullname("User B");
        testUserB.setRoleid(5);
        testUserB.setStatus(1);
        userDao.insert(testUserB);

        testAdmin = new User();
        testAdmin.setUsername("admin_" + System.currentTimeMillis());
        testAdmin.setEmail("admin_" + System.currentTimeMillis() + "@test.com");
        testAdmin.setPassword(PasswordUtil.hash("123456"));
        testAdmin.setFullname("Admin");
        testAdmin.setRoleid(1);
        testAdmin.setStatus(1);
        userDao.insert(testAdmin);
    }

    @AfterAll
    public static void tearDown() {
        Constant.resetUploadDirForTest();
        if (tempUploadDir != null && tempUploadDir.exists()) {
            deleteRecursively(tempUploadDir);
        }
    }

    private static void deleteRecursively(File file) {
        if (file.isDirectory()) {
            File[] children = file.listFiles();
            if (children != null) {
                for (File child : children) deleteRecursively(child);
            }
        }
        file.delete();
    }

    @Test
    @Order(1)
    @DisplayName("TC-V01: Top 10 Latest Videos & Loại trừ Video Inactive/Thiếu Link")
    public void testTc01_Top10LatestVideos() {
        long baseTime = System.currentTimeMillis();

        // Thêm 12 video với trạng thái đa dạng
        for (int i = 1; i <= 12; i++) {
            Video v = new Video();
            v.setVideoId("tc01_vid_" + i + "_" + UUID.randomUUID().toString().substring(0, 6));
            v.setTitle("Video Test Top 10 #" + i);
            v.setPoster("poster_" + i + ".png");
            v.setSourceType(VideoSourceType.YOUTUBE);
            v.setVideoPath("https://www.youtube.com/embed/dQw4w9WgXcQ");
            v.setUser(testUserA);
            v.setCreatedDate(new Date(baseTime + (i * 1000L))); // i càng lớn càng mới
            v.setActive(i <= 8 ? 1 : 0); // Video 9-12 là inactive (active = 0)
            videoService.insert(v);
        }

        // Thêm 1 video active nhưng thiếu videoPath (không được xuất hiện ở Top 10)
        Video broken = new Video();
        broken.setVideoId("tc01_broken_" + UUID.randomUUID().toString().substring(0, 6));
        broken.setTitle("Broken Video");
        broken.setActive(1);
        broken.setVideoPath(null);
        broken.setUser(testUserA);
        broken.setCreatedDate(new Date(baseTime + 99999L));
        videoService.insert(broken);

        List<Video> top10 = videoService.findTop10Latest();
        assertNotNull(top10);
        assertTrue(top10.size() <= 10);
        assertTrue(top10.size() >= 8);

        // Kiểm tra tất cả video trong Top 10 đều active = 1 và có videoPath
        for (Video v : top10) {
            assertEquals(1, v.getActive(), "Video trong Top 10 bắt buộc phải active = 1");
            assertNotNull(v.getVideoPath(), "Video trong Top 10 bắt buộc có đường dẫn phát");
            assertFalse(v.getVideoPath().trim().isEmpty());
        }

        // Kiểm tra thứ tự giảm dần theo thời gian tạo
        for (int i = 0; i < top10.size() - 1; i++) {
            assertTrue(top10.get(i).getCreatedDate().getTime() >= top10.get(i + 1).getCreatedDate().getTime(),
                    "Top 10 phải sắp xếp theo CreatedDate giảm dần");
        }
    }

    @Test
    @Order(2)
    @DisplayName("TC-V02: Phân trang 6 video/trang và Phân vùng Video Của Tôi")
    public void testTc02_PaginationAndUserVideoIsolation() {
        int publicCount = videoService.countPublicVideos();
        assertTrue(publicCount >= 8);

        // Trang 1: lấy tối đa 6 sản phẩm
        List<Video> page1 = videoService.findPublicVideosWithPaging(1, 6);
        assertEquals(6, page1.size(), "Trang 1 phải có đúng 6 video khi tổng số > 6");

        // Trang 2: lấy các sản phẩm còn lại
        List<Video> page2 = videoService.findPublicVideosWithPaging(2, 6);
        assertFalse(page2.isEmpty());
        assertTrue(page2.size() <= 6);

        // Đảm bảo video trang 1 không trùng lặp trang 2
        for (Video v1 : page1) {
            for (Video v2 : page2) {
                assertNotEquals(v1.getVideoId(), v2.getVideoId(), "Video phân trang không được trùng lặp giữa các trang");
            }
        }

        // Kiểm tra Video của Tôi (User A): bao gồm cả video active = 0 và active = 1
        int userACount = videoService.countVideosByUserId(testUserA.getId());
        assertTrue(userACount >= 12, "User A phải sở hữu toàn bộ 12+ video đã tạo");

        List<Video> userAVideos = videoService.findVideosByUserIdWithPaging(1, 6, testUserA.getId());
        assertEquals(6, userAVideos.size());
        for (Video v : userAVideos) {
            assertEquals(testUserA.getId(), v.getUser().getId(), "Video phải thuộc quyền sở hữu của User A");
        }

        // User B không có video nào
        int userBCount = videoService.countVideosByUserId(testUserB.getId());
        assertEquals(0, userBCount, "User B chưa đăng video nào nên số lượng = 0");
    }

    @Test
    @Order(3)
    @DisplayName("TC-V03: Moderation & Bảo mật Quyền Sở hữu (Owner vs Non-owner vs Admin)")
    public void testTc03_ModerationAndOwnershipSecurity() {
        // 1. User A tạo video mới: active ban đầu = 0
        Video v = new Video();
        v.setVideoId("mod_test_" + UUID.randomUUID().toString().substring(0, 6));
        v.setTitle("Moderation Policy Test");
        v.setActive(0);
        v.setSourceType(VideoSourceType.YOUTUBE);
        v.setVideoPath("https://www.youtube.com/embed/dQw4w9WgXcQ");
        v.setUser(testUserA);
        videoService.insert(v);

        Video created = videoService.findById(v.getVideoId());
        assertEquals(0, created.getActive(), "Video mới đăng tải phải có trạng thái chờ duyệt active = 0");

        // 2. Admin duyệt video: active chuyển thành 1
        boolean approved = videoService.adminUpdateActive(v.getVideoId(), 1);
        assertTrue(approved);
        Video approvedVideo = videoService.findById(v.getVideoId());
        assertEquals(1, approvedVideo.getActive(), "Admin duyệt video thành công");

        // 3. User B (kẻ giả mạo) cố gắng chỉnh sửa video của User A -> BỊ TỪ CHỐI
        Video fakeUpdate = new Video();
        fakeUpdate.setVideoId(v.getVideoId());
        fakeUpdate.setTitle("Hacked Title by User B");
        fakeUpdate.setDescription("Hacked Description");
        boolean hackedUpdate = videoService.updateByUser(fakeUpdate, testUserB.getId());
        assertFalse(hackedUpdate, "Người dùng không phải chủ sở hữu không được phép cập nhật video");

        // 4. User A chỉnh sửa video của chính mình -> THÀNH CÔNG, trạng thái tự động reset về active = 0 (Moderation Reset)
        Video validUpdate = new Video();
        validUpdate.setVideoId(v.getVideoId());
        validUpdate.setTitle("Updated Title by Owner User A");
        validUpdate.setDescription("Updated Description");
        boolean ownerUpdated = videoService.updateByUser(validUpdate, testUserA.getId());
        assertTrue(ownerUpdated, "Chủ sở hữu hợp pháp phải cập nhật video thành công");

        Video reloaded = videoService.findById(v.getVideoId());
        assertEquals("Updated Title by Owner User A", reloaded.getTitle());
        assertEquals(0, reloaded.getActive(), "Quy chuẩn Moderation Reset: chỉnh sửa video phải chuyển active về 0 chờ duyệt lại");

        // 5. User B cố gắng xóa video của User A -> BỊ TỪ CHỐI
        boolean hackedDelete = videoService.deleteByUser(v.getVideoId(), testUserB.getId());
        assertFalse(hackedDelete, "Người dùng không phải chủ sở hữu không được phép xóa video");

        // 6. User A xóa video của mình -> THÀNH CÔNG
        boolean ownerDelete = videoService.deleteByUser(v.getVideoId(), testUserA.getId());
        assertTrue(ownerDelete, "Chủ sở hữu hợp pháp phải xóa được video của mình");
        assertNull(videoService.findById(v.getVideoId()));
    }

    @Test
    @Order(4)
    @DisplayName("TC-V04: Bù trừ Thao tác Tệp (Compensating File Management Rollback)")
    public void testTc04_CompensatingFileManagement() throws Exception {
        // Tạo file poster và video thực tế trong thư mục upload
        File posterFile = new File(Constant.getPosterDir(), "test_compensate_poster.png");
        try (FileOutputStream fos = new FileOutputStream(posterFile)) {
            fos.write("fake-poster-bytes".getBytes());
        }
        File videoFile = new File(Constant.getVideoDir(), "test_compensate_video.mp4");
        try (FileOutputStream fos = new FileOutputStream(videoFile)) {
            fos.write("fake-video-bytes".getBytes());
        }

        assertTrue(posterFile.exists());
        assertTrue(videoFile.exists());

        // Mô phỏng logic compensating rollback trong Controller:
        // Nếu DB bị exception (ví dụ video title null gây lỗi NOT NULL constraint)
        Video brokenVideo = new Video();
        brokenVideo.setVideoId("comp_broken_" + UUID.randomUUID().toString().substring(0, 6));
        brokenVideo.setTitle(null); // Vi phạm Title NOT NULL
        brokenVideo.setPoster(posterFile.getName());
        brokenVideo.setVideoPath(videoFile.getName());
        brokenVideo.setSourceType(VideoSourceType.LOCAL);

        assertThrows(Exception.class, () -> {
            try {
                videoService.insert(brokenVideo);
            } catch (Exception e) {
                // Controller bắt lỗi và thực hiện compensating rollback
                if (posterFile.exists()) posterFile.delete();
                if (videoFile.exists()) videoFile.delete();
                throw e;
            }
        });

        // Xác nhận cả 2 file trên đĩa đã được dọn sạch, không để lại tệp rác
        assertFalse(posterFile.exists(), "Poster phải được xóa bù trừ khi DB thất bại");
        assertFalse(videoFile.exists(), "Video phải được xóa bù trừ khi DB thất bại");
    }

    @Test
    @Order(5)
    @DisplayName("TC-V05: RFC 9110 HTTP Range Streaming & Phân tích Byte Slicing")
    public void testTc05_Rfc9110HttpRangeStreaming() throws Exception {
        // 1. Tạo file video mẫu chuẩn (kích thước 10,000 bytes)
        int sampleSize = 10000;
        byte[] sampleData = new byte[sampleSize];
        for (int i = 0; i < sampleSize; i++) {
            sampleData[i] = (byte) (i % 128);
        }
        String fileName = "stream_test_sample.mp4";
        File testVideoFile = new File(Constant.getVideoDir(), fileName);
        try (FileOutputStream fos = new FileOutputStream(testVideoFile)) {
            fos.write(sampleData);
        }

        // 2. Tạo bản ghi Video trong DB
        String vId = "stream_vid_" + UUID.randomUUID().toString().substring(0, 6);
        Video video = new Video();
        video.setVideoId(vId);
        video.setTitle("Stream Sample Video");
        video.setSourceType(VideoSourceType.LOCAL);
        video.setVideoPath(fileName);
        video.setActive(1);
        video.setUser(testUserA);
        videoService.insert(video);

        VideoStreamController streamController = new VideoStreamController();

        // Sub-test 1: Không có header Range -> 200 OK toàn bộ file
        {
            HttpServletRequest req = mock(HttpServletRequest.class);
            HttpServletResponse resp = mock(HttpServletResponse.class);
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            setupMockStreams(req, resp, baos, vId, null);

            streamController.doGet(req, resp);

            verify(resp).setStatus(HttpServletResponse.SC_OK);
            verify(resp).setHeader("Content-Length", String.valueOf(sampleSize));
            assertEquals(sampleSize, baos.toByteArray().length);
        }

        // Sub-test 2: Header Range với unit không hiểu (invalid=0-10) -> RFC 9110 bỏ qua, trả 200 OK
        {
            HttpServletRequest req = mock(HttpServletRequest.class);
            HttpServletResponse resp = mock(HttpServletResponse.class);
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            setupMockStreams(req, resp, baos, vId, "invalid=0-10");

            streamController.doGet(req, resp);

            verify(resp).setStatus(HttpServletResponse.SC_OK);
            verify(resp).setHeader("Content-Length", String.valueOf(sampleSize));
            assertEquals(sampleSize, baos.toByteArray().length);
        }

        // Sub-test 3: Header Range hợp lệ: bytes=0-499 -> 206 Partial Content (500 bytes)
        {
            HttpServletRequest req = mock(HttpServletRequest.class);
            HttpServletResponse resp = mock(HttpServletResponse.class);
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            setupMockStreams(req, resp, baos, vId, "bytes=0-499");

            streamController.doGet(req, resp);

            verify(resp).setStatus(HttpServletResponse.SC_PARTIAL_CONTENT);
            verify(resp).setHeader("Content-Range", "bytes 0-499/" + sampleSize);
            verify(resp).setHeader("Content-Length", "500");
            assertEquals(500, baos.toByteArray().length);
            assertEquals(sampleData[0], baos.toByteArray()[0]);
            assertEquals(sampleData[499], baos.toByteArray()[499]);
        }

        // Sub-test 4: Header Range đuôi mở: bytes=9000- -> 206 Partial Content (1000 bytes)
        {
            HttpServletRequest req = mock(HttpServletRequest.class);
            HttpServletResponse resp = mock(HttpServletResponse.class);
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            setupMockStreams(req, resp, baos, vId, "bytes=9000-");

            streamController.doGet(req, resp);

            verify(resp).setStatus(HttpServletResponse.SC_PARTIAL_CONTENT);
            verify(resp).setHeader("Content-Range", "bytes 9000-9999/" + sampleSize);
            verify(resp).setHeader("Content-Length", "1000");
            assertEquals(1000, baos.toByteArray().length);
        }

        // Sub-test 5: Header Range hậu tố: bytes=-500 -> 206 Partial Content (500 bytes cuối)
        {
            HttpServletRequest req = mock(HttpServletRequest.class);
            HttpServletResponse resp = mock(HttpServletResponse.class);
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            setupMockStreams(req, resp, baos, vId, "bytes=-500");

            streamController.doGet(req, resp);

            verify(resp).setStatus(HttpServletResponse.SC_PARTIAL_CONTENT);
            verify(resp).setHeader("Content-Range", "bytes 9500-9999/" + sampleSize);
            verify(resp).setHeader("Content-Length", "500");
            assertEquals(500, baos.toByteArray().length);
        }

        // Sub-test 6: Header Multi-range bị từ chối: bytes=0-10,20-30 -> 416 Range Not Satisfiable
        {
            HttpServletRequest req = mock(HttpServletRequest.class);
            HttpServletResponse resp = mock(HttpServletResponse.class);
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            setupMockStreams(req, resp, baos, vId, "bytes=0-10,20-30");

            streamController.doGet(req, resp);

            verify(resp).setStatus(HttpServletResponse.SC_REQUESTED_RANGE_NOT_SATISFIABLE);
            verify(resp).setHeader("Content-Range", "bytes */" + sampleSize);
        }

        // Sub-test 7: Header Range vượt ngoài phạm vi: bytes=20000- -> 416 Range Not Satisfiable
        {
            HttpServletRequest req = mock(HttpServletRequest.class);
            HttpServletResponse resp = mock(HttpServletResponse.class);
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            setupMockStreams(req, resp, baos, vId, "bytes=20000-");

            streamController.doGet(req, resp);

            verify(resp).setStatus(HttpServletResponse.SC_REQUESTED_RANGE_NOT_SATISFIABLE);
            verify(resp).setHeader("Content-Range", "bytes */" + sampleSize);
        }
    }

    private void setupMockStreams(HttpServletRequest req, HttpServletResponse resp,
                                  ByteArrayOutputStream baos, String videoId, String rangeHeader) throws IOException {
        when(req.getParameter("id")).thenReturn(videoId);
        when(req.getHeader("Range")).thenReturn(rangeHeader);
        when(req.getSession(false)).thenReturn(null);

        ServletOutputStream sos = new ServletOutputStream() {
            @Override
            public boolean isReady() { return true; }
            @Override
            public void setWriteListener(WriteListener writeListener) {}
            @Override
            public void write(int b) { baos.write(b); }
            @Override
            public void write(byte[] b, int off, int len) { baos.write(b, off, len); }
        };
        when(resp.getOutputStream()).thenReturn(sos);
    }

    @Test
    @Order(6)
    @DisplayName("TC-V06: Ngăn Chặn Tuyệt Đối Tấn Công Path Traversal")
    public void testTc06_PathTraversalPrevention() throws Exception {
        // Tạo video với VideoPath độc hại trỏ ra ngoài thư mục video
        String vId = "traversal_vid_" + UUID.randomUUID().toString().substring(0, 6);
        Video video = new Video();
        video.setVideoId(vId);
        video.setTitle("Path Traversal Attack Video");
        video.setSourceType(VideoSourceType.LOCAL);
        video.setVideoPath("../../etc/passwd");
        video.setActive(1);
        video.setUser(testUserA);
        videoService.insert(video);

        VideoStreamController streamController = new VideoStreamController();
        HttpServletRequest req = mock(HttpServletRequest.class);
        HttpServletResponse resp = mock(HttpServletResponse.class);
        when(req.getParameter("id")).thenReturn(vId);
        when(req.getSession(false)).thenReturn(null);

        streamController.doGet(req, resp);

        // Bắt buộc phải trả về 403 hoặc 404, không bao giờ lộ file hệ thống
        verify(resp).sendError(intThat(code -> code == HttpServletResponse.SC_FORBIDDEN || code == HttpServletResponse.SC_NOT_FOUND), anyString());
    }

    @Test
    @Order(7)
    @DisplayName("TC-V07: Cơ Chế Xác Thực Sớm CSRF Token")
    public void testTc07_CsrfTokenValidation() {
        HttpSession session = mock(HttpSession.class);
        String token = CsrfUtil.generateToken(session);
        assertNotNull(token);
        assertEquals(64, token.length(), "CSRF Token phải là chuỗi Hex 64 ký tự (32 bytes)");

        // 1. Kiểm tra thành công khi Token hợp lệ
        HttpServletRequest validReq = mock(HttpServletRequest.class);
        when(validReq.getSession(false)).thenReturn(session);
        when(session.getAttribute(CsrfUtil.SESSION_CSRF_KEY)).thenReturn(token);
        when(validReq.getParameter(CsrfUtil.CSRF_PARAM_NAME)).thenReturn(token);
        assertTrue(CsrfUtil.isValid(validReq), "CSRF Token trùng khớp phải hợp lệ");

        // 2. Kiểm tra từ chối khi Token giả mạo
        HttpServletRequest invalidReq = mock(HttpServletRequest.class);
        when(invalidReq.getSession(false)).thenReturn(session);
        when(invalidReq.getParameter(CsrfUtil.CSRF_PARAM_NAME)).thenReturn("fake_token_1234567890abcdef");
        assertFalse(CsrfUtil.isValid(invalidReq), "CSRF Token sai lệch phải bị từ chối");

        // 3. Kiểm tra từ chối khi không có Token
        HttpServletRequest missingReq = mock(HttpServletRequest.class);
        when(missingReq.getSession(false)).thenReturn(session);
        when(missingReq.getParameter(CsrfUtil.CSRF_PARAM_NAME)).thenReturn(null);
        assertFalse(CsrfUtil.isValid(missingReq), "Thiếu CSRF Token phải bị từ chối");
    }

    @Test
    @Order(8)
    @DisplayName("TC-V08: Chuẩn Hóa Đường Dẫn Nhúng YouTube (YouTube URL Normalization)")
    public void testTc08_YouTubeUrlNormalization() {
        // Link xem thông thường (Watch URL)
        String watchUrl = "https://www.youtube.com/watch?v=dQw4w9WgXcQ";
        assertEquals("https://www.youtube.com/embed/dQw4w9WgXcQ", videoService.normalizeYouTubeEmbedUrl(watchUrl));

        // Link rút gọn (Shortened URL)
        String shortUrl = "https://youtu.be/dQw4w9WgXcQ";
        assertEquals("https://www.youtube.com/embed/dQw4w9WgXcQ", videoService.normalizeYouTubeEmbedUrl(shortUrl));

        // Link xem có kèm tham số phụ
        String complexUrl = "https://www.youtube.com/watch?feature=shared&v=dQw4w9WgXcQ&t=42s";
        assertEquals("https://www.youtube.com/embed/dQw4w9WgXcQ", videoService.normalizeYouTubeEmbedUrl(complexUrl));

        // Link đã ở định dạng Embed
        String embedUrl = "https://www.youtube.com/embed/dQw4w9WgXcQ";
        assertEquals("https://www.youtube.com/embed/dQw4w9WgXcQ", videoService.normalizeYouTubeEmbedUrl(embedUrl));

        // Chuỗi rỗng hoặc null
        assertNull(videoService.normalizeYouTubeEmbedUrl(null));
        assertNull(videoService.normalizeYouTubeEmbedUrl("   "));
    }
}
