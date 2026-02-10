# Systollic Array with DFT v2 

Second iteration on the systollic array targetting IHP 180 nm 
open PDK, part of Tiny Tapeout shuttle `sky26a`.


## Planned improvements on v1 

- signed intergers upgraded to floating point math using `bfloat16`
- systollic array flops part of scan chain for debugging
- including denser SRAM memories using IHP macro


### Floating point math 

This design will be including a from scratch custom implementation of the 
bfloat16 artithemtic optimized for performance and area. 

Given the nature of the workload and the additional cost of there support 
this implementation will not be supporting subnormals: all subnormals will be clamped to 0. 

[Link to bfloat repo](https://github.com/Essenceia/BFloat16)


