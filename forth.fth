include" forth_65c02.fth"

\\
\\ Common words
\\

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
    over +          ( addr addr-end )
    swap            ( addr-end addr )
    do
        key         ( addr c )
        case
            8 of        ( Handle the backspace key )
            endof

            13 of       ( Handle the return key )
                leave
            endof

            ( Handle any other keypress )
            dup             ( addr c c )
            i c!            ( addr c )
            0 i 1+ c!       ( write NUL sentinel after c in buffer )
            emit            ( echo the character )
        end-case
    loop
;

\\
\\ Input Routines
\\

\\
\\ Boot strapping word...
\\

include" f256jr.fth"

: cold
    c" Welcome to MetaForth v00.00.00" count type cr

    5000h 80 expect cr
    c" typed..." count type cr
    5000h 80 type

\\    unittest
\\    c" All unit tests PASSED!" count type cr
;
