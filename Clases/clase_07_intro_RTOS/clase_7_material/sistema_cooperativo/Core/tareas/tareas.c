#include "tareas.h"
#include <stdlib.h>

static tarea lista_tareas[MAX_TASKS];
extern void despacha_una_tarea(tarea *tsk);

void Inicializar_tareas(void)
{
	uint32_t i;
	for(i=0; i<MAX_TASKS; i++)
	{
		lista_tareas[i].periodo = 0;
		lista_tareas[i].ticks = 0;
		lista_tareas[i].tarea = NULL;
		lista_tareas[i].debug_info = NULL;
		lista_tareas[i].parametros = NULL;
	}
}

int Agregar_tarea(void (*tarea)(void*), uint32_t periodo, uint32_t offset, void *parametros)
{
	uint32_t i;
	for(i=0; i<MAX_TASKS-1; i++)
	{
		if(!lista_tareas[i].tarea)
		{
			lista_tareas[i].tarea = tarea;
			lista_tareas[i].periodo = periodo;
			lista_tareas[i].ticks = offset;
			lista_tareas[i].parametros = parametros;
			lista_tareas[i].debug_info = NULL;
			break;
		}
	}
	return (i==MAX_TASKS)?EXIT_FAILURE:EXIT_SUCCESS;
}

void Despachar_tarea(void)
{
	uint32_t i;
	for(i=0;i<MAX_TASKS;i++)
	{
		if(!lista_tareas[i].ticks && lista_tareas[i].tarea)
		{
			despacha_una_tarea(&lista_tareas[i]);
			lista_tareas[i].ticks = lista_tareas[i].periodo;
		}
		lista_tareas[i].ticks--;
		if(!lista_tareas[i].tarea) break;
	}
	return;
}
