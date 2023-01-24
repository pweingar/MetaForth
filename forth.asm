.include "mf_pre_65c02.asm"
.section code
; Start of auto-generated code

; ( a-addr -- )
; BEGIN testname
w_testname:
	.byte $08
	.text 'testname'
	.fill 8
	.word 0
xt_testname:
	.block
	lda pstack+2,x
	sta test
	lda pstack+3,x
	sta test+1
	inx
	inx
	jmp next
	.bend
; END testname

; ( x1 x2 -- )
; BEGIN assert=
w_assertx3d:
	.byte $07
	.text 'assert='
	.fill 9
	.word w_testname
xt_assertx3d:
	.block
	lda pstack+2,x      ; Check to see if x1 and x2 are equal
	cmp pstack+4,x
	bne fail            ; If not, fail
	lda pstack+3,x
	cmp pstack+5,x
	bne fail
	txa                 ; If so, clean up the stack
	clc
	adc #4
	tax
	jmp next            ; And continue
	fail:
	lda #<leadin        ; Print the failure message
	sta src_ptr
	lda #>leadin
	sta src_ptr+1
	jsr prints
	lda test            ; Print the name of the test
	sta src_ptr
	lda test+1
	sta src_ptr+1
	jsr prints
	lda #<actual        ; Print the "Actual" label
	sta src_ptr
	lda #>actual
	sta src_ptr+1
	jsr prints
	ldy pstack+5,x      ; Print the actual value computed
	lda pstack+4,x
	jsr printyah
	lda #<expected      ; Print the "Expected" label
	sta src_ptr
	lda #>expected
	sta src_ptr+1
	jsr prints
	ldy pstack+3,x      ; Print the expected value
	lda pstack+2,x
	jsr printyah
	lock:
	nop                 ; Lock up
	bra lock
	leadin:
	.null "FAIL: "
	expected:
	.null " EXPECTED: "
	actual:
	.null " ACTUAL: "
	.bend
; END assert=

; ( -- )
; BEGIN halt
w_halt:
	.byte $04
	.text 'halt'
	.fill 12
	.word w_assertx3d
xt_halt:
	.block
	lda #<registers         ; Print register banner
	sta src_ptr
	lda #>registers
	sta src_ptr+1
	jsr prints
	ldy ip+1                ; Print the IP
	lda ip
	jsr printyah
	lda #' '
	jsr conout
	ldy wp+1                ; Print the WP
	lda wp
	jsr printyah
	lda #' '
	jsr conout
	stx savex               ; Print the return stack pointer
	ldy #$01
	tsx
	txa
	jsr printyah
	ldx savex
	lda #' '
	jsr conout
	ldy #0                  ; Print the parameter stack pointer
	txa
	jsr printyah
	lda #13
	jsr conout
	cpx #$6e                ; Check to see if there is anything on the parameter stack
	bge lock
	lda #>stackmsg          ; Yes: print the stack message and the stack contents
	sta src_ptr+1
	lda #<stackmsg
	sta src_ptr
	jsr prints
	loop:
	cpx #$6e
	bge lock
	ldy pstack+3,x
	lda pstack+2,x
	inx
	inx
	jsr printyah
	lda #' '
	jsr conout
	bra loop
	lock:
	wait:
	nop
	bra wait
	registers:  .text 13,13,"|   IP   WP  RSP  PSP",13
	.null "| "
	stackmsg:   .null 13,"Parameter Stack:",13
	.bend
; END halt

; ( c -- )
; BEGIN emit
w_emit:
	.byte $04
	.text 'emit'
	.fill 12
	.word w_halt
xt_emit:
	.block
	lda pstack+2,x
	phx
	jsr conout
	plx
	inx
	inx
	jmp next
	.bend
; END emit

; ( -- f )
; BEGIN key?
w_keyx3f:
	.byte $04
	.text 'key?'
	.fill 12
	.word w_emit
xt_keyx3f:
	.block
	jsr constat
	and #1
	beq waiting
	stz pstack,x
	stz pstack+1,x
	bra done
	waiting:
	lda #$ff
	sta pstack,x
	sta pstack+1,x
	done:
	dex
	dex
	jmp next
	.bend
; END key?

; ( -- c )
; BEGIN key
w_key:
	.byte $03
	.text 'key'
	.fill 13
	.word w_keyx3f
xt_key:
	.block
	phx
	wait:
	jsr conin
	cmp #0
	beq wait
	plx
	sta pstack,x
	stz pstack+1,x
	dex
	dex
	jmp next
	.bend
; END key

; ( -- )
; BEGIN cr
w_cr:
	.byte $02
	.text 'cr'
	.fill 14
	.word w_key
xt_cr:
	.block
	phx
	lda #$0d
	jsr conout
	plx
	jmp next
	.bend
; END cr

; ( -- 0 )
; BEGIN 0
w_0:
	.byte $01
	.text '0'
	.fill 15
	.word w_cr
xt_0:
	.block
	stz pstack+1,x
	stz pstack,x
	dex
	dex
	jmp next
	.bend
; END 0

; ( -- 1 )
; BEGIN 1
w_1:
	.byte $01
	.text '1'
	.fill 15
	.word w_0
xt_1:
	.block
	stz pstack+1,x
	lda #1
	sta pstack,x
	dex
	dex
	jmp next
	.bend
; END 1

; ( -- 2 )
; BEGIN 2
w_2:
	.byte $01
	.text '2'
	.fill 15
	.word w_1
xt_2:
	.block
	stz pstack+1,x
	lda #2
	sta pstack,x
	dex
	dex
	jmp next
	.bend
; END 2

; ( -- -1 )
; BEGIN -1
w_x2d1:
	.byte $02
	.text '-1'
	.fill 14
	.word w_2
xt_x2d1:
	.block
	lda #$ff
	sta pstack+1,x
	sta pstack,x
	dex
	dex
	jmp next
	.bend
; END -1

; ( -- -2 )
; BEGIN -2
w_x2d2:
	.byte $02
	.text '-2'
	.fill 14
	.word w_x2d1
xt_x2d2:
	.block
	lda #$fe
	sta pstack+1,x
	sta pstack,x
	dex
	dex
	jmp next
	.bend
; END -2

; ( -- x )
; BEGIN (literal)
w_x28literalx29:
	.byte $09
	.text '(literal)'
	.fill 7
	.word w_x2d2
xt_x28literalx29:
	.block
	ldy #1
	lda (ip)
	sta pstack,x
	lda (ip),y
	sta pstack+1,x
	dex
	dex
	clc
	lda ip
	adc #2
	sta ip
	lda ip+1
	adc #0
	sta ip+1
	jmp next
	.bend
; END (literal)

; ( .. x_n -- n )
; BEGIN depth
w_depth:
	.byte $05
	.text 'depth'
	.fill 11
	.word w_x28literalx29
xt_depth:
	.block
	stx tmp
	sec
	lda #$6e
	sbc tmp
	lsr a
	stz pstack+1,x
	sta pstack,x
	dex
	dex
	jmp next
	.bend
; END depth

; BEGIN unittest
w_unittest:
	.byte $08
	.text 'unittest'
	.fill 8
	.word w_depth
xt_unittest:
	.block
	jmp i_enter
	.word xt_x28literalx29
	.word l_2
	.word xt_x28branchx29
	.word l_3
l_2:
	.null "depth --> 0"
l_3:
	.word xt_testname
	.word xt_depth
	.word xt_0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_4
	.word xt_x28branchx29
	.word l_5
l_4:
	.null "0 depth --> 0 1"
l_5:
	.word xt_testname
	.word xt_0
	.word xt_depth
	.word xt_1
	.word xt_assertx3d
	.word xt_0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_6
	.word xt_x28branchx29
	.word l_7
l_6:
	.null "1 1 1 depth --> 1 1 1 3"
l_7:
	.word xt_testname
	.word xt_1
	.word xt_1
	.word xt_1
	.word xt_depth
	.word xt_x28literalx29
	.word 3
	.word xt_assertx3d
	.word xt_1
	.word xt_assertx3d
	.word xt_1
	.word xt_assertx3d
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_8
	.word xt_x28branchx29
	.word l_9
l_8:
	.null "1 2 drop --> 1"
l_9:
	.word xt_testname
	.word xt_1
	.word xt_2
	.word xt_drop
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_10
	.word xt_x28branchx29
	.word l_11
l_10:
	.null "1 2 3 drop --> 1 2"
l_11:
	.word xt_testname
	.word xt_1
	.word xt_2
	.word xt_x28literalx29
	.word 3
	.word xt_drop
	.word xt_2
	.word xt_assertx3d
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_12
	.word xt_x28branchx29
	.word l_13
l_12:
	.null "1 dup --> 1 1"
l_13:
	.word xt_testname
	.word xt_1
	.word xt_dup
	.word xt_1
	.word xt_assertx3d
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_14
	.word xt_x28branchx29
	.word l_15
l_14:
	.null "1 2 dup --> 1 2 2"
l_15:
	.word xt_testname
	.word xt_1
	.word xt_2
	.word xt_dup
	.word xt_2
	.word xt_assertx3d
	.word xt_2
	.word xt_assertx3d
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_16
	.word xt_x28branchx29
	.word l_17
l_16:
	.null "1 2 3 swap --> 1 3 2"
l_17:
	.word xt_testname
	.word xt_1
	.word xt_2
	.word xt_x28literalx29
	.word 3
	.word xt_swap
	.word xt_2
	.word xt_assertx3d
	.word xt_x28literalx29
	.word 3
	.word xt_assertx3d
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_18
	.word xt_x28branchx29
	.word l_19
l_18:
	.null "1 2 3 4 2swap --> 3 4 1 2"
l_19:
	.word xt_testname
	.word xt_1
	.word xt_2
	.word xt_x28literalx29
	.word 3
	.word xt_x28literalx29
	.word 4
	.word xt_2swap
	.word xt_2
	.word xt_assertx3d
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word 4
	.word xt_assertx3d
	.word xt_x28literalx29
	.word 3
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_20
	.word xt_x28branchx29
	.word l_21
l_20:
	.null "1 2 over --> 1 2 1"
l_21:
	.word xt_testname
	.word xt_1
	.word xt_2
	.word xt_over
	.word xt_1
	.word xt_assertx3d
	.word xt_2
	.word xt_assertx3d
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_22
	.word xt_x28branchx29
	.word l_23
l_22:
	.null "1 2 3 4 2over --> 1 2 3 4 1 2"
l_23:
	.word xt_testname
	.word xt_1
	.word xt_2
	.word xt_x28literalx29
	.word 3
	.word xt_x28literalx29
	.word 4
	.word xt_2over
	.word xt_2
	.word xt_assertx3d
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word 4
	.word xt_assertx3d
	.word xt_x28literalx29
	.word 3
	.word xt_assertx3d
	.word xt_2
	.word xt_assertx3d
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_24
	.word xt_x28branchx29
	.word l_25
l_24:
	.null "5555h 0004h ! 0004h @ --> 5555h"
l_25:
	.word xt_testname
	.word xt_x28literalx29
	.word 21845
	.word xt_x28literalx29
	.word 4
	.word xt_x21
	.word xt_x28literalx29
	.word 4
	.word xt_x40
	.word xt_x28literalx29
	.word 21845
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_26
	.word xt_x28branchx29
	.word l_27
l_26:
	.null "aaaah 0004h ! 0004h @ --> aaaah"
l_27:
	.word xt_testname
	.word xt_x28literalx29
	.word 43690
	.word xt_x28literalx29
	.word 4
	.word xt_x21
	.word xt_x28literalx29
	.word 4
	.word xt_x40
	.word xt_x28literalx29
	.word 43690
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_28
	.word xt_x28branchx29
	.word l_29
l_28:
	.null "55h 0003h c! 0003h c@ --> 55h"
l_29:
	.word xt_testname
	.word xt_x28literalx29
	.word 85
	.word xt_x28literalx29
	.word 3
	.word xt_cx21
	.word xt_x28literalx29
	.word 3
	.word xt_cx40
	.word xt_x28literalx29
	.word 85
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_30
	.word xt_x28branchx29
	.word l_31
l_30:
	.null "aah 0003h c! 0003h c@ --> aah"
l_31:
	.word xt_testname
	.word xt_x28literalx29
	.word 170
	.word xt_x28literalx29
	.word 3
	.word xt_cx21
	.word xt_x28literalx29
	.word 3
	.word xt_cx40
	.word xt_x28literalx29
	.word 170
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_32
	.word xt_x28branchx29
	.word l_33
l_32:
	.null "1 0 + --> 1"
l_33:
	.word xt_testname
	.word xt_1
	.word xt_0
	.word xt_x2b
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_34
	.word xt_x28branchx29
	.word l_35
l_34:
	.null "1 1 + --> 2"
l_35:
	.word xt_testname
	.word xt_1
	.word xt_1
	.word xt_x2b
	.word xt_2
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_36
	.word xt_x28branchx29
	.word l_37
l_36:
	.null "3 10 + --> 13"
l_37:
	.word xt_testname
	.word xt_x28literalx29
	.word 3
	.word xt_x28literalx29
	.word 10
	.word xt_x2b
	.word xt_x28literalx29
	.word 13
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_38
	.word xt_x28branchx29
	.word l_39
l_38:
	.null "ffffh 5 + --> 4"
l_39:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_x28literalx29
	.word 5
	.word xt_x2b
	.word xt_x28literalx29
	.word 4
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_40
	.word xt_x28branchx29
	.word l_41
l_40:
	.null "1234h 5678h 1111h 1111h d+ --> 2345h 6789h"
l_41:
	.word xt_testname
	.word xt_x28literalx29
	.word 4660
	.word xt_x28literalx29
	.word 22136
	.word xt_x28literalx29
	.word 4369
	.word xt_x28literalx29
	.word 4369
	.word xt_dx2b
	.word xt_x28literalx29
	.word 26505
	.word xt_assertx3d
	.word xt_x28literalx29
	.word 9029
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_42
	.word xt_x28branchx29
	.word l_43
l_42:
	.null "0000h 1111h 0000h eeefh d+ --> 0001h 0000h"
