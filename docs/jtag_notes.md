# Wiring

Small reminder, this is why I allways wire up the `Vref` on the jlink : 
```
Info : VTarget = 0.000 V
```

It is because I always wire it jtag probe the wrong way around.

# ILA

Never forget the ila hates you and it will hide itself if you don't drive it's clock. 

# RP2040 tap

The rp2040 tap doesn't appear if you don't wire the Vref because the default power 
level selected by the JLINK is wrong.  
