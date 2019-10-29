#ifndef __SCCB_H
#define __SCCB_H

#include <stdint.h>

#define SCCB_ID   			0X42  			//OV7670/7725µÄID

///////////////////////////////////////////
void SCCB_Init(uint32_t freq, uint8_t IEN);
uint8_t SCCB_WR_Reg(uint8_t RegAddr, uint8_t Data);
uint8_t SCCB_RD_Reg(uint8_t reg);

#endif













