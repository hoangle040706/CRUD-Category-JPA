package vn.iotstar.service;

import java.util.concurrent.CompletableFuture;

/**
 * Mailer service interface for sending OTP and notification emails.
 */
public interface IOtpMailer {
    /**
     * Send OTP code asynchronously to the given email address.
     *
     * @param toEmail recipient email address
     * @param otp 6-digit plain OTP code
     * @return CompletableFuture completing with true if successfully sent, false if failed
     */
    CompletableFuture<Boolean> sendOtpAsync(String toEmail, String otp);

    /**
     * Send security notification email asynchronously.
     *
     * @param toEmail recipient email address
     * @param message notification message
     * @return CompletableFuture completing with true if successfully sent, false if failed
     */
    CompletableFuture<Boolean> sendNoticeAsync(String toEmail, String message);
}
