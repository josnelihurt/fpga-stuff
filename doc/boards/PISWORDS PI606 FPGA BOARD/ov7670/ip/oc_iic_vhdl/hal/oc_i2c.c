#include "system.h"
#include "oc_i2c_regs.h"
#include "alt_types.h"

#define AT24C64

void I2CWaitTIP(alt_u32 base);

/*********************************************************************************************************
** Function name:			InitI2C
**
** Descriptions:			Initialize the I2C Open Core. The frequency of SCL is set as freq
**                    Interrupt will be or not be enabled by the IEN  
**
** input parameters:	base: The base address of I2C Core;
**                    freq: The frequency of SCL we want
**                    IEN : When the IEN is 1, interrupt will be enabled;
**                          When the IEN is NOT 1, interrupt will be disabled.                       
**						
** Returned value:		None 
**         
** Used global variables:	None
** Calling modules:			  None
**
**-------------------------------------------------------------------------------------------------------
** Modified by:
** Modified date:
**------------------------------------------------------------------------------------------------------
********************************************************************************************************/
void InitI2C(alt_u32 base, alt_u32 freq, alt_u8 IEN)
{
	alt_u32 prescale;
	// Calculate the prescale value
	prescale = ALT_CPU_FREQ/((freq<<2) + freq);
  // Setup prescaler for the freq of SCL with sysclk of ALT_CPU_FREQ
  IOWR_OC_I2C_PRERLO(base, prescale & 0xff);
  IOWR_OC_I2C_PRERHI(base,(prescale & 0xff00)>>8);
  // Enable core
  if(IEN == 1) // Enable interrupt
  {
  	IOWR_OC_I2C_CTR(base, 0xC0);
  }
  else // Enable core while disable interrupt
  {
  	IOWR_OC_I2C_CTR(base, 0x80);
  }
}

/*********************************************************************************************************
** Function name:     I2CWaitTIP
**
** Descriptions:      Wait for the completion of transfer. 
**
** input parameters:  base:    The base address of I2C Core;
**                 
**            
** Returned value:    None 
**         
** Used global variables: None
** Calling modules:       None
**
** Created by:        Jing.Zhang
** Created Date:      2005/09/30
**-------------------------------------------------------------------------------------------------------
** Modified by:
** Modified date:
**------------------------------------------------------------------------------------------------------
********************************************************************************************************/
void I2CWaitTIP(alt_u32 base)
{
  while ((IORD_OC_I2C_SR(base) & OC_I2C_SR_TIP_MSK) > 0) {}
}

/*********************************************************************************************************
** Function name:			I2CWrite
**
** Descriptions:			Write num bytes data to slave device by I2C bus. 
**
** input parameters:	base:    The base address of I2C Core;
**                    address: The address of I2C slave device;
**                    reg:     The register of I2C slave device;
**                    buf:     The pointer to data buffer;
**                    num:     The num bytes of data which will be written                       
**						
** Returned value:		None 
**         
** Used global variables:	None
** Calling modules:			  None

**-------------------------------------------------------------------------------------------------------
** Modified by:
** Modified date:
**------------------------------------------------------------------------------------------------------
********************************************************************************************************/
void I2CWrite(alt_u32 base, alt_u8 address, alt_u16 reg, alt_u8 *buf, alt_u16 num)
{
	alt_u16 i,tmp;
	// Wait for the completion of transfer
	I2CWaitTIP(base);
 
  // write address of I2C slave device
  // and generate START & WR command
  IOWR_OC_I2C_TXR(base, address);
  IOWR_OC_I2C_CR(base, OC_I2C_CR_STA_MSK | OC_I2C_CR_WR_MSK);
  I2CWaitTIP(base);

#ifdef AT24C64
  // write register address H
  IOWR_OC_I2C_TXR(base, reg>>8);
  IOWR_OC_I2C_CR(base, OC_I2C_CR_WR_MSK);
  I2CWaitTIP(base);
#endif

  // write register address(L)
  IOWR_OC_I2C_TXR(base, reg & 0x00ff);
  IOWR_OC_I2C_CR(base, OC_I2C_CR_WR_MSK);
  I2CWaitTIP(base);

  // write data
  if(num > 0) 
  {
  	tmp = num - 1;
  	for(i=0; i<tmp; i++)
  	{
  		 IOWR_OC_I2C_TXR(base,*buf++);
       IOWR_OC_I2C_CR(base, OC_I2C_CR_WR_MSK);
       I2CWaitTIP(base);
  	}
  }

  // write data with STOP signal
  IOWR_OC_I2C_TXR(base, *buf);
  IOWR_OC_I2C_CR(base, OC_I2C_CR_WR_MSK | OC_I2C_CR_STO_MSK);
  I2CWaitTIP(base);
}

/*********************************************************************************************************
** Function name:			I2CRead
**
** Descriptions:			Read num bytes data from slave device by I2C bus. 
**
** input parameters:	base:    The base address of I2C Core;
**                    address: The address of I2C slave device;
**                    reg:     The register of I2C slave device;
**                    buf:     The pointer to data buffer;
**                    num:     The num bytes of data which will be written                       
**						
** Returned value:		None 
**         
** Used global variables:	None
** Calling modules:			  None
**
** Created by:				Jing.Zhang
** Created Date:			2005/09/30
**-------------------------------------------------------------------------------------------------------
** Modified by:
** Modified date:
**------------------------------------------------------------------------------------------------------
********************************************************************************************************/
void I2CRead(alt_u32 base, alt_u8 address, alt_u16 reg, alt_u8 *buf, alt_u16 num)
{
	alt_u16 i,tmp;
	// Wait for the completion of transfer
	I2CWaitTIP(base);
 
  // write address of I2C slave device
  // and generate START & WR command
  IOWR_OC_I2C_TXR(base, address);
  IOWR_OC_I2C_CR(base, OC_I2C_CR_STA_MSK | OC_I2C_CR_WR_MSK);
  I2CWaitTIP(base);

#ifdef AT24C64
  // write register address H
  IOWR_OC_I2C_TXR(base, reg>>8);
  IOWR_OC_I2C_CR(base, OC_I2C_CR_WR_MSK);
  I2CWaitTIP(base);
#endif

  // write register address
  IOWR_OC_I2C_TXR(base, reg & 0x00ff);
  IOWR_OC_I2C_CR(base, OC_I2C_CR_WR_MSK);
  I2CWaitTIP(base);

  // write address of I2C slave device
  // and RD command
  IOWR_OC_I2C_TXR(base, address|1);
  IOWR_OC_I2C_CR(base, OC_I2C_CR_STA_MSK | OC_I2C_CR_WR_MSK);
  I2CWaitTIP(base);
  // Read data
  if(num > 0) 
  {
  	tmp = num - 1;
  	for(i=0; i<tmp; i++)
  	{
  		 IOWR_OC_I2C_CR(base,OC_I2C_CR_RD_MSK);// | I2C_CR_ACK);
       I2CWaitTIP(base);
       *buf++ = IORD_OC_I2C_RXR(base);
  	}
  }

  // Read data with STOP signal
  IOWR_OC_I2C_CR(base,OC_I2C_CR_RD_MSK | OC_I2C_CR_ACK_MSK | OC_I2C_CR_STO_MSK);
  I2CWaitTIP(base);
  *buf++ = IORD_OC_I2C_RXR(base);
}


