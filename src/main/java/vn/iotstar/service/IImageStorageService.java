package vn.iotstar.service;

import java.io.IOException;
import jakarta.servlet.http.Part;

/**
 * Storage service abstraction for uploading user avatar images.
 */
public interface IImageStorageService {
    /**
     * Upload an avatar file and return the public URL or relative path.
     *
     * @param filePart multipart Part containing the uploaded image
     * @param userId ID of the user uploading the avatar
     * @return secure image URL or path with timestamp version query
     * @throws IOException on read/upload failure
     */
    String uploadAvatar(Part filePart, int userId) throws IOException;
}
