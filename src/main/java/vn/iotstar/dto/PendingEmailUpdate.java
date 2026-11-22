package vn.iotstar.dto;

import java.io.Serializable;

/**
 * Data Transfer Object holding pending email change state in session.
 */
public class PendingEmailUpdate implements Serializable {
    private static final long serialVersionUID = 1L;

    private final int userId;
    private final String newEmail;
    private byte[] otpHashBytes;
    private long expiresAtMillis;
    private int attempts;
    private int resendCount;
    private long lastSentAtMillis;
    private volatile boolean mailDeliveryFailed;
    private int currentSendSeq;

    public PendingEmailUpdate(int userId, String newEmail, byte[] otpHashBytes, long expiresAtMillis, long lastSentAtMillis) {
        this.userId = userId;
        this.newEmail = newEmail != null ? newEmail.trim().toLowerCase() : "";
        this.otpHashBytes = otpHashBytes;
        this.expiresAtMillis = expiresAtMillis;
        this.lastSentAtMillis = lastSentAtMillis;
        this.attempts = 0;
        this.resendCount = 0;
        this.mailDeliveryFailed = false;
        this.currentSendSeq = 1;
    }

    public int getUserId() {
        return userId;
    }

    public String getNewEmail() {
        return newEmail;
    }

    public byte[] getOtpHashBytes() {
        return otpHashBytes;
    }

    public void setOtpHashBytes(byte[] otpHashBytes) {
        this.otpHashBytes = otpHashBytes;
    }

    public long getExpiresAtMillis() {
        return expiresAtMillis;
    }

    public void setExpiresAtMillis(long expiresAtMillis) {
        this.expiresAtMillis = expiresAtMillis;
    }

    public int getAttempts() {
        return attempts;
    }

    public void incrementAttempts() {
        this.attempts++;
    }

    public int getResendCount() {
        return resendCount;
    }

    public void incrementResendCount() {
        this.resendCount++;
    }

    public long getLastSentAtMillis() {
        return lastSentAtMillis;
    }

    public void setLastSentAtMillis(long lastSentAtMillis) {
        this.lastSentAtMillis = lastSentAtMillis;
    }

    public boolean isMailDeliveryFailed() {
        return mailDeliveryFailed;
    }

    public void setMailDeliveryFailed(boolean mailDeliveryFailed) {
        this.mailDeliveryFailed = mailDeliveryFailed;
    }

    public int getCurrentSendSeq() {
        return currentSendSeq;
    }

    public int incrementAndGetSendSeq() {
        return ++this.currentSendSeq;
    }
}
