EESchema Schematic File Version 4
LIBS:IS62WV12816BLL-cache
EELAYER 26 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L sharkboard:sharkboard U?
U 1 1 5BE48B66
P 2450 2700
F 0 "U?" H 2400 4325 50  0000 C CNN
F 1 "sharkboard" H 2400 4234 50  0000 C CNN
F 2 "" H 2500 2700 50  0001 C CNN
F 3 "" H 2500 2700 50  0001 C CNN
	1    2450 2700
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5BE2C734
P 3200 3400
F 0 "#PWR?" H 3200 3150 50  0001 C CNN
F 1 "GND" V 3205 3272 50  0000 R CNN
F 2 "" H 3200 3400 50  0001 C CNN
F 3 "" H 3200 3400 50  0001 C CNN
	1    3200 3400
	0    -1   -1   0   
$EndComp
Wire Wire Line
	3200 3400 2900 3400
$Comp
L power:GND #PWR?
U 1 1 5BE2C74F
P 3200 2400
F 0 "#PWR?" H 3200 2150 50  0001 C CNN
F 1 "GND" V 3205 2272 50  0000 R CNN
F 2 "" H 3200 2400 50  0001 C CNN
F 3 "" H 3200 2400 50  0001 C CNN
	1    3200 2400
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5BE2C76F
P 3150 1400
F 0 "#PWR?" H 3150 1150 50  0001 C CNN
F 1 "GND" V 3155 1272 50  0000 R CNN
F 2 "" H 3150 1400 50  0001 C CNN
F 3 "" H 3150 1400 50  0001 C CNN
	1    3150 1400
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5BE2C780
P 1550 4100
F 0 "#PWR?" H 1550 3850 50  0001 C CNN
F 1 "GND" V 1555 3972 50  0000 R CNN
F 2 "" H 1550 4100 50  0001 C CNN
F 3 "" H 1550 4100 50  0001 C CNN
	1    1550 4100
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5BE2C78F
P 1550 3100
F 0 "#PWR?" H 1550 2850 50  0001 C CNN
F 1 "GND" V 1555 2972 50  0000 R CNN
F 2 "" H 1550 3100 50  0001 C CNN
F 3 "" H 1550 3100 50  0001 C CNN
	1    1550 3100
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5BE2C79D
P 1550 2100
F 0 "#PWR?" H 1550 1850 50  0001 C CNN
F 1 "GND" V 1555 1972 50  0000 R CNN
F 2 "" H 1550 2100 50  0001 C CNN
F 3 "" H 1550 2100 50  0001 C CNN
	1    1550 2100
	0    1    1    0   
$EndComp
Wire Wire Line
	1550 4100 1900 4100
Wire Wire Line
	1900 3100 1550 3100
Wire Wire Line
	1900 2100 1550 2100
Wire Wire Line
	3200 2400 2900 2400
Wire Wire Line
	3150 1400 2900 1400
$Comp
L power:+5V #PWR?
U 1 1 5BE2CABD
P 3150 1300
F 0 "#PWR?" H 3150 1150 50  0001 C CNN
F 1 "+5V" V 3165 1428 50  0000 L CNN
F 2 "" H 3150 1300 50  0001 C CNN
F 3 "" H 3150 1300 50  0001 C CNN
	1    3150 1300
	0    1    1    0   
$EndComp
Wire Wire Line
	3150 1300 2900 1300
$Comp
L power:+3V3 #PWR?
U 1 1 5BE2CB94
P 3200 2300
F 0 "#PWR?" H 3200 2150 50  0001 C CNN
F 1 "+3V3" V 3215 2428 50  0000 L CNN
F 2 "" H 3200 2300 50  0001 C CNN
F 3 "" H 3200 2300 50  0001 C CNN
	1    3200 2300
	0    1    1    0   
$EndComp
Wire Wire Line
	3200 2300 2900 2300
$Comp
L power:+3V3 #PWR?
U 1 1 5BE2CC2D
P 3200 3300
F 0 "#PWR?" H 3200 3150 50  0001 C CNN
F 1 "+3V3" V 3215 3428 50  0000 L CNN
F 2 "" H 3200 3300 50  0001 C CNN
F 3 "" H 3200 3300 50  0001 C CNN
	1    3200 3300
	0    1    1    0   
$EndComp
Wire Wire Line
	3200 3300 2900 3300
