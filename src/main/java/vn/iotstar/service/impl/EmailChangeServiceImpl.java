package vn.iotstar.service.impl;

import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.Clock;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import vn.iotstar.dao.IUserDao;
import vn.iotstar.dao.UserDao;
import vn.iotstar.dto.PendingEmailUpdate;
import vn.iotstar.entity.User;
import vn.iotstar.enums.ResendResult;
import vn.iotstar.enums.VerifyResult;
import vn.iotstar.service.IEmailChangeService;
import vn.iotstar.service.IOtpMailer;
import vn.iotstar.util.HashUtil;

public class EmailChangeServiceImpl implements IEmailChangeService {

    public static final int MAX_ATTEMPTS = 5;
    public static final int MAX_RESENDS = 3;
    public static final long COOLDOWN_MILLIS = 60_000L;
    public static final long OTP_VALIDITY_MILLIS = 5 * 60_000L;
    public static final int MAX_EMAILS_PER_HOUR = 10;

    private final Clock clock;
    private final IOtpMailer mailer;
    private final IUserDao userDao;
    private final SecureRandom secureRandom;
    private final Map<Integer, UserThrottle> throttleMap = new ConcurrentHashMap<>();

    public EmailChangeServiceImpl() {
        this(Clock.systemDefaultZone(), new AsyncOtpMailerImpl(), new UserDao());
    }

    public EmailChangeServiceImpl(Clock clock, IOtpMailer mailer, IUserDao userDao) {
        this.clock = clock;
        this.mailer = mailer;
        this.userDao = userDao;
        this.secureRandom = new SecureRandom();
    }

    @Override
    public PendingEmailUpdate initiate(User user, String newEmail, PendingEmailUpdate existingPending) {
        if (user == null) {
            throw new IllegalArgumentException("User cannot be null");
        }
        String normalizedNewEmail = newEmail != null ? newEmail.trim().toLowerCase() : "";
        if (normalizedNewEmail.isEmpty()) {
            throw new IllegalArgumentException("Email cannot be empty");
        }

        long now = clock.millis();
        UserThrottle throttle = throttleMap.computeIfAbsent(user.getId(), id -> new UserThrottle());

        if (throttle.isHourlyLimitExceeded(now, MAX_EMAILS_PER_HOUR)) {
            throw new IllegalStateException("Bạn đã vượt quá giới hạn gửi email trong 1 giờ. Vui lòng thử lại sau.");
        }

        if (existingPending != null && !existingPending.isMailDeliveryFailed()) {
            if (now - existingPending.getLastSentAtMillis() < COOLDOWN_MILLIS) {
                throw new IllegalStateException("Vui lòng chờ 60 giây trước khi yêu cầu đổi email mới.");
            }
        }

        if (throttle.isCooldownActive(now, COOLDOWN_MILLIS)) {
            throw new IllegalStateException("Vui lòng chờ 60 giây trước khi yêu cầu đổi email mới.");
        }

        int code = secureRandom.nextInt(1_000_000);
        String otp = String.format("%06d", code);
        byte[] otpHashBytes = HashUtil.sha256Bytes(otp);

        PendingEmailUpdate pending = new PendingEmailUpdate(
                user.getId(),
                normalizedNewEmail,
                otpHashBytes,
                now + OTP_VALIDITY_MILLIS,
                now
        );

        throttle.recordSend(now);

        int seq = pending.getCurrentSendSeq();
        mailer.sendOtpAsync(normalizedNewEmail, otp).thenAccept(success -> {
            if (!success) {
                synchronized (pending) {
                    if (pending.getCurrentSendSeq() == seq) {
                        pending.setMailDeliveryFailed(true);
                    }
                }
            }
        });

        return pending;
    }

