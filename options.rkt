#lang racket

(provide (struct-out options)
         parse-options)

(require (prefix-in std-headers/ "standard-headers.rkt"))

(struct options
  (extensions ; (list-of string?): file extensions, sans period
   exclusions ; (set-of string?): #include'd headers to omit from graph
   paths) ; (list-of path?): files/directories of source code
        #:transparent)

(define *default-extensions*
  '("c" "cc" "cpp" "cxx" "C" "h" "hpp" "hxx"))

(define (parse-options argv)
  (define extensions (make-parameter '()))
  (define exclusions (make-parameter (set)))
  (command-line
    #:program "graph-includes"
    #:argv argv
    #:multi
    [("--extension") EXTENSION 
                          "Consider files with the extension"
                         (extensions (cons EXTENSION (extensions)))]
    [("--exclude") EXCLUSION
                          "Omit header from graph output"
                          (exclusions (set-add (exclusions) EXCLUSION))]
    #:once-each
    [("--exclude-std-c") "Omit standard C headers from graph output"
            (exclusions (set-union (exclusions) std-headers/c))]
    [("--exclude-std-cpp") "Omit standard C++ headers from graph output"
            (exclusions (set-union (exclusions) std-headers/c++))]
    [("--exclude-posix") "Omit POSIX standard headers from graph output"
            (exclusions (set-union (exclusions) std-headers/posix))]
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
