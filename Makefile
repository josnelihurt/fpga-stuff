############################################################################
######   SharkBoard Main Makefile                                       ####
#########This file include the general rules for the projects           ####
#################################################################FES - JRB##
#
# SharkBoad
# Copyright (C) 2012 Bogotá, Colombia
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#/

#/*
#  _________.__                  __   __________                       .___
# /   _____/|  |__ _____ _______|  | _\______   \ _________ _______  __| _/
# \_____  \ |  |  \\__  \\_  __ \  |/ /|    |  _//  _ \__  \\_  __ \/ __ | 
# /        \|   Y  \/ __ \|  | \/    < |    |   (  <_> ) __ \|  | \/ /_/ | 
#/_______  /|___|  (____  /__|  |__|_ \|______  /\____(____  /__|  \____ | 
#        \/      \/     \/           \/       \/           \/           \/ 
#
#*/

#############################################################################
# General Files and paths
# Remember When you add a new rtl-generic driver include the paths here
# 	The you can use it in a SRC file
PATH_RTL_GENRIC_LIBS	=$(CURDIR)/../../rtl-generic
PATH_MAIN_PROJ			=$(CURDIR)/..
VINCDIR=										\
	-I$(PATH_RTL_GENRIC_LIBS)/7segdriver		\
	-I$(PATH_RTL_GENRIC_LIBS)/counter		\
	-I$(PATH_RTL_GENRIC_LIBS)/dataregister	\
	-I$(PATH_RTL_GENRIC_LIBS)/debounce		\
	-I$(PATH_RTL_GENRIC_LIBS)/fifo			\
	-I$(PATH_RTL_GENRIC_LIBS)/matrix_ctrl	\
	-I$(PATH_RTL_GENRIC_LIBS)/uart			\
	-I$(PATH_RTL_GENRIC_LIBS)/vgadriver		
SYN_SRC=

SIM_SRC=					\

SRC=						\
	../system.v				
#This is the defaul FPGA KGates size
#FPGA_SIZE=100 It has been moved to the particular project to support multiples FPGA sizes

#############################################################################
# Synthesis constants
SYNCLEAN=system.bgn system.drc system.mrp system.ngd system.pcf 
SYNCLEAN+=system.bld system.lso system.ncd system.ngm system.srp
SYNCLEAN+=system.bit system.svf system_signalbrowser.* system-routed_pad.tx
SYNCLEAN+=system.map system_summary.xml timing.twr
SYNCLEAN+=system-routed* system_usage* system.ngc param.opt netlist.lst
SYNCLEAN+=xst system.prj *ngr *xrpt  _xmsgs  xlnx_auto_0_xdb *html *log *xwbt
SYNCLEAN+=*~ syn_install_scripts

USAGE_DEPTH=0
SMARTGUIDE=

#############################################################################
# Simulation constants
SIMCLEAN=system_tb.vvp system_tb.vcd verilog.log system_tb.vvp.list simulation 

CVER=cver
GTKWAVE=gtkwave
IVERILOG=iverilog
VVP=vvp
	
#############################################################################
# 
sim: system_tb.vcd
syn: system.bit system.svf
view: system_tb.view
install:
	sudo jtag syn_install_scripts/urjtag_cmds
#############################################################################
# Ikarus verilog simulation

system_tb.vvp:
	echo $(PATH_RTL_GENRIC_LIBS)
	rm -rf  simulation/*
	cp system_tb.v system_conf.v system_tb.vcd.save.sav simulation && cd simulation && rm -f $@.list
	for i in $(SRC); do echo $$i >> simulation/$@.list; done
	for i in $(SIM_SRC); do echo $$i >> simulation/$@.list; done
	echo "Running: $(IVERILOG) -o $@ $(VINCDIR) -c $@.list -s $(@:.vvp=)"
	cd simulation && $(IVERILOG) -DSIMULATION -o $@ $(VINCDIR) -c $@.list -s $(@:.vvp=)

%.vcd: %.vvp
	cd simulation && $(VVP) $<

#############################################################################
# ISE Synthesis

system.prj:
	rm -rf build && mkdir build
	#mkdir build
	@rm -f $@
	for i in $(SRC); do echo verilog work $$i >> build/$@; done
	for i in $(SRC_HDL); do echo VHDL work $$i >> build/$@; done

system.ngc: system.prj
	rm -rf syn_install_scripts && mkdir syn_install_scripts
	@echo "Generate the system.xst it will configure the FPGA version that you have"
	@echo "$(FPGA_SIZE) K-Gates"
	@echo "run" >> syn_install_scripts/system.xst
	@echo "-ifn system.prj" >> syn_install_scripts/system.xst
	@echo "-top system" >> syn_install_scripts/system.xst
	@echo "-ifmt MIXED" >> syn_install_scripts/system.xst
	@echo "-opt_mode AREA" >> syn_install_scripts/system.xst
	@echo "-opt_level 2" >> syn_install_scripts/system.xst
	@echo "-ofn system.ngc" >> syn_install_scripts/system.xst
	@echo "-p xc3S$(FPGA_SIZE)e-VQ100-4" >> syn_install_scripts/system.xst
	@echo "-register_balancing yes" >> syn_install_scripts/system.xst
	@echo "-rtlview yes" >> syn_install_scripts/system.xst
	cd build && xst -ifn ../syn_install_scripts/system.xst

system.ngd: system.ngc system.ucf
	cd build && ngdbuild -uc ../system.ucf system.ngc

system.ncd: system.ngd
	cd build && map $(SMARTGUIDE) system.ngd

system-routed.ncd: system.ncd
	cd build && par $(SMARTGUIDE) -ol high -w system.ncd system-routed.ncd

system.bit: system-routed.ncd
	cd build &&  bitgen -w system-routed.ncd system.bit
	@mv -f build/system.bit $@

system.mcs: system.bit
	cd build && promgen -u 0 system

system-routed.xdl: system-routed.ncd
	cd build && xdl -ncd2xdl system-routed.ncd system-routed.xdl

system-routed.twr: system-routed.ncd
	cd build &&  trce -v 10 system-routed.ncd system.pcf

timing: system-routed.twr

usage: system-routed.xdl
	xdlanalyze.pl system-routed.xdl $(USAGE_DEPTH)

####################################################################
# SVF file
system.svf: system.bit
	rm -rf syn_install_scripts && mkdir syn_install_scripts
	@echo "Generate the impact_batch_cmds it will generate the svf file to use urjtag"
	@echo "setMode -bscan" >> syn_install_scripts/impact_batch_cmds
	@echo "setcable -p svf -file system.svf" >> syn_install_scripts/impact_batch_cmds
	@echo "addDevice -p 1 -file system.bit" >> syn_install_scripts/impact_batch_cmds
	@echo "program -p 1" >> syn_install_scripts/impact_batch_cmds
	@echo "quit" >> syn_install_scripts/impact_batch_cmds
	impact -batch syn_install_scripts/impact_batch_cmds
	@echo "Generate the urjtag_cmds it will program the FPGA"
	@echo "cable Flyswatter" >> syn_install_scripts/urjtag_cmds
	@echo "detect" >> syn_install_scripts/urjtag_cmds
	@echo "svf system.svf" >> syn_install_scripts/urjtag_cmds
	
####################################################################
# final targets

%.view: %.vcd
	cd simulation && $(GTKWAVE) $< $<.save.sav

clean:
	rm -Rf build $(SYNCLEAN) $(SIMCLEAN) 

.PHONY: clean view
