package vn.iotstar;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import vn.iotstar.util.ValidationUtil;

import java.nio.charset.StandardCharsets;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

@DisplayName("ValidationUtil Unit Tests")
class ValidationTest {

    @Nested
    @DisplayName("Email Validation Tests")
    class EmailValidationTests {

        @ParameterizedTest(name = "Valid email: {0}")
        @ValueSource(strings = {
                "user@example.com",
                "john.doe@sub.domain.vn",
                "admin123@iotstar.edu.vn",
                "test+filter@gmail.com",
                "customer_service@company.org",
                "first.last-tag@email.io"
        })
        void testValidEmail(String email) {
            assertTrue(ValidationUtil.isValidEmail(email), () -> "Expected valid email: " + email);
        }

        @ParameterizedTest(name = "Invalid email: {0}")
        @ValueSource(strings = {
                "",
                "   ",
                "plainaddress",
                "@missinguser.com",
                "missingdomain@",
                "user@domain",
                "user@domain.",
                "user@.com",
                "user@domain..com",
                "two@@signs.com",
                "user space@domain.com"
        })
        void testInvalidEmail(String email) {
            assertFalse(ValidationUtil.isValidEmail(email), () -> "Expected invalid email: " + email);
        }

        @Test
        void testNullEmail() {
            assertFalse(ValidationUtil.isValidEmail(null));
        }
    }

    @Nested
    @DisplayName("Vietnamese Phone Number Validation Tests")
    class PhoneValidationTests {

        @ParameterizedTest(name = "Valid VN phone: {0}")
        @ValueSource(strings = {
                "0912345678",
                "0387654321",
                "0701234567",
                "0868888888",
                "0523456789",
                "0412345678",
                "0612345678"
        })
        void testValidPhone(String phone) {
            assertTrue(ValidationUtil.isValidPhone(phone), () -> "Expected valid phone: " + phone);
        }

        @ParameterizedTest(name = "Invalid phone: {0}")
        @ValueSource(strings = {
                "",
                "   ",
                "0123456789",    // 01 prefix is old 11-digit prefix, not valid in modern 10-digit format
                "0212345678",    // 02 prefix is landline
                "091234567",     // 9 digits
                "09123456789",   // 11 digits
                "091234567a",    // non-digit character
                "+84912345678",  // country code not matching 0[3-9] 10 digits
                "09 1234 5678",
                "09-1234-5678"
        })
        void testInvalidPhone(String phone) {
            assertFalse(ValidationUtil.isValidPhone(phone), () -> "Expected invalid phone: " + phone);
        }

        @Test
        void testNullPhone() {
            assertFalse(ValidationUtil.isValidPhone(null));
        }
    }

    @Nested
    @DisplayName("Username Validation Tests")
    class UsernameValidationTests {

        @ParameterizedTest(name = "Valid username: {0}")
        @ValueSource(strings = {
                "abc",
                "admin",
                "user_name",
                "JohnDoe123",
                "test_user_99",
                "123456",
                "____________________"
        })
        void testValidUsername(String username) {
            assertTrue(ValidationUtil.isValidUsername(username), () -> "Expected valid username: " + username);
        }

        @Test
        void testValidUsernameBoundaryMaxLength() {
            String maxLengthUsername = "a".repeat(50);
            assertTrue(ValidationUtil.isValidUsername(maxLengthUsername));
        }

        @ParameterizedTest(name = "Invalid username: {0}")
        @ValueSource(strings = {
                "",
                "  ",
                "ab",           // less than 3 characters
                "a",
                "user-name",    // hyphen not allowed
                "user.name",    // dot not allowed
                "user name",    // space not allowed
                "user@name",    // special characters not allowed
                "admin#1"
        })
        void testInvalidUsername(String username) {
            assertFalse(ValidationUtil.isValidUsername(username), () -> "Expected invalid username: " + username);
        }

        @Test
        void testInvalidUsernameExceedsMaxLength() {
            String tooLongUsername = "a".repeat(51);
            assertFalse(ValidationUtil.isValidUsername(tooLongUsername));
        }

