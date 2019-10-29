/****************************************Copyright (c)**************************************************
**--------------File Info-------------------------------------------------------------------------------
** File name:			  oc_i2c_regs.h
** Latest modified Date:
** Latest Version:		  1.0
** Descriptions:		  Provide Register definitions and register accessor Macro
**                        for the I2C Master Core and
**------------------------------------------------------------------------------------------------------
** Modified by:
** Modified date:
** Version:
** Descriptions:
**
********************************************************************************************************/
#ifndef __OC_I2C_REGS_H__
#define __OC_I2C_REGS_H__

#include <io.h>
//PRERlo Clock Prescale register low byte
#define IORD_OC_I2C_PRERLO(base)                   IORD_8DIRECT(base, 0)
#define IOWR_OC_I2C_PRERLO(base, data)             IOWR_8DIRECT(base, 0, data)

//PRERhi Clock Prescale register High byte
#define IORD_OC_I2C_PRERHI(base)                   IORD_8DIRECT(base, 1)
#define IOWR_OC_I2C_PRERHI(base, data)             IOWR_8DIRECT(base, 1, data)

//CTR Control register
#define IORD_OC_I2C_CTR(base)                      IORD_8DIRECT(base, 2)
#define IOWR_OC_I2C_CTR(base, data)                IOWR_8DIRECT(base, 2, data)
#define OC_I2C_CTR_EN_MSK                          (0x80)
#define OC_I2C_CTR_EN_OFST                         (7)
#define OC_I2C_CTR_IEN_MSK                         (0x40)
#define OC_I2C_CTR_IEN_OFST                        (6)

//RXR Receiver register
#define IORD_OC_I2C_RXR(base)                      IORD_8DIRECT(base, 3)

//TXR Transmit register
#define IOWR_OC_I2C_TXR(base, data)                IOWR_8DIRECT(base, 3, data)
#define OC_I2C_TXR_RW_MSK                          (0x01)
#define OC_I2C_TXR_RW_OFST                         (0)

//SR Status register
#define IORD_OC_I2C_SR(base)                       IORD_8DIRECT(base, 4)
#define OC_I2C_SR_RxACK_MSK                        (0x80)
#define OC_I2C_SR_RxACK_OFST                       (7)
#define OC_I2C_SR_BSY_MSK                          (0x40)
#define OC_I2C_SR_BSY_OFST                         (6)
#define OC_I2C_SR_TIP_MSK                          (0x02)
#define OC_I2C_SR_TIP_OFST                         (1)
#define OC_I2C_SR_IF_MSK                           (0x01)
#define OC_I2C_SR_IF_OFST                          (0)
//CR Command register
#define IOWR_OC_I2C_CR(base, data)                 IOWR_8DIRECT(base, 4, data)
#define OC_I2C_CR_STA_MSK                          (0x80)
#define OC_I2C_CR_STA_OFST                         (7)
#define OC_I2C_CR_STO_MSK                          (0x40)
#define OC_I2C_CR_STO_OFST                         (6)
#define OC_I2C_CR_RD_MSK                           (0x20)
#define OC_I2C_CR_RD_OFST                          (5)
#define OC_I2C_CR_WR_MSK                           (0x10)
#define OC_I2C_CR_WR_OFST                          (4)
#define OC_I2C_CR_ACK_MSK                          (0x08)
#define OC_I2C_CR_ACK_OFST                         (3)
#define OC_I2C_CR_IACK_MSK                         (0x01) 
#define OC_I2C_CR_IACK_OFST                        (0)

#endif /* __OC_I2C_REGS_H__ */
