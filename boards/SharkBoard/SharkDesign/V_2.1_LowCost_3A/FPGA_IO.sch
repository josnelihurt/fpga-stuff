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
Sheet 9 9
Title "SharkBoard V2.0 "
Date "7 mar 2013"
Rev ""
Comp "Go-Bit.co"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text HLabel 1850 2650 0    60   Input ~ 0
ADC_IN
Text HLabel 1850 3250 0    60   Input ~ 0
DAC_OUT
Text Label 1850 2750 2    60   ~ 0
P21
$Comp
L GND #PWR040
U 1 1 5122CEB6
P 750 950
F 0 "#PWR040" H 750 950 30  0001 C CNN
F 1 "GND" H 750 880 30  0001 C CNN
	1    750  950 
	0    1    1    0   
$EndComp
$Comp
L +3.3V #PWR041
U 1 1 5122CEB5
P 750 850
F 0 "#PWR041" H 750 810 30  0001 C CNN
F 1 "+3.3V" H 750 960 30  0000 C CNN
	1    750  850 
	0    -1   -1   0   
$EndComp
Wire Wire Line
	2000 850  1850 850 
Wire Wire Line
	2000 950  1850 950 
Wire Wire Line
	2000 1150 1850 1150
Wire Wire Line
	2000 1050 1850 1050
Wire Wire Line
	2000 1450 1850 1450
Wire Wire Line
	2000 1550 1850 1550
Wire Wire Line
	2000 1350 1850 1350
Wire Wire Line
	2000 1250 1850 1250
Wire Wire Line
	2000 2050 1850 2050
Wire Wire Line
	2000 2150 1850 2150
Wire Wire Line
	2000 2350 1850 2350
Wire Wire Line
	2000 2250 1850 2250
Wire Wire Line
	2000 1850 1850 1850
Wire Wire Line
	2000 1950 1850 1950
Wire Wire Line
	2000 1750 1850 1750
Wire Wire Line
	2000 1650 1850 1650
Wire Wire Line
	2000 2650 1850 2650
Wire Wire Line
	2000 2750 1850 2750
Wire Wire Line
	2000 2550 1850 2550
Wire Wire Line
	2000 2450 1850 2450
Wire Wire Line
	2000 3150 1850 3150
Wire Wire Line
	2000 3250 1850 3250
Wire Wire Line
	2000 2950 1850 2950
Wire Wire Line
	2000 3050 1850 3050
Wire Wire Line
	2000 2850 1850 2850
Wire Wire Line
	900  2850 750  2850
Wire Wire Line
	900  3050 750  3050
Wire Wire Line
	900  2950 750  2950
Wire Wire Line
	900  3250 750  3250
Wire Wire Line
	900  3150 750  3150
$Comp
L CONN_25 P702
U 1 1 5122BE86
P 2350 2050
F 0 "P702" V 2300 2050 60  0000 C CNN
F 1 "CONN_25" V 2400 2050 60  0000 C CNN
	1    2350 2050
	1    0    0    -1  
$EndComp
$Comp
L CONN_25 P701
U 1 1 5122BE81
P 1250 2050
F 0 "P701" V 1200 2050 60  0000 C CNN
F 1 "CONN_25" V 1300 2050 60  0000 C CNN
	1    1250 2050
	1    0    0    -1  
$EndComp
Wire Wire Line
	900  2450 750  2450
Wire Wire Line
	900  2550 750  2550
Wire Wire Line
	900  2750 750  2750
Wire Wire Line
	900  2650 750  2650
Wire Wire Line
	900  1650 750  1650
Wire Wire Line
	900  1750 750  1750
Wire Wire Line
	900  1950 750  1950
Wire Wire Line
	900  1850 750  1850
Wire Wire Line
	900  2250 750  2250
Wire Wire Line
	900  2350 750  2350
Wire Wire Line
	900  2150 750  2150
Wire Wire Line
	900  2050 750  2050
Wire Wire Line
	900  1250 750  1250
Wire Wire Line
	900  1350 750  1350
Wire Wire Line
	900  1550 750  1550
Wire Wire Line
	900  1450 750  1450
Wire Wire Line
	900  1050 750  1050
Wire Wire Line
	900  1150 750  1150
Wire Wire Line
	900  950  750  950 
Wire Wire Line
	4250 4250 3850 4250
Wire Wire Line
	4250 4350 3850 4350
Wire Wire Line
	4250 4450 3850 4450
