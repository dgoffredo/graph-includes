#lang racket

(provide minimal-lex)

(require racket/generator
         threading)

(define (get-quoted-string in quote-char)
 (and (equal? (peek-char in) quote-char)
      (let ([pattern 
             (~a quote-char "((?:\\\\.|[^" quote-char "\\\\])*)" quote-char)])
        (~>> in
          (regexp-match pattern) ; match /'thing'/ or maybe /"thing"/
          second                 ; get what's inside the quotes
          bytes->string/utf-8    ; convert to string (from raw bytes)
          (cons 'string)))))     ; tag with 'string, e.g. '(string . "thing")

(define (get-string in)
  (or (get-quoted-string in #\")
      (get-quoted-string in #\')))

(define (get-line-comment in)
  (and (equal? (peek-string 2 0 in) "//")
       (cons 'comment (read-line in))))

(define (get-block-comment in)
  (and (equal? (peek-string 2 0 in) "/*")
       (cons 'comment (car (regexp-match #px"/\\*.*?\\*/" in)))))

(define (get-token in)
  (match (regexp-match #px"\\w+|\\p{P}|\\p{L}|\\p{S}" in)
    [#f #f]
    [(list text _ ...) (cons 'token (bytes->string/utf-8 text))]))

(define (consume-whitespace in)
  (let ([ch (peek-char in)])
    (when (and (not (eof-object? ch)) (char-whitespace? ch))
      (read-char in)
      (consume-whitespace in))))

(define (minimal-lex in)
  (in-generator
    (let loop ()
      (consume-whitespace in)
      (when (not (eof-object? (peek-char in)))
        (yield (or (get-string in)
                   (get-line-comment in)
                   (get-block-comment in)
                   (get-token in)
                   (raise-user-error "Unable to parse any token from input.")))
        (loop)))))
