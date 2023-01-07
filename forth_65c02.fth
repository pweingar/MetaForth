\\\
\\\ Sourcecode to generate the Metaforth interpreter
\\\

\\
\\ Basic code words for the WDC65C02
\\

$cpu$ 65c02

( a-addr -- )
code testname
    lda pstack+2,x
    sta test
    lda pstack+3,x
    sta test+1
    inx
    inx
    jmp next
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
end-code

( -- )
code halt
lock:
    nop
    bra lock
end-code

( c -- )
code emit
    lda pstack+2,x
    phx
    jsr conout
    plx

    inx
    inx
    jmp next
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
    jmp next
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
    jmp next
end-code

( -- )
code cr
    phx
    lda #$0d
    jsr conout
    plx
    jmp next
end-code

( -- 0 )
code 0
    stz pstack+1,x
    stz pstack,x
    dex
    dex
    jmp next
end-code

( -- 1 )
code 1
    stz pstack+1,x
    lda #1
    sta pstack,x
    dex
    dex
    jmp next
end-code

( -- 2 )
code 2
    stz pstack+1,x
    lda #2
    sta pstack,x
    dex
    dex
    jmp next
end-code

( -- -1 )
code -1
    lda #$ff
    sta pstack+1,x
    sta pstack,x
    dex
    dex
    jmp next
end-code

( -- -2 )
code -2
    lda #$fe
    sta pstack+1,x
    sta pstack,x
    dex
    dex
    jmp next
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

    jmp next
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
    jmp next
end-code
{ depth --> 0 }
{ 0 depth --> 0 1 }
{ 1 1 1 depth --> 1 1 1 3 }

( x -- )
code drop
    inx
    inx
    jmp next
end-code
{ 1 2 drop --> 1 }
{ 1 2 3 drop --> 1 2 }

( x -- x x )
code dup
    lda pstack+2,x
    sta pstack,x
    lda pstack+3,x
    sta pstack+1,x
    dex
    dex
    jmp next
end-code
{ 1 dup --> 1 1 }
{ 1 2 dup --> 1 2 2 }

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
    jmp next
end-code
{ 1 2 3 swap --> 1 3 2 }

( x1 x2 -- x1 x2 x1 )
code over
    lda pstack+4,x
    sta pstack,x
    lda pstack+5,x
    sta pstack+1,x
    dex
    dex
    jmp next
end-code
{ 1 2 over --> 1 2 1 }

( x -- ) ( R: -- x )
code >r
    lda pstack+3,x
    pha
    lda pstack+2,x
    pha
    inx
    inx
    jmp next
end-code

( -- x ) ( R: x -- )
code r>
    pla
    sta pstack,x
    pla
    sta pstack+1,x
    dex
    dex
    jmp next
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
    jmp next
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
    jmp next
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

    jmp next
end-code
{ 5555h 0004h ! 0004h @ --> 5555h }
{ aaaah 0004h ! 0004h @ --> aaaah }

( c a-addr -- )
code c!
    lda pstack+4,x
    sta (pstack+2,x)
    inx
    inx
    inx
    inx

    jmp next
end-code

( a-addr -- c )
code c@
    lda (pstack+2,x)
    sta pstack+2,x
    stz pstack+3,x

    jmp next
end-code
{ 55h 0003h c! 0003h c@ --> 55h }
{ aah 0003h c! 0003h c@ --> aah }

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
    jmp next
end-code

( a-addr -- )
code +!
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
    jmp next    
end-code
{ 1 0 + --> 1 }
{ 1 1 + --> 2 }
{ 3 10 + --> 13 }
{ ffffh 5 + --> 4 }

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
    jmp next    
end-code
{ 4 3 - --> 1 }
{ 3 4 - --> ffffh }
{ 10 5 - --> 5 }

( n1 n2 -- n3 )
code *
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
end-code

