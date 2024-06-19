.text
.global main
	.equ N, 0
return1:
	mov r4, #1
	bx lr
N_out_of_range:
	mov r4, #1
	neg r4, r4
	bx lr
overflow:
	mov r4, #2
	neg r4, r4
	bx lr
fib:
	cmp r0, #100
	bhi N_out_of_range		// if N > 100 , then return -1
	cmp r0, #1
	beq return1				// if N = 1 , then return the answer fib(1)=1
	blt N_out_of_range		// if N < 1 , then return -1
	cmp r0, #2
	beq return1				// if N = 2 , then return the answer fib(1)=1

	mov r1, #1				//r1== An-1   r2==An-2
	mov r2, #1

	fibloop:
			add r4, r2, r1
			cmp r4, #0
			blt overflow	// if f(n) overflow , then return -2
			mov r2, r1
			mov r1, r4
			sub r0, r0, #1
			cmp r0, #2
			bne fibloop
	bx lr
main:
	movs R0, #N			//r0==counter
	bl fib
L: b L
