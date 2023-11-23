#
# Simple VM for the compiler
#

vm_dict = {}
vm_stack = []

def vm_set_value(name, value):
	"""Set the value of NAME in the compiler dictionary."""
	vm_dict[name] = value

def vm_get_value(name):
	"""Return the value of NAME in the compiler dictionary."""
	return vm_dict[name]

def vm_defined(name):
	"""Return true if the name is defined in the compiler dictionary."""
	return (name in vm_dict)

def vm_push(value):
	"""Push a value onto the compiler's stack."""
	vm_stack.append(value)

def vm_pop():
	"""Pop a value from the compiler stack."""
	return vm_stack.pop()
