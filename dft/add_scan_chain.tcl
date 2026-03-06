source utils.tcl 
source helper.tcl

set pdk_lib_path {/home/gp/.ciel/ciel/gf180mcu/versions/0fe599b2afb6708d281543108caf8310912f54af/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0}
set top_module tt_um_essen
set synth_verilog_path {/home/gp/asic/dft_fpga_emulation/runs/wokwi/06-yosys-synthesis}

 
read_lef $pdk_lib_path/techlef/gf180mcu_fd_sc_mcu7t5v0__nom.tlef
read_lef $pdk_lib_path/lef/gf180mcu_fd_sc_mcu7t5v0.lef
read_liberty $pdk_lib_path/lib/gf180mcu_fd_sc_mcu7t5v0__tt_025C_3v30.lib

read_verilog $synth_verilog_path/$top_module.nl.v
link_design $top_module

# add dummy clks 
create_clock -name main_clock -period 20.0000 -waveform {0.0000 10.0000} [get_ports {clk}]
create_clock -name jtag_clock -period 500.0000 -waveform {0.0000 250.0000} [get_ports {ui_in[0]}]


set_dft_config -max_chains 1 -clock_mixing clock_mix -scan_enable_name_pattern {m_sce_buff} -scan_in_name_pattern {m_sci_buff} -scan_out_name_pattern {m_sco_buff}  

add_scan_chain

set def_file [make_result_file scan_chain_inserted.def]
write_def $def_file

write_scan_chain_translate [make_result_file translation.csv] [odb::get_block]
