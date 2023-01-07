;;;
;;; Code to do simple keyboard stuff
;;;

KBD_SCAN = $d642
KBD_STAT = $d644
KBD_RDY = $01

KBD_ST_F0 = $01
KBD_ST_E0 = $02

KBD_SHIFT = $80
KBD_CTRL = $81
KBD_ALT = $82
KBD_OS = $83
KBD_CAP = $84

KBD_MOD_SHIFT = $01
KBD_MOD_CTRL = $02
KBD_MOD_ALT = $04
KBD_MOD_OS = $08
KBD_MOD_CAP = $10

KBD_BUFFER_SIZE = 80

.section variables
kbd_state   .byte ?         ; The current state of the scan code interpreter
kbd_mods    .byte ?         ; The current state of the modifier keys
kbd_buffer  .fill 80        ; Keyboard buffer
kbd_head    .byte ?         ; Index to write to in the keyboard buffer
.send

.section code


initkbd:    .proc
            stz kbd_state
            stz kbd_mods
            stz kbd_head
            rts
            .pend

;
; Return the status of the keyboard
;
; Returns:
; A = $00: no characters waiting,
;     $01: characters waiting
;
kbd_status: .proc
            lda kbd_head
            beq is_empty

            lda #1
            rts

is_empty:
            rts
            .pend

;
; Add the character in A to the keyboard buffer
;
kbd_enqueue: .proc
            phx

            ldx kbd_head            ; Make sure the buffer is not full
            cpx #KBD_BUFFER_SIZE
            bge done

            sta kbd_buffer,x        ; Save the character to the end of the buffer
            inx 
            stx kbd_head            ; Update the index

done:
            plx
            rts
            .pend

;
; Remove a key from the keyboard buffer and return in A... 0 if nothing is queued
;
kbd_dequeue: .proc
            phx

            ldx kbd_head            ; Make sure the buffer is not empty
            beq is_empty            ; If so, return 0

            lda kbd_buffer          ; Get the character
            pha                     ; Save it temporarily to the stack

            ldx #0                  ; Remove a character from the buffer
loop:
            lda kbd_buffer+1,x      ; Copy a character down
            sta kbd_buffer,x
            inx                     ; Move to the next character
            cpx kbd_head            ; Until we've copied all saved characters
            bne loop

            dec kbd_head            ; Decrement the index
            
            pla                     ; Get the character back and return
            bra done

is_empty:
            lda #0                  ; Return 0 if buffer is empty

done:
            plx
            rts
            .pend

handlekbd:  .proc
            lda KBD_STAT    ; Check to see if the key is ready
            and #KBD_RDY
            bne done        ; No: skip the keyboard

            lda kbd_state   ; Get state of the interpreter
            beq st_0        ; If base state...

            cmp #KBD_ST_F0  ; Have we seen an F0?
            beq st_f0       ; Yes process the F0 codes

            ; TODO: handle F0 and E0 states

            stz kbd_state   ; Something is wrong... reset the state machine

done:
            rts

st_0:       ; Process base state scan codes

            lda KBD_SCAN    ; Get the scan code

            cmp #$f0        ; Is it a release code
            bne not_f0

            lda #KBD_ST_F0  ; Yes: go to state KBD_ST_F0
            sta kbd_state
            bra done

not_f0:     cmp #$e0        ; Is it E0?
            bne not_f0e0

            lda #KBD_ST_E0  ; Yes: go to state KBD_ST_E0
            sta kbd_state
            bra done

            ;
            ; Ordinary key press
            ;
not_f0e0:
            pha
            lda kbd_mods
            bit #KBD_MOD_CAP
            bne read_caps
            bit #KBD_MOD_SHIFT
            bne read_shift

            pla
            tax
            lda kbd_sc_00,x
            bra proc_ascii

read_caps:
            bit #KBD_MOD_SHIFT
            bne read_caps_shift
            pla
            tax
            lda kbd_sc_cap,x
            bra proc_ascii

read_caps_shift:
            pla
            tax
            lda kbd_sc_cs,x
            bra proc_ascii

read_shift:
            pla
            tax
            lda kbd_sc_sh,x

proc_ascii:
            cmp #KBD_SHIFT          ; If shift...
            beq raise_shift

            cmp #KBD_CAP            ; If it's a capslock
            beq toggle_caps

            jsr kbd_enqueue         ; Enqueue the character
            bra done

raise_shift:
            ; lda #$18                ; Flag shift up
            ; jsr conout

            lda kbd_mods            ; Turn on the SHIFT modifier
            ora #KBD_MOD_SHIFT
            sta kbd_mods
            bra done

toggle_caps:
            lda kbd_mods            ; Toggle CAPS modifier
            eor #KBD_MOD_CAP
            sta kbd_mods
            bra done

