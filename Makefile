############################################################################
######   SharkBoard Main Makefile                                       ####
#########This file include the specific rules for the projects          ####
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
# Include main Makefile
#Remember this could be used as parameter 500 250 or 100 according to your
#FPGA capacity
FPGA_SIZE=500

include ../Makefile
#############################################################################

VINCDIR=						\
	-I../rtl/barrel_shifter		
SYN_SRC=

SIM_SRC=					\
	system_tb.v				
		
# Include here the files that you need to build your project,
#	Remember in PATH_RTL_GENRIC_LIBS the git provide constant updates for the
#		typical modules. It means in the rtl-generic folder
#	In the local folder rtl you can add your own system description
#		For example:
SRC=														\
	../system.v												\
	../tm1638.v									\
	../basic.v									\
	$(PATH_RTL_GENRIC_LIBS)/dataregister/dataregister.v		\
	$(PATH_RTL_GENRIC_LIBS)/counter/counter.v				\
	../rtl/barrel_shifter/barrel_shifter.v		

#



