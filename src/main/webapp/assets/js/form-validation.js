/**
 * form-validation.js
 * Client-side Bootstrap 5 form validation for all .needs-validation forms.
 * - Intercepts submit, adds .was-validated so Bootstrap shows valid/invalid states.
 * - Custom password-confirm matching if #confirmPassword is present.
 * - Custom file-size checks for poster (5 MB) and video (200 MB).
 */
(function () {
    'use strict';

    var MAX_POSTER_BYTES = 5 * 1024 * 1024;   // 5 MB
    var MAX_VIDEO_BYTES  = 200 * 1024 * 1024;  // 200 MB

    /**
     * Encode a string to UTF-8 bytes and return the byte length.
     */
    function utf8ByteLength(str) {
        return new TextEncoder().encode(str).length;
    }

    /**
     * Set a custom validity message on an input (clears on empty string).
     */
    function setCustomValidity(input, msg) {
        if (input) {
            input.setCustomValidity(msg);
        }
    }

    /**
     * Wire up Bootstrap validation on a single form element.
     */
    function wireForm(form) {
        form.addEventListener('submit', function (event) {
            var valid = true;

            /* --- Password byte-length check (max 72 bytes UTF-8) --- */
            var pwdInput = form.querySelector('input[name="password"]');
            if (pwdInput && pwdInput.value) {
                if (utf8ByteLength(pwdInput.value) > 72) {
                    setCustomValidity(pwdInput, 'Mật khẩu không được vượt quá 72 bytes UTF-8.');
                    valid = false;
                } else {
                    setCustomValidity(pwdInput, '');
                }
            }

            /* --- Password confirmation matching --- */
            var confirmInput = form.querySelector('#confirmPassword');
            if (confirmInput && pwdInput) {
                if (confirmInput.value !== pwdInput.value) {
                    setCustomValidity(confirmInput, 'Xác nhận mật khẩu không khớp.');
                    valid = false;
                } else {
                    setCustomValidity(confirmInput, '');
                }
            }

            /* --- Poster file size (≤ 5 MB) --- */
            var posterInput = form.querySelector('input[name="poster"]');
            if (posterInput && posterInput.files && posterInput.files.length > 0) {
                if (posterInput.files[0].size > MAX_POSTER_BYTES) {
                    setCustomValidity(posterInput, 'Ảnh bìa không được vượt quá 5 MB.');
                    valid = false;
                } else {
                    setCustomValidity(posterInput, '');
                }
            }

            /* --- Video file size (≤ 200 MB) --- */
            var videoInput = form.querySelector('input[name="videoFile"]');
            if (videoInput && videoInput.files && videoInput.files.length > 0) {
                if (videoInput.files[0].size > MAX_VIDEO_BYTES) {
                    setCustomValidity(videoInput, 'File video không được vượt quá 200 MB.');
                    valid = false;
                } else {
                    setCustomValidity(videoInput, '');
                }
            }

            /* --- Image upload for category (≤ 5 MB) --- */
            var catImageInput = form.querySelector('input[name="images1"]');
            if (catImageInput && catImageInput.files && catImageInput.files.length > 0) {
                if (catImageInput.files[0].size > MAX_POSTER_BYTES) {
                    setCustomValidity(catImageInput, 'Ảnh danh mục không được vượt quá 5 MB.');
                    valid = false;
                } else {
                    setCustomValidity(catImageInput, '');
                }
            }

            /* --- Run native HTML5 validity --- */
            if (!form.checkValidity()) {
                valid = false;
            }

            if (!valid) {
                event.preventDefault();
                event.stopPropagation();
            }

            form.classList.add('was-validated');
        }, false);

        /* Clear custom validity on input so user can retype */
        form.querySelectorAll('input, textarea, select').forEach(function (el) {
            el.addEventListener('input', function () {
                if (el.dataset.customCleared !== 'true') {
                    el.setCustomValidity('');
                }
            });
        });
    }

    document.addEventListener('DOMContentLoaded', function () {
        document.querySelectorAll('form.needs-validation').forEach(wireForm);
    });
})();
