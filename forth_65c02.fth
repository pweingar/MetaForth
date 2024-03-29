\\\
\\\ Sourcecode to generate the Metaforth interpreter
\\\

\\
\\ Basic code words for the WDC65C02
\\

$cpu$ 65c02

code next
    ldy #1          ; wp := (ip)
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
end-code

code exit
    pla             ; ip := pop()
    sta ip
    pla
    sta ip+1

    jmp xt_next
end-code

code enter
    lda ip+1        ; push(ip)
    pha
    lda ip
    pha

    clc             ; ip := wp + 3
    lda wp
    adc #3
    sta ip
    lda wp+1
    adc #0
    sta ip+1

    jmp xt_next
end-code

code dodoes
    clc             ; push PFA to parameter stack
    lda wp
    adc #3
    sta pstack,x
    lda wp+1
    adc #0
    sta pstack+1,x
    dex
    dex

    clc             ; Address of high level code into tmp
    pla
    adc #1
    sta tmp
    pla
    adc #0
    sta tmp+1

    lda ip+1        ; push ip to return stack
    pha
    lda ip
    pha

    lda tmp         ; ip := tmp
    sta ip
    lda tmp+1
    sta ip+1

    jmp xt_next
end-code

( a-addr -- )
code testname
    lda pstack+2,x
    sta test
    lda pstack+3,x
    sta test+1
    inx
    inx
    jmp xt_next
end-code

( x1 x2 -- )
code assert=
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

    jmp xt_next            ; And continue

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
end-code

( -- )
code halt
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
end-code

( -- addr )
code rp@
    stx savex           ; Save the parameter stack pointer
    tsx                 ; Get the return stack pointer
    sta tmp             ; Save it for later
    ldx savex           ; Recover the parameter stack pointer

    lda #$01            ; Get the high byte of the RSP
    sta pstack+1,x      ; Save it to the parameter stack
    lda tmp             ; Get the low byte of the RSP
    sta pstack,x        ; Save it to the parameter stack
    dex
    dex
  
    jmp xt_next
end-code

( addr -- )
code rp!
    stx savex           ; Save the parameter stack pointer
    lda pstack+2,x      ; Get the new RSP from the parameter stack
    tax
    txs                 ; Set the RSP
    ldx savex           ; Restore the parameter stack pointer
    inx
    inx

    jmp xt_next
end-code

( -- addr )
code sp@
    lda #>pstack        ; Get the high byte of the stack address
    sta pstack+1,x      ; And push it to the stack
    txa                 ; Get the low byte of the stack address
    sta pstack,x        ; And push it to the stack
    dex
    dex
    jmp xt_next
end-code

( addr -- )
code sp!
    lda pstack+2,x      ; Get the address from the stack
    tax                 ; And set the stack pointer
    jmp xt_next
end-code

( c -- )
code emit
    lda pstack+2,x
    phx
    jsr conout
    plx

    inx
    inx
    jmp xt_next
end-code

( -- f )
code key?
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
    jmp xt_next
end-code

( -- c )
code key
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
    jmp xt_next
end-code

( -- )
code cr
    phx
    lda #$0d
    jsr conout
    plx
    jmp xt_next
end-code

( -- 0 )
code 0
    stz pstack+1,x
    stz pstack,x
    dex
    dex
    jmp xt_next
end-code

( -- 1 )
code 1
    stz pstack+1,x
    lda #1
    sta pstack,x
    dex
    dex
    jmp xt_next
end-code

( -- 2 )
code 2
    stz pstack+1,x
    lda #2
    sta pstack,x
    dex
    dex
    jmp xt_next
end-code

( -- -1 )
code -1
    lda #$ff
    sta pstack+1,x
    sta pstack,x
    dex
    dex
    jmp xt_next
end-code

( -- -2 )
code -2
    lda #$fe
    sta pstack+1,x
    sta pstack,x
    dex
    dex
    jmp xt_next
end-code

( -- x )
code (literal)
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

    jmp xt_next
end-code 

( -- d )
code (dliteral)
    ldy #1
    lda (ip)
    sta pstack,x
    lda (ip),y
    sta pstack+1,x
    iny
    sta pstack+2,x
    iny
    sta pstack+3,x

    dex
    dex
    dex
    dex

    clc
    lda ip
    adc #2
    sta ip
    lda ip+1
    adc #0
    sta ip+1

    jmp xt_next
