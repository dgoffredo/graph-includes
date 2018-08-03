#lang racket

(provide (struct-out options)
         parse-options)

(struct options (extensions ; (list-of string?): file extensions, sans period
                 paths)     ; (list-of path?): files/directories of source code
        #:transparent)

(define (parse-options argv)
  (define extensions (make-parameter '()))
  (command-line
    #:program "graph-includes"
    #:argv argv
    #:multi
    [("-e" "--extension") EXTENSION 
                          "Consider files with the extension"
                         (extensions (cons EXTENSION (extensions)))]
    #:args paths
    (options 
      ; extensions
      (for/list ([extension
                  (let ([exts (extensions)])
                    (if (empty? exts) '("c" "cc" "cpp" "h" "hpp") exts))])
        (if (equal? (string-ref extension 0) #\.)
          (substring extension 1)
          extension))
      ;paths
      paths)))
