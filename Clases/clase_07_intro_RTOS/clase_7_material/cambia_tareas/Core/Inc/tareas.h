#ifndef SRC_TAREAS_H_
#define SRC_TAREAS_H_
#define	MAX_TAREAS	128
#include <stdint.h>
typedef struct
{
	uint32_t	registros[8];	//Los registros que no guardo en la pila los guardo acá R4 - R11
	uint32_t	pila;			//Pila de la tarea, de acá uso 32 bytes para el stacking
	uint32_t	ticks;			//ticks que le restan a la tarea para irse.
	uint32_t	slices;			//cantidad de ticks que corre la tarea.
} tarea;

void agregar_tarea(void (*tarea)(void), uint32_t slices, void *stack, uint32_t lenstack);
void correr_tareas(void);
void cambiar_tareas(tarea *t_actual, tarea *t_futura);
void despachar_tareas(void);
void inicializar_tareas(void);
extern void cambiar_pila(uint32_t pila, uint32_t len);

#endif /* SRC_TAREAS_H_ */
