EESchema Schematic File Version 2  date Wed 06 Mar 2013 10:45:45 PM COT
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:special
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:lacedaemonia-cache
EELAYER 25  0
EELAYER END
$Descr A4 11700 8267
encoding utf-8
Sheet 1 9
Title "SharkBoard V2.0 "
Date "7 mar 2013"
Rev ""
Comp "Go-Bit.co"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Wire Wire Line
	5850 1450 6550 1450
Wire Wire Line
	6550 1350 5850 1350
Wire Wire Line
	4050 1500 4250 1500
Wire Wire Line
	4050 1300 4250 1300
Wire Bus Line
	5850 1200 6550 1200
Wire Wire Line
	4050 1200 4250 1200
Wire Wire Line
	4050 1400 4250 1400
$Sheet
S 4250 1050 1600 1400
U 4FAE678E
F0 "FPGA" 60
F1 "FPGA.sch" 60
F2 "C_FPGA_TCK" I L 4250 1200 60 
F3 "C_FPGA_TMS" I L 4250 1300 60 
F4 "C_FPGA_TDO" I L 4250 1400 60 
F5 "C_FPGA_TDI" I L 4250 1500 60 
F6 "FPGA_IO[0..99]" I R 5850 1200 60 
F7 "DAC_OUT" I R 5850 1350 60 
F8 "ADC_IN" I R 5850 1450 60 
$EndSheet
$Sheet
S 1400 1050 1100 500 
U 4FAF11BE
F0 "PWR" 60
F1 "PWR.sch" 60
$EndSheet
$Sheet
S 2700 1050 1350 1400
U 4FAF0EE8
F0 "FTDI_JTAG" 60
F1 "FTDI_JTAG.sch" 60
F2 "TMS" I R 4050 1300 60 
F3 "TDI" I R 4050 1500 60 
F4 "TDO" I R 4050 1400 60 
F5 "TCK" I R 4050 1200 60 
$EndSheet
$Sheet
S 6550 1050 1200 450 
U 4FAF0E53
F0 "FPGA_IO" 60
F1 "FPGA_IO.sch" 60
F2 "IO[0..99]" I L 6550 1200 60 
F3 "ADC_IN" I L 6550 1450 60 
F4 "DAC_OUT" I L 6550 1350 60 
$EndSheet
$EndSCHEMATC
