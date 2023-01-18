#lang racket

(provide
  (struct-out options)
  (struct-out exclusion-set)
  exclusion-set-add
  exclusion-set-union
  exclusion-set-member?
  parse-options)

(require
  (prefix-in std-headers/ "standard-headers.rkt")
  file/glob)

(struct exclusion-set
  (literals ; (set)
   glob-patterns) ; (list-of string?)
  #:transparent)

(define (exclusion-set-add ex-set path)
  (match ex-set
    [(exclusion-set literals glob-patterns)
     (if (or (string-contains? path "*") (string-contains? path "?"))
      (exclusion-set literals (cons path glob-patterns))
      (exclusion-set (set-add path literals) glob-patterns))]))

(define (exclusion-set-union ex-set other)
  (match ex-set
    [(exclusion-set literals glob-patterns)
      (match other
        [(? set?)
         (exclusion-set (set-union literals other) glob-patterns)] 
        [(exclusion-set other-literals other-glob-patterns)
         (exclusion-set (set-union literals other-literals) (append glob-patterns other-glob-patterns))])]))

(define (exclusion-set-member? ex-set path)
  (match ex-set
    [(exclusion-set literals glob-patterns)
     (or (set-member? literals path)
      (ormap (λ (pattern) (glob-match? pattern path)) glob-patterns))]))

(struct options
  (extensions ; (list-of string?): file extensions, sans period
   exclusions ; (set-of string?): #include'd headers to omit from graph
   paths) ; (list-of path?): files/directories of source code
        #:transparent)

(define *default-extensions*
  '("c" "cc" "cpp" "cxx" "C" "h" "hpp" "hxx"))

(define (parse-options argv)
  (define extensions (make-parameter '()))
  (define exclusions (make-parameter (exclusion-set (set) '())))
  (command-line
    #:program "graph-includes"
    #:argv argv
    #:multi
    [("--extension") EXTENSION 
                          "Consider files with the extension"
                         (extensions (cons EXTENSION (extensions)))]
    [("--exclude") EXCLUSION
                          "Omit header from graph output"
                          (exclusions (exclusion-set-add (exclusions) EXCLUSION))]
    #:once-each
    [("--exclude-std-c") "Omit standard C headers from graph output"
            (exclusions (exclusion-set-union (exclusions) std-headers/c))]
    [("--exclude-std-cpp") "Omit standard C++ headers from graph output"
            (exclusions (exclusion-set-union (exclusions) std-headers/c++))]
    [("--exclude-posix") "Omit POSIX standard headers from graph output"
            (exclusions (exclusion-set-union (exclusions) std-headers/posix))]
    #:args paths
    (options 
      ; extensions
      (for/list ([extension
                  (let ([exts (extensions)])
                    (if (empty? exts) *default-extensions* exts))])
        (if (equal? (string-ref extension 0) #\.)
          (substring extension 1)
          extension))
      ; exclusions
      (exclusions)
      ; paths
      paths)))
