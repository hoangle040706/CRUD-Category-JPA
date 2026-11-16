package vn.iotstar.util;

import java.nio.charset.StandardCharsets;
import org.mindrot.jbcrypt.BCrypt;

public final class PasswordUtil {
    public static final int BCRYPT_COST = 10;
    public static final int MAX_PASSWORD_BYTES = 72;

    private PasswordUtil() {
    }

    public static String hash(String rawPassword) {
        if (rawPassword == null) {
            throw new IllegalArgumentException("Mật khẩu không được để trống");
        }
        if (rawPassword.getBytes(StandardCharsets.UTF_8).length > MAX_PASSWORD_BYTES) {
            throw new IllegalArgumentException("Mật khẩu không được vượt quá tối đa 72 byte UTF-8");
        }
        return BCrypt.hashpw(rawPassword, BCrypt.gensalt(BCRYPT_COST));
    }

    public static boolean check(String rawPassword, String storedHash) {
        if (rawPassword == null || storedHash == null) {
            return false;
        }
        if (rawPassword.getBytes(StandardCharsets.UTF_8).length > MAX_PASSWORD_BYTES) {
            return false;
        }
        if (!isBcryptHash(storedHash)) {
            return false;
        }
        try {
            return BCrypt.checkpw(rawPassword, storedHash);
        } catch (Exception e) {
            return false;
        }
    }

    public static boolean isBcryptHash(String storedPassword) {
        if (storedPassword == null || storedPassword.length() != 60) {
            return false;
        }
        return storedPassword.startsWith("$2a$") || storedPassword.startsWith("$2b$") || storedPassword.startsWith("$2y$");
    }
}
