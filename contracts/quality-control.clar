;; Quality Control Contract

(define-map quality-checks
  { product-id: uint }
  {
    inspector: principal,
    status: (string-ascii 20),
    notes: (string-utf8 500),
    timestamp: uint
  }
)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_NOT_FOUND (err u404))

(define-public (perform-quality-check (product-id uint) (status (string-ascii 20)) (notes (string-utf8 500)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (map-set quality-checks
      { product-id: product-id }
      {
        inspector: tx-sender,
        status: status,
        notes: notes,
        timestamp: block-height
      }
    )
    (ok true)
  )
)

(define-read-only (get-quality-check (product-id uint))
  (map-get? quality-checks { product-id: product-id })
)