end-code 

( .. x_n -- n )
code depth
    stx tmp
    sec
    lda #$6e
    sbc tmp
    lsr a
    stz pstack+1,x
    sta pstack,x
    dex
    dex
    jmp xt_next
end-code
t{ depth -> 0 }t
t{ -1 depth -> -1 1 }t
t{ 1 1 1 depth -> 1 1 1 3 }t

( x -- )
code drop
    inx
    inx
    jmp xt_next
end-code
t{ 1 2 drop -> 1 }t
t{ 1 2 3 drop -> 1 2 }t

( x -- x x )
code dup
    lda pstack+2,x
    sta pstack,x
    lda pstack+3,x
    sta pstack+1,x
    dex
    dex
    jmp xt_next
end-code
t{ 1 dup -> 1 1 }t
t{ 1 2 dup -> 1 2 2 }t

( x1 x2 -- x2 x1 )
code swap
    lda pstack+2,x
    ldy pstack+4,x
    sty pstack+2,x
    sta pstack+4,x
    lda pstack+3,x
    ldy pstack+5,x
    sty pstack+3,x
    sta pstack+5,x
    jmp xt_next
end-code
t{ 1 2 3 swap -> 1 3 2 }t

( d1 d2 -- d2 d1 )
code 2swap
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
    
    jmp xt_next
end-code
t{ 1 2 3 4 2swap -> 3 4 1 2 }t

( x1 x2 -- x1 x2 x1 )
code over
    lda pstack+4,x
    sta pstack,x
    lda pstack+5,x
    sta pstack+1,x
    dex
    dex
    jmp xt_next
end-code
t{ 1 2 over -> 1 2 1 }t

( d1 d2 -- d1 d2 d1 )
code 2over
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
    
    jmp xt_next
end-code
t{ 1 2 3 4 2over -> 1 2 3 4 1 2 }t

( x -- ) ( R: -- x )
code >r
    lda pstack+3,x
    pha
    lda pstack+2,x
    pha
    inx
    inx
    jmp xt_next
end-code

( -- x ) ( R: x -- )
code r>
    pla
    sta pstack,x
    pla
    sta pstack+1,x
    dex
    dex
    jmp xt_next
end-code

( -- x )
code r
    pla
    sta pstack,x
    pla
    sta pstack+1,x
    pha
    lda pstack,x
    pha
    dex
    dex
    jmp xt_next
end-code

( r: x -- )
code rdrop
    pla
    pla
end-code

( x a-addr -- )
code !
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
    jmp xt_next
end-code

( a-addr -- x )
code @
    lda pstack+2,x
    sta tmp
    lda pstack+3,x
    sta tmp+1

    ldy #1
    lda (tmp)
    sta pstack+2,x
    lda (tmp),y
    sta pstack+3,x

    jmp xt_next
end-code
t{ 5555h 0004h ! 0004h @ -> 5555h }t
t{ aaaah 0004h ! 0004h @ -> aaaah }t

( c a-addr -- )
code c!
    lda pstack+4,x
    sta (pstack+2,x)
    inx
    inx
    inx
    inx

    jmp xt_next
end-code

( a-addr -- c )
code c@
    lda (pstack+2,x)
    sta pstack+2,x
    stz pstack+3,x

    jmp xt_next
end-code
t{ 55h 0003h c! 0003h c@ -> 55h }t
t{ aah 0003h c! 0003h c@ -> aah }t

( c-addr u b -- )
code fill 
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
    jmp xt_next
end-code

( n a-addr -- )
code +!
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

    jmp xt_next
end-code

( addr c -- addr n1 n2 n3 )
code enclose
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
    bne chk_delim1          ; Is it NUL? No: check it against the delimiter
none:
    jmp xt_next             ; Yes: we want to return all 0

chk_delim1:
	jsr is_delim			; Is it the delimiter?
    bcc found1st 			; No: we found our first character

    iny                     ; Move to the next character
    beq none                ; If we've rolled over, we found nothing
    bra loop1               ; Otherwise: check the next character

found1st:                   ; We found the first character
    sty pstack+6,x          ; Save the offset to it in n1

