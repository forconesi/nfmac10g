# Marco Forconesi

GEN_DIR ?= utils

.PHONY: clean sim

sim:
	# Test
	echo "Max throughput, no corrupted pkts, no underrun"
	make -s -C $(GEN_DIR) runsim SIMHDL=$(SIMHDL) SRCHDL=$(SRCHDL) PCAP=$(PCAP) IFG=0 CORR_LEVL=0 UNDERRUN=0
	# Test
	echo "Mid throughput, no corrupted pkts, no underrun"
	make -s -C $(GEN_DIR) runsim SIMHDL=$(SIMHDL) SRCHDL=$(SRCHDL) PCAP=$(PCAP) IFG=20 CORR_LEVL=0 UNDERRUN=0
	# Test
	echo "Max throughput, some corrupted pkts, no underrun"
	make -s -C $(GEN_DIR) runsim SIMHDL=$(SIMHDL) SRCHDL=$(SRCHDL) PCAP=$(PCAP) IFG=0 CORR_LEVL=1 UNDERRUN=0
	# Test
	echo "Max throughput, all pkts corrupted, no underrun"
	make -s -C $(GEN_DIR) runsim SIMHDL=$(SIMHDL) SRCHDL=$(SRCHDL) PCAP=$(PCAP) IFG=0 CORR_LEVL=2 UNDERRUN=0
	# Test
	echo "Max throughput, no corrupted pkts, explicit underrun"
	make -s -C $(GEN_DIR) runsim SIMHDL=$(SIMHDL) SRCHDL=$(SRCHDL) PCAP=$(PCAP) IFG=0 CORR_LEVL=0 UNDERRUN=1
	# Test
	echo "Max throughput, no corrupted pkts, implicit underrun"
	make -s -C $(GEN_DIR) runsim SIMHDL=$(SIMHDL) SRCHDL=$(SRCHDL) PCAP=$(PCAP) IFG=0 CORR_LEVL=0 UNDERRUN=2

clean:
	make -s -C $(GEN_DIR) clean
