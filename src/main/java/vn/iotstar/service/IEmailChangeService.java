package vn.iotstar.service;

import vn.iotstar.dto.PendingEmailUpdate;
import vn.iotstar.entity.User;
import vn.iotstar.enums.ResendResult;
import vn.iotstar.enums.VerifyResult;

public interface IEmailChangeService {

    PendingEmailUpdate initiate(User user, String newEmail, PendingEmailUpdate existingPending);

    VerifyResult verifyOtp(PendingEmailUpdate pending, int currentUserId, String inputOtp);

    ResendResult resendOtp(PendingEmailUpdate pending, int currentUserId);

    boolean confirmEmailUpdate(int userId, String newEmail, String oldEmail);

    void resetThrottleForUser(int userId);
}
