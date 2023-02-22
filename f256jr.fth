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

: maze
    ( Draw a random maze to fill the screen )
    
    initrandom
    begin
        random 1 and CDh + emit
    again
;
