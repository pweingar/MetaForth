( IIRC, some FORTHs expect an initializer after the name )
0 variable x0
0 variable y0
0 variable x1
0 variable y1
0 variable dx
0 variable dy
0 variable sx
0 variable sy
0 variable error
0 variable e2

: f256.line ( x0 y0 x1 y1 c -- )

    ( copy arguments )
        f256.pen !
        y1 !
		x1 !
		y0 !
		x0 !
    
    ( compute constants )    
        x1 @ x0 @ - abs dx !
        y1 @ y0 @ - abs negate dy !
        x0 @ x1 @ < if 1 else -1 then sx !
        y0 @ y1 @ < if 1 else -1 then sy !
        dx @ dy @ + error !
        
    ( plot the points )
        \ begin
            x0 @ y0 @ f256.plot
            x0 @ x1 @ <> while
            y0 @ y1 @ <> while
            error @ dup + e2 !
        /     e2 @ dy @ >= if
        /         \ x0 @ x1 @ <> while
        /         error dy @ +!
        /         x0 sx @ +!
        /     then
        /     e2 @ dy @ <= if
        /         \ y0 @ y1 @ <> while
        /         error dx @ +!
        /         y0 sy @ +!
        /     then
        /  repeat
     ;