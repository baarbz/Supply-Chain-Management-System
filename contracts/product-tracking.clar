;; Product Tracking Contract

(define-map products
  { product-id: uint }
  {
    manufacturer: principal,
    current-owner: principal,
    status: (string-ascii 20),
    timestamp: uint
  }
)

(define-data-var product-nonce uint u0)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_NOT_FOUND (err u404))

(define-public (register-product (manufacturer principal))
  (let
    (
      (new-product-id (+ (var-get product-nonce) u1))
    )
    (map-set products
      { product-id: new-product-id }
      {
        manufacturer: manufacturer,
        current-owner: manufacturer,
        status: "manufactured",
        timestamp: block-height
      }
    )
    (var-set product-nonce new-product-id)
    (ok new-product-id)
  )
)

(define-public (update-product-status (product-id uint) (new-status (string-ascii 20)))
  (let
    (
      (product (unwrap! (map-get? products { product-id: product-id }) ERR_NOT_FOUND))
    )
    (asserts! (is-eq tx-sender (get current-owner product)) ERR_UNAUTHORIZED)
    (map-set products
      { product-id: product-id }
      (merge product { status: new-status, timestamp: block-height })
    )
    (ok true)
  )
)

(define-public (transfer-ownership (product-id uint) (new-owner principal))
  (let
    (
      (product (unwrap! (map-get? products { product-id: product-id }) ERR_NOT_FOUND))
    )
    (asserts! (is-eq tx-sender (get current-owner product)) ERR_UNAUTHORIZED)
    (map-set products
      { product-id: product-id }
      (merge product { current-owner: new-owner, timestamp: block-height })
    )
    (ok true)
  )
)

(define-read-only (get-product (product-id uint))
  (map-get? products { product-id: product-id })
)

