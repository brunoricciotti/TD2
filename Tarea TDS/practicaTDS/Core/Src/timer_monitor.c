#include "stm32f1xx_hal.h"
#include <stdint.h>
void inic_timer(uint32_t divisor_us)
{
	/*
	 * Uso el timer 2 para el monitor del sistema.
	 */
	RCC->APB1ENR |= RCC_APB1ENR_TIM2EN;
	/*
	 * Esta línea configura el prescaler del timer
	 * que cuenta tiempo del procesador. Prestar atención.
	 */
	TIM2->PSC = (SystemCoreClock / (1000000*divisor_us)) - 1;
	TIM2->CNT = -1;
	TIM2->CR1 |= TIM_CR1_CEN;
	TIM2->CR1 &= ~TIM_CR1_CEN;
}

void start_timer(void)
{
	TIM2->CNT = 0;
	TIM2->CR1 |= TIM_CR1_CEN;
}

uint32_t stop_timer(void)
{
	uint32_t ret = TIM2->CNT;
	TIM2->CR1 &= ~TIM_CR1_CEN;
	return ret;
}
