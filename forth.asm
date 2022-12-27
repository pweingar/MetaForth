.include "mf_pre_65c02.asm"
.section code
; Start of auto-generated code

; ( a-addr -- )
; BEGIN testname
w_testname:
	.byte $08
	.text 'testname'
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
	.word w_assertx3d
xt_halt:
	.block
	lock:
	nop
	bra lock
	.bend
; END halt

; ( c -- )
; BEGIN emit
w_emit:
	.byte $04
	.text 'emit'
	.word w_halt
xt_emit:
	.block
	phx
	phy
	lda pstack+2,x
	jsr conout
	plx
	inx
	inx
	ply
	jmp next
	.bend
; END emit

; ( -- )
; BEGIN cr
w_cr:
	.byte $02
	.text 'cr'
	.word w_emit
xt_cr:
	.block
	phx
	lda #$0d
	jsr conout
	plx
	jmp next
	.bend
; END cr

; ( a-addr -- )
; BEGIN type
w_type:
	.byte $04
	.text 'type'
	.word w_cr
xt_type:
	.block
	lda pstack+2,x
	sta src_ptr
	lda pstack+3,x
	sta src_ptr+1
	phx
	phy
	jsr prints
	ply
	plx
	inx
	inx
	jmp next
	.bend
; END type

; ( -- 0 )
; BEGIN 0
w_0:
	.byte $01
	.text '0'
	.word w_type
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
	.null "1 2 over --> 1 2 1"
l_19:
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
	.word l_20
	.word xt_x28branchx29
	.word l_21
l_20:
	.null "5555h 0004h ! 0004h @ --> 5555h"
l_21:
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
	.word l_22
	.word xt_x28branchx29
	.word l_23
l_22:
	.null "aaaah 0004h ! 0004h @ --> aaaah"
l_23:
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
	.word l_24
	.word xt_x28branchx29
	.word l_25
l_24:
	.null "55h 0003h c! 0003h c@ --> 55h"
l_25:
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
	.word l_26
	.word xt_x28branchx29
	.word l_27
l_26:
	.null "aah 0003h c! 0003h c@ --> aah"
l_27:
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
	.word l_28
	.word xt_x28branchx29
	.word l_29
l_28:
	.null "1 0 + --> 1"
l_29:
	.word xt_testname
	.word xt_1
	.word xt_0
	.word xt_x2b
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_30
	.word xt_x28branchx29
	.word l_31
l_30:
	.null "1 1 + --> 2"
l_31:
	.word xt_testname
	.word xt_1
	.word xt_1
	.word xt_x2b
	.word xt_2
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_32
	.word xt_x28branchx29
	.word l_33
l_32:
	.null "3 10 + --> 13"
l_33:
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
	.word l_34
	.word xt_x28branchx29
	.word l_35
l_34:
	.null "ffffh 5 + --> 4"
l_35:
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
	.word l_36
	.word xt_x28branchx29
	.word l_37
l_36:
	.null "4 3 - --> 1"
l_37:
	.word xt_testname
	.word xt_x28literalx29
	.word 4
	.word xt_x28literalx29
	.word 3
	.word xt_x2d
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_38
	.word xt_x28branchx29
	.word l_39
l_38:
	.null "3 4 - --> ffffh"
l_39:
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
	.word l_40
	.word xt_x28branchx29
	.word l_41
l_40:
	.null "10 5 - --> 5"
l_41:
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
	.word l_42
	.word xt_x28branchx29
	.word l_43
l_42:
	.null "1 1+ --> 2"
l_43:
	.word xt_testname
	.word xt_1
	.word xt_1x2b
	.word xt_2
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_44
	.word xt_x28branchx29
	.word l_45
l_44:
	.null "0 1+ --> 1"
l_45:
	.word xt_testname
	.word xt_0
	.word xt_1x2b
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_46
	.word xt_x28branchx29
	.word l_47
l_46:
	.null "20 1+ --> 21"
l_47:
	.word xt_testname
	.word xt_x28literalx29
	.word 20
	.word xt_1x2b
	.word xt_x28literalx29
	.word 21
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_48
	.word xt_x28branchx29
	.word l_49