$Comp
L power:+3V3 #PWR?
U 1 1 5BE2CCE7
P 1550 4200
F 0 "#PWR?" H 1550 4050 50  0001 C CNN
F 1 "+3V3" V 1565 4328 50  0000 L CNN
F 2 "" H 1550 4200 50  0001 C CNN
F 3 "" H 1550 4200 50  0001 C CNN
	1    1550 4200
	0    -1   -1   0   
$EndComp
Wire Wire Line
	1550 4200 1900 4200
$Comp
L power:+3V3 #PWR?
U 1 1 5BE2CDC8
P 1550 3200
F 0 "#PWR?" H 1550 3050 50  0001 C CNN
F 1 "+3V3" V 1565 3328 50  0000 L CNN
F 2 "" H 1550 3200 50  0001 C CNN
F 3 "" H 1550 3200 50  0001 C CNN
	1    1550 3200
	0    -1   -1   0   
$EndComp
Wire Wire Line
	1550 3200 1900 3200
$Comp
L power:+3V3 #PWR?
U 1 1 5BE2CEE0
P 1550 2200
F 0 "#PWR?" H 1550 2050 50  0001 C CNN
F 1 "+3V3" V 1565 2328 50  0000 L CNN
F 2 "" H 1550 2200 50  0001 C CNN
F 3 "" H 1550 2200 50  0001 C CNN
	1    1550 2200
	0    -1   -1   0   
$EndComp
Wire Wire Line
	1550 2200 1900 2200
$Comp
L sharkboard:IS62WV12816 U?
U 1 1 5BE30DE3
P 5350 2650
F 0 "U?" H 5000 4100 50  0000 C CNN
F 1 "IS62WV12816" H 5450 2100 50  0000 C CNN
F 2 "44-Pin mini TSOP (Type II)" H 4650 1450 50  0001 C CNN
F 3 "" H 5650 3100 50  0001 C CNN
	1    5350 2650
	1    0    0    -1  
$EndComp
$Comp
L power:+3V3 #PWR?
U 1 1 5BE30E69
P 5350 950
F 0 "#PWR?" H 5350 800 50  0001 C CNN
F 1 "+3V3" H 5365 1123 50  0000 C CNN
F 2 "" H 5350 950 50  0001 C CNN
F 3 "" H 5350 950 50  0001 C CNN
	1    5350 950 
	1    0    0    -1  
$EndComp
Wire Wire Line
	5300 950  5350 950 
Wire Wire Line
	5350 950  5400 950 
Connection ~ 5350 950 
$Comp
L power:GND #PWR?
U 1 1 5BE311FB
P 5350 4050
F 0 "#PWR?" H 5350 3800 50  0001 C CNN
F 1 "GND" H 5355 3877 50  0000 C CNN
F 2 "" H 5350 4050 50  0001 C CNN
F 3 "" H 5350 4050 50  0001 C CNN
	1    5350 4050
	1    0    0    -1  
$EndComp
Wire Wire Line
	5400 4050 5350 4050
Wire Wire Line
	5350 4050 5300 4050
Connection ~ 5350 4050
Wire Wire Line
	5400 3950 5400 4050
Wire Wire Line
	5300 4050 5300 3950
Wire Wire Line
	5300 950  5300 1100
Wire Wire Line
	5400 950  5400 1100
Entry Wire Line
	6200 1550 6300 1650
Entry Wire Line
	6200 1650 6300 1750
Entry Wire Line
	6200 1750 6300 1850
Entry Wire Line
	6200 1850 6300 1950
Entry Wire Line
	6200 1950 6300 2050
Entry Wire Line
	6200 2050 6300 2150
Entry Wire Line
	6200 2150 6300 2250
Entry Wire Line
	6200 2250 6300 2350
Entry Wire Line
	6200 2350 6300 2450
Entry Wire Line
	6200 2450 6300 2550
Entry Wire Line
	6200 2550 6300 2650
Entry Wire Line
	6200 2650 6300 2750
Entry Wire Line
	6200 2750 6300 2850
Entry Wire Line
	6200 2850 6300 2950
Entry Wire Line
	6200 2950 6300 3050
Entry Wire Line
	6200 3050 6300 3150
Text Label 800  5200 0    50   ~ 0
IO16_BUS
Wire Bus Line
	4400 1400 3550 1400
Entry Wire Line
	3450 1500 3550 1600
Entry Wire Line
	3450 1600 3550 1700
Entry Wire Line
	3450 1700 3550 1800
Entry Wire Line
	3450 1800 3550 1900
Entry Wire Line
	3450 1900 3550 2000
Entry Wire Line
	3450 2000 3550 2100
Entry Wire Line
	3450 2100 3550 2200
