PCBNEW-LibModule-V1  Thu 23 Aug 2012 11:02:52 AM COT
# encoding utf-8
Units deci-mils
$INDEX
Pulse_smd_KFC-A04-02
con-pulse-J1
$EndINDEX
$MODULE Pulse_smd_KFC-A04-02
Po 0 0 0 15 50365429 00000000 ~~
Li Pulse_smd_KFC-A04-02
Sc 0
AR 
Op 0 0 0
T0 1500 3000 600 600 0 120 N I 21 N "Pulse_smd_KFC-A04-02"
T1 2000 1500 600 600 0 120 N V 21 N "VAL**"
DC 1000 1000 1150 950 150 21
DS 500 500 500 1500 150 21
DS 1500 1000 1000 1000 150 21
DS 0 1000 500 1000 150 21
DS 1500 0 1500 2000 150 21
DS 0 0 0 2000 150 21
$PAD
Sh "1" R 394 394 0 0 0
Dr 0 0 0
At SMD N 00888000
Ne 0 ""
Po 0 0
$EndPAD
$PAD
Sh "2" R 394 394 0 0 0
Dr 0 0 0
At SMD N 00888000
Ne 0 ""
Po 1457 0
$EndPAD
$PAD
Sh "1" R 394 394 0 0 0
Dr 0 0 0
At SMD N 00888000
Ne 0 ""
Po 0 2047
$EndPAD
$PAD
Sh "2" R 394 394 0 0 0
Dr 0 0 0
At SMD N 00888000
Ne 0 ""
Po 1457 2047
$EndPAD
$EndMODULE Pulse_smd_KFC-A04-02
$MODULE con-pulse-J1
Po 0 0 0 15 5028AC03 00000000 ~~
Li con-pulse-J1
Cd PULSEJACK (TM) 1X1 TAB-UP RJ45
Kw PULSEJACK (TM) 1X1 TAB-UP RJ45
Sc 0
AR /4E9D76FD/4DE92C0F/4EA5F379
Op 0 0 0
At VIRTUAL
T0 1941 -3683 500 500 0 35 N V 21 N "J1201"
T1 150 1504 500 500 0 35 N V 21 N "RJ45-TRANSFO"
DS -3309 6712 3309 6712 80 21
DS 3309 6712 3309 -3208 80 21
DS -3309 -3208 -3309 6712 80 21
DS -3309 -3208 3309 -3208 80 21
DS -3301 6685 -3466 6423 80 21
DS -4126 3603 -4085 3658 80 21
DS 3301 6685 3466 6423 80 21
DS 4126 3603 4085 3658 80 21
DS -3309 -3208 -3309 500 80 21
DS -3309 2000 -3309 6712 80 21
DS 3309 6712 3309 2000 80 21
DS 3309 500 3309 -3208 80 21
DS -2713 6666 -2589 3484 80 21
DS -2506 6666 -2424 3884 80 21
DS -1831 3884 -1735 6680 80 21
DS -1528 6666 -1652 3484 80 21
DS -2479 3374 -1763 3374 80 21
DS 2713 6666 2589 3484 80 21
DS 2506 6666 2424 3884 80 21
DS 1831 3884 1735 6680 80 21
DS 1528 6666 1652 3484 80 21
DS 2479 3374 1763 3374 80 21
DC 2250 2500 2574 2824 50 21
DS 1600 2500 2899 2500 50 21
DS 2250 3149 2250 1850 50 21
DC -2250 2500 -2574 2824 50 21
DS -2899 2500 -1600 2500 50 21
DS -2250 3149 -2250 1850 50 21
DA -230 4380 -3466 6423 371 80 21
DA -4628 4008 -4167 3645 430 80 21
DA -4144 3626 -4167 3645 1665 80 21
DA -4471 3948 -4085 3658 351 80 21
DA -8834 4078 -3988 3933 34 80 21
DA -69 4339 -3328 6519 354 80 21
DA 230 4380 4044 4057 371 80 21
DA 4628 4008 4044 4057 430 80 21
DA 4144 3626 4126 3603 1665 80 21
DA 4471 3948 3988 3933 351 80 21
DA 8834 4078 3988 4222 34 80 21
DA 69 4339 3988 4222 354 80 21
DA -2474 3489 -2589 3484 855 80 21
DA -2128 3893 -2424 3884 1765 80 21
DA -1767 3489 -1763 3374 855 80 21
DA 2474 3489 2479 3374 855 80 21
DA 2128 3893 1831 3884 1765 80 21
DA 1767 3489 1652 3484 855 80 21
$PAD
Sh "1" C 511 511 0 0 0
Dr 354 0 0
At STD N 00ACFFFF
Ne 3 "/cpu/ETHERNET/tx+"
Po 1750 -1000
$EndPAD
$PAD
Sh "2" C 511 511 0 0 0
Dr 354 0 0
At STD N 00ACFFFF
Ne 6 "N-000202"
Po 1250 0
$EndPAD
$PAD
Sh "3" C 511 511 0 0 0
Dr 354 0 0
At STD N 00ACFFFF
Ne 4 "/cpu/ETHERNET/tx-"
Po 750 -1000
$EndPAD
$PAD
Sh "4" C 511 511 0 0 0
Dr 354 0 0
At STD N 00ACFFFF
Ne 1 "/cpu/ETHERNET/rx+"
Po 250 0
$EndPAD
$PAD
Sh "5" C 511 511 0 0 0
Dr 354 0 0
At STD N 00B8FFFF
Ne 6 "N-000202"
Po -250 -1000
$EndPAD
$PAD
Sh "6" C 511 511 0 0 0
Dr 354 0 0
At STD N 00ACFFFF
Ne 2 "/cpu/ETHERNET/rx-"
Po -750 0
$EndPAD
$PAD
Sh "7" C 511 511 0 0 0
Dr 354 0 0
At STD N 00ACFFFF
Ne 0 ""
Po -1250 -1000
$EndPAD
$PAD
Sh "8" C 511 511 0 0 0
Dr 354 0 0
At STD N 00ACFFFF
Ne 5 "GND"
Po -1750 0
$EndPAD
$PAD
Sh "YK9" C 560 560 0 0 0
Dr 393 0 0
At STD N 00BCFFFF
Ne 0 ""
Po 2151 -2901
$EndPAD
$PAD
Sh "YA" C 560 560 0 0 0
Dr 393 0 0
At STD N 00ACFFFF
Ne 0 ""
Po 1151 -2901
$EndPAD
$PAD
Sh "GK" C 560 560 0 0 0
Dr 393 0 0
At STD N 00ACFFFF
Ne 0 ""
Po -1151 -2901
$EndPAD
$PAD
Sh "GA" C 560 560 0 0 0
Dr 393 0 0
At STD N 00ACFFFF
Ne 0 ""
Po -2151 -2901
$EndPAD
$PAD
Sh "19" C 859 859 0 0 0
Dr 629 0 0
At STD N 00BCFFFF
Ne 0 ""
Po -3100 1299
$EndPAD
$PAD
Sh "19" C 859 859 0 0 0
Dr 629 0 0
At STD N 00ACFFFF
Ne 0 ""
Po 3100 1299
$EndPAD
$PAD
Sh "17" C 1300 1300 0 0 0
Dr 1200 0 0
At STD N 00ACFFFF
Ne 0 ""
Po 2250 2500
$EndPAD
$PAD
Sh "18" C 1300 1300 0 0 0
Dr 1200 0 0
At STD N 00BCFFFF
Ne 0 ""
Po -2250 2500
$EndPAD
$SHAPE3D
Na "connectors/RJ45_8.wrl"
Sc 0.4 0.4 0.4
Of 0 -0.25 0
Ro 0 0 0
$EndSHAPE3D
$EndMODULE con-pulse-J1
$EndLIBRARY