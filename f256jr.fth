\\
\\ Words to support the F256jr
\\

\\
\\ I/O Page #0 addresses
\\

d000h constant vky.mcr
01h constant vky.mcr.text
02h constant vky.mcr.overlay
04h constant vky.mcr.graphics
08h constant vky.mcr.bitmap
10h constant vky.mcr.tile
20h constant vky.mcr.sprite
40h constant vky.mcr.gamma

d001h constant vky.mcr2
01h constant vky.mcr2.clk70
02h constant vky.mcr2.dbl_x
04h constant vky.mcr2.dbl_y
08h constant vky.mcr2.sleep
10h constant vky.mcr2.font_overlay
20h constant vky.mcr2.font_set

d002h constant vky.layers

d100h constant vky.bm0.ctrl
d101h constant vky.bm0.address
d108h constant vky.bm1.ctrl
d109h constant vky.bm1.address
d110h constant vky.bm2.ctrl
d111h constant vky.bm2.address

\\
\\ I/O Page #1 addresses
\\

d000h constant vky.graphics.clut.0
d400h constant vky.graphics.clut.1
d800h constant vky.graphics.clut.2
dc00h constant vky.graphics.clut.3

\\
\\ Random Number Generator
\\

d6a4h constant rnd.value
d6a6h constant rnd.ctrl

( -- )
: initrandom
    ( initialize the random number generator )
    1 rnd.ctrl c!			( Turn on the random number generator )
;

( -- n )
: random                    ( Return a random, 16-bit number )
    rnd.value @
;

\\
\\ MMU Words
\\

0001h constant io-page      ( The address of the mmu-io-page register )

( -- )
: set-io-text
    ( Set the I/O page to the text matrix )
    2 io-page c!
;

( -- )
: set-io-color
    ( Set the I/O page to the color matrix )
    3 io-page c!
;

code mmu.init
	; Initialize the MMU for MetaForth
	; Mainly, we want to turn on MLUT editing for the current MLUT

	lda $0000		; Get the value of the main MMU register
	and #$03		; Mask out everything but the currently active MLUT number
	sta tmp			; Save it for later use

	asl a			; Shift the active MLUT to the edit MLUT position
	asl a
	asl a
	asl a

	ora tmp			; Merge back in the active MLUT number

	ora #$80		; Turn on the EDIT bit

	sta $0000		; Set the value of the main MMU register

	jmp xt_next
end-code

( d -- offset page )
code mmu.page.offset
	; Compute the MMU page number and offset for a 20-bit address

	lda pstack+4,x		; Get the bits for the MMU page number
	and #$1f
	sta tmp+1
	lda pstack+3,x
	and #$e0
	sta tmp

	lda pstack+2,x		; Filter out the addr bits (offset within the MMU page) 
	sta pstack+4,x
	lda pstack+3,x
	and #$1f
	sta pstack+5,x

	asl tmp				; Shift three times to get the MMU page number
	rol tmp+1
	asl tmp
	rol tmp+1
	asl tmp
	rol tmp+1

	lda tmp+1			; Store the MMU page number to the stack
	sta pstack+2,x
	lda #0
	sta pstack+3,x

	jmp xt_next
end-code

12 constant mmu.winreg			\ Address of the MLUT register for the MMU window
8000h constant mmu.winadr		\ Address of the MMU window

( c d -- )
code far.c!
	lda pstack+2,x				; Get the far address
	sta fptr
	lda pstack+3,x
	sta fptr+1
	lda pstack+4,x
	sta fptr+2

	jsr bank_offset				; And set the window to the appropriate spot

	lda pstack+6,x				; Get the value to write
	sta (tmp)					; And write it

	lda tmp+3					; Get the original MMU window setting
	sta 12						; And restore it

	txa							; Clean up the stack
	clc
	adc #6
	tax

	jmp xt_next
end-code

