;;;
;;; I/O library to interface to the microkernel
;;;

.include "io_f256.asm"              ; Define the I/O registers
.include "api.asm"                  ; API for the MicroKernel

CHAR_BS = 8                         ; Backspace
CHAR_FF = 12                        ; Form feed character
CHAR_NL = 13                        ; Newline character

DEF_COLOR = $f4                     ; Default color

;
; Define zero page variables
; 
.section zp
cur_line    .word ?                 ; Address of the current line on the text screen
src_ptr     .word ?                 ; General pointer for the source of something in memory
dst_ptr     .word ?                 ; General pointer for the destination of something in memory
.send

;
; Define non-zero page variables
;
.section variables
event       .dstruct kernel.event.event_t
curs_color  .byte ?                 ; Current color for printing
curs_x      .byte ?                 ; Current column for the text cursor
curs_y      .byte ?                 ; Current row for the text cursor
old_y       .byte ?                 ; Previous cursor row
curs_width  .byte ?                 ; Width of the screen in text columns
curs_height .byte ?                 ; Height of the screen in text columns
.send

;
; The main BIOS code
;
.section code

;
; Initialize the I/O variables and systems
;
ioinit:     
            ; ldx #$ff                        ; Initialize the stack
            ; txs
            
            lda #<event                     ; Point to our event record
		    sta kernel.args.events+0
		    lda #>event
		    sta kernel.args.events+1 

            jsr initlut                     ; Initialize the CLUT

            lda #DEF_COLOR                  ; Set the default color (will be defined with the LUT)
            sta curs_color

            lda #$ff                        ; Set old_y to something silly
            sta old_y

            lda #80
            sta curs_width
            lda #60
            sta curs_height

            jsr consclr                     ; Clear the text screen and home the cursor
            rts


;
; Initialize the text color lookup tables
;
initlut:    .proc
            pha
            phy

            lda MMU_IO_CTRL             ; Save the current I/O page
            pha

            lda #MMU_IO_PAGE_0          ; Make sure we're on I/O page #0
            sta MMU_IO_CTRL

            ldy #0
loop:       lda text_lut,y              ; Get a color component
            sta VKY_TEXT_FG_LUT,y       ; Write it to the text foreground CLUT
            sta VKY_TEXT_BG_LUT,y       ; And then to the text background CLUT
            iny
            cpy #4*16                   ; Have we copied all 16 colors (4 components)
            bne loop                    ; No: copy the next one

            pla
            sta MMU_IO_CTRL             ; Restore the current I/O page

            ply
            pla
            rts
            .pend

            ; BB GG RR AA
text_lut:   .byte $00, $00, $00, $00    ; Black
            .byte $00, $00, $80, $00    ; Red
            .byte $00, $80, $00, $00    ; Green
            .byte $00, $80, $80, $00    ; Yellow
            .byte $80, $00, $00, $00    ; Blue
            .byte $80, $00, $80, $00    ; Magenta
            .byte $80, $80, $00, $00    ; Cyan
            .byte $8c, $8c, $8c, $00    ; White
            
            .byte $80, $80, $80, $00    ; Bright Black
            .byte $00, $00, $ff, $00    ; Bright Red
            .byte $00, $ff, $00, $00    ; Bright Green
            .byte $00, $ff, $ff, $00    ; Bright Yellow
            .byte $ff, $00, $00, $00    ; Bright Blue
            .byte $ff, $00, $ff, $00    ; Bright Magenta
            .byte $ff, $ff, $00, $00    ; Bright Cyan
            .byte $ff, $ff, $ff, $00    ; Bright White

;
; Return the status of the console
;
constat:    .proc
            lda #0
            rts
            .pend

;
; Wait for a keypress and return the ASCII value in A
;
conin:      .proc
            jsr kernel.NextEvent            ; Grab the event
            bcs conin

            lda event.type                  ; Check the event type
            cmp #kernel.event.key.PRESSED
            bne conin

            lda event.key.ascii             ; Get the ASCII code of the key pressed

            rts
            .pend

