#lang racket

(provide extract-includes)

(require racket/generator
         threading)

(define (simplify lexemes)
  (~>> lexemes
    (sequence-filter 
      (lambda (lexeme) 
        (not (equal? (car lexeme) 'comment))))
    (sequence-map
      (match-lambda
        [`(string . ,value) value]
        [`(token . ,value)  (string->symbol value)]))))

(define (extract-includes lexemes)
  (in-generator
    (define (emit header)
      (yield header)
      (values 'start '()))

    (for/fold ([state 'start] [pieces '()])
              ([lexeme (simplify lexemes)])
      (match (cons state lexeme)
        [`(start . |#|)
         (values 'before-include pieces)]

        [`(before-include . include)
         (values 'after-include pieces)]

        [`(after-include . <)
         (values 'header-name pieces)]

        [`(header-name . >)
         (emit (~> pieces reverse (map ~a _) (string-join _ "")))]

        [`(header-name . ,(? symbol? piece))
         (values 'header-name (cons piece pieces))]

        [`(after-include . ,(? string? header))
          (emit header)]
        
        [_
         (values 'start '())]))))
