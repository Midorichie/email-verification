;; email-verification.clar
;; A decentralized system for verifying email ownership on Stacks blockchain

(define-data-var admin principal tx-sender)

;; Error codes
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ALREADY_VERIFIED (err u101))
(define-constant ERR_INVALID_HASH (err u102))

;; Public functions

;; Request verification for an email address
;; @param email-hash - Hash of the email address to be verified
;; @returns - Success or error code
(define-public (request-verification (email-hash (buff 32)))
  (begin
    (asserts! (is-valid-hash email-hash) ERR_INVALID_HASH)
    (try! (contract-call? .email-registry register-request tx-sender email-hash))
    (ok true)))

;; Confirm verification after off-chain verification process
;; @param user - Principal of the user
;; @param email-hash - Hash of the email address
;; @param verification-code - Code provided during verification
;; @returns - Success or error code
(define-public (confirm-verification (user principal) (email-hash (buff 32)) (verification-code (buff 32)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) ERR_UNAUTHORIZED)
    (try! (contract-call? .email-registry register-verified user email-hash verification-code))
    (ok true)))

;; Private functions

;; Check if hash matches required format
(define-private (is-valid-hash (hash (buff 32)))
  (is-eq (len hash) u32))

;; Administrative functions

;; Change admin address
;; @param new-admin - Principal address of new admin
;; @returns - Success or error code
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) ERR_UNAUTHORIZED)
    (ok (var-set admin new-admin))))
