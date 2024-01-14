;;;
;;; MetaForth for the WDC65C02
;;;

;;
;; Preamble -- This section is hand coded and stored in mf_pre_65c02.asm
;;             To change, alter that file and regenerate the assembly.
;;

.cpu "w65c02"

pstack = $0000          ; Location of the "bottom" of the parameter stack
rstack = $0100          ; Location of the "bottom" of the return stack
USERAREA = $1000        ; Area for user variables

CHAR_TAB = 9
CHAR_LF = 10
CHAR_CR = 13

.include "sections.asm" ; Define the memory map

.section zp
ip      .word ?         ; Instruction pointer
wp      .word ?         ; Word pointer
up      .word ?         ; User pointer
donep   .word ?         ; Pointer to the code to take over when the interpreter quits
test    .word ?         ; Pointer to the current test name
tmp     .fill 4
fptr	.dword ?		; A pointer to the full address space
savex   .byte ?
counter .byte ?         ; A counter used for some code
sign    .byte ?         ; A scratch byte to keep track of the sign of a number
.send

.section code

		; .byte $f2, $56							; F256 TinyKernel code signature
		; .byte (end_of_code - coldstart) / 8096	; Size in 8KB blocks
		; .byte 2									; Starting block $4000
		; .word coldstart							; Starting address
		; .fill 4									; Reserved
		; .null "forth"							; Name of the code

coldstart:
        jsr ioinit
        jmp start

;;
;; Initial User Variable values
;;

init_user:
        .word $006e     ; Initial PSP (S0)
        .word $00ff     ; Initial RSP (R0)
        .word 10        ; Initial BASE
        .word 0         ; Initial STATE
        .word 0         ; Initial CONTEXT
        .word 0         ; Initial CURRENT
        .word $1000     ; Initial DP
        .word 0         ; Initial >IN
        .word $3f00     ; Initial TIB
        .word 0         ; Initial SOURCE-ID
        .word 0         ; Initial BLK
        .word $ffff     ; Initial DPL
        .word 0         ; Initial HLD
        .word 0         ; Initial HANDLER

init_user_end:

user_s0 = 0
user_r0 = 2
user_base = 4
user_state = 6
user_context = 8
user_current = 10
user_dp = 12
user_in = 14
user_tib = 16
user_source_id = 18
user_blk = 20
user_dpl = 22
user_hld = 24
user_handler = 26

;;
;; Far pointer management code
;;

;
; Calculate the bank and offset of the far pointer in fptr
;
; Side effect:
; Updates the MMU to point the MMU bank window to the correct memory
;
; Input:
; fptr = 24-bit pointer to the desired memory
;
; Output:
; tmp = 16-bit address of the byte in the banked memory
;
bank_offset:
		lda 12			; Get the current value of the window
		sta tmp+3		; Save it to tmp+3

		lda fptr+2		; Get the upper 8-bits of the full address
		sta tmp+1
		lda fptr+1
		sta tmp

		asl tmp			; Shift to get the number of the 8KB bank
		rol tmp+1
		asl tmp
		rol tmp+1
		asl tmp
		rol tmp+1

		lda tmp+1		; Set the MMU window
		sta 12

		clc				; Add $8000 (address of window) to the offset
		lda fptr+1
		and #$1F
		adc #$80
		sta tmp+1
		lda fptr
		sta tmp			; And store the 16-bit address in tmp

		rts

;;
;; Bootstrapping code
;;

start   ldx #$6e        ; Initialize the PSP

        ; Initialize IP and start the interpreter
        lda #<vstart
        sta ip
        lda #>vstart
        sta ip+1

        ; Initialize the user pointer
        lda #<USERAREA
        sta up
        lda #>USERAREA
        sta up+1

        ; Initialize the USER area
        ldy #0
init_user_loop:
        lda init_user,y
        sta (up),y
        iny
        cpy #(init_user_end - init_user)
        bne init_user_loop

        jmp xt_next

vstart  .word xt_cold
        .word xt_halt



;;
;; Address interpreter
;; 

done    jmp (donep)     ; Quit the interpreter by going to the code at donep

.send

.include "io.asm"       ; Include the light BIOS

end_of_code: