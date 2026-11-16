package vn.iotstar.dao;

import java.util.Date;
import java.util.List;
import vn.iotstar.entity.User;

public interface IUserDao {

    void insert(User user);

    void update(User user);

    void delete(int id) throws Exception;

    User findById(int id);

    User findByUsername(String username);

    User findByEmail(String email);

    User findByRememberTokenHash(String rememberTokenHash);

    List<User> findAll();

    boolean checkExistEmail(String email);

    boolean checkExistUsername(String username);

    boolean checkExistPhone(String phone);

    int lockOtpRequest(String email, String otp, String otpType, Date cooldownThreshold, Date now);

    int setOtpExpiry(String email, String otp, Date expiry);

    int cancelOtp(String email, String otp);

    int consumeRegisterOtp(String email, String otp, Date now);

    int consumeForgotPasswordOtp(String email, String otp, String newHashedPassword, Date now);

    int incrementOtpAttempts(String email, String otpType, Date now);

    int rotateRememberToken(String oldHash, String newHash, Date newExpiry, Date now);

    void clearRememberToken(int userId);

    void updatePassword(int userId, String newHashedPassword);
}
