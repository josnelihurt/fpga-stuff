# Copyright (C) 1991-2013 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.

# Quartus II 64-Bit Version 13.0.0 Build 156 04/24/2013 SJ Full Version
# File: C:\Users\Administrator\Desktop\AC620_SDRAM_pin_assigments.tcl
# Generated on: Sat Jan 21 16:46:55 2017

package require ::quartus::project

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[12]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[11]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[10]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_addr[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_ba[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_ba[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_cas_n
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_cke
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_clk
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_cs_n
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[15]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[14]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[13]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[12]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[11]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[10]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dq[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dqm[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_dqm[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_ras_n
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdram_we_n
set_location_assignment PIN_P11 -to sdram_addr[0]
set_location_assignment PIN_L10 -to sdram_addr[1]
set_location_assignment PIN_P14 -to sdram_addr[2]
set_location_assignment PIN_T13 -to sdram_addr[3]
set_location_assignment PIN_N12 -to sdram_addr[4]
set_location_assignment PIN_M11 -to sdram_addr[5]
set_location_assignment PIN_L11 -to sdram_addr[6]
set_location_assignment PIN_T15 -to sdram_addr[7]
set_location_assignment PIN_R14 -to sdram_addr[8]
set_location_assignment PIN_T14 -to sdram_addr[9]
set_location_assignment PIN_M10 -to sdram_addr[10]
set_location_assignment PIN_R13 -to sdram_addr[11]
set_location_assignment PIN_N11 -to sdram_addr[12]
set_location_assignment PIN_T12 -to sdram_ba[0]
set_location_assignment PIN_M9 -to sdram_ba[1]
set_location_assignment PIN_R11 -to sdram_cas_n
set_location_assignment PIN_T11 -to sdram_cke
set_location_assignment PIN_T10 -to sdram_clk
set_location_assignment PIN_R12 -to sdram_cs_n
set_location_assignment PIN_T8 -to sdram_dqm[0]
set_location_assignment PIN_R10 -to sdram_dqm[1]
set_location_assignment PIN_R3 -to sdram_dq[0]
set_location_assignment PIN_T3 -to sdram_dq[1]
set_location_assignment PIN_R4 -to sdram_dq[2]
set_location_assignment PIN_T4 -to sdram_dq[3]
set_location_assignment PIN_R5 -to sdram_dq[4]
set_location_assignment PIN_T5 -to sdram_dq[5]
set_location_assignment PIN_R6 -to sdram_dq[6]
set_location_assignment PIN_R8 -to sdram_dq[7]
set_location_assignment PIN_R9 -to sdram_dq[8]
set_location_assignment PIN_K9 -to sdram_dq[9]
set_location_assignment PIN_L9 -to sdram_dq[10]
set_location_assignment PIN_K8 -to sdram_dq[11]
set_location_assignment PIN_L8 -to sdram_dq[12]
set_location_assignment PIN_M8 -to sdram_dq[13]
set_location_assignment PIN_N8 -to sdram_dq[14]
set_location_assignment PIN_P9 -to sdram_dq[15]
set_location_assignment PIN_N9 -to sdram_ras_n
set_location_assignment PIN_T9 -to sdram_we_n
