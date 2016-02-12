# Marco Forconesi

set target_fpga "xc7vx690tffg1761-3"
set src_hdl [lindex $argv 0]
set src_xdc [lindex $argv 1]

read_verilog [glob -dir $src_hdl *.v]
read_xdc [glob -dir $src_xdc *.xdc]
synth_design -top nfmac10g -part $target_fpga
opt_design
report_utilization -file report_utilization.log
report_timing_summary -file report_timing_summary.log
