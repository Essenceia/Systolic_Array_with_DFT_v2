# Simulation testbench 

Using both pure RTL and gate level simulation. 

Given the scan chain is added during implementation, we are 
adding gate level specific tests the scan chain. 

## Usage 

Run classic sim using icarus on raw verilog files: 
```
make
```

Use cvc with sdf file : 
```
make GATES=yes SIM=cvc
```

Use icarus with gate level netlist and pdk supplied timing models: 
```
make GATES=yes
```

Use icarus with gate level netlist and phony pdk cell library replacement (FPGA emulated gate level netlist): 
```
make GATES=yes PHONY_GATES=yes
```

Enable waves `WAVES=1`
```
make WAVES=1
```

## Gate level testing considerations 

Because of the implicit converstion of bfloat16 to the higher percision float32 
for calculation under the hood the simulator doesn't natively have a correct model 
of the bf16 operations. Given that the bf16 models have been thoughly tested in there
native repo this testbench is focused on testing the systolic array dataflow itseft and the 
JTAG. As such, the floating point unit is replaced by an unsigned integer unit for netlist
simulation. 

This swapping does not occure for gate level testing and the actually floating point 
results will be returned. As such, expect all systolic array test to fail for gate level 
sim. JTAG test should not fail. 


