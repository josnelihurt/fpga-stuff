#ifndef __OC_I2C_H__
#define __OC_I2C_H__

#include "alt_types.h"

void InitI2C(alt_u32 base, alt_u32 freq, alt_u8 IEN);
void I2CWrite(alt_u32 base,alt_u8 address, alt_u16 reg, alt_u8 *buf, alt_u16 num);
void I2CRead(alt_u32 base,alt_u8 address, alt_u16 reg, alt_u8 *buf, alt_u16 num);


#endif /* __OC_I2C_H__ */
