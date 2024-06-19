	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	result: .byte 0
.text
.global main
	.equ X, 0x5536
	.equ Y, 0x4211
hamm:
	EOR R4,R0,R1	//R4 is the register with bits we want to count
	mov R5, #0		//R5 is the counter
	mov R6, #0		//R6 is a temp register
	shift_right:
		MOVS R4, R4, LSR #1  //shift right by 1, right most bit is in carry flag
		ADC R5, R5, R6 			//if there's a carry, R5 will increase by 1
		CMP R4, #0              // to check whether we have done the process
		BNE shift_right
str R5, [R2]
bx lr
main:
	mov R0, #X
	mov R1, #Y
	ldr R2, =result
	bl hamm
L: b L
