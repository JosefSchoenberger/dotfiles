python
class StackLayout(gdb.Command):
    def invoke(self, arg, from_tty):
        max_depth = -1
        if len(arg) == 1:
            max_depth = int(arg[0])
        elif len(arg) != 0:
            print('stack_layout only takes up to one argument.\nUsage: stack_layout [<max-depth>]')
            return

        try:
            frame = gdb.selected_frame()
        except gdb.error:
            print('No frame selected. Is programm running?')
            return

        orig_frame = frame
        list_of_values = [] # all symbols found. Contains tuples: (name, address, size)
        while frame:
            if max_depth == 0:
                break
            max_depth -= 1;

            frame.select() # select so that 'info frame' chooses the correct frame
            sp = frame.read_register('sp')
            try:
                block = frame.block()
            except gdb.error:
                print('Could not get block of current frame. Maybe your code is optimized?');
                return

            while not block.is_static and not block.is_global:
                for symbol in block:
                    val = symbol.value(frame)
                    typ = val.type

                    if val.address:
                        if val.address < sp - 0x100000 or val.address > sp + 0x200: # 1 MiB below or 512 Bytes above
                            continue # This isn't on the stack. These are things like __PRETTY_FUNCTION__ etc.
                        list_of_values.append((symbol.name, int(val.address), typ.sizeof or 1))
                block = block.superblock
            # determine saved registers (which GDB doesn't expose via its Python API)
            try:
                info_frame = gdb.execute('info frame', False, True)
            except gdb.error:
                print('Could not create full trace. Is there a corrupted stack frame (perhaps a buffer overflow)?')
                break
            saved_registers = info_frame.find('\n Saved registers:\n  ')
            if saved_registers != -1:
                saved_registers = info_frame[saved_registers + 21:]
                for register_specification in saved_registers.split(','):
                    words = register_specification.strip().split(' ', 2)
                    if len(words) != 3 or words[1] != 'at':
                        break;
                    register = '$' + words[0].strip()
                    address = int(words[2].strip(), base=16)
                    list_of_values.append((register, address, 8)) # Assuming the register size is 8 Bytes
            frame = frame.older()
        orig_frame.select() # reselect original frame


        if len(list_of_values) == 0:
            print('No local variables on stack.');
            return

        list_of_values.sort(key=lambda t: t[1]) # Sort by address
        start = list_of_values[0][1]
        end = list_of_values[-1][1] + list_of_values[-1][2]

        stackframe = gdb.selected_inferior().read_memory(start, end - start).tobytes()
        offset_in_line = start & 0xf
        last_color = ''
        last_color_index = 0
        colors = ['31', '32', '33', '36', '35', '34']
        new_variables = []
        stop_underline_offset = -1
        for address, byte in enumerate(stackframe, start = start):
            if offset_in_line == stop_underline_offset:
                print('\x1b[24m', end='') # reset underline
                stop_underline_offset = -1


            if address == start and offset_in_line > 0: # stack is not 16-byte aligned
                print(f'{address&~0xf:12x}:', '   ' * offset_in_line + (' ' * (offset_in_line//8)), end='')
            elif offset_in_line == 0:
                print(f'{address:12x}: ', end = '')
            elif offset_in_line == 8:
                print(' ', end='')

            if address >= list_of_values[0][1] + list_of_values[0][2]:
                del list_of_values[0]
                last_color = ''

            if address < list_of_values[0][1]:
                print(f' {byte:02x}', end='')
            else:
                if last_color == '':
                    last_color = '\x1b[' + colors[last_color_index] + 'm'
                    last_color_index += 1
                    last_color_index %= len(colors)
                    new_variables.append((list_of_values[0][0], last_color))
                    if list_of_values[0][0] == '$rip': # assuming x86_64 here
                        print( '\x1b[4m', end=''); # start underline
                        stop_underline_offset = (offset_in_line + 8) % 16
                print(f'{last_color} {byte:02x}\x1b[39m', end='') #'\x1b[39m' = reset color

            offset_in_line += 1

            if offset_in_line == 16 or address == end - 1:
                print(' ', end='')
                for name, color in new_variables:
                    print( f' {color}{name}\x1b[39m', end='')
                new_variables = []
                print("\x1b[24m") # end underline
                offset_in_line = 0
        self.dont_repeat()

StackLayout('stack_layout', gdb.COMMAND_STACK)
end