;
; Clear the console screen and home the cursor
;
consclr:    .proc
            pha
            phx

            lda #<VKY_TEXT_MATRIX   ; Move the current line to the first line
            sta cur_line
            lda #>VKY_TEXT_MATRIX
            sta cur_line+1

            ldy #0
loop:       jsr clrline             ; Clear the current line
            iny                     ; Move to the next line
            cpy curs_height
            beq home                ; If we've done the last line, home the cursor

            clc                     ; Advance cur_line to the next line in the matrix
            lda cur_line
            adc curs_width
            sta cur_line
            lda cur_line+1
            adc #0
            sta cur_line+1

            bra loop                ; And go back to clear it too

home:       stz curs_x              ; Set the cursor to (0, 0)
            stz curs_y
            jsr cursset

            plx
            pla
            rts
            .pend

;
; Set the cursor position to (curs_x, curs_y)
;
cursset:    .proc
            pha
            phy

            ; Make sure the column is visible

            lda curs_x              ; Where is the cursor column pointing
            cmp curs_width
            blt chk_row             ; If on screen, let's check the row

            stz curs_x              ; If not on screen, move it to the left and down
            inc curs_y

chk_row:    ; Make sure the row is visible

            lda curs_y              ; Where is the cursor row pointing
            cmp curs_height
            blt set_hw              ; If on screen, set the hardware registers

            lda curs_height         ; Otherwise: Move the last visible row
            dec a
            sta curs_y

            jsr consscroll          ; And we need to scroll the screen

set_hw:     lda curs_x              ; Set the hardware cursor column
            sta VKY_CURS_X
            stz VKY_CURS_X+1

            lda curs_y              ; Set the hardware cursor row
            sta VKY_CURS_Y
            stz VKY_CURS_Y+1

            lda old_y               ; Is old_y == curs_y
            cmp curs_y
            beq done                ; Yes: we are done

            ; No: we need to recalculate cur_line

            lda #<VKY_TEXT_MATRIX   ; Start on the first line
            sta cur_line
            lda #>VKY_TEXT_MATRIX
            sta cur_line+1

            ldy curs_y              ; Get the desired row
            sty old_y               ; And mark that it will be our old row from now on
            beq done                ; If it's zero, we are done

loop:       clc                     ; Move cur_line to the next line
            lda cur_line
            adc curs_width
            sta cur_line
            lda cur_line+1
            adc #0
            sta cur_line+1

            dey                     ; Decrement line counter
            bne loop                ; If not zero, keep moving down a line

done:       ply
            pla
            rts
            .pend

;
; Scroll the screen up by one row
;
consscroll: .proc
            pha
            phx

            lda cur_line+1          ; Save the current line
            pha
            lda cur_line
            pha

            lda MMU_IO_CTRL         ; Save the current I/O page
            pha

            lda #<VKY_TEXT_MATRIX   ; Destination pointer is the first line
            sta dst_ptr
            lda #>VKY_TEXT_MATRIX
            sta dst_ptr+1

            clc                     ; src_ptr is the second line
            lda dst_ptr
            adc curs_width
            sta src_ptr
            lda dst_ptr+1
            adc #0
            sta src_ptr+1

            ldx #1                  ; X will be our source row number

copy_text:  lda #MMU_IO_PAGE_TEXT   ; Move to the text page
            sta MMU_IO_CTRL

            ldy #0                  ; Copy a text line from src to dst
loop1:      lda (src_ptr),y
            sta (dst_ptr),y
            iny
            cpy curs_width
            bne loop1    

            lda #MMU_IO_PAGE_COLOR  ; Move to the text color page
            sta MMU_IO_CTRL   

            ldy #0                  ; Copy a color line from src to dst
