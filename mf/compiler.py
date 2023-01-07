import re
import sys
import comp_words
import tokens
import emit65c02

base_id = 0

def next_id():
    """Get the next unused ID."""
    global base_id
    base_id = base_id + 1
    return base_id

class LabelDeclaration:
    """Represent the declaration of a label in a bytecode stream"""

    def __init__(self, label):
        self._label = label

    def emit(self, emitter):
        """Write the label declaration"""
        emitter.emit_label_declaration(self._label)

class LabelReference:
    """Represent the reference to a label in a bytecode stream"""

    def __init__(self, label):
        self._label = label

    def emit(self, emitter):
        """Write the label reference"""
        emitter.emit_label_reference(self._label)

class Literal:
    """Represent a literal in a bytecode stream"""

    def __init__(self, value):
        self._value = value

    def emit(self, emitter):
        """Write the literal"""
        emitter.emit_literal(self._value)

class LiteralString:
    """Represent a literal string in a bytecode stream"""

    def __init__(self, value):
        self._value = value

    def emit(self, emitter):
        """Write the literal"""
        emitter.emit_literal_string(self._value)

class LiteralPascalString:
    """Represent a literal Pascal style string in a bytecode stream"""

    def __init__(self, value):
        self._value = value

    def emit(self, emitter):
        """Write the literal"""
        emitter.emit_literal_pascal_string(self._value)

class TargetObject:
    """Represent an object that gets written to the target assembly file."""

    def __init__(self):
        self._id = next_id()

    def get_id(self):
        """Return the unique ID of the Forth word"""
        return self._id

class Word(TargetObject):
    """Represent a general word"""

    def __init__(self, name):
        super().__init__()
        self._name = name
        self._link = None
        self._flags = 0

    def get_name(self):
        """Return the name of the word"""
        return self._name

    def set_name(self, name):
        """Sets the name of the object"""
        self._name = name

    def get_link(self):
        """Return the link of this word"""
        return self._link

    def set_link(self, link):
        """Sets the link of this word"""
        self._link = link

    def get_flags(self):
        """Return the flags"""
        return self._flags

    def set_flags(self, flags):
        """Set the flags"""
        self._flags = flags | 0x80          # Include 0x80 in flags to serve as a begining of definition marker

    def get_name_label(self):
        """Return the label for the name field."""
        return "w_{}".format(self.get_name())

    def get_xt_label(self):
        """Return the label for the execution token."""
        return "xt_{}".format(self.get_name())

    def is_immediate(self):
        """Return True if the IMMEDIATE flag is set."""
        return (self.get_flags() & Compiler.FLAG_IMMEDIATE) == Compiler.FLAG_IMMEDIATE

class Comment(Word):
    """Represent a comment"""

    def __init__(self, value):
        super().__init__("")
        self.set_name("comment_{}".format(self.get_id()))
        self._value = value

    def emit(self, emitter):
        """Emit the Forth word to the assembly file."""
        emitter.emit_comment("( {} )".format(self._value))

class ForthWord(Word):
    """Represent a word defined using Forth"""

    def __init__(self, name):
        super().__init__(name)
        self._bytecodes = []
        self._enter = "i_enter"
        self._exit = "i_exit"

    def compile(self, bytecode):
        self._bytecodes.append(bytecode)

    def emit(self, emitter):
        """Emit the Forth word to the assembly file."""
        emitter.emit_forth_word(self)

    def get_bytecodes(self):
        """Return the bytecodes"""
        return self._bytecodes

    def set_enter_label(self, label):
        """Set the label for the ENTER word at the beginning"""
        self._enter = label

    def get_enter_label(self):
        """Return the label for the code field"""
        return self._enter

    def set_exit_label(self, label):
        """Set the label for the EXIT word at the end"""
        self._exit = label

    def get_exit_label(self):
        """Return the label for the exit"""
        return self._exit

class CodeWord(Word):
    """Represent a word implemented in assembly."""

    def __init__(self, name):
        super().__init__(name)
        self._assembly = ""

    def set_assembly(self, assembly):
        """Set the assembly code"""
        self._assembly = assembly

    def get_assembly(self):
        """Get the assembly code"""
        return self._assembly

    def emit(self, emitter):
        """Emit the code word to the assembly file."""
        emitter.emit_code_word(self)

class CompilerWord(Word):
    """Represent a word for the compiler"""

    def __init__(self, name, procedure, is_immediate):
        super().__init__(name)
        self._procedure = procedure
        if is_immediate:
            self.set_flags(Compiler.FLAG_IMMEDIATE)

    def execute(self, c):
        """Invoke the compiler word"""
        self._procedure(c)
   
