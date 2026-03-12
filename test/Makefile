# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# defaults
SIM ?= icarus
FST ?= -fst # Use more efficient FST format
TOPLEVEL_LANG ?= verilog
SRC_DIR = $(PWD)/../src
BF16_LIB_DIR = $(PWD)/../src/bf16/src
PROJECT_SOURCES = 

COMPILE_ARGS        += -DCOCOTB

ifneq ($(GATES),yes)

# RTL simulation:
SIM_BUILD	 	= sim_build/rtl
VERILOG_SOURCES += $(wildcard $(SRC_DIR)/*.v) $(wildcard $(BF16_LIB_DIR)/*.v)

else

# WHY ARE WE CALLING THE SIM CVC WHEN WE ARE USING CVC64 AAAAAAHHHH
SIM=cvc
# Gate level simulation:
SIM_BUILD		= sim_build/gl
COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DSIM
VERILOG_SOURCES += $(PDK_ROOT)/ihp-sg13g2/libs.ref/sg13g2_io/verilog/sg13g2_io.v
VERILOG_SOURCES += $(PDK_ROOT)/ihp-sg13g2/libs.ref/sg13g2_stdcell/verilog/sg13g2_stdcell.v

# lattest gate level netlist is to be placed in the artifact folder
VERILOG_SOURCES += ../final/tt_um_essen.nl.v

endif

# Allow sharing configuration between design and testbench via `include`
# no need to include bf16 lib since they are ommited from tb
COMPILE_ARGS 		+= -I$(SRC_DIR)

# Include the testbench sources:
VERILOG_SOURCES += $(PWD)/tb.v
TOPLEVEL = tb

# List test modules to run, separated by commas and without the .py suffix:
COCOTB_TEST_MODULES = test

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
