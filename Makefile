# Marco Forconesi

SIM_DIR ?= $(PWD)/sim
SRC_DIR ?= $(PWD)/src
SYNTH_DIR ?= $(PWD)/synth
USR_INTF_DIR ?= $(PWD)/usr_intf

SIMHDL := $(SIM_DIR)/hdl
SRCHDL := $(SRC_DIR)/hdl
SRCXDC := $(SRC_DIR)/xdc
USR_INTF_SRCHDL := $(USR_INTF_DIR)/src/hdl

SIM_LOG := $(PWD)/sim_result.log
USR_INTF_SIM_LOG := $(PWD)/usr_intf_result.log

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

sim_usr_intf: clean
	make -s -C $(SIM_DIR) sim_usr_intf SIMHDL=$(SIMHDL) SRCHDL=$(SRCHDL) USR_INTF_SRCHDL=$(USR_INTF_SRCHDL) PCAP=$(pcapf) LOG=$(USR_INTF_SIM_LOG)

synth:
	make -s -C $(SYNTH_DIR) synth SRCHDL=$(SRCHDL) SRCXDC=$(SRCXDC)

clean:
	make -s -C $(SIM_DIR) clean SIMHDL=$(SIMHDL)
	make -s -C $(SYNTH_DIR) clean
	rm -f $(SIM_LOG) $(USR_INTF_SIM_LOG)
