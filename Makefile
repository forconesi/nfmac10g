# Marco Forconesi

SIM_DIR ?= $(PWD)/sim
SRC_DIR ?= $(PWD)/src
SYNTH_DIR ?= $(PWD)/synth

SIMHDL := $(SIM_DIR)/hdl
SRCHDL := $(SRC_DIR)/hdl
SRCXDC := $(SRC_DIR)/xdc

SIM_LOG := $(PWD)/sim_result.log

ifeq ($(PCAP),)
	pcapf := $(SIM_DIR)/all_rem.pcap
else
	pcapf := $(PWD)/$(PCAP)
endif

.PHONY: clean sim synth

sim: clean
	make -s -C $(SIM_DIR) sim SIMHDL=$(SIMHDL) SRCHDL=$(SRCHDL) PCAP=$(pcapf) LOG=$(SIM_LOG)

sim_no_xilinx: clean
	make -s -C $(SIM_DIR) loopback SIMHDL=$(SIMHDL) SRCHDL=$(SRCHDL) PCAP=$(pcapf) LOG=$(SIM_LOG)

synth:
	make -s -C $(SYNTH_DIR) synth SRCHDL=$(SRCHDL) SRCXDC=$(SRCXDC)

clean:
	make -s -C $(SIM_DIR) clean SIMHDL=$(SIMHDL)
	make -s -C $(SYNTH_DIR) clean
	rm -f $(SIM_LOG)
