# Marco Forconesi

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
