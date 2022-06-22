		.syntax		unified
		.cpu		cortex-m0
		.thumb

// Para ver como funciona: https://youtu.be/2BslL5V6484
/****************************************/
/*	Defino Rutinas Externas				*/
/****************************************/
	.extern		led_init, led_set
	.extern		siete_segmentos_init, siete_segmentos_set

/****************************************/
/*	Defino variables en RAM				*/
/****************************************/
	.section	.bss
	//Numero a mostrar (4 bytes).
	.comm	valor_a_mostrar,4

/****************************************/
/*	Defino constantes de programa		*/
/****************************************/
// Demora por software.
.equ LOOP_COMPARE, 	0x2ffff

/****************************************/
/*	Función main. Acá salta boot.s 		*/
/*	cuando termina.						*/
/*	main NO TIENE QUE TERMINAR NUNCA	*/
/****************************************/
		.section	.text
		.align		2
 		.global		main
		.type		main, %function
main:
		BL		led_init				//Inicializo led
		BL		siete_segmentos_init	//Inicializo siete segmentos.
		MOVS	R0,#10					//
		BL		siete_segmentos_set		//Borro siete segmentos.
		MOVS	R0,#9					//
		LDR		R1,=valor_a_mostrar		//
		STR		R0,[R1]					//Inicializo valor_a_mostrar en 9

main_loop:
		MOVS	R0,#1
		BL		led_set					//Enciendo el led
		BL		cuenta_para_atras		//Pongo valor_a_mostrar en el display
		LDR		R0,=#LOOP_COMPARE		//
		BL		delay					//demora por software

		MOVS	R0,#0					//
		BL		led_set					//
		LDR		R0,=#LOOP_COMPARE*8		//
		BL		delay					//Apago el led y espero 8 veces más que cuando lo encendí
		B		main_loop				//Vuelvo a encender el led.

/****************************************/
/*	Función cuenta_para_atras. 			*/
/*	usa la variable valor_a_mostrar		*/
/****************************************/
		.type	cuenta_para_atras, %function
cuenta_para_atras:
		PUSH	{R0,R1,LR}				//Guardo R0, R1 y LR (anido funciones)
		LDR		R1,=valor_a_mostrar		//voy a buscar la
		LDR		R0,[R1]					//variable "valor_a_mostrar" y la pongo en R0
		BL		siete_segmentos_set		//Cargo R0 en el digito
		SUBS	R0,R0,#1				//decremento R0
		CMP		R0,#0					//
		BGE		cuenta_guardar_valor	//Si es mayor o igual a cero (con signo).
		MOVS	R0,#9					//cargo 9 en R0
cuenta_guardar_valor:					//
		STR		R0,[R1]					//guardo R0 en la variable "valor_a_mostrar"
		POP		{R0, R1, PC}			//restauro R0, R1 y vuelvo


/****************************************/
/*	Función delay. 				 		*/
/*	Recibe por R0 la demora				*/
/****************************************/
		.type	delay, %function
delay:
		PUSH	{R0, LR}			// Guardo el parámetro y LR en la pila.
delay_dec:
        SUBS	R0, 1				//
        BNE		delay_dec			// while(--R0);
		POP		{R0, PC}			// repongo R0 y vuelvo.
.end