l_48:
	.null "ffffh 1+ --> 0"
l_49:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_1x2b
	.word xt_0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_50
	.word xt_x28branchx29
	.word l_51
l_50:
	.null "1 2+ --> 3"
l_51:
	.word xt_testname
	.word xt_1
	.word xt_2x2b
	.word xt_x28literalx29
	.word 3
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_52
	.word xt_x28branchx29
	.word l_53
l_52:
	.null "0 2+ --> 2"
l_53:
	.word xt_testname
	.word xt_0
	.word xt_2x2b
	.word xt_2
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_54
	.word xt_x28branchx29
	.word l_55
l_54:
	.null "20 2+ --> 22"
l_55:
	.word xt_testname
	.word xt_x28literalx29
	.word 20
	.word xt_2x2b
	.word xt_x28literalx29
	.word 22
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_56
	.word xt_x28branchx29
	.word l_57
l_56:
	.null "fffeh 2+ --> 0"
l_57:
	.word xt_testname
	.word xt_x28literalx29
	.word 65534
	.word xt_2x2b
	.word xt_0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_58
	.word xt_x28branchx29
	.word l_59
l_58:
	.null "1 1- --> 0"
l_59:
	.word xt_testname
	.word xt_1
	.word xt_1x2d
	.word xt_0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_60
	.word xt_x28branchx29
	.word l_61
l_60:
	.null "0 1- --> ffffh"
l_61:
	.word xt_testname
	.word xt_0
	.word xt_1x2d
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_62
	.word xt_x28branchx29
	.word l_63
l_62:
	.null "20 1- --> 19"
l_63:
	.word xt_testname
	.word xt_x28literalx29
	.word 20
	.word xt_1x2d
	.word xt_x28literalx29
	.word 19
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_64
	.word xt_x28branchx29
	.word l_65
l_64:
	.null "ffffh 1- --> fffeh"
l_65:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_1x2d
	.word xt_x28literalx29
	.word 65534
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_66
	.word xt_x28branchx29
	.word l_67
l_66:
	.null "1 2- --> ffffh"
l_67:
	.word xt_testname
	.word xt_1
	.word xt_2x2d
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_68
	.word xt_x28branchx29
	.word l_69
l_68:
	.null "0 2- --> fffeh"
l_69:
	.word xt_testname
	.word xt_0
	.word xt_2x2d
	.word xt_x28literalx29
	.word 65534
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_70
	.word xt_x28branchx29
	.word l_71
l_70:
	.null "20 2- --> 18"
l_71:
	.word xt_testname
	.word xt_x28literalx29
	.word 20
	.word xt_2x2d
	.word xt_x28literalx29
	.word 18
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_72
	.word xt_x28branchx29
	.word l_73
l_72:
	.null "ffffh 2- --> fffdh"
l_73:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_2x2d
	.word xt_x28literalx29
	.word 65533
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_74
	.word xt_x28branchx29
	.word l_75
l_74:
	.null "0000h 0000h and --> 0000h"
l_75:
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
	.word l_76
	.word xt_x28branchx29
	.word l_77
l_76:
	.null "0000h ffffh and --> 0000h"
l_77:
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
	.word l_78
	.word xt_x28branchx29
	.word l_79
l_78:
	.null "ffffh 0000h and --> 0000h"
l_79:
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
	.word l_80
	.word xt_x28branchx29
	.word l_81
l_80:
	.null "ffffh ffffh and --> ffffh"
l_81:
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
	.word l_82
	.word xt_x28branchx29
	.word l_83
l_82:
	.null "0000h 0000h or --> 0000h"
l_83:
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
	.word l_84
	.word xt_x28branchx29
	.word l_85
l_84:
	.null "0000h ffffh or --> ffffh"
l_85:
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
	.word l_86
	.word xt_x28branchx29
	.word l_87
l_86:
	.null "ffffh 0000h or --> ffffh"
l_87:
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
	.word l_88
	.word xt_x28branchx29
	.word l_89
