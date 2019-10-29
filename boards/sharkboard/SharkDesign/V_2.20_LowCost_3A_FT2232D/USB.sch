EESchema Schematic File Version 2  date Thu 07 Mar 2013 01:48:10 AM COT
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
LIBS:xilinx_virtexii-xc2v80&flashprom
LIBS:m25pxx
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
	3950 4650 4100 4650
Wire Wire Line
	6800 5850 3200 5850
Wire Wire Line
	6800 5550 5400 5550
Connection ~ 3500 5200
Wire Wire Line
	3500 5050 3500 5200
Connection ~ 3600 5200
Wire Wire Line
	4400 6250 2900 6250
Wire Wire Line
	2650 4650 2600 4650
Wire Wire Line
	5400 5550 5400 4300
Wire Wire Line
	3400 5050 3400 5200
Wire Wire Line
	3200 5850 3200 5050
Wire Wire Line
	3350 6250 3350 6400
Connection ~ 3350 6250
Wire Wire Line
	3100 5050 3100 5150
Wire Wire Line
	3300 5050 3300 5700
Wire Wire Line
	2650 4750 2600 4750
Connection ~ 2600 4750
Wire Wire Line
	3950 4750 4100 4750
Connection ~ 4100 4650
Wire Wire Line
	3600 5250 3600 5200
Wire Wire Line
	3600 5200 3400 5200
Wire Wire Line
	3300 5700 6800 5700
Wire Wire Line
	3100 5150 2400 5150
Wire Wire Line
	2400 5150 2400 4300
Wire Wire Line
	2400 4300 5400 4300
NoConn ~ 2600 4650
NoConn ~ 2600 4750
NoConn ~ 4100 4750
NoConn ~ 4100 4650
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
L GND #PWR043
U 1 1 4EAB4955
P 3600 5250
F 0 "#PWR043" H 3600 5250 30  0001 C CNN
F 1 "GND" H 3600 5180 30  0001 C CNN
	1    3600 5250
	1    0    0    -1  
$EndComp
Text Label 3050 6250 0    60   ~ 0
USB_SHIELD
$Comp
L GND #PWR044
U 1 1 4DE40A0E
P 3350 6400
F 0 "#PWR044" H 3350 6400 30  0001 C CNN
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
