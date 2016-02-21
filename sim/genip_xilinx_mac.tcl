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

set prj_name XilMacPrj

create_project -part xc7vx690tffg1761-3 $prj_name -force
create_ip -vlnv xilinx.com:ip:ten_gig_eth_mac:15.0 -module_name xilinx_mac
set_property CONFIG.Management_Interface false [get_ips xilinx_mac]
#report_property [get_ips xilinx_mac]
generate_target -force simulation [get_ips]

#puts "path to cpy files $argv"
# Xilinx can move generated files location with future version of the core
# Please set the new corrected path if it fails
set src_files [glob -dir $prj_name.srcs/sources_1/ip/xilinx_mac/synth/ *.v]
set src_files "$src_files [glob -dir $prj_name.srcs/sources_1/ip/xilinx_mac/ten_gig_eth_mac_v15_0/hdl/ *.v]"
set src_files "$src_files [glob -dir $prj_name.srcs/sources_1/ip/xilinx_mac/ten_gig_eth_mac_v15_0_3/hdl/ *.v]"
foreach fil $src_files {
	file copy -force -- $fil $argv/
}
