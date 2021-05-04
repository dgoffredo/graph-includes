#lang racket

(provide digraph-from
         graphviz-from)

(require "minimal-lex.rkt"
         "extract-includes.rkt"
         graph
         threading)

(define (included-headers path)
  ; Return a list of the header file paths included by the specified file.
  (displayln (~a "Examining file " path) (current-error-port))
  (let* ([in (open-input-file path)]
         [headers (~> in
                    minimal-lex
                    extract-includes
                    sequence->list)])
    (close-input-port in)
    headers))

(define (basename path)
  ; Return what the UNIX command `basename` would return, e.g.
  ; "foo/bar/baz.txt" -> "baz.txt".
  (let-values ([(base name must-be-dir?) (split-path path)])
    name))

(define (edges-from path)
  ; Return a list of pairs, where each pair represents a directed edge out of
  ; the specified source file and into whichever header files it includes.
  (for/list ([header (included-headers path)])
    (list (~a (basename path)) header)))

(define (edge-worker paths)
  ; Start an interpreter in parallel to calculate include graph edges for the
  ; specified files. Return a channel providing access to the worker. The
  ; worker will put a list of edges on the channel when complete.
  (let ([worker-chan
         (place chan
           (~>> chan
             place-channel-get
             (append-map edges-from)
             (place-channel-put chan)))])
    (place-channel-put worker-chan paths)
    worker-chan))

(define (split-into num-pieces lst)
  ; (split-into 4 '(1 2 3 4 5 6 7 8 9)) -> '((1 2) (3 4) (5 6) (7 8 9))
  ; The behavior is undefined unless 0 < num-pieces <= (length lst).
  (let* ([len        (length lst)]
         [chunk-size (quotient len num-pieces)])
    (let loop ([lst lst] [len len])
      (let ([amount (if (< len (* 2 chunk-size)) len chunk-size)])
        (if (zero? amount)
          '()
          (cons (take lst amount) (loop (drop lst amount) (- len amount))))))))

(define (digraph-from paths exclusions)
  ; Return a directed inclusion graph from the specified list of file paths.
  ; An edge X -> Y in the graph indicates that the source file or header X
  ; includes the header Y.
  (if (empty? paths)
    ; no sources -> empty graph
    (directed-graph '())
    ; Otherwise, spin up some workers to calculate the edges. Then collect the
    ; edges and combine them into a directed graph.
    (~>> paths
      shuffle
      (split-into (min (processor-count) (length paths)))
      (map edge-worker)
      (append-map place-channel-get)
      (filter (match-lambda [(list from to) (not (set-member? exclusions to))]))
      directed-graph)))

(define (graphviz-from paths exclusions)
  ; Return a string containing a graphviz `dot` representation of the directed
  ; inclusion graph calculated by extracting #include directives from the
  ; specified files.
  (graphviz (digraph-from paths exclusions)))