    @Override
    public VerifyResult verifyOtp(PendingEmailUpdate pending, int currentUserId, String inputOtp) {
        if (pending == null) {
            return VerifyResult.UNAUTHORIZED;
        }

        synchronized (pending) {
            if (pending.getUserId() != currentUserId) {
                return VerifyResult.UNAUTHORIZED;
            }

            if (pending.getAttempts() >= MAX_ATTEMPTS) {
                return VerifyResult.ATTEMPTS_EXCEEDED;
            }

            if (clock.millis() > pending.getExpiresAtMillis()) {
                return VerifyResult.EXPIRED;
            }

            if (inputOtp == null || inputOtp.isBlank()) {
                pending.incrementAttempts();
                if (pending.getAttempts() >= MAX_ATTEMPTS) {
                    return VerifyResult.ATTEMPTS_EXCEEDED;
                }
                return VerifyResult.INVALID_OTP;
            }

            byte[] inputHash = HashUtil.sha256Bytes(inputOtp.trim());
            boolean matches = MessageDigest.isEqual(inputHash, pending.getOtpHashBytes());

            if (!matches) {
                pending.incrementAttempts();
                if (pending.getAttempts() >= MAX_ATTEMPTS) {
                    return VerifyResult.ATTEMPTS_EXCEEDED;
                }
                return VerifyResult.INVALID_OTP;
            }

            return VerifyResult.SUCCESS;
        }
    }

    @Override
    public ResendResult resendOtp(PendingEmailUpdate pending, int currentUserId) {
        if (pending == null) {
            return ResendResult.UNAUTHORIZED;
        }

        synchronized (pending) {
            if (pending.getUserId() != currentUserId) {
                return ResendResult.UNAUTHORIZED;
            }

            if (pending.getResendCount() >= MAX_RESENDS) {
                return ResendResult.MAX_RESENDS_EXCEEDED;
            }

            long now = clock.millis();
            if (!pending.isMailDeliveryFailed() && (now - pending.getLastSentAtMillis() < COOLDOWN_MILLIS)) {
                return ResendResult.COOLDOWN_ACTIVE;
            }

            UserThrottle throttle = throttleMap.computeIfAbsent(currentUserId, id -> new UserThrottle());
            if (throttle.isHourlyLimitExceeded(now, MAX_EMAILS_PER_HOUR)) {
                return ResendResult.MAX_RESENDS_EXCEEDED;
            }

            int code = secureRandom.nextInt(1_000_000);
            String otp = String.format("%06d", code);
            pending.setOtpHashBytes(HashUtil.sha256Bytes(otp));
            pending.setLastSentAtMillis(now);
            pending.setExpiresAtMillis(now + OTP_VALIDITY_MILLIS);
            pending.incrementResendCount();
            pending.setMailDeliveryFailed(false);
            int seq = pending.incrementAndGetSendSeq();

            throttle.recordSend(now);

            mailer.sendOtpAsync(pending.getNewEmail(), otp).thenAccept(success -> {
                if (!success) {
                    synchronized (pending) {
                        if (pending.getCurrentSendSeq() == seq) {
                            pending.setMailDeliveryFailed(true);
                        }
                    }
                }
            });

            return ResendResult.SENT;
        }
    }

    @Override
    public boolean confirmEmailUpdate(int userId, String newEmail, String oldEmail) {
        String normalizedNewEmail = newEmail != null ? newEmail.trim().toLowerCase() : "";
        boolean updated = userDao.updateEmail(userId, normalizedNewEmail);
        if (updated) {
            if (oldEmail != null && !oldEmail.isBlank()) {
                mailer.sendNoticeAsync(oldEmail.trim().toLowerCase(),
                        "Địa chỉ email của tài khoản trên MyVideo Platform đã được cập nhật thành công thành: " + normalizedNewEmail);
            }
            return true;
        }
        return false;
    }

    @Override
    public void resetThrottleForUser(int userId) {
        throttleMap.remove(userId);
    }

    public static class UserThrottle {
        private long lastSentAtMillis = 0;
        private final List<Long> sendTimestamps = new ArrayList<>();

        public synchronized void recordSend(long timestamp) {
            this.lastSentAtMillis = timestamp;
            this.sendTimestamps.add(timestamp);
            cleanOld(timestamp);
        }

        public synchronized boolean isCooldownActive(long now, long cooldownMillis) {
            return now - lastSentAtMillis < cooldownMillis;
        }

        public synchronized boolean isHourlyLimitExceeded(long now, int maxPerHour) {
            cleanOld(now);
            return sendTimestamps.size() >= maxPerHour;
        }

        private void cleanOld(long now) {
            long oneHourAgo = now - 3600_000L;
            sendTimestamps.removeIf(ts -> ts < oneHourAgo);
        }

        public synchronized long getLastSentAtMillis() {
            return lastSentAtMillis;
        }
    }
}
