#include"usrlcd.h"
GPIO_InitTypeDef  GPIO_InitStructure;
void ioinit(void)
{
  RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOD, ENABLE);
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_All;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;
  GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_100MHz;
  GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;
  GPIO_Init(GPIOD, &GPIO_InitStructure);
  
  RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOC, ENABLE);
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_7;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;
  GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_100MHz;
  GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;
  GPIO_Init(GPIOC, &GPIO_InitStructure);
  
  RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOA, ENABLE);
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_0|GPIO_Pin_1|GPIO_Pin_2|GPIO_Pin_3|GPIO_Pin_4|GPIO_Pin_5;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;
  GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_100MHz;
  GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;
  GPIO_Init(GPIOA, &GPIO_InitStructure);
}


void Delay(volatile uint32_t nCount)
{
  while(nCount--)
  {
  }
}

void LCD_Writ_Bus(uint16_t data)
{
GPIO_Write(GPIOD,data);
LCD_WR_0;
LCD_WR_1; 
}  

void Lcd_Write_Datakk(uint16_t data)
{
  LCD_RS_1;
  GPIO_Write(GPIOD,data);
  LCD_WR_0;
  LCD_WR_1; 
}

void Lcd_Write_Com(uint16_t data)	 //发送命令
{	
LCD_RS_0;
LCD_Writ_Bus(data);
}

void Lcd_Write_Data(uint16_t da)	//发送数据
{
LCD_RS_1;
LCD_Writ_Bus(da);
}

void Lcd_Write_Com_Data(uint16_t com,uint16_t val)		   //发送数据命令
{
Lcd_Write_Com(com);
Lcd_Write_Data(val);
}


void LCD_SetPixel(uint16_t x,uint16_t y,uint16_t color)
{
  Lcd_Write_Com_Data(0x0003,x);
  Lcd_Write_Com_Data(0x0007,y);
  Lcd_Write_Com(0x0022);	
  Lcd_Write_Datakk(color);
}


uint16_t LCD_ReadPixel(uint16_t x,uint16_t y)
{
  return 0x5555;
}


void Address_set(unsigned int x1,unsigned int y1,unsigned int x2,unsigned int y2)
{
Lcd_Write_Com_Data(0x0003,x1);
Lcd_Write_Com_Data(0x0006,y1>>8);
Lcd_Write_Com_Data(0x0007,y1);	
Lcd_Write_Com_Data(0x0005,x2);
Lcd_Write_Com_Data(0x0008,y2>>8);
Lcd_Write_Com_Data(0x0009,y2);
Lcd_Write_Com(0x0022);							 
}