Entry Wire Line
	3450 2200 3550 2300
Entry Wire Line
	3450 2500 3550 2600
Entry Wire Line
	3450 2600 3550 2700
Entry Wire Line
	3450 2700 3550 2800
Entry Wire Line
	3450 2800 3550 2900
Entry Wire Line
	3450 2900 3550 3000
Entry Wire Line
	3450 3000 3550 3100
Entry Wire Line
	3450 3100 3550 3200
Entry Wire Line
	3450 3200 3550 3300
Entry Wire Line
	3450 3500 3550 3600
Wire Wire Line
	2900 3500 3450 3500
Wire Wire Line
	3450 3200 2900 3200
Wire Wire Line
	2900 3100 3450 3100
Wire Wire Line
	2900 3000 3450 3000
Wire Wire Line
	3450 2900 2900 2900
Wire Wire Line
	2900 2800 3450 2800
Wire Wire Line
	3450 2700 2900 2700
Wire Wire Line
	2900 2600 3450 2600
Wire Wire Line
	3450 2500 2900 2500
Wire Wire Line
	3450 2200 2900 2200
Wire Wire Line
	2900 2100 3450 2100
Wire Wire Line
	3450 2000 2900 2000
Wire Wire Line
	2900 1900 3450 1900
Wire Wire Line
	3450 1800 2900 1800
Wire Wire Line
	3450 1700 2900 1700
Wire Wire Line
	2900 1600 3450 1600
Wire Wire Line
	3450 1500 2900 1500
Text Label 3850 1400 0    50   ~ 0
A17_BUS
Entry Wire Line
	4400 3000 4500 3100
Entry Wire Line
	4400 2900 4500 3000
Entry Wire Line
	4400 2800 4500 2900
Entry Wire Line
	4400 2700 4500 2800
Entry Wire Line
	4400 1400 4500 1500
Entry Wire Line
	4400 1500 4500 1600
Entry Wire Line
	4400 1600 4500 1700
Entry Wire Line
	4400 1700 4500 1800
Entry Wire Line
	4400 1800 4500 1900
Entry Wire Line
	4400 1900 4500 2000
Entry Wire Line
	4400 2000 4500 2100
Entry Wire Line
	4400 2100 4500 2200
Entry Wire Line
	4400 2200 4500 2300
Entry Wire Line
	4400 2300 4500 2400
Entry Wire Line
	4400 2400 4500 2500
Entry Wire Line
	4400 2500 4500 2600
Entry Wire Line
	4400 2600 4500 2700
Wire Wire Line
	4500 1500 4650 1500
Wire Wire Line
	4500 1600 4650 1600
Wire Wire Line
	4500 1700 4650 1700
Wire Wire Line
	4500 1800 4650 1800
Wire Wire Line
	4500 1900 4650 1900
Wire Wire Line
	4500 3100 4650 3100
Wire Wire Line
	4500 3000 4650 3000
Wire Wire Line
	4500 2900 4650 2900
Wire Wire Line
	4650 2800 4500 2800
Wire Wire Line
	4500 2700 4650 2700
Wire Wire Line
	4500 2600 4650 2600
Wire Wire Line
	4650 2500 4500 2500
Wire Wire Line
	4500 2400 4650 2400
Wire Wire Line
	4500 2300 4650 2300
Wire Wire Line
	4500 2200 4650 2200
Wire Wire Line
	4500 2100 4650 2100
Wire Wire Line
	4500 2000 4650 2000
Wire Wire Line
	5950 1550 6200 1550
Wire Wire Line
	5950 1650 6200 1650
Wire Wire Line
	6200 1750 5950 1750
Wire Wire Line
	5950 1850 6200 1850
Wire Wire Line
	5950 3050 6200 3050
Wire Wire Line
	6200 2950 5950 2950
Wire Wire Line
	5950 2850 6200 2850
Wire Wire Line
	6200 2750 5950 2750
Wire Wire Line
	5950 2650 6200 2650
Wire Wire Line
	6200 2550 5950 2550
Wire Wire Line
	5950 2450 6200 2450
Wire Wire Line
	6200 2350 5950 2350
Wire Wire Line
	5950 2250 6200 2250
Wire Wire Line
	6200 2150 5950 2150
Wire Wire Line
	5950 2050 6200 2050
Wire Wire Line
	6200 1950 5950 1950
Entry Wire Line
	800  3900 900  4000
Entry Wire Line
	800  3800 900  3900
Entry Wire Line
	800  3700 900  3800