Wire Wire Line
	4250 3900 3850 3900
Wire Wire Line
	4250 4050 3850 4050
Wire Wire Line
	4250 4150 3850 4150
Wire Wire Line
	4250 3800 3850 3800
Wire Wire Line
	4250 3700 3850 3700
Wire Wire Line
	4250 2400 3850 2400
Wire Wire Line
	4250 2500 3850 2500
Wire Wire Line
	4250 2850 3850 2850
Wire Wire Line
	4250 2750 3850 2750
Wire Wire Line
	4250 2600 3850 2600
Wire Wire Line
	4250 3150 3850 3150
Wire Wire Line
	4250 3050 3850 3050
Wire Wire Line
	4250 2950 3850 2950
Wire Wire Line
	5750 1150 5350 1150
Wire Wire Line
	5750 1250 5350 1250
Wire Wire Line
	5750 1600 5350 1600
Wire Wire Line
	5750 1500 5350 1500
Wire Wire Line
	5750 1350 5350 1350
Wire Wire Line
	5750 1700 5350 1700
Wire Wire Line
	4250 1700 3850 1700
Wire Wire Line
	4250 1800 3850 1800
Wire Wire Line
	4250 1900 3850 1900
Wire Wire Line
	4250 1350 3850 1350
Wire Wire Line
	4250 1500 3850 1500
Wire Wire Line
	4250 1600 3850 1600
Wire Wire Line
	4250 1250 3850 1250
Wire Wire Line
	4250 1150 3850 1150
Wire Wire Line
	5550 1050 5750 1050
Wire Bus Line
	1000 600  1300 600 
Wire Wire Line
	5550 950  5750 950 
Wire Wire Line
	3250 850  3450 850 
Wire Wire Line
	3250 950  3450 950 
Wire Wire Line
	4050 2300 4250 2300
Wire Wire Line
	4050 2200 4250 2200
Wire Wire Line
	4050 3500 4250 3500
Wire Wire Line
	4050 3600 4250 3600
Wire Wire Line
	900  850  750  850 
Text Label 750  2850 0    60   ~ 0
P98
Text Label 750  2750 0    60   ~ 0
P97
Text Label 750  2650 0    60   ~ 0
P94
Text Label 750  2550 0    60   ~ 0
P93
Text Label 750  2450 0    60   ~ 0
P90
Text Label 750  2350 0    60   ~ 0
P89
Text Label 750  2250 0    60   ~ 0
P88
Text Label 750  2150 0    60   ~ 0
P86
Text Label 750  2050 0    60   ~ 0
P85
Text Label 750  1950 0    60   ~ 0
P84
Text Label 750  1850 0    60   ~ 0
P83
Text Label 750  1750 0    60   ~ 0
P82
Text Label 750  1550 0    60   ~ 0
P78
Text Label 750  1650 0    60   ~ 0
P77
Text Label 750  1450 0    60   ~ 0
P73
Text Label 750  1350 0    60   ~ 0
P72
Text Label 750  1250 0    60   ~ 0
P71
Text Label 750  1150 0    60   ~ 0
P70
Text Label 750  1050 0    60   ~ 0
P68
Text Label 1850 1050 2    60   ~ 0
P65
Text Label 1850 1450 2    60   ~ 0
P64
Text Label 1850 1550 2    60   ~ 0
P62
Text Label 1850 1150 2    60   ~ 0
P61
Text Label 1850 1250 2    60   ~ 0
P60
Text Label 1850 1350 2    60   ~ 0
P59
Text Label 1850 1650 2    60   ~ 0
P57
Text Label 1850 1750 2    60   ~ 0
P56
Text Label 1850 1850 2    60   ~ 0
P52
Text Label 1850 1950 2    60   ~ 0
P50
Text Label 1850 2250 2    60   ~ 0
P36
Text Label 1850 2050 2    60   ~ 0
P49
Text Label 1850 2150 2    60   ~ 0
P41
Text Label 3200 1600 2    60   ~ 0
P40
Text Label 3200 1700 2    60   ~ 0
P39
Text Label 3250 1950 2    60   ~ 0
P37
Text Label 3200 1800 2    60   ~ 0
P36
Text Label 3250 2050 2    60   ~ 0
P35
Text Label 1850 2350 2    60   ~ 0
P34
Text Label 1850 2450 2    60   ~ 0
P33
Text Label 1850 2550 2    60   ~ 0
P32
Text Label 1850 2850 2    60   ~ 0
P20
Text Label 1850 2950 2    60   ~ 0
P19
Text Label 1850 3050 2    60   ~ 0
P16
Text Label 1850 3150 2    60   ~ 0
P15
Text Label 3350 3250 2    60   ~ 0
P13
Text Label 3850 3700 0    60   ~ 0
P12
Text Label 3850 3800 0    60   ~ 0
P10
Text Label 3850 3900 0    60   ~ 0
P9
Text Label 3850 4050 0    60   ~ 0
P7
Text Label 750  3250 0    60   ~ 0
P6
Text Label 750  3150 0    60   ~ 0
P5
Text Label 750  3050 0    60   ~ 0
P4
Text Label 750  2950 0    60   ~ 0
P3
$Comp
L +3.3V #PWR042
U 1 1 505FC165
P 4050 3500
F 0 "#PWR042" H 4050 3460 30  0001 C CNN
F 1 "+3.3V" H 4050 3610 30  0000 C CNN
	1    4050 3500
	0    -1   -1   0   