void Lcd_Init(void)
{			 	
LCD_RST_1;
Delay(0xFFFF);
LCD_RST_0;
Delay(0xFFFF);
LCD_RST_1;
LCD_CS_1;
LCD_RD_1;
LCD_WR_1;
Delay(0xFFFF);
LCD_CS_0;  //打开片选使能
Lcd_Write_Com(0x0083);           
Lcd_Write_Data(0x0002);  //TESTM=1 
Lcd_Write_Com(0x0085);  
Lcd_Write_Data(0x0003);  //VDC_SEL=011
Lcd_Write_Com(0x008B);  
Lcd_Write_Data(0x0001);
Lcd_Write_Com(0x008C);  
Lcd_Write_Data(0x0093); //STBA[7]=1,STBA[5:4]=01,STBA[1:0]=11
Lcd_Write_Com(0x0091);  
Lcd_Write_Data(0x0001); //DCDC_SYNC=1
Lcd_Write_Com(0x0083);  
Lcd_Write_Data(0x0000); //TESTM=0//Gamma Setting
Lcd_Write_Com(0x003E);  
Lcd_Write_Data(0x00B0);
Lcd_Write_Com(0x003F);  
Lcd_Write_Data(0x0003);
Lcd_Write_Com(0x0040);  
Lcd_Write_Data(0x0010);
Lcd_Write_Com(0x0041);  
Lcd_Write_Data(0x0056);
Lcd_Write_Com(0x0042);  
Lcd_Write_Data(0x0013);
Lcd_Write_Com(0x0043);  
Lcd_Write_Data(0x0046);
Lcd_Write_Com(0x0044);  
Lcd_Write_Data(0x0023);
Lcd_Write_Com(0x0045);  
Lcd_Write_Data(0x0076);
Lcd_Write_Com(0x0046);  
Lcd_Write_Data(0x0000);
Lcd_Write_Com(0x0047);  
Lcd_Write_Data(0x005E);
Lcd_Write_Com(0x0048);  
Lcd_Write_Data(0x004F);
Lcd_Write_Com(0x0049);  
Lcd_Write_Data(0x0040);	//**********Power On sequence************
Lcd_Write_Com(0x0017);  
Lcd_Write_Data(0x0091);
Lcd_Write_Com(0x002B);  
Lcd_Write_Data(0x00F9);
Delay(0xFFFF);
Lcd_Write_Com(0x001B);  
Lcd_Write_Data(0x0014);  
Lcd_Write_Com(0x001A);  
Lcd_Write_Data(0x0011);      
Lcd_Write_Com(0x001C);  
Lcd_Write_Data(0x0006);	  //0d
Lcd_Write_Com(0x001F);  
Lcd_Write_Data(0x0042);
Delay(0xFFFF);
Lcd_Write_Com(0x0019);  
Lcd_Write_Data(0x000A);
Lcd_Write_Com(0x0019);  
Lcd_Write_Data(0x001A);
Delay(0xFFFF);
Lcd_Write_Com(0x0019);  
Lcd_Write_Data(0x0012);
Delay(0xFFFF);
Lcd_Write_Com(0x001E);  
Lcd_Write_Data(0x0027);
Delay(0x1FFFF);   //**********DISPLAY ON SETTING***********
Lcd_Write_Com(0x0024);  
Lcd_Write_Data(0x0060);
Lcd_Write_Com(0x003D);  
Lcd_Write_Data(0x0040);
Lcd_Write_Com(0x0034);  
Lcd_Write_Data(0x0038);
Lcd_Write_Com(0x0035);  
Lcd_Write_Data(0x0038);
Lcd_Write_Com(0x0024);  
Lcd_Write_Data(0x0038);
Delay(0xFFFF);       
Lcd_Write_Com(0x0024);  
Lcd_Write_Data(0x003C);
Lcd_Write_Com(0x0016);  
Lcd_Write_Data(0x001C);
Lcd_Write_Com(0x0001);  
Lcd_Write_Data(0x0006);
Lcd_Write_Com(0x0055);  
Lcd_Write_Data(0x0000); 
Lcd_Write_Com(0x0002);           
Lcd_Write_Data(0x0000);
Lcd_Write_Com(0x0003);           
Lcd_Write_Data(0x0000);
Lcd_Write_Com(0x0004);           
Lcd_Write_Data(0x0000);
Lcd_Write_Com(0x0005);           
Lcd_Write_Data(0x00ef);
Lcd_Write_Com(0x0006);           
Lcd_Write_Data(0x0000);
Lcd_Write_Com(0x0007);           
Lcd_Write_Data(0x0000);
Lcd_Write_Com(0x0008);           
Lcd_Write_Data(0x0001);
Lcd_Write_Com(0x0009);           
Lcd_Write_Data(0x008f);
Lcd_Write_Com(0x0022);
LCD_CS_1;  //关闭片选使能
}

void Pant(uint16_t data)
{
  int i;
  LCD_CS_0;  //打开片选使能
  Address_set(0,0,239,399);
  for(i=0;i<96000;i++)
  {
    Lcd_Write_Datakk(data);
  }
  LCD_CS_1;  //关闭片选使能
}

/*

#ifdef  USE_FULL_ASSERT
void assert_failed(uint8_t* file, uint32_t line)
{ 
  while (1)
  {
  }
}
#endif
*/