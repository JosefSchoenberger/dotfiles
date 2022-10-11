# The following code has been shamelessly copied from
# https://ternet.fr/media/gdb_init_real_mode.txt
# which stands under the GPLv3 license, as of March 2021

init-if-undefined $rip = (void(*)()) 0x0
define nni
## we know that an opcode starting by 0xE8 has a fixed length
## for the 0xFF opcodes, we can enumerate what is possible to have

	if ($rip == 0x0)
		set $lip = $eip + $cs * 16
	else
		set $lip = $rip
	end
	set $offset = 0

	# first, get rid of segment prefixes, if any
	set $_byte1 = *(unsigned char *)$lip
	# CALL DS:xx CS:xx, etc.
	if ($_byte1 == 0x3E || $_byte1 == 0x26 || $_byte1 == 0x2E || $_byte1 == 0x36 || $_byte1 == 0x3E || $_byte1 == 0x64 || $_byte1 == 0x65)
		set $lip = $lip + 1
		set $_byte1 = *(unsigned char*)$lip
		set $offset = 1
	end
	set $_byte2 = *(unsigned char *)($lip+1)
	set $_byte3 = *(unsigned char *)($lip+2)
	set $noffset = 0

	if ($_byte1 == 0xE8)
	# call near
		set $noffset = 3
	else
		if ($_byte1 == 0xFF)
		# A "ModR/M" byte follows
			set $_mod = ($_byte2 & 0xC0) >> 6
			set $_reg = ($_byte2 & 0x38) >> 3
			set $_rm  = ($_byte2 & 7)
			#printf "mod: %d reg: %d rm: %d\n", $_mod, $_reg, $_rm

			# only for CALL instructions
			if ($_reg == 2 || $_reg == 3)
				# default offset
				set $noffset = 2
				if ($_mod == 0)
					if ($_rm == 6)
						# a 16bit address follows
						set $noffset = 4
					end
				else
					if ($_mod == 1)
						# a 8bit displacement follows
						set $noffset = 3
					else
						if ($_mod == 2)
							# 16bit displacement
							set $noffset = 4
						end
					end
				end
			end
			# end of _reg == 2 or _reg == 3

		else
			# else byte1 != 0xff
			if ($_byte1 == 0x9A)
				# call far
				set $noffset = 5
			else
				if ($_byte1 == 0xCD)
				# INTERRUPT CASE
					set $noffset = 2
				end
			end
		end
		# end of byte1 == 0xff
	end
	# else byte1 != 0xe8

	# if we have found a call to bypass we set a temporary breakpoint on next instruction and continue 
	if ($noffset != 0)
		set $_nextaddress = $eip + $offset + $noffset
		printf "Setting BP to %04X\n", $_nextaddress
		tbreak *$_nextaddress
		continue
		# else we just single step
	else
		nexti
	end
end
document nni
Next instruction over interrupts
This function will set a temporary breakpoint on next instruction after the call so the call will be bypassed.
You can safely use it instead of nexti since it will single step code if it's not a call instruction (unless you want to go into the call function)
end



### This is my version

python
class StepOverInterrupt(gdb.Command):
    def invoke(self, arg, from_tty):
        next_instr_byte = gdb.selected_inferior().read_memory(gdb.selected_frame().pc(), 2).tobytes()[0]
        if next_instr_byte in [0xcc, 0xcd, 0xce, 0xf1]:
            if next_instr_byte == 0xcd:
                gdb.execute( f"tbreak *{gdb.selected_frame().pc() + 2:#x}")
            else:
                gdb.execute( f"tbreak *{gdb.selected_frame().pc() + 1:#x}")
            gdb.execute( "continue")
        else:
            gdb.execute( "si")

StepOverInterrupt('isi', gdb.COMMAND_USER)
end