Entry Wire Line
	800  3600 900  3700
Entry Wire Line
	800  3500 900  3600
Entry Wire Line
	800  3400 900  3500
Entry Wire Line
	800  3300 900  3400
Entry Wire Line
	800  3200 900  3300
Entry Wire Line
	800  2900 900  3000
Entry Wire Line
	800  2800 900  2900
Entry Wire Line
	800  2700 900  2800
Entry Wire Line
	800  2600 900  2700
Wire Wire Line
	900  4000 1900 4000
Wire Wire Line
	1900 3900 900  3900
Wire Wire Line
	900  3800 1900 3800
Wire Wire Line
	900  3700 1900 3700
Wire Wire Line
	1900 3600 900  3600
Wire Wire Line
	900  3500 1900 3500
Wire Wire Line
	900  3400 1900 3400
Wire Wire Line
	1900 3300 900  3300
Entry Wire Line
	800  2500 900  2600
Entry Wire Line
	800  2400 900  2500
Entry Wire Line
	800  2300 900  2400
Entry Wire Line
	800  2200 900  2300
Wire Wire Line
	900  3000 1900 3000
Wire Wire Line
	1900 2900 900  2900
Wire Wire Line
	900  2800 1900 2800
Wire Wire Line
	900  2600 1900 2600
Wire Wire Line
	900  2700 1900 2700
Wire Wire Line
	1900 2500 900  2500
Wire Wire Line
	900  2400 1900 2400
Wire Wire Line
	1900 2300 900  2300
Wire Wire Line
	4650 3250 4400 3250
Wire Wire Line
	4400 3250 4400 3800
Wire Wire Line
	4400 3800 3300 3800
Wire Wire Line
	3300 3800 3300 3600
Wire Wire Line
	3300 3600 2900 3600
Wire Wire Line
	2900 3700 3250 3700
Wire Wire Line
	3250 3700 3250 3850
Wire Wire Line
	3250 3850 4450 3850
Wire Wire Line
	4450 3850 4450 3350
Wire Wire Line
	4450 3350 4650 3350
Wire Wire Line
	4650 3450 4500 3450
Wire Wire Line
	4500 3450 4500 3900
Wire Wire Line
	4500 3900 3200 3900
Wire Wire Line
	3200 3900 3200 3800
Wire Wire Line
	3200 3800 2900 3800
Wire Wire Line
	2900 3900 3150 3900
Wire Wire Line
	3150 3900 3150 3950
Wire Wire Line
	3150 3950 4550 3950
Wire Wire Line
	4550 3950 4550 3550
Wire Wire Line
	4550 3550 4650 3550
Wire Wire Line
	4650 3650 4600 3650
Wire Wire Line
	4600 3650 4600 4000
Wire Wire Line
	4600 4000 2900 4000
$Comp
L Display_Character:HY1602E DS?
U 1 1 5BF218DC
P 10600 1950
F 0 "DS?" H 10600 2928 50  0000 C CNN
F 1 "HY1602E" H 10600 2837 50  0000 C CNN
F 2 "Display:HY1602E" H 10600 1050 50  0001 C CIN
F 3 "http://www.icbank.com/data/ICBShop/board/HY1602E.pdf" H 10800 2050 50  0001 C CNN
	1    10600 1950
	1    0    0    -1  
$EndComp
Entry Wire Line
	9800 1750 9900 1850
Entry Wire Line
	9800 1850 9900 1950
Entry Wire Line
	9800 1950 9900 2050
Entry Wire Line
	9800 2050 9900 2150
Entry Wire Line
	9800 2150 9900 2250
Entry Wire Line
	9800 2250 9900 2350
Entry Wire Line
	9800 2350 9900 2450
Entry Wire Line
	9800 2450 9900 2550
Wire Wire Line
	9900 1850 10200 1850
Wire Wire Line
	10200 1950 9900 1950
Wire Wire Line
	9900 2050 10200 2050
Wire Wire Line
	10200 2150 9900 2150
Wire Wire Line
	9900 2250 10200 2250
Wire Wire Line
	10200 2350 9900 2350
Wire Wire Line
	9900 2450 10200 2450
Wire Wire Line
	10200 2550 9900 2550