\: far.c!
\	( Write a byte value into system RAM on the F256 )
\	mmu.winreg c@ >r			\ Save the current MMU window
\	mmu.page.offset				\ Calculate the new window setting and offset
\	mmu.winreg c!				\ Set the new MMU window
\	mmu.winadr + c!				\ Store the value into the correct location in the window
\	r> mmu.winreg c!			\ Restore the MMU window
\;

( d -- c )
code far.c@
	lda pstack+2,x				; Get the far address
	sta fptr
	lda pstack+3,x
	sta fptr+1
	lda pstack+4,x
	sta fptr+2

	jsr bank_offset				; And set the window to the appropriate spot

	lda (tmp)					; Read the value

	sta pstack+4,x				; And save it to the stack
	stz pstack+5,x

	lda tmp+3					; Get the original MMU window setting
	sta 12						; And restore it

	inx							; Clean up the stack
	inx

	jmp xt_next
end-code

\: far.c@
\	( Read a byte value into system RAM on the F256 )
\	mmu.winreg c@ >r			\ Save the current MMU window
\	mmu.page.offset				\ Calculate the new window setting and offset
\	mmu.winreg c!				\ Set the new MMU window
\	mmu.winadr + c@				\ Store the value into the correct location in the window
\	r> mmu.winreg c!			\ Restore the MMU window
\;

( d addr -- )
: l!
	( Write a 24-bit value to a 16-bit address )
	dup r>
	!
	r>
	2 + c!
;

\\
\\ DMA
\\

df00h constant dma.ctrl
df01h constant dma.datastat
df04h constant dma.src
df08h constant dma.dst
df0ch constant dma.count

( c daddr dn -- )
: dma.fill
	( Use the DMA engine to fill the dn bytes of memory at the 24-bit address daddr with the byte c )
	io-page c@ >r       ( Save the current I/O page )

	0 io-page c!		( Switch to the I/O registers )

	05h dma.ctrl c!		( Set up the DMA engine for 1D fill )

	dma.count !			( Set the count of bytes to write )
	dma.count 2 + c!

	dma.dst !			( Set the destination address )
	dma.dst 2 + c!

	dma.datastat c!		( Set the data to write )

	85h dma.ctrl c!		( Trigger the transfer )

	begin
		( Wait for BUSY bit to go to 0 )
		dma.datastat c@ 80h and 0=
	until

    r> io-page c!       ( Restore the current I/O page )
;

( r g b n -- )
: def-text-fg-color
    ( Set the components of text foreground color n to <r, g, b> )
    0fh and             ( Make sure the color number is 0 - 15 )
    io-page c@ >r       ( Save the current I/O page )
    0 io-page c!        ( Go to I/O page 0)
    4 * d800h +         ( Compute base address )
    dup 3 + swap do
        i c!            ( Set each color component )
    loop
    r> io-page c!       ( Restore the current I/O page )
;

( r g b n -- )
: def-text-bg-color
    ( Set the components of text foreground color n to <r, g, b> )
    0fh and             ( Make sure the color number is 0 - 15 )
    io-page c@ >r       ( Save the current I/O page )
    0 io-page c!        ( Go to I/O page 0)
    4 * d840h +         ( Compute base address )
    dup 3 + swap do
        i c!            ( Set each color component )
    loop
    r> io-page c!       ( Restore the current I/O page )
;

( r g b -- )
: set-border-color
    ( Set the color of the border )
    io-page c@ >r       ( Save the current I/O page )
    0 io-page c!        ( Go to I/O page 0)
    d005h c!            ( Set the blue component )
    d006h c!            ( Set the green component )
    d007h c!            ( Set the red component )
    r> io-page c!       ( Restore the current I/O page )
;

( w h -- )
: set-border-size
    ( Set the color of the border )
    io-page c@ >r                   ( Save the current I/O page )
    0 io-page c!                    ( Go to I/O page 0)

    over over or if
        1fh and d009h c!            ( Set the height )
        1fh and d008h c!            ( Set the width )
        d004h c@ 01h or d004h c!    ( Turn on the border )
    else
        d004h c@ feh and d004h c!   ( Turn off the border )
        2drop                       ( Drop size from stack )
    then

    r> io-page c!                   ( Restore the current I/O page )
