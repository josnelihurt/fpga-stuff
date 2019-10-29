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
$Descr A4 11700 8267
encoding utf-8
Sheet 3 9
Title ""
Date "7 mar 2013"
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Wire Wire Line
	4750 1550 4900 1550
Wire Wire Line
	4750 1750 4900 1750
Wire Wire Line
	3400 1650 3600 1650
Wire Wire Line
	3600 1550 3450 1550
Wire Wire Line
	3500 1750 3600 1750
Wire Wire Line
	4900 1650 4750 1650
$Comp
L +3.3V #PWR020
U 1 1 5122E0AA
P 3450 1550
F 0 "#PWR020" H 3450 1510 30  0001 C CNN
F 1 "+3.3V" H 3450 1660 30  0000 C CNN
	1    3450 1550
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR021
U 1 1 5122E0A4
P 3400 1650
F 0 "#PWR021" H 3400 1650 30  0001 C CNN
F 1 "GND" H 3400 1580 30  0001 C CNN
	1    3400 1650
	0    1    1    0   
$EndComp
$Comp
L ADC081C021 U301
U 1 1 5122E08C
P 4200 1550
F 0 "U301" H 4050 1750 60  0000 C CNN
F 1 "ADC081C021" H 4100 1200 60  0000 C CNN
	1    4200 1550
	1    0    0    -1  
$EndComp
Text HLabel 3500 1750 0    60   Input ~ 0
VIN
Text HLabel 4900 1750 2    60   Input ~ 0
INT
Text HLabel 4900 1650 2    60   Input ~ 0
SCL
Text HLabel 4900 1550 2    60   Input ~ 0
SDA
$EndSCHEMATC
