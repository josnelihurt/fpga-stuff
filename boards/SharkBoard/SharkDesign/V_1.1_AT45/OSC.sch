EESchema Schematic File Version 2  date Tue 26 Jun 2012 10:46:20 PM COT
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
LIBS:lacedaemonia-cache
EELAYER 25  0
EELAYER END
$Descr A 11000 8500
encoding utf-8
Sheet 3 7
Title "CondorBoard_V1"
Date "27 jun 2012"
Rev "V1"
Comp "Uniandes"
Comment1 "Josnelihurt Rodriguez Barajas"
Comment2 ""
Comment3 "Autores:"
Comment4 ""
$EndDescr
Connection ~ 5300 3800
Wire Wire Line
	5300 3800 5100 3800
Connection ~ 5300 3300
Wire Wire Line
	6400 3300 5100 3300
Wire Wire Line
	5100 3300 5100 3350
Connection ~ 6400 3300
Wire Wire Line
	6400 3250 6400 3500
Wire Wire Line
	5400 3600 5300 3600
Wire Wire Line
	6400 3500 6300 3500
Wire Wire Line
	5300 3300 5300 3500
Wire Wire Line
	5300 3500 5400 3500
Wire Wire Line
	6300 3600 6400 3600
Wire Wire Line
	5400 3700 5300 3700
Wire Wire Line
	5300 3700 5300 3850
Wire Wire Line
	6550 3700 6300 3700
Wire Wire Line
	5100 3800 5100 3750
$Comp
L C C1901
U 1 1 4E00BA51
P 5100 3550
F 0 "C1901" H 5150 3650 50  0000 L CNN
F 1 "1uF" H 5150 3450 50  0000 L CNN
	1    5100 3550
	1    0    0    -1  
$EndComp
$Comp
L +3.3V #PWR029
U 1 1 4E00BA1B
P 6400 3250
F 0 "#PWR029" H 6400 3210 30  0001 C CNN
F 1 "+3.3V" H 6400 3360 30  0000 C CNN
	1    6400 3250
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR030
U 1 1 4E00BA14
P 5300 3850
F 0 "#PWR030" H 5300 3850 30  0001 C CNN
F 1 "GND" H 5300 3780 30  0001 C CNN
	1    5300 3850
	1    0    0    -1  
$EndComp
NoConn ~ 5300 3600
NoConn ~ 6400 3600
$Comp
L FXO-HC73 OSC1901
U 1 1 4E00B9FA
P 5850 3650
F 0 "OSC1901" H 5700 3900 60  0000 C CNN
F 1 "FXO-HC73" H 5850 3500 60  0000 C CNN
F 4 "631-1060-1-ND" H 5850 3650 60  0001 C CNN "Buy"
	1    5850 3650
	1    0    0    -1  
$EndComp
Text HLabel 6550 3700 2    60   Input ~ 0
OSC_50M
$EndSCHEMATC
