#lang racket

(provide minimal-lex)

(require racket/generator
         threading)

(define (debug . args)
  (displayln (apply ~s args)  (current-error-port)))

(define (get-double-quoted-string in)
  (and (equal? (peek-char in) #\")
       (cons 'string (read in))))

(define (get-single-quoted-string in)
  (and (equal? (peek-char in) #\')
       (~>> in 
         (regexp-match #px"'((?:[^']|\\')*)'") ; match /'thing'/
         second                                ; #"thing"
         bytes->string/utf-8                   ; "thing"
         (cons 'string))))                     ; '(string . "thing")

(define (get-string in)
  (or (get-double-quoted-string in)
      (get-single-quoted-string in)))

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
      (when (not (eof-object? (peek-char in)))
        (consume-whitespace in)
        (let ([lexeme (or (get-string in)
                          (get-line-comment in)
                          (get-block-comment in)
                          (get-token in))])
          (when lexeme
            (yield lexeme)
            (loop)))))))
