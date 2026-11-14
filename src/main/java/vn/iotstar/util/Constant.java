package vn.iotstar.util;

import java.io.File;

public class Constant {
    public static final String SESSION_USERNAME = "username";
    public static final String COOKIE_REMEMBER = "username";
    public static final String DIR = resolveUploadDir();
    public static final String UPLOAD_DIRECTORY = DIR;
    public static final String DEFAULT_FILENAME = "default.png";

    public static class Path {
        public static final String REGISTER = "/views/register.jsp";
        public static final String LOGIN = "/views/login.jsp";
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
