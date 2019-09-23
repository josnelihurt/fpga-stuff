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
Sheet 4 9
Title ""
Date "7 mar 2013"
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text HLabel 4550 2950 2    60   Input ~ 0
DAC_OUT
Wire Wire Line
	4300 2950 4550 2950
Wire Wire Line
	4400 3050 4300 3050
Wire Wire Line
	3150 3050 2950 3050
Wire Wire Line
	3150 2950 3000 2950
Wire Wire Line
	3000 2950 3000 2900
Wire Wire Line
	3000 2900 2950 2900
Wire Wire Line
	3150 3150 3000 3150
Wire Wire Line
	3000 3150 3000 3200
Wire Wire Line
	3000 3200 2950 3200
Wire Wire Line
	4300 3150 4450 3150
$Comp
L +3.3V #PWR022
U 1 1 5122DAC0
P 4450 3150
F 0 "#PWR022" H 4450 3110 30  0001 C CNN
F 1 "+3.3V" H 4450 3260 30  0000 C CNN
	1    4450 3150
	0    1    1    0   
$EndComp
$Comp
L GND #PWR023
U 1 1 5122DAB4
P 4400 3050
F 0 "#PWR023" H 4400 3050 30  0001 C CNN
F 1 "GND" H 4400 2980 30  0001 C CNN
	1    4400 3050
	0    -1   -1   0   
$EndComp
$Comp
L DAC5311 U403
U 1 1 5122DAA5
P 3750 2950
F 0 "U403" H 3600 3150 60  0000 C CNN
F 1 "DAC5311" H 3650 2600 60  0000 C CNN
	1    3750 2950
	1    0    0    -1  
$EndComp
Text HLabel 2950 3200 0    60   Input ~ 0
DATA_IN
Text HLabel 2950 3050 0    60   Input ~ 0
SCLK
Text HLabel 2950 2900 0    60   Input ~ 0
nSYNC
$EndSCHEMATC