loop2:
    iny                     ; Go to the next character
    beq found_nul           ; If it rolls over, we've reached the end (NUL)

    lda (src_ptr),y         ; Get the character
    beq found_nul           ; If it is NUL, we've reached the end (NUL)

	jsr is_delim			; Is it the a delimiter?
	bcs found_delim			; Yes: return our results
	bra loop2

found_delim:                ; We found a delimiter
    sty pstack+4,x          ; Save the offset of the delimiter in n2
    iny
    sty pstack+2,x          ; And the offset +1 to n3
    jmp xt_next             ; And we're done

found_nul:                  ; We did not find a delimiter... reached NUL or end of buffer
    sty pstack+4,x          ; Save the offset of the delimiter in n2
    sty pstack+2,x          ; And to n3
    jmp xt_next             ; And we're done   

;
; Check to see if A is a delimiter, based on value in TMP
;
; If TMP is a space, any white space in A is a delimiter
; Otherwise, A is a delimiter if it is equal to tmp
;
; Returns
; carry set on true, clear on false
;
is_delim:
	cmp tmp				; Is the current character an exact match?
	beq delim_true		; Yes: return that we have a delimiter

	sta tmp+2			; Save A for the moment
	lda tmp				; Check the character to find
	cmp #' '			; Is it a space?
	bne delim_false		; No: we needed that exact match... return FALSE

	lda tmp+2			; Get A back
	cmp #' '			; Is it space?
	beq delim_true		; Yes: return true

	cmp #CHAR_TAB		; Is it a tab?
	beq delim_true		; Yes: return true

	cmp #CHAR_LF		; Is it a line-feed
	beq delim_true		; Yes: return true

	cmp #CHAR_CR		; Is it a carriage return?
	beq delim_true		; Yes: return true

	; Otherwise...

delim_false:			; Return FALSE
	clc
	rts

delim_true:				; Return TRUE
	sec
	rts
end-code

( src-addr dst-addr u -- )
code cmove
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
    jmp xt_next
end-code

( addr1 addr2 u -- )
code move
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
end-code

( n1 n2 -- n3 )
code +
    clc
    lda pstack+4,x
    adc pstack+2,x
    sta pstack+4,x
    lda pstack+5,x
    adc pstack+3,x
    sta pstack+5,x
    inx
    inx
    jmp xt_next    
end-code
t{ 1 0 + -> 1 }t
t{ 1 1 + -> 2 }t
t{ 3 10 + -> 13 }t
t{ ffffh 5 + -> 4 }t

( d1 d2 -- d3 )
code d+
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

    jmp xt_next
end-code
t{ 1234h 5678h 1111h 1111h d+ -> 2345h 6789h }t
t{ 0000h 1111h 0000h eeefh d+ -> 0001h 0000h }t

( d1 d2 -- d3 )
code d-
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
    
    jmp xt_next
end-code

( n1 n2 -- n3 )
code -
    sec
    lda pstack+4,x
    sbc pstack+2,x
    sta pstack+4,x
    lda pstack+5,x
    sbc pstack+3,x
    sta pstack+5,x
    inx
    inx
    jmp xt_next    
end-code
t{ 4 3 - -> 1 }t
t{ 3 4 - -> ffffh }t
t{ 10 5 - -> 5 }t

( n1 -- n2 )
code negate
	sec
	lda #0
	sbc pstack+2,x
	sta pstack+2,x
	lda #0
	sbc pstack+3,x
	sta pstack+3,x
	jmp xt_next
end-code
t{  0 negate ->  0 }t
t{  1 negate -> -1 }t
t{ -1 negate ->  1 }t
t{  2 negate -> -2 }t
t{ -2 negate ->  2 }t

( u1 u2 -- u3 )
[defined] math_hw [if]
( Unsigned multiply using the F56 integer math coprocessor )
code u*
    stz MMU_IO_CTRL ; Go to I/O page #0

    lda pstack+5,x  ; Set coprocessor unsigned A argument
    sta $de01
    lda pstack+4,x
    sta $de00

    lda pstack+3,x  ; Set coprocessor unsigned B argument
    sta $de03
    lda pstack+2,x
    sta $de02

    inx
    inx

    lda $de11       ; Read the coprocessor unsigned multiplication result
    sta pstack+3,x
    lda $de10
    sta pstack+2,x

    jmp xt_next
