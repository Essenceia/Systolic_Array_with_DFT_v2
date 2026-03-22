# Firmware debug notes

## Sending data 

Debug in progress, sending weights and data ${ 0.0, 1.0 , 2.0 , 3.0 }$ encoded in bfloat16 : 
```
(gdb) p/u *data
$11 = {
  bf = {{
      m = 0,
      e = 0,
      s = 0
    }, {
      m = 0,
      e = 127,
      s = 0
    }, {
      m = 0,
      e = 128,
      s = 0
    }, {
      m = 64,
      e = 128,
      s = 0
    }},
  u = {0, 0, 128, 63, 0, 64, 64, 64}
}
```
Transfer is done over 8 cycles, pinouts for weight transfer : 
```
(gdb) p/u *p@pl
$14 = {{
    data_i = 0,
    res_o = 0,
    valid_i = 1,
    data_mode_i = 1,
    res_valid_o = 0,
    unusued = 0
  }, {
    data_i = 0,
    res_o = 0,
    valid_i = 1,
    data_mode_i = 1,
    res_valid_o = 0,
    unusued = 0
  }, {
    data_i = 128,
    res_o = 0,
    valid_i = 1,
    data_mode_i = 1,
    res_valid_o = 0,
    unusued = 0
  }, {
    data_i = 63,
    res_o = 0,
    valid_i = 1,
    data_mode_i = 1,
    res_valid_o = 0,
    unusued = 0
  }, {
    data_i = 0,
    res_o = 0,
    valid_i = 1,
    data_mode_i = 1,
    res_valid_o = 0,
    unusued = 0
  }, {
    data_i = 64,
    res_o = 0,
    valid_i = 1,
    data_mode_i = 1,
    res_valid_o = 0,
    unusued = 0
  }, {
    data_i = 64,
    res_o = 0,
    valid_i = 1,
    data_mode_i = 1,
    res_valid_o = 0,
    unusued = 0
  }, {
    data_i = 64,
    res_o = 0,
    valid_i = 1,
    data_mode_i = 1,
    res_valid_o = 0,
    unusued = 0
  }}
``

Validating correspondance, looking at second element: 
```
(gdb) p/x p[2]@2
$25 = {{
    data_i = 0x80,
    res_o = 0x0,
    valid_i = 0x1,
    data_mode_i = 0x1,
    res_valid_o = 0x0,
    unusued = 0x0
  }, {
    data_i = 0x3f,
    res_o = 0x0,
    valid_i = 0x1,
    data_mode_i = 0x1,
    res_valid_o = 0x0,
    unusued = 0x0
  }}
(gdb) p/x (uint16_t)data->bf[1]
$26 = 0x3f80
```

## It works

For a weight and input data matrix of `sent_data` we get the correct result received `res`.

```
(gdb) p/x sent_data
quit
$14 = {
  bf = {{
      m = 0x0,
      e = 0x0,
      s = 0x0
    }, {
      m = 0x0,
      e = 0x7f,
      s = 0x0
    }, {
      m = 0x0,
      e = 0x80,
      s = 0x0
    }, {
      m = 0x40,
      e = 0x80,
      s = 0x0
    }},
  u = {0x0, 0x0, 0x80, 0x3f, 0x0, 0x40, 0x40, 0x40}
}
(gdb) p/x res
$15 = {
  bf = {{
      m = 0x0,
      e = 0x80,
      s = 0x0
    }, {
      m = 0x40,
      e = 0x80,
      s = 0x0
    }, {
      m = 0x40,
      e = 0x81,
      s = 0x0
    }, {
      m = 0x30,
      e = 0x82,
      s = 0x0
    }},
  u = {0x0, 0x40, 0x40, 0x40, 0xc0, 0x40, 0x30, 0x41}
}
```

The rp2040 now has proper bfloat16 support, all that is left is to wait 8 months for the 
silicon to come back to install it :rofl:
