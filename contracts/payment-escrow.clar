;; Payment Escrow Contract

(define-map escrows
  { escrow-id: uint }
  {
    payer: principal,
    payee: principal,
    amount: uint,
    status: (string-ascii 20),
    release-height: uint
  }
)

(define-data-var escrow-nonce uint u0)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_INVALID_STATUS (err u400))

(define-public (create-escrow (payee principal) (amount uint) (release-height uint))
  (let
    (
      (new-escrow-id (+ (var-get escrow-nonce) u1))
    )
    (map-set escrows
      { escrow-id: new-escrow-id }
      {
        payer: tx-sender,
        payee: payee,
        amount: amount,
        status: "pending",
        release-height: release-height
      }
    )
    (var-set escrow-nonce new-escrow-id)
    (ok new-escrow-id)
  )
)

(define-public (release-escrow (escrow-id uint))
  (let
    (
      (escrow (unwrap! (map-get? escrows { escrow-id: escrow-id }) ERR_NOT_FOUND))
    )
    (asserts! (is-eq tx-sender (get payer escrow)) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get status escrow) "pending") ERR_INVALID_STATUS)
    (asserts! (>= block-height (get release-height escrow)) ERR_UNAUTHORIZED)
    (map-set escrows
      { escrow-id: escrow-id }
      (merge escrow { status: "released" })
    )
    (ok true)
  )
)

(define-read-only (get-escrow (escrow-id uint))
  (map-get? escrows { escrow-id: escrow-id })
)

