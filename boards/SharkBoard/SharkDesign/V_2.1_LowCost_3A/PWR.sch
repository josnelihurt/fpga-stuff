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
Sheet 4 9
Title "SharkBoard V2.0 "
Date "7 mar 2013"
Rev "V1"
Comp "Go-Bit.co"
Comment1 "Josnelihurt Rodriguez Barajas"
Comment2 ""
Comment3 "Autores:"
Comment4 ""
$EndDescr
Connection ~ 4800 1050
Wire Wire Line
	4800 1050 3550 1050
Wire Wire Line
	4800 2450 4800 2550
Connection ~ 2250 1050
Connection ~ 7350 1250
Wire Wire Line
	7400 1250 7300 1250
Wire Wire Line
	7200 1250 7250 1250
Wire Wire Line
	3450 1050 3450 1150
Wire Wire Line
	3450 1150 3400 1150
Wire Wire Line
	7100 1100 7100 1400
Wire Wire Line
	7450 1350 7450 1250
Wire Wire Line
	7350 1250 7350 1400
Wire Wire Line
	7350 1400 7850 1400
Wire Wire Line
	7850 1400 7850 1150
Wire Wire Line
	7850 1150 7900 1150
Wire Wire Line
	7250 1250 7250 1400
Wire Wire Line
	7250 1400 7100 1400
Connection ~ 2600 1050
Wire Notes Line
	850  5050 850  5400
Connection ~ 2450 1050
Connection ~ 1700 1050
Wire Wire Line
	4800 1450 4800 850 
Wire Wire Line
	4800 1950 4800 1850
Wire Wire Line
	3550 1050 3550 1300
Wire Wire Line
	3550 1300 3300 1300
Wire Wire Line
	3300 1300 3300 1050
Wire Wire Line
	3400 1150 3400 1200
Wire Wire Line
	3250 1050 3350 1050
Connection ~ 3300 1050
Wire Wire Line
	7450 1250 7500 1250
Wire Wire Line
	950  900  950  1050
Wire Wire Line
	950  1050 3150 1050
Wire Wire Line
	2250 800  2250 1050
$Comp
L GND #PWR026
U 1 1 500F4B14
P 4800 2550
F 0 "#PWR026" H 4800 2550 30  0001 C CNN
F 1 "GND" H 4800 2480 30  0001 C CNN
	1    4800 2550
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR027
U 1 1 4FCD3AAA
P 950 900
F 0 "#PWR027" H 950 1000 30  0001 C CNN
F 1 "VCC" H 950 1000 30  0000 C CNN
	1    950  900 
	1    0    0    -1  
$EndComp
$Comp
L +5V #PWR028
U 1 1 4EAB61F9
P 7100 1100
F 0 "#PWR028" H 7100 1190 20  0001 C CNN
F 1 "+5V" H 7100 1190 30  0000 C CNN
	1    7100 1100
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR029
U 1 1 4EAB60AE
P 7450 1350
F 0 "#PWR029" H 7450 1350 30  0001 C CNN
F 1 "GND" H 7450 1280 30  0001 C CNN
	1    7450 1350
	-1   0    0    -1  
$EndComp
$Comp
L +1.2V #PWR030
U 1 1 4E00DE2E
P 7900 1150
F 0 "#PWR030" H 7900 1290 20  0001 C CNN
F 1 "+1.2V" H 7900 1260 30  0000 C CNN
	1    7900 1150
	1    0    0    -1  
$EndComp
$Comp
L AP1122 U402
U 1 1 4E00DD41
P 7350 1000
F 0 "U402" H 7450 1350 60  0000 C CNN
F 1 "AP1122_1.2" H 7250 1250 60  0000 C CNN
F 4 "http://search.digikey.com/scripts/DkSearch/dksus.dll?Detail&name=AP1122EGDITR-ND" H 7350 1000 60  0001 C CNN "Buy"
	1    7350 1000
	-1   0    0    -1  
$EndComp
$Comp
L AP1122 U401
U 1 1 4EAB5F92
P 3300 800
F 0 "U401" H 3450 1050 60  0000 C CNN
F 1 "AP1122_3.3" H 3250 1150 60  0000 C CNN
F 4 "http://search.digikey.com/scripts/DkSearch/dksus.dll?Detail&name=AP1122EGDITR-ND" H 3300 800 60  0001 C CNN "Buy"
	1    3300 800 
	-1   0    0    -1  
$EndComp
$Comp
L R R401
U 1 1 4EAB5DF2
P 4800 2200
F 0 "R401" V 4880 2200 50  0000 C CNN
F 1 "330R" V 4800 2200 50  0000 C CNN
	1    4800 2200
	1    0    0    -1  
$EndComp
$Comp
L LED D401
U 1 1 4EAB5DEC
P 4800 1650
F 0 "D401" H 4800 1750 50  0000 C CNN
F 1 "LED" H 4800 1550 50  0000 C CNN
	1    4800 1650
	0    -1   1    0   
$EndComp
$Comp
L +5V #PWR031
U 1 1 4E00C0FF
P 2250 800
F 0 "#PWR031" H 2250 890 20  0001 C CNN
F 1 "+5V" H 2250 890 30  0000 C CNN
	1    2250 800 
	1    0    0    -1  
$EndComp
Text Label 1250 1050 0    60   ~ 0
PRE_5
$Comp
L +3.3V #PWR032
U 1 1 4DF92B34
P 4800 850
F 0 "#PWR032" H 4800 810 30  0001 C CNN
F 1 "+3.3V" H 4800 960 30  0000 C CNN
	1    4800 850 
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR033
U 1 1 4DF9299E
P 3400 1200
F 0 "#PWR033" H 3400 1200 30  0001 C CNN
F 1 "GND" H 3400 1130 30  0001 C CNN
	1    3400 1200
	1    0    0    -1  
$EndComp
$EndSCHEMATC
