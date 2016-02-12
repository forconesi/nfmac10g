# Marco Forconesi

.PHONY: clean synth

synth:
	vivado -nojou -nolog -mode batch -source synth.tcl -tclargs $(SRCHDL) $(SRCXDC)
	cat report_utilization.log  | grep -B 1 -A 10 '|        Site Type        | Used | Fixed | Available | Util% |'
	cat report_timing_summary.log | grep -B 2 -A 6 'From Clock:  tx_clk0'

clean:
	rm -rf *.log .Xil