include" forth_65c02.fth"

\\
\\ Common words
\\

( Define some constants )
8 constant bs     ( Backspace )
13 constant nl     ( Newline character )
32 constant bl     ( Blank character )

( Define the user variables )

0 user s0           ( Initial PSP )
2 user r0           ( Initial RSP )
4 user base         ( Current radix )
6 user state        ( Compiler/Interpreter state )
8 user context      ( Pointer to top wordlist for searching )
10 user current     ( Pointer to the current wordlist for definitions )
12 user dp          ( Pointer to the current compilation point )
14 user >in         ( Pointer to cursor offset into input buffer )
16 user tib         ( Pointer to the cell containing the pointer to the input buffer )
18 user source-id   ( Pointer to the source ID -1 for string, 0 for keyboard, any other number for file )
20 user blk         ( Pointer to the block number )
22 user dpl         ( Pointer to the DPL )
24 user hld         ( Pointer to the HLD variable )
26 user handler     ( Pointer to the HANDLER variable for TRY-CATCH )

( x -- 0 | x x )
: ?dup
    dup if
        dup
    then
;
{ 0 ?dup --> 0 }
{ 1 ?dup --> 1 1 }

( x1 x2 x3 -- x2 x3 x1 )
: rot
    >r
    swap 
    r>
    swap
;
{ 1 2 3 rot --> 2 3 1 }

( x1 x2 -- x1 x2 x1 x2 )
: 2dup
    over
    over
;
{ 1 2 2dup --> 1 2 1 2 }

( x x -- )
: 2drop
    drop
    drop
;
{ 1 2 3 4 2drop --> 1 2 }

\\
\\ Comparison Words
\\

( n1 n2 -- f )
: <
    - 0<
;
{ 1 2 < --> ffffh }
{ 2 1 < --> 0000h }
{ 0 ffffh < --> 0000h }
{ ffffh 0 < --> ffffh }

( n1 n2 -- f )
: >
    - 0>
;
{ 1 2 > --> 0000h }
{ 2 1 > --> ffffh }
{ 0 ffffh > --> ffffh }
{ ffffh 0 > --> 0000h }

( n1 n2 -- f )
: =
    - 0=
;
{ 1 0 = --> 0000h }
{ 1 1 = --> ffffh }
{ ffffh 0 = --> 0000h }
{ ffffh ffffh = --> ffffh }
{ 0 0 = --> ffffh }

( d1 d2 -- f )
: d<
    d- drop 0<
;

\\
\\ Common Math Words
\\

( n1 -- n2 )
: abs
    dup 0< if
        0 swap -
    then
;
{ 1 abs --> 1 }
{ ffffh abs --> 1 }
{ 0 abs --> 0 }

( d1 -- d2 )
: dabs
    over 0< if              ( If d1 is negative... )
        0 0 2swap d-        ( d2 := 0 - d1 )
    then
;
{ 1 2 dabs --> 1 2 }
{ ffffh ffffh dabs --> 0 1 }
{ 0 0 dabs --> 0 0 }

( n1 n2 -- n3 n4 )
: /mod
;

( n1 n2 -- n3 )
: /
    /mod swap drop
;
{ 6 3 / --> 2 }
{ 10 3 / --> 3 }

( n1 n2 -- n3 )
: mod
    /mod drop
;
{ 6 3 mod --> 0 }
{ 10 3 mod --> 1 }

( n1 n2 -- n1|n2 )
: max
    2dup < if
        over drop
    else
        drop
    then
;
{ 1 2 max --> 2 }
{ 3 0 max --> 3 }
{ fffeh ffffh max --> ffffh }

( n1 n2 -- n1|n2 )
: min
    2dup > if
        over drop
    else
        drop
    then
;
{ 1 2 min --> 1 }
{ 3 0 min --> 0 }
{ fffeh ffffh min --> fffeh }

\\
\\ Dictionary words
\\

( pfa -- lfa )
: lfa
    5 -
;

( pfa -- cfa )
: cfa
    3 -
;

( pfa -- nfa )
: nfa
    22 -
;

( nfa -- pfa )
: pfa 
    22 +
;

( -- addr )
: here
    dp @        ( Return the value of the dictionary pointer )
;

( n -- )
: allot
    dp +!       ( Add the amount to the dictionary pointer )
;

( x -- )
: ,
    here !      ( Write the word to the dictionary )
    2 allot     ( Allocate space for it )
;

