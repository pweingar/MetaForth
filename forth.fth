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

( x -- 0 | x x )
: ?dup
    dup if
        dup
    then
;
{ 0 ?dup --> 0 }
{ 1 ?dup --> 1 1 }

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

\\
\\ Common Math Words
\\

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

( n1 -- n2 )
: abs
    dup 0< if
        0 swap -
    then
;

( n1 n2 -- n1|n2 )
: max
    over over < if
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
    over over > if
        over drop
    else
        drop
    then
;
{ 1 2 min --> 1 }
{ 3 0 min --> 0 }
{ fffeh ffffh min --> fffeh }

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

( -- )
: space
    32 emit
;

( n -- )
: spaces
    0 do
        space
    loop
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
    \here 32 blanks
    >in +!                  ( addr2 n1 n2 )
    over - >r               ( addr2 n1 : Save n2 - n1)
    r here c!               ( store the character count to the dictionary )
    +                       ( addr3 : Starting address of the word )
    here 1+                 ( addr3 addr4 : Starting address in the dictionary space )
    r>                      ( addr3 addr4 count )
    cmove                   ( copy the word to the dictionary space )
;

\\
\\ Input Routines
\\

\\
\\ Boot strapping word...
\\

include" f256jr.fth"

: cold
    0 blk !                 ( Initialize the block number to 0 )
    4000h dp !              ( Initialize the dictionary pointer )
    BF00h tib !             ( Initialize the TIB )

    c" Welcome to MetaForth v00.00.00" count type cr

    \\ query cr cr
    \\ c" You typed" count type
    \\ bl emit AEh emit
    \\ tib @ 80 type
    \\ AFh emit

    c" ok" count type cr
    query
    bl word cr
    c" You entered: " count type
    here count type

\\    unittest
\\    c" All unit tests PASSED!" count type cr
;
