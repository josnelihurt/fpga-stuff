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
$Descr A 11000 8500
encoding utf-8
Sheet 8 9
Title "SharkBoard V2.0 "
Date "7 mar 2013"
Rev "V1"
Comp "Go-Bit.co"
Comment1 "Josnelihurt Rodriguez Barajas"
Comment2 ""
Comment3 "Autores:"
Comment4 ""
$EndDescr
Wire Wire Line
	2400 5150 2400 4300
Wire Wire Line
	6800 5700 3300 5700
Wire Wire Line
	3600 5200 3400 5200
Wire Wire Line
	3600 5200 3600 5250
Connection ~ 4100 4650
Wire Wire Line
	4100 4650 4100 4750
Wire Wire Line
	4100 4750 3950 4750
Connection ~ 2600 4750
Wire Wire Line
	2650 4750 2600 4750
Connection ~ 2400 5150
Wire Wire Line
	2400 5150 3100 5150
Wire Wire Line
	3300 5700 3300 5050
Wire Wire Line
	3100 5150 3100 5050
Connection ~ 3350 6250
Wire Wire Line
	3350 6250 3350 6400
Wire Wire Line
	3200 5050 3200 5850
Wire Wire Line
	3400 5200 3400 5050
Wire Wire Line
	2400 4300 5400 4300
Wire Wire Line
	5400 4300 5400 5550
Wire Wire Line
	2900 5000 2900 6250
Wire Wire Line
	2900 5000 2600 5000
Wire Wire Line
	2600 5000 2600 4650
Wire Wire Line
	2600 4650 2650 4650
Wire Wire Line
	2900 6250 4400 6250
Wire Wire Line
	4400 6250 4400 4650
Wire Wire Line
	4400 4650 3950 4650
Connection ~ 3600 5200
Wire Wire Line
	3500 5050 3500 5200
Connection ~ 3500 5200
Wire Wire Line
	5400 5550 6800 5550
Wire Wire Line
	3200 5850 6800 5850
Text Label 5500 5550 0    60   ~ 0
PPRE_V5USB
$Comp
L MINI-USB-32005-201 X601
U 1 1 4EAB47BF
P 3300 4850
F 0 "X601" V 3200 5300 50  0000 L BNN
F 1 "MINI-USB" V 3665 4550 50  0000 L BNN
F 2 "con-cypressindustries-32005-201" H 3300 5000 50  0001 C CNN
	1    3300 4850
	0    -1   -1   0   
$EndComp
Text Label 3850 5850 0    60   ~ 0
D-
Text Label 3850 5700 0    60   ~ 0
D+
$Comp
L GND #PWR038
U 1 1 4EAB4955
P 3600 5250
F 0 "#PWR038" H 3600 5250 30  0001 C CNN
F 1 "GND" H 3600 5180 30  0001 C CNN
	1    3600 5250
	1    0    0    -1  
$EndComp
Text Label 3050 6250 0    60   ~ 0
USB_SHIELD
$Comp
L GND #PWR039
U 1 1 4DE40A0E
P 3350 6400
F 0 "#PWR039" H 3350 6400 30  0001 C CNN
F 1 "GND" H 3350 6330 30  0001 C CNN
	1    3350 6400
	1    0    0    -1  
$EndComp
Text HLabel 6800 5700 2    60   BiDi ~ 0
DDP
Text HLabel 6800 5850 2    60   BiDi ~ 0
DDM
Text HLabel 6800 5550 2    60   BiDi ~ 0
V5USB
$EndSCHEMATC