end-code
[else]
( Unsigned multiply using the generic 65C02 assembly )
code u*
	lda #16			; There are 16 bits in n2
	sta counter

	lda #0

	stz tmp+3
	stz tmp+2
	stz tmp+1
	stz tmp        
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
    ror a 
    ror tmp+2
    ror tmp+1
    ror tmp
    dec counter
    bne l1
    sta tmp+3

    lda tmp         ; Save result to parameter stack
    sta pstack+4,x
    lda tmp+1
    sta pstack+5,x

    inx             ; Clean up parameter stack
    inx

    jmp xt_next
end-code
[then]
t{ 1 7 u* -> 7 }t
t{ 2 3 u* -> 6 }t
t{ 10 4 u* -> 40 }t

( n1 n2 -- d )
code m*
    stz MMU_IO_CTRL ; Go to I/O page #0

    lda pstack+5,x  ; Set coprocessor unsigned A argument
    sta $de01
    lda pstack+4,x
    sta $de00

    lda pstack+3,x  ; Set coprocessor unsigned B argument
    sta $de03
    lda pstack+2,x
    sta $de02

    lda $de13       ; Read the coprocessor multiplication result
    sta pstack+5,x
    lda $de12
    sta pstack+4,x
    lda $de11
    sta pstack+3,x
    lda $de10
    sta pstack+2,x

    jmp xt_next
end-code

( u1 u2 -- u3 )
: *
	u*
;
t{ 2 3 * -> 6 }t
t{ 10 4 * -> 40 }t
t{ fffeh 3 * -> fffah }t

[defined] math_hw [if]
( Division with quotient and remainder, defined using the F256 integer hardware unit )
( n1 n2 -- n3 n4 )
code /mod
	stz MMU_IO_CTRL ; Go to I/O page #0

    lda pstack+5,x  ; Set coprocessor signed numerator
    sta $de07
    lda pstack+4,x
    sta $de06

    lda pstack+3,x  ; Set coprocessor signed denominator
    sta $de05
    lda pstack+2,x
    sta $de04

    lda $de17		; Set the remainder
    sta pstack+5,x
    lda $de16
    sta pstack+4,x

    lda $de15		; Set the quotient
    sta pstack+3,x
    lda $de14
    sta pstack+2,x

    jmp xt_next
end-code
[else]
( Division defined using um/mod using a software implementation )
( n1 n2 -- n3 n4 )
: /mod
	0 rot rot um/mod
;
[then]

( ud1 n1 -- n2 n3 )
code um/mod
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

    jmp xt_next
end-code
t{ 0 1 3 um/mod -> 1 0 }t
t{ 0 2 3 um/mod -> 2 0 }t
t{ 0 3 3 um/mod -> 0 1 }t
t{ 0 4 3 um/mod -> 1 1 }t
t{ 0 6 3 um/mod -> 0 2 }t

( n -- d )
code s>d
    dex
    dex
    lda pstack+4,x
    sta pstack+2,x
    lda pstack+5,x
    sta pstack+3,x

    bmi is_neg
    
    stz pstack+4,x
    stz pstack+5,x
    jmp xt_next

is_neg:
    lda #$ff
    sta pstack+4,x
    sta pstack+5,x
    jmp xt_next
end-code
t{ 1234h s>d -> 0000h 1234h }t
t{ ffffh s>d -> ffffh ffffh }t
t{ fffeh s>d -> ffffh fffeh }t

( n1 -- n2 )
code 1+
    inc pstack+2,x
    bne skip
    inc pstack+3,x
skip:
    jmp xt_next
end-code
t{ 1 1+ -> 2 }t
t{ 0 1+ -> 1 }t
t{ 20 1+ -> 21 }t
t{ ffffh 1+ -> 0 }t

( n1 -- n2 )
code 2+
    clc
    lda pstack+2,x
    adc #2
    sta pstack+2,x
    lda pstack+3,x
    adc #0
    sta pstack+3,x
    jmp xt_next
end-code
t{ 1 2+ -> 3 }t
t{ 0 2+ -> 2 }t
t{ 20 2+ -> 22 }t
t{ fffeh 2+ -> 0 }t