l_43:
	.word xt_testname
	.word xt_x28literalx29
	.word 0
	.word xt_x28literalx29
	.word 4369
	.word xt_x28literalx29
	.word 0
	.word xt_x28literalx29
	.word 61167
	.word xt_dx2b
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word 1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_44
	.word xt_x28branchx29
	.word l_45
l_44:
	.null "4 3 - --> 1"
l_45:
	.word xt_testname
	.word xt_x28literalx29
	.word 4
	.word xt_x28literalx29
	.word 3
	.word xt_x2d
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_46
	.word xt_x28branchx29
	.word l_47
l_46:
	.null "3 4 - --> ffffh"
l_47:
	.word xt_testname
	.word xt_x28literalx29
	.word 3
	.word xt_x28literalx29
	.word 4
	.word xt_x2d
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_48
	.word xt_x28branchx29
	.word l_49
l_48:
	.null "10 5 - --> 5"
l_49:
	.word xt_testname
	.word xt_x28literalx29
	.word 10
	.word xt_x28literalx29
	.word 5
	.word xt_x2d
	.word xt_x28literalx29
	.word 5
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_50
	.word xt_x28branchx29
	.word l_51
l_50:
	.null "0 1 3 um/mod --> 1 0"
l_51:
	.word xt_testname
	.word xt_0
	.word xt_1
	.word xt_x28literalx29
	.word 3
	.word xt_umx2fmod
	.word xt_0
	.word xt_assertx3d
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_52
	.word xt_x28branchx29
	.word l_53
l_52:
	.null "0 2 3 um/mod --> 2 0"
l_53:
	.word xt_testname
	.word xt_0
	.word xt_2
	.word xt_x28literalx29
	.word 3
	.word xt_umx2fmod
	.word xt_0
	.word xt_assertx3d
	.word xt_2
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_54
	.word xt_x28branchx29
	.word l_55
l_54:
	.null "0 3 3 um/mod --> 0 1"
l_55:
	.word xt_testname
	.word xt_0
	.word xt_x28literalx29
	.word 3
	.word xt_x28literalx29
	.word 3
	.word xt_umx2fmod
	.word xt_1
	.word xt_assertx3d
	.word xt_0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_56
	.word xt_x28branchx29
	.word l_57
l_56:
	.null "0 4 3 um/mod --> 1 1"
l_57:
	.word xt_testname
	.word xt_0
	.word xt_x28literalx29
	.word 4
	.word xt_x28literalx29
	.word 3
	.word xt_umx2fmod
	.word xt_1
	.word xt_assertx3d
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_58
	.word xt_x28branchx29
	.word l_59
l_58:
	.null "0 6 3 um/mod --> 0 2"
l_59:
	.word xt_testname
	.word xt_0
	.word xt_x28literalx29
	.word 6
	.word xt_x28literalx29
	.word 3
	.word xt_umx2fmod
	.word xt_2
	.word xt_assertx3d
	.word xt_0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_60
	.word xt_x28branchx29
	.word l_61
l_60:
	.null "1234h s>d --> 0000h 1234h"
l_61:
	.word xt_testname
	.word xt_x28literalx29
	.word 4660
	.word xt_sx3ed
	.word xt_x28literalx29
	.word 4660
	.word xt_assertx3d
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_62
	.word xt_x28branchx29
	.word l_63
l_62:
	.null "ffffh s>d --> ffffh ffffh"
l_63:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_sx3ed
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_64
	.word xt_x28branchx29
	.word l_65
l_64:
	.null "fffeh s>d --> ffffh fffeh"
l_65:
	.word xt_testname
	.word xt_x28literalx29
	.word 65534
	.word xt_sx3ed
	.word xt_x28literalx29
	.word 65534
	.word xt_assertx3d
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_66
	.word xt_x28branchx29
	.word l_67
l_66:
	.null "1 1+ --> 2"
l_67:
	.word xt_testname
	.word xt_1
	.word xt_1x2b
	.word xt_2
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_68
	.word xt_x28branchx29
	.word l_69
l_68:
	.null "0 1+ --> 1"
l_69:
	.word xt_testname
	.word xt_0
	.word xt_1x2b
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_70
	.word xt_x28branchx29
	.word l_71
l_70:
	.null "20 1+ --> 21"
l_71:
	.word xt_testname
	.word xt_x28literalx29
	.word 20
	.word xt_1x2b
	.word xt_x28literalx29
	.word 21
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_72
	.word xt_x28branchx29
	.word l_73
l_72:
	.null "ffffh 1+ --> 0"
l_73:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_1x2b
	.word xt_0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_74
	.word xt_x28branchx29
	.word l_75
l_74:
	.null "1 2+ --> 3"
l_75:
	.word xt_testname
	.word xt_1
	.word xt_2x2b
	.word xt_x28literalx29
	.word 3
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_76
	.word xt_x28branchx29
	.word l_77
l_76:
	.null "0 2+ --> 2"
l_77:
	.word xt_testname
	.word xt_0
	.word xt_2x2b
	.word xt_2
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_78
	.word xt_x28branchx29
	.word l_79
l_78:
	.null "20 2+ --> 22"
l_79:
	.word xt_testname
	.word xt_x28literalx29
	.word 20
	.word xt_2x2b
	.word xt_x28literalx29
	.word 22
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_80
	.word xt_x28branchx29
	.word l_81
l_80:
	.null "fffeh 2+ --> 0"
l_81:
	.word xt_testname
	.word xt_x28literalx29
	.word 65534
	.word xt_2x2b
	.word xt_0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_82
	.word xt_x28branchx29
	.word l_83
l_82:
	.null "1 1- --> 0"
l_83:
	.word xt_testname
	.word xt_1
	.word xt_1x2d
	.word xt_0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_84
	.word xt_x28branchx29
	.word l_85
l_84:
	.null "0 1- --> ffffh"
l_85:
	.word xt_testname
	.word xt_0
	.word xt_1x2d
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_86
	.word xt_x28branchx29
	.word l_87
l_86:
	.null "20 1- --> 19"
l_87:
	.word xt_testname
	.word xt_x28literalx29
	.word 20
	.word xt_1x2d
	.word xt_x28literalx29
	.word 19
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_88
	.word xt_x28branchx29
	.word l_89
l_88:
	.null "ffffh 1- --> fffeh"
l_89:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_1x2d
	.word xt_x28literalx29
	.word 65534
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_90
	.word xt_x28branchx29
	.word l_91
l_90:
	.null "1 2- --> ffffh"
l_91:
	.word xt_testname
	.word xt_1
	.word xt_2x2d
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_92
	.word xt_x28branchx29
	.word l_93
l_92:
	.null "0 2- --> fffeh"
l_93:
	.word xt_testname
	.word xt_0
	.word xt_2x2d
	.word xt_x28literalx29
	.word 65534
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_94
	.word xt_x28branchx29
	.word l_95
l_94:
	.null "20 2- --> 18"
l_95:
	.word xt_testname
	.word xt_x28literalx29
	.word 20
	.word xt_2x2d
	.word xt_x28literalx29
	.word 18
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_96
	.word xt_x28branchx29
	.word l_97
l_96:
	.null "ffffh 2- --> fffdh"
l_97:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_2x2d
	.word xt_x28literalx29
	.word 65533
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_98
	.word xt_x28branchx29
	.word l_99
l_98:
	.null "0000h 0000h and --> 0000h"
l_99:
	.word xt_testname
	.word xt_x28literalx29
	.word 0
	.word xt_x28literalx29
	.word 0
	.word xt_and
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_100
	.word xt_x28branchx29
	.word l_101
l_100:
	.null "0000h ffffh and --> 0000h"
l_101:
	.word xt_testname
	.word xt_x28literalx29
	.word 0
	.word xt_x28literalx29
	.word 65535
	.word xt_and
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_102
	.word xt_x28branchx29
	.word l_103
l_102:
	.null "ffffh 0000h and --> 0000h"
l_103:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_x28literalx29
	.word 0
	.word xt_and
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_104
	.word xt_x28branchx29
	.word l_105
l_104:
	.null "ffffh ffffh and --> ffffh"
l_105:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_x28literalx29
	.word 65535
	.word xt_and
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_106
	.word xt_x28branchx29
	.word l_107
l_106:
	.null "0000h 0000h or --> 0000h"
l_107:
	.word xt_testname
	.word xt_x28literalx29
	.word 0
	.word xt_x28literalx29
	.word 0
	.word xt_or
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_108
	.word xt_x28branchx29
	.word l_109
l_108:
	.null "0000h ffffh or --> ffffh"
l_109:
	.word xt_testname
	.word xt_x28literalx29
	.word 0
	.word xt_x28literalx29
	.word 65535
	.word xt_or
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_110
	.word xt_x28branchx29
	.word l_111
l_110:
	.null "ffffh 0000h or --> ffffh"
l_111:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_x28literalx29
	.word 0
	.word xt_or
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_112
	.word xt_x28branchx29
	.word l_113
l_112:
	.null "ffffh ffffh or --> ffffh"
l_113:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_x28literalx29
	.word 65535
	.word xt_or
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_114
	.word xt_x28branchx29
	.word l_115
l_114:
	.null "0000h 0000h xor --> 0000h"
l_115:
	.word xt_testname
	.word xt_x28literalx29
	.word 0
	.word xt_x28literalx29
	.word 0
	.word xt_xor
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_116
	.word xt_x28branchx29
	.word l_117
l_116:
	.null "0000h ffffh xor --> ffffh"
l_117:
	.word xt_testname
	.word xt_x28literalx29
	.word 0
	.word xt_x28literalx29
	.word 65535
	.word xt_xor
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_118
	.word xt_x28branchx29
	.word l_119
l_118:
	.null "ffffh 0000h xor --> ffffh"
l_119:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_x28literalx29
	.word 0
	.word xt_xor
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_120
	.word xt_x28branchx29
	.word l_121
l_120:
	.null "ffffh ffffh xor --> 0000h"
l_121:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_x28literalx29
	.word 65535
	.word xt_xor
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_122
	.word xt_x28branchx29
	.word l_123
l_122:
	.null "0000h not --> ffffh"
l_123:
	.word xt_testname
	.word xt_x28literalx29
	.word 0
	.word xt_not
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_124
	.word xt_x28branchx29
	.word l_125
l_124:
	.null "ffffh not --> 0000h"
l_125:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_not
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_126
	.word xt_x28branchx29
	.word l_127
l_126:
	.null "0 0< --> 0000h"
l_127:
	.word xt_testname
	.word xt_0
	.word xt_0x3c
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_128
	.word xt_x28branchx29
	.word l_129
l_128:
	.null "3 0< --> 0000h"
l_129:
	.word xt_testname
	.word xt_x28literalx29
	.word 3
	.word xt_0x3c
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_130
	.word xt_x28branchx29
	.word l_131
l_130:
	.null "ffffh 0< --> ffffh"
l_131:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_0x3c
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_132
	.word xt_x28branchx29
	.word l_133
l_132:
	.null "0 0= --> ffffh"
l_133:
	.word xt_testname
	.word xt_0
	.word xt_0x3d
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_134
	.word xt_x28branchx29
	.word l_135
l_134:
	.null "3 0= --> 0000h"
l_135:
	.word xt_testname
	.word xt_x28literalx29
	.word 3
	.word xt_0x3d
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_136
	.word xt_x28branchx29
	.word l_137
l_136:
	.null "ffffh 0= --> 0000h"
l_137:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_0x3d
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_138
	.word xt_x28branchx29
	.word l_139
l_138:
	.null "0 0> --> 0000h"
l_139:
	.word xt_testname
	.word xt_0
	.word xt_0x3e
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_140
	.word xt_x28branchx29
	.word l_141
l_140:
	.null "3 0> --> ffffh"
l_141:
	.word xt_testname
	.word xt_x28literalx29
	.word 3
	.word xt_0x3e
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_142
	.word xt_x28branchx29
	.word l_143
l_142:
	.null "ffffh 0> --> 0000h"
l_143:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_0x3e
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_144
	.word xt_x28branchx29
	.word l_145
l_144:
	.null "cells 2 - 0= --> ffffh"
l_145:
	.word xt_testname
	.word xt_cells
	.word xt_2
	.word xt_x2d
	.word xt_0x3d
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_146
	.word xt_x28branchx29
	.word l_147
l_146:
	.null "' 1 execute --> 1"
l_147:
	.word xt_testname
	.word xt_x28literalx29
	.word xt_1
	.word xt_execute
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_148
	.word xt_x28branchx29
	.word l_149
l_148:
	.null "1 2 ' + execute --> 3"
l_149:
	.word xt_testname
	.word xt_1
	.word xt_2
	.word xt_x28literalx29
	.word xt_x2b
	.word xt_execute
	.word xt_x28literalx29
	.word 3
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_150
	.word xt_x28branchx29
	.word l_151
l_150:
	.null "30h 10 digit --> 0 ffffh"
l_151:
	.word xt_testname
	.word xt_x28literalx29
	.word 48
	.word xt_x28literalx29
	.word 10
	.word xt_digit
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_152
	.word xt_x28branchx29
	.word l_153
l_152:
	.null "31h 10 digit --> 1 ffffh"
l_153:
	.word xt_testname
	.word xt_x28literalx29
	.word 49
	.word xt_x28literalx29
	.word 10
	.word xt_digit
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_154
	.word xt_x28branchx29
	.word l_155
l_154:
	.null "39h 10 digit --> 9 ffffh"
l_155:
	.word xt_testname
	.word xt_x28literalx29
	.word 57
	.word xt_x28literalx29
	.word 10
	.word xt_digit
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word 9
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_156
	.word xt_x28branchx29
	.word l_157
l_156:
	.null "41h 10 digit --> 0"
l_157:
	.word xt_testname
	.word xt_x28literalx29
	.word 65
	.word xt_x28literalx29
	.word 10
	.word xt_digit
	.word xt_0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_158
	.word xt_x28branchx29
	.word l_159
l_158:
	.null "61h 10 digit --> 0"
