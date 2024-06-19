	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	result: .word 0
	max_size: .word 0
.text
	.global main
	m: .word 0x27
	n: .word 0x41

GCD:
	cmp r7, #0
	it eq
	cmpeq r0, #0
	itt eq
	moveq r7, r1
	beq exit
	cmp r7, #0
	it eq
	cmpeq r1, #0
	it eq
	moveq r7, r0
	beq exit

	cmp r0, #0
	beq exit
	cmp r1, #0
	beq exit

	and r2, r0, #1
	and r3, r1, #1
	orr r4, r3, r2
	cmp r4, #0
	ite eq
	moveq r4, #1
	movne r4, #0
	add r6, r6, #4
	stmfd sp!, {r4,lr}

	cmp r4, #1
	ittt eq
	lsreq r0, #1
	lsreq r1, #1
	bleq GCD

	cmp r2, #0
	itt eq
	lsreq r0, #1
	bleq GCD

	cmp r3, #0
	itt eq
	lsreq r1, #1
	bleq GCD

	subs r5, r0, r1
	cmp r0, r1
	it lt
	movlt r1, r0
	movs r0, r5
	it mi
	rsbmi r0, r5, #0;
	bl GCD

exit:
	ldmfd sp!, {r4, lr}
	lsl r7, r4
	mov r2, #1
	mov r3, #1
	mov r4, #0
	mov pc, lr
	bx lr

main:
	ldr r0, #m
	ldr r1, #n
	mov r4, #0
	mov r7, #0
	BL GCD

	ldr r0, =result
	ldr r1, =max_size
	str r7, [r0]
	str r6, [r1]

L:
	nop
	b L
