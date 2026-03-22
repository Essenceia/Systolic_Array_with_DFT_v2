import gdb
import gdb.prompt
import gdb.command.prompt

#########
# Setup #
#########

gdb.execute("""
    define hook-quit
        set confirm off
    end
""")


gdb.execute('''
# Show context.
define ctx
	x/20i $pc
	info reg
	f
	info args
	info locals
end
''')

gdb.execute("set pagination off")

gdb.execute("set print pretty yes")

#############################
# Define-like command class #
#############################

class cmd_def(gdb.Command):
    cmds = []
    def __init__(self, path, cmds):
        super(cmd_def, self).__init__(path, gdb.COMMAND_SUPPORT)
        if type(cmds) is list:
            self.cmds = cmds 
        elif type(cmds) is str:
            self.cmds = [cmds]
        else:
            assert 0, "list or string expected."

    def invoke(self, arg_str, from_tty):
        for x in self.cmds:
            gdb.execute(x)

##############
# Log buffer #
##############

class ns_log_cmd(gdb.Command):
    """Write a command."""
    def __init__(self):
        super(ns_log_cmd, self).__init__("ns log", gdb.COMMAND_DATA, gdb.COMMAND_NONE, True)
    def invoke(self, arg_str, from_tty):
        print(gdb.parse_and_eval("_" + arg_str + "_buf").string(), end="")

################
# Reg database #
################

global reg_mods
global reg_ists

# Register modules : {name : {reg_name : (off, size, {fld_name : (bit_start, bit_size)})}}
reg_mods = {};

# Module instances : {name : (module, addr, size)}
reg_ists = {};

#####################
# Register decoding #
#####################

# List blocks.
class ns_dec_lsblk_cmd(gdb.Command):
    """List available blocks."""
    def __init__(self):
        super(ns_dec_lsblk_cmd, self).__init__("ns dec lsblk", gdb.COMMAND_DATA, gdb.COMMAND_NONE, True)
    def invoke(self, arg_str, from_tty):
        l = [x for x in sorted(reg_ists.keys()) if x.startswith(arg_str)];
        if len(l) == 0:
            print("No matching blocks.")
            return
        print("Available blocks :");
        for x in l:
            blk = reg_ists[x];
            print("- " + x + " : " + blk[0] + " : (" + hex(blk[1]) + ", " + hex(blk[2]) + ")");


# List blocks.
class ns_dec_lsreg_cmd(gdb.Command):
    """List available registers of a block."""
    def __init__(self):
        super(ns_dec_lsreg_cmd, self).__init__("ns dec lsreg", gdb.COMMAND_DATA, gdb.COMMAND_NONE, True)
    def invoke(self, arg_str, from_tty):

        # Red args.
        args = arg_str.split(" ");
        print(args)
        if (len(args) < 1):
            print("Usage : ns dec lsreg [blk] [reg]")
            return
        blk_nam = args[0]
        reg_nam = args[1] if len(args) >= 2 else ""
        
        # Find the block.
        if blk_nam not in reg_ists.keys():
            print("block " + blk_nam + " not found.")
            return
        blk = reg_ists[blk_nam]

        # Find the module.
        mod_nam = blk[0];
        if mod_nam not in reg_mods.keys():
            print("module " + mod_nam + " not found.")
            return
        mod = reg_mods[mod_nam]
      
        # Find matching registers.
        l = [x for x in sorted(mod.keys()) if x.startswith(reg_nam)];
        if len(l) == 0:
            print("No matching registers.")
            return
        print("Available registers :");
        for x in l:
            reg = mod[x];
            print("- " + blk_nam + "." + x + " : " + blk[0] + " : " + hex(blk[1] + reg[0]));

