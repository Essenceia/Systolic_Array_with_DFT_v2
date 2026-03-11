# JTAG TAP 

Custom openOCD scripts to interact with accelerator over JTAG. 


## OpenOCD low level JTAG commands


**Command: drscan tap [numbits value]+ [-endstate tap\_state]**

Loads the data register of tap with a series of bit fields that specify the entire register. Each field is numbits bits long with a numeric value (hexadecimal encouraged). The return value holds the original value of each of those fields.

For example, a 38 bit number might be specified as one field of 32 bits then one of 6 bits. For portability, never pass fields which are more than 32 bits long. Many OpenOCD implementations do not support 64-bit (or larger) integer values.

All TAPs other than tap must be in BYPASS mode. The single bit in their data registers does not matter.

When tap\_state is specified, the JTAG state machine is left in that state. For example DRPAUSE might be specified, so that more instructions can be issued before re-entering the RUN/IDLE state. If the end state is not specified, the RUN/IDLE state is entered.

> Warning: OpenOCD does not record information about data register lengths, so it is important that you get the bit field lengths right. Remember that different JTAG instructions refer to different data registers, which may have different lengths. Moreover, those lengths may not be fixed; the SCAN\_N instruction can change the length of the register accessed by the INTEST instruction (by connecting a different scan chain). 

**Command: irscan [tap instruction]+ [-endstate tap\_state]**

For each tap listed, loads the instruction register with its associated numeric instruction. (The number of bits in that instruction may be displayed using the scan\_chain command.) For other TAPs, a BYPASS instruction is loaded.

When tap\_state is specified, the JTAG state machine is left in that state. For example IRPAUSE might be specified, so the data register can be loaded before re-entering the RUN/IDLE state. If the end state is not specified, the RUN/IDLE state is entered.

>  Note: OpenOCD currently supports only a single field for instruction register values, unlike data register values. For TAPs where the instruction register length is more than 32 bits, portable scripts currently must issue only BYPASS instructions. 


source : [Low level openOCD JTAG commands](https://openocd.org/doc-release/html/JTAG-Commands.html)