l_159:
	.word xt_testname
	.word xt_x28literalx29
	.word 97
	.word xt_x28literalx29
	.word 10
	.word xt_digit
	.word xt_0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_160
	.word xt_x28branchx29
	.word l_161
l_160:
	.null "41h 16 digit --> 10 ffffh"
l_161:
	.word xt_testname
	.word xt_x28literalx29
	.word 65
	.word xt_x28literalx29
	.word 16
	.word xt_digit
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word 10
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_162
	.word xt_x28branchx29
	.word l_163
l_162:
	.null "61h 16 digit --> 10 ffffh"
l_163:
	.word xt_testname
	.word xt_x28literalx29
	.word 97
	.word xt_x28literalx29
	.word 16
	.word xt_digit
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word 10
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_164
	.word xt_x28branchx29
	.word l_165
l_164:
	.null "46h 16 digit --> fh ffffh"
l_165:
	.word xt_testname
	.word xt_x28literalx29
	.word 70
	.word xt_x28literalx29
	.word 16
	.word xt_digit
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word 15
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_166
	.word xt_x28branchx29
	.word l_167
l_166:
	.null "66h 16 digit --> fh ffffh"
l_167:
	.word xt_testname
	.word xt_x28literalx29
	.word 102
	.word xt_x28literalx29
	.word 16
	.word xt_digit
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word 15
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_169
	.word xt_x28branchx29
	.word l_170
l_169:
	.null "0 ?dup --> 0"
l_170:
	.word xt_testname
	.word xt_0
	.word xt_x3fdup
	.word xt_0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_171
	.word xt_x28branchx29
	.word l_172
l_171:
	.null "1 ?dup --> 1 1"
l_172:
	.word xt_testname
	.word xt_1
	.word xt_x3fdup
	.word xt_1
	.word xt_assertx3d
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_173
	.word xt_x28branchx29
	.word l_174
l_173:
	.null "1 2 3 rot --> 2 3 1"
l_174:
	.word xt_testname
	.word xt_1
	.word xt_2
	.word xt_x28literalx29
	.word 3
	.word xt_rot
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word 3
	.word xt_assertx3d
	.word xt_2
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_175
	.word xt_x28branchx29
	.word l_176
l_175:
	.null "1 2 2dup --> 1 2 1 2"
l_176:
	.word xt_testname
	.word xt_1
	.word xt_2
	.word xt_2dup
	.word xt_2
	.word xt_assertx3d
	.word xt_1
	.word xt_assertx3d
	.word xt_2
	.word xt_assertx3d
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_177
	.word xt_x28branchx29
	.word l_178
l_177:
	.null "1 2 3 4 2drop --> 1 2"
l_178:
	.word xt_testname
	.word xt_1
	.word xt_2
	.word xt_x28literalx29
	.word 3
	.word xt_x28literalx29
	.word 4
	.word xt_2drop
	.word xt_2
	.word xt_assertx3d
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_179
	.word xt_x28branchx29
	.word l_180
l_179:
	.null "1 2 < --> ffffh"
l_180:
	.word xt_testname
	.word xt_1
	.word xt_2
	.word xt_x3c
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_181
	.word xt_x28branchx29
	.word l_182
l_181:
	.null "2 1 < --> 0000h"
l_182:
	.word xt_testname
	.word xt_2
	.word xt_1
	.word xt_x3c
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_183
	.word xt_x28branchx29
	.word l_184
l_183:
	.null "0 ffffh < --> 0000h"
l_184:
	.word xt_testname
	.word xt_0
	.word xt_x28literalx29
	.word 65535
	.word xt_x3c
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_185
	.word xt_x28branchx29
	.word l_186
l_185:
	.null "ffffh 0 < --> ffffh"
l_186:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_0
	.word xt_x3c
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_187
	.word xt_x28branchx29
	.word l_188
l_187:
	.null "1 2 > --> 0000h"
l_188:
	.word xt_testname
	.word xt_1
	.word xt_2
	.word xt_x3e
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_189
	.word xt_x28branchx29
	.word l_190
l_189:
	.null "2 1 > --> ffffh"
l_190:
	.word xt_testname
	.word xt_2
	.word xt_1
	.word xt_x3e
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_191
	.word xt_x28branchx29
	.word l_192
l_191:
	.null "0 ffffh > --> ffffh"
l_192:
	.word xt_testname
	.word xt_0
	.word xt_x28literalx29
	.word 65535
	.word xt_x3e
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_193
	.word xt_x28branchx29
	.word l_194
l_193:
	.null "ffffh 0 > --> 0000h"
l_194:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_0
	.word xt_x3e
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_195
	.word xt_x28branchx29
	.word l_196
l_195:
	.null "1 0 = --> 0000h"
l_196:
	.word xt_testname
	.word xt_1
	.word xt_0
	.word xt_x3d
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_197
	.word xt_x28branchx29
	.word l_198
l_197:
	.null "1 1 = --> ffffh"
l_198:
	.word xt_testname
	.word xt_1
	.word xt_1
	.word xt_x3d
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_199
	.word xt_x28branchx29
	.word l_200
l_199:
	.null "ffffh 0 = --> 0000h"
l_200:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_0
	.word xt_x3d
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_201
	.word xt_x28branchx29
	.word l_202
l_201:
	.null "ffffh ffffh = --> ffffh"
l_202:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_x28literalx29
	.word 65535
	.word xt_x3d
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_203
	.word xt_x28branchx29
	.word l_204
l_203:
	.null "0 0 = --> ffffh"
l_204:
	.word xt_testname
	.word xt_0
	.word xt_0
	.word xt_x3d
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_206
	.word xt_x28branchx29
	.word l_207
l_206:
	.null "1 abs --> 1"
l_207:
	.word xt_testname
	.word xt_1
	.word xt_abs
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_208
	.word xt_x28branchx29
	.word l_209
l_208:
	.null "ffffh abs --> 1"
l_209:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_abs
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_210
	.word xt_x28branchx29
	.word l_211
l_210:
	.null "0 abs --> 0"
l_211:
	.word xt_testname
	.word xt_0
	.word xt_abs
	.word xt_0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_213
	.word xt_x28branchx29
	.word l_214
l_213:
	.null "1 2 dabs --> 1 2"
l_214:
	.word xt_testname
	.word xt_1
	.word xt_2
	.word xt_dabs
	.word xt_2
	.word xt_assertx3d
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_215
	.word xt_x28branchx29
	.word l_216
l_215:
	.null "ffffh ffffh dabs --> 0 1"
l_216:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_x28literalx29
	.word 65535
	.word xt_dabs
	.word xt_1
	.word xt_assertx3d
	.word xt_0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_217
	.word xt_x28branchx29
	.word l_218
l_217:
	.null "0 0 dabs --> 0 0"
l_218:
	.word xt_testname
	.word xt_0
	.word xt_0
	.word xt_dabs
	.word xt_0
	.word xt_assertx3d
	.word xt_0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_220
	.word xt_x28branchx29
	.word l_221
l_220:
	.null "6 3 / --> 2"
l_221:
	.word xt_testname
	.word xt_x28literalx29
	.word 6
	.word xt_x28literalx29
	.word 3
	.word xt_x2f
	.word xt_2
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_222
	.word xt_x28branchx29
	.word l_223
l_222:
	.null "10 3 / --> 3"
l_223:
	.word xt_testname
	.word xt_x28literalx29
	.word 10
	.word xt_x28literalx29
	.word 3
	.word xt_x2f
	.word xt_x28literalx29
	.word 3
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_224
	.word xt_x28branchx29
	.word l_225
l_224:
	.null "6 3 mod --> 0"
l_225:
	.word xt_testname
	.word xt_x28literalx29
	.word 6
	.word xt_x28literalx29
	.word 3
	.word xt_mod
	.word xt_0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_226
	.word xt_x28branchx29
	.word l_227
l_226:
	.null "10 3 mod --> 1"
l_227:
	.word xt_testname
	.word xt_x28literalx29
	.word 10
	.word xt_x28literalx29
	.word 3
	.word xt_mod
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_230
	.word xt_x28branchx29
	.word l_231
l_230:
	.null "1 2 max --> 2"
l_231:
	.word xt_testname
	.word xt_1
	.word xt_2
	.word xt_max
	.word xt_2
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_232
	.word xt_x28branchx29
	.word l_233
l_232:
	.null "3 0 max --> 3"
l_233:
	.word xt_testname
	.word xt_x28literalx29
	.word 3
	.word xt_0
	.word xt_max
	.word xt_x28literalx29
	.word 3
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_234
	.word xt_x28branchx29
	.word l_235
l_234:
	.null "fffeh ffffh max --> ffffh"
l_235:
	.word xt_testname
	.word xt_x28literalx29
	.word 65534
	.word xt_x28literalx29
	.word 65535
	.word xt_max
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_238
	.word xt_x28branchx29
	.word l_239
l_238:
	.null "1 2 min --> 1"
l_239:
	.word xt_testname
	.word xt_1
	.word xt_2
	.word xt_min
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_240
	.word xt_x28branchx29
	.word l_241
l_240:
	.null "3 0 min --> 0"
l_241:
	.word xt_testname
	.word xt_x28literalx29
	.word 3
	.word xt_0
	.word xt_min
	.word xt_0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_242
	.word xt_x28branchx29
	.word l_243
l_242:
	.null "fffeh ffffh min --> fffeh"
l_243:
	.word xt_testname
	.word xt_x28literalx29
	.word 65534
	.word xt_x28literalx29
	.word 65535
	.word xt_min
	.word xt_x28literalx29
	.word 65534
	.word xt_assertx3d
	.word i_exit
	.bend
; END unittest

; ( x -- )
; BEGIN drop
w_drop:
	.byte $04
	.text 'drop'
	.fill 12
	.word w_unittest
xt_drop:
	.block
	inx
	inx
	jmp next
	.bend
; END drop

; ( x -- x x )
; BEGIN dup
w_dup:
	.byte $03
	.text 'dup'
	.fill 13
	.word w_drop
xt_dup:
	.block
	lda pstack+2,x
	sta pstack,x
	lda pstack+3,x
	sta pstack+1,x
	dex
	dex
	jmp next
	.bend
; END dup

; ( x1 x2 -- x2 x1 )
; BEGIN swap
w_swap:
	.byte $04
	.text 'swap'
	.fill 12
	.word w_dup
xt_swap:
	.block
	lda pstack+2,x
	ldy pstack+4,x
	sty pstack+2,x
	sta pstack+4,x
	lda pstack+3,x
	ldy pstack+5,x
	sty pstack+3,x
	sta pstack+5,x
	jmp next
	.bend
; END swap

; ( d1 d2 -- d2 d1 )
; BEGIN 2swap
w_2swap:
	.byte $05
	.text '2swap'
	.fill 11
	.word w_swap
xt_2swap:
	.block
	lda pstack+5,x
	pha
	lda pstack+4,x
	pha
	lda pstack+3,x
	pha
	lda pstack+2,x
	pha
	lda pstack+9,x
	sta pstack+5,x
	lda pstack+8,x
	sta pstack+4,x
	lda pstack+7,x
	sta pstack+3,x
	lda pstack+6,x
	sta pstack+2,x
	pla
	sta pstack+6,x
	pla
	sta pstack+7,x
	pla
	sta pstack+8,x
	pla
	sta pstack+9,x
	jmp next
	.bend
; END 2swap

; ( x1 x2 -- x1 x2 x1 )
; BEGIN over
w_over:
	.byte $04
	.text 'over'
	.fill 12
	.word w_2swap
xt_over:
	.block
	lda pstack+4,x
	sta pstack,x
	lda pstack+5,x
	sta pstack+1,x
	dex
	dex
	jmp next
	.bend
; END over

; ( d1 d2 -- d1 d2 d1 )
; BEGIN 2over
w_2over:
	.byte $05
	.text '2over'
	.fill 11
	.word w_over
xt_2over:
	.block
	dex
	dex
	dex
	dex
	lda pstack+13,x
	sta pstack+5,x
	lda pstack+12,x
	sta pstack+4,x
	lda pstack+11,x
	sta pstack+3,x
	lda pstack+10,x
	sta pstack+2,x
	jmp next
	.bend
; END 2over

; ( x -- )
; ( R: -- x )
; BEGIN >r
w_x3er:
	.byte $02
	.text '>r'
	.fill 14
	.word w_2over
xt_x3er:
	.block
	lda pstack+3,x
	pha
	lda pstack+2,x
	pha
	inx
	inx
	jmp next
	.bend
; END >r

; ( -- x )
; ( R: x -- )
; BEGIN r>
w_rx3e:
	.byte $02
	.text 'r>'
	.fill 14
	.word w_x3er
xt_rx3e:
	.block
	pla
	sta pstack,x
	pla
	sta pstack+1,x
	dex
	dex
	jmp next
	.bend
; END r>

; ( -- x )
; BEGIN r
w_r:
	.byte $01
	.text 'r'
	.fill 15
	.word w_rx3e
xt_r:
	.block
	pla
	sta pstack,x
	pla
	sta pstack+1,x
	pha
	lda pstack,x
	pha
	dex
	dex
	jmp next
	.bend
; END r

; ( r: x -- )
; BEGIN rdrop
w_rdrop:
	.byte $05
	.text 'rdrop'
	.fill 11
	.word w_r
xt_rdrop:
	.block
	pla
	pla
	.bend
; END rdrop

; ( x a-addr -- )
; BEGIN !
w_x21:
	.byte $01
	.text '!'
	.fill 15
	.word w_rdrop
xt_x21:
	.block
	lda pstack+2,x
	sta tmp
	lda pstack+3,x
	sta tmp+1
	ldy #1
	lda pstack+4,x
	sta (tmp)
	lda pstack+5,x
	sta (tmp),y
	inx
	inx
	inx
	inx
	jmp next
	.bend
; END !

; ( a-addr -- x )
; BEGIN @
w_x40:
	.byte $01
	.text '@'
	.fill 15
	.word w_x21
xt_x40:
	.block
	lda pstack+2,x
	sta tmp
	lda pstack+3,x
	sta tmp+1
	ldy #1
	lda (tmp)
	sta pstack+2,x
	lda (tmp),y
	sta pstack+3,x
	jmp next
	.bend
