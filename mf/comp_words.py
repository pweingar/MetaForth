import compiler
import testing

#
# Define the code for all the compiler words for MetaForth
#
# These are the words that are actually executed by the compiler at compile time
#

LOOP_TYPE_BEGIN = 1
LOOP_TYPE_DO = 2

def exec_case(c):
    """Process a CASE word"""
    end_case_label = c.gen_label()
    c.push_label(end_case_label)

def exec_end_case(c):
    """Process an END-CASE word"""
    current_word = c.get_current_word()
    end_case_label = c.pop_label()
    current_word.compile(compiler.LabelReference("xt_drop"))
    current_word.compile(compiler.LabelDeclaration(end_case_label))
    print("end-case {}".format(end_case_label))

def exec_of(c):
    """Process an OF clause"""
    current_word = c.get_current_word()
    end_of_label = c.gen_label()
    c.push_label(end_of_label)
    current_word.compile(compiler.LabelReference("xt_(of)"))
    current_word.compile(compiler.LabelReference(end_of_label))

def exec_endof(c):
    """Process an ENDOF word"""
    current_word = c.get_current_word()
    end_of_label = c.pop_label()
    end_case_label = c.pop_label()
    c.push_label(end_case_label)
    current_word.compile(compiler.LabelReference("xt_(branch)"))
    current_word.compile(compiler.LabelReference(end_case_label))
    current_word.compile(compiler.LabelDeclaration(end_of_label))

def exec_include(c):
    """Process an include command"""
    file_name = c.read_to("\"")
    c.process_file(file_name)

# ( limit initial -- )
def exec_do(c):
    """Compile the word DO"""
    current_word = c.get_current_word()
    jump_label = c.gen_label()
    exit_label = c.gen_label()
    c.push_label(exit_label)
    c.push_label(jump_label)
    c.push_label(LOOP_TYPE_DO)
    current_word.compile(compiler.LabelReference("xt_(do)"))
    current_word.compile(compiler.LabelDeclaration(jump_label))

def exec_plusloop(c):
    """Compile the word +LOOP"""
    current_word = c.get_current_word()
    loop_type = c.pop_label()
    jump_label = c.pop_label()
    exit_label = c.pop_label()
    current_word.compile(compiler.LabelReference("xt_(+loop)"))
    current_word.compile(compiler.LabelReference(jump_label))
    current_word.compile(compiler.LabelDeclaration(exit_label))

def exec_loop(c):
    """Compile the word LOOP"""
    current_word = c.get_current_word()
    loop_type = c.pop_label()
    jump_label = c.pop_label()
    exit_label = c.pop_label()
    current_word.compile(compiler.LabelReference("xt_(loop)"))
    current_word.compile(compiler.LabelReference(jump_label))
    current_word.compile(compiler.LabelDeclaration(exit_label))

def exec_begin(c):
    """Compile the word BEGIN"""
    current_word = c.get_current_word()
    jump_label = c.gen_label()
    exit_label = c.gen_label()
    c.push_label(exit_label)
    c.push_label(jump_label)
    c.push_label(LOOP_TYPE_BEGIN)
    current_word.compile(compiler.LabelDeclaration(jump_label))

def exec_exit(c):
    """Compile the word EXIT"""
    # TODO: generalize to support DO as well
    current_word = c.get_current_word()
    loop_type = c.pop_label()
    jump_label = c.pop_label()
    exit_label = c.pop_label()
    c.push_label(exit_label)
    c.push_label(jump_label)
    c.push_label(loop_type)

    if loop_type == LOOP_TYPE_DO:
        current_word.compile(compiler.LabelReference("xt_rdrop"))
        current_word.compile(compiler.LabelReference("xt_rdrop"))

    current_word.compile(compiler.LabelReference("xt_(branch)"))
    current_word.compile(compiler.LabelReference(exit_label))

def exec_while(c):
    """Compile the word WHILE"""
    current_word = c.get_current_word()
    loop_type = c.pop_label()
    jump_label = c.pop_label()
    exit_label = c.pop_label()
    c.push_label(exit_label)
    c.push_label(jump_label)
    c.push_label(loop_type)
    current_word.compile(compiler.LabelReference("xt_(branch0)"))
    current_word.compile(compiler.LabelReference(exit_label))