( n1 -- n2 )
code 1-
    lda pstack+2,x
    bne l1
    dec pstack+3,x
l1:
    dec pstack+2,x
    jmp xt_next
end-code
t{ 1 1- -> 0 }t
t{ 0 1- -> ffffh }t
t{ 20 1- -> 19 }t
t{ ffffh 1- -> fffeh }t

( n1 -- n2 )
code 2-
    sec
    lda pstack+2,x
    sbc #2
    sta pstack+2,x
    lda pstack+3,x
    sbc #0
    sta pstack+3,x
    jmp xt_next
end-code
t{ 1 2- -> ffffh }t
t{ 0 2- -> fffeh }t
t{ 20 2- -> 18 }t
t{ ffffh 2- -> fffdh }t

( x1 x2 -- x3 )
code and
    lda pstack+2,x
    and pstack+4,x
    sta pstack+4,x
    lda pstack+3,x
    and pstack+5,x
    sta pstack+5,x

    inx
    inx
    jmp xt_next
end-code
t{ 0000h 0000h and -> 0000h }t
t{ 0000h ffffh and -> 0000h }t
t{ ffffh 0000h and -> 0000h }t
t{ ffffh ffffh and -> ffffh }t

( x1 x2 -- x3 )
code or
    lda pstack+2,x
    ora pstack+4,x
    sta pstack+4,x
    lda pstack+3,x
    ora pstack+5,x
    sta pstack+5,x

    inx
    inx
    jmp xt_next
end-code
t{ 0000h 0000h or -> 0000h }t
t{ 0000h ffffh or -> ffffh }t
t{ ffffh 0000h or -> ffffh }t
t{ ffffh ffffh or -> ffffh }t

( x1 x2 -- x3 )
code xor
    lda pstack+2,x
    eor pstack+4,x
    sta pstack+4,x
    lda pstack+3,x
    eor pstack+5,x
    sta pstack+5,x

    inx
    inx
    jmp xt_next
end-code
t{ 0000h 0000h xor -> 0000h }t
t{ 0000h ffffh xor -> ffffh }t
t{ ffffh 0000h xor -> ffffh }t
t{ ffffh ffffh xor -> 0000h }t

( x1 -- x2 )
code not
    lda pstack+2,x
    eor #$ff
    sta pstack+2,x
    lda pstack+3,x
    eor #$ff
    sta pstack+3,x
    jmp xt_next
end-code
t{ 0000h not -> ffffh }t
t{ ffffh not -> 0000h }t

( x -- f )
code 0<
    lda pstack+3,x
    bmi istrue
    stz pstack+2,x
    stz pstack+3,x
    jmp xt_next

istrue:
    lda #$01
    sta pstack+2,x
    stz pstack+3,x
    jmp xt_next
end-code
t{ 0 0< -> 0000h }t
t{ 3 0< -> 0000h }t
t{ ffffh 0< -> 1 }t

( x -- f )
code 0=
    lda pstack+2,x
    bne isfalse
    lda pstack+3,x
    bne isfalse

    lda #$01
    sta pstack+2,x
    stz pstack+3,x
    jmp xt_next

isfalse:
    stz pstack+2,x
    stz pstack+3,x
    jmp xt_next
end-code
t{ 0 0= -> 1 }t
t{ 3 0= -> 0000h }t
t{ ffffh 0= -> 0000h }t

( x -- f )
code 0>
    lda pstack+3,x
    bmi isfalse
    bne istrue
    lda pstack+2,x
    beq isfalse

istrue:
    lda #$01
    sta pstack+2,x
    stz pstack+3,x
    jmp xt_next

isfalse:
    stz pstack+2,x
    stz pstack+3,x
    jmp xt_next
end-code
t{ 0 0> -> 0000h }t
t{ 3 0> -> 1 }t
t{ ffffh 0> -> 0000h }t

\\
\\ Variables, etc.
\\

( -- a-addr )
code (variable)
    clc                     ; push(wp + 3)
    lda wp
    adc #3
    sta pstack,x
    lda wp+1
    adc #0
    sta pstack+1,x

    dex
    dex

    jmp xt_next
end-code

( -- x )
code (constant)
    ldy #3                  ; push(memory(wp + 3))
    lda (wp),y
    sta pstack,x
    iny
    lda (wp),y
    sta pstack+1,x
    
    dex
    dex

    jmp xt_next
