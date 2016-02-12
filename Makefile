# Marco Forconesi

SIM_DIR ?= $(PWD)/sim
SRC_DIR ?= $(PWD)/src

SIMHDL := $(SIM_DIR)/hdl
SRCHDL := $(SRC_DIR)/hdl

SIM_LOG := $(PWD)/sim_result.log

ifeq ($(PCAP),)
	pcapf := $(SIM_DIR)/all_rem.pcap
else
	pcapf := $(PWD)/$(PCAP)
endif

.PHONY: clean sim

sim: clean
	make -s -C $(SIM_DIR) sim SIMHDL=$(SIMHDL) SRCHDL=$(SRCHDL) PCAP=$(pcapf) LOG=$(SIM_LOG)

sim_no_xilinx: clean
	make -s -C $(SIM_DIR) loopback SIMHDL=$(SIMHDL) SRCHDL=$(SRCHDL) PCAP=$(pcapf) LOG=$(SIM_LOG)

clean:
	make -s -C $(SIM_DIR) clean SIMHDL=$(SIMHDL)
	rm -f $(SIM_LOG)