def exec_again_repeat(c):
    """Compile the word AGAIN or REPEAT"""
    current_word = c.get_current_word()
    loop_type = c.pop_label()
    jump_label = c.pop_label()
    exit_label = c.pop_label()
    current_word.compile(compiler.LabelReference("xt_(branch)"))
    current_word.compile(compiler.LabelReference(jump_label))
    current_word.compile(compiler.LabelDeclaration(exit_label))

def exec_until(c):
    """Compile the word UNTIL"""
    current_word = c.get_current_word()
    loop_type = c.pop_label()
    jump_label = c.pop_label()
    exit_label = c.pop_label()
    current_word.compile(compiler.LabelReference("xt_(branch0)"))
    current_word.compile(compiler.LabelReference(jump_label))
    current_word.compile(compiler.LabelDeclaration(exit_label))

def exec_cstr(c):
    """Compile the word C\""""
    text_label = c.gen_label()
    jump_label = c.gen_label()
    current_word = c.get_current_word()
    data = c.read_to("\"")
    current_word.compile(compiler.LabelReference("xt_(literal)"))
    current_word.compile(compiler.LabelReference(text_label))
    current_word.compile(compiler.LabelReference("xt_(branch)"))
    current_word.compile(compiler.LabelReference(jump_label))
    current_word.compile(compiler.LabelDeclaration(text_label))
    current_word.compile(compiler.LiteralPascalString(data))
    current_word.compile(compiler.LabelDeclaration(jump_label))

def exec_user(c):
    """Compile a USER"""
    name = c.next_token()
    value = c.pop_param()

    new_word = compiler.ForthWord(name)
    c.add_word(new_word)
    
    new_word.set_enter_label("xt_(user)")
    new_word.set_exit_label("")
    new_word.compile(compiler.Literal(value))

def exec_constant(c):
    """Compile a CONSTANT"""
    name = c.next_token()
    value = c.pop_param()

    new_word = compiler.ForthWord(name)
    c.add_word(new_word)
    
    new_word.set_enter_label("xt_(constant)")
    new_word.set_exit_label("")
    new_word.compile(compiler.Literal(value))

def exec_if(c):
    """Compile an IF word"""

    # COMPILE: (branch0) <label to false_case/end_if>
    current_word = c.get_current_word()
    false_case = c.gen_label()
    c.push_label(false_case)
    current_word.compile(compiler.LabelReference("xt_(branch0)"))
    current_word.compile(compiler.LabelReference(false_case))

def exec_else(c):
    """Compile an ELSE word"""

    # COMPILE: branch <label to end_if>
    #          <label to false_case>
    false_case = c.pop_label()
    end_if = c.gen_label()
    c.push_label(end_if)
    current_word = c.get_current_word()
    current_word.compile(compiler.LabelReference("xt_(branch)"))
    current_word.compile(compiler.LabelReference(end_if))
    current_word.compile(compiler.LabelDeclaration(false_case))

def exec_then(c):
    """Compile a THEN word"""

    # COMPILE: label for IF or ELSE to call
    current_word = c.get_current_word()
    end_if = c.pop_label()
    current_word.compile(compiler.LabelDeclaration(end_if))

def exec_cpu(c):
    """Set the target CPU"""
    cpu = c.next_token()
    c.set_prolog("mf_pre_{}.asm".format(cpu))
    c.set_epilog("mf_post_{}.asm".format(cpu))

def exec_colon(c):
    """Creates a new word and starts compiling into it."""
    name = c.next_token()
    new_word = compiler.ForthWord(name)
    c.add_word(new_word)
    c.set_state(compiler.Compiler.STATE_COMPILING)
    print("Defined {}".format(name))

def exec_semi(c):
    """Ends a definition and goes back to the running state"""
    c.set_state(compiler.Compiler.STATE_RUNNING)

def exec_code(c):
    name = c.next_token()
    body = c.read_to("end-code")

    cw = compiler.CodeWord(name)
    cw.set_assembly(body)
    c.add_word(cw)

def exec_immediate(c):
    cw = c.get_current_word()
    cw.set_flags(cw.get_flags() | compiler.Compiler.FLAG_IMMEDIATE)

