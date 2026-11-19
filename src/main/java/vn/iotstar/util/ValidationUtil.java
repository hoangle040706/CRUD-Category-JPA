package vn.iotstar.util;

import java.nio.charset.StandardCharsets;
import java.util.regex.Pattern;

/**
 * Utility class for server-side input validation.
 * All methods are static and null-safe.
 */
public class ValidationUtil {

    // VN phone: 10 digits, starts with 0 followed by 3-9
    private static final Pattern PHONE_PATTERN =
            Pattern.compile("^0[3-9][0-9]{8}$");

    // Username: 3–50 alphanumeric + underscore
    private static final Pattern USERNAME_PATTERN =
            Pattern.compile("^[a-zA-Z0-9_]{3,50}$");

    // Basic email pattern
    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[a-zA-Z0-9._%+\\-]+@([a-zA-Z0-9\\-]+\\.)+[a-zA-Z]{2,}$");

    // YouTube URLs: standard watch, short youtu.be, embed, shorts
    private static final Pattern YOUTUBE_PATTERN = Pattern.compile(
            "^(https?://)?(www\\.)?(youtube\\.com/(watch\\?v=|embed/|shorts/)|youtu\\.be/)[\\w\\-]{11}.*$");

    private ValidationUtil() {}

    /**
     * Validates an email address.
     *
     * @param email the email string to validate
     * @return true if valid, false otherwise
     */
    public static boolean isValidEmail(String email) {
        if (email == null || email.isBlank()) return false;
        return EMAIL_PATTERN.matcher(email.trim()).matches();
    }

    /**
     * Validates a Vietnamese phone number (10 digits, starts with 0[3-9]).
     *
     * @param phone the phone string to validate
     * @return true if valid, false otherwise
     */
    public static boolean isValidPhone(String phone) {
        if (phone == null || phone.isBlank()) return false;
        return PHONE_PATTERN.matcher(phone.trim()).matches();
    }

    /**
     * Validates a username: 3–50 characters, alphanumeric + underscore.
     *
     * @param username the username string to validate
     * @return true if valid, false otherwise
     */
    public static boolean isValidUsername(String username) {
        if (username == null || username.isBlank()) return false;
        return USERNAME_PATTERN.matcher(username.trim()).matches();
    }

    /**
     * Validates a password: 6–72 bytes in UTF-8 encoding.
     * Upper bound 72 bytes is bcrypt's effective limit.
     *
     * @param password the plaintext password to validate
     * @return true if valid, false otherwise
     */
    public static boolean isValidPassword(String password) {
        if (password == null || password.isEmpty()) return false;
        int len = password.getBytes(StandardCharsets.UTF_8).length;
        return len >= 6 && len <= 72;
    }

    /**
     * Validates a YouTube URL (standard watch, short, embed, shorts).
     *
     * @param url the URL to validate
     * @return true if it looks like a valid YouTube link, false otherwise
     */
    public static boolean isValidYouTubeUrl(String url) {
        if (url == null || url.isBlank()) return false;
        return YOUTUBE_PATTERN.matcher(url.trim()).matches();
    }
}