; END @

; ( c a-addr -- )
; BEGIN c!
w_cx21:
	.byte $02
	.text 'c!'
	.fill 14
	.word w_x40
xt_cx21:
	.block
	lda pstack+4,x
	sta (pstack+2,x)
	inx
	inx
	inx
	inx
	jmp next
	.bend
; END c!

; ( a-addr -- c )
; BEGIN c@
w_cx40:
	.byte $02
	.text 'c@'
	.fill 14
	.word w_cx21
xt_cx40:
	.block
	lda (pstack+2,x)
	sta pstack+2,x
	stz pstack+3,x
	jmp next
	.bend
; END c@

; ( c-addr u b -- )
; BEGIN fill
w_fill:
	.byte $04
	.text 'fill'
	.fill 12
	.word w_cx40
xt_fill:
	.block
	loop:
	lda pstack+3,x          ; Check to see if the count is 0
	bne do_write
	lda pstack+4,x
	beq done                ; Yes: we're done...
	do_write:
	lda pstack+1,x          ; No:; get the byte to use for the fill
	sta (pstack+5,x)        ; And store it in the indicated location
	inc pstack+5,x          ; Increment the address
	bne deccount
	inc pstack+6,x
	deccount:
	sec                     ; Decrement the count
	lda pstack+3,x
	sbc #1
	sta pstack+3,x
	lda pstack+4,x
	sbc #0
	sta pstack+4,x
	bra loop                ; And check again
	done:
	txa                     ; Clean up the parameter stack
	adc #6
	tax
	jmp next
	.bend
; END fill

; ( n a-addr -- )
; BEGIN +!
w_x2bx21:
	.byte $02
	.text '+!'
	.fill 14
	.word w_fill
xt_x2bx21:
	.block
	lda pstack+3,x
	sta tmp+1
	lda pstack+2,x
	sta tmp
	clc
	ldy #1
	lda (tmp)
	adc pstack+4,x
	sta (tmp)
	lda (tmp),y
	adc pstack+5,x
	sta (tmp),y
	done:
	inx                     ; Clean up the stack
	inx
	inx
	inx
	jmp next
	.bend
; END +!

; ( addr c -- addr n1 n2 n3 )
; BEGIN enclose
w_enclose:
	.byte $07
	.text 'enclose'
	.fill 9
	.word w_x2bx21
xt_enclose:
	.block
	;
	; scan a text buffer start at addr and find the first non delimiter (c) the offset to it goes in n1
	; scan to the next delimiter... its offset goes in n2
	; if NUL found instead (or end of buffer) n3 = n2, otherwise n3 = n2 + 1
	;
	lda pstack+5,x          ; Copy the address
	sta src_ptr+1
	lda pstack+4,x
	sta src_ptr
	lda pstack+2,x          ; tmp := c
	sta tmp
	; Prepare the return values
	txa
	sec
	sbc #4
	tax
	stz pstack+7,x          ; n1 ... offset to first character
	stz pstack+6,x
	stz pstack+5,x          ; n2 ... offset to first delimiter
	stz pstack+4,x
	stz pstack+3,x          ; n3 ... n2 + 1 or n2
	stz pstack+2,x
	; Skip over leading delimiters
	ldy #0
	loop1:
	lda (src_ptr),y         ; Get the character
	bne chk_delim1          ; NUL? No:; check it against the delimiter
	none:
	jmp next                ; Yes: we want to return 0s
	chk_delim1:
	cmp tmp                 ; Is it the delimiter?
	beq skip2               ; Yes: skip the character
	lda tmp                 ; Check the delimiter
	cmp #' '                ; Is it BL?
	bne found               ; No: ok, we've found the first character;
	lda (src_ptr),y         ; Get the character back
	cmp #CHAR_TAB           ; Is it a TAB?
	bne found               ; No: we found the first character
	iny                     ; Move to the next character
	beq none                ; If we've rolled over, we found nothing
	bra loop1               ; Otherwise: check the next character
	found:                      ; We found the first character
	sty pstack+6,x          ; Save the offset to it in n1
	skip2:
	iny                     ; Go to the next character
	beq found_nul           ; If it rolls over, we've reached the end (NUL)
	loop2:
	lda (src_ptr),y         ; Get the character
	beq found_nul           ; If it is NUL, we've reached the end (NUL)
	cmp tmp                 ; Check it against the delimiter
	beq found_delim         ; If it's the delimiter, we've reached the end (with delimiter)
	lda tmp                 ; Get the delimiter
	cmp #' '                ; Is it space?
	bne skip2               ; No: go to the next character
	lda (src_ptr),y         ; Get the character again
	cmp #CHAR_TAB           ; Is it a tab?
	bne skip2               ; No: go to the next character
	found_delim:                ; We found a delimiter
	sty pstack+4,x          ; Save the offset of the delimiter in n2
	iny
	sty pstack+2,x          ; And the offset +1 to n3
	jmp next                ; And we're done
	found_nul:                  ; We did not find a delimiter... reached NUL or end of buffer
	sty pstack+4,x          ; Save the offset of the delimiter in n2
	sty pstack+2,x          ; And to n3
	jmp next                ; And we're done
	.bend
; END enclose

; ( src-addr dst-addr u -- )
; BEGIN cmove
w_cmove:
	.byte $05
	.text 'cmove'
	.fill 11
	.word w_enclose
xt_cmove:
	.block
	lda pstack+3,x          ; Pull count off the stack
	sta tmp+1
	lda pstack+2,x
	sta tmp
	lda pstack+5,x          ; Pull the dst_ptr
	sta dst_ptr+1
	lda pstack+4,x
	sta dst_ptr
	lda pstack+7,x          ; Pull the src_ptr
	sta src_ptr+1
	lda pstack+6,x
	sta src_ptr
	txa                     ; Clean up the stack
	clc
	adc #6
	sta savex               ; And save it for later restoration
	ldx #0                  ; We'll use X for the high byte of the count
	ldy #0                  ; and Y for the low byte of the count
	loop:
	cpx tmp+1               ; is tmp == X:Y?
	bne copy
	cpy tmp
	beq done                ; Yes: we're done
	copy:
	lda (src_ptr),y         ; Copy the byte
	sta (dst_ptr),y
	iny                     ; Move to the next byte
	bne loop                ; Repeat for 256 bytes
	inx                     ; Move to the next block of 256
	inc src_ptr+1
	inc dst_ptr+1
	bra loop                ; And continue the loop
	done:
	ldx savex
	jmp next
	.bend
; END cmove

; ( addr1 addr2 u -- )
; BEGIN move
w_move:
	.byte $04
	.text 'move'
	.fill 12
	.word w_cmove
xt_move:
	.block
	sec                     ; Compare addr1 and addr2
	lda pstack+6,x
	sbc pstack+4,x
	sta tmp
	lda pstack+7,x
	sbc pstack+5,x
	sta tmp+1
	bmi a1less
	beq chklo
	; addr1 > addr2, so copy from addr1 to addr1 + u
	a1greater:
	lda pstack+2,x          ; Is u = 0?
	bne docopy1
	lda pstack+3,x
	beq done                ; Yes: we're done;
	lda (pstack+6,x)        ; Get the source byte
	sta (pstack+4,x)        ; Write it to the destination
	inc pstack+6,x          ; addr1 := addr1 + 1
	bne inc2
	inc pstack+7,x
	inc2:
	inc pstack+4,x          ; addr2 := addr2 + 1
	bne dec_count
	inc pstack+3,x
	dec_count:
	lda pstack+2,x          ; Decrement counter
	bne l1
	dec pstack+3,x
	l1:
	dec pstack+2,x
	bra a1greater
	; addr1 < addr2, so copy from addr1 + u to addr1
	a1less:
	lda pstack+4,x          ; Decrement addr2
	bne l2
	dec pstack+5,x
	l2:
	dec pstack+4,x
	clc                     ; addr2 := addr2 + u
	lda pstack+4,x
	adc pstack+2,x
	sta pstack+4,x
	lda pstack+5,x
	adc pstack+3,x
	sta pstack+5,x
	lda pstack+6,x          ; Decrement addr1
	bne l3
	dec pstack+7,x
	l3:
	dec pstack+6,x
	clc                     ; addr1 := addr1 + u
	lda pstack+6,x
	adc pstack+2,x
	sta pstack+6,x
	lda pstack+7,x
	adc pstack+3,x
	sta pstack+7,x
	loop2:
	lda pstack+2,x          ; Is u = 0?
	bne docopy1
	lda pstack+3,x
	beq done                ; Yes: we're done;
	docopy1:
	lda (pstack+6,x)        ; Get the source byte
	sta (pstack+4,x)        ; Write it to the destination
	lda pstack+6,x          ; Decrement addr1
	bne l4
	dec pstack+7,x
	l4:
	dec pstack+6,x
	lda pstack+4,x          ; Decrement addr2
	bne l5
	dec pstack+5,x
	l5:
	dec pstack+4,x
	lda pstack+2,x          ; Decrement counter
	bne l6
	dec pstack+3,x
	l6:
	dec pstack+2,x
	bra loop2
	chklo:
	lda tmp                 ; High bytes are equal: check the low byte
	bmi a1less
	beq done                ; If equal, we don't need to move the data
	bra a1greater
	done:
	txa
	clc
	adc #6
	tax
	rts
	.bend
; END move

; ( n1 n2 -- n3 )
; BEGIN +
w_x2b:
	.byte $01
	.text '+'
	.fill 15
	.word w_move
xt_x2b:
	.block
	clc
	lda pstack+4,x
	adc pstack+2,x
	sta pstack+4,x
	lda pstack+5,x
	adc pstack+3,x
	sta pstack+5,x
	inx
	inx
	jmp next
	.bend
; END +

; ( d1 d2 -- d3 )
; BEGIN d+
w_dx2b:
	.byte $02
	.text 'd+'
	.fill 14
	.word w_x2b
xt_dx2b:
	.block
	clc
	lda pstack+6,x
	adc pstack+2,x
	sta pstack+6,x
	lda pstack+7,x
	adc pstack+3,x
	sta pstack+7,x
	lda pstack+8,x
	adc pstack+4,x
	sta pstack+8,x
	lda pstack+9,x
	adc pstack+5,x
	sta pstack+9,x
	inx
	inx
	inx
	inx
	jmp next
	.bend
; END d+

; ( d1 d2 -- d3 )
; BEGIN d-
w_dx2d:
	.byte $02
	.text 'd-'
	.fill 14
	.word w_dx2b
xt_dx2d:
	.block
	sec
	lda pstack+6,x
	sbc pstack+2,x
	sta pstack+6,x
	lda pstack+7,x
	sbc pstack+3,x
	sta pstack+7,x
	lda pstack+8,x
	sbc pstack+4,x
	sta pstack+8,x
	lda pstack+9,x
	sbc pstack+5,x
	sta pstack+9,x
	inx
	inx
	inx
	inx
	jmp next
	.bend
; END d-

; ( n1 n2 -- n3 )
; BEGIN -
w_x2d:
	.byte $01
	.text '-'
	.fill 15
	.word w_dx2d
xt_x2d:
	.block
	sec
	lda pstack+4,x
	sbc pstack+2,x
	sta pstack+4,x
	lda pstack+5,x
	sbc pstack+3,x
	sta pstack+5,x
	inx
	inx
	jmp next
	.bend
; END -

; ( u1 u2 -- u3 )
; BEGIN u*
w_ux2a:
	.byte $02
	.text 'u*'
	.fill 14
	.word w_x2d
xt_ux2a:
	.block
	lda #0          ; Initialize RESULT to 0
	sta tmp+2
	ldx #16         ; There are 16 bits in n2
	l1:
	lsr pstack+3,x  ; Get low bit of n2
	ror pstack+2,x
	bcc l2          ; 0 or 1?
	tay             ; If 1, add n1 (hi byte of tmp is in A)
	clc
	lda pstack+4,x
	adc tmp+2
	sta tmp+2
	tya
	adc pstack+5,x
	l2:
	ror A
	ror tmp+2
	ror tmp+1
	ror tmp
	dec a
	bne l1
	sta tmp+3
	lda tmp         ; Save result to parameter stack
	sta pstack+4,x
	lda tmp+1
	sta pstack+5,x
	inx             ; Clean up parameter stack
	inx
	jmp next
	.bend
; END u*

; ( n1 n2 -- n3 )
; BEGIN *
w_x2a:
	.byte $01
	.text '*'
	.fill 15
	.word w_ux2a
xt_x2a:
	.block
	stz sign
	lda pstack+5,x  ; Check to see if n1 is negative
	bpl chk_n2
	lda #$80        ; Yes: record the sign
	sta sign
	sec             ; Negate n1
	lda #0
	sbc pstack+4,x
	sta pstack+4,x
	lda #0
	sbc pstack+5,x
	sta pstack+5,x
	chk_n2:
	lda pstack+3,x  ; Check to see if n2 is negative
	bpl init_tmp
	lda sign        ; Flip the sign bit, if so
	eor #$80        ; And set the bit for the remainder
	sta sign
	sec             ; Negate n2
	lda #0
	sbc pstack+2,x
	sta pstack+2,x
	lda #0
	sbc pstack+3,x
	sta pstack+3,x
	init_tmp:
	lda #0          ; Initialize RESULT to 0
	sta tmp+2
	ldx #16         ; There are 16 bits in n2
	l1:
	lsr pstack+3,x  ; Get low bit of n2
	ror pstack+2,x
	bcc l2          ; 0 or 1?
	tay             ; If 1, add n1 (hi byte of tmp is in A)
	clc
	lda pstack+4,x
	adc tmp+2
	sta tmp+2
	tya
	adc pstack+5,x
	l2:
	ror A
	ror tmp+2
	ror tmp+1
	ror tmp
	dec a
	bne l1
	sta tmp+3
	lda tmp         ; Save result to parameter stack
	sta pstack+4,x
	lda tmp+1
	sta pstack+5,x
	inx             ; Clean up parameter stack
	inx
	lda sign        ; Check the sign
	bpl done
	sec             ; If negative, negate result
	lda #0
	sbc pstack+2,x
	sta pstack+2,x
	lda #0
	sbc pstack+3,x
	sta pstack+3,x
	done:
	jmp next
	.bend
