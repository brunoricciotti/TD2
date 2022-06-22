//
//	codifico un generador pseudoaleatorio del tipo xorshift
//
//	uint32_t xorshift128(struct xorshift128_state *state)
//  {
//		/* Algorithm "xor128" from p. 5 of Marsaglia, "Xorshift RNGs" */
//		uint32_t t  = state->x[3];
//	    uint32_t s  = state->x[0];  /* Perform a contrived 32-bit shift. */
//		state->x[3] = state->x[2];
//		state->x[2] = state->x[1];
//		state->x[1] = s;
//		t ^= t << 11;
//		t ^= t >> 8;
//		return state->x[0] = t ^ s ^ (s >> 19);
//	}
//
//

.syntax		unified
.thumb

/****************************************/
/*	Defino variables en RAM				*/
/****************************************/
	.section	.bss
	.comm	state_0		,4
	.comm	state_1		,4
	.comm	state_2		,4
	.comm	state_3		,4


/****************************************/
/*	Defino memoria de programa (FLASH)	*/
/****************************************/
.section	.text
.align		2

.global xorshift128_inic
.type xorshift128_inic, %function
xorshift128_inic:
	//Recibo por R0 - R1 - R2 - R3
	//el valor inicial.
	PUSH 	{R4}				//Mando R4 a la pila.
	LDR 	R4,=state_0			//Pongo en R4 la dirección state_0
	STMIA 	R4!, {R0-R3}  		//Mando R0, R1, R2 y R3 a la memoria a partir de R4
	POP  	{R4}				//devuelvo R4
	BX 		LR					//Vuelvo de la función.


.global xorshift128
.type xorshift128, %function
xorshift128:
	PUSH 	{R1-R7}
	LDR		R7,=state_0			//Puntero a state_0
	LDMIA	R7!,{R0-R3}			//Leo los cuatro state
	MOV		R5,R3				//t = state[3]
	MOV		R4,R0				//s = state[0]
	MOV		R3,R2				//state[3]=state[2]
	MOV		R2,R1				//state[2]=state[1]
	MOV		R1,R0				//state[1]=state[0]
	LSL		R6,R5,#11			//
	EOR		R5,R5,R6			//t ^= t << 11
	LSR		R6,R5,#8			//
	EOR		R5,R5,R6			//t ^= t >> 8
	LSR		R6,R4,#19			//
	EOR		R4,R4,R6			//
	EOR		R0,R4,R5			//state[0] = t ^ s ^ (s >> 19)
	LDR		R7,=state_0			//
	STMIA	R7!,{R0-R3}			//actualizo state
	POP {R1-R7}					//R0 tiene el retorno
	BX LR						//Vuelvo de la función.
.end
