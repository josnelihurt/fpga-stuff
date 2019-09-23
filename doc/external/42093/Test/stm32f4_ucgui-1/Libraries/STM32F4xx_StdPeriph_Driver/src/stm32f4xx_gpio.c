#include "stm32f4xx_gpio.h"
#include "stm32f4xx_rcc.h"

void GPIO_DeInit(GPIO_TypeDef* GPIOx)
{
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));

  if (GPIOx == GPIOA)
  {
    RCC_AHB1PeriphResetCmd(RCC_AHB1Periph_GPIOA, ENABLE);
    RCC_AHB1PeriphResetCmd(RCC_AHB1Periph_GPIOA, DISABLE);
  }
  else if (GPIOx == GPIOB)
  {
    RCC_AHB1PeriphResetCmd(RCC_AHB1Periph_GPIOB, ENABLE);
    RCC_AHB1PeriphResetCmd(RCC_AHB1Periph_GPIOB, DISABLE);
  }
  else if (GPIOx == GPIOC)
  {
    RCC_AHB1PeriphResetCmd(RCC_AHB1Periph_GPIOC, ENABLE);
    RCC_AHB1PeriphResetCmd(RCC_AHB1Periph_GPIOC, DISABLE);
  }
  else if (GPIOx == GPIOD)
  {
    RCC_AHB1PeriphResetCmd(RCC_AHB1Periph_GPIOD, ENABLE);
    RCC_AHB1PeriphResetCmd(RCC_AHB1Periph_GPIOD, DISABLE);
  }
  else if (GPIOx == GPIOE)
  {
    RCC_AHB1PeriphResetCmd(RCC_AHB1Periph_GPIOE, ENABLE);
    RCC_AHB1PeriphResetCmd(RCC_AHB1Periph_GPIOE, DISABLE);
  }
  else if (GPIOx == GPIOF)
  {
    RCC_AHB1PeriphResetCmd(RCC_AHB1Periph_GPIOF, ENABLE);
    RCC_AHB1PeriphResetCmd(RCC_AHB1Periph_GPIOF, DISABLE);
  }
  else if (GPIOx == GPIOG)
  {
    RCC_AHB1PeriphResetCmd(RCC_AHB1Periph_GPIOG, ENABLE);
    RCC_AHB1PeriphResetCmd(RCC_AHB1Periph_GPIOG, DISABLE);
  }
  else if (GPIOx == GPIOH)
  {
    RCC_AHB1PeriphResetCmd(RCC_AHB1Periph_GPIOH, ENABLE);
    RCC_AHB1PeriphResetCmd(RCC_AHB1Periph_GPIOH, DISABLE);
  }
  else
  {
    if (GPIOx == GPIOI)
    {
      RCC_AHB1PeriphResetCmd(RCC_AHB1Periph_GPIOI, ENABLE);
      RCC_AHB1PeriphResetCmd(RCC_AHB1Periph_GPIOI, DISABLE);
    }
  }
}


void GPIO_Init(GPIO_TypeDef* GPIOx, GPIO_InitTypeDef* GPIO_InitStruct)
{
  uint32_t pinpos = 0x00, pos = 0x00 , currentpin = 0x00;
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));
  assert_param(IS_GPIO_PIN(GPIO_InitStruct->GPIO_Pin));
  assert_param(IS_GPIO_MODE(GPIO_InitStruct->GPIO_Mode));
  assert_param(IS_GPIO_PUPD(GPIO_InitStruct->GPIO_PuPd));


  for (pinpos = 0x00; pinpos < 0x10; pinpos++)
  {
    pos = ((uint32_t)0x01) << pinpos;

    currentpin = (GPIO_InitStruct->GPIO_Pin) & pos;

    if (currentpin == pos)
    {
      GPIOx->MODER  &= ~(GPIO_MODER_MODER0 << (pinpos * 2));
      GPIOx->MODER |= (((uint32_t)GPIO_InitStruct->GPIO_Mode) << (pinpos * 2));

      if ((GPIO_InitStruct->GPIO_Mode == GPIO_Mode_OUT) || (GPIO_InitStruct->GPIO_Mode == GPIO_Mode_AF))
      {
        assert_param(IS_GPIO_SPEED(GPIO_InitStruct->GPIO_Speed));
        GPIOx->OSPEEDR &= ~(GPIO_OSPEEDER_OSPEEDR0 << (pinpos * 2));
        GPIOx->OSPEEDR |= ((uint32_t)(GPIO_InitStruct->GPIO_Speed) << (pinpos * 2));
        assert_param(IS_GPIO_OTYPE(GPIO_InitStruct->GPIO_OType));
        GPIOx->OTYPER  &= ~((GPIO_OTYPER_OT_0) << ((uint16_t)pinpos)) ;
        GPIOx->OTYPER |= (uint16_t)(((uint16_t)GPIO_InitStruct->GPIO_OType) << ((uint16_t)pinpos));
      }
      GPIOx->PUPDR &= ~(GPIO_PUPDR_PUPDR0 << ((uint16_t)pinpos * 2));
      GPIOx->PUPDR |= (((uint32_t)GPIO_InitStruct->GPIO_PuPd) << (pinpos * 2));
    }
  }
}