( c -- )
: c,
    here c!     ( Write the character to the dictionary )
    1 allot     ( Allocate space for it )
;

( -- )
: definitions
    context @
    current !
;

( -- addr )
: latest
    current @ @
;

\\
\\ String Related Words
\\

( c-addr1 -- c-addr2 n )
: count
    dup 1+      ( addr2 := addr1 + 1 )
    swap        ( stack now addr2 addr1 )
    c@          ( stack now addr2 n )
;

( c-addr n -- )
: type
    ?dup if
        ( n is > 0 )
        over +          \ start-addr end-addr 
        swap            \ end-addr start-addr
        do
            i c@        \ get char at current address
            ?dup if     \ If it is non-zero
                emit    \ Print it
            else
                leave   \ Otherwise, quit early
            then
        loop
    else
        ( n == 0 )
        drop            \ if zero, clean c-addr off the stack
    then
;

\\
\\ I/O words
\\

( c-addr -- )
: (.")
    r               ( Get the pointer to the counted string to print )
    count           ( Get the length and address of the string )
    dup 1+          ( Get the offset we need to add to the return point )
    r> + >r         ( And add it to the return point )
    type            ( print the string)
;

( -- )
: space
    32 emit
;

( n -- )
: spaces
    dup 0> if
        0 do
            space
        loop
    else
        drop
    then
;

( addr n -- )
: expect
    over +                      ( addr addr-end )
    over                        ( addr-end addr )
    do
        key                     ( addr c )
        case
            bs of               ( Handle the backspace key )
                dup             ( addr addr )
                i = not if
                    ( If we're not at the start of the string )
                    ( TODO: ring the bell if we are at the start )

                    bs emit     ( Delete the previous character from the screen )
                    bl emit
                    bs emit
                    0 i 1- c!   ( And zero out the current character)
                    i 2- >i
                then
            endof

            nl of               ( Handle the return key )
                0 i c!          ( Write a blank at the end of the line )
                leave           ( Just return to the caller )
            endof

            ( Handle any other keypress )
            dup dup             ( addr c c c )
            i c!                ( addr c c )
            0 i 1+ c!           ( write NUL sentinel after c in buffer )
            emit                ( echo the character )
        end-case
    loop
    drop                        ( drop the starting address )
;

( -- )
: query
    tib @                   ( get address for TIB )
    80 expect               ( Load at most 80 characters into TIB from keyboard )
    0 >in !                 ( Set the IN index to the beginning )
;

( c-addr u -- )
: erase
    ( Write u NULs to c-addr )
    0 fill
;

( c-addr u -- )
: blanks
    ( Write u NULs to c-addr )
    bl fill
;

( c -- )
: word
    ( Read the next word from the input source )
    ( TODO: handle blocks and files )

    tib @                   ( c addr1 )
    >in @ +                 ( c addr2 )
    swap                    ( addr2 c )
    enclose                 ( add2 n1 n2 n3 )
    0 here !
    \ here 32 blanks
    >in +!                  ( addr2 n1 n2 )
    over - >r               ( addr2 n1 : Save n2 - n1)
    r here c!               ( store the character count to the dictionary )
    +                       ( addr3 : Starting address of the word )
    here 1+                 ( addr3 addr4 : Starting address in the dictionary space )
    r>                      ( addr3 addr4 count )
    cmove                   ( copy the word to the dictionary space )
;

( -- pfa b tf | 0 )
: -find
    ( Read a word of input and try to find it in the dictionary )
    bl word
    here
    context @ @
    (find)

    dup 0= if
        drop
        here
        latest
        (find)
    then
;

\\
\\ Number Conversion
\\

( -- )
: decimal
    10 base !
;

( -- )
: hex
    16 base !
;

( -- )
: octal 
    8 base !
;

( d1 addr1 -- d2 addr2 )
: (number)
    begin
        1+ dup >r           ( d1 addr1+1 R: addr1+1 )
        c@                  ( d1 c )
        base @              ( d1 c n )
        digit               ( d1 n2 tf | d1 0)
        
        while
        >r                  ( d1 R: addr1+1 n2 )
        base @ u*           ( d2 )
        r>                  ( d2 n2 R: addr1+1 )
        s>d                 ( d2 d3 )
        d+                  ( d4 )
        r>
    repeat
    r>
;

defer ?error

( addr -- d )
: number
    0 0 rot                 ( d0 addr )
    dup 1+ c@               ( d0 addr c )
    2dh = if                ( is it the minus sign? )
        1 >r                ( save flag )
    else
        0 >r
        1 +                 ( d0 addr+1 )
    then
    
    -1
    begin
        dpl !               ( d0 addr )
        (number)            ( d1 addr2 )
        dup c@              ( d1 addr2 c )
        bl -
    while
        dup c@              ( d1 addr2 c )
        2eh -
        halt
        0 ?error
        0
    repeat
    drop                    ( d1 )
    r>                      ( d1 f )
    if
        0 0 2swap d-        ( d2 )
    then
;

( -- )
: <#
    pad hld !
;

( c -- )
: hold
    -1 hld +!
    hld @ c!
;

( d1 -- d2 )
: #
    base @      ( d1 n )
    um/mod      ( n1 n2 )
    s>d rot     ( d2 n1 )
    9 over < if ( if the remainder < 9 )
        7 +     ( make it alphabetic)
    then
    30h +       ( and make it ASCII)
    hold
;

( d1 -- d2 )
: #s
    begin
        #
        over over
        or 0=
    until
;

( n d -- d )
: sign
    rot 0< if
        2dh hold
    then
;

( d -- addr count )
: #>
    2drop
    hld @
    pad over -
;

( d n -- )
: d.r
    >r              ( Store n to the return stack )
    over swap
    dabs
    <# #s sign #>
    r>
    over - spaces
    type
;

( d -- )
: d.
    0
    d.r
;

( x -- )
: .
    s>d
    d.
;

( n1 n2 -- )
: .r
    >r
    s>d
    r> d.r
;

( addr -- )
: ?
    @ .
;

( addr n -- )
: dump
    0 do
        cr
        dup 0 swap 5 d.r
        3ah emit
        8 0 do
            dup @ 0 swap 5 d.r
            2+
        loop
    8 +loop
    drop
;

\\
\\ Text interpreter
\\

defer interpret

( xt -- exception# | 0 )            \ return addr on stack
: catch 
    sp@ >r              ( xt )      \ save data stack pointer
    handler @ >r        ( xt )      \ and previous handler
    rp@ handler !       ( xt )      \ set current handler
    execute             ( )         \ execute returns if no THROW
    r> handler !        ( )         \ restore previous handler
    r> drop             ( )         \ discard saved stack ptr
    0                   ( 0 )       \ normal completion
;

( ??? exception# -- ??? exception# )
: throw 
    ?dup if                 ( exc# )    \ 0 THROW is no-op
        handler @ rp!       ( exc# )    \ restore prev return stack
        r> handler !        ( exc# )    \ restore prev handler
        r> swap >r          ( sp )      \ exc# on return stack
        sp! drop r>         ( exc# )    \ restore stack
                                        \ Return to the caller of CATCH because return
                                        \ stack is restored to the state that existed
                                        \ when CATCH began execution
    then
;

( -- )
: quit
    hex
    forth definitions
    0 state !
    begin
        cr
        state @ 0= if
            ." ok" 
            cr
        then
        query
        cr
        interpret
    again
;

( n -- )
: error
    dup 0= not if
        here count type
        c" ? MSG#" count type .
    then
    quit
;

( f n -- )
: ?error
    swap if
        error
    else
        drop
    then
;

( -- )
: interpret
    begin
    tib @ >in @ + c@ while  ( Repeat while the TIB has characters )
        -find               ( Try to look up the word )
        if
            ( Word found... either run it or compile it )
            state @ < if
                cfa ,       ( COMPILE & not IMMEDIATE... compile the word )
            else
                cfa execute ( Otherwise, execute the word )
            then
        else
            cr ." not found:" space here count type cr
            ( Not found: maybe it's a number... )
            here number     ( Try to parse it as a number )
            swap drop       ( TODO: handle doubles )
            \\ state @ if
                ( Compiling... compile the number )
                ( Otherwise, leave the number on the stack )
            \\    postpone (literal) ,
            \\    halt
            \\ then
            halt
        then
    repeat
;

\\
\\ Boot strapping word...
\\

include" f256jr.fth"

: cold
    forth definitions
    s0 @ sp!                ( Set the parameter stack pointer to the initial value )
    r0 @ rp!                ( Set the return stack pointer )
    0 blk !                 ( Initialize the block number to 0 )
    5000h dp !              ( Initialize the dictionary pointer )
    BF00h tib !             ( Initialize the TIB )

    ." Welcome to MetaForth v00.00.00" cr

    \\ unittest
    \\ ." All unit tests PASSED!" cr

    quit
;
