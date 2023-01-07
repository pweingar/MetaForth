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

: maze
    ( Draw a random maze to fill the screen )
    
    initrandom
    begin
        random 1 and CDh + emit
    again
;