void GPIO_StructInit(GPIO_InitTypeDef* GPIO_InitStruct)
{
  GPIO_InitStruct->GPIO_Pin  = GPIO_Pin_All;
  GPIO_InitStruct->GPIO_Mode = GPIO_Mode_IN;
  GPIO_InitStruct->GPIO_Speed = GPIO_Speed_2MHz;
  GPIO_InitStruct->GPIO_OType = GPIO_OType_PP;
  GPIO_InitStruct->GPIO_PuPd = GPIO_PuPd_NOPULL;
}


void GPIO_PinLockConfig(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin)
{
  __IO uint32_t tmp = 0x00010000;
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));
  assert_param(IS_GPIO_PIN(GPIO_Pin));
  tmp |= GPIO_Pin;
  GPIOx->LCKR = tmp;
  GPIOx->LCKR =  GPIO_Pin;
  GPIOx->LCKR = tmp;
  tmp = GPIOx->LCKR;
  tmp = GPIOx->LCKR;
}


uint8_t GPIO_ReadInputDataBit(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin)
{
  uint8_t bitstatus = 0x00;
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));
  assert_param(IS_GET_GPIO_PIN(GPIO_Pin));

  if ((GPIOx->IDR & GPIO_Pin) != (uint32_t)Bit_RESET)
  {
    bitstatus = (uint8_t)Bit_SET;
  }
  else
  {
    bitstatus = (uint8_t)Bit_RESET;
  }
  return bitstatus;
}


uint16_t GPIO_ReadInputData(GPIO_TypeDef* GPIOx)
{
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));
  return ((uint16_t)GPIOx->IDR);
}


uint8_t GPIO_ReadOutputDataBit(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin)
{
  uint8_t bitstatus = 0x00;
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));
  assert_param(IS_GET_GPIO_PIN(GPIO_Pin));

  if ((GPIOx->ODR & GPIO_Pin) != (uint32_t)Bit_RESET)
  {
    bitstatus = (uint8_t)Bit_SET;
  }
  else
  {
    bitstatus = (uint8_t)Bit_RESET;
  }
  return bitstatus;
}


uint16_t GPIO_ReadOutputData(GPIO_TypeDef* GPIOx)
{
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));
  return ((uint16_t)GPIOx->ODR);
}


void GPIO_SetBits(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin)
{
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));
  assert_param(IS_GPIO_PIN(GPIO_Pin));
  GPIOx->BSRRL = GPIO_Pin;
}


void GPIO_ResetBits(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin)
{
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));
  assert_param(IS_GPIO_PIN(GPIO_Pin));
  GPIOx->BSRRH = GPIO_Pin;
}


void GPIO_WriteBit(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin, BitAction BitVal)
{
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));
  assert_param(IS_GET_GPIO_PIN(GPIO_Pin));
  assert_param(IS_GPIO_BIT_ACTION(BitVal));

  if (BitVal != Bit_RESET)
  {
    GPIOx->BSRRL = GPIO_Pin;
  }
  else
  {
    GPIOx->BSRRH = GPIO_Pin ;
  }
}


void GPIO_Write(GPIO_TypeDef* GPIOx, uint16_t PortVal)
{
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));
  GPIOx->ODR = PortVal;
}

void GPIO_ToggleBits(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin)
{
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));
  GPIOx->ODR ^= GPIO_Pin;
}


void GPIO_PinAFConfig(GPIO_TypeDef* GPIOx, uint16_t GPIO_PinSource, uint8_t GPIO_AF)
{
  uint32_t temp = 0x00;
  uint32_t temp_2 = 0x00;
  assert_param(IS_GPIO_ALL_PERIPH(GPIOx));
  assert_param(IS_GPIO_PIN_SOURCE(GPIO_PinSource));
  assert_param(IS_GPIO_AF(GPIO_AF));
  temp = ((uint32_t)(GPIO_AF) << ((uint32_t)((uint32_t)GPIO_PinSource & (uint32_t)0x07) * 4)) ;
  GPIOx->AFR[GPIO_PinSource >> 0x03] &= ~((uint32_t)0xF << ((uint32_t)((uint32_t)GPIO_PinSource & (uint32_t)0x07) * 4)) ;
  temp_2 = GPIOx->AFR[GPIO_PinSource >> 0x03] | temp;
  GPIOx->AFR[GPIO_PinSource >> 0x03] = temp_2;
}