Text Notes 7500 1650 0    50   ~ 0
OV7670
Text Notes 7500 1850 0    50   ~ 0
lcd 1\nlcd 2
Text Notes 7500 1950 0    50   ~ 0
usb3300 ulpi board
Text Notes 7500 2100 0    50   ~ 0
vga
Text Notes 7500 2200 0    50   ~ 0
micro sd
$Comp
L Connector_Generic:Conn_02x09_Odd_Even J?
U 1 1 5BE48B28
P 2000 6550
F 0 "J?" H 2050 7167 50  0000 C CNN
F 1 "OV7670" H 2050 7076 50  0000 C CNN
F 2 "" H 2000 6550 50  0001 C CNN
F 3 "~" H 2000 6550 50  0001 C CNN
	1    2000 6550
	1    0    0    -1  
$EndComp
Wire Wire Line
	1800 6250 1600 6250
Wire Wire Line
	1800 6350 1600 6350
Wire Wire Line
	1800 6450 1600 6450
Wire Wire Line
	1800 6950 1600 6950
Wire Wire Line
	2500 6250 2300 6250
Wire Wire Line
	2500 6350 2300 6350
Wire Wire Line
	2500 6450 2300 6450
Wire Wire Line
	2500 6950 2300 6950
Text Label 1750 6150 2    50   ~ 0
OV7670_VCC
Text Label 2350 6150 0    50   ~ 0
OV7670_GND
Text Label 1750 6250 2    50   ~ 0
OV7670_SDIOC
Text Label 2350 6250 0    50   ~ 0
OV7670_SDIOD
Text Label 1750 6350 2    50   ~ 0
OV7670_VSYNC
Text Label 2350 6350 0    50   ~ 0
OV7670_HREF
Text Label 1750 6450 2    50   ~ 0
OV7670_PCLK
Text Label 2350 6450 0    50   ~ 0
OV7670_XCLK
Text Label 2350 6850 0    50   ~ 0
OV7670_D0
Text Label 2350 6750 0    50   ~ 0
OV7670_D2
Text Label 2350 6650 0    50   ~ 0
OV7670_D4
Text Label 2350 6550 0    50   ~ 0
OV7670_D6
Text Label 1750 6850 2    50   ~ 0
OV7670_D1
Text Label 1750 6750 2    50   ~ 0
OV7670_D3
Text Label 1750 6650 2    50   ~ 0
OV7670_D5
Text Label 1750 6550 2    50   ~ 0
OV7670_D7
Text Label 2350 6950 0    50   ~ 0
OV7670_PWRDN
Text Label 1750 6950 2    50   ~ 0
OV7670_RESET
Entry Wire Line
	800  6450 900  6550
Entry Wire Line
	800  6550 900  6650
Entry Wire Line
	800  6650 900  6750
Entry Wire Line
	800  6750 900  6850
Entry Wire Line
	3150 6850 3250 6950
Entry Wire Line
	3150 6750 3250 6850
Entry Wire Line
	3150 6650 3250 6750
Entry Wire Line
	3150 6550 3250 6650
Wire Bus Line
	800  7600 3250 7600
Wire Wire Line
	900  6850 1800 6850
Wire Wire Line
	900  6750 1800 6750
Wire Wire Line
	900  6650 1800 6650
Wire Wire Line
	900  6550 1800 6550
Wire Wire Line
	2300 6850 3150 6850
Wire Wire Line
	2300 6750 3150 6750
Wire Wire Line
	2300 6650 3150 6650
Wire Wire Line
	2300 6550 3150 6550
