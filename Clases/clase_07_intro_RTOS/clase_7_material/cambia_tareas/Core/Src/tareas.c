#include "tareas.h"
#include "main.h"
#include <string.h>

tarea	*actual, *futura;
static tarea 	lista_tareas[MAX_TAREAS];
static uint32_t	ntarea, max_tarea;


void agregar_tarea(void (*tarea)(void), uint32_t slices, void *stack, uint32_t lenstack)
{
	uint32_t i;
	uint32_t *ptr = (uint32_t*)stack;

	/*
	 * Esta función genera el stack para cambiar el "contexto" del procesador para el primer cambio
	 * Para ayudarme use el link:
	 * https://developer.arm.com/documentation/dui0552/a/the-cortex-m3-processor/exception-model/exception-entry-and-return
	 *
	 * Cada tarea tiene una cantidad de ticks que va a ejecutarse, su propia pila y datos
	 * que no se almacenan en la pila que se guardan aparte.
	 */

	for(i=0;i<MAX_TAREAS-1;i++)
	{
		if(!lista_tareas[i].slices)
		{
			max_tarea++;											//Incremento la cantidad de tareas.
			lista_tareas[i].slices = slices;						//Cuantos "ticks" le voy a dedicar
			lista_tareas[i].ticks = slices;							//Arranca con todos los ticks.
			lista_tareas[i].pila = ((uint32_t)ptr)+lenstack-32;		//Cada tarea tiene su propia pila, uso un espacio de 8 registros de 32 bits por el stacking.
			*(ptr+lenstack/4-1)	= 1<<24;							//El xPSR debe tener el bit T (Thumb) en 1.
			*(ptr+lenstack/4-2)	= (uint32_t)tarea;					//PC a restaurar, lo apunto a la tarea que quiero.
			*(ptr+lenstack/4-3)	= 0xFFFFFFF9;						//LR. El link register en el stacking tiene el modo al que vuelvo. Thread con MSP
			*(ptr+lenstack/4-4)	= 0;								//R12. La primera vez no me importa lo que vale.
			*(ptr+lenstack/4-5)	= 0;								//R3
			*(ptr+lenstack/4-6)	= 0;								//R2
			*(ptr+lenstack/4-7)	= 0;								//R1
			*(ptr+lenstack/4-8)	= 0;								//R0
			break;
		}
	}
}


static void trigger_pendsv(void)
{
	/*
	 *	Interrupt Control and State Register
	 * 	------------------------------------
	 * 	https://developer.arm.com/documentation/dui0552/a/cortex-m3-peripherals/system-control-block/interrupt-control-and-state-register
	 *
	 * Uso el bit 28 de este registro para setear el pedido de la excepción
	 * PEND_SV
	 *
	 */
	volatile uint32_t *icsr = (void *)0xE000ED04;
	*icsr = 0x1 << 28;
	/*
	 * ISB. Interrupt synchronization barrier
	 * Vacío el pipeline porque en este punto
	 * muy probablemente cambie el contexto (el contenido de todos los registros)
	 */
	__ISB();
}


void correr_tareas(void)
{
	static tarea dummy;
	static uint8_t pila_dummy[64];
	dummy.pila = ((uint32_t)pila_dummy)+64;
	cambiar_tareas(&dummy,&lista_tareas[0]);
}

void cambiar_tareas(tarea *t_actual, tarea *t_futura)
{
		actual = t_actual;
		futura = t_futura;
		if(actual != futura)
		{
			/*
			 * Las tareas se cambian cuando se ejecuta la excepción asociada a la Pend_SV.
			 * Es decir, Modifico el stacking para volver a donde necesito.
			 *
			 */
			trigger_pendsv();
		}
}

void despachar_tareas(void)
{
	tarea *t_actual;
	if(!--lista_tareas[ntarea].ticks)
	{
		lista_tareas[ntarea].ticks = lista_tareas[ntarea].slices;
		t_actual = &lista_tareas[ntarea];
		if(++ntarea>=max_tarea) ntarea=0;
		cambiar_tareas(t_actual,&lista_tareas[ntarea]);
	}
}


void SysTick_Handler(void)
{
	/*
	 * Atiendo a la HAL para que el generador de código siga funcionando bien.
	 * Si regenero el código tengo que comentar la SysTick_Handler de stm32f4xx_it.c
	 */
	HAL_IncTick();
	/*
	 *	Asumo que corre cada 1ms.
	 *	despachar_tareas() decrementa los ticks de la tarea que está corriendo y
	 *	pasa a la que sigue cuando llega a cero.
	 */
	despachar_tareas();
}


void inicializar_tareas(void)
{
	uint32_t i;
	for(i=0;i<MAX_TAREAS;i++)
	{
		lista_tareas[i].pila = 0;
		lista_tareas[i].slices = 0;
		lista_tareas[i].ticks = 0;
		memset((void*)lista_tareas[i].registros,0,sizeof(lista_tareas[i].registros));
	}
	actual = &lista_tareas[0];
	futura = &lista_tareas[0];
	ntarea = 0;
	max_tarea = 0;
}
