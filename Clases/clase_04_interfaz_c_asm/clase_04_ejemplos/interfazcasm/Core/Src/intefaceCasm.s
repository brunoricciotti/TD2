.syntax		unified
.thumb

.section	.text
.align		2

.global FuncionDummy
.type FuncionDummy, %function
FuncionDummy:
	PUSH	{R4}	//R4 a la pila
	MOV	 	R4, #1	//R4 = 1
	POP	 	{R4}	//restauro R4
	BX 		LR		//Retorna de la funcion

//Genero una función que haga alguna tarea.
.global RotarDerecha
.type RotarDerecha, %function
RotarDerecha:
	//Recibe dos parámetros R0 el valor en R1 cuanto rota.
	//Cuando se pasan parámetros se reciben desde R0 a R3
	//donde el primer parámetro es R0, R1 es el segundo y así
	//El retorno de la función es por R0
	RORS R0, R0, R1
	BX LR

.global RotarIzquierda
.type RotarIzquierda, %function
RotarIzquierda:
	PUSH 	{R2,LR}		//Manda R2 y LR a la Pila
	RSBS	R2,R1,#32	//Calculo R2 = 32 - R1
	RORS	R0,R0,R2	//Roto a la izquierda
	POP		{R2,PC}		//Restaura R2 y Vuelve de la función.

.global ParametrosPorPila
.type ParametrosPorPila, %function
ParametrosPorPila:
	//A partir del quinto parámetro se lo recibe por la pila.

	//Es importante ver que quien hace la  invocación de la función
	//no pasa los parámetros haciendo PUSH sino que los escribe por
	//encima de la pila, por lo que si hacemos PUSH antes de recuperarlos,
	//perdemos los parámetros del quinto en adelante
	//Por lo que no nos va quedar otra opcion que rescatarlos antes.
	//Uso R12 como registro temporal, porque sí cae una interrupción
	//se stackea su contenido de manera automática, lo mismo que R0,
	//R1, R2, R3, LR, xPSR y el PC

	LDR R12, [SP, #4]	//Rescato el sexto parámetro
	ADDS R0, R0, R12	//Sumo el primero contra el sexto
	LDR	R12, [SP, #0]	//Rescato el quinto parámetro
	ADCS R0, R0, R12	//Sumo el parcial con el quinto
	PUSH {LR}			//Ahora puedo usar la pila.
	ADCS R0, R0, R1		//Sumo el resto
	ADCS R0, R0, R2
	ADCS R0, R0, R3
	POP {PC}			//Retorno de la función
.end

