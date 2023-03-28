\\\
\\\ Assembler words for the 65c02
\\\

( address zp-opcode abs-opcode -- )
: asm.zp.abs
    ( Choose between zero page and absolute operations )
    rot             ( zp-opcode abs-opcode addr )
    dup ff00h and 0= if
        rot c,      ( Compile the zero-page opcode: abs-opcode addr )
        c,          ( Compile the zero page operand )
        drop        ( Drop the absolute opcode )
    else
        rot drop    ( Drop the zero-page opcode: abs-opcode addr )
        swap c,     ( Compile the absolute opcode )
        ,           ( Compile the 16-bit operand )
    then
;

( address zp-opcode -- )
: asm.zp
    ( Ensure only a zero-page address is given )
    dup ff00h and 0= if
        c,          ( Compile the zero-page op-code )
        c,          ( Compile the byte operand )
    else
        abort" Operand out of range"
    then
;

\\ ADC words...

: adc.#,
    ( Compile the ADC # operation )
    69h c,
    ,
;

: adc,
    ( Compile the ADC absolute or ZP operation )
    65h 6dh asm.zp.abs
;

: adc.x,
    ( Compile the ADC,X absolute or ZP operation )
    75h 7dh asm.zp.abs
;

: adc.y,
    ( Compile the ADC,Y operation )
    69h c,
    ,           ( Compile the 16-bit operand )
;

: adc.()
    ( Compile the ADC () operation )
    72h asm.zp
;

: adc.(x),
    ( Compile the ADC (X) operation )
    61h asm.zp
;

: adc.()y,
    ( Compile the ADC (),Y operation )
    71h asm.zp
;

\\ AND words...

: and.#,
    ( Compile the and # operation )
    29h c,
    ,
;

: and,
    ( Compile the and absolute or ZP operation )
    25h 2dh asm.zp.abs
;

: and.x,
    ( Compile the and,X absolute or ZP operation )
    35h 3dh asm.zp.abs
;

: and.y,
    ( Compile the and,Y operation )
    39h c,
    ,           ( Compile the 16-bit operand )
;

: and.(),
    ( Compile the and () operation )
    32h asm.zp
;

: and.(x),
    ( Compile the and (X) operation )
    21h asm.zp
;

: and.()y,
    ( Compile the and (),Y operation )
    31h asm.zp
;

\\ ASL words...

: asl.a,
    ( Compile the ASL A instruction )
    0ah c,
;

: asl,
    ( Compile the ASL absolute or ZP operation )
    06h 0eh asm.zp.abs
;

: asl.x,
    ( Compile the ASL ,X  operation )
    16h 1eh asm.zp.abs
;

\\ BIT words

: bit.#,
    ( Compile the BIT # instruction )
    89h c,
;

: bit,
    ( Compile the BIT operation )
    24h 2ch asm.zp.abs
;

: bit.x,
    ( Compile the BIT,X absolute or ZP operation )
    34h 3ch asm.zp.abs
;

\\ Branch instructions

( addr opcode -- )
: bxx,
    ( Compile a branch instruction )
    c,                  ( Compile the opcode )
    here -              ( Compute the offset )
    dup and ff00h 0= if
        c,              ( Compile the offset )
    else
        abort" Offset out of range"
    then
;

: bpl,
    ( Compile BPL instruction )
    10h bxx,
;

: bmi,
    ( Compile BMI instruction )
    30h bxx,
;

: bvc,
    ( Compile BVC instruction )
    50h bxx,
;

: bvs,
    ( Compile BVS instruction )
    70h bxx,
;

: bcc,
    ( Compile BCC instruction )
    90h bxx,
;

: bcs,
    ( Compile BCS instruction )
    b0h bxx,
;

: bne,
    ( Compile BNE instruction )
    d0h bxx,
;

: beq,
    ( Compile BEQ instruction )
    f0h bxx,
;

: bra,
    ( Compile BRA instruction )
    80h bxx,
;

\\ BRK

: brk
    ( Compile the BRK instruction )
    00h c,
;

\\ Compare instructions

: cmp.#,
    ( Compile the CMP # operation )
    c9h c,
    ,
;

: cmp,
    ( Compile the CMP absolute or ZP operation )
    c5h cdh asm.zp.abs
;

: cmp.x,
    ( Compile the CMP,X absolute or ZP operation )
    d5h ddh asm.zp.abs
;

: cmp.y,
    ( Compile the CMP,Y operation )
    c9h c,
    ,           ( Compile the 16-bit operand )
;

: cmp.(),
    ( Compile the CMP () operation )
    d2h asm.zp
;

: cmp.(x),
    ( Compile the CMP (X) operation )
    c1h asm.zp
;

: cmp.()y,
    ( Compile the CMP (),Y operation )
    d1h asm.zp
;

: cpx.#,
    ( Compile the CPX # operation )
    e0h c,
    ,
;

: cpx,
    ( Compile the CPX absolute or ZP operation )
    e4h ech asm.zp.abs
;

: cpy.#,
    ( Compile the CPY # operation )
    c0h c,
    ,
;

: cpy,
    ( Compile the CPY absolute or ZP operation )
    c4h cch asm.zp.abs
;

\\ Decrement Instructions

: dec.a,
    ( Compile the DEC A operation )
    3ah c,
;

: dex,
    ( Compile the DEX operation )
    cah c,
;

: dey,
    ( Compile the DEY operation )
    88h c,
;

: dec,
    ( Compile the DEC absolute or ZP operation )
    c6h ceh asm.zp.abs
;

: dec.x,
    ( Compile the DEC,X absolute or ZP operation )
    d6h deh asm.zp.abs
;


\\ TODO: EOR

\\ Flag instructions

: clc,
    ( Compile the CLC instruction )
    18h c,
;

: sec,
    ( Compile the SEC instruction )
    38h c,
;

: cli,
    ( Compile the CLI instruction )
    58h c,
;

: sei,
    ( Compile the SEI instruction )
    78h c,
;

: clv,
    ( Compile the CLV instruction )
    b8h c,
;

: cld,
    ( Compile the CLD instruction )
    d8h c,
;

: sed,
    ( Compile the SED instruction )
    f8h c,
;

\ JMP

: jmp,
    ( Compile a JMP absolute )
    4ch c, ,
;

: jmp.(),
    ( Compile a JMP indirect )
    6ch c, ,
;

: jmp.(x),
    ( Compile a JMP indexed indirect )
    7ch c, ,
;

\ Helpful words...

( -- )
: next,
    ( Compile the NEXT word )
    ' next jmp,
;