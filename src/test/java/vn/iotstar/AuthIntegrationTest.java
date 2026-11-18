package vn.iotstar;

import org.junit.jupiter.api.*;
import vn.iotstar.dao.IUserDao;
import vn.iotstar.dao.UserDao;
import vn.iotstar.entity.User;
import vn.iotstar.service.IUserService;
import vn.iotstar.service.UserServiceImpl;
import vn.iotstar.util.HashUtil;
import vn.iotstar.util.PasswordUtil;

import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;

import static org.junit.jupiter.api.Assertions.*;

@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class AuthIntegrationTest {

    private static IUserDao userDao;
    private static IUserService userService;

    @BeforeAll
    public static void setUp() {
        TestBootstrapHelper.ensureTestDatabaseReady();
        System.setProperty("APP_DEV_MODE", "true");
        userDao = new UserDao();
        userService = new UserServiceImpl();
    }

    @Test
    @Order(1)
    @DisplayName("TC-01: BCrypt Hashing and Password Limits")
    public void testTc01_BCryptHashing() {
        String rawPass = "123456";
        String hashed = PasswordUtil.hash(rawPass);
        assertNotNull(hashed);
        assertTrue(hashed.startsWith("$2a$10$") || hashed.startsWith("$2b$10$"));
        assertTrue(PasswordUtil.check(rawPass, hashed));
        assertFalse(PasswordUtil.check("wrongpassword", hashed));

        byte[] valid72 = new byte[72];
        for (int i = 0; i < 72; i++) valid72[i] = 'a';
        String pass72 = new String(valid72, StandardCharsets.UTF_8);
        assertDoesNotThrow(() -> PasswordUtil.hash(pass72));

        byte[] invalid73 = new byte[73];
        for (int i = 0; i < 73; i++) invalid73[i] = 'a';
        String pass73 = new String(invalid73, StandardCharsets.UTF_8);
        assertThrows(IllegalArgumentException.class, () -> PasswordUtil.hash(pass73));
    }

    @Test
    @Order(2)
    @DisplayName("TC-02: Instant Verification after OTP Generation")
    public void testTc02_InstantVerification() {
        String email = "test_tc02_" + System.currentTimeMillis() + "@gmail.com";
        String username = "user_tc02_" + System.currentTimeMillis();
        boolean reg = userService.register(email, "pass123", username, "Test TC02", "0901111111");
        assertTrue(reg);

        User created = userDao.findByEmail(email);
        assertNotNull(created);
        assertEquals(0, created.getStatus());
        String otp = created.getCode();
        assertNotNull(otp);

        Date expiry = new Date(System.currentTimeMillis() + 5 * 60 * 1000);
        userDao.setOtpExpiry(email, otp, expiry);

        int result = userService.verifyOtp(email, otp, "REGISTER");
        assertEquals(IUserService.OTP_SUCCESS, result);

        User verified = userDao.findByEmail(email);
        assertEquals(1, verified.getStatus());
        assertNull(verified.getCode());
        assertNull(verified.getOtpExpired());
    }

    @Test
    @Order(3)
    @DisplayName("TC-03: Expired OTP Verification Fails")
    public void testTc03_ExpiredOtp() {
        String email = "test_tc03_" + System.currentTimeMillis() + "@gmail.com";
        String username = "user_tc03_" + System.currentTimeMillis();
        userService.register(email, "pass123", username, "Test TC03", "0902222222");

        User user = userDao.findByEmail(email);
        String otp = user.getCode();

        Date pastExpiry = new Date(System.currentTimeMillis() - 10000);
        user.setOtpExpired(pastExpiry);
        userDao.update(user);

        int result = userService.verifyOtp(email, otp, "REGISTER");
        assertEquals(IUserService.OTP_EXPIRED, result);

        User stillUnverified = userDao.findByEmail(email);
        assertEquals(0, stillUnverified.getStatus());
    }

    @Test
    @Order(4)
    @DisplayName("TC-04: OTP 5th Wrong Attempt Cancellation")
    public void testTc04_FifthAttemptCancellation() {
        String email = "test_tc04_" + System.currentTimeMillis() + "@gmail.com";
        String username = "user_tc04_" + System.currentTimeMillis();
        userService.register(email, "pass123", username, "Test TC04", "0903333333");

        User user = userDao.findByEmail(email);
        String realOtp = user.getCode();
        Date expiry = new Date(System.currentTimeMillis() + 5 * 60 * 1000);
        userDao.setOtpExpiry(email, realOtp, expiry);

        String wrongOtp = "999999";

        for (int i = 1; i <= 4; i++) {
            int res = userService.verifyOtp(email, wrongOtp, "REGISTER");
            assertEquals(IUserService.OTP_INVALID, res, "Attempt " + i + " should return OTP_INVALID");
        }

        int fifthRes = userService.verifyOtp(email, wrongOtp, "REGISTER");
        assertEquals(IUserService.OTP_ATTEMPTS_EXCEEDED, fifthRes, "5th attempt should return OTP_ATTEMPTS_EXCEEDED");

        User canceled = userDao.findByEmail(email);
        assertEquals(5, canceled.getOtpAttempts());
        assertNull(canceled.getCode());
        assertNull(canceled.getOtpExpired());
    }

    @Test
    @Order(5)
    @DisplayName("TC-05: Concurrency Race on Same OTP")
    public void testTc05_ConcurrencyRace() throws Exception {
        String email = "test_tc05_" + System.currentTimeMillis() + "@gmail.com";
        String username = "user_tc05_" + System.currentTimeMillis();
        userService.register(email, "pass123", username, "Test TC05", "0904444444");

        User user = userDao.findByEmail(email);
        String otp = user.getCode();
        Date expiry = new Date(System.currentTimeMillis() + 5 * 60 * 1000);
        userDao.setOtpExpiry(email, otp, expiry);

        int threads = 2;
        ExecutorService pool = Executors.newFixedThreadPool(threads);
        CyclicBarrier barrier = new CyclicBarrier(threads);
        AtomicInteger successCount = new AtomicInteger(0);
        AtomicInteger failCount = new AtomicInteger(0);

        CountDownLatch latch = new CountDownLatch(threads);
        for (int i = 0; i < threads; i++) {
            pool.submit(() -> {
                try {
                    barrier.await();
                    int res = userService.verifyOtp(email, otp, "REGISTER");
                    if (res == IUserService.OTP_SUCCESS) {
                        successCount.incrementAndGet();
                    } else {
                        failCount.incrementAndGet();
                    }
                } catch (Exception e) {
                    failCount.incrementAndGet();
                } finally {
                    latch.countDown();
                }
            });
        }

        latch.await(5, TimeUnit.SECONDS);
        pool.shutdown();

        assertEquals(1, successCount.get(), "Exactly one concurrent request must succeed");
        assertEquals(1, failCount.get(), "The other concurrent request must fail");
    }

    @Test
    @Order(6)
    @DisplayName("TC-06: OTP Orphan Cleanup on Error/Queue Rejection")
    public void testTc06_CancelOtpCleanup() {
        String email = "test_tc06_" + System.currentTimeMillis() + "@gmail.com";
        String username = "user_tc06_" + System.currentTimeMillis();
        userService.register(email, "pass123", username, "Test TC06", "0905555555");

        User user = userDao.findByEmail(email);
        String otp = user.getCode();
        assertNotNull(otp);

        int canceled = userDao.cancelOtp(email, otp);
        assertEquals(1, canceled);

        User cleared = userDao.findByEmail(email);
        assertNull(cleared.getCode());
        assertNull(cleared.getOtpExpired());
        assertNull(cleared.getOtpCooldownAt());
        assertNull(cleared.getOtpType());
    }

    @Test
    @Order(7)
    @DisplayName("TC-07: Remember Me Token Rotation and Status = 1 Check")
    public void testTc07_RememberMeRotationAndStatusCheck() throws Exception {
        User activeUser = userDao.findByUsername("lmh");
        assertNotNull(activeUser);
        assertEquals(1, activeUser.getStatus());

        String rawToken = userService.createRememberToken(activeUser.getId());
        assertNotNull(rawToken);

        int threads = 2;
        ExecutorService pool = Executors.newFixedThreadPool(threads);
        CyclicBarrier barrier = new CyclicBarrier(threads);
        AtomicInteger successCount = new AtomicInteger(0);
        AtomicInteger failCount = new AtomicInteger(0);

        CountDownLatch latch = new CountDownLatch(threads);
        for (int i = 0; i < threads; i++) {
            pool.submit(() -> {
                try {
                    barrier.await();
                    IUserService.RememberResult res = userService.loginWithToken(rawToken);
                    if (res != null) {
                        successCount.incrementAndGet();
                    } else {
                        failCount.incrementAndGet();
                    }
                } catch (Exception e) {
                    failCount.incrementAndGet();
                } finally {
                    latch.countDown();
                }
            });
        }

        latch.await(5, TimeUnit.SECONDS);
        pool.shutdown();

        assertEquals(1, successCount.get(), "Exactly one rotation must succeed");
        assertEquals(1, failCount.get(), "The other must fail (anti-replay)");

        String unverifiedEmail = "unverified_" + System.currentTimeMillis() + "@gmail.com";
        userService.register(unverifiedEmail, "pass123", "unverified_" + System.currentTimeMillis(), "Unverified", "0906666666");
        User unverifiedUser = userDao.findByEmail(unverifiedEmail);
        assertEquals(0, unverifiedUser.getStatus());

        String unverifiedToken = userService.createRememberToken(unverifiedUser.getId());
        IUserService.RememberResult unverifiedRes = userService.loginWithToken(unverifiedToken);
        assertNull(unverifiedRes, "Remember me must reject unverified user (status != 1)");
    }

    @Test
    @Order(8)
    @DisplayName("TC-08: Legacy Plaintext Password Lazy Re-hash")
    public void testTc08_LegacyPasswordRehash() {
        User legacy = userDao.findByUsername("legacy_user");
        assertNotNull(legacy);

        userDao.updatePassword(legacy.getId(), "123456");

        User beforeLogin = userDao.findByUsername("legacy_user");
        assertEquals("123456", beforeLogin.getPassword());

        User loggedIn = userService.login("legacy_user", "123456");
        assertNotNull(loggedIn);

        User afterLogin = userDao.findByUsername("legacy_user");
        assertNotEquals("123456", afterLogin.getPassword());
        assertTrue(afterLogin.getPassword().startsWith("$2a$10$") || afterLogin.getPassword().startsWith("$2b$10$"));
        assertTrue(PasswordUtil.check("123456", afterLogin.getPassword()));
    }
}
