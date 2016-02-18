# Marco Forconesi

GEN_DIR ?= utils
clean_vivado := XilMacPrj*

sep := "//////////////////"

.PHONY: clean sim loopback interoperability

sim: loopback interoperability

loopback:
	echo "$(sep)\nLoopback on XGMII interfaces\n$(sep)" >> $(LOG)
	make -s -C $(GEN_DIR) siminst SIMHDL=$(SIMHDL) SRCHDL=$(SRCHDL) PCAP=$(PCAP) TEST=loopback LOG=$(LOG)

interoperability:
	echo "create Xilinx ten_gig_eth_mac core"
	vivado -nojou -nolog -mode batch -source genip_xilinx_mac.tcl -tclargs $(SIMHDL)
	make -s clean_vivado
	echo "\n\n$(sep)\nnfmac.Tx -> xilinx_mac.Rx\n$(sep)" >> $(LOG)
	make -s -C $(GEN_DIR) siminst SIMHDL=$(SIMHDL) SRCHDL=$(SRCHDL) PCAP=$(PCAP) TEST=nf2xil LOG=$(LOG)
	echo "xilinx_mac Tx -> nfmac Rx" >> $(LOG)
	echo "\n\n$(sep)\nxilinx_mac.Tx -> nfmac.Rx\n$(sep)" >> $(LOG)
	make -s -C $(GEN_DIR) siminst SIMHDL=$(SIMHDL) SRCHDL=$(SRCHDL) PCAP=$(PCAP) TEST=xil2nf LOG=$(LOG)

sim_usr_intf:
	echo "$(sep)\nLoopback on AXIS interfaces\n$(sep)" >> $(LOG)
	make -s -C $(GEN_DIR) sim_usr_intf SIMHDL=$(SIMHDL) SRCHDL=$(SRCHDL) USR_INTF_SRCHDL=$(USR_INTF_SRCHDL) PCAP=$(PCAP) TEST=axis_loopback LOG=$(LOG)

clean_vivado:
	rm -rf $(clean_vivado)

clean: clean_vivado
	make -s -C $(GEN_DIR) clean
	rm -rf $(SIMHDL)/xilinx* $(SIMHDL)/ten_gig_eth_mac*
