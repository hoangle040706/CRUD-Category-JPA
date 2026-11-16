package vn.iotstar.service;

import java.nio.charset.StandardCharsets;
import java.sql.Date;
import java.util.List;
import vn.iotstar.dao.IUserDao;
import vn.iotstar.dao.UserDao;
import vn.iotstar.entity.User;
import vn.iotstar.util.Constant;
import vn.iotstar.util.EmailUtil;
import vn.iotstar.util.HashUtil;
import vn.iotstar.util.PasswordUtil;

public class UserServiceImpl implements IUserService {

    private final IUserDao userDao = new UserDao();

    @Override
    public User login(String username, String password) {
        if (username == null || password == null) {
            return null;
        }
        User user = userDao.findByUsername(username);
        if (user == null) {
            return null;
        }

        boolean matches = PasswordUtil.check(password, user.getPassword());
        if (!matches) {
            if (password.equals(user.getPassword())) {
                String newHash = PasswordUtil.hash(password);
                userDao.updatePassword(user.getId(), newHash);
                user.setPassword(newHash);
                matches = true;
            }
        }

        if (!matches) {
            return null;
        }

        return user;
    }

    @Override
    public User get(int id) {
        return userDao.findById(id);
    }

    @Override
    public User get(String username) {
        return userDao.findByUsername(username);
    }

    @Override
    public User findByEmail(String email) {
        return userDao.findByEmail(email);
    }

    @Override
    public void insert(User user) {
        userDao.insert(user);
    }

    @Override
    public void update(User user) {
        userDao.update(user);
    }

    @Override
    public boolean register(String email, String password, String username, String fullname, String phone) {
        if (userDao.checkExistUsername(username) || userDao.checkExistEmail(email)) {
            return false;
        }
        if (password == null || password.getBytes(StandardCharsets.UTF_8).length > 72) {
            return false;
        }

        String hashedPassword = PasswordUtil.hash(password);
        String otp = EmailUtil.generateOtp();

        User user = new User();
        user.setEmail(email);
        user.setUsername(username);
        user.setFullname(fullname);
        user.setPassword(hashedPassword);
        user.setRoleid(5);
        user.setPhone(phone);
        user.setAvatar("user.png");
        user.setCreatedDate(new Date(System.currentTimeMillis()));
        user.setStatus(0);
        user.setCode(otp);
        user.setOtpAttempts(0);
        user.setOtpType("REGISTER");
        user.setOtpCooldownAt(new java.util.Date());

        userDao.insert(user);
        EmailUtil.sendOtpAsync(email, otp, "Mã kích hoạt tài khoản", "Mã xác thực đăng ký tài khoản của bạn là:");
        return true;
    }

    @Override
    public int verifyOtp(String email, String otp, String type) {
        java.util.Date now = new java.util.Date();
        if ("REGISTER".equalsIgnoreCase(type)) {
            int rows = userDao.consumeRegisterOtp(email, otp, now);
            if (rows == 1) {
                return OTP_SUCCESS;
            }
            int attemptResult = userDao.incrementOtpAttempts(email, type, now);
            if (attemptResult == 1) {
                return OTP_INVALID;
            }
            if (attemptResult == 2) {
                return OTP_ATTEMPTS_EXCEEDED;
            }
            return OTP_EXPIRED;
        }
        return OTP_EXPIRED;
    }

    @Override
    public boolean resendOtp(String email, String type) {
        java.util.Date now = new java.util.Date();
        java.util.Date cooldownThreshold = new java.util.Date(now.getTime() - (long) Constant.OTP_COOLDOWN_SECONDS * 1000);
        String otp = EmailUtil.generateOtp();
        int locked = userDao.lockOtpRequest(email, otp, type, cooldownThreshold, now);
        if (locked == 1) {
            String subject = "REGISTER".equalsIgnoreCase(type) ? "Mã kích hoạt tài khoản mới" : "Mã đặt lại mật khẩu mới";
            String header = "REGISTER".equalsIgnoreCase(type) ? "Mã xác thực đăng ký tài khoản mới của bạn là:" : "Mã xác thực đặt lại mật khẩu mới của bạn là:";
            EmailUtil.sendOtpAsync(email, otp, subject, header);
            return true;
        }
        return false;
    }

    @Override
    public boolean forgotPassword(String email) {
        User user = userDao.findByEmail(email);
        if (user == null) {
            return true;
        }
        java.util.Date now = new java.util.Date();
        java.util.Date cooldownThreshold = new java.util.Date(now.getTime() - (long) Constant.OTP_COOLDOWN_SECONDS * 1000);
        String otp = EmailUtil.generateOtp();
        int locked = userDao.lockOtpRequest(email, otp, "FORGOT_PASSWORD", cooldownThreshold, now);
        if (locked == 1) {
            EmailUtil.sendOtpAsync(email, otp, "Mã đặt lại mật khẩu", "Mã xác thực đặt lại mật khẩu của bạn là:");
            return true;
        }
        return false;
    }

    @Override
    public int resetPassword(String email, String otp, String newPassword) {
        if (newPassword == null || newPassword.getBytes(StandardCharsets.UTF_8).length > 72) {
            return PASSWORD_TOO_LONG;
        }
        String newHash = PasswordUtil.hash(newPassword);
        java.util.Date now = new java.util.Date();
        int rows = userDao.consumeForgotPasswordOtp(email, otp, newHash, now);
        if (rows == 1) {
            return OTP_SUCCESS;
        }
        int attemptResult = userDao.incrementOtpAttempts(email, "FORGOT_PASSWORD", now);
        if (attemptResult == 1) {
            return OTP_INVALID;
        }
        if (attemptResult == 2) {
            return OTP_ATTEMPTS_EXCEEDED;
        }
        return OTP_EXPIRED;
    }

    @Override
    public String createRememberToken(int userId) {
        String rawToken = HashUtil.generateRandomToken();
        String tokenHash = HashUtil.sha256(rawToken);
        java.util.Date expiry = new java.util.Date(System.currentTimeMillis() + 30L * 24 * 3600 * 1000);
        User user = userDao.findById(userId);
        if (user != null) {
            user.setRememberTokenHash(tokenHash);
            user.setRememberTokenExpiry(expiry);
            userDao.update(user);
            return rawToken;
        }
        return null;
    }

    @Override
    public RememberResult loginWithToken(String rawToken) {
        if (rawToken == null || rawToken.trim().isEmpty()) {
            return null;
        }
        String oldHash = HashUtil.sha256(rawToken.trim());
        String newRawToken = HashUtil.generateRandomToken();
        String newHash = HashUtil.sha256(newRawToken);
        java.util.Date newExpiry = new java.util.Date(System.currentTimeMillis() + 30L * 24 * 3600 * 1000);
        java.util.Date now = new java.util.Date();
        int rotated = userDao.rotateRememberToken(oldHash, newHash, newExpiry, now);
        if (rotated == 1) {
            User user = userDao.findByRememberTokenHash(newHash);
            if (user != null && user.getStatus() == 1) {
                return new RememberResult(user, newRawToken);
            }
        }
        return null;
    }

    @Override
    public void clearRememberToken(int userId) {
        userDao.clearRememberToken(userId);
    }

    @Override
    public boolean checkExistEmail(String email) {
        return userDao.checkExistEmail(email);
    }

    @Override
    public boolean checkExistUsername(String username) {
        return userDao.checkExistUsername(username);
    }

    @Override
    public boolean checkExistPhone(String phone) {
        return userDao.checkExistPhone(phone);
    }

    @Override
    public List<User> getAll() {
        return userDao.findAll();
    }
}
