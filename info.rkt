#lang info

(define name "graph-includes")

(define deps '("racket" "threading-lib"))

(define raco-commands
  '(("graph-includes"                                  ; command
     (submod graph-includes main)                      ; module path
     "print graphviz representation of #include graph" ; description
     #f)))                                             ; prominence (hide)
