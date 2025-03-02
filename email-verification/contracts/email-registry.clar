;; email-registry.clar
;; Storage contract for the email verification system

;; Data structure for verification requests
(define-map verification-requests 
  { user: principal } 
  { email-hash: (buff 32), request-time: uint })

;; Data structure for verified emails
(define-map verified-emails 
  { user: principal } 
  { email-hash: (buff 32), verification-code: (buff 32), verification-time: uint })

;; Constants for authorization
(define-constant CONTRACT_OWNER tx-sender)
(define-constant VERIFIER_CONTRACT .email-verification)

;; Error codes
(define-constant ERR_UNAUTHORIZED (err u200))
(define-constant ERR_ALREADY_REQUESTED (err u201))
(define-constant ERR_ALREADY_VERIFIED (err u202))
(define-constant ERR_NOT_REQUESTED (err u203))

;; Register a verification request
;; @param user - Principal of the requesting user
;; @param email-hash - Hash of the email to verify
;; @returns - Success or error code
(define-public (register-request (user principal) (email-hash (buff 32)))
  (begin
    (asserts! (or (is-eq tx-sender VERIFIER_CONTRACT) (is-eq tx-sender CONTRACT_OWNER)) ERR_UNAUTHORIZED)
    (asserts! (is-none (map-get? verification-requests {user: user})) ERR_ALREADY_REQUESTED)
    (asserts! (is-none (map-get? verified-emails {user: user})) ERR_ALREADY_VERIFIED)
    
    (map-set verification-requests 
      {user: user} 
      {email-hash: email-hash, request-time: block-height})
    
    (ok true)))

;; Register a verified email
;; @param user - Principal of the verified user
;; @param email-hash - Hash of the verified email
;; @param verification-code - Code used for verification
;; @returns - Success or error code
(define-public (register-verified (user principal) (email-hash (buff 32)) (verification-code (buff 32)))
  (begin
    (asserts! (or (is-eq tx-sender VERIFIER_CONTRACT) (is-eq tx-sender CONTRACT_OWNER)) ERR_UNAUTHORIZED)
    (asserts! (is-some (map-get? verification-requests {user: user})) ERR_NOT_REQUESTED)
    (asserts! (is-none (map-get? verified-emails {user: user})) ERR_ALREADY_VERIFIED)
    
    (map-set verified-emails 
      {user: user} 
      {email-hash: email-hash, verification-code: verification-code, verification-time: block-height})
    
    (map-delete verification-requests {user: user})
    
    (ok true)))

;; Check if an email is verified for a user
;; @param user - Principal to check
;; @returns - Boolean indicating verification status
(define-read-only (is-email-verified (user principal))
  (is-some (map-get? verified-emails {user: user})))

;; Get verified email hash
;; @param user - Principal to check
;; @returns - Email hash or none
(define-read-only (get-verified-email-hash (user principal))
  (match (map-get? verified-emails {user: user})
    verified-data (some (get email-hash verified-data))
    none))
