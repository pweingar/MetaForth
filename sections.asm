;;;
;;; Memory blocks used by BIOS and MetaForth
;;;

* = $0020           ; Location for zero page variables
.dsection zp

* = $0200           ; Location for standard variables
.dsection variables

* = $4000           ; Location for runtime code
.dsection code
