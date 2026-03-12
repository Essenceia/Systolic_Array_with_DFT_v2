############
# Sim type #
############

# Define simulator we are using, priority to iverilog
SIM ?= verilator
$(info Using simulator: $(SIM))

###########
# Globals #
###########

# Global configs.
PROJET_NAME := tt_um_essen
FPGA_DIR := fpga
SW_DIR := firmware
TB_DIR := test
TV_DIR := tv
SRC_DIR := src
BF16_SRC_DIR := $(SRC_DIR)/bf16/src
CONF := conf
DEBUG_FLAG := $(if $(debug), debug=1)
DEFINES := $(if $(wave),wave=1)
WAIVER_FILE := waiver.vlt
FPGA_LIB:= lib
IMPLEM_DIR := final

.PHONY: firmware openocd gdb fpga fpga_prog lint lint_fpga tv test gates def

########
# Lint #
########

# Lint variables.
LINT_FLAGS :=
ifeq ($(SIM),icarus)
LINT_FLAGS +=-Wall -g2012 $(if $(assert),-gassertions) -gstrict-expr-width
LINT_FLAGS +=$(if $(debug),-DDEBUG) 
else
LINT_FLAGS += -Wall -Wpedantic -Wno-GENUNNAMED -Wno-LATCH -Wno-IMPLICIT
LINT_FLAGS += -Wno-DECLFILENAME
LINT_FLAGS +=$(if $(wip),-Wno-UNUSEDSIGNAL)
LINT_FLAGS += -Ilib
endif

# Lint commands.
ifeq ($(SIM),icarus)
define LINT
	mkdir -p build
	iverilog $(LINT_FLAGS) -s $2 -o $(BUILD_DIR)/$2 $1
endef
else
	
define LINT
	mkdir -p build
	verilator $(CONF)/$(WAIVER_FILE) --lint-only $(LINT_FLAGS) --no-timing $1 --top $2
endef
endif

########
# Lint #
########

entry_deps := $(wildcard $(SRC_DIR)/*.v) $(wildcard $(BF16_SRC_DIR)/*.v)
fpga_deps := $(entry_deps) $(wildcard $(FPGA_DIR)/*.v)

lint: $(entry_deps)
	$(call LINT,$^,$(PROJET_NAME))

lint_fpga: $(fpga_deps)
	$(call LINT,$^,emulator)


############################
# Implementation artifacts #
############################
# copy the result of the lattest librelane run results into the gate directory
# used for gate level simulation and debug tooling, will be tracked by git
LIBRELANE_RUN_PATH:=$(SRC_DIR)/runs
LIBRELANE_FINAL:=$(strip $(shell find $(LIBRELANE_RUN_PATH) -type d -name final | tail -n 1))

ifneq ($(LIBRELANE_FINAL),)
gates:
	cp $(LIBRELANE_FINAL)/nl/$(PROJET_NAME).nl.v $(IMPLEM_DIR)/.
	cp $(LIBRELANE_FINAL)/pnl/$(PROJET_NAME).pnl.v $(IMPLEM_DIR)/.
def:
	cp $(LIBRELANE_FINAL)/def/$(PROJET_NAME).def $(IMPLEM_DIR)/.
else
# don't have an implem run, not a machine on which I am running implementation
gates:
def:
endif

#############
# Testbench #
#############
# Call cocotb
test:
	COCOTB_LOG_LEVEL=$(if $(debug),DEBUG,INFO) $(MAKE) -C $(TB_DIR) $(if $(wave),WAVES=1) 

test_gates: gates
	COCOTB_LOG_LEVEL=$(if $(debug),DEBUG,INFO) GATES=yes $(MAKE) -C $(TB_DIR) $(if $(wave),WAVES=1) 


waves: 
	gtkwave $(TB_DIR)/tb.vcd $(CONF)/tb.gtkw &

###############
# Test vector #
###############
# Build and run test vector generation
tv:
	$(MAKE) -C $(TV_DIR) run

#############
# Firmware  #
#############
# Build RP2040 firmware
firmware:
	$(MAKE) -C $(SW_DIR) build

# start openocd, connect to RPi via JLink JTAG, start gdb server
openocd:
	$(MAKE) -C $(SW_DIR) debug

gdb:
	$(MAKE) -C $(SW_DIR) gdb

#############
# FPGA      # <- hand aligning these little boxes is a pain
#############
# Build vivado project and run PnR, not generating bitstream or flashing
fpga:
	$(MAKE) -C $(FPGA_DIR) build $(DEBUG_FLAG)

# Program the FPGA using a xilinx approved probe, no openocd config this time
fpga_prog:
	$(MAKE) -C $(FPGA_DIR) prog $(DEBUG_FLAG)

# Cleanup
clean:
	rm -f vgcore.* vgd.log*
	rm -f callgrind.out.*
	rm -fr build/*
	rm -fr obj_dir/*
	$(MAKE) -C $(TB_DIR) clean
	$(MAKE) -C $(FPGA_DIR) clean
	$(MAKE) -C $(SW_DIR) clean