;
; F0 prefix in effect...
;
st_f0:      ; F0 seen... this is a break... just skip it
            ; lda #$1f
            ; jsr conout

            lda KBD_SCAN            ; Get the scan code
            tax
            lda kbd_sc_00,x         ; Get the base key for it

            cmp #KBD_SHIFT          ; If shift...
            bne exit_f0

            ; lda #$19                ; Flag shift down
            ; jsr conout

            lda kbd_mods            ; Drop the SHIFT modifier
            and #~KBD_MOD_SHIFT
            sta kbd_mods

exit_f0:
            stz kbd_state   ; Go back to state 0
            bra done

            .pend

; Unmodified keys
kbd_sc_00:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $08, '`', $00    ; $00 - $0F
            .byte $00, $00, $80, $00, $00, 'q', '1', $00, $00, $00, 'z', 's', 'a', 'w', '2', $00    ; $10 - $1F
            .byte $00, 'c', 'x', 'd', 'e', '4', '3', $00, $00, ' ', 'v', 'f', 't', 'r', '5', $00    ; $20 - $2F
            .byte $00, 'n', 'b', 'h', 'g', 'y', '6', $00, $00, $00, 'm', 'j', 'u', '7', '8', $00    ; $30 - $3F
            .byte $00, ',', 'k', 'i', 'o', '0', '9', $00, $00, '.', '/', 'l', ';', 'p', '-', $00    ; $40 - $4F
            .byte $00, $00, $27, $00, '[', '=', $00, $00, $84, $80, $0d, ']', $00, '\', $00, $00    ; $50 - $5F
            .byte $00, $00, $00, $00, $00, $00, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00    ; $60 - $6F
            .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00    ; $70 - $7F

; Shifted keys
kbd_sc_sh:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $08, '~', $00    ; $00 - $0F
            .byte $00, $00, $80, $00, $00, 'Q', '!', $00, $00, $00, 'Z', 'S', 'A', 'W', '@', $00    ; $10 - $1F
            .byte $00, 'C', 'X', 'D', 'E', '$', '#', $00, $00, ' ', 'V', 'F', 'T', 'R', '%', $00    ; $20 - $2F
            .byte $00, 'N', 'B', 'H', 'G', 'Y', '^', $00, $00, $00, 'M', 'J', 'U', '&', '*', $00    ; $30 - $3F
            .byte $00, '<', 'K', 'I', 'O', ')', '(', $00, $00, '>', '?', 'L', ':', 'P', '_', $00    ; $40 - $4F
            .byte $00, $00, '"', $00, '{', '+', $00, $00, $84, $80, $0d, '}', $00, '|', $00, $00    ; $50 - $5F
            .byte $00, $00, $00, $00, $00, $00, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00    ; $60 - $6F
            .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00    ; $70 - $7F

; Caps lock keys
kbd_sc_cap: .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $08, '`', $00    ; $00 - $0F
            .byte $00, $00, $80, $00, $00, 'Q', '1', $00, $00, $00, 'Z', 'S', 'A', 'W', '2', $00    ; $10 - $1F
            .byte $00, 'C', 'X', 'D', 'E', '4', '3', $00, $00, ' ', 'V', 'F', 'T', 'R', '5', $00    ; $20 - $2F
            .byte $00, 'N', 'B', 'H', 'G', 'Y', '6', $00, $00, $00, 'M', 'J', 'U', '7', '8', $00    ; $30 - $3F
            .byte $00, ',', 'K', 'I', 'O', '0', '9', $00, $00, '.', '/', 'L', ';', 'P', '-', $00    ; $40 - $4F
            .byte $00, $00, $27, $00, '[', '=', $00, $00, $84, $80, $0d, ']', $00, '\', $00, $00    ; $50 - $5F
            .byte $00, $00, $00, $00, $00, $00, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00    ; $60 - $6F
            .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00    ; $70 - $7F

; Caps and Shift keys
kbd_sc_cs:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $08, '~', $00    ; $00 - $0F
            .byte $00, $00, $80, $00, $00, 'q', '!', $00, $00, $00, 'z', 's', 'a', 'w', '@', $00    ; $10 - $1F
            .byte $00, 'c', 'x', 'd', 'e', '$', '#', $00, $00, ' ', 'v', 'f', 't', 'r', '%', $00    ; $20 - $2F
            .byte $00, 'n', 'b', 'h', 'g', 'y', '^', $00, $00, $00, 'm', 'j', 'u', '&', '*', $00    ; $30 - $3F
            .byte $00, '<', 'k', 'i', 'o', '0', '(', $00, $00, '>', '?', 'l', ':', 'p', '_', $00    ; $40 - $4F
            .byte $00, $00, '"', $00, '{', '+', $00, $00, $84, $80, $0d, '}', $00, '|', $00, $00    ; $50 - $5F
            .byte $00, $00, $00, $00, $00, $00, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00    ; $60 - $6F
            .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00    ; $70 - $7F

.send
