.syntax		unified
.cpu		cortex-m0
.thumb

.section	.text
.align		2

.global sumar_todo
.type sumar_todo, %function
sumar_todo:

	MOVS R2, #0 //R2 es nuestro sumador, y lo hacemos R2=0
	PUSH {R4}   //Guardo en el stack lo que tengo en R4 ya que voy a usar ese registro

lazo_busqueda:

	SUBS R1, #1 //R1 es la longitud del array, R1 = R1-1
	BMI  termine//Si R1 < 0 salto a termine
	LSLS R4, R1,#2 //R4 = R1 << 2(multiplica por 4 por que una palabra tiene 4 bytes)
	LDR  R3, [R0,R4] //Cargar en R3 lo que haya en la posicion de memoria R0+R4
	ADDS R2, R3 //suma = suma + R3
	B    lazo_busqueda //Si llego aca vuelvo a saltar al inicio de lazo_busqueda (loop)

termine:

	MOVS R0, R2//Guardo en R0 el valor de suma. R0 es el valor de retorno
	POP  {R4} //Restauro R4
	BX 		LR
.end