loop2:      lda (src_ptr),y
            sta (dst_ptr),y
            iny
            cpy curs_width
            bne loop2

            lda src_ptr             ; Move dst_ptr to the next line
            sta dst_ptr
            lda src_ptr+1
            sta dst_ptr+1

            clc                     ; Move src_ptr to the next line
            lda src_ptr
            adc curs_width
            sta src_ptr
            lda src_ptr+1
            adc #0
            sta src_ptr+1

            inx                     ; Move src line number to the next row
            cpx curs_height         ; Have we copied the last row?
            bne copy_text           ; No: copy the line

            lda dst_ptr             ; Clear the destination line
            sta cur_line
            lda dst_ptr+1
            sta cur_line+1
            jsr clrline

            pla                     ; Restore the original I/O page
            sta MMU_IO_CTRL

            pla                     ; Restore the current line
            sta cur_line
            pla
            sta cur_line+1

            plx
            pla
            rts
            .pend

;
; Clear the current line
;
clrline:    .proc
            pha
            phy

            lda MMU_IO_CTRL         ; Save the current I/O page
            pha

            lda #MMU_IO_PAGE_TEXT   ; Move to the text page
            sta MMU_IO_CTRL

            ldy #0                  ; Fill the text matrix line with blanks
            lda #' '
loop1:      sta (cur_line),y
            iny
            cpy curs_width
            bne loop1

            lda #MMU_IO_PAGE_COLOR  ; Move to the text color page
            sta MMU_IO_CTRL

            ldy #0                  ; Fill the color matrix line with the current color
            lda curs_color
loop2:      sta (cur_line),y
            iny
            cpy curs_width
            bne loop2

            pla                     ; Restore the original I/O page
            sta MMU_IO_CTRL

            ply
            pla
            rts
            .pend

;
; Print the character in A
;
conout:     .proc
            phy

            cmp #CHAR_NL            ; Is it a carriage return?
            bne not_cr

            stz curs_x              ; Yes: Do a carriage return
            inc curs_y
            jsr cursset
            bra done

not_cr:     cmp #CHAR_FF            ; Is it a FF character?
            bne not_ff

            jsr consclr             ; Yes: clear the screen
            bra done

not_ff:     cmp #CHAR_BS            ; Is it a backspace character?
            bne not_bs

            lda curs_x              ; Yes: move the cursor back
            beq bs_leftmost         ; Is it already on column 0?
            dec a                   ; No: move it back one
            sta curs_x
            jsr cursset
bs_leftmost:
            lda #' '                ; Clear the current character
            ldy curs_x              ; Get the index to the cursor
            sta (cur_line),y        ; Write the character to the screen
            bra done

not_bs:     sta tmp                 ; Otherwise: save A in preparation for printing
            
            lda MMU_IO_CTRL         ; Save the current I/O page
            pha

            lda #MMU_IO_PAGE_TEXT   ; Move to the text page
            sta MMU_IO_CTRL

            lda tmp                 ; Get A back
            ldy curs_x              ; Get the index to the cursor
            sta (cur_line),y        ; Write the character to the screen

            lda #MMU_IO_PAGE_COLOR  ; Move to the color page
            sta MMU_IO_CTRL

            lda curs_color          ; Get the current color
            sta (cur_line),y        ; And set it on the screen

            pla                     ; Restore the I/O page
            sta MMU_IO_CTRL

            inc curs_x              ; Move to the next column
            jsr cursset

done:       ply
            rts
            .pend

;
; Print the number in A as a hexadecimal
;
printah:    .proc
            phx

            pha
            lsr a
            lsr a
            lsr a
            lsr a
            and #$0f
            tax                     ; Convert it to an index
            lda hex_digits,x        ; Lookup the hex digit for that nibble
            jsr conout              ; And print it

            pla
            and #$0f                ; Isolate the low nibble
            tax                     ; Convert it to an index
            lda hex_digits,x        ; Lookup the hex digit for that nibble
            jsr conout              ; And print it

            plx
            rts
            .pend

;
; Print the 16-bit number in Y:A as a hexadecimal number
;
printyah:   .proc
            pha
            tya
            jsr printah
            pla
            jsr printah
            rts
            .pend

hex_digits: .text "0123456789ABCDEF"

;
; Print the ASCIIZ string indicated by src_ptr
;
prints:     .proc
            pha
            phy

            ldy #0
loop:       lda (src_ptr),y
            beq done
            jsr conout
            iny
            bne loop

done:       ply
            pla
            rts
            .pend
.send
