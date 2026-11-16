package vn.iotstar.util;

import java.io.File;

public class Constant {
    public static final String SESSION_USERNAME = "username";
    public static final String SESSION_USER = "user";
    public static final String SESSION_PENDING_REGISTER_EMAIL = "PENDING_REGISTER_EMAIL";
    public static final String SESSION_PENDING_RESET_EMAIL = "PENDING_RESET_EMAIL";

    public static final String COOKIE_REMEMBER = "remember-me";
    public static final String COOKIE_REMEMBER_TOKEN = "remember-me";

    public static final int OTP_VALIDITY_MINUTES = 5;
    public static final int OTP_COOLDOWN_SECONDS = 60;
    public static final int OTP_MAX_ATTEMPTS = 5;

    public static final boolean DEV_MODE = Boolean.parseBoolean(
            System.getProperty("APP_DEV_MODE", System.getenv().getOrDefault("APP_DEV_MODE", "false")));

    public static final String SMTP_HOST = System.getProperty("SMTP_HOST",
            System.getenv().getOrDefault("SMTP_HOST", "smtp.gmail.com"));
    public static final String SMTP_PORT = System.getProperty("SMTP_PORT",
            System.getenv().getOrDefault("SMTP_PORT", "587"));
    public static final String SMTP_USER = System.getProperty("SMTP_USER",
            System.getenv().getOrDefault("SMTP_USER", "noreply@example.com"));
    public static final String SMTP_PASS = System.getProperty("SMTP_PASS",
            System.getenv().getOrDefault("SMTP_PASS", ""));

    public static final String TRUSTED_PROXIES = System.getProperty("TRUSTED_PROXIES",
            System.getenv().getOrDefault("TRUSTED_PROXIES", "127.0.0.1,::1"));

    public static final String DIR = resolveUploadDir();
    public static final String UPLOAD_DIRECTORY = DIR;
    public static final String DEFAULT_FILENAME = "default.png";

    public static class Path {
        public static final String REGISTER = "/views/register.jsp";
        public static final String LOGIN = "/views/login.jsp";
        public static final String VERIFY_OTP = "/views/auth/verify-otp.jsp";
        public static final String FORGOT_PASSWORD = "/views/auth/forgot-password.jsp";
        public static final String RESET_PASSWORD = "/views/auth/reset-password.jsp";
        public static final String ADMIN_HOME = "/views/admin/home.jsp";
        public static final String USER_HOME = "/views/home.jsp";
    }

    public static final String REGISTER = Path.REGISTER;

    private static String resolveUploadDir() {
        String os = System.getProperty("os.name", "").toLowerCase();
        if (os.contains("win")) {
            File eDir = new File("E:\\upload");
            try {
                if (eDir.exists() || eDir.mkdirs()) {
                    return "E:\\upload";
                }
            } catch (Exception ignored) {
            }
            File cDir = new File("C:\\upload");
            try {
                if (cDir.exists() || cDir.mkdirs()) {
                    return "C:\\upload";
                }
            } catch (Exception ignored) {
            }
        }
        String homeDir = System.getProperty("user.home") + File.separator + "upload";
        File dir = new File(homeDir);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        return homeDir;
    }
}