# Print the decoded content of a register.
def _reg_dec(blk, mod, reg, blk_nam, reg_nam, reg_bin):

    size = reg[1]
    if size not in [8, 16, 32, 64]:
        print("Invalid size " + str(size) + ", expected 8, 16, 32 or 64.")
        return;

    # Read memory.
    if reg_bin is None:
        print("Decoding {}.{} from memory.".format(blk_nam, reg_nam))
        reg_bin = int(gdb.parse_and_eval("*(uint" + str(size) + "_t *) " + hex(blk[1] + reg[0])))
    else:
        print(("Decoding {}.{} with value {:0"+str(int(size / 4)) +"x}").format(blk_nam, reg_nam, reg_bin))
    print(("{}.{} (0x{:x}) : 0x{:0"+str(int(size / 4)) + "x}").format(blk_nam, reg_nam, blk[1] + reg[0], reg_bin))

    binary = True

    if binary:
        d = {reg[2][fld_nam][0] : fld_nam for fld_nam in reg[2].keys()}
        offs = sorted(d.keys())
        strs = []
        base_len = 0
        for off in offs:
            fld = reg[2][d[off]]
            base = "{}.{} [{},{}]".format(reg_nam, d[off], fld[0] + fld[1] - 1, fld[0])
            strs += [base];
            base_len = max(len(base), base_len)


        # Decode fields.
        head = str(reg_nam) + (" " * (base_len - len(reg_nam))) + " : " + ("{:0"+str(size) +"b}").format(reg_bin) + " : " + hex(reg_bin) + " : " + str(reg_bin) 
        print(head);
        i = 0
        for off in offs:
            fld = reg[2][d[off]]
            bit_min = fld[0]
            bit_max = fld[1] + fld[0]
            msk = (1 << fld[1]) - 1;
            val = (reg_bin >> fld[0]) & msk;
            ns_str_min = "-" * bit_min
            ns_str_max = "-" * (size - bit_max)
            strs[i] += (" " * (base_len - len(strs[i]))) + " : " + ns_str_max + ("{:0"+str(fld[1]) + "b}").format(val) + ns_str_min + " : " + hex(val) + " : " + str(val)
            i+=1

        strs.reverse()
        for i in range(len(strs)):
            print(strs[i])

    else: 

        # Decode fields.
        for fld_nam in reg[2].keys():
            fld = reg[2][fld_nam]
            msk = (1 << fld[1]) - 1;
            val = (reg_bin >> fld[0]) & msk;
            print("- {} ({},{}) : {:b}".format(fld_nam, fld[0], fld[1], val))


# Decode a register.
class ns_dec_reg_cmd(gdb.Command):
    """Decode a register."""
    def __init__(self):
        super(ns_dec_reg_cmd, self).__init__("ns dec reg", gdb.COMMAND_DATA, gdb.COMMAND_NONE, True)
    def invoke(self, arg_str, from_tty):

        # Red args.
        args = arg_str.split(" ");
        if (len(args) < 2):
            print("Usage : ns dec reg [blk] [reg] [val]")
            return
        blk_nam = args[0]
        reg_nam = args[1]
        reg_bin = int(args[2], 0) if len(args) >= 3 else None
        
        # Find the block.
        if blk_nam not in reg_ists.keys():
            print("block " + blk_nam + " not found.")
            return
        blk = reg_ists[blk_nam]

        # Find the module.
        mod_nam = blk[0];
        if mod_nam not in reg_mods.keys():
            print("module " + mod_nam + " not found.")
            return
        mod = reg_mods[mod_nam]

        # Find the register.
        if reg_nam not in mod.keys():
            print("register " + reg_nam + " not found.")
            return
        reg = mod[reg_nam]
     
        # Decode the register.
        _reg_dec(blk, mod, reg, blk_nam, reg_nam, reg_bin)
        return
        
class ns_dec_cmd(gdb.Command):
    """ns register decoding utilities."""
    def __init__(self):
        super(ns_dec_cmd, self).__init__("ns dec", gdb.COMMAND_DATA, gdb.COMMAND_NONE, True)


######
# Ns #
######

class ns_cmd(gdb.Command):
    """ns debug utilities."""
    def __init__(self):
        super(ns_cmd, self).__init__("ns", gdb.COMMAND_DATA, gdb.COMMAND_NONE, True)

############
# Commands #
############

ns_cmd()
ns_log_cmd()

ns_dec_cmd()
ns_dec_reg_cmd()
ns_dec_lsblk_cmd()
ns_dec_lsreg_cmd()

cmd_def("si", ["stepi", "ctx"])
cmd_def("fin", ["finish", "ctx"])
cmd_def("cnt", ["continue", "ctx"])