        @Test
        void testNullUsername() {
            assertFalse(ValidationUtil.isValidUsername(null));
        }
    }

    @Nested
    @DisplayName("Password Validation Tests")
    class PasswordValidationTests {

        @ParameterizedTest(name = "Valid password: {0}")
        @ValueSource(strings = {
                "123456",
                "password",
                "Secret@2026",
                "very-secure-password-#99"
        })
        void testValidPassword(String password) {
            assertTrue(ValidationUtil.isValidPassword(password), () -> "Expected valid password: " + password);
        }

        @Test
        void testValidPasswordBoundaries() {
            // Exactly 6 bytes
            String sixBytes = "abcdef";
            assertTrue(ValidationUtil.isValidPassword(sixBytes));

            // Exactly 72 bytes (bcrypt maximum limit)
            String seventyTwoBytes = "a".repeat(72);
            assertTrue(ValidationUtil.isValidPassword(seventyTwoBytes));

            // UTF-8 multibyte characters
            // "MậtKhẩu" in UTF-8: M(1) + ậ(3) + t(1) + K(1) + h(1) + ẩ(3) + u(1) = 11 bytes
            String vietnamesePassword = "MậtKhẩu123";
            assertTrue(ValidationUtil.isValidPassword(vietnamesePassword));
        }

        @Test
        void testInvalidPasswordTooShort() {
            assertFalse(ValidationUtil.isValidPassword(""));
            assertFalse(ValidationUtil.isValidPassword("12345")); // 5 bytes
            assertFalse(ValidationUtil.isValidPassword("a"));
        }

        @Test
        void testInvalidPasswordTooLong() {
            String seventyThreeBytes = "a".repeat(73);
            assertFalse(ValidationUtil.isValidPassword(seventyThreeBytes));
        }

        @Test
        void testNullPassword() {
            assertFalse(ValidationUtil.isValidPassword(null));
        }
    }

    @Nested
    @DisplayName("YouTube URL Validation Tests")
    class YouTubeUrlValidationTests {

        @ParameterizedTest(name = "Valid YouTube URL: {0}")
        @ValueSource(strings = {
                "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
                "http://www.youtube.com/watch?v=dQw4w9WgXcQ",
                "https://youtube.com/watch?v=dQw4w9WgXcQ",
                "http://youtube.com/watch?v=dQw4w9WgXcQ",
                "www.youtube.com/watch?v=dQw4w9WgXcQ",
                "youtube.com/watch?v=dQw4w9WgXcQ",
                "https://youtu.be/dQw4w9WgXcQ",
                "http://youtu.be/dQw4w9WgXcQ",
                "youtu.be/dQw4w9WgXcQ",
                "https://www.youtube.com/embed/dQw4w9WgXcQ",
                "https://www.youtube.com/shorts/dQw4w9WgXcQ",
                "https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=10s",
                "https://youtu.be/dQw4w9WgXcQ?si=abcdefghijk"
        })
        void testValidYouTubeUrl(String url) {
            assertTrue(ValidationUtil.isValidYouTubeUrl(url), () -> "Expected valid YouTube URL: " + url);
        }

        @ParameterizedTest(name = "Invalid YouTube URL: {0}")
        @ValueSource(strings = {
                "",
                "   ",
                "https://vimeo.com/123456789",
                "https://dailymotion.com/video/x7tgad0",
                "https://www.youtube.com/watch?v=short",       // less than 11 ID chars
                "https://youtu.be/short",
                "https://www.notyoutube.com/watch?v=dQw4w9WgXcQ",
                "just-plain-text",
                "https://google.com"
        })
        void testInvalidYouTubeUrl(String url) {
            assertFalse(ValidationUtil.isValidYouTubeUrl(url), () -> "Expected invalid YouTube URL: " + url);
        }

        @Test
        void testNullYouTubeUrl() {
            assertFalse(ValidationUtil.isValidYouTubeUrl(null));
        }
    }
}