; END *

; ( ud1 n1 -- n2 n3 )
; BEGIN um/mod
w_umx2fmod:
	.byte $06
	.text 'um/mod'
	.fill 10
	.word w_x2a
xt_umx2fmod:
	.block
	sec
	lda     pstack+6,x          ; Subtract hi cell of dividend by
	sbc     pstack+2,x          ; divisor to see if there's an overflow condition.
	lda     pstack+7,x
	sbc     pstack+3,x
	bcs     overflow            ; Branch if /0 or overflow.
	lda     #$11                ; Loop 17x.
	sta     tmp                 ; Use tmp for loop counter.
	loop:
	rol     pstack+4,x          ; Rotate dividend lo cell left one bit.
	rol     pstack+5,x
	dec     tmp                 ; Decrement loop counter.
	beq     done                ; If we're done, then branch to end.
	rol     pstack+6,x          ; Otherwise rotate dividend hi cell left one bit.
	rol     pstack+7,x
	stz     tmp+1
	rol     tmp+1               ; Rotate the bit carried out of above into tmp+1.
	sec
	lda     pstack+6,x          ; Subtract dividend hi cell minus divisor.
	sbc     pstack+2,x
	sta     tmp+2               ; Put result temporarily in tmp+2 (lo byte)
	lda     pstack+7,x
	sbc     pstack+3,x
	tay                         ; and Y (hi byte).
	lda     tmp+1               ; Remember now to bring in the bit carried out above.
	sbc     #0
	bcc     loop
	lda     tmp+2               ; If that didn't cause a borrow,
	sta     pstack+6,x          ; make the result from above to
	sty     pstack+7,x          ; be the new dividend hi cell
	bra     loop                ; and then brach up.  (NMOS 6502 can use BCS here.)
	overflow:
	lda     #$ff                ; If overflow or /0 condition found,
	sta     pstack+6,x          ; just put FFFF in both the remainder
	sta     pstack+7,x
	sta     pstack+4,x          ; and the quotient.
	sta     pstack+5,x
	done:
	inx
	inx
	jmp next
	.bend
; END um/mod

; ( n -- d )
; BEGIN s>d
w_sx3ed:
	.byte $03
	.text 's>d'
	.fill 13
	.word w_umx2fmod
xt_sx3ed:
	.block
	dex
	dex
	lda pstack+4,x
	sta pstack+2,x
	lda pstack+5,x
	sta pstack+3,x
	bmi is_neg
	stz pstack+4,x
	stz pstack+5,x
	jmp next
	is_neg:
	lda #$ff
	sta pstack+4,x
	sta pstack+5,x
	jmp next
	.bend
; END s>d

; ( n1 -- n2 )
; BEGIN 1+
w_1x2b:
	.byte $02
	.text '1+'
	.fill 14
	.word w_sx3ed
xt_1x2b:
	.block
	inc pstack+2,x
	bne skip
	inc pstack+3,x
	skip:
	jmp next
	.bend
; END 1+

; ( n1 -- n2 )
; BEGIN 2+
w_2x2b:
	.byte $02
	.text '2+'
	.fill 14
	.word w_1x2b
xt_2x2b:
	.block
	clc
	lda pstack+2,x
	adc #2
	sta pstack+2,x
	lda pstack+3,x
	adc #0
	sta pstack+3,x
	jmp next
	.bend
; END 2+

; ( n1 -- n2 )
; BEGIN 1-
w_1x2d:
	.byte $02
	.text '1-'
	.fill 14
	.word w_2x2b
xt_1x2d:
	.block
	lda pstack+2,x
	bne l1
	dec pstack+3,x
	l1:
	dec pstack+2,x
	jmp next
	.bend
; END 1-

; ( n1 -- n2 )
; BEGIN 2-
w_2x2d:
	.byte $02
	.text '2-'
	.fill 14
	.word w_1x2d
xt_2x2d:
	.block
	sec
	lda pstack+2,x
	sbc #2
	sta pstack+2,x
	lda pstack+3,x
	sbc #0
	sta pstack+3,x
	jmp next
	.bend
; END 2-

; ( x1 x2 -- x3 )
; BEGIN and
w_and:
	.byte $03
	.text 'and'
	.fill 13
	.word w_2x2d
xt_and:
	.block
	lda pstack+2,x
	and pstack+4,x
	sta pstack+4,x
	lda pstack+3,x
	and pstack+5,x
	sta pstack+5,x
	inx
	inx
	jmp next
	.bend
; END and

; ( x1 x2 -- x3 )
; BEGIN or
w_or:
	.byte $02
	.text 'or'
	.fill 14
	.word w_and
xt_or:
	.block
	lda pstack+2,x
	ora pstack+4,x
	sta pstack+4,x
	lda pstack+3,x
	ora pstack+5,x
	sta pstack+5,x
	inx
	inx
	jmp next
	.bend
; END or

; ( x1 x2 -- x3 )
; BEGIN xor
w_xor:
	.byte $03
	.text 'xor'
	.fill 13
	.word w_or
xt_xor:
	.block
	lda pstack+2,x
	eor pstack+4,x
	sta pstack+4,x
	lda pstack+3,x
	eor pstack+5,x
	sta pstack+5,x
	inx
	inx
	jmp next
	.bend
; END xor

; ( x1 -- x2 )
; BEGIN not
w_not:
	.byte $03
	.text 'not'
	.fill 13
	.word w_xor
xt_not:
	.block
	lda pstack+2,x
	eor #$ff
	sta pstack+2,x
	lda pstack+3,x
	eor #$ff
	sta pstack+3,x
	jmp next
	.bend
; END not

; ( x -- f )
; BEGIN 0<
w_0x3c:
	.byte $02
	.text '0<'
	.fill 14
	.word w_not
xt_0x3c:
	.block
	lda pstack+3,x
	bmi istrue
	stz pstack+2,x
	stz pstack+3,x
	jmp next
	istrue:
	lda #$ff
	sta pstack+2,x
	sta pstack+3,x
	jmp next
	.bend
; END 0<

; ( x -- f )
; BEGIN 0=
w_0x3d:
	.byte $02
	.text '0='
	.fill 14
	.word w_0x3c
xt_0x3d:
	.block
	lda pstack+2,x
	bne isfalse
	lda pstack+3,x
	bne isfalse
	lda #$ff
	sta pstack+2,x
	sta pstack+3,x
	jmp next
	isfalse:
	stz pstack+2,x
	stz pstack+3,x
	jmp next
	.bend
; END 0=

; ( x -- f )
; BEGIN 0>
w_0x3e:
	.byte $02
	.text '0>'
	.fill 14
	.word w_0x3d
xt_0x3e:
	.block
	lda pstack+3,x
	bmi isfalse
	bne istrue
	lda pstack+2,x
	beq isfalse
	istrue:
	lda #$ff
	sta pstack+2,x
	sta pstack+3,x
	jmp next
	isfalse:
	stz pstack+2,x
	stz pstack+3,x
	jmp next
	.bend
; END 0>

; ( -- a-addr )
; BEGIN (variable)
w_x28variablex29:
	.byte $0A
	.text '(variable)'
	.fill 6
	.word w_0x3e
xt_x28variablex29:
	.block
	clc                     ; push(wp + 3)
	lda wp
	adc #3
	sta pstack,x
	lda wp+1
	adc #0
	sta pstack+1,x
	dex
	dex
	jmp next
	.bend
; END (variable)

; ( -- x )
; BEGIN (constant)
w_x28constantx29:
	.byte $0A
	.text '(constant)'
	.fill 6
	.word w_x28variablex29
xt_x28constantx29:
	.block
	ldy #3                  ; push(memory(wp + 3))
	lda (wp),y
	sta pstack,x
	iny
	lda (wp),y
	sta pstack+1,x
	dex
	dex
	jmp next
	.bend
; END (constant)

; ( -- n )
; BEGIN cells
w_cells:
	.byte $05
	.text 'cells'
	.fill 11
	.word w_x28constantx29
xt_cells:
	.block
	jmp xt_x28constantx29
	.word 2
	.bend
; END cells

; ( -- a-addr )
; BEGIN (user)
w_x28userx29:
	.byte $06
	.text '(user)'
	.fill 10
	.word w_cells
xt_x28userx29:
	.block
	clc                     ; push(up + memory(wp + 3))
	ldy #3
	lda up
	adc (wp),y
	sta pstack,x
	iny
	lda up+1
	adc (wp),y
	sta pstack+1,x
	dex
	dex
	jmp next
	.bend
; END (user)

; ( -- )
; BEGIN (branch)
w_x28branchx29:
	.byte $08
	.text '(branch)'
	.fill 8
	.word w_x28userx29
xt_x28branchx29:
	.block
	ldy #1              ; ip := branch address
	lda (ip)
	sta tmp
	lda (ip),y
	sta ip+1
	lda tmp
	sta ip
	jmp next
	.bend
; END (branch)

; ( f -- )
; BEGIN (branch0)
w_x28branch0x29:
	.byte $09
	.text '(branch0)'
	.fill 7
	.word w_x28branchx29
xt_x28branch0x29:
	.block
	lda pstack+2,x      ; Check to see if TOS is 0
	bne nobranch        ; No: skip over the branch address
	lda pstack+3,x
	beq dobranch        ; Yes: take the branch
	nobranch:
	clc                 ; No: skip over the branch address
	lda ip
	adc #2
	sta ip
	lda ip+1
	adc #0
	sta ip+1
	bra done
	dobranch:
	ldy #1              ; ip := branch address
	lda (ip)
	sta tmp
	lda (ip),y
	sta ip+1
	lda tmp
	sta ip
	done:
	inx                 ; clean up the parameter stack
	inx
	jmp next
	.bend
; END (branch0)

; ( limit initial -- )
; ( R: -- current limit )
; BEGIN (do)
w_x28dox29:
	.byte $04
	.text '(do)'
	.fill 12
	.word w_x28branch0x29
xt_x28dox29:
	.block
	lda pstack+3,x
	pha
	lda pstack+2,x
	pha
	lda pstack+5,x
	pha
	lda pstack+4,x
	pha
	clc
	txa
	adc #4
	tax
	jmp next
	.bend
; END (do)

; ( n -- )
; BEGIN >i
w_x3ei:
	.byte $02
	.text '>i'
	.fill 14
	.word w_x28dox29
xt_x3ei:
	.block
	.virtual $0101,x
	limit       .word ?
	current     .word ?
	.endv
	lda pstack+3,x      ; tmp := n
	sta tmp+1
	lda pstack+2,x
	sta tmp
	inx
	inx
	stx savex           ; Point X to the return stack temporarily
	tsx
	lda tmp+1           ; current := tmp = n
	sta current+1
	lda tmp
	sta current
	ldx savex
	jmp next
	.bend
; END >i

; ( -- )
; BEGIN leave
w_leave:
	.byte $05
	.text 'leave'
	.fill 11
	.word w_x3ei
xt_leave:
	.block
	.virtual $0101,x
	limit       .word ?
	current     .word ?
	.endv
	stx savex           ; Point X to the return stack temporarily
	tsx
	lda current+1       ; limit := current
	sta limit+1
	lda current
	sta limit
	ldx savex
	jmp next
	.bend
; END leave

; ( -- )
; ( R: x*i current limit -- x*i current limit | x*i )
; BEGIN (loop)
w_x28loopx29:
	.byte $06
	.text '(loop)'
	.fill 10
	.word w_leave
xt_x28loopx29:
	.block
	.virtual $0101,x
	limit       .word ?
	current     .word ?
	.endv
	stx savex           ; Point X to the return stack temporarily
	tsx
	inc current         ; Increment current
	bne chk_current
	inc current+1
	chk_current:
	sec
	lda current+1       ; compare high bytes
	sbc limit+1
	bvc label1          ; the equality comparison is in the Z flag here
	eor #$80            ; the Z flag is affected here
	label1:
	bmi dobranch        ; if current+1 < limit+1 then NUM1 < limit
	bvc label2          ; the Z flag was affected only if V is 1
	eor #$80            ; restore the Z flag to the value it had after sbc NUM2H
	label2:
	bne nobranch        ; if current+1 <> limit+1 then current > limit (so current >= limit)
	lda current         ; compare low bytes
	sbc limit
	bcc dobranch        ; if current < limit then current < limit
	nobranch:
	txa                 ; Yes: Remove the context from the return stack
	clc
	adc #4
	tax
	txs
	clc                 ; And skip over the branch address
	lda ip
	adc #2
	sta ip
	lda ip+1
	adc #0
	sta ip+1
	bra done
	dobranch:
	ldy #1              ; No: ip := branch address
	lda (ip)
	sta tmp
	lda (ip),y
	sta ip+1
	lda tmp
	sta ip
	done:
	ldx savex           ; Restore the parameter stack pointer
	jmp next
	.bend
; END (loop)

; ( n -- )
; ( R: x*i current limit -- x*i current limit | x*i )
; BEGIN (+loop)
w_x28x2bloopx29:
	.byte $07
	.text '(+loop)'
	.fill 9
	.word w_x28loopx29
