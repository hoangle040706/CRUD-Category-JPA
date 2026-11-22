package vn.iotstar.service.impl;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Map;
import org.apache.commons.io.IOUtils;
import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import jakarta.servlet.http.Part;
import vn.iotstar.service.IImageStorageService;
import vn.iotstar.util.Constant;
import vn.iotstar.util.ValidationUtil;

public class CloudinaryStorageServiceImpl implements IImageStorageService {

    private Cloudinary cloudinary;

    public CloudinaryStorageServiceImpl() {
        initCloudinary();
    }

    public CloudinaryStorageServiceImpl(Cloudinary cloudinary) {
        this.cloudinary = cloudinary;
    }

    private void initCloudinary() {
        String cloudinaryUrl = System.getProperty("CLOUDINARY_URL", System.getenv("CLOUDINARY_URL"));
        if (cloudinaryUrl != null && !cloudinaryUrl.isBlank()) {
            this.cloudinary = new Cloudinary(cloudinaryUrl);
            return;
        }

        String cloudName = System.getProperty("CLOUDINARY_CLOUD_NAME", System.getenv("CLOUDINARY_CLOUD_NAME"));
        String apiKey = System.getProperty("CLOUDINARY_API_KEY", System.getenv("CLOUDINARY_API_KEY"));
        String apiSecret = System.getProperty("CLOUDINARY_API_SECRET", System.getenv("CLOUDINARY_API_SECRET"));

        if (cloudName != null && !cloudName.isBlank()
                && apiKey != null && !apiKey.isBlank()
                && apiSecret != null && !apiSecret.isBlank()) {
            this.cloudinary = new Cloudinary(ObjectUtils.asMap(
                    "cloud_name", cloudName.trim(),
                    "api_key", apiKey.trim(),
                    "api_secret", apiSecret.trim(),
                    "secure", true
            ));
        }
    }

    @Override
    public String uploadAvatar(Part filePart, int userId) throws IOException {
        if (filePart == null || filePart.getSize() == 0) {
            throw new IllegalArgumentException("Vui lòng chọn tệp hình ảnh avatar.");
        }

        if (filePart.getSize() > Constant.MAX_POSTER_SIZE) {
            throw new IllegalArgumentException("Dung lượng ảnh vượt quá giới hạn cho phép (tối đa 5MB).");
        }

        String submittedFileName = filePart.getSubmittedFileName();
        if (submittedFileName == null || !ValidationUtil.hasValidImageExtension(submittedFileName)) {
            throw new IllegalArgumentException("Định dạng file không hợp lệ. Chỉ chấp nhận .jpg, .jpeg, .png, .webp.");
        }

        byte[] bytes;
        try (InputStream is = filePart.getInputStream()) {
            bytes = IOUtils.toByteArray(is);
        }

        if (!ValidationUtil.isValidImageMagicBytes(bytes)) {
            throw new IllegalArgumentException("Nội dung tệp không phải định dạng hình ảnh hợp lệ (Magic Bytes không khớp).");
        }

        // Nếu Cloudinary khả dụng -> Upload lên Cloudinary
        if (this.cloudinary != null) {
            try {
                @SuppressWarnings("unchecked")
                Map<String, Object> uploadResult = this.cloudinary.uploader().upload(bytes, ObjectUtils.asMap(
                        "public_id", "avatars/user_" + userId,
                        "overwrite", true,
                        "invalidate", true,
                        "resource_type", "image"
                ));
                String secureUrl = (String) uploadResult.get("secure_url");
                if (secureUrl != null && !secureUrl.isBlank()) {
                    return secureUrl;
                }
            } catch (Exception e) {
                System.err.println("[Cloudinary Warning] Upload failed, falling back to local: " + e.getMessage());
            }
        }

        // Fallback lưu local khi Cloudinary chưa cấu hình hoặc upload lỗi
        String ext = "jpg";
        String lower = submittedFileName.toLowerCase();
        if (lower.endsWith(".png")) ext = "png";
        else if (lower.endsWith(".webp")) ext = "webp";

        String localFileName = "user_" + userId + "." + ext;
        File localFile = new File(Constant.getAvatarDir(), localFileName);
        try (FileOutputStream fos = new FileOutputStream(localFile)) {
            fos.write(bytes);
        }
        return localFileName;
    }
}