l_88:
	.null "ffffh ffffh or --> ffffh"
l_89:
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
	.word l_90
	.word xt_x28branchx29
	.word l_91
l_90:
	.null "0000h 0000h xor --> 0000h"
l_91:
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
	.word l_92
	.word xt_x28branchx29
	.word l_93
l_92:
	.null "0000h ffffh xor --> ffffh"
l_93:
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
	.word l_94
	.word xt_x28branchx29
	.word l_95
l_94:
	.null "ffffh 0000h xor --> ffffh"
l_95:
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
	.word l_96
	.word xt_x28branchx29
	.word l_97
l_96:
	.null "ffffh ffffh xor --> 0000h"
l_97:
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
	.word l_98
	.word xt_x28branchx29
	.word l_99
l_98:
	.null "0000h not --> ffffh"
l_99:
	.word xt_testname
	.word xt_x28literalx29
	.word 0
	.word xt_not
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_100
	.word xt_x28branchx29
	.word l_101
l_100:
	.null "ffffh not --> 0000h"
l_101:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_not
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_102
	.word xt_x28branchx29
	.word l_103
l_102:
	.null "0 0< --> 0000h"
l_103:
	.word xt_testname
	.word xt_0
	.word xt_0x3c
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_104
	.word xt_x28branchx29
	.word l_105
l_104:
	.null "3 0< --> 0000h"
l_105:
	.word xt_testname
	.word xt_x28literalx29
	.word 3
	.word xt_0x3c
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_106
	.word xt_x28branchx29
	.word l_107
l_106:
	.null "ffffh 0< --> ffffh"
l_107:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_0x3c
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_108
	.word xt_x28branchx29
	.word l_109
l_108:
	.null "0 0= --> ffffh"
l_109:
	.word xt_testname
	.word xt_0
	.word xt_0x3d
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_110
	.word xt_x28branchx29
	.word l_111
l_110:
	.null "3 0= --> 0000h"
l_111:
	.word xt_testname
	.word xt_x28literalx29
	.word 3
	.word xt_0x3d
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_112
	.word xt_x28branchx29
	.word l_113
l_112:
	.null "ffffh 0= --> 0000h"
l_113:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_0x3d
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_114
	.word xt_x28branchx29
	.word l_115
l_114:
	.null "0 0> --> 0000h"
l_115:
	.word xt_testname
	.word xt_0
	.word xt_0x3e
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_116
	.word xt_x28branchx29
	.word l_117
l_116:
	.null "3 0> --> ffffh"
l_117:
	.word xt_testname
	.word xt_x28literalx29
	.word 3
	.word xt_0x3e
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_118
	.word xt_x28branchx29
	.word l_119
l_118:
	.null "ffffh 0> --> 0000h"
l_119:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_0x3e
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_120
	.word xt_x28branchx29
	.word l_121
l_120:
	.null "cells 2 - 0= --> ffffh"
l_121:
	.word xt_testname
	.word xt_cells
	.word xt_2
	.word xt_x2d
	.word xt_0x3d
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_122
	.word xt_x28branchx29
	.word l_123
l_122:
	.null "bl 32 - 0= --> ffffh"
l_123:
	.word xt_testname
	.word xt_bl
	.word xt_x28literalx29
	.word 32
	.word xt_x2d
	.word xt_0x3d
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_124
	.word xt_x28branchx29
	.word l_125
l_124:
	.null "' 1 execute --> 1"
l_125:
	.word xt_testname
	.word xt_x28literalx29
	.word xt_1
	.word xt_execute
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_126
	.word xt_x28branchx29
	.word l_127
l_126:
	.null "1 2 ' + execute --> 3"
l_127:
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
	.word l_129
	.word xt_x28branchx29
	.word l_130
l_129:
	.null "0 ?dup --> 0"
l_130:
	.word xt_testname
	.word xt_0
	.word xt_x3fdup
	.word xt_0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_131
	.word xt_x28branchx29
	.word l_132
l_131:
	.null "1 ?dup --> 1 1"
