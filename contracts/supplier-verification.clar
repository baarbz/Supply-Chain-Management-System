;; Supplier Verification Contract

(define-map suppliers
  { supplier-id: principal }
  {
    name: (string-utf8 100),
    verification-status: (string-ascii 20),
    verification-date: uint
  }
)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_NOT_FOUND (err u404))

(define-public (register-supplier (supplier-id principal) (name (string-utf8 100)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (map-set suppliers
      { supplier-id: supplier-id }
      {
        name: name,
        verification-status: "pending",
        verification-date: u0
      }
    )
    (ok true)
  )
)

(define-public (verify-supplier (supplier-id principal) (status (string-ascii 20)))
  (let
    (
      (supplier (unwrap! (map-get? suppliers { supplier-id: supplier-id }) ERR_NOT_FOUND))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (map-set suppliers
      { supplier-id: supplier-id }
      (merge supplier { verification-status: status, verification-date: block-height })
    )
    (ok true)
  )
)

(define-read-only (get-supplier (supplier-id principal))
  (map-get? suppliers { supplier-id: supplier-id })
)

