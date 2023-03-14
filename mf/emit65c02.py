
#
# Emitter for the WDC65C02 and 64TASS
#
# Emitters generate the actual assembly file that is the end product of MetaForth.
# They are specific to the target CPU and assembler.
#

def clean_label(label):
    """Convert a label to an assembler clean version"""

    to_translate = ['(',')','\'','!','@','\"','*','+',',','-','.','/','?','<','=','>','$','#','$','%','&',':',';','[',']']

    for c in label:
        if c in to_translate:
            label = label.replace(c, "x{:02x}".format(ord(c)))

    return label

class EmitterC02:
    """Emitter for the WDC65C02 and 64TASS."""

    MAX_NAME_SIZE = 16

    def __init__(self, out):
        self._out = out

    def emit_start_file(self):
        """Emit code for the start of the file."""
        self._out.write(".section code\n; Start of auto-generated code\n\n")

    def emit_end_file(self):
        """Emit code for the end of the file."""
        self._out.write(".send\n; End of auto-generated code\n\n")

    def emit_literal(self, value):
        """Emit a literal value."""
        self._out.write("\t.word {}\n".format(value))

    def emit_literal_string(self, value):
        """Emit a literal string value."""
        self._out.write("\t.null \"{}\"\n".format(value))

    def emit_literal_pascal_string(self, value):
        """Emit a literal string value."""
        self._out.write("\t.ptext \"{}\"\n".format(value))

    def emit_label_declaration(self, label):
        """Emit the declaration of a label."""
        self._out.write("{}:\n".format(clean_label(label)))

    def emit_label_reference(self, label):
        """Emit the reference to a label."""
        self._out.write("\t.word {}\n".format(clean_label(label)))

    def emit_comment(self, comment):
        """Emit a comment"""
        self._out.write("; {}\n".format(comment))

    def emit_code_word(self, word):
        """Emit the CODE word."""
        name = word.get_name()[:EmitterC02.MAX_NAME_SIZE]
        self._out.write("; BEGIN {}\n".format(word.get_name()))
        self.emit_label_declaration(word.get_name_label())
        self._out.write("\t.byte ${:02X}\n".format(len(name) + word.get_flags()))
        self._out.write("\t.text \'{}\'\n".format(name))
        self._out.write("\t.fill {},0\n".format(EmitterC02.MAX_NAME_SIZE - len(name)))
        if word.get_link():
            # If there is a linked word, emit the reference link to the word
            self.emit_label_reference(word.get_link().get_name_label())
        else:
            # There are no more words in this wordlist, emit null as the reference link
            self._out.write("\t.word 0\n")

        self.emit_label_declaration(word.get_xt_label())
        self._out.write("\t.block\n")
        for line in word.get_assembly().splitlines():
            self._out.write("\t{}\n".format(line))
        self._out.write("\t.bend\n; END {}\n\n".format(word.get_name()))

    def emit_forth_word(self, word):
        """Emit the Forth word."""
        name = word.get_name()[:EmitterC02.MAX_NAME_SIZE]
        self._out.write("; BEGIN {}\n".format(name))
        self.emit_label_declaration(word.get_name_label())
        self._out.write("\t.byte ${:02X}\n".format(len(name) + word.get_flags()))
        self._out.write("\t.text \'{}\'\n".format(name))
        self._out.write("\t.fill {},0\n".format(EmitterC02.MAX_NAME_SIZE - len(name)))
        if word.get_link():
            # If there is a linked word, emit the reference link to the word
            self.emit_label_reference(word.get_link().get_name_label())
        else:
            # There are no more words in this wordlist, emit null as the reference link
            self._out.write("\t.word 0\n")
        self.emit_label_declaration(word.get_xt_label())
        self._out.write("\t.block\n\tjmp {}\n".format(clean_label(word.get_enter_label())))

        for bc in word.get_bytecodes():
            bc.emit(self)
        
        if word.get_exit_label() != "":
            self._out.write("\t.word {}\n".format(clean_label(word.get_exit_label())))

        self._out.write("\t.bend\n; END {}\n\n".format(word.get_name()))

    def emit_include(self, file):
        """Emit the include for a file"""
        self._out.write(".include \"{}\"\n".format(file))