l_132:
	.word xt_testname
	.word xt_1
	.word xt_x3fdup
	.word xt_1
	.word xt_assertx3d
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_133
	.word xt_x28branchx29
	.word l_134
l_133:
	.null "1 2 < --> ffffh"
l_134:
	.word xt_testname
	.word xt_1
	.word xt_2
	.word xt_x3c
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_135
	.word xt_x28branchx29
	.word l_136
l_135:
	.null "2 1 < --> 0000h"
l_136:
	.word xt_testname
	.word xt_2
	.word xt_1
	.word xt_x3c
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_137
	.word xt_x28branchx29
	.word l_138
l_137:
	.null "0 ffffh < --> 0000h"
l_138:
	.word xt_testname
	.word xt_0
	.word xt_x28literalx29
	.word 65535
	.word xt_x3c
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_139
	.word xt_x28branchx29
	.word l_140
l_139:
	.null "ffffh 0 < --> ffffh"
l_140:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_0
	.word xt_x3c
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_141
	.word xt_x28branchx29
	.word l_142
l_141:
	.null "1 2 > --> 0000h"
l_142:
	.word xt_testname
	.word xt_1
	.word xt_2
	.word xt_x3e
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_143
	.word xt_x28branchx29
	.word l_144
l_143:
	.null "2 1 > --> ffffh"
l_144:
	.word xt_testname
	.word xt_2
	.word xt_1
	.word xt_x3e
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_145
	.word xt_x28branchx29
	.word l_146
l_145:
	.null "0 ffffh > --> ffffh"
l_146:
	.word xt_testname
	.word xt_0
	.word xt_x28literalx29
	.word 65535
	.word xt_x3e
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_147
	.word xt_x28branchx29
	.word l_148
l_147:
	.null "ffffh 0 > --> 0000h"
l_148:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_0
	.word xt_x3e
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_149
	.word xt_x28branchx29
	.word l_150
l_149:
	.null "1 0 = --> 0000h"
l_150:
	.word xt_testname
	.word xt_1
	.word xt_0
	.word xt_x3d
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_151
	.word xt_x28branchx29
	.word l_152
l_151:
	.null "1 1 = --> ffffh"
l_152:
	.word xt_testname
	.word xt_1
	.word xt_1
	.word xt_x3d
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_153
	.word xt_x28branchx29
	.word l_154
l_153:
	.null "ffffh 0 = --> 0000h"
l_154:
	.word xt_testname
	.word xt_x28literalx29
	.word 65535
	.word xt_0
	.word xt_x3d
	.word xt_x28literalx29
	.word 0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_155
	.word xt_x28branchx29
	.word l_156
l_155:
	.null "ffffh ffffh = --> ffffh"
l_156:
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
	.word l_157
	.word xt_x28branchx29
	.word l_158
l_157:
	.null "0 0 = --> ffffh"
l_158:
	.word xt_testname
	.word xt_0
	.word xt_0
	.word xt_x3d
	.word xt_x28literalx29
	.word 65535
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_162
	.word xt_x28branchx29
	.word l_163
l_162:
	.null "1 2 max --> 2"
l_163:
	.word xt_testname
	.word xt_1
	.word xt_2
	.word xt_max
	.word xt_2
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_164
	.word xt_x28branchx29
	.word l_165
l_164:
	.null "3 0 max --> 3"
l_165:
	.word xt_testname
	.word xt_x28literalx29
	.word 3
	.word xt_0
	.word xt_max
	.word xt_x28literalx29
	.word 3
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_166
	.word xt_x28branchx29
	.word l_167
l_166:
	.null "fffeh ffffh max --> ffffh"
l_167:
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
	.word l_170
	.word xt_x28branchx29
	.word l_171
l_170:
	.null "1 2 min --> 1"
l_171:
	.word xt_testname
	.word xt_1
	.word xt_2
	.word xt_min
	.word xt_1
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_172
	.word xt_x28branchx29
	.word l_173
l_172:
	.null "3 0 min --> 0"
l_173:
	.word xt_testname
	.word xt_x28literalx29
	.word 3
	.word xt_0
	.word xt_min
	.word xt_0
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_174
	.word xt_x28branchx29
	.word l_175
