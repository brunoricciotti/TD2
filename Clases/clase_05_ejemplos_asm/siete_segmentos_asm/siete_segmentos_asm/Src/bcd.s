	.syntax		unified
	.cpu		cortex-m0
	.thumb

/****************************************/
/*	Defino constantes de programa		*/
/****************************************/
.equ RCC_APB2ENR, 	0x40021018		// Registros para habilitar el clock de GPIOB
.equ GPIOB_CHR,		0x40010C04		// Configuracion del puerto B
.equ PORTB_ODR,		0x40010C0C		// Puerto B


	.section	.text
	.align		2
	//Rutinas que puedo llamar desde otros archivos.
 	.global		siete_segmentos_init, siete_segmentos_set

/****************************************/
/*	Función siete_segmentos_init. 		*/
/*		Inicializa un siete segmentos	*/
/*		de anodo común en los pines de	*/
/*		B9 a B15						*/
/****************************************/
	.type	siete_segmentos_init, %function
siete_segmentos_init:
	PUSH	{R0, R1, R2}
	LDR		R1, =#RCC_APB2ENR
	LDR		R0,[R1]
	MOVS	R2,#(1<<3)
	ORRS	R0,R0,R2
	STR		R0,[R1]				// Habilito el CLK en el port b
	LDR		R1,=#GPIOB_CHR
	LDR		R0,[R1]
	LDR		R2,=#(0x33333330)
	ORRS	R0,R0,R2
	STR		R0,[R1]				//Puertos B9 a B15 como salidas.
	POP		{R0, R1, R2}		//Ver manual del chip https://www.st.com/resource/en/reference_manual/cd00171190-stm32f101xx-stm32f102xx-stm32f103xx-stm32f105xx-and-stm32f107xx-advanced-arm-based-32-bit-mcus-stmicroelectronics.pdf
	BX		LR					// return

/****************************************/
/*	Función siete_segmentos_set 		*/
/*		Escribe el valor recibido por R0*/
/*		en el display. Si es mayor a 9	*/
/*		borra el display				*/
/****************************************/
	.type	siete_segmentos_set, %function
siete_segmentos_set:
	PUSH	{R0,R1,R2}
	LDR		R1,=#(0x7F<<9)
	CMP		R0,#9
	BHI		setear_pines
	LDR		R2,=tabla_siete_segmentos	//Pongo R2 a la dirección de la tabla
	LDRB	R1,[R2,R0]					//Me traigo el valor 7 segmentos a R1 desde [R0+R2]
	MOVS	R2,#9						//
	LSLS	R1,R1,R2					//Lo desplazo 9 posiciones porque uso
setear_pines:							//de R15 a R9
	LDR		R2,=#PORTB_ODR				//Me fijo donde escribo
	STR		R1,[R2]						//Escribo el puerto
	POP		{R0,R1,R2}					//Dejo R0, R1 y R2 como estaban
	BX		LR							// return

tabla_siete_segmentos:
					//gfa_bedc
	.byte	0x40	//100_0000 //'0'
	.byte	0x76	//111_0110 //'1'
	.byte	0x21	//010_0001 //'2'
	.byte	0x24	//010_0100 //'3'
	.byte	0x16	//001_0110 //'4'
	.byte	0x0C	//000_1100 //'5'
	.byte	0x08	//000_1000 //'6'
	.byte	0x66	//110_0110 //'7'
	.byte	0x00	//000_0000 //'8'
	.byte	0x04	//000_0100 //'9'
.end
