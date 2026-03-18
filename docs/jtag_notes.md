# Debug notes 

## Wiring

Small reminder, this is why I allways wire up the `Vref` on the jlink : 
```
Info : VTarget = 0.000 V
```

It is because I always wire it jtag probe the wrong way around.

## ILA

Never forget the ila hates you and it will hide itself if you don't drive it's clock. 

## RP2040 tap

The rp2040 tap doesn't appear if you don't wire the Vref because the default power 
level selected by the JLINK is wrong.  

# Custom TAP 

## Logs

Logs of a working TAP post reset on FPGA (dff rst to '0 on FPGA):

```
Open On-Chip Debugger 0.12.0+dev-02429-ge4c49d860 (2026-03-17-19:44)
Licensed under GNU GPL v2
For bug reports, read
	http://openocd.org/doc/doxygen/bugs.html
Info : J-Link V10 compiled Jan 30 2023 11:28:07
Info : Hardware version: 10.10
Info : VTarget = 3.348 V
Info : clock speed 2000 kHz
Info : JTAG tap: tpu.tap tap/device found: 0x2beef0d7 (mfg: 0x06b (Transwitch), part: 0xbeef, ver: 0x2)
Warn : gdb services need one or more targets defined
idcode : 2beef0d7
read internal register 0:0 : 0x0000 - weight
read internal register 0:1 : 0x0000 - multiplicand ( input data )
read internal register 0:2 : 0x0000 - summand ( input data )
read internal register 0:3 : 0x0000 - multiplication result (internal computation)
read internal register 1:0 : 0x0000 - weight
read internal register 1:1 : 0x0000 - multiplicand ( input data )
read internal register 1:2 : 0x0000 - summand ( input data )
read internal register 1:3 : 0x0000 - multiplication result (internal computation)
read internal register 2:0 : 0x0000 - weight
read internal register 2:1 : 0x0000 - multiplicand ( input data )
read internal register 2:2 : 0x0000 - summand ( input data )
read internal register 2:3 : 0x0000 - multiplication result (internal computation)
read internal register 3:0 : 0x0000 - weight
read internal register 3:1 : 0x0000 - multiplicand ( input data )
read internal register 3:2 : 0x0000 - summand ( input data )
read internal register 3:3 : 0x0000 - multiplication result (internal computation)
Info : Listening on port 6666 for tcl connections
Info : Listening on port 4444 for telnet connections
``` 
