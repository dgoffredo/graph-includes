#lang racket

(provide digraph-from
         graphviz-from)

(require "minimal-lex.rkt"
         "extract-includes.rkt"
         graph
         threading)

(define (included-headers path)
  ; Return a list of the header file paths included by the specified file.
  (~> path
    open-input-file
    minimal-lex
    extract-includes
    sequence->list))

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

(define (digraph-from paths)
  ; Return a directed inclusion graph from the specified list of file paths.
  ; An edge X -> Y in the graph indicates that the source file or header X
  ; includes the header Y.
  (directed-graph (append-map edges-from paths)))

(define (graphviz-from paths)
  ; Return a string containing a graphviz `dot` representation of the directed
  ; inclusion graph calculated by extracting #include directives from the
  ; specified files.
  (graphviz (digraph-from paths)))
