EESchema Schematic File Version 2  date Mon 18 Jun 2012 08:09:06 AM COT
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
LIBS:usba-plug
LIBS:usb_a
LIBS:fsusb20
LIBS:usbconn
LIBS:con-cypressindustries
LIBS:at45db321d
LIBS:devices_mod
LIBS:smd-special
LIBS:my_dev
LIBS:ft2232d
LIBS:lacedaemonia-cache
EELAYER 25  0
EELAYER END
$Descr A 11000 8500
encoding utf-8
Sheet 4 7
Title "CondorBoard_V1"
Date "18 jun 2012"
Rev "V1"
Comp "Uniandes"
Comment1 "Josnelihurt Rodriguez Barajas"
Comment2 ""
Comment3 "Autores:"
Comment4 ""
$EndDescr
Text Label 5500 5550 0    60   ~ 0
PPRE_V5USB
Wire Wire Line
	6375 5550 5400 5550
Wire Wire Line
	6600 5550 6800 5550
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
	5100 5850 3200 5850
Wire Wire Line
	2700 6400 2700 6250
Wire Wire Line
	3300 5050 3300 5700
Wire Wire Line
	3100 5150 3100 5050
Connection ~ 5050 5700
Wire Wire Line
	5050 5600 5050 5700
Wire Wire Line
	2700 6400 2750 6400
Wire Notes Line
	4650 5650 5300 5650
Wire Notes Line
	4650 5650 4650 5100
Wire Notes Line
	4650 5100 5300 5100
Wire Notes Line
	5300 5100 5300 5650
Connection ~ 5850 6550
Wire Wire Line
	5850 6750 5850 6550
Wire Wire Line
	6000 6350 6000 6550
Wire Wire Line
	6000 6550 5700 6550
Wire Wire Line
	5700 6550 5700 6350
Connection ~ 5700 5700
Wire Wire Line
	5700 5950 5700 5700
Wire Wire Line
	5600 5850 6800 5850
Wire Wire Line
	2700 6250 2400 6250
Connection ~ 3350 6250
Connection ~ 2550 6250
Wire Wire Line
	6800 5700 5600 5700
Wire Wire Line
	6000 5950 6000 5850
Connection ~ 6000 5850
Wire Wire Line
	2550 6450 2550 6250
Wire Wire Line
	4800 5700 4800 5600
Connection ~ 4800 5700
Wire Wire Line
	3350 6250 3350 6400
Wire Wire Line
	4800 5100 4800 5000
Wire Wire Line
	5050 5200 4900 5200
Wire Wire Line
	4900 5200 4900 5850
Connection ~ 4900 5850
Connection ~ 6000 5950
Connection ~ 5700 5950
Connection ~ 5700 6350
Connection ~ 6000 6350
Wire Wire Line
	3200 5850 3200 5050
Wire Wire Line
	3400 5200 3400 5050
Wire Wire Line
	3300 5700 5100 5700
Wire Wire Line
	2400 5700 2400 4300
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
$Comp
L PAD2_NC PAD801
U 1 1 4FA836FD
P 6500 5550
F 0 "PAD801" H 6450 5650 60  0000 C CNN
F 1 "PAD2_NC" H 6500 5450 60  0000 C CNN
	1    6500 5550
	1    0    0    -1  
$EndComp
$Comp
L MINI-USB-32005-201 X901
U 1 1 4EAB47BF
P 3300 4850
F 0 "X901" V 3200 5300 50  0000 L BNN
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
L GND #PWR025
U 1 1 4EAB4955
P 3600 5250
F 0 "#PWR025" H 3600 5250 30  0001 C CNN
F 1 "GND" H 3600 5180 30  0001 C CNN
	1    3600 5250
	1    0    0    -1  
$EndComp
Text Label 3050 6250 0    60   ~ 0
USB_SHIELD
$Comp
L INDUCTOR L901
U 1 1 4DF92811
P 3050 6400
F 0 "L901" V 3000 6400 40  0000 C CNN
F 1 "HZ0805C202R-10" V 3150 6400 40  0000 C CNN
	1    3050 6400
	0    1    1    0   
$EndComp
Text Notes 4600 5650 1    60   ~ 0
NOT POPULATED\n
$Comp
L C C904
U 1 1 4DE925C3
P 5050 5400
F 0 "C904" H 5100 5500 50  0000 L CNN
F 1 "33pF" H 5100 5300 50  0000 L CNN
	1    5050 5400
	1    0    0    -1  
$EndComp
$Comp
L +3.3V #PWR026
U 1 1 4DE92589
P 4800 5000
F 0 "#PWR026" H 4800 4960 30  0001 C CNN
F 1 "+3.3V" H 4800 5110 30  0000 C CNN
	1    4800 5000
	1    0    0    -1  
$EndComp
$Comp
L R R906
U 1 1 4DE92548
P 4800 5350
F 0 "R906" V 4880 5350 50  0000 C CNN
F 1 "1.5k" V 4800 5350 50  0000 C CNN
	1    4800 5350
	-1   0    0    1   
$EndComp
$Comp
L GND #PWR027
U 1 1 4DE40AE6
P 5850 6750
F 0 "#PWR027" H 5850 6750 30  0001 C CNN
F 1 "GND" H 5850 6680 30  0001 C CNN
	1    5850 6750
	1    0    0    -1  
$EndComp
$Comp
L C C907
U 1 1 4DE40AD5
P 6000 6150
F 0 "C907" H 6050 6250 50  0000 L CNN
F 1 "15pF" H 6050 6050 50  0000 L CNN
	1    6000 6150
	1    0    0    -1  
$EndComp
$Comp
L C C906
U 1 1 4DE40ABF
P 5700 6150
F 0 "C906" H 5750 6250 50  0000 L CNN
F 1 "15pF" H 5750 6050 50  0000 L CNN
	1    5700 6150
	1    0    0    -1  
$EndComp
$Comp
L R R910
U 1 1 4DE40A75
P 5350 5850
F 0 "R910" V 5430 5850 50  0000 C CNN
F 1 "39R" V 5350 5850 50  0000 C CNN
	1    5350 5850
	0    1    1    0   
$EndComp
$Comp
L R R909
U 1 1 4DE40A6F
P 5350 5700
F 0 "R909" V 5430 5700 50  0000 C CNN
F 1 "39R" V 5350 5700 50  0000 C CNN
	1    5350 5700
	0    1    1    0   
$EndComp
$Comp
L GND #PWR028
U 1 1 4DE40A0E
P 2550 6450
F 0 "#PWR028" H 2550 6450 30  0001 C CNN
F 1 "GND" H 2550 6380 30  0001 C CNN
	1    2550 6450
	1    0    0    -1  
$EndComp
Text HLabel 6800 5700 2    60   BiDi ~ 0
DDP
Text HLabel 6800 5850 2    60   BiDi ~ 0
DDM
Text HLabel 6800 5550 2    60   BiDi ~ 0
V5USB
$EndSCHEMATC