$EndComp
$Comp
L GND #PWR043
U 1 1 505FC164
P 4050 3600
F 0 "#PWR043" H 4050 3600 30  0001 C CNN
F 1 "GND" H 4050 3530 30  0001 C CNN
	1    4050 3600
	0    1    1    0   
$EndComp
$Comp
L GND #PWR044
U 1 1 505FC161
P 5550 3550
F 0 "#PWR044" H 5550 3550 30  0001 C CNN
F 1 "GND" H 5550 3480 30  0001 C CNN
	1    5550 3550
	0    1    1    0   
$EndComp
$Comp
L +3.3V #PWR045
U 1 1 505FC160
P 5550 3450
F 0 "#PWR045" H 5550 3410 30  0001 C CNN
F 1 "+3.3V" H 5550 3560 30  0000 C CNN
	1    5550 3450
	0    -1   -1   0   
$EndComp
$Comp
L GND #PWR046
U 1 1 505FC158
P 4050 2300
F 0 "#PWR046" H 4050 2300 30  0001 C CNN
F 1 "GND" H 4050 2230 30  0001 C CNN
	1    4050 2300
	0    1    1    0   
$EndComp
$Comp
L +3.3V #PWR047
U 1 1 505FC157
P 4050 2200
F 0 "#PWR047" H 4050 2160 30  0001 C CNN
F 1 "+3.3V" H 4050 2310 30  0000 C CNN
	1    4050 2200
	0    -1   -1   0   
$EndComp
$Comp
L +3.3V #PWR048
U 1 1 505FC153
P 5550 2250
F 0 "#PWR048" H 5550 2210 30  0001 C CNN
F 1 "+3.3V" H 5550 2360 30  0000 C CNN
	1    5550 2250
	0    -1   -1   0   
$EndComp
$Comp
L GND #PWR049
U 1 1 505FC152
P 5550 2350
F 0 "#PWR049" H 5550 2350 30  0001 C CNN
F 1 "GND" H 5550 2280 30  0001 C CNN
	1    5550 2350
	0    1    1    0   
$EndComp
$Comp
L +3.3V #PWR050
U 1 1 505FC14D
P 1850 850
F 0 "#PWR050" H 1850 810 30  0001 C CNN
F 1 "+3.3V" H 1850 960 30  0000 C CNN
	1    1850 850 
	0    -1   -1   0   
$EndComp
$Comp
L GND #PWR051
U 1 1 505FC14C
P 1850 950
F 0 "#PWR051" H 1850 950 30  0001 C CNN
F 1 "GND" H 1850 880 30  0001 C CNN
	1    1850 950 
	0    1    1    0   
$EndComp
$Comp
L GND #PWR052
U 1 1 505FC131
P 5550 1050
F 0 "#PWR052" H 5550 1050 30  0001 C CNN
F 1 "GND" H 5550 980 30  0001 C CNN
	1    5550 1050
	0    1    1    0   
$EndComp
$Comp
L +3.3V #PWR053
U 1 1 505FC127
P 5550 950
F 0 "#PWR053" H 5550 910 30  0001 C CNN
F 1 "+3.3V" H 5550 1060 30  0000 C CNN
	1    5550 950 
	0    -1   -1   0   
$EndComp
Text Label 1300 600  0    60   ~ 0
P[0..99]
Text HLabel 1000 600  0    60   Input ~ 0
IO[0..99]
$EndSCHEMATC