def exec_lbrace(c):
    """Handle a left brace --- the declaration for a test case."""
    # Generate a test case and add it to the unittest word.

    state = 0
    name = ""
    operations = []
    expected_values = []

    while True:
        token = c.next_token()
        if state == 0:
            name = name + token + " "
            if token == "-->":
                state = 1
            else:
                operations.append(token)

        elif state == 1:
            if token == "}":
                # Test is assembled, compile it
                break

            else:
                name = name + token + " "
                expected_values.append(token)

    # Compile the test
    test_word = c.get_test_word()

    # Compile setting the name of the test
    text_label = c.gen_label()
    jump_label = c.gen_label()
    test_word.compile(compiler.LabelReference("xt_(literal)"))
    test_word.compile(compiler.LabelReference(text_label))
    test_word.compile(compiler.LabelReference("xt_(branch)"))
    test_word.compile(compiler.LabelReference(jump_label))
    test_word.compile(compiler.LabelDeclaration(text_label))
    test_word.compile(compiler.LiteralString(name.strip()))
    test_word.compile(compiler.LabelDeclaration(jump_label))
    test_word.compile(compiler.LabelReference("xt_testname"))

    # Compile each of the test words
    state = 0
    for token in operations:
        if state == 0:
            if token == "\'":
                # If we have seen ', switch to state 1
                state = 1
            else:
                # Otherwise, just compile the token
                c.compile_token(test_word, token)
        
        elif state == 1:
            # We have seen a tick... compile a literal of the current token
            state = 0
            test_word.compile(compiler.LabelReference("xt_(literal)"))
            test_word.compile(compiler.LabelReference("xt_{}".format(token)))

    # Compile each value assertion
    while len(expected_values) > 0:
        expected_value = expected_values.pop()
        c.compile_token(test_word, expected_value)
        test_word.compile(compiler.LabelReference("xt_assert="))

def exec_lp(c):
    """Process a comment"""
    comment = c.read_to(")")
    entry = compiler.Comment(comment)
    c.add_entry(entry)

def exec_dotlp(c):
    """Process a printable comment"""
    comment = c.read_to(")")
    print(comment)

def register_all(c):
    """Register all the compiler words."""
    c.register(compiler.CompilerWord("(", exec_lp, True))
    c.register(compiler.CompilerWord(".(", exec_dotlp, False))
    c.register(compiler.CompilerWord("include\"", exec_include, False))
    c.register(compiler.CompilerWord("code", exec_code, False))
    c.register(compiler.CompilerWord("immediate", exec_immediate, False))
    c.register(compiler.CompilerWord(":", exec_colon, False))
    c.register(compiler.CompilerWord(";", exec_semi, True))
    c.register(compiler.CompilerWord("$cpu$", exec_cpu, False))
    c.register(compiler.CompilerWord("{", exec_lbrace, False))
    c.register(compiler.CompilerWord("if", exec_if, True))
    c.register(compiler.CompilerWord("else", exec_else, True))
    c.register(compiler.CompilerWord("then", exec_then, True))
    c.register(compiler.CompilerWord("constant", exec_constant, False))
    c.register(compiler.CompilerWord("user", exec_user, False))
    c.register(compiler.CompilerWord("c\"", exec_cstr, True))
    c.register(compiler.CompilerWord("begin", exec_begin, True))
    c.register(compiler.CompilerWord("again", exec_again_repeat, True))
    c.register(compiler.CompilerWord("repeat", exec_again_repeat, True))
    c.register(compiler.CompilerWord("while", exec_while, True))
    c.register(compiler.CompilerWord("until", exec_until, True))
    c.register(compiler.CompilerWord("exit", exec_exit, True))
    c.register(compiler.CompilerWord("do", exec_do, True))
    c.register(compiler.CompilerWord("loop", exec_loop, True))
    c.register(compiler.CompilerWord("+loop", exec_plusloop, True))
    c.register(compiler.CompilerWord("case", exec_case, True))
    c.register(compiler.CompilerWord("end-case", exec_end_case, True))
    c.register(compiler.CompilerWord("of", exec_of, True))
    c.register(compiler.CompilerWord("endof", exec_endof, True))
