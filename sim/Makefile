#
# Copyright (c) 2016 University of Cambridge All rights reserved.
#
# Author: Marco Forconesi
#
# This software was developed with the support of 
# Prof. Gustavo Sutter and Prof. Sergio Lopez-Buedo and
# University of Cambridge Computer Laboratory NetFPGA team.
#
# @NETFPGA_LICENSE_HEADER_START@
#
# Licensed to NetFPGA C.I.C. (NetFPGA) under one or more
# contributor license agreements.  See the NOTICE file distributed with this
# work for additional information regarding copyright ownership.  NetFPGA
# licenses this file to you under the NetFPGA Hardware-Software License,
# Version 1.0 (the "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at:
#
#   http://www.netfpga-cic.org
#
# Unless required by applicable law or agreed to in writing, Work distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations under the License.
#
# @NETFPGA_LICENSE_HEADER_END@

##############################################################################

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
