package vn.iotstar.util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.HexFormat;

public class CsrfUtil {
    public static final String CSRF_PARAM_NAME = "csrfToken";
    public static final String SESSION_CSRF_KEY = "CSRF_TOKEN";
    private static final SecureRandom RANDOM = new SecureRandom();

    public static String getToken(HttpSession session) {
        if (session == null) {
            return null;
        }
        String token = (String) session.getAttribute(SESSION_CSRF_KEY);
        if (token == null) {
            token = generateToken(session);
        }
        return token;
    }

    public static String generateToken(HttpSession session) {
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        String token = HexFormat.of().formatHex(bytes);
        if (session != null) {
            session.setAttribute(SESSION_CSRF_KEY, token);
        }
        return token;
    }

    public static String rotateToken(HttpSession session) {
        return generateToken(session);
    }

    public static boolean isValid(HttpServletRequest req) {
        if (req == null) {
            return false;
        }
        HttpSession session = req.getSession(false);
        if (session == null) {
            return false;
        }
        String sessionToken = (String) session.getAttribute(SESSION_CSRF_KEY);
        if (sessionToken == null || sessionToken.trim().isEmpty()) {
            return false;
        }
        String reqToken = req.getParameter(CSRF_PARAM_NAME);
        if (reqToken == null) {
            reqToken = req.getHeader("X-CSRF-Token");
        }
        if (reqToken == null || reqToken.trim().isEmpty()) {
            return false;
        }
        return MessageDigest.isEqual(
                sessionToken.getBytes(java.nio.charset.StandardCharsets.UTF_8),
                reqToken.getBytes(java.nio.charset.StandardCharsets.UTF_8)
        );
    }
}
