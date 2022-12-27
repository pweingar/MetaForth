#
# Unit test code
#

class SimpleTest:
    """A unit test"""

    def __init__(self):
        self._name = "Unnamed test"
        self._bytecodes = []
        self._expected_values = []

    def set_name(self, name):
        """Set the name of the test"""
        self._name = name

    def get_name(self):
        """Get the name of the test"""
        return self._name

    def compile(self, bytecode):
        """Add a bytecode to the test"""
        self._bytecodes.append(bytecode)

    def get_bytecodes(self):
        """Get the byte codes that need to be run for the test"""
        return self._bytecodes

    def add_expected(self, expected):
        """Add an expected value to the list"""
        self._expected_values.append(expected)

    def get_expected(self):
        """Get the list of expected values."""
        return self._expected_values

    def emit(self, emitter):
        """Emit the test to the assembly file."""
        emitter.emit_test(self)
