;;;
;;; Local variable support for 65C02
;;;

			.section zp
fp			.byte ?			; Frame pointer
			.send

;;
;; Frame layout:
;;
;;        |     ...     |
;;        +------+------+
;;        | RETURN ADDR |
;;        +------+------+
;;        | local_(n-1) |
;;        +------+------+
;;        |     ...     |
;;        +------+------+
;;        |   local_0   |
;;        +------+------+
;;        |  SP  |  FP  | <-- FP
;;        +------+------+
;; SP --> |     ...     |
;;

; Set up the local variable frame, given the size of the frame (in byte) in A
frame_up	.macro

			cmp #0			; Handle things differently for 0 sized frames
			bne full_frame

			;
			; Empty frame... just save PSP and FP
			;

			stx savex		; Save the PSP

			tsx				; Push the old stack pointer
			phx

			ldx fp			; Push the old frame pointer
			phx

			tsx				; Adjust the frame pointer
			inx
			stx fp

			bra continue

full_frame: stx savex		; Save the PSP

			sta count		; Save the number of bytes

			tsx				; Save the old stack pointer
			sta tmp

			txa				; Allocate space on the return stack for the locals
			sec
			sbc count
			tax
			txs

			ldx tmp			; Save the old stack pointer to the stack
			phx

			ldx fp			; Save the old frame pointer to the stack
			phx
			
			dec a			; Update the frame pointer
			sta fp

continue:	ldx savex		; Restore the PSP
			.endm

; Tear down the local variable frame
frame_down	.macro
			; Save the PSP
			stx savex

			; Restore the return stack pointer
			ldy fp
			ldx rstack+1,y
			txs

			; Restore the frame pointer
			lda rstack,y
			sta fp
			
			; Restore the PSP
			ldx savex
			.endm

; Code to evaluate a local variable reference
; The index of the local is the first byte in the parameter section of the word
; It represents the byte offset of the low byte of the variable within the frame (above RSP and FP)
; local_0 -> 0
; local_1 -> 2
; local_2 -> 4
; ...
dolocal:	.proc
			lda (ip)		; Get the index...
			inc ip
			bne calcaddr
			inc ip+1

calcaddr:	inc a			; Calculate the offset of the local
			sec
			adc fp			; offset := fp + 2 + index (skip over FP and RSP in the frame)
			tay

			lda rstack+1,y	; Push the value of the indexed local
			sta pstack+1,x
			lda rstack,y
			sta pstack,x
			dex
			dex

			jmp xt_next		; And continue execution  
			.pend