( n1 n2 -- n3 n4 )
( code adapted from https://llx.com/Neil/a2/mult.html )
code /mod  
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
    stz tmp         ; Initialize tmp (remainder) to 0
    stz tmp+1

    lda #16         ; There are 16 bits in NUM1
    sta counter
    
l1:
    asl pstack+4,x  ; Shift hi bit of NUM1 into REM
    rol pstack+5,x  ; (vacating the lo bit, which will be used for the quotient)
    rol tmp
    rol tmp+1
    lda tmp
    sec             ; Trial subtraction
    sbc pstack+2,x
    tay
    lda tmp+1,x
    sbc pstack+3,x
    bcc l2          ; Did subtraction succeed?
    sta tmp+1       ; If yes, save it
    sty tmp
    inc pstack+4,x  ; and record a 1 in the quotient
l2:
    dec counter
    bne l1

    lda pstack+5,x  ; Set the quotient
    sta pstack+3,x
    lda pstack+4,x
    sta pstack+2,x

    lda tmp         ; Save the remainder to the stack
    sta pstack+4,x
    lda tmp+1
    sta pstack+5,x

    lda sign        ; Check to see if the sign should be negative
    bpl done

    sec             ; Negate the quotient
    lda #0
    sbc pstack+2,x
    sta pstack+2,x
    lda #0
    sbc pstack+3,x
    sta pstack+3,x

done:
    jmp next
end-code
{ 1 3 /mod --> 1 0 }
{ 2 3 /mod --> 2 0 }
{ 3 3 /mod --> 0 1 }
{ 4 3 /mod --> 1 1 }
{ 6 3 /mod --> 0 2 }

( n1 -- n2 )
code 1+
    inc pstack+2,x
    bne skip
    inc pstack+3,x
skip:
    jmp next
end-code
{ 1 1+ --> 2 }
{ 0 1+ --> 1 }
{ 20 1+ --> 21 }
{ ffffh 1+ --> 0 }

( n1 -- n2 )
code 2+
    clc
    lda pstack+2,x
    adc #2
    sta pstack+2,x
    lda pstack+3,x
    adc #0
    sta pstack+3,x
    jmp next
end-code
{ 1 2+ --> 3 }
{ 0 2+ --> 2 }
{ 20 2+ --> 22 }
{ fffeh 2+ --> 0 }

( n1 -- n2 )
code 1-
    lda pstack+2,x
    bne l1
    dec pstack+3,x
l1:
    dec pstack+2,x
    jmp next
end-code
{ 1 1- --> 0 }
{ 0 1- --> ffffh }
{ 20 1- --> 19 }
{ ffffh 1- --> fffeh }

( n1 -- n2 )
code 2-
    sec
    lda pstack+2,x
    sbc #2
    sta pstack+2,x
    lda pstack+3,x
    sbc #0
    sta pstack+3,x
    jmp next
end-code
{ 1 2- --> ffffh }
{ 0 2- --> fffeh }
{ 20 2- --> 18 }
{ ffffh 2- --> fffdh }

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
    jmp next
end-code
{ 0000h 0000h and --> 0000h }
{ 0000h ffffh and --> 0000h }
{ ffffh 0000h and --> 0000h }
{ ffffh ffffh and --> ffffh }

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
    jmp next
end-code
{ 0000h 0000h or --> 0000h }
{ 0000h ffffh or --> ffffh }
{ ffffh 0000h or --> ffffh }
{ ffffh ffffh or --> ffffh }

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
    jmp next
end-code
{ 0000h 0000h xor --> 0000h }
{ 0000h ffffh xor --> ffffh }
{ ffffh 0000h xor --> ffffh }
{ ffffh ffffh xor --> 0000h }

( x1 -- x2 )
code not
    lda pstack+2,x
    eor #$ff
    sta pstack+2,x
    lda pstack+3,x
    eor #$ff
    sta pstack+3,x
    jmp next
end-code
{ 0000h not --> ffffh }
{ ffffh not --> 0000h }

( x -- f )
code 0<
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
end-code
{ 0 0< --> 0000h }
{ 3 0< --> 0000h }
{ ffffh 0< --> ffffh }

( x -- f )
code 0=
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
end-code
{ 0 0= --> ffffh }
{ 3 0= --> 0000h }
{ ffffh 0= --> 0000h }

( x -- f )
code 0>
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
end-code
{ 0 0> --> 0000h }
{ 3 0> --> ffffh }
{ ffffh 0> --> 0000h }

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

    jmp next
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

    jmp next
end-code 

( -- n )
2 constant cells
{ cells 2 - 0= --> ffffh }

( -- n )
32 constant bl
{ bl 32 - 0= --> ffffh }

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

    jmp next
end-code 

( Define the user variables )

0 user s0           ( Initial PSP )
1 user r0           ( Initial RSP )
2 user base         ( Current radix )
3 user state        ( Compiler/Interpreter state )
4 user context      ( Pointer to top wordlist for searching )
5 user current      ( Pointer to the current wordlist for definitions )
6 user dp           ( Pointer to the current compilation point )
7 user >in          ( Pointer to cursor offset into input buffer )
8 user tib          ( Pointer to the cell containing the pointer to the input buffer )
9 user source-id    ( Pointer to the source ID -1 for string, 0 for keyboard, any other number for file )

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

    jmp next
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

    jmp next
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

    jmp next
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

    dex
    dex

    stx savex           ; Point X to the return stack temporarily
    tsx

    lda tmp+1           ; current := tmp = n
    sta current+1
    lda tmp
    sta current

    ldx savex
    jmp next
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
    jmp next
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
end-code

( n -- ) ( R: x*i current limit -- x*i current limit | x*i )
code (+loop)
    .virtual $0101,x
limit       .word ?
current     .word ?
    .endv

    lda pstack+3,x
    sta tmp+1
    lda pstack+2,x
    sta tmp

    stx savex           ; Point X to the return stack temporarily
    tsx
    
    clc                 ; Increment current by n
    lda current
    adc tmp
    sta current
    lda current+1
    adc tmp+1
    sta current+1

    inc savex           ; Remove n from the stack
    inc savex

chk_current:
    lda current+1       ; Is current < limit
    cmp limit+1
    bne chk_ne
    lda current
    cmp limit
chk_ne:
    bcc dobranch        ; Yes: take the branch

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
    jmp next
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
{ ' 1 execute --> 1 }
{ 1 2 ' + execute --> 3 }

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
    
    jmp next
end-code

code forth
    jmp xt_x28vocabularyx29
    .word <>w_cold
end-code
