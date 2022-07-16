// /* The state word must be initialized to non-zero */
// uint32_t xorshift32(struct xorshift32_state *state)
// {
//	/* Algorithm "xor" from p. 4 of Marsaglia, "Xorshift RNGs" */
//	uint32_t x = state->a;
//	x ^= x << 13;
//	x ^= x >> 17;
//	x ^= x << 5;
//	return state->a = x;
//}

.syntax		unified
.thumb

/****************************************/
/*	Defino variables en RAM				*/
/****************************************/
	.section	.bss
	.comm	state		,4


/****************************************/
/*	Defino memoria de programa (FLASH)	*/
/****************************************/
.section	.text
.align		2

.global xorshift_inic
.type xorshift_inic, %function
xorshift_inic:
	//Recibo por R0 el valor inicial.
	PUSH 	{R1}				//Mando R1 a la pila.
	LDR 	R1,=state			//Pongo en R1 la dirección state
	STR 	R0, [R1]  			//Mando R0 a la posición de memoria apuntada por R1
	POP  	{R1}				//devuelvo R1
	BX 		LR					//Vuelvo de la función.


.global xorshift
.type xorshift, %function
xorshift:
	PUSH 	{R1, R2}
	LDR		R2,=state			//Puntero a state
	LDR		R0,[R2]				//Leo state
	LSL		R1,R0,#13			//
	EOR		R0,R0,R1			//  x ^= x << 13
	LSR		R1,R0,#17			//
	EOR		R0,R0,R1			//	x ^= x >> 17;
	LSL		R1,R0,#5			//
	EOR		R0,R0,R1			//	x ^= x << 5;
	STR		R0,[R2]				//  Guardo State.
	POP 	{R1, R2}			//R0 tiene el retorno
	BX LR						//Vuelvo de la función.
.end
s
