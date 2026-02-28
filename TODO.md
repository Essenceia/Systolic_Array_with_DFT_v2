# TODO 

## Workflow 

[ ] Create a sub-macro containing all the systollic array: would make inserting the dft scan chain cleaner

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

### output data fifo ?

Would help fix my MCU handshaking problem/lack of pins, by guarantying a gapless 
stream of responses. 
But using an SRAM for this is totally overkill: they are too large to be a good 
replacement for a 64b of ff storage. 

So I should just add the ff bank, still no use for the SRAM though.   

## Desing

- [ ] cleanup MAC FSM 
    - [ ] rework output fifo and make it bank based to output only a continous data stream 
