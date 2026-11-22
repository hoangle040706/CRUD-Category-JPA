package vn.iotstar.service.impl;

import java.util.Date;
import java.util.Properties;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ThreadPoolExecutor;
import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import vn.iotstar.config.AppContextListener;
import vn.iotstar.service.IOtpMailer;
import vn.iotstar.util.Constant;

public class AsyncOtpMailerImpl implements IOtpMailer {

    @Override
    public CompletableFuture<Boolean> sendOtpAsync(String toEmail, String otp) {
        CompletableFuture<Boolean> future = new CompletableFuture<>();

        if (Constant.DEV_MODE) {
            System.out.println("[DEV_MODE PROFILE OTP] To: " + toEmail + " | Code: " + otp + " | Time: " + new Date());
        }

        ThreadPoolExecutor executor = AppContextListener.getMailExecutor();
        Runnable task = () -> {
            try {
                if (Constant.SMTP_PASS == null || Constant.SMTP_PASS.trim().isEmpty()) {
                    if (Constant.DEV_MODE) {
                        System.out.println("[DEV_MODE] SMTP_PASS not set, simulated email delivery to: " + toEmail);
                        future.complete(true);
                        return;
                    }
                }
                sendHtmlEmail(toEmail, "Mã xác thực thay đổi địa chỉ email - MyVideo Platform",
                        buildOtpHtml("Mã xác thực thay đổi địa chỉ email của bạn là:", otp));
                future.complete(true);
            } catch (Exception e) {
                if (Constant.DEV_MODE) {
                    System.err.println("[AsyncOtpMailer] Delivery failed to " + toEmail + ": " + e.getMessage());
                }
                future.complete(false);
            }
        };

        if (executor != null && !executor.isShutdown()) {
            executor.submit(task);
        } else {
            new Thread(task, "fallback-profile-mailer").start();
        }

        return future;
    }

    @Override
    public CompletableFuture<Boolean> sendNoticeAsync(String toEmail, String message) {
        CompletableFuture<Boolean> future = new CompletableFuture<>();
        ThreadPoolExecutor executor = AppContextListener.getMailExecutor();
        Runnable task = () -> {
            try {
                if (Constant.SMTP_PASS == null || Constant.SMTP_PASS.trim().isEmpty()) {
                    future.complete(true);
                    return;
                }
                sendHtmlEmail(toEmail, "Thông báo bảo mật tài khoản - MyVideo Platform",
                        "<p style='font-family:sans-serif;color:#1e3a8a;'><b>MyVideo Platform Thông Báo:</b></p><p>" + message + "</p>");
                future.complete(true);
            } catch (Exception e) {
                future.complete(false);
            }
        };

        if (executor != null && !executor.isShutdown()) {
            executor.submit(task);
        } else {
            new Thread(task, "fallback-profile-notice").start();
        }

        return future;
    }

    private void sendHtmlEmail(String toEmail, String subject, String htmlContent) throws Exception {
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
        message.setFrom(new InternetAddress(Constant.SMTP_USER, "MyVideo Platform"));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject(subject);
        message.setContent(htmlContent, "text/html; charset=UTF-8");

        Transport.send(message);
    }

    private String buildOtpHtml(String header, String otp) {
        return "<div style=\"font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; max-width: 500px; margin: auto; padding: 24px; border: 1px solid #e2e8f0; border-radius: 8px; background-color: #ffffff;\">"
                + "<h2 style=\"color: #1e3a8a; text-align: center; margin-bottom: 20px;\">MyVideo Platform</h2>"
                + "<p style=\"color: #334155; font-size: 15px;\">Xin chào,</p>"
                + "<p style=\"color: #334155; font-size: 15px;\">" + header + "</p>"
                + "<div style=\"background-color: #eff6ff; border: 1px dashed #2563eb; border-radius: 6px; padding: 16px; text-align: center; margin: 24px 0;\">"
                + "<span style=\"font-size: 32px; font-weight: bold; letter-spacing: 6px; color: #1d4ed8;\">" + otp + "</span>"
                + "</div>"
                + "<p style=\"color: #64748b; font-size: 13px;\">Mã OTP này có hiệu lực trong vòng <b>" + Constant.OTP_VALIDITY_MINUTES + " phút</b>. Vui lòng không chia sẻ mã này cho bất kỳ ai.</p>"
                + "<hr style=\"border: none; border-top: 1px solid #e2e8f0; margin: 20px 0;\" />"
                + "<p style=\"color: #94a3b8; font-size: 12px; text-align: center;\">Email này được gửi tự động, vui lòng không phản hồi.</p>"
                + "</div>";
    }
}
