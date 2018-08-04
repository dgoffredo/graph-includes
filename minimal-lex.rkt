#lang at-exp racket

(provide minimal-lex)

(require racket/generator
         threading)

(define (px . args)
  ; This function is meant to be used with @ reader notation, so that
  ;
  ;     @px{This "has" @3 args}
  ;
  ; reads as
  ;
  ;     (pregexp (~a "This \"has\" " 3 " args"))
  ;
  (pregexp (apply ~a args)))

(define (quoted-string-getter quote-char)
  ; Note on the regex: A quoted string begins with a quote and ends with a
  ; quote, and inside there are zero or more of either a character preceded by
  ; a backslash (escaped character), or a non-quote, non-backslash character.
  (let ([regex @px{^@|quote-char|((?:\\.|[^@|quote-char|\\])*)@|quote-char|}])
    (lambda (in)
      (match (regexp-try-match regex in)
        [#f #f]
        [(list _ inside)
         (~>> inside bytes->string/utf-8 (cons 'string))]))))
    
(define get-single-quoted-string (quoted-string-getter #\'))

(define get-double-quoted-string (quoted-string-getter #\"))

(define (get-string in)
  (or (get-single-quoted-string in)
      (get-double-quoted-string in)))

(define (get-line-comment in)
  (and (equal? (peek-string 2 0 in) "//")
       (cons 'comment (read-line in))))

(define (get-block-comment in)
  (and (equal? (peek-string 2 0 in) "/*")
       (cons 'comment (car (regexp-match #px"/\\*.*?\\*/" in)))))

(define (get-token in)
  (match (regexp-try-match #px"^(\\w+|\\p{P}|\\p{L}|\\p{S})" in)
    [#f #f]
    [(list text _ ...)
     (~>> text bytes->string/utf-8 (cons 'token))]))

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