;

( -- )
: f256.bitmap
	( Turn on the bitmap )
	io-page c@ >r
	0 io-page c!

	vky.mcr.graphics vky.mcr.bitmap or
	vky.mcr.text or
	vky.mcr.overlay or
	vky.mcr c!

	0210h vky.layers !			\ Set the layers

	1 vky.bm0.ctrl c!			\ Turn on bitmap #0, set clut to #0
	0 vky.bm0.address !			\ Set address to $100000
	1 vky.bm0.address 2 + c!
	
	r> io-page c!
;

: f256.text
	( Switch to text mode )
	io-page c@ >r
	0 io-page c!

	vky.mcr.text vky.mcr c!
	
	r> io-page c!
;

ffh variable f256.pen				\ Variable for the current graphics pen color

( r g b pen -- )
: f256.setcolor
	( Set the color for a given pen )
	io-page c@ >r
	1 io-page c!

	4 * vky.graphics.clut.0 +	\ Compute the base address
	dup
	3 +							\ Compute address of last color
	swap do
		i c!
	loop

	r> io-page c!
;

0 variable plot.x
0 variable plot.y

( x y -- )
: f256.plot
	( Set the color of the pixel at x,y to that of the current pen )

	plot.y !				\ Save Y
	plot.x !				\ Save X

	f256.pen c@				\ Get the current pen color

	plot.y @ 320 m*			\ Multiply y by 320 to get a double...
	0 plot.x @ 				\ Convert x to double
	d+						\ And add together
	01h 0000h d+			\ Add the bitmap base address

	far.c!					\ Set the pixel color
;

0 variable x0
0 variable y0
0 variable x1
0 variable y1
0 variable dx
0 variable dy
0 variable sx
0 variable sy
0 variable err
0 variable e2

: f256.line ( x0 y0 x1 y1 -- )
    ( copy arguments )
        y1 !
		x1 !
		y0 !
		x0 !
    
    ( compute constants )    
        x1 @ x0 @ - abs dx !
        y1 @ y0 @ - abs negate dy !
        x0 @ x1 @ < if 1 else -1 then sx !
        y0 @ y1 @ < if 1 else -1 then sy !
        dx @ dy @ + err !
        
    ( plot the points )
        begin
            x0 @ y0 @ f256.plot

            x0 @ x1 @ <> while
            y0 @ y1 @ <> while

            err @ dup + e2 !
            e2 @ dy @ >= if
                dy @ err +!
                sx @ x0 +!
            then
            e2 @ dy @ <= if
                dx @ err +!
                sy @ y0 +!
            then
         repeat
     ;

: hgr.clrcol
	100 0 do
		dup i f256.plot
	loop
	drop
;

( -- n )
: rand320
	( Return a random number from 0 to 319 )
	random 1ffh and
	dup 319 > if
		drop
		319
	then
;

( -- n )
: rand240
	( Return a random number from 0 to 239 )
	random ffh and
	dup 239 > if
		drop
		239
	then
;

: randlines
	mmu.init
	initrandom						( Set up the randome number generator )
	f256.bitmap						( Turn on the bitmap )
	0 01h 0000h 01h 2c00h dma.fill	( Clear the bitmap )
	100 0 do
		random 255 and f256.pen !
		rand320 rand240 rand320 rand240 f256.line
	loop
;

: hgr.test
	f256.bitmap
	255 255 255 1 f256.setcolor

	1 f256.pen !
	0 0 100 100 f256.line
;

\
\ Low level routines to call into the kernel
\

0 constant file.open.read
1 constant file.open.write
2 constant file.open.append

0 constant r/o
1 constant w/o
2 constant r/w

