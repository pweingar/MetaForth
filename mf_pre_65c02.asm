;;;
;;; MetaForth for the WDC65C02
;;;

;;
;; Preamble -- This section is hand coded and stored in mf_pre_65c02.asm
;;             To change, alter that file and regenerate the assembly.
;;

.cpu "w65c02"

pstack = $0000          ; Location of the "bottom" of the parameter stack
USERAREA = $A000        ; Area for user variables

CHAR_TAB = 9


.include "bios65.asm"   ; Include the light BIOS

.section zp
ip      .word ?         ; Instruction pointer
wp      .word ?         ; Word pointer
up      .word ?         ; User pointer
donep   .word ?         ; Pointer to the code to take over when the interpreter quits
test    .word ?         ; Pointer to the current test name
tmp     .fill 4
savex   .byte ?
counter .byte ?         ; A counter used for some code
sign    .byte ?         ; A scratch byte to keep track of the sign of a number
.send

.section code

welcome .null "MetaForth v00.00.00",13

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
        .word <>endcode ; Initial DP
        .word 0         ; Initial >IN
        .word $bf00     ; Initial TIB
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
;; Bootstrapping code
;;

start   ldx #$ff        ; Initialize the RSP
        txs
        
        ldx #$6e        ; Initialize the PSP

        ; TODO: initialize the USER variables

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

        jmp next

vstart  .word xt_cold
        .word xt_halt

;;
;; Address interpreter
;; 

done    jmp (donep)     ; Quit the interpreter by going to the code at donep



        ; jmp next

next    ldy #1          ; wp := (ip)
        lda (ip)
        sta wp
        lda (ip),y
        sta wp+1

        clc             ; ip := ip + 2
        lda ip
        adc #2
        sta ip
        lda ip+1
        adc #0
        sta ip+1

        jmp (wp)        ; jmp (wp)

;;
;; Words -- This section is machine generated code.
;;          To modify, update the relevant FTH files and regenerate the assembly
;;

.send