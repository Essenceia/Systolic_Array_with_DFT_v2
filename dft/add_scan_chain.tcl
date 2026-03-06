source utils.tcl 
source helper.tcl

puts "Loading libs" 
 
read_liberty $::env(STDCELL_LIB_PATH)/lib/sg13g2_stdcell_typ_1p20V_25C.lib
read_lef $::env(STDCELL_LIB_PATH)/lef/sg13g2_tech.lef
read_lef $::env(STDCELL_LIB_PATH)/lef/sg13g2_stdcell.lef

puts "Reading design" 

read_verilog $::env(SYNTH_VERILOG_PATH)/$::env(TOP_MODULE).nl.v
link_design $::env(TOP_MODULE)

# add dummy clks 
puts "Adding clks" 
set jtag_clk_name "jtag_clock"
create_clock -name main_clock -period 10.0000 -waveform {0.0000 5.0000} [get_ports {clk}]
create_clock -name $jtag_clk_name -period 500.0000 -waveform {0.0000 250.0000} [get_ports {ui_in[0]}]

set_dft_config -max_chains 1 -clock_mixing no_mix \
-scan_enable_name_pattern {m_sce_buff} \
-scan_in_name_pattern {m_sci_buff} \
-scan_out_name_pattern {m_sco_buff}  

set existing_dont_touch [report_dont_touch]

# set don't touch on everything connected to jtag clk since it will be used
# to driver dft ff verif
set jtag_clk [get_clock $jtag_clk_name] 
exclude_from_scan_chain $jtag_clk

add_scan_chain

# cleanup dont touch to allow optimizations of implem
cleanup_dont_touch $jtag_clk

# check cleaned dont touch matches existing dont touch 
# if these don't match this means we might be removing some
# explicitly set dont touch we actually wanted to keep
set cleaned_dont_touch [report_dont_touch] 
if { $existing_dont_touch != $cleaned_dont_touch } {
	utl::error ADD_SCAN_CHAIN_TCL 1 "Custom error, dont touch list after cleanup doesnt match expected. Likely error in cleanup" 
}

set def_file [make_result_file scan_chain_inserted.def]
write_def $def_file

write_scan_chain_translate [make_result_file translation.csv] [odb::get_block]
