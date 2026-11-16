package vn.iotstar.service;

import java.util.List;
import vn.iotstar.entity.User;

public interface IUserService {

    int OTP_SUCCESS = 1;
    int OTP_INVALID = -1;
    int OTP_ATTEMPTS_EXCEEDED = -2;
    int OTP_EXPIRED = -3;
    int PASSWORD_TOO_LONG = -4;

    class RememberResult {
        private final User user;
        private final String newRawToken;

        public RememberResult(User user, String newRawToken) {
            this.user = user;
            this.newRawToken = newRawToken;
        }

        public User getUser() {
            return user;
        }

        public String getNewRawToken() {
            return newRawToken;
        }
    }

    User login(String username, String password);

    User get(int id);

    User get(String username);

    User findByEmail(String email);

    void insert(User user);

    void update(User user);

    boolean register(String email, String password, String username, String fullname, String phone);

    int verifyOtp(String email, String otp, String type);

    boolean resendOtp(String email, String type);

    boolean forgotPassword(String email);

    int resetPassword(String email, String otp, String newPassword);

    String createRememberToken(int userId);

    RememberResult loginWithToken(String rawToken);

    void clearRememberToken(int userId);

    boolean checkExistEmail(String email);

    boolean checkExistUsername(String username);

    boolean checkExistPhone(String phone);

    List<User> getAll();
}
