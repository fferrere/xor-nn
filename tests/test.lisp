(in-package :xor-nn/test)

(define-test xor-training
  (xor-nn:setup-network)
  (is equal 1 (xor-nn:xor 0 0))
  (is equal 1 (xor-nn:xor 0 1))
  (is equal 1 (xor-nn:xor 1 0))
  (is equal 1 (xor-nn:xor 1 1))
  (xor-nn:feed-network :rounds 8000)
  (is equal 0 (xor-nn:xor 0 0))
  (is equal 1 (xor-nn:xor 0 1))
  (is equal 1 (xor-nn:xor 1 0))
  (is equal 0 (xor-nn:xor 1 1))
  )