l_174:
	.null "fffeh ffffh min --> fffeh"
l_175:
	.word xt_testname
	.word xt_x28literalx29
	.word 65534
	.word xt_x28literalx29
	.word 65535
	.word xt_min
	.word xt_x28literalx29
	.word 65534
	.word xt_assertx3d
	.word xt_x28literalx29
	.word l_176
	.word xt_x28branchx29
	.word l_177
l_176:
	.null "1 2 3 rot --> 2 3 1"
l_177:
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
	.word l_178
	.word xt_x28branchx29
	.word l_179
l_178:
	.null "1 2 2dup --> 1 2 1 2"
l_179:
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
	.word l_180
	.word xt_x28branchx29
	.word l_181
l_180:
	.null "1 2 3 4 2drop --> 1 2"
l_181:
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
	.word i_exit
	.bend
; END unittest

; ( x -- )
; BEGIN drop
w_drop:
	.byte $04
	.text 'drop'
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

; ( x1 x2 -- x1 x2 x1 )
; BEGIN over
w_over:
	.byte $04
	.text 'over'
	.word w_swap
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

; ( x -- )
; ( R: -- x )
; BEGIN >r
w_x3er:
	.byte $02
	.text '>r'
	.word w_over
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

; ( a-addr -- )
; BEGIN +!
w_x2bx21:
	.byte $02
	.text '+!'
	.word w_fill
xt_x2bx21:
	.block
	lda (pstack+2,x)        ; Increment the low byte
	inc a
	sta (pstack+2,x)
	bne done                ; If it does not roll over, we're done
	lda pstack+2,x          ; Increment the pointer
	inc a
	sta pstack+2,x
	bne inc2
	lda pstack+3,x
	inc a
	sta pstack+3,x
	inc2:
	lda (pstack+2,x)        ; Increment the high byte
	inc a
	sta (pstack+2,x)
	done:
	inx                     ; Clean up the stack
	inx
	jmp next
	.bend
; END +!

; ( addr1 addr2 u -- )
; BEGIN move
w_move:
	.byte $04
	.text 'move'
	.word w_x2bx21
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

; ( n1 n2 -- n3 )
; BEGIN -
w_x2d:
	.byte $01
	.text '-'
	.word w_x2b
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

; ( n1 n2 -- n3 )
; BEGIN *
w_x2a:
	.byte $01
	.text '*'
	.word w_x2d
xt_x2a:
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
; END *

; ( n1 -- n2 )
; BEGIN 1+
w_1x2b:
	.byte $02
	.text '1+'
	.word w_x2a
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

; ( -- n )
; BEGIN bl
w_bl:
	.byte $02
	.text 'bl'
	.fill 14
	.word w_cells
xt_bl:
	.block
	jmp xt_x28constantx29
	.word 32
	.bend
; END bl

; ( -- a-addr )
; BEGIN (user)
w_x28userx29:
	.byte $06
	.text '(user)'
	.word w_bl
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

; ( Define the user variables )
; BEGIN s0
w_s0:
	.byte $02
	.text 's0'
	.fill 14
	.word w_x28userx29
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
	.word 1
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
	.word 2
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
	.word 3
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
	.word 4
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
	.word 5
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
	.word 6
	.bend
; END dp

; ( Pointer to the current compilation point )
; ( -- )
; BEGIN (branch)
w_x28branchx29:
	.byte $08
	.text '(branch)'
	.word w_dp
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

; ( -- )
; ( R: x*i current limit -- x*i current limit | x*i )
; BEGIN (loop)
w_x28loopx29:
	.byte $06
	.text '(loop)'
	.word w_x28dox29
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
	lda current         ; current == limit?
	cmp limit
	bne dobranch
	lda current+1
	cmp limit+1
	bne dobranch
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

; ( -- current )
; ( R: x*i current limit -- x*i current limit )
; BEGIN i
w_i:
	.byte $01
	.text 'i'
	.word w_x28loopx29
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

