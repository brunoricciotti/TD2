		.syntax		unified
		.cpu		cortex-m0
		.thumb
		.extern actual, futura

		.section	.text
		.align		2
		.global	PendSV_Handler
		.type	PendSV_Handler, %function
PendSV_Handler:

		//Guardo los registros de R4 a R11 en memoria
		CPSID I
		LDR		R0,	=actual
		LDR 	R0,	[R0]
		MOV		R1,	R0
		STM		R0!,{R4, R5, R6, R7}
		MOV		R4,	R8
		MOV		R5,	R9
		MOV		R6,	R10
		MOV		R7,	R11
		STM		R0!,{R4, R5, R6, R7}
		MOV		R0, SP
		STR		R0,[R1,#0x20]
		LDR		R2,	=futura
		LDR		R2,	[R2]
		LDR		R0,	[R2,#0x20]
		MOV		SP,	R0
		ISB
		DSB
		MOV		R1,	R2
		ADDS	R2, #0x10
		LDM 	R2!,{R4, R5, R6, R7}
		MOV		R8,	R4
		MOV		R9,	R5
		MOV		R10,R6
		MOV		R11,R7
		LDM R1!,{R4, R5, R6, R7}
		CPSIE 	I
		BX		LR

		.global	cambiar_pila
		.type	cambiar_pila, %function
cambiar_pila:
		ADDS	R0,	R1
		MOV		SP,	R0
		ISB
		DSB
		BX	LR
		.end
