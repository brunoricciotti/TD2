#ifndef SRC_TAREAS_H_
#define SRC_TAREAS_H_
#define	MAX_TAREAS	128
#include <stdint.h>
typedef struct
{
	uint32_t	registros[8];
	uint32_t	pila;
	uint32_t	ticks;
	uint32_t	slices;
} tarea;

void agregar_tarea(void (*tarea)(void), uint32_t slices, void *stack, uint32_t lenstack);
void correr_tareas(void);
void cambiar_tareas(tarea *t_actual, tarea *t_futura);
void despachar_tareas(void);
void inicializar_tareas(void);
extern void cambiar_pila(uint32_t pila, uint32_t len);

#endif /* SRC_TAREAS_H_ */
