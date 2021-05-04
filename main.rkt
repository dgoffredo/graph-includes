#lang racket

(require "graph-includes.rkt"
         "options.rkt"
         file/glob
         threading)

(define (path-patterns paths extensions)
  (flatten
    (for/list ([path paths])
      (cond
        [(file-exists? path) path]
        [(directory-exists? path)
         (list
           (for/list ([ext extensions])
             (build-path path (~a "*." ext)))
           (for/list ([ext extensions])
               (build-path path "**" (~a "*." ext))))]
        [else
         (raise-user-error (~a "The path " path " doesn't exist."))]))))

(define (read-lines [in (current-input-port)])
  (sequence->list (in-lines in)))

(define (run args)
  (match (parse-options args)
    [(options extensions exclusions paths)
     (let ([paths (if (empty? paths) (read-lines) paths)])
       (~> (path-patterns paths extensions)
         glob 
         (graphviz-from exclusions)
         display))]))

(module+ main
  (run (current-command-line-arguments)))
