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
Sheet 7 9
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
	3250 2275 2650 2275
Wire Wire Line
	2650 2275 2650 2175
Wire Wire Line
	2650 2175 2350 2175
Connection ~ 5375 1975
Wire Wire Line
	5375 1975 5375 2275
Wire Wire Line
	5375 2275 7000 2275
Wire Wire Line
	3150 1775 3150 1825
Wire Wire Line
	3150 1825 3250 1825
Wire Wire Line
	3250 2575 3000 2575
Wire Wire Line
	3250 2875 3000 2875
Connection ~ 4150 3875
Wire Wire Line
	4150 4025 4150 3875
Connection ~ 4050 3875
Wire Wire Line
	4050 3775 4050 3875
Wire Wire Line
	5100 2575 7000 2575
Wire Wire Line
	5100 1975 5800 1975
Wire Wire Line
	2350 1975 2600 1975
Wire Wire Line
	2600 1975 2600 1825
Wire Wire Line
	5100 1875 5800 1875
Wire Wire Line
	7000 2475 5100 2475
Wire Wire Line
	5100 2375 7000 2375
Wire Wire Line
	4350 3875 4350 3775
Wire Wire Line
	3900 3775 3900 3875
Wire Wire Line
	4200 3775 4200 3875
Connection ~ 4200 3875
Wire Wire Line
	4500 3775 4500 3875
Wire Wire Line
	4500 3875 3900 3875
Connection ~ 4350 3875
Wire Wire Line
	3250 2775 3000 2775
Wire Wire Line
	3250 3075 3000 3075
Wire Wire Line
	3250 1925 3000 1925
Wire Wire Line
	3000 1925 3000 1750
Wire Wire Line
	3250 2175 2725 2175
Wire Wire Line
	2725 2175 2725 2075
Wire Wire Line
	2725 2075 2350 2075
$Sheet
S 1800 1925 550  800 
U 4FAF1740
F0 "USB" 60
F1 "USB.sch" 60
F2 "DDP" B R 2350 2175 60 
F3 "DDM" B R 2350 2075 60 
F4 "V5USB" B R 2350 1975 60 
$EndSheet
NoConn ~ 5100 2075
NoConn ~ 5100 2175
NoConn ~ 5100 2275
NoConn ~ 5100 2675
NoConn ~ 5100 2775
NoConn ~ 5100 2875
NoConn ~ 5100 2975
NoConn ~ 5100 3075
$Comp
L +5V #PWR034
U 1 1 505FC4BD
P 3000 1750
F 0 "#PWR034" H 3000 1840 20  0001 C CNN
F 1 "+5V" H 3000 1840 30  0000 C CNN
	1    3000 1750
	1    0    0    -1  
$EndComp
$Comp
L +3.3V #PWR035
U 1 1 505FC4A7
P 3150 1775
F 0 "#PWR035" H 3150 1735 30  0001 C CNN
F 1 "+3.3V" H 3150 1885 30  0000 C CNN
	1    3150 1775
	1    0    0    -1  
$EndComp
NoConn ~ 3000 3075
NoConn ~ 3000 2875
NoConn ~ 3000 2775
NoConn ~ 3000 2575
$Comp
L FT232RL U501
U 1 1 505FC413
P 4200 2575
F 0 "U501" H 4200 3475 60  0000 C CNN
F 1 "FT232RL" H 4600 1575 60  0000 L CNN
	1    4200 2575
	1    0    0    -1  
$EndComp
Text HLabel 5800 1875 2    60   Input ~ 0
TX
Text HLabel 5800 1975 2    60   Input ~ 0
RX
Text HLabel 7000 2275 2    60   Input ~ 0
TMS
Text HLabel 7000 2375 2    60   Input ~ 0
TDI
Text HLabel 7000 2475 2    60   Input ~ 0
TDO
Text HLabel 7000 2575 2    60   Input ~ 0
TCK
Text Label 6350 2275 0    60   ~ 0
TMS
Text Label 6350 2475 0    60   ~ 0
TDO
Text Label 6350 2375 0    60   ~ 0
TDI
Text Label 6350 2575 0    60   ~ 0
TCK
Text Label 5400 1975 0    60   ~ 0
FT_RXD
Text Label 5400 1875 0    60   ~ 0
FT_TXD
$Comp
L GND #PWR036
U 1 1 4FCD5727
P 4150 4025
F 0 "#PWR036" H 4150 4025 30  0001 C CNN
F 1 "GND" H 4150 3955 30  0001 C CNN
	1    4150 4025
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR037
U 1 1 4FCD3A9F
P 2600 1825
F 0 "#PWR037" H 2600 1925 30  0001 C CNN
F 1 "VCC" H 2600 1925 30  0000 C CNN
	1    2600 1825
	1    0    0    -1  
$EndComp
Text Label 1850 2100 0    60   ~ 0
-
Text Label 1850 2200 0    60   ~ 0
+
$EndSCHEMATC
