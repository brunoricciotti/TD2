.syntax unified
.cpu	cortex-m3
.thumb

.section .text
.align 2

.global calcular_potencia
.type calcular_potencia, %function

calcular_potencia:

	MOVS R2, #0 //Este sera mi contador, lo inicializo en 0
	PUSH {R4,R5,R6}	//Guardo en el stack lo que haya en R4 Y R5 porque voy a usar LOS registros
	MOVS R6, R1 //Guardo la longitud del array en R6
	CMP  R1, #0 //Me fijo que R1 no sea igual a cero
	BEQ	 error  //Si R1=0 salto a error

lazo_busqueda:

	SUBS R1, #1 //R1 es la longitud del array, R1=R1-1
	BMI  termine
	LSLS R4, R1,#2
	LDR  R3, [R0,R4]
	MUL  R5, R3, R3 //Multiplico R3*R3 y lo guardo en R5
	ADDS R2, R5 //suma = suma + R5
	BMI  error  //Si la suma de cuadrados es negativa salto a error
	B    lazo_busqueda

termine:

	UDIV R2, R2, R6 //R2 = R2/R6
	MOVS R0, R2 //Guardo el valor final en R0 (valor de retorno)
	POP  {R4,R5,R6}
	BX   LR

error:

	MOVS R0, #-1
	POP  {R4,R5,R6}
	BX   LR

.end
