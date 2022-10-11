python
import os
import subprocess

main_term_height = os.getenv("LINES")
if main_term_height:
	gdb.execute('dashboard source -style height ' + str(int(int(main_term_height) * 0.75 - 10)))

asm_tty = os.getenv("ASM_TTY")
if asm_tty and not os.path.exists(asm_tty):
	print("\033[33mDashboard:\033[0m \"" + asm_tty + "\" does not exist, not using asm TTY")
	asm_tty = None
elif asm_tty:
	print("\033[33mDashboard:\033[0m Using \"" + asm_tty + "\" as the TTY for assembly output")
	gdb.execute('dashboard registers -output ' + asm_tty)
	gdb.execute('dashboard assembly -output ' + asm_tty)
	gdb.execute('dashboard stack -output ' + asm_tty)
	height = subprocess.check_output(['stty', '-F', asm_tty, 'size']).decode('ascii')
	height = height[:height.index(' ')]
	gdb.execute('dashboard assembly -style height ' + str(int(height) - 25));

mem_tty = os.getenv("MEM_TTY")
if mem_tty and not os.path.exists(mem_tty):
	print("\033[33mDashboard:\033[0m \"" + mem_tty + "\" does not exist, not using mem TTY")
	mem_tty = None
elif mem_tty:
	print("\033[33mDashboard:\033[0m Using \"" + mem_tty + "\" as the TTY for memory output")
	gdb.execute('dashboard memory -output ' + mem_tty);
	
qemu = os.getenv("DEBUG_QEMU")
if qemu:
	registers = {
		"i8086" : "ax bx cx dx di si bp sp eip eflags cs ss ds es fs gs fs_base gs_base k_gs_base cr0 cr2 cr3 cr4 cr8 efer mxcsr",
		"i386" : "eax ebx ecx edx edi esi ebp esp eip eflags cs ss ds es fs gs fs_base gs_base k_gs_base cr0 cr2 cr3 cr4 cr8 efer mxcsr",
		"x86-64" : "rax rbx rcx rdx rdi rsi rbp rsp r8 r9 r10 r11 r12 r13 r14 r15 rip eflags cs ss ds es fs gs fs_base gs_base k_gs_base cr0 cr2 cr3 cr4 cr8 efer mxcsr"
	}
	try:
		gdb.execute('dashboard registers -style list "' + registers[qemu] + '"');
	except KeyError:
		print('\033[33mDashboard:\033[0m Architecture "' + qemu + '" unknown; ignoring DEBUG_QEMU');
		qemu = None
	else:
		gdb.execute('dashboard assembly -style opcodes True');

# let's build the layout depending on asm_tty, mem_tty and qemu
layouts = {
	# (asm_tty, mem_tty, qemu) = layout_string
	(True, True, True)    : "source variables registers assembly stack memory",
	(True, True, False)   : "source variables registers assembly stack memory",
	(True, False, True)   : "source variables registers assembly stack",
	(True, False, False)  : "source variables registers assembly stack",
    (False, True, True)   : "registers source variables memory",
    (False, True, False)  : "registers source variables memory",
    (False, False, True)  : "registers source variables",
    (False, False, False) : "registers source variables"
}

gdb.execute('dashboard -layout ' + layouts[(asm_tty != None, mem_tty != None, qemu != None)]);

# if main_term_height:
# 	gdb.execute('dashboard assembly -style height ' + str(int(int(main_term_height) * 0.75 - 10)))
# 	gdb.execute('dashboard source -style height ' + str(int(int(main_term_height) * 0.75 - 10)))
end
