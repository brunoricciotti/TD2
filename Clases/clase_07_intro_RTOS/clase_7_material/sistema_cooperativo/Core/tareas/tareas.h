#ifndef __TAREASH
#define __TAREASH
#include "stdint.h"
#define MAX_TASKS	128

	typedef struct
	{
		uint32_t ticks;
		uint32_t periodo;
		void (*tarea)(void*);
		void *parametros;
		void *debug_info;
	} tarea;

	void Inicializar_tareas(void);
	int Agregar_tarea(void (*tarea)(void*), uint32_t periodo, uint32_t offset, void *parametros);
	void Despachar_tarea(void);
#endif
