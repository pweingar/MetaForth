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
28 user csp         ( Pointer to a save location for the return stack pointer )

( -- addr )
: pad
    ( Return the address of the temporary string buffer )
    dp @ 0100h +
;

( -- )
: [
    ( Switch state to EXECUTE )
    0 state !
; immediate

( -- )
: ]
    ( Switch state to COMPILE )
    c0h state !
; immediate

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
    23 -
;

( nfa -- pfa )
: pfa
    23 +
;

( n1 -- n2 )
: nfa>cfa
    ( Convert the NFA to the CFA )
    19 +
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
    ( Code behind ." )
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
    >in +!                  ( addr2 n1 n2 )
    over - >r               ( addr2 n1 : Save n2 - n1)
    r here c!               ( store the character count to the dictionary )
    +                       ( addr3 : Starting address of the word )
    here 1+                 ( addr3 addr4 : Starting address in the dictionary space )
    r>                      ( addr3 addr4 count )
    cmove                   ( copy the word to the dictionary space )

    bl here count + c!      ( Terminate word with a blank )
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
        dup >r              ( d1 addr1 R: addr1 )
        c@                  ( d1 c )
        base @              ( d1 c n )
        digit               ( d1 n2 tf | d1 0)
    while
        >r                  ( d1 R: addr1 n2 )
        base @ u*           ( d2 R: addr1 n2 )
        r>                  ( d2 n2 R: addr1 )
        s>d                 ( d2 d3 R: addr1 )
        d+                  ( d4 R: addr1 )
        r>                  ( d4 addr1 )
        1+
    repeat
    r>
;

( addr -- d )
: number
    0 0 rot                 ( d0 addr )
    dup c@                  ( d0 addr c )
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
        dup c@              ( d2 addr2 c )
        bl -
    while
        dup c@              ( d2 addr2 c )
        2eh
         - if
            fff3h ?error    ( -13 is undefined word error )
        then
        0
    repeat
    drop                    ( d2 )
    r>                      ( d2 f )
    if
        0 0 2swap d-        ( d3 )
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

( n1 n2 n3 -- f )
: between
    ( Return true if n2 <= n1 <= n3 )
    >r                  ( Save n3 )
    over >r             ( Save a copy of n1 )
    < if
        ( Is n1 < n2 )
        r> drop         ( Drop copy of n1 )
        r> drop         ( Drop n3 )
        0               ( Return false )
    else
        r> r>
        ( Return true if n3 >= n1? )
        > not
    then
;

( c -- f )
: isprint
    ( Return true if character is printable )
    dup
    20h 7eh between if
        ( Return true if character betwen 0x20 and 0x7e )
        drop
        ffffh
    else
        ( Return true if character betwen 0xA0 and 0xFF )
        a0h ffh between
    then
;

( c -- )
: cprint
    ( Print a byte... replace non-printable characters with a dot )
    dup isprint if
        emit
    else
        drop
        [char] . emit
    then
;

( addr n -- )
: cdump
    over +                                      ( addr addr+n )
    over do                                     ( addr addr+n addr )
        cr                                      ( addr )
        i s>d 5 d.r
        [char] : emit space

        i                                       ( addr addr1 )
        8 0 do
            dup                                 ( addr addr1 addr1 )
            i +                                 ( addr addr1 addr2 )
            c@ s>d 2 d.r 20h emit
        loop

        2 spaces

        8 0 do
            dup i + c@ cprint
        loop

        drop                                    ( addr )
    8 +loop
    drop
;

\\ More I/O

: ."
    ( Print a string ." )
    postpone (.")       ( Compile call to print string utility for ." )
    22h word            ( Grab the input up to the double quote )
    here c@             ( Get the size of the string input )
    1+ allot            ( Allocate room for it and the size byte )
; immediate

\\
\\ Text interpreter
\\

: (
    ( Process a comment )
    [char] ) word
; immediate

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
    forth definitions
    0 state !
    begin
        cr
        state @ 0= if
            cr [char] > emit bl emit
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
        ." ? MSG#" .
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
: ?csp
    ( Trigger an error if the PSP is not pointing to the place indicated by CSP )
    csp @ sp@ - if
        0 25 - error
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
            ( Not found: maybe it's a number... )
            here number     ( Try to parse it as a number )
            swap drop       ( TODO: handle doubles )
            state @ if
                ( Compiling... compile the number )
                ( Otherwise, leave the number on the stack )
                postpone (literal) ,
            then
        then
    repeat
;

\\
\\ Control Flow
\\

( n -- )
: ?control
    ( Validate that N is the top of the return stack )
    - 0 22 - ?error
;

( -- )
: begin
    ( Start a loop... end with again or repeat )
    
    here                ( Save the location of the loop return point )
    1                   ( Push 1 as a marker for BEGIN )
; immediate

( -- )
: again
    ( Jump back to the begin point )

    1 ?control          ( Validate we're in a BEGIN loop )
    postpone (branch)   ( Compile BRANCH into the current word )
    ,                   ( Pull the address of the BEGIN and compile it for BRANCH )
; immediate

( -- )
: until
    ( Check TOS, if 0, branch back to the BEGIN )

    1 ?control          ( Validate we're in a BEGIN loop )
    postpone (branch0)  ( Compile BRANCH0 into the current word )
    ,                   ( Pull the address of the BEGIN and compile it for BRANCH )
; immediate

( f -- )
: if
    ( Start a basic conditional )

    postpone (branch0)  ( Compile BRANCH0 to the word )
    here                ( Save the location of the jump address )
    0 ,                 ( Compile a dummy jump address )
    2                   ( Save the indicator for an IF/ELSE )
; immediate

( -- )
: else
    ( Start the false condition block )

    2 ?control          ( Validate that we are in an IF/ELSE )
    postpone (branch)   ( Compile the branch to go to the end of the IF... ELSE... THEN )
    here swap
    0 ,                 ( Compile a dummy jump address )
    here swap !         ( Update the IF jump address to here )
    2                   ( Save the indicator for an IF/ELSE )
; immediate

( -- )
: then
    ( Close out an IF... ELSE... THEN clause )

    2 ?control          ( Validate that we are in an IF/ELSE )
    here swap !         ( Update the IF jump address to here )
; immediate

\\
\\ Defining words
\\

( -- )
: create
    ( Read the next word and add it )
    here                    ( Save start of new word )
    bl word                 ( Find the word )
    11h allot               ( Allocate enough room for the dictionary entry )
    latest ,                ( Link to the previous LATEST )
    current @ !             ( Make this word the new latest word in the dictionary )
    jump-instruction c,
    postpone enter
;

( -- )
: :
    ( Define a word... )
    current @ context !         ( Make the definition context the same as the current search list )
    create                      ( Define the word in the dictionary )
    ]                           ( Switch to COMPILE mode )
;

( -- )
: (;code)
    ( Execution phase of ;code )
    latest nfa>cfa dup          ( Get the CFA of the word being defined )
    jump-instruction swap c!    ( Start the CFA field )
    1+ r> swap !                ( Store the address of the machine language in the CFA )
;

( -- )
: ;code
    ( Enter assembly code mode )
    postpone (;code)            ( Compile the code to set the CFA )
    [                           ( Drop out of COMPILE mode )
; immediate

( -- )
: does>
    ( Start high level definition of execution phase of word )
    postpone (;code)            ( Switch to machine code )
    call-instruction c,
    postpone dodoes             ( Compile a call to DODOES )
; immediate 

( -- )
: ;
    ( Close a colon or DOES> defined word )
    postpone exit               ( Compile EXIT )
    [                           ( Switch to EXECUTE mode )
; immediate

( -- )
: end-code
    ( Close out a CODE word definition )
    jump-instruction c,
    postpone next               ( Compile a JMP NEXT )
;

: greeting
    ." hello" cr
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
    0800h dp !              ( Initialize the dictionary pointer )
    decimal

    ." Welcome to MetaForth v00.00.00" cr

 	unittest
    ." All unit tests PASSED!" cr

    quit
;
