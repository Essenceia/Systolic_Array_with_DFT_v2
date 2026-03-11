# Systollic Array with DFT v2 

Second iteration on the systollic array targetting IHP 180 nm 
open PDK, part of Tiny Tapeout shuttle `sky26a`.


## Improvements on v1 

- signed intergers upgraded to floating point math using `bfloat16`
- systollic array flops part of scan chain for debugging
- including denser SRAM memories using IHP macro
- higher clock frequency: max 100MHz target

### Floating point math 

This design will be including a from scratch custom implementation of the 
bfloat16 artithemtic optimized for performance and area. 

Given the nature of the workload and the additional cost of there support 
this implementation will not be supporting subnormals: all subnormals will be clamped to 0. 

[Link to bfloat repo](https://github.com/Essenceia/BFloat16)

## Dependancies

In order to add the DFT scan chain this project rellies on a custom version of librelane 
found [here](https://github.com/Essenceia/librelane) on branch `dft_scan_chain`. 

Then, since the scan chain is hooking up to an internal component and not top level I/O pins
and there was a small bug in the syntax of the output def file format produced by openROAD 
we must also run a different openROAD version than the default version used by librelane `3.0.0rc0`. 
Yet, because of a breaking change in openSTA, I have backported this def writer fix to a 
older version of openROAD. 
So now we have both a custom librelane and openROAD version. 

This custom openROAD can be found [here](https://github.com/Essenceia/OpenROAD) on branch `librelane_300rc0` and will be 
automatically used instead of the default version on nix shells. 
