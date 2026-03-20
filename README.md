# Systollic Array with DFT v2 

Second iteration on the systollic array targetting IHP 180 nm 
open PDK. 


## Improvements on v1 

[Link to v1, tapedout on GlobalFoundary 180nm, part of Tiny Tapeout experimental shuttle `gf0p2`](https://github.com/Essenceia/Systolic_MAC_with_DFT)

- signed intergers upgraded to floating point math using `bfloat16`
- systollic array flops part of scan chain for debugging
- higher clock frequency: max 100MHz target

### Floating point math 

This design will be including a from scratch custom implementation of the 
bfloat16 artithemtic optimized for performance and area. 

This implementation leverages the fact there is no official standard outlining the 
behavior of `bfloat16` to implement only the subset of floating point behavior 
that I judge to be neccessary for our workload in favor of higher performance at 
a low area budget. 

These choices are : 
- round toward zero rounding only
- no subnormal support, all subnormals will be clamped to 0
- no $\pm \infty$ or $NaN$ support

For more information refer to the [bfloat repository](https://github.com/Essenceia/BFloat16)

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
