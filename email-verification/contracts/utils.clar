;; utils.clar
;; Utility functions for the email verification system

;; Check if a hash is valid for verification
;; @param hash - The hash to verify
;; @returns - Boolean indicating if valid
(define-read-only (is-valid-hash (hash (buff 32)))
  (is-eq (len hash) u32))

;; Format checking for verification codes
;; @param code - The verification code
;; @returns - Boolean indicating if valid format
(define-read-only (is-valid-verification-code (code (buff 32)))
  (is-eq (len code) u32))
