# Marco Forconesi

CC=gcc
CFLAGS=-Wall -lpcap

clean_list := xsim* xelab* xvlog* webtalk* simlog *.dat

TEST ?= loopback
top_sim_hdl := nfmac10g_$(TEST)_tb

ifeq ($(TEST),nf2xil)
	top_sim_hdl := nfmac10g_interoperability_tb
	xvflags := -d tx=nfmac10g -d rx=xilinx_mac
endif

ifeq ($(TEST),xil2nf)
	top_sim_hdl := nfmac10g_interoperability_tb
	xvflags := -d rx=nfmac10g -d tx=xilinx_mac
endif

ifeq ($(TEST),axis_loopback)
	top_sim_hdl := usr_intf_axis_loopback_tb
	xvflags := -d rx=nfmac10g -d tx=nfmac10g $(USR_INTF_SRCHDL)/*.v
endif

.PHONY: clean cleansim gen_stim runsim siminst sim_usr_intf

siminst:
	for ifgi in 0 10 20 ; do \
		for corr_levli in 0 1 2 ; do \
			make -s runsim SIMHDL=$(SIMHDL) SRCHDL=$(SRCHDL) PCAP=$(PCAP) TEST=$(TEST) \
				IFG=$$ifgi CORR_LEVL=$$corr_levli UNDERRUN=0 LOG=$(LOG) ; \
			simresult=$$? ; \
			if [ $$simresult -ne 0 ] ; then break ; fi ; \
		done ; \
		if [ $$simresult -ne 0 ] ; then \
			echo "Simulation failed. Check reports"; break; fi ; \
		for underruni in 1 2 ; do \
			make -s runsim SIMHDL=$(SIMHDL) SRCHDL=$(SRCHDL) PCAP=$(PCAP) TEST=$(TEST) \
				IFG=$$ifgi CORR_LEVL=0 UNDERRUN=$$underruni LOG=$(LOG) ; \
			simresult=$$? ; \
			if [ $$simresult -ne 0 ] ; then break ; fi ; \
		done ; \
		if [ $$simresult -ne 0 ] ; then \
			echo "Simulation failed. Check reports"; break; fi ; \
	done; \
	if [ $$simresult -ne 0 ] ; then false ; fi ;

runsim: gen_stim
	echo "\n\n////\nSim: IFG=$(IFG) CORR_LEVL=$(CORR_LEVL) UNDERRUN=$(UNDERRUN)\n////" >> $(LOG)
	xvlog $(xvflags) $(SRCHDL)/*.v $(SIMHDL)/*.v
	xelab work.$(top_sim_hdl) -s sim_snapshot
	xsim -R sim_snapshot > simlog
	grep -i "SIM OK" simlog || (echo "Simulation failed, see reports"; false)
	cat simlog >> $(LOG)

sim_usr_intf:
	for ifgi in 0 10 20 ; do \
		make -s runsim SIMHDL=$(SIMHDL) SRCHDL=$(SRCHDL) USR_INTF_SRCHDL=$(USR_INTF_SRCHDL) PCAP=$(PCAP) TEST=$(TEST) \
			IFG=$$ifgi CORR_LEVL=0 UNDERRUN=0 LOG=$(LOG) ; \
		simresult=$$? ; \
		if [ $$simresult -ne 0 ] ; then \
			echo "Simulation failed. Check reports"; break; fi ; \
	done ; \
	if [ $$simresult -ne 0 ] ; then false ; fi ;

gen_stim: pcap2axis cleansim
	./$< $(PCAP) $(IFG) $(CORR_LEVL) $(UNDERRUN)

pcap2axis: pcap2axis.c
	$(CC) -o $@  $< $(CFLAGS)

cleansim:
	rm -rf $(clean_list)

clean: cleansim
	rm -f pcap2axis