( mode drvnum c-addr n -- fd 1 | error 0 )
code file.open
			; Set the length of the path
			lda pstack+2,x
			sta kernel.args.file.open.fname_len

			; Set the path
			lda pstack+4,x
			sta kernel.args.file.open.fname+0
			lda pstack+5,x
			sta kernel.args.file.open.fname+1

			; Set the drive number
			lda pstack+6,x
			sta kernel.args.file.open.drive

			; Set the mode
			lda pstack+8,x
			sta kernel.args.file.open.mode

			; Adjust the stack for the return values
			inx
			inx
			inx
			inx

			; Try to open the file
			jsr kernel.File.Open

loop:		jsr kernel.Yield
            jsr kernel.NextEvent
            bcs loop

			lda event.type
            cmp #kernel.event.file.OPENED
            beq is_open
            cmp #kernel.event.file.ERROR
            beq is_error

			bra loop

is_error:	stz pstack+2,x				; Return 0 for the status flag
			stz pstack+3,x

			stz pstack+4,x				; And 0 for the stream/error... TODO:; return a proper error code
			stz pstack+5,x
			jmp xt_next

is_open:	lda #1						; Return 1 for the status flag
			sta pstack+2,x
			stz pstack+3,x

			lda event.file.stream		; and the stream number
			sta pstack+4,x
			stz pstack+5,x
			jmp xt_next
end-code

( fd -- )
code file.close
			; Check to make sure we have a real stream
			lda pstack+2,x
			beq done

			; Close the file
			sta kernel.args.file.close.stream
			jsr kernel.File.Close

done:
			jmp xt_next
end-code

( fd buf_addr buf_size -- bytes_read )
code file.read
			; Set the stream ID
			lda pstack+6,x
			sta kernel.args.file.read.stream

			; Set the number of bytes to read
			lda pstack+2,x
			sta kernel.args.file.read.buflen

			jsr kernel.File.Read
			bcs error

			;
			; Wait for data to come back
			;

wait:		jsr kernel.Yield
			jsr kernel.NextEvent
			bcs wait

			lda event.type
			cmp #kernel.event.file.DATA
			beq data
			cmp #kernel.event.file.ERROR
			beq error
			cmp #kernel.event.file.EOF
			beq error

			bra wait

data:		; Set the number of bytes to copy
			lda event.file.data.read
			sta kernel.args.recv.buflen

			; Set the pointer to the buffer
			lda pstack+4,x
            sta kernel.args.recv.buf+0
            lda pstack+5,x
            sta kernel.args.recv.buf+1

            jsr  kernel.ReadData

done:		lda event.file.data.read	; Return the number of bytes read

			; Adjust the stack for the return value
			inx
			inx
			inx
			inx

			sta pstack+2,x
			stz pstack+3,x
			jmp xt_next

error:		
			; Adjust the stack for the return value
			inx
			inx
			inx
			inx
			
			stz pstack+2,x				; Return 0 for EOF or error
			stz pstack+3,x
			jmp xt_next
end-code

( fd addr n1 -- n2 )
\ code file.write
\ end-code

( addr1 n1 -- drvnum addr2 n2 )
: file.parse.path
  >r                            ( Save n1 )
  >r				( Save the address )

  30h r c@ 34h
  between			( First character is a drive number? )
  
  r dup 1 + c@			( Get the second character)
  [char] :
  =				( And... second character is a colon ?)

  and if
    ( Path matches the regular expression ^[0-4]\: )
    r c@ [char] 0 -		( Convert the first character to a number )
    r> 2 +			( Adjust the address to point right after the colon )
    r> 2 -			( Recover the size and subtract the size of the drive spec )
  else
    ( Path does NOT match the regular expression ^[0-4]\: should be taken as-is )
    0				( Select #0 as the drive )
    r>				( Recover the original address )
    r>				( Recover the length of the path and leave as-is )
  then
;

\
\ Forth Standard routines
\

( c-addr u fam -- fileid ior )
: open-file
  rot rot file.parse.path file.open
  if
    ( If ok, then return file-id and 0 )
    0
  else
    ( If error, return 0 and error number )
    0 swap
  then
;

( fd -- ior )
: close-file
  file.close 0
;

( c-addr u1 fileid -- u2 ior )
: read-file
  rot rot file.read dup 0 > if
    0
  else
    1
  then
;

