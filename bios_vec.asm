;;;
;;; Declare the BIOS hardware vectors
;;;

* = $fffa
vnmi:       .word <>h_nmi
vreset:     .word <>boot
virq:       .word <>h_irq

