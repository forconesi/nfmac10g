# Marco Forconesi

SIM_DIR ?= $(PWD)/sim
SRC_DIR ?= $(PWD)/src

SIMHDL := $(SIM_DIR)/hdl
SRCHDL := $(SRC_DIR)/hdl

ifeq ($(PCAP),)
	PCAP := $(SIM_DIR)/all_rem.pcap
endif

.PHONY: clean sim

sim:
	make -s -C $(SIM_DIR) sim SIMHDL=$(SIMHDL) SRCHDL=$(SRCHDL) PCAP=$(PCAP)

clean:
	make -s -C $(SIM_DIR) clean
