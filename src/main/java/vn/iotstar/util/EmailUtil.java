package vn.iotstar.util;

import java.security.SecureRandom;
import java.util.Date;
import java.util.Properties;
import java.util.concurrent.RejectedExecutionException;
import java.util.concurrent.ThreadPoolExecutor;
import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import vn.iotstar.config.AppContextListener;
import vn.iotstar.dao.IUserDao;
import vn.iotstar.dao.UserDao;

public final class EmailUtil {
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();
    private static final IUserDao userDao = new UserDao();

    private EmailUtil() {
    }

    public static String generateOtp() {
        return String.format("%06d", SECURE_RANDOM.nextInt(1_000_000));
    }

    public static void sendOtpAsync(String toEmail, String otp, String subject, String contentHeader) {
        if (Constant.DEV_MODE) {
            System.out.println("[DEV_MODE OTP] To: " + toEmail + " | Code: " + otp + " | Time: " + new Date());
        }

        ThreadPoolExecutor executor = AppContextListener.getMailExecutor();
        Runnable task = () -> {
            try {
                Date expiry = new Date(System.currentTimeMillis() + (long) Constant.OTP_VALIDITY_MINUTES * 60 * 1000);
                userDao.setOtpExpiry(toEmail, otp, expiry);

                sendHtmlEmail(toEmail, subject, buildOtpHtml(contentHeader, otp));
            } catch (Exception e) {
                userDao.cancelOtp(toEmail, otp);
                if (Constant.DEV_MODE) {
                    System.err.println("[Email Error] Failed to send email to " + toEmail + ": " + e.getMessage());
                }
            }
        };

        try {
            if (executor != null && !executor.isShutdown()) {
                executor.submit(task);
            } else {
                new Thread(task, "fallback-mail-thread").start();
            }
        } catch (RejectedExecutionException e) {
            userDao.cancelOtp(toEmail, otp);
            throw new RuntimeException("Hàng đợi gửi email đang bận, vui lòng thử lại sau giây lát.", e);
        }
    }

    private static void sendHtmlEmail(String toEmail, String subject, String htmlContent) throws MessagingException {
        if (Constant.SMTP_PASS == null || Constant.SMTP_PASS.trim().isEmpty()) {
            if (Constant.DEV_MODE) {
                System.out.println("[SMTP Warning] SMTP_PASS chưa được cấu hình. Bỏ qua gửi SMTP thực tế trong DEV_MODE.");
                return;
            } else {
                throw new MessagingException("SMTP_PASS is not configured on server.");
            }
        }

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", Constant.SMTP_HOST);
        props.put("mail.smtp.port", Constant.SMTP_PORT);
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(Constant.SMTP_USER, Constant.SMTP_PASS);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(Constant.SMTP_USER));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject(subject);
        message.setContent(htmlContent, "text/html; charset=UTF-8");

        Transport.send(message);
    }

    private static String buildOtpHtml(String header, String otp) {
        return "<div style='font-family: Arial, sans-serif; max-width: 500px; margin: auto; padding: 25px; border: 1px solid #e0e0e0; border-radius: 8px;'>"
                + "<h2 style='color: #007bff; text-align: center;'>Hệ Thống Xác Thực</h2>"
                + "<p>" + header + "</p>"
                + "<div style='text-align: center; margin: 25px 0;'>"
                + "<span style='font-size: 32px; font-weight: bold; letter-spacing: 6px; color: #28a745; background: #e8f5e9; padding: 10px 20px; border-radius: 6px; display: inline-block;'>"
                + otp + "</span>"
                + "</div>"
                + "<p style='color: #666; font-size: 14px;'>Mã xác thực có hiệu lực trong vòng <strong>" + Constant.OTP_VALIDITY_MINUTES + " phút</strong>. Tuyệt đối không chia sẻ mã này cho bất kỳ ai.</p>"
                + "</div>";
    }
}
