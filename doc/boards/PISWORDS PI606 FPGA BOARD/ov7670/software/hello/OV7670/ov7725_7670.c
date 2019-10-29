#include <stdint.h>
#include "ov7725cfg.h"
#include "ov7670cfg.h"
#include "ov7725_7670.h"
#include "sccb.h"
#include "unistd.h"

uint8_t OV7xxx_Init(void)
{
	uint8_t PID,VER;
	uint16_t i=0;
	uint8_t CMOS_MODEL;
	SCCB_Init(400000, 0);        		//初始化SCCB 的IO
 	if(SCCB_WR_Reg(0x12,0x80))return 1;	//复位SCCB
	usleep(50000);
	//读取产品型号
	VER=SCCB_RD_Reg(0x0b);
	PID=SCCB_RD_Reg(0x0a);

	if((PID == 0x77) & (VER == 0x21))
	{
		CMOS_MODEL = OV7725;
		//初始化序列
		for(i=0;i<sizeof(ov7725_init_reg_tbl)/sizeof(ov7725_init_reg_tbl[0]);i++)
		{
			SCCB_WR_Reg(ov7725_init_reg_tbl[i][0],ov7725_init_reg_tbl[i][1]);
			usleep(2000);
		}
	}
	else if((PID == 0x76) & (VER == 0x73))
	{
		CMOS_MODEL = OV7670;
		//初始化序列
		for(i=0;i<sizeof(ov7670_init_reg_tbl)/sizeof(ov7670_init_reg_tbl[0]);i++)
		{
			SCCB_WR_Reg(ov7670_init_reg_tbl[i][0],ov7670_init_reg_tbl[i][1]);
			usleep(2000);
		}
	}
	else
		CMOS_MODEL = UNKNOWN;
   	return CMOS_MODEL; 	//ok
}