Text Label 6050 1550 0    50   ~ 0
B15
Text Label 6050 3050 0    50   ~ 0
B0
Text Label 6050 2950 0    50   ~ 0
B1
Text Label 6050 2850 0    50   ~ 0
B2
Text Label 6050 2750 0    50   ~ 0
B3
Text Label 6050 2650 0    50   ~ 0
B4
Text Label 6050 2550 0    50   ~ 0
B5
Text Label 6050 2450 0    50   ~ 0
B6
Text Label 6050 2350 0    50   ~ 0
B7
Text Label 6050 2250 0    50   ~ 0
B8
Text Label 6050 2150 0    50   ~ 0
B9
Text Label 6050 2050 0    50   ~ 0
B10
Text Label 6050 1950 0    50   ~ 0
B11
Text Label 6050 1850 0    50   ~ 0
B12
Text Label 6050 1750 0    50   ~ 0
B13
Text Label 6050 1650 0    50   ~ 0
B14
Text Label 1000 4000 0    50   ~ 0
B0
Text Label 1000 3900 0    50   ~ 0
B1
Text Label 1000 3800 0    50   ~ 0
B2
Text Label 1000 3700 0    50   ~ 0
B3
Text Label 1000 3600 0    50   ~ 0
B4
Text Label 1000 3500 0    50   ~ 0
B5
Text Label 1000 3400 0    50   ~ 0
B6
Text Label 1000 3000 0    50   ~ 0
B8
Text Label 1000 3300 0    50   ~ 0
B7
Text Label 1000 2800 0    50   ~ 0
B10
Text Label 1000 2900 0    50   ~ 0
B9
Text Label 1000 2700 0    50   ~ 0
B11
Text Label 1000 2600 0    50   ~ 0
B12
Text Label 1000 2500 0    50   ~ 0
B13
Text Label 1000 2400 0    50   ~ 0
B14
Text Label 1000 2300 0    50   ~ 0
B15
Text Label 3000 6850 0    50   ~ 0
B0
Text Label 1000 6850 0    50   ~ 0
B1
Text Label 3000 6750 0    50   ~ 0
B2
Text Label 1000 6750 0    50   ~ 0
B3
Text Label 3000 6650 0    50   ~ 0
B4
Text Label 1000 6650 0    50   ~ 0
B5
Text Label 3000 6550 0    50   ~ 0
B6
Text Label 1000 6550 0    50   ~ 0
B7
$Comp
L power:GND #PWR?
U 1 1 5BEE6E4D
P 3000 6150
F 0 "#PWR?" H 3000 5900 50  0001 C CNN
F 1 "GND" H 3005 5977 50  0000 C CNN
F 2 "" H 3000 6150 50  0001 C CNN
F 3 "" H 3000 6150 50  0001 C CNN
	1    3000 6150
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5BEE6E84
P 1150 6150
F 0 "#PWR?" H 1150 5900 50  0001 C CNN
F 1 "GND" V 1155 6022 50  0000 R CNN
F 2 "" H 1150 6150 50  0001 C CNN
F 3 "" H 1150 6150 50  0001 C CNN
	1    1150 6150
	0    1    1    0   
$EndComp
Wire Wire Line
	1150 6150 1800 6150
Wire Wire Line
	2300 6150 3000 6150
Text Label 4500 3100 0    50   ~ 0
A0
Text Label 4500 3000 0    50   ~ 0
A1
Text Label 4500 2900 0    50   ~ 0
A2
Text Label 4500 2800 0    50   ~ 0
A3
Text Label 4500 2700 0    50   ~ 0
A4
Text Label 4500 2600 0    50   ~ 0
A5
Text Label 4500 2500 0    50   ~ 0
A6
Text Label 4500 2400 0    50   ~ 0
A7
Text Label 4500 2300 0    50   ~ 0
A8
Text Label 4500 2200 0    50   ~ 0
A9
Text Label 4500 2100 0    50   ~ 0
A10
Text Label 4500 2000 0    50   ~ 0
A11
Text Label 4500 1900 0    50   ~ 0
A12
Text Label 4500 1800 0    50   ~ 0
A13
Text Label 4500 1700 0    50   ~ 0
A14
Text Label 4500 1600 0    50   ~ 0
A15
Text Label 4500 1500 0    50   ~ 0
A16
Text Label 3000 3500 0    50   ~ 0
A0
Text Label 3000 3200 0    50   ~ 0
A1
Text Label 3000 3100 0    50   ~ 0
A2
Text Label 3000 3000 0    50   ~ 0
A3
Text Label 3000 2900 0    50   ~ 0
A4
Text Label 3000 2800 0    50   ~ 0
A5
Text Label 3000 2700 0    50   ~ 0
A6
Text Label 3000 2600 0    50   ~ 0
A7
Text Label 3000 2500 0    50   ~ 0
A8
Text Label 3000 2200 0    50   ~ 0
A9
Text Label 3000 2100 0    50   ~ 0
A10
Text Label 3000 2000 0    50   ~ 0
A11
Text Label 3000 1900 0    50   ~ 0
A12
Text Label 3000 1800 0    50   ~ 0
A13
Text Label 3000 1700 0    50   ~ 0
A14
Text Label 3000 1600 0    50   ~ 0
A15
Text Label 3000 1500 0    50   ~ 0
A16
Wire Bus Line
	9800 700  6300 700 
Wire Bus Line
	3250 6650 3250 7600
Wire Bus Line
	9800 700  9800 2450
Wire Bus Line
	3550 1400 3550 3600
Wire Bus Line
	4400 1400 4400 3000
Wire Bus Line
	6300 700  6300 3150
Wire Bus Line
	800  700  800  7600
Connection ~ 6300 700 
Wire Bus Line
	6300 700  800  700 
$EndSCHEMATC