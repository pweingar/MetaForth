\\
\\ Words to support the F256jr
\\

( -- )
: initrandom
    ( initialize the random number generator )
    1 d6a6h c!              ( Turn on the random number generator )
;

( -- n )
: random                    ( Return a random, 16-bit number )
    d6a4h @
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

\
\ Low level routines to call into the kernel
\

0 constant file.open.read
1 constant file.open.write
2 constant file.open.append

0 constant r/o
1 constant w/o
2 constnat r/w

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

