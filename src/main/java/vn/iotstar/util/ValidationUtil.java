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

    /**
     * Whitelist extensions for avatar images.
     */
    public static boolean hasValidImageExtension(String fileName) {
        if (fileName == null || fileName.isBlank()) return false;
        String lower = fileName.trim().toLowerCase();
        return lower.endsWith(".jpg") || lower.endsWith(".jpeg") || lower.endsWith(".png") || lower.endsWith(".webp");
    }

    /**
     * Validates image header magic bytes (JPEG, PNG, WebP).
     * Skips bytes 4-7 for WebP RIFF file length.
     *
     * @param header first bytes of the file (at least 12 bytes recommended)
     * @return true if magic bytes match JPEG, PNG, or WebP
     */
    public static boolean isValidImageMagicBytes(byte[] header) {
        if (header == null || header.length < 4) {
            return false;
        }

        // JPEG: FF D8 FF
        if (header.length >= 3
                && (header[0] & 0xFF) == 0xFF
                && (header[1] & 0xFF) == 0xD8
                && (header[2] & 0xFF) == 0xFF) {
            return true;
        }

        // PNG: 89 50 4E 47 (0x89, 'P', 'N', 'G')
        if (header.length >= 4
                && (header[0] & 0xFF) == 0x89
                && (header[1] & 0xFF) == 0x50
                && (header[2] & 0xFF) == 0x4E
                && (header[3] & 0xFF) == 0x47) {
            return true;
        }

        // WebP: RIFF (bytes 0-3: 0x52, 0x49, 0x46, 0x46) and WEBP (bytes 8-11: 0x57, 0x45, 0x42, 0x50)
        if (header.length >= 12
                && (header[0] & 0xFF) == 0x52
                && (header[1] & 0xFF) == 0x49
                && (header[2] & 0xFF) == 0x46
                && (header[3] & 0xFF) == 0x46
                && (header[8] & 0xFF) == 0x57
                && (header[9] & 0xFF) == 0x45
                && (header[10] & 0xFF) == 0x42
                && (header[11] & 0xFF) == 0x50) {
            return true;
        }

        return false;
    }
}
