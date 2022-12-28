AS = 64tass
ASFLAGS = --mw65c02

.PHONY: all runhex clean

all: forth.hex

runhex: forth.hex
	python $(FOENIXMGR)/FoenixMgr/fnxmgr.py --upload forth.hex

%.asm: %.fth
	python mf/compiler.py

%.hex: %.asm
	$(AS) $(ASFLAGS) --intel-hex -o $@ $< --list=$*.lst

clean:
	del *.hex
	del *.lst