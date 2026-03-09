SYNTH_VERILOG_PATH:=../src/runs/$(shell ls ../src/runs/ | sort | tail -n 1)/06-yosys-synthesis
TOP_MODULE:=tt_um_essen

PDK_PATH:=/home/gp/.ciel/ciel/ihp-sg13g2/versions/c4b8b4e5e7a05f375cca3815d51b3a37721fbf5c/ihp-sg13g2
STDCELL_LIB_PATH:=$(PDK_PATH)/libs.ref/sg13g2_stdcell

run: 
	SYNTH_VERILOG_PATH=$(SYNTH_VERILOG_PATH) TOP_MODULE=$(TOP_MODULE) STDCELL_LIB_PATH=$(STDCELL_LIB_PATH) openroad add_scan_chain.tcl

load:
	SYNTH_VERILOG_PATH=$(SYNTH_VERILOG_PATH) TOP_MODULE=$(TOP_MODULE) STDCELL_LIB_PATH=$(STDCELL_LIB_PATH) openroad load_design.tcl
