# Marco Forconesi

CC=gcc
CFLAGS=-Wall -lpcap

top_sim_hdl := nfmac10g_tb

.PHONY: clean cleansim gen_stim runsim

runsim: gen_stim
	xvlog $(SRCHDL)/*.v
	xvlog $(SIMHDL)/*.v
	xelab work.$(top_sim_hdl) -s sim_snapshot
	xsim -R sim_snapshot > simlog
	grep -i "SIM OK" simlog || (echo "Simulation failed, see reports"; false)

gen_stim: pcap2axis cleansim
	./$< $(PCAP) $(IFG) $(CORR_LEVL) $(UNDERRUN)

pcap2axis: pcap2axis.c
	$(CC) -o $@  $< $(CFLAGS)

cleansim:
	rm -rf xsim* xelab* xvlog* webtalk* simlog *.dat

clean: cleansim
	rm -f pcap2axis
