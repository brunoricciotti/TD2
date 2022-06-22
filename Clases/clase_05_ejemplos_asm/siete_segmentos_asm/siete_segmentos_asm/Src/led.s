		.syntax		unified
		.cpu		cortex-m0
		.thumb

		.section	.text
		.align		2
 		.global		led_init, led_set

/****************************************/
/*	Defino constantes de programa		*/
/****************************************/
.equ PORTC_ODR,		0x4001100C		// .equ es similar a  #define
.equ GPIOC_CHR, 	0x40011004		// Puerto GPIOC
.equ RCC_APB2ENR, 	0x40021018		// Registros para habilitar el clock de GPIOC

/****************************************/
/*	Función led_init. 				 	*/
/*	Inicializa El LED					*/
/****************************************/
		.type	led_init, %function
led_init:
		PUSH	{R1, R2, LR}		// Mando a la pila los registros que modifico y LR
		LDR		R1, =(1 << 4)       // Cargo en R1 el bit que me habilita el GPIOC
		LDR 	R2, =#RCC_APB2ENR   // Cargo la dirección de memoria
		STR		R1, [R2]            // Habilito la señal de reloj para GPIOC
									//Pongo GPIOC13 como salida.
		LDR 	R1, =(0b11 << 20)
		LDR 	R2, =#GPIOC_CHR
		STR 	R1, [R2]
		POP		{R1, R2, PC}

/****************************************/
/*	Función led_set. 				 	*/
/*	Setea el led en funcion de R0		*/
/****************************************/
		.type	led_set, %function
led_set:
		PUSH	{R0, R1, R2}		// Mando a la pila todos los registros que modifico
		MVNS	R0,R0				// R0   = ~R0
		MOVS	R1,#1				// R1   = 0x01
		ANDS	R0,R0,R1			// R0 & = 0x01
		LSLS	R0,R0,#13			// R0 <<= 13
		ldr 	R2, =#PORTC_ODR   	// Escribo la dirección de memoria para setear GPIOC
		STR 	R0, [R2]          	// Escribo el puerto de salida
		POP		{R0, R1, R2}		// Repongo los registros que toqué.
		BX		LR					// return
.end
