#include "sccb.h"
#include "oc_i2c_regs.h"
#include "system.h"

#define SCCB_BASE OC_IIC_0_BASE

void SCCBWaitTIP(void)
{
  while ((IORD_OC_I2C_SR(SCCB_BASE) & OC_I2C_SR_TIP_MSK) > 0) {}
}

void SCCB_Init(uint32_t freq, uint8_t IEN)
{
	alt_u32 prescale;
	// Calculate the prescale value
	prescale = ALT_CPU_FREQ/((freq<<2) + freq) - 1;
  // Setup prescaler for the freq of SCL with sysclk of ALT_CPU_FREQ
  IOWR_OC_I2C_PRERLO(SCCB_BASE, prescale & 0xff);
  IOWR_OC_I2C_PRERHI(SCCB_BASE,(prescale & 0xff00)>>8);
  // Enable core
  if(IEN == 1) // Enable interrupt
  {
  	IOWR_OC_I2C_CTR(SCCB_BASE, 0xC0);
  }
  else // Enable core while disable interrupt
  {
  	IOWR_OC_I2C_CTR(SCCB_BASE, 0x80);
  }
}


uint8_t SCCB_WR_Reg(uint8_t RegAddr, uint8_t Data)
{
	// Wait for the completion of transfer
	SCCBWaitTIP();

	// write address of I2C slave device
	// and generate START & WR command
	IOWR_OC_I2C_TXR(SCCB_BASE, SCCB_ID);
	IOWR_OC_I2C_CR(SCCB_BASE, OC_I2C_CR_STA_MSK | OC_I2C_CR_WR_MSK);
	SCCBWaitTIP();

	// write register address
	IOWR_OC_I2C_TXR(SCCB_BASE, RegAddr);
	IOWR_OC_I2C_CR(SCCB_BASE, OC_I2C_CR_WR_MSK);
	SCCBWaitTIP();

	// write data with STOP signal
	IOWR_OC_I2C_TXR(SCCB_BASE, Data);
	IOWR_OC_I2C_CR(SCCB_BASE, OC_I2C_CR_WR_MSK | OC_I2C_CR_STO_MSK);
	SCCBWaitTIP();

	return 0;
}

uint8_t SCCB_RD_Reg(uint8_t reg)
{
	// Wait for the completion of transfer
	SCCBWaitTIP();

  // write address of I2C slave device
  // and generate START & WR command
  IOWR_OC_I2C_TXR(SCCB_BASE, SCCB_ID);
  IOWR_OC_I2C_CR(SCCB_BASE, OC_I2C_CR_STA_MSK | OC_I2C_CR_WR_MSK);
  SCCBWaitTIP();


  // write register address
  IOWR_OC_I2C_TXR(SCCB_BASE, reg & 0x00ff);
  IOWR_OC_I2C_CR(SCCB_BASE, OC_I2C_CR_WR_MSK | OC_I2C_CR_STO_MSK);
  SCCBWaitTIP();

  // write address of I2C slave device
  // and RD command
  IOWR_OC_I2C_TXR(SCCB_BASE, SCCB_ID|1);
  IOWR_OC_I2C_CR(SCCB_BASE, OC_I2C_CR_STA_MSK | OC_I2C_CR_WR_MSK);
  SCCBWaitTIP();

  // Read data with STOP signal
  IOWR_OC_I2C_CR(SCCB_BASE,OC_I2C_CR_RD_MSK | OC_I2C_CR_ACK_MSK | OC_I2C_CR_STO_MSK);
  SCCBWaitTIP();
  return IORD_OC_I2C_RXR(SCCB_BASE);
}
