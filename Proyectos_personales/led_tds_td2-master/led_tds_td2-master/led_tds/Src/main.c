#define F_CLK		(8000000)
#define ESCALA_TICK	(1)
#define F_TICK		(1000*ESCALA_TICK)
#define LED_TICKS	(125*ESCALA_TICK)
#define UNUSED(x)	((void)(x))

#define STM32F103xB
#include "stm32f1xx.h"
#include "dwt.h"
#include <stdint.h>

void hardware_init(void)
{
	/* Habilito el clock para el puerto C*/
	RCC->APB2ENR |= RCC_APB2ENR_IOPCEN;

	/* Pongo el puerto C13 como salida*/
	GPIOC->CRH &= ~GPIO_CRH_CNF13_Msk;
	GPIOC->CRH &= ~GPIO_CRH_MODE13_Msk;
	GPIOC->CRH |= GPIO_CRH_MODE13_0 | GPIO_CRH_MODE13_0;
	GPIOC->BSRR = GPIO_BSRR_BS13;

	/*Habilito el SysTick (Asumo clk de 8MHz)*/
	SysTick_Config((F_CLK/F_TICK)-1);

	/*Habilito el contador de ciclos de reloj*/
	dwt_inic();
}

void toggle_led(void)
{
	GPIOC->ODR ^= GPIO_ODR_ODR13_Msk;
}

int main(void)
{
	uint32_t tics =	LED_TICKS;
	uint32_t ciclos_una_pasada;
	uint32_t ciclos_actuales, ciclos_maximos=0;
	hardware_init();
	for(;;)
	{
		ciclos_una_pasada = dwt_read();
		dwt_reset();
		if(!--tics)
		{
			tics = LED_TICKS;
			toggle_led();
		}
		ciclos_actuales = dwt_read();

		/*
		 * ¿A qué se van a deber las diferencias entre corridas?
		 * ¿Qué corrida va a ser determinante para la carga de CPU?
		 */
		if(ciclos_maximos<ciclos_actuales)
		{
			ciclos_maximos = ciclos_actuales;
		}
		UNUSED(ciclos_maximos);
		UNUSED(ciclos_una_pasada);

		/*
		 * Para que se usa la instrucción "WFI".
		 * https://developer.arm.com/documentation/ddi0360/e/CHDEEIJB
		 * ¿Para que se la usa acá?
		 *
		 * Si no la uso, ¿Cómo tengo que resolver?
		 */
		asm("wfi");//se duerme el procesador hasta que tenga una interrupcion
	}
}

void SysTick_Handler(void)
{
	/*
	 * ¿Por qué no hace nada esta interrupción?
	 * ¿Es necesaria aunque no haga nada? ¿Por qué?
	 *
	 * No hace nada porque solo quiero despertar al procesador y que de la vuelta en el for
	 */
}
