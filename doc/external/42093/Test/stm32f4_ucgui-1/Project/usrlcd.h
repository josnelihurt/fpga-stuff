#include "stm32f4_discovery.h"
#define LCD_RS_1 GPIO_SetBits(GPIOA, GPIO_Pin_5)
#define LCD_RS_0 GPIO_ResetBits(GPIOA, GPIO_Pin_5)
#define LCD_WR_1 GPIO_SetBits(GPIOA, GPIO_Pin_2)
#define LCD_WR_0 GPIO_ResetBits(GPIOA, GPIO_Pin_2)
#define LCD_RD_1 GPIO_SetBits(GPIOA, GPIO_Pin_3)
#define LCD_RD_0 GPIO_ResetBits(GPIOA, GPIO_Pin_3)
#define LCD_CS_1 GPIO_SetBits(GPIOA, GPIO_Pin_0)
#define LCD_CS_0 GPIO_ResetBits(GPIOA, GPIO_Pin_0)
#define LCD_RST_1 GPIO_SetBits(GPIOA, GPIO_Pin_1)
#define LCD_RST_0 GPIO_ResetBits(GPIOA, GPIO_Pin_1)

void Delay(__IO uint32_t nCount);
void Lcd_Init(void);
void Pant(uint16_t data);
void Address_set(unsigned int x1,unsigned int y1,unsigned int x2,unsigned int y2);
void Lcd_Write_Data(uint16_t da);
void Lcd_Write_Datakk(uint16_t data);
void LCD_SetPixel(uint16_t x,uint16_t y,uint16_t color);
uint16_t LCD_ReadPixel(uint16_t x,uint16_t y);
void Lcd_Write_Com(uint16_t data);
void Lcd_Write_Com_Data(uint16_t com,uint16_t val);
void ioinit(void);
