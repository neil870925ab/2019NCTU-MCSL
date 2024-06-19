#include "stm32l476xx.h"

#define SET_REG(REG,SELECT,VAL){((REG)=((REG)&(~(SELECT))) | (VAL));};
int plln = 3, pllm = 1;

void SystemClock_Config();
void SysTick_UserConfig();
void SysTick_Handler();
extern void GPIO_init();

int main(){
	SystemClock_Config();
	SysTick_UserConfig();
	GPIO_init();
}

void SystemClock_Config(){
	RCC->CR |= RCC_CR_HSION;	// turn on hsi16 oscilator
	while((RCC->CR&RCC_CR_HSIRDY)== 0);	//check hsi16 ready
	SET_REG(RCC->CFGR, RCC_CFGR_HPRE, 8<<4); //  16/2 = 8MHz

	RCC->CFGR &= ~RCC_CFGR_SW;
	RCC->CFGR |= RCC_CFGR_SW_HSI;

	RCC->CR &= ~RCC_CR_PLLON;
	while (RCC->CR & RCC_CR_PLLRDY);

	SET_REG(RCC->PLLCFGR, RCC_PLLCFGR_PLLSRC_HSI, 1);
	SET_REG(RCC->PLLCFGR, RCC_PLLCFGR_PLLM, (pllm<<4));
	SET_REG(RCC->PLLCFGR, RCC_PLLCFGR_PLLN, (plln<<8));
	SET_REG(RCC->PLLCFGR, RCC_PLLCFGR_PLLR, (11<<25));		//pllr = 8
	
	SET_REG(RCC->PLLCFGR, RCC_PLLCFGR_PLLPEN, (1<<16));
	SET_REG(RCC->PLLCFGR, RCC_PLLCFGR_PLLQEN, (1<<20));
	SET_REG(RCC->PLLCFGR, RCC_PLLCFGR_PLLREN, (1<<24));
	
	RCC->CR |= RCC_CR_PLLON;
	while ((RCC->CR & RCC_CR_PLLRDY) == 0);

	RCC->CFGR &= ~RCC_CFGR_SW;
	RCC->CFGR |= RCC_CFGR_SW_PLL;

	if((RCC->CR & RCC_CR_HSIRDY) == 0){
		return;
	}
}

void SysTick_UserConfig(){
	SysTick->CTRL |= 0x00000004;
	SysTick->LOAD = 1000000; // 3 second
	SysTick->VAL = 0;
	SysTick->CTRL |= 0x00000003;
}

void SysTick_Handler(){
	GPIOA->ODR = (GPIOA->ODR & 0xFFFFFFDF) | ~(GPIOA->ODR & 0x00000020);
}
