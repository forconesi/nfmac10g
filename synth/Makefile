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

.PHONY: clean synth

synth:
	vivado -nojou -nolog -mode batch -source synth.tcl -tclargs $(SRCHDL) $(SRCXDC)
	cat report_utilization.log  | grep -B 1 -A 10 '|        Site Type        | Used | Fixed | Available | Util% |'
	cat report_timing_summary.log | grep -B 2 -A 6 'From Clock:  tx_clk0'

clean:
	rm -rf *.log .Xil