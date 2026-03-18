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

HOSTNAME=$(shell hostname)
$(info $(HOSTNAME)) 
ifeq ($(HOSTNAME),superpitchu)
PDK_ROOT=/home/$(USER)/rtl/pdk/IHP-Open-PDK/
endif

ifneq ($(GATES),yes)

# RTL simulation:
SIM_BUILD	 	= sim_build/rtl
VERILOG_SOURCES += $(wildcard $(SRC_DIR)/*.v) $(wildcard $(BF16_LIB_DIR)/*.v)

else
# Gate level simulation:
SIM_BUILD		= sim_build/gl_cvc
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DSIM

ifeq ($(PHONY_GATES),yes)
VERILOG_SOURCES +=$(PWD)/../lib/sg13g2_stdcell_phony.v
else
VERILOG_SOURCES += $(PDK_ROOT)/ihp-sg13g2/libs.ref/sg13g2_stdcell/verilog/sg13g2_stdcell.v
endif

VERILOG_SOURCES += ../final/tt_um_essen.nl.v
ifeq ($(SIM),cvc)
# WHY ARE WE CALLING THE SIM CVC WHEN WE ARE USING CVC64 AAAAAAHHHH
SIM_BUILD		= sim_build/gl_cvc
COMPILE_ARGS    += -DSDF
else
SIM_BUILD		= sim_build/gl
endif
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
