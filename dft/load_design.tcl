puts "Loading libs" 
 
read_liberty $::env(STDCELL_LIB_PATH)/lib/sg13g2_stdcell_typ_1p20V_25C.lib
read_lef $::env(STDCELL_LIB_PATH)/lef/sg13g2_tech.lef
read_lef $::env(STDCELL_LIB_PATH)/lef/sg13g2_stdcell.lef

puts "Reading design" 

read_verilog $::env(SYNTH_VERILOG_PATH)/$::env(TOP_MODULE).nl.v
link_design $::env(TOP_MODULE)
