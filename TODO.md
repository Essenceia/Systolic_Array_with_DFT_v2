# TODO 

## Workflow 

- [x] ~Create a sub-macro containing all the systollic array: would make inserting the dft scan chain cleaner?~

## SWD 
Idea cancelled due to legal risk involved with designing a JTAG-AP over SWD ... I might mistakenly infringe on a pattent 

[x] Try to save on pins by wrapping the JTAG protocol behind SWD 
    - [x] look up how SWD works: is it a JTAG wrapper ? 
    - [x] learn protocol
    - [x] ~implement~ 
    - [x] ~update tb~
    - [x] ~emulation validation~

## SRAM 

Find a use for the SRAM: do I actually want to integrate it ? 

Idea: output mirror buffer <- accessible over JTAG only
- [x] setup SRAM as output mirror
- [x] wire up MBIST to JTAG

### output data fifo ?

Would help fix my MCU handshaking problem/lack of pins, by guarantying a gapless 
stream of responses. 
But using an SRAM for this is totally overkill: they are too large to be a good 
replacement for a 64b of ff storage. 

So I should just add the ff bank, still no use for the SRAM though.   

## Desing

- [x] cleanup MAC FSM 
- [x] rework output fifo and make it bank based to output only a continous data stream 

## JTAG

- [x] add scan chain interface
- [x] add scan chain test for gate sim mode
	- [x] add sim for jtag scan chain scan 
	- [x] add mock when not using gate level netlist
	- [x] pass scan chain length to python, depending on if we are using the mock or the actual gate level netlist
- [x] MBIST 
	- [x] add instruction
	- [x] read up on expected operation 
- [ ] update openocd script 
	- [ ] include scan chain scan 

### DFT

- [x] update scan chain infra to IHP: scan cells 
- [x] add ignore flop autotagging system to not insert a scan chain on the jtag architecture
- [x] create librelane step to branch this into librelane flow, update to 3.0.0rc (extra testing for mole) 
- [x] figure out tt lef autosubmit
- [x] ~plug in custom librelane in place of tt librelane~ not possible, they use the python librelane lib

### FPGA emulation ?

This would require a custom synthesis to allow for more granular remapping of the scan chain to the synth
result ... No certain I want to invest the time ...

Solution: emulate gate level netlist

- [x] create phony gate library 
- [x] add gate netlist emulation `gates=1` build flag

Scan scan chain netlist: checking netlist integrity 
- [x] created `dft_explorer.tcl` script 
	- [x] confirmed full scan chain present in netlist

## CATS

- [ ] bogo cat

## Firmware 

- [ ] double check firmware 

## Submission 

- [ ] update doc 
- [ ] create phony submission to setup tiles, no scan chain
- [ ] open manual PR with updated gds/lef/nl using custom flow 
