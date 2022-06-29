		.syntax		unified
		.cpu		cortex-m0
		.thumb
		.section	.text
		.align		2

		.global	despacha_una_tarea
		.type	despacha_una_tarea, %function
despacha_una_tarea:
		PUSH	{R0,R1,LR}			// Mando a la pila
		LDR		R1,[R0,#8]			// Busco la funcion
		LDR		R0,[R0,#12]			// Busco los parámetros.
		BLX		R1					// Salta al contenido de R1
		POP		{R0,R1,PC}			// Return
		.end
