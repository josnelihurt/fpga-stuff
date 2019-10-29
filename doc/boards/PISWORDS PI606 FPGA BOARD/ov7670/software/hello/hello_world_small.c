#include <stdint.h>
#include "OV7670/ov7725_7670.h"
#include "system.h"
#include "OV7670/sccb.h"
#include "unistd.h"
#include "sys/alt_stdio.h"
#include "altera_avalon_uart_regs.h"
#include "altera_avalon_pio_regs.h"

int main(void)
{
	uint8_t *data;
	uint32_t i;
	uint8_t error = 2;
	uint8_t CMOS_MODEL;

label1:
	CMOS_MODEL = OV7xxx_Init();
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_RESET_BASE, 0);
	usleep(1000);
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_RESET_BASE, 1);
	usleep(1000);
	if(CMOS_MODEL == OV7725)
	{
		alt_putstr("CMOS Init OK,The Model is OV7725!\n");
	}else if(CMOS_MODEL == OV7670){
		alt_putstr("CMOS Init OK,The Model is OV7670!\n");
	}
	else
	{
		alt_putstr("Can't recognize the Model!\n");
		return 0;
	}
	alt_putstr("You can send a register address to modify the value in it through the serial port\n");
	alt_putstr("For Example: Send 0x42 0x1e 0x01 in hex format, You can mirror of the image in vertical direction.(For OV7670)\n");
	alt_putstr("note:0x42 is the id of CMOS, 0x1e is one of the register address, 0x01 is the new value\n");

 	while(1)
	{
 		if(IORD_ALTERA_AVALON_UART_STATUS(UART_0_BASE) & ALTERA_AVALON_UART_STATUS_RRDY_MSK)	//接收到数据
 		{
 			data[0] = IORD_ALTERA_AVALON_UART_RXDATA(UART_0_BASE);	//读出接收到数据
 			if(data[0] == SCCB_ID)	//是要对7725/7670进行操作
 			{
 				i = 1000000;
 				while((!(IORD_ALTERA_AVALON_UART_STATUS(UART_0_BASE) & ALTERA_AVALON_UART_STATUS_RRDY_MSK)) && i)//等待接收到数据或者超时溢出
 				{
 					i--;
 				}
 				if(IORD_ALTERA_AVALON_UART_STATUS(UART_0_BASE) & ALTERA_AVALON_UART_STATUS_RRDY_MSK)//如果接收到数据
 				{
 					data[1] = IORD_ALTERA_AVALON_UART_RXDATA(UART_0_BASE);	//读出接收到数据
 					i = 1000000;
					while((!(IORD_ALTERA_AVALON_UART_STATUS(UART_0_BASE) & ALTERA_AVALON_UART_STATUS_RRDY_MSK)) && i)//等待接收到数据或者超时溢出
					{
						i--;
					}
					if(IORD_ALTERA_AVALON_UART_STATUS(UART_0_BASE) & ALTERA_AVALON_UART_STATUS_RRDY_MSK)//如果接收到数据
					{
						data[2] = IORD_ALTERA_AVALON_UART_RXDATA(UART_0_BASE);	//读出接收到数据
						error = 0;
					}
					else
						error = 1;
 				}
 				else
 					error = 1;
 			}
 			else
 				error = 1;
 		}

 		if(!error)
 		{
 			if((data[1] & data[2]) == 0xff)
 			{
 				data[1] = 0;
 				data[2] = 0;
 				goto label1;
 			}
 			else{
 				SCCB_WR_Reg(data[1],data[2]);
 				error = 2;
 			}
 		}
 		else if(error == 1){
 			alt_putstr("CMD ERROR!!!\n");
 			error = 2;
 		}
	}

	return 0;
}