end-code 

: cells ( n1 -- n2 )
	2 *
;

( -- a-addr )
code (user)
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

    jmp xt_next
end-code 

\\
\\ Control Words
\\

( -- )
code (branch)
    ldy #1              ; ip := branch address
    lda (ip)
    sta tmp
    lda (ip),y
    sta ip+1
    lda tmp
    sta ip

    jmp xt_next
end-code 

( f -- )
code (branch0)
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

    jmp xt_next
end-code 

( limit initial -- ) ( R: -- current limit )
code (do)
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

    jmp xt_next
end-code

( n -- )
code >i
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
    jmp xt_next
end-code

( -- )
code (leave)
	pla					; Remove the current value
	pla
	pla					; Remove the limit value
	pla

    ldy #1              ; ip := branch address
    lda (ip)
    sta tmp
    lda (ip),y
    sta ip+1
    lda tmp
    sta ip
    jmp xt_next
end-code

( -- )
code leave
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
    jmp xt_next
end-code

( -- ) ( R: x*i current limit -- x*i current limit | x*i )
code (loop)
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
    jmp xt_next
end-code

( n -- ) ( R: x*i current limit -- x*i current limit | x*i )
code (+loop)
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
    jmp xt_next
end-code

( -- current ) ( R: x*i current limit -- x*i current limit )
code i
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
    jmp xt_next
end-code

( x*i n1 n2 -- x*i | x*i n1 )
code (of)
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

    jmp xt_next

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

    jmp xt_next
end-code

( i*x xt -- j*y )
code execute
    lda pstack+2,x      ; wp := xt
    sta wp
    lda pstack+3,x
    sta wp+1

    inx                 ; Clean up stack
    inx

    jmp (wp)            ; jmp xt
end-code
t{ ' 1 execute -> 1 }t
t{ 1 2 ' + execute -> 3 }t

\\
\\ Vocabulary and wordlist support
\\

code (vocabulary)
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
    
    jmp xt_next
end-code

code forth
    jmp xt_x28vocabularyx29
    .word <>w_cold
end-code

( c-addr1 c-addr2 -- 0 | pfa u 1 )
code (find)
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
    jmp xt_next

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
    tay                     ; y := index to character to check

char_loop:
    lda (src_ptr),y         ; Check the yth character
    cmp (dst_ptr),y
    bne next_word           ; If they are not equal, go to the next word in the dictionary

    dey                     ; Move to the previous character in the words
    bne char_loop           ; Are we back at the size? No: keep checking

    ; Words are equal... we found a match!

    dex                     ; Make room for all the return values
    dex

    lda #1                  ; 1 at top of stack
    stz pstack+3,x
    sta pstack+2,x

    lda (src_ptr)           ; Then the length of the word
    stz pstack+5,x
    sta pstack+4,x

    clc                     ; Then the pfa pointer
    lda src_ptr
    adc #17+5               ; Skip size, name, link, and code cfa
    sta pstack+6,x
    lda src_ptr+1
    adc #0
    sta pstack+7,x

    jmp xt_next
end-code

( c n1 -- n2 tf | 0)
code digit
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

not_found:
    inx                     ; Clean up the stack
    inx

    stz pstack+3,x          ; Return false
    stz pstack+2,x

    jmp xt_next

found:
    stz pstack+5,x          ; Return the value of the digit
    sty pstack+4,x

    lda #$ff                ; And the true flag
    sta pstack+3,x
    sta pstack+2,x

    jmp xt_next

digits:
    .text "0123456789ABCDEF"
end-code
t{ 30h 10 digit -> 0 ffffh }t
t{ 31h 10 digit -> 1 ffffh }t
t{ 39h 10 digit -> 9 ffffh }t
t{ 41h 10 digit -> 0 }t
t{ 61h 10 digit -> 0 }t
t{ 41h 16 digit -> 10 ffffh }t
t{ 61h 16 digit -> 10 ffffh }t
t{ 46h 16 digit -> fh ffffh }t
t{ 66h 16 digit -> fh ffffh }t

( -- c )
: jump-instruction
    ( Push the code for a jump instruction )
    4ch
;

( -- c )
: call-instruction
    ( Push the code for a call instruction )
    20h
;
