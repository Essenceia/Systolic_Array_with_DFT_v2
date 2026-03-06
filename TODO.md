# TODO 

## Workflow 

- [ ] ~Create a sub-macro containing all the systollic array: would make inserting the dft scan chain cleaner?~

## SWD 
Idea cancelled due to legal risk involved with designing a JTAG-AP over SWD ... I might mistakenly infringe on a pattent 

[x] Try to save on pins by wrapping the JTAG protocol behind SWD 
    - [x] look up how SWD works: is it a JTAG wrapper ? 
    - [x] learn protocol
    - [ ] ~implement~ 
    - [ ] ~update tb~
    - [ ] ~emulation validation~

## SRAM 

Find a use for the SRAM: do I actually want to integrate it ? 

Idea: output mirror buffer <- accessible over JTAG only
- [ ] setup SRAM as output mirror
- [ ] wire up MBIST to JTAG

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
- [ ] add scan chain test for gate sim mode
- [ ] MBIST 
	- [ ] add instruction
	- [ ] read up on expected operation 

### DFT

- [ ] update scan chain infra to IHP: scan cells 
- [ ] add ignore flop autotagging system to not insert a scan chain on the jtag architecture
- [ ] create librelane step to branch this into librelane flow, update to 3.0.0rc (extra testing for mole) 
- [ ] figure out tt lef autosubmit
- [ ] plug in custom librelane in place of tt librelane 

### FPGA emulation ?

This would require a custom synthesis to allow for more granular remapping of the scan chain to the synth
result ... No certain I want to invest the time ...

# CATS

- [ ] bogo cat
