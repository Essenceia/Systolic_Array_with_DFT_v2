# Basys3 rev D xdc

# Switches
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {switch_i[0]}]
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {switch_i[1]}]

# LEDs
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[0]}]
set_property -dict { PACKAGE_PIN E19   IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[1]}]
set_property -dict { PACKAGE_PIN U19   IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[2]}]
set_property -dict { PACKAGE_PIN V19   IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[3]}]
set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[4]}]
set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[5]}]
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[6]}]
set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[7]}]
set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[8]}]
set_property -dict { PACKAGE_PIN V3    IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[9]}]
set_property -dict { PACKAGE_PIN W3    IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[10]}]
set_property -dict { PACKAGE_PIN U3    IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[11]}]
set_property -dict { PACKAGE_PIN P3    IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[12]}]
set_property -dict { PACKAGE_PIN N3    IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[13]}]
set_property -dict { PACKAGE_PIN P1    IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[14]}]
set_property -dict { PACKAGE_PIN L1    IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {led_o[15]}]

#Pmod Header JD - JADX
set_property -dict { PACKAGE_PIN J3   IOSTANDARD LVCMOS33  } [get_ports {data_i[0]}];
set_property -dict { PACKAGE_PIN L3   IOSTANDARD LVCMOS33  } [get_ports {data_i[1]}];
set_property -dict { PACKAGE_PIN M2   IOSTANDARD LVCMOS33  } [get_ports {data_i[2]}];
set_property -dict { PACKAGE_PIN N2   IOSTANDARD LVCMOS33  } [get_ports {data_i[3]}];
set_property -dict { PACKAGE_PIN K3   IOSTANDARD LVCMOS33  } [get_ports {data_i[4]}];
set_property -dict { PACKAGE_PIN M3   IOSTANDARD LVCMOS33  } [get_ports {data_i[5]}];
set_property -dict { PACKAGE_PIN M1   IOSTANDARD LVCMOS33  } [get_ports {data_i[6]}];
set_property -dict { PACKAGE_PIN N1   IOSTANDARD LVCMOS33  } [get_ports {data_i[7]}];

#Pmod Header JA
set_property -dict { PACKAGE_PIN J1   IOSTANDARD LVCMOS33 } [get_ports {res_o[0]}];
set_property -dict { PACKAGE_PIN L2   IOSTANDARD LVCMOS33 } [get_ports {res_o[1]}];
set_property -dict { PACKAGE_PIN J2   IOSTANDARD LVCMOS33 } [get_ports {res_o[2]}];
set_property -dict { PACKAGE_PIN G2   IOSTANDARD LVCMOS33 } [get_ports {res_o[3]}];
set_property -dict { PACKAGE_PIN H1   IOSTANDARD LVCMOS33 } [get_ports {res_o[4]}];
set_property -dict { PACKAGE_PIN K2   IOSTANDARD LVCMOS33 } [get_ports {res_o[5]}];
set_property -dict { PACKAGE_PIN H2   IOSTANDARD LVCMOS33 } [get_ports {res_o[6]}];
set_property -dict { PACKAGE_PIN G3   IOSTANDARD LVCMOS33 } [get_ports {res_o[7]}];

#Pmod Header JB
set_property -dict { PACKAGE_PIN A14   IOSTANDARD LVCMOS33  } [get_ports {data_v_i}];
set_property -dict { PACKAGE_PIN A16   IOSTANDARD LVCMOS33  } [get_ports {data_mode_i[0]}];
set_property -dict { PACKAGE_PIN B15   IOSTANDARD LVCMOS33  } [get_ports {data_mode_i[1]}];
set_property -dict { PACKAGE_PIN B16   IOSTANDARD LVCMOS33  } [get_ports {res_v_o}];

# Pmod Header JC
# jtag
set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33  } [get_ports {tdi_i}];
set_property -dict { PACKAGE_PIN M18  IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {tck_i}];
create_clock -add -name tck_i -period 500.00 [get_ports tck_i]
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33  } [get_ports {tms_i}];
set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33  } [get_ports {tdo_o}];
# clk 
set_property -dict { PACKAGE_PIN L17  IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports {clk_bus_i}];
create_clock -add -name clk_bus_i -period 50.00 [get_ports clk_bus_i]

# tie unused pins
set_property -dict { PACKAGE_PIN W7   IOSTANDARD LVCMOS33 } [get_ports {unused_o[0]}]
set_property -dict { PACKAGE_PIN W6   IOSTANDARD LVCMOS33 } [get_ports {unused_o[1]}]
set_property -dict { PACKAGE_PIN U8   IOSTANDARD LVCMOS33 } [get_ports {unused_o[2]}]
set_property -dict { PACKAGE_PIN V8   IOSTANDARD LVCMOS33 } [get_ports {unused_o[3]}]
set_property -dict { PACKAGE_PIN U5   IOSTANDARD LVCMOS33 } [get_ports {unused_o[4]}]
set_property -dict { PACKAGE_PIN V5   IOSTANDARD LVCMOS33 } [get_ports {unused_o[5]}]
set_property -dict { PACKAGE_PIN U7   IOSTANDARD LVCMOS33 } [get_ports {unused_o[6]}]
set_property -dict { PACKAGE_PIN V7   IOSTANDARD LVCMOS33 } [get_ports {unused_o[7]}]
set_property -dict { PACKAGE_PIN U2   IOSTANDARD LVCMOS33 } [get_ports {unused_o[8]}]
set_property -dict { PACKAGE_PIN U4   IOSTANDARD LVCMOS33 } [get_ports {unused_o[9]}]
set_property -dict { PACKAGE_PIN V4   IOSTANDARD LVCMOS33 } [get_ports {unused_o[10]}]
set_property -dict { PACKAGE_PIN W4   IOSTANDARD LVCMOS33 } [get_ports {unused_o[11]}]

## Configuration options, can be used for all designs
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

## SPI configuration mode options for QSPI boot, can be used for all designs
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

# set data delays
# assuming clk and data are affected by the same delay 
# IOVDD at 3,3V according to the RP2040 datashete electrical 
# characteristics of the pinnout, adding a bit extra for safety
set_input_delay -clock [get_clocks clk_bus_i] -min 0.0 [get_ports -regexp data_.*]
set_input_delay -clock [get_clocks clk_bus_i] -max 11.2 [get_ports -regexp data_.*]

set_output_delay -clock [get_clocks clk_bus_i] -min -1.0 [get_ports -regexp res.*]
set_output_delay -clock [get_clocks clk_bus_i] -max 5.5 [get_ports -regexp res.*]