xt_x28x2bloopx29:
	.block
	.virtual $0101,x
	limit       .word ?
	current     .word ?
	.endv
	lda pstack+3,x      ; Pop n from the stack
	sta tmp+1
	lda pstack+2,x
	sta tmp
	inx
	inx
	stx savex           ; Point X to the return stack temporarily
	tsx
	clc                 ; Increment current by n
	lda current
	adc tmp
	sta current
	lda current+1
	adc tmp+1
	sta current+1
	chk_current:
	sec
	lda current+1       ; compare high bytes
	sbc limit+1
	bvc label1          ; the equality comparison is in the Z flag here
	eor #$80            ; the Z flag is affected here
	label1:
	bmi dobranch        ; if current+1 < limit+1 then current < limit
	bvc label2          ; the Z flag was affected only if V is 1
	eor #$80            ; restore the Z flag to the value it had after sbc current+1
	label2:
	bne nobranch        ; if current+1 <> limit+1 then current > limit (so current >= limit)
	lda current         ; compare low bytes
	sbc limit
	bcc dobranch        ; if current < limit then current < limit
	nobranch:
	txa                 ; Yes: Remove the context from the return stack
	clc
	adc #4
	tax
	txs
	clc                 ; And skip over the branch address
	lda ip
	adc #2
	sta ip
	lda ip+1
	adc #0
	sta ip+1
	bra done
	dobranch:
	ldy #1              ; No: ip := branch address
	lda (ip)
	sta tmp
	lda (ip),y
	sta ip+1
	lda tmp
	sta ip
	done:
	ldx savex           ; Restore the parameter stack pointer
	jmp next
	.bend
; END (+loop)

; ( -- current )
; ( R: x*i current limit -- x*i current limit )
; BEGIN i
w_i:
	.byte $01
	.text 'i'
	.fill 15
	.word w_x28x2bloopx29
xt_i:
	.block
	.virtual $0101,x
	limit       .word ?
	current     .word ?
	.endv
	stx savex           ; Point X to the return stack temporarily
	tsx
	ldy current+1       ; Get the value of current
	lda current
	ldx savex           ; Restore the PSP
	sty pstack+1,x      ; Save the value of current to the stack
	sta pstack,x
	dex
	dex
	jmp next
	.bend
; END i

; ( x*i n1 n2 -- x*i | x*i n1 )
; BEGIN (of)
w_x28ofx29:
	.byte $04
	.text '(of)'
	.fill 12
	.word w_i
xt_x28ofx29:
	.block
	lda pstack+2,x      ; Does n1 == n2?
	cmp pstack+4,x
	bne not_eq
	lda pstack+3,x
	cmp pstack+5,x
	bne not_eq
	; Yes... pop both off and continue with code after OF
	inx
	inx
	inx
	inx
	clc                 ; Skip over the branch target
	lda ip
	adc #2
	sta ip
	lda ip+1
	adc #0
	sta ip+1
	jmp next
	; No... pop n2 off of stack and jump past END-OF
	not_eq:
	inx                 ; Remove n2 from stack
	inx
	ldy #1              ; Take the branch target
	lda (ip)
	sta tmp
	lda (ip),y
	sta ip+1
	lda tmp
	sta ip
	jmp next
	.bend
; END (of)

; ( i*x xt -- j*y )
; BEGIN execute
w_execute:
	.byte $07
	.text 'execute'
	.fill 9
	.word w_x28ofx29
xt_execute:
	.block
	lda pstack+2,x      ; wp := xt
	sta wp
	lda pstack+3,x
	sta wp+1
	inx                 ; Clean up stack
	inx
	jmp (wp)            ; jmp xt
	.bend
; END execute

; BEGIN (vocabulary)
w_x28vocabularyx29:
	.byte $0C
	.text '(vocabulary)'
	.fill 4
	.word w_execute
xt_x28vocabularyx29:
	.block
	clc                 ; tmp := up + user_context
	lda up
	adc #user_context
	sta tmp
	lda up+1
	adc #0
	sta tmp+1
	ldy #1              ; (tmp) := wp + 3
	clc
	lda wp
	adc #3
	sta (tmp)
	lda wp+1
	adc #0
	sta (tmp),y
	jmp next
	.bend
; END (vocabulary)

; BEGIN forth
w_forth:
	.byte $05
	.text 'forth'
	.fill 11
	.word w_x28vocabularyx29
xt_forth:
	.block
	jmp xt_x28vocabularyx29
	.word <>w_cold
	.bend
; END forth

; ( c-addr1 c-addr2 -- 0 | pfa u 1 )
; BEGIN (find)
w_x28findx29:
	.byte $06
	.text '(find)'
	.fill 10
	.word w_forth
xt_x28findx29:
	.block
	; find the word indicated by the counted string at c-addr1 on the dictionary, starting with c-addr2
	lda pstack+3,x          ; src_ptr = dictionary name
	sta src_ptr+1
	lda pstack+2,x
	sta src_ptr
	lda pstack+5,x          ; dst_ptr = word to find
	sta dst_ptr+1
	lda pstack+4,x
	sta dst_ptr
	loop:
	lda src_ptr             ; Check to see if src_ptr = NULL
	bne not_eod
	lda src_ptr+1
	bne not_eod
	; We've reached the end of the dictionary without finding a match
	inx                     ; Clean up the stack
	inx
	stz pstack+3,x          ; And return 0
	stz pstack+2,x
	jmp next
	not_eod:
	lda (src_ptr)           ; Get the size of the word in the dictionary
	and #$3f                ; Filter out the flags
	cmp (dst_ptr)           ; Check it against the word to search
	beq chk_chars           ; If they match, check the characters
	; Otherwise, move to the next word in the dictionary
	next_word:
	clc                     ; Move src_ptr to the link field
	lda src_ptr
	adc #17
	sta src_ptr
	lda src_ptr+1
	adc #0
	sta src_ptr+1
	ldy #1                  ; Follow the link to the next word in the dictionary
	lda (src_ptr)
	pha
	lda (src_ptr),y
	sta src_ptr+1
	pla
	sta src_ptr
	bra loop                ; And check that word
	chk_chars:
	tay                     ; y := index of last character in word
	dey
	char_loop:
	lda (src_ptr),y         ; Check the yth character
	cmp (dst_ptr),y
	bne next_word           ; If they are not equal, go to the next word in the dictionary
	dey                     ; Move to the previous character in the words
	cpy #$ff                ; Did we just check the first character?
	bne char_loop           ; No: check this one
	; Words are equal... we found a match!
	dex                     ; Make room for all the return values
	dex
	lda #1                  ; 1 at top of stack
	stz pstack+3,x
	sta pstack+2,x
	lda (dst_ptr)           ; Then the length of the word
	stz pstack+5,x
	sta pstack+4,x
	clc                     ; Then the pfa pointer
	lda src_ptr
	adc #17+5               ; Skip size, name, link, and code cfa
	sta pstack+6,x
	lda src_ptr+1
	adc #0
	sta pstack+7,x
	jmp next
	.bend
; END (find)

; ( c n1 -- n2 tf | 0 )
; BEGIN digit
w_digit:
	.byte $05
	.text 'digit'
	.fill 11
	.word w_x28findx29
xt_digit:
	.block
	lda pstack+4,x          ; Get the character in A
	cmp #'a'
	blt get_base
	cmp #'z'+1
	bge get_base
	and #$df               ; Turn off the case bit
	get_base:
	ldy pstack+2,x          ; Get the base into Y
	dey
	loop:
	cmp digits,y            ; Check to see if we have a match
	beq found               ; If so: return the number
	dey                     ; Move to the previous digit
	cpy #$ff                ; Have we checked the first digit?
	bne loop                ; No: check against this digit
	; We were not able to convert the digit
	stz pstack+5,x          ; Return false
	stz pstack+4,x
	inx                     ; Clean up the stack
	inx
	jmp next
	found:
	stz pstack+5,x          ; Return the value of the digit
	sty pstack+4,x
	lda #$ff                ; And the true flag
	sta pstack+3,x
	sta pstack+2,x
	jmp next
	digits:
	.text "0123456789ABCDEF"
	.bend
; END digit

; ( -- addr )
; BEGIN pad
w_pad:
	.byte $03
	.text 'pad'
	.fill 13
	.word w_digit
xt_pad:
	.block
	lda #$90
	sta pstack+1,x
	stz pstack,x
	dex
	dex
	jmp next
	.bend
; END pad

; ( Define some constants )
; BEGIN bs
w_bs:
	.byte $02
	.text 'bs'
	.fill 14
	.word w_pad
xt_bs:
	.block
	jmp xt_x28constantx29
	.word 8
	.bend
; END bs

; ( Backspace )
; BEGIN nl
w_nl:
	.byte $02
	.text 'nl'
	.fill 14
	.word w_bs
xt_nl:
	.block
	jmp xt_x28constantx29
	.word 13
	.bend
; END nl

; ( Newline character )
; BEGIN bl
w_bl:
	.byte $02
	.text 'bl'
	.fill 14
	.word w_nl
xt_bl:
	.block
	jmp xt_x28constantx29
	.word 32
	.bend
; END bl

; ( Blank character )
; ( Define the user variables )
; BEGIN s0
w_s0:
	.byte $02
	.text 's0'
	.fill 14
	.word w_bl
xt_s0:
	.block
	jmp xt_x28userx29
	.word 0
	.bend
; END s0

; ( Initial PSP )
; BEGIN r0
w_r0:
	.byte $02
	.text 'r0'
	.fill 14
	.word w_s0
xt_r0:
	.block
	jmp xt_x28userx29
	.word 2
	.bend
; END r0

; ( Initial RSP )
; BEGIN base
w_base:
	.byte $04
	.text 'base'
	.fill 12
	.word w_r0
xt_base:
	.block
	jmp xt_x28userx29
	.word 4
	.bend
; END base

; ( Current radix )
; BEGIN state
w_state:
	.byte $05
	.text 'state'
	.fill 11
	.word w_base
xt_state:
	.block
	jmp xt_x28userx29
	.word 6
	.bend
; END state

; ( Compiler/Interpreter state )
; BEGIN context
w_context:
	.byte $07
	.text 'context'
	.fill 9
	.word w_state
xt_context:
	.block
	jmp xt_x28userx29
	.word 8
	.bend
; END context

; ( Pointer to top wordlist for searching )
; BEGIN current
w_current:
	.byte $07
	.text 'current'
	.fill 9
	.word w_context
xt_current:
	.block
	jmp xt_x28userx29
	.word 10
	.bend
; END current

; ( Pointer to the current wordlist for definitions )
; BEGIN dp
w_dp:
	.byte $02
	.text 'dp'
	.fill 14
	.word w_current
xt_dp:
	.block
	jmp xt_x28userx29
	.word 12
	.bend
; END dp

; ( Pointer to the current compilation point )
; BEGIN >in
w_x3ein:
	.byte $03
	.text '>in'
	.fill 13
	.word w_dp
xt_x3ein:
	.block
	jmp xt_x28userx29
	.word 14
	.bend
; END >in

; ( Pointer to cursor offset into input buffer )
; BEGIN tib
w_tib:
	.byte $03
	.text 'tib'
	.fill 13
	.word w_x3ein
xt_tib:
	.block
	jmp xt_x28userx29
	.word 16
	.bend
; END tib

; ( Pointer to the cell containing the pointer to the input buffer )
; BEGIN source-id
w_sourcex2did:
	.byte $09
	.text 'source-id'
	.fill 7
	.word w_tib
xt_sourcex2did:
	.block
	jmp xt_x28userx29
	.word 18
	.bend
; END source-id

; ( Pointer to the source ID -1 for string, 0 for keyboard, any other number for file )
; BEGIN blk
w_blk:
	.byte $03
	.text 'blk'
	.fill 13
	.word w_sourcex2did
xt_blk:
	.block
	jmp xt_x28userx29
	.word 20
	.bend
; END blk

; ( Pointer to the block number )
; BEGIN dpl
w_dpl:
	.byte $03
	.text 'dpl'
	.fill 13
	.word w_blk
xt_dpl:
	.block
	jmp xt_x28userx29
	.word 22
	.bend
; END dpl

; ( Pointer to the DPL )
; BEGIN hld
w_hld:
	.byte $03
	.text 'hld'
	.fill 13
	.word w_dpl
xt_hld:
	.block
	jmp xt_x28userx29
	.word 24
	.bend
; END hld

; ( Pointer to the HLD variable )
; ( x -- 0 | x x )
; BEGIN ?dup
w_x3fdup:
	.byte $04
	.text '?dup'
	.fill 12
	.word w_hld
xt_x3fdup:
	.block
	jmp i_enter
	.word xt_dup
	.word xt_x28branch0x29
	.word l_168
	.word xt_dup
l_168:
	.word i_exit
	.bend
; END ?dup

; ( x1 x2 x3 -- x2 x3 x1 )
; BEGIN rot
w_rot:
	.byte $03
	.text 'rot'
	.fill 13
	.word w_x3fdup
xt_rot:
	.block
	jmp i_enter
	.word xt_x3er
	.word xt_swap
	.word xt_rx3e
	.word xt_swap
	.word i_exit
	.bend
; END rot

; ( x1 x2 -- x1 x2 x1 x2 )
; BEGIN 2dup
w_2dup:
	.byte $04
	.text '2dup'
	.fill 12
	.word w_rot
xt_2dup:
	.block
	jmp i_enter
	.word xt_over
	.word xt_over
	.word i_exit
	.bend
; END 2dup

; ( x x -- )
; BEGIN 2drop
w_2drop:
	.byte $05
	.text '2drop'
	.fill 11
	.word w_2dup
xt_2drop:
	.block
	jmp i_enter
	.word xt_drop
	.word xt_drop
	.word i_exit
	.bend
; END 2drop

; ( n1 n2 -- f )
; BEGIN <
w_x3c:
	.byte $01
	.text '<'
	.fill 15
	.word w_2drop
xt_x3c:
	.block
	jmp i_enter
	.word xt_x2d
	.word xt_0x3c
	.word i_exit
	.bend
; END <

; ( n1 n2 -- f )
; BEGIN >
w_x3e:
	.byte $01
	.text '>'
	.fill 15
	.word w_x3c
xt_x3e:
	.block
	jmp i_enter
	.word xt_x2d
	.word xt_0x3e
	.word i_exit
	.bend
; END >

; ( n1 n2 -- f )
; BEGIN =
w_x3d:
	.byte $01
	.text '='
	.fill 15
	.word w_x3e
xt_x3d:
	.block
	jmp i_enter
	.word xt_x2d
	.word xt_0x3d
	.word i_exit
	.bend
; END =

; ( d1 d2 -- f )
; BEGIN d<
w_dx3c:
	.byte $02
	.text 'd<'
	.fill 14
	.word w_x3d
xt_dx3c:
	.block
	jmp i_enter
	.word xt_dx2d
	.word xt_drop
	.word xt_0x3c
	.word i_exit
	.bend
; END d<

; ( n1 -- n2 )
; BEGIN abs
w_abs:
	.byte $03
	.text 'abs'
	.fill 13
	.word w_dx3c
xt_abs:
	.block
	jmp i_enter
	.word xt_dup
	.word xt_0x3c
	.word xt_x28branch0x29
	.word l_205
	.word xt_0
	.word xt_swap
	.word xt_x2d
l_205:
	.word i_exit
	.bend
; END abs

; ( d1 -- d2 )
; BEGIN dabs
w_dabs:
	.byte $04
	.text 'dabs'
	.fill 12
	.word w_abs
xt_dabs:
	.block
	jmp i_enter
	.word xt_over
	.word xt_0x3c
	.word xt_x28branch0x29
	.word l_212
	.word xt_0
	.word xt_0
	.word xt_2swap
	.word xt_dx2d
l_212:
	.word i_exit
	.bend
; END dabs

; ( If d1 is negative... )
; ( d2 := 0 - d1 )
; ( n1 n2 -- n3 n4 )
; BEGIN /mod
w_x2fmod:
	.byte $04
	.text '/mod'
	.fill 12
	.word w_dabs
xt_x2fmod:
	.block
	jmp i_enter
	.word xt_dup
	.word xt_x28literalx29
	.word 32768
	.word xt_and
	.word xt_x3er
	.word xt_swap
	.word xt_dup
	.word xt_x28literalx29
	.word 32768
	.word xt_and
	.word xt_x3er
	.word xt_abs
	.word xt_sx3ed
	.word xt_rot
	.word xt_umx2fmod
	.word xt_rx3e
	.word xt_rx3e
	.word xt_xor
	.word xt_x28branch0x29
	.word l_219
	.word xt_0
	.word xt_swap
	.word xt_x2d
l_219:
	.word i_exit
	.bend
; END /mod

; ( n1 n2 r: f2 )
; ( n2 n1 )
; ( n2 n1 r: f2 f1 )
; ( n2 d1 )
; ( d1 n2 )
; ( n3 n4 )
; ( n3 n4 f2 f1 )
; ( n3 n4 )
; ( n1 n2 -- n3 )
; BEGIN /
w_x2f:
	.byte $01
	.text '/'
	.fill 15
	.word w_x2fmod
xt_x2f:
	.block
	jmp i_enter
	.word xt_x2fmod
	.word xt_swap
	.word xt_drop
	.word i_exit
	.bend
; END /

; ( n1 n2 -- n3 )
; BEGIN mod
w_mod:
	.byte $03
	.text 'mod'
	.fill 13
	.word w_x2f
xt_mod:
	.block
	jmp i_enter
	.word xt_x2fmod
	.word xt_drop
	.word i_exit
	.bend
; END mod

; ( n1 n2 -- n1|n2 )
; BEGIN max
w_max:
	.byte $03
	.text 'max'
	.fill 13
	.word w_mod
xt_max:
	.block
	jmp i_enter
	.word xt_2dup
	.word xt_x3c
	.word xt_x28branch0x29
	.word l_228
	.word xt_over
	.word xt_drop
	.word xt_x28branchx29
	.word l_229
l_228:
	.word xt_drop
l_229:
	.word i_exit
	.bend
; END max

; ( n1 n2 -- n1|n2 )
; BEGIN min
w_min:
	.byte $03
	.text 'min'
	.fill 13
	.word w_max
xt_min:
	.block
	jmp i_enter
	.word xt_2dup
	.word xt_x3e
	.word xt_x28branch0x29
	.word l_236
	.word xt_over
	.word xt_drop
	.word xt_x28branchx29
	.word l_237
l_236:
	.word xt_drop
l_237:
	.word i_exit
	.bend
; END min

; ( pfa -- lfa )
; BEGIN lfa
w_lfa:
	.byte $03
	.text 'lfa'
	.fill 13
	.word w_min
xt_lfa:
	.block
	jmp i_enter
	.word xt_x28literalx29
	.word 5
	.word xt_x2d
	.word i_exit
	.bend
; END lfa

; ( pfa -- cfa )
; BEGIN cfa
w_cfa:
	.byte $03
	.text 'cfa'
	.fill 13
	.word w_lfa
xt_cfa:
	.block
	jmp i_enter
	.word xt_x28literalx29
	.word 3
	.word xt_x2d
	.word i_exit
	.bend
; END cfa

; ( pfa -- nfa )
; BEGIN nfa
w_nfa:
	.byte $03
	.text 'nfa'
	.fill 13
	.word w_cfa
xt_nfa:
	.block
	jmp i_enter
	.word xt_x28literalx29
	.word 22
	.word xt_x2d
	.word i_exit
	.bend
; END nfa

; ( nfa -- pfa )
; BEGIN pfa
w_pfa:
	.byte $03
	.text 'pfa'
	.fill 13
	.word w_nfa
xt_pfa:
	.block
	jmp i_enter
	.word xt_x28literalx29
	.word 22
	.word xt_x2b
	.word i_exit
	.bend
; END pfa

; ( -- addr )
; BEGIN here
w_here:
	.byte $04
	.text 'here'
	.fill 12
	.word w_pfa
xt_here:
	.block
	jmp i_enter
	.word xt_dp
	.word xt_x40
	.word i_exit
	.bend
; END here

; ( Return the value of the dictionary pointer )
; ( n -- )
; BEGIN allot
w_allot:
	.byte $05
	.text 'allot'
	.fill 11
	.word w_here
xt_allot:
	.block
	jmp i_enter
	.word xt_dp
	.word xt_x2bx21
	.word i_exit
	.bend
; END allot

; ( Add the amount to the dictionary pointer )
; ( x -- )
; BEGIN ,
w_x2c:
	.byte $01
	.text ','
	.fill 15
	.word w_allot
xt_x2c:
	.block
	jmp i_enter
	.word xt_here
	.word xt_x21
	.word xt_2
	.word xt_allot
	.word i_exit
	.bend
; END ,

; ( Write the word to the dictionary )
; ( Allocate space for it )
; ( c -- )
; BEGIN c,
w_cx2c:
	.byte $02
	.text 'c,'
	.fill 14
	.word w_x2c
xt_cx2c:
	.block
	jmp i_enter
	.word xt_here
	.word xt_cx21
	.word xt_1
	.word xt_allot
	.word i_exit
	.bend
; END c,

; ( Write the character to the dictionary )
; ( Allocate space for it )
; ( -- )
; BEGIN definitions
w_definitions:
	.byte $0B
	.text 'definitions'
	.fill 5
	.word w_cx2c
xt_definitions:
	.block
	jmp i_enter
	.word xt_context
	.word xt_x40
	.word xt_current
	.word xt_x21
	.word i_exit
	.bend
; END definitions

; ( -- addr )
; BEGIN latest
w_latest:
	.byte $06
	.text 'latest'
	.fill 10
	.word w_definitions
xt_latest:
	.block
	jmp i_enter
	.word xt_current
	.word xt_x40
	.word xt_x40
	.word i_exit
	.bend
; END latest

; ( c-addr1 -- c-addr2 n )
; BEGIN count
w_count:
	.byte $05
	.text 'count'
	.fill 11
	.word w_latest
xt_count:
	.block
	jmp i_enter
	.word xt_dup
	.word xt_1x2b
	.word xt_swap
	.word xt_cx40
	.word i_exit
	.bend
; END count

; ( addr2 := addr1 + 1 )
; ( stack now addr2 addr1 )
; ( stack now addr2 n )
; ( c-addr n -- )
; BEGIN type
w_type:
	.byte $04
	.text 'type'
	.fill 12
	.word w_count
xt_type:
	.block
	jmp i_enter
	.word xt_x3fdup
	.word xt_x28branch0x29
	.word l_244
	.word xt_over
	.word xt_x2b
	.word xt_swap
	.word xt_x28dox29
l_245:
	.word xt_i
	.word xt_cx40
	.word xt_x3fdup
	.word xt_x28branch0x29
	.word l_247
	.word xt_emit
	.word xt_x28branchx29
	.word l_248
l_247:
	.word xt_leave
l_248:
	.word xt_x28loopx29
	.word l_245
l_246:
	.word xt_x28branchx29
	.word l_249
l_244:
	.word xt_drop
l_249:
	.word i_exit
	.bend
; END type

; ( n is > 0 )
; ( n == 0 )
; ( -- )
; BEGIN space
w_space:
	.byte $05
	.text 'space'
	.fill 11
	.word w_type
xt_space:
	.block
	jmp i_enter
	.word xt_x28literalx29
	.word 32
	.word xt_emit
	.word i_exit
	.bend
; END space

; ( n -- )
; BEGIN spaces
w_spaces:
	.byte $06
	.text 'spaces'
	.fill 10
	.word w_space
xt_spaces:
	.block
	jmp i_enter
	.word xt_dup
	.word xt_0x3e
	.word xt_x28branch0x29
	.word l_250
	.word xt_0
	.word xt_x28dox29
l_251:
	.word xt_space
	.word xt_x28loopx29
	.word l_251
l_252:
	.word xt_x28branchx29
	.word l_253
l_250:
	.word xt_drop
l_253:
	.word i_exit
	.bend
; END spaces

; ( addr n -- )
; BEGIN expect
w_expect:
	.byte $06
	.text 'expect'
	.fill 10
	.word w_spaces
xt_expect:
	.block
	jmp i_enter
	.word xt_over
	.word xt_x2b
	.word xt_over
	.word xt_x28dox29
l_254:
	.word xt_key
	.word xt_bs
	.word xt_x28ofx29
	.word l_257
	.word xt_dup
	.word xt_i
	.word xt_x3d
	.word xt_not
	.word xt_x28branch0x29
	.word l_258
	.word xt_bs
	.word xt_emit
	.word xt_bl
	.word xt_emit
	.word xt_bs
	.word xt_emit
	.word xt_0
	.word xt_i
	.word xt_1x2d
	.word xt_cx21
	.word xt_i
	.word xt_2x2d
	.word xt_x3ei
l_258:
	.word xt_x28branchx29
	.word l_256
l_257:
	.word xt_nl
	.word xt_x28ofx29
	.word l_259
	.word xt_0
	.word xt_i
	.word xt_cx21
	.word xt_leave
	.word xt_x28branchx29
	.word l_256
l_259:
	.word xt_dup
	.word xt_dup
	.word xt_i
	.word xt_cx21
	.word xt_0
	.word xt_i
	.word xt_1x2b
	.word xt_cx21
	.word xt_emit
	.word xt_drop
l_256:
	.word xt_x28loopx29
	.word l_254
l_255:
	.word xt_drop
	.word i_exit
	.bend
; END expect