class Compiler:
    """Represent the cross-compiler for the Forth system."""

    STATE_RUNNING = 0
    STATE_COMPILING = 1

    FLAG_IMMEDIATE = 0x40

    def __init__(self):
        """Initialize the compiler."""
        self._state = Compiler.STATE_RUNNING
        self._entries = []
        self._compiler_words = {}
        self._object_words = {}
        self._input_file = None
        self._current_word = None
        self._old_state = None
        self._prolog = ""
        self._epilog = ""
        self._label_stack = []
        self._parameter_stack = []
        self._test_word = None
        self._file_stack = []

    def register(self, word):
        """Register a compiler word."""
        self._compiler_words[word.get_name().lower()] = word

    def get_test_word(self):
        """Gets the word to contain the unit tests. Create if it does not already exist."""
        if self._test_word == None:
            self._test_word = ForthWord("unittest")
            self.add_word(self._test_word)
        return self._test_word

    def set_prolog(self, file):
        """Set the prolog assembly file"""
        self._prolog = file

    def set_epilog(self, file):
        """Set the prolog assembly file"""
        self._epilog = file

    def add_word(self, word):
        """Add a CodeWord or ForthWord to the dictionary"""
        self._object_words[word.get_name()] = word
        word.set_link(self._current_word)
        self._current_word = word
        self.add_entry(word)

    def add_entry(self, entry):
        """Add an entry (comment or word) to the list of entries"""
        self._entries.append(entry)

    def get_entries(self, word):
        """Get all the entries (words and comments) in definition order"""
        return self._entries

    def get_current_word(self):
        """Get the most recently defined word from the dictionary"""
        return self._current_word

    def gen_label(self):
        """Generate a new label"""
        return "l_{}".format(next_id())

    def push_label(self, label):
        """Save a label on the label stack"""
        self._label_stack.append(label)

    def pop_label(self):
        """Pop a label from the label stack"""
        return self._label_stack.pop()

    def push_param(self, value):
        """Push a parameter onto the parameter stack."""
        self._parameter_stack.append(value)

    def pop_param(self):
        """Pop a parameter from the parameter stack."""
        return self._parameter_stack.pop()

    def error(self, message):
        """Print an error message and quit."""
        print(message)
        sys.exit(1)

    def set_state(self, state):
        """Set the state of the compiler."""
        self._old_state = self._state
        self._state = state

    def pop_state(self):
        """Restore the previous state."""
        if self._old_state:
            self._state = self._old_state
            self._old_state = None

    def parse_number(self, token):
        """Attempt to parse the token as a number."""
        # Check to see if the number is in decimal
        match = re.match(r'(\d+)', token)
        if match:
            # We matched a decimal: return the value
            return match.group(1)

        # # Check to see if the number is in hexadecimal ($1S2)
        # match = re.match(r'\$(\x+)', token)
        # if match:
        #     # We matched a hexadecimal number
        #     return int(match.group(0), 16)

        # # Check to see if the number is in hexadecimal (1A2H)
        # match = re.match(r'(\x+)[hH]', token)
        # if match:
        #     # We matched a hexadecimal number
        #     return int(match.group(0), 16)

        # Check to see if the number is in binary (%01110)
        match = re.match(r'\%([01]+)', token)
        if match:
            # We matched a binary number
            return int(match.group(0), 2)

        return None

    def skip_to(self, character):
        """Skip everything until character is found."""
        self._input_file.read_to(character)

    def read_to(self, character):
        """Read data on the current line until character is found"""
        return self._input_file.read_to(character)

    def compile_token(self, word, token):
        """Convert the token to the correct bytecode(s) and compile it to the word."""

        # If we're compiling, we're looking for defined words to compile into the current word
        if word:
            # There is a current word...
            if token in self._compiler_words.keys() and self._compiler_words[token].is_immediate():
                # There is an IMMEDIATE compiler word
                self._compiler_words[token].execute(self)

            elif token in self._object_words.keys():
                # Word is defined... compile it in the current word
                target_word = self._object_words[token]
                word.compile(LabelReference(target_word.get_xt_label()))

            else:
                match = re.match(r'^(\d+)$', token)
                if match:
                    # Matched a decimal number
                    word.compile(LabelReference("xt_(literal)"))
                    word.compile(Literal(int(match.group(1))))
                    return

                match = re.match(r'^([0-9a-fA-F]+)h$', token)
                if match:
                    # Matched a hex number
                    word.compile(LabelReference("xt_(literal)"))
                    word.compile(Literal(int(match.group(1), 16)))
                    return

                else:
                    # The word is not defined... this is an error
                    self.error("Unknown word: {}".format(token))

        else:
            # There is not a current word... don't know how this happens, but it's an error
            self.error("Not defining a word.")

    def process_token(self, token):
        """Process an individual word."""

        if token:
            if self._state == Compiler.STATE_RUNNING:
                # If we're just in running mode, we expect only compiler words to execute
                token_lc = token.lower()
                if token in self._compiler_words.keys():
                    compiler_word = self._compiler_words[token_lc]
                    compiler_word.execute(self)

                else:
                    # Not a compiler word... is it a number?
                    n = self.parse_number(token)
                    if n == None:
                        # Unknown compiler word... this is an error
                        self.error("Unknown compiler word: {}".format(token))
                    
                    else:
                        self.push_param(n)

            elif self._state == Compiler.STATE_COMPILING:
                # If we're compiling, we're looking for defined words to compile into the current word
                self.compile_token(self._current_word, token)

    def next_token(self):
        """Get the next token from the current file."""
        return self._input_file.get_token()

    def process_file(self, file):
        """Process the words in a file"""

        # TODO: allow for include files
        if self._input_file != None:
            self._file_stack.append(self._input_file)

        with open(file, "r") as input:
            self._input_file = tokens.TokenStream(input)
            token = self._input_file.get_token()
            while token:
                if token:
                    self.process_token(token)
                    token = self._input_file.get_token()

        if len(self._file_stack) > 0:
            self._input_file = self._file_stack.pop()

    def emit(self, emitter):
        """Emit all the words to the assembly file."""
        emitter.emit_include(self._prolog)
        emitter.emit_start_file()

        words = self._entries
        for word in words:
            word.emit(emitter)

        emitter.emit_end_file()
        emitter.emit_include(self._epilog)

if __name__ == "__main__":
    c = Compiler()
    comp_words.register_all(c)
    c.process_file("forth.fth")

    with open("forth.asm", "w") as out:
        e = emit65c02.EmitterC02(out)
        c.emit(e)