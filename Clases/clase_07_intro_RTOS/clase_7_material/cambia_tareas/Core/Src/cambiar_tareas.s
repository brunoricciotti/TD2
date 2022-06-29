		.syntax		unified
		.cpu		cortex-m0
		.thumb
		.extern actual, futura				//Punteros a las estructuras tarea, cambio actual por futura.

		.section	.text
		.align		2
		.global	PendSV_Handler
		.type	PendSV_Handler, %function
PendSV_Handler:

		//Guardo los registros de R4 a R11 en memoria
		CPSID I								//Apago las interrupciones. Voy a tocar la pila.
		LDR		R0,	=actual					//Pongo el R0 la dirección del puntero a la tarea (ptr a ptr)
		LDR 	R0,	[R0]					//Me traigo el puntero a R0
		MOV		R1,	R0						//Guardo en R1 el valor original donde empieza la tarea actual
		STM		R0!,{R4, R5, R6, R7}		//es equivalen a STMIA guardo R4 - R7 en la estructura.
		MOV		R4,	R8
		MOV		R5,	R9
		MOV		R6,	R10
		MOV		R7,	R11
		STM		R0!,{R4, R5, R6, R7}		//Guardo R8-R11 en la estructura siguiendo a R7 (Por eso uso R0).
		MOV		R0, SP						// Guardo el puntero a la Pila
		STR		R0,[R1,#0x20]				// donde va en la estructura
		LDR		R2,	=futura					//Cargo en R2 la dirección de la nueva.
		LDR		R2,	[R2]
		LDR		R0,	[R2,#0x20]				//Me traigo la nueva pila (la primera vez el stacking lo armé en
		MOV		SP,	R0						//en agregar_tarea, las demás lo hizo el procesador.
		ISB									//Toqué la pila, rompo pipeline
		DSB									//Flush de memoria de datos. No se ejecuta nada hasta que esto termine
		MOV		R1,	R2						//A partir de acá me traigo los registros
		ADDS	R2, #0x10					//R4 - R11 que no se guardan en el stacking.
		LDM 	R2!,{R4, R5, R6, R7}		//
		MOV		R8,	R4						//
		MOV		R9,	R5						//
		MOV		R10,R6						//
		MOV		R11,R7						//
		LDM R1!,{R4, R5, R6, R7}			//
		CPSIE 	I							//Habilito interrupciones.
		BX		LR							//Vuelvo de la excepción. Empieza el unstacking.
		.end