; ( addr addr-end )
; ( addr-end addr )
; ( addr c )
; ( Handle the backspace key )
; ( addr addr )
; ( If we're not at the start of the string )
; ( TODO: ring the bell if we are at the start )
; ( Delete the previous character from the screen )
; ( And zero out the current character )
; ( Handle the return key )
; ( Write a blank at the end of the line )
; ( Just return to the caller )
; ( Handle any other keypress )
; ( addr c c c )
; ( addr c c )
; ( write NUL sentinel after c in buffer )
; ( echo the character )
; ( drop the starting address )
; ( -- )
; BEGIN query
w_query:
	.byte $05
	.text 'query'
	.fill 11
	.word w_expect
xt_query:
	.block
	jmp i_enter
	.word xt_tib
	.word xt_x40
	.word xt_x28literalx29
	.word 80
	.word xt_expect
	.word xt_0
	.word xt_x3ein
	.word xt_x21
	.word i_exit
	.bend
; END query

; ( get address for TIB )
; ( Load at most 80 characters into TIB from keyboard )
; ( Set the IN index to the beginning )
; ( c-addr u -- )
; BEGIN erase
w_erase:
	.byte $05
	.text 'erase'
	.fill 11
	.word w_query
xt_erase:
	.block
	jmp i_enter
	.word xt_0
	.word xt_fill
	.word i_exit
	.bend
; END erase

; ( Write u NULs to c-addr )
; ( c-addr u -- )
; BEGIN blanks
w_blanks:
	.byte $06
	.text 'blanks'
	.fill 10
	.word w_erase
xt_blanks:
	.block
	jmp i_enter
	.word xt_bl
	.word xt_fill
	.word i_exit
	.bend
; END blanks

; ( Write u NULs to c-addr )
; ( c -- )
; BEGIN word
w_word:
	.byte $04
	.text 'word'
	.fill 12
	.word w_blanks
xt_word:
	.block
	jmp i_enter
	.word xt_tib
	.word xt_x40
	.word xt_x3ein
	.word xt_x40
	.word xt_x2b
	.word xt_swap
	.word xt_enclose
	.word xt_0
	.word xt_here
	.word xt_x21
	.word xt_x3ein
	.word xt_x2bx21
	.word xt_over
	.word xt_x2d
	.word xt_x3er
	.word xt_r
	.word xt_here
	.word xt_cx21
	.word xt_x2b
	.word xt_here
	.word xt_1x2b
	.word xt_rx3e
	.word xt_cmove
	.word i_exit
	.bend
; END word

; ( Read the next word from the input source )
; ( TODO: handle blocks and files )
; ( c addr1 )
; ( c addr2 )
; ( addr2 c )
; ( add2 n1 n2 n3 )
; ( addr2 n1 n2 )
; ( addr2 n1 : Save n2 - n1 )
; ( store the character count to the dictionary )
; ( addr3 : Starting address of the word )
; ( addr3 addr4 : Starting address in the dictionary space )
; ( addr3 addr4 count )
; ( copy the word to the dictionary space )
; ( -- pfa b tf | 0 )
; BEGIN -find
w_x2dfind:
	.byte $05
	.text '-find'
	.fill 11
	.word w_word
xt_x2dfind:
	.block
	jmp i_enter
	.word xt_bl
	.word xt_word
	.word xt_here
	.word xt_context
	.word xt_x40
	.word xt_x40
	.word xt_x28findx29
	.word xt_dup
	.word xt_0x3d
	.word xt_x28branch0x29
	.word l_260
	.word xt_drop
	.word xt_here
	.word xt_latest
	.word xt_x28findx29
l_260:
	.word i_exit
	.bend
; END -find

; ( Read a word of input and try to find it in the dictionary )
; ( -- )
; BEGIN decimal
w_decimal:
	.byte $07
	.text 'decimal'
	.fill 9
	.word w_x2dfind
xt_decimal:
	.block
	jmp i_enter
	.word xt_x28literalx29
	.word 10
	.word xt_base
	.word xt_x21
	.word i_exit
	.bend
; END decimal

; ( -- )
; BEGIN hex
w_hex:
	.byte $03
	.text 'hex'
	.fill 13
	.word w_decimal
xt_hex:
	.block
	jmp i_enter
	.word xt_x28literalx29
	.word 16
	.word xt_base
	.word xt_x21
	.word i_exit
	.bend
; END hex

; ( -- )
; BEGIN octal
w_octal:
	.byte $05
	.text 'octal'
	.fill 11
	.word w_hex
xt_octal:
	.block
	jmp i_enter
	.word xt_x28literalx29
	.word 8
	.word xt_base
	.word xt_x21
	.word i_exit
	.bend
; END octal

; ( d1 addr1 -- d2 addr2 )
; BEGIN (number)
w_x28numberx29:
	.byte $08
	.text '(number)'
	.fill 8
	.word w_octal
xt_x28numberx29:
	.block
	jmp i_enter
l_261:
	.word xt_1x2b
	.word xt_dup
	.word xt_x3er
	.word xt_cx40
	.word xt_base
	.word xt_x40
	.word xt_digit
	.word xt_x28branch0x29
	.word l_262
	.word xt_x3er
	.word xt_base
	.word xt_x40
	.word xt_ux2a
	.word xt_rx3e
	.word xt_sx3ed
	.word xt_dx2b
	.word xt_rx3e
	.word xt_x28branchx29
	.word l_261
l_262:
	.word xt_rx3e
	.word i_exit
	.bend
; END (number)

; ( d1 addr1+1 R: addr1+1 )
; ( d1 c )
; ( d1 c n )
; ( d1 n2 tf | d1 0 )
; ( d1 R: addr1+1 n2 )
; ( d2 )
; ( d2 n2 R: addr1+1 )
; ( d2 d3 )
; ( d4 )
; ( addr -- d )
; BEGIN number
w_number:
	.byte $06
	.text 'number'
	.fill 10
	.word w_x28numberx29
xt_number:
	.block
	jmp i_enter
	.word xt_0
	.word xt_0
	.word xt_rot
	.word xt_dup
	.word xt_1x2b
	.word xt_cx40
	.word xt_x28literalx29
	.word 45
	.word xt_x3d
	.word xt_x28branch0x29
	.word l_263
	.word xt_1
	.word xt_x3er
	.word xt_x28branchx29
	.word l_264
l_263:
	.word xt_0
	.word xt_x3er
	.word xt_1
	.word xt_x2b
l_264:
	.word xt_x2d1
l_265:
	.word xt_dpl
	.word xt_x21
	.word xt_x28numberx29
	.word xt_dup
	.word xt_cx40
	.word xt_bl
	.word xt_x3d
	.word xt_x28branch0x29
	.word l_266
	.word xt_dup
	.word xt_cx40
	.word xt_x28literalx29
	.word 46
	.word xt_x3d
	.word xt_x28branch0x29
	.word l_267
	.word xt_0
	.word xt_x28branchx29
	.word l_268
l_267:
	.word xt_dpl
	.word xt_x40
l_268:
	.word xt_x28branchx29
	.word l_265
l_266:
	.word xt_drop
	.word xt_rx3e
	.word xt_x28branch0x29
	.word l_269
	.word xt_0
	.word xt_0
	.word xt_2swap
	.word xt_dx2d
l_269:
	.word i_exit
	.bend
; END number

; ( d0 addr )
; ( d0 addr c )
; ( is it the minus sign? )
; ( save flag )
; ( d0 addr+1 )
; ( d0 addr )
; ( d1 addr2 )
; ( d1 addr2 c )
; ( d1 addr2 c )
; ( is it '-' )
; ( d1 addr2 0 )
; ( d1 addr2 n )
; ( d1 )
; ( d1 f )
; ( d2 )
; ( -- )
; BEGIN <#
w_x3cx23:
	.byte $02
	.text '<#'
	.fill 14
	.word w_number
xt_x3cx23:
	.block
	jmp i_enter
	.word xt_pad
	.word xt_hld
	.word xt_x21
	.word i_exit
	.bend
; END <#

; ( c -- )
; BEGIN hold
w_hold:
	.byte $04
	.text 'hold'
	.fill 12
	.word w_x3cx23
xt_hold:
	.block
	jmp i_enter
	.word xt_x2d1
	.word xt_hld
	.word xt_x2bx21
	.word xt_hld
	.word xt_x40
	.word xt_cx21
	.word i_exit
	.bend
; END hold

; ( d1 -- d2 )
; BEGIN #
w_x23:
	.byte $01
	.text '#'
	.fill 15
	.word w_hold
xt_x23:
	.block
	jmp i_enter
	.word xt_base
	.word xt_x40
	.word xt_umx2fmod
	.word xt_sx3ed
	.word xt_rot
	.word xt_x28literalx29
	.word 9
	.word xt_over
	.word xt_x3c
	.word xt_x28branch0x29
	.word l_270
	.word xt_x28literalx29
	.word 7
	.word xt_x2b
l_270:
	.word xt_x28literalx29
	.word 48
	.word xt_x2b
	.word xt_hold
	.word i_exit
	.bend
; END #

; ( d1 n )
; ( n1 n2 )
; ( d2 n1 )
; ( if the remainder < 9 )
; ( make it alphabetic )
; ( and make it ASCII )
; ( d1 -- d2 )
; BEGIN #s
w_x23s:
	.byte $02
	.text '#s'
	.fill 14
	.word w_x23
xt_x23s:
	.block
	jmp i_enter
l_271:
	.word xt_x23
	.word xt_over
	.word xt_over
	.word xt_or
	.word xt_0x3d
	.word xt_x28branch0x29
	.word l_271
l_272:
	.word i_exit
	.bend
; END #s

; ( n d -- d )
; BEGIN sign
w_sign:
	.byte $04
	.text 'sign'
	.fill 12
	.word w_x23s
xt_sign:
	.block
	jmp i_enter
	.word xt_rot
	.word xt_0x3c
	.word xt_x28branch0x29
	.word l_273
	.word xt_x28literalx29
	.word 45
	.word xt_hold
l_273:
	.word i_exit
	.bend
; END sign

; ( d -- addr count )
; BEGIN #>
w_x23x3e:
	.byte $02
	.text '#>'
	.fill 14
	.word w_sign
xt_x23x3e:
	.block
	jmp i_enter
	.word xt_2drop
	.word xt_hld
	.word xt_x40
	.word xt_pad
	.word xt_over
	.word xt_x2d
	.word i_exit
	.bend
; END #>

; ( d n -- )
; BEGIN d.r
w_dx2er:
	.byte $03
	.text 'd.r'
	.fill 13
	.word w_x23x3e
xt_dx2er:
	.block
	jmp i_enter
	.word xt_x3er
	.word xt_over
	.word xt_swap
	.word xt_dabs
	.word xt_x3cx23
	.word xt_x23s
	.word xt_sign
	.word xt_x23x3e
	.word xt_rx3e
	.word xt_over
	.word xt_x2d
	.word xt_spaces
	.word xt_type
	.word i_exit
	.bend
; END d.r

; ( Store n to the return stack )
; ( d -- )
; BEGIN d.
w_dx2e:
	.byte $02
	.text 'd.'
	.fill 14
	.word w_dx2er
xt_dx2e:
	.block
	jmp i_enter
	.word xt_0
	.word xt_dx2er
	.word i_exit
	.bend
; END d.

; ( x -- )
; BEGIN .
w_x2e:
	.byte $01
	.text '.'
	.fill 15
	.word w_dx2e
xt_x2e:
	.block
	jmp i_enter
	.word xt_sx3ed
	.word xt_dx2e
	.word i_exit
	.bend
; END .

; ( n1 n2 -- )
; BEGIN .r
w_x2er:
	.byte $02
	.text '.r'
	.fill 14
	.word w_x2e
xt_x2er:
	.block
	jmp i_enter
	.word xt_x3er
	.word xt_sx3ed
	.word xt_rx3e
	.word xt_dx2er
	.word i_exit
	.bend
; END .r

; ( addr -- )
; BEGIN ?
w_x3f:
	.byte $01
	.text '?'
	.fill 15
	.word w_x2er
xt_x3f:
	.block
	jmp i_enter
	.word xt_x40
	.word xt_x2e
	.word i_exit
	.bend
; END ?

; ( addr n -- )
; BEGIN dump
w_dump:
	.byte $04
	.text 'dump'
	.fill 12
	.word w_x3f
xt_dump:
	.block
	jmp i_enter
	.word xt_0
	.word xt_x28dox29
l_274:
	.word xt_cr
	.word xt_dup
	.word xt_0
	.word xt_swap
	.word xt_x28literalx29
	.word 5
	.word xt_dx2er
	.word xt_x28literalx29
	.word 58
	.word xt_emit
	.word xt_x28literalx29
	.word 8
	.word xt_0
	.word xt_x28dox29
l_276:
	.word xt_dup
	.word xt_x40
	.word xt_0
	.word xt_swap
	.word xt_x28literalx29
	.word 5
	.word xt_dx2er
	.word xt_2x2b
	.word xt_x28loopx29
	.word l_276
l_277:
	.word xt_x28literalx29
	.word 8
	.word xt_x28x2bloopx29
	.word l_274
l_275:
	.word xt_drop
	.word i_exit
	.bend
; END dump

; ( -- )
; BEGIN initrandom
w_initrandom:
	.byte $0A
	.text 'initrandom'
	.fill 6
	.word w_dump
xt_initrandom:
	.block
	jmp i_enter
	.word xt_1
	.word xt_x28literalx29
	.word 54950
	.word xt_cx21
	.word i_exit
	.bend
; END initrandom

; ( initialize the random number generator )
; ( Turn on the random number generator )
; ( -- n )
; BEGIN random
w_random:
	.byte $06
	.text 'random'
	.fill 10
	.word w_initrandom
xt_random:
	.block
	jmp i_enter
	.word xt_x28literalx29
	.word 54948
	.word xt_x40
	.word i_exit
	.bend
; END random

; ( Return a random, 16-bit number )
; BEGIN maze
w_maze:
	.byte $04
	.text 'maze'
	.fill 12
	.word w_random
xt_maze:
	.block
	jmp i_enter
	.word xt_initrandom
l_278:
	.word xt_random
	.word xt_1
	.word xt_and
	.word xt_x28literalx29
	.word 205
	.word xt_x2b
	.word xt_emit
	.word xt_x28branchx29
	.word l_278
l_279:
	.word i_exit
	.bend
; END maze

; ( Draw a random maze to fill the screen )
; BEGIN cold
w_cold:
	.byte $04
	.text 'cold'
	.fill 12
	.word w_maze
xt_cold:
	.block
	jmp i_enter
	.word xt_forth
	.word xt_definitions
	.word xt_0
	.word xt_blk
	.word xt_x21
	.word xt_x28literalx29
	.word 16384
	.word xt_dp
	.word xt_x21
	.word xt_x28literalx29
	.word 48896
	.word xt_tib
	.word xt_x21
	.word xt_x28literalx29
	.word l_280
	.word xt_x28branchx29
	.word l_281
l_280:
	.ptext "Welcome to MetaForth v00.00.00"
l_281:
	.word xt_count
	.word xt_type
	.word xt_cr
	.word xt_unittest
	.word xt_x28literalx29
	.word l_282
	.word xt_x28branchx29
	.word l_283
l_282:
	.ptext "All unit tests PASSED!"
l_283:
	.word xt_count
	.word xt_type
	.word xt_cr
	.word xt_hex
	.word xt_x28literalx29
	.word 36864
	.word xt_x3f
	.word xt_x28literalx29
	.word 32768
	.word xt_here
	.word xt_x21
l_284:
	.word xt_here
	.word xt_x40
	.word xt_0x3d
	.word xt_x28branch0x29
	.word l_286
	.word xt_cr
	.word xt_x28literalx29
	.word l_287
	.word xt_x28branchx29
	.word l_288
l_287:
	.ptext "ok"
l_288:
	.word xt_count
	.word xt_type
	.word xt_cr
	.word xt_query
l_286:
	.word xt_x2dfind
	.word xt_dup
	.word xt_0x3d
	.word xt_x28branch0x29
	.word l_289
	.word xt_drop
	.word xt_here
	.word xt_x40
	.word xt_0x3d
	.word xt_not
	.word xt_x28branch0x29
	.word l_290
	.word xt_cr
	.word xt_x28literalx29
	.word l_291
	.word xt_x28branchx29
	.word l_292
l_291:
	.ptext "Word not found:"
l_292:
	.word xt_count
	.word xt_type
	.word xt_bl
	.word xt_emit
	.word xt_here
	.word xt_count
	.word xt_type
	.word xt_cr
l_290:
	.word xt_x28branchx29
	.word l_293
l_289:
	.word xt_drop
	.word xt_drop
	.word xt_cr
	.word xt_x28literalx29
	.word l_294
	.word xt_x28branchx29
	.word l_295
l_294:
	.ptext "Found:"
l_295:
	.word xt_count
	.word xt_type
	.word xt_bl
	.word xt_emit
	.word xt_nfa
	.word xt_count
	.word xt_type
	.word xt_cr
l_293:
	.word xt_x28branchx29
	.word l_284
l_285:
	.word i_exit
	.bend
; END cold

; ( Initialize the block number to 0 )
; ( Initialize the dictionary pointer )
; ( Initialize the TIB )
.send
; End of auto-generated code

.include "mf_post_65c02.asm"
