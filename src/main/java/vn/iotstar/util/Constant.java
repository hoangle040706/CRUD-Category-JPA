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
    public static final String DEFAULT_POSTER = "default-poster.jpg";

    public static final long MAX_POSTER_SIZE = 5L * 1024 * 1024; // 5MB
    public static final long MAX_VIDEO_SIZE = 200L * 1024 * 1024; // 200MB
    public static final long MAX_REQUEST_SIZE = 250L * 1024 * 1024; // 250MB
    public static final int PAGE_SIZE_VIDEO = 6;

    private static volatile String customUploadDir = null;

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

    public static String getUploadDir() {
        return customUploadDir != null ? customUploadDir : DIR;
    }

    public static String getPosterDir() {
        String base = getUploadDir();
        String posterPath = base + File.separator + "posters";
        File dir = new File(posterPath);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        return posterPath;
    }

    public static String getVideoDir() {
        String base = getUploadDir();
        String videoPath = base + File.separator + "videos";
        File dir = new File(videoPath);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        return videoPath;
    }

    public static synchronized void setCustomUploadDirForTest(String path) {
        if (path == null) {
            customUploadDir = null;
            return;
        }
        File f = new File(path);
        if (!f.exists()) {
            f.mkdirs();
        }
        customUploadDir = f.getAbsolutePath();
        new File(customUploadDir + File.separator + "posters").mkdirs();
        new File(customUploadDir + File.separator + "videos").mkdirs();
    }

    public static synchronized void resetUploadDirForTest() {
        customUploadDir = null;
    }

    private static String resolveUploadDir() {
        String customEnv = System.getenv("UPLOAD_DIR");
        if (customEnv != null && !customEnv.trim().isEmpty()) {
            File f = new File(customEnv.trim());
            if (f.exists() || f.mkdirs()) {
                return f.getAbsolutePath();
            }
        }
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
        new File(homeDir + File.separator + "posters").mkdirs();
        new File(homeDir + File.separator + "videos").mkdirs();
        return homeDir;
    }
}
