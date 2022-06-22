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

	for(i=0;i<MAX_TAREAS-1;i++)
	{
		if(!lista_tareas[i].slices)
		{
			max_tarea++;
			lista_tareas[i].slices = slices;
			lista_tareas[i].ticks = slices;
			lista_tareas[i].pila = ((uint32_t)ptr)+lenstack-32;
			*(ptr+lenstack/4-1)	= 1<<24;
			*(ptr+lenstack/4-2)	= (uint32_t)tarea;
			*(ptr+lenstack/4-3)	= 0xFFFFFFF9;
			*(ptr+lenstack/4-4)	= 0;
			*(ptr+lenstack/4-5)	= 0;
			*(ptr+lenstack/4-6)	= 0;
			*(ptr+lenstack/4-7)	= 0;
			*(ptr+lenstack/4-8)	= 0;
			break;
		}
	}
}


static void trigger_pendsv(void)
{
  volatile uint32_t *icsr = (void *)0xE000ED04;
  *icsr = 0x1 << 28;
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