; ( i*x xt -- j*y )
; BEGIN execute
w_execute:
	.byte $07
	.text 'execute'
	.word w_i
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
	.word w_x28vocabularyx29
xt_forth:
	.block
	jmp xt_x28vocabularyx29
	.word <>w_cold
	.bend
; END forth

; ( x -- 0 | x x )
; BEGIN ?dup
w_x3fdup:
	.byte $04
	.text '?dup'
	.fill 12
	.word w_forth
xt_x3fdup:
	.block
	jmp i_enter
	.word xt_dup
	.word xt_x28branch0x29
	.word l_128
	.word xt_dup
l_128:
	.word i_exit
	.bend
; END ?dup

; ( n1 n2 -- f )
; BEGIN <
w_x3c:
	.byte $01
	.text '<'
	.fill 15
	.word w_x3fdup
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

; ( n1 -- n2 )
; BEGIN abs
w_abs:
	.byte $03
	.text 'abs'
	.fill 13
	.word w_x3d
xt_abs:
	.block
	jmp i_enter
	.word xt_dup
	.word xt_0x3c
	.word xt_x28branch0x29
	.word l_159
	.word xt_0
	.word xt_swap
	.word xt_x2d
l_159:
	.word i_exit
	.bend
; END abs

; ( n1 n2 -- n1|n2 )
; BEGIN max
w_max:
	.byte $03
	.text 'max'
	.fill 13
	.word w_abs
xt_max:
	.block
	jmp i_enter
	.word xt_over
	.word xt_over
	.word xt_x3c
	.word xt_x28branch0x29
	.word l_160
	.word xt_over
	.word xt_drop
	.word xt_x28branchx29
	.word l_161
l_160:
	.word xt_drop
l_161:
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
	.word xt_over
	.word xt_over
	.word xt_x3e
	.word xt_x28branch0x29
	.word l_168
	.word xt_over
	.word xt_drop
	.word xt_x28branchx29
	.word l_169
l_168:
	.word xt_drop
l_169:
	.word i_exit
	.bend
; END min

; ( x1 x2 x3 -- x2 x3 x1 )
; BEGIN rot
w_rot:
	.byte $03
	.text 'rot'
	.fill 13
	.word w_min
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

; ( pfa -- lfa )
; BEGIN lfa
w_lfa:
	.byte $03
	.text 'lfa'
	.fill 13
	.word w_2drop
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

; BEGIN foobar
w_foobar:
	.byte $06
	.text 'foobar'
	.fill 10
	.word w_latest
xt_foobar:
	.block
	jmp i_enter
l_182:
	.word xt_x28literalx29
	.word l_184
	.word xt_x28branchx29
	.word l_185
l_184:
	.null "Hello,  world!"
l_185:
	.word xt_type
	.word xt_cr
	.word xt_x28branchx29
	.word l_183
	.word xt_0
	.word xt_x28branch0x29
	.word l_182
l_183:
	.word i_exit
	.bend
; END foobar

; BEGIN cold
w_cold:
	.byte $04
	.text 'cold'
	.fill 12
	.word w_foobar
xt_cold:
	.block
	jmp i_enter
	.word xt_x28literalx29
	.word l_186
	.word xt_x28branchx29
	.word l_187
l_186:
	.null "Welcome to MetaForth v00.00.00"
l_187:
	.word xt_type
	.word xt_cr
	.word xt_x28literalx29
	.word 5
	.word xt_0
	.word xt_x28dox29
l_188:
	.word xt_x28literalx29
	.word l_190
	.word xt_x28branchx29
	.word l_191
l_190:
	.null "Hello, MetaForth!"
l_191:
	.word xt_type
	.word xt_cr
	.word xt_i
	.word xt_x28loopx29
	.word l_188
l_189:
	.word xt_x28literalx29
	.word l_192
	.word xt_x28branchx29
	.word l_193
l_192:
	.null "All unit tests PASSED!"
l_193:
	.word xt_type
	.word xt_cr
	.word i_exit
	.bend
; END cold

.send
; End of auto-generated code

.include "mf_post_65c02.asm"
