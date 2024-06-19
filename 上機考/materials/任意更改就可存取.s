.syntax unified
.cpu cortex-m4
.thumb


.text
 	.global main
 	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOA_MODER, 0x48000000

	.equ decode_mode, 0x9
	.equ shutdown, 0xC
	.equ display_test, 0xF
	.equ scan_limit, 0xB
	.equ intensity, 0xA
	.equ shutdown, 0xC

	.equ data, 0x20 	//PA5
	.equ load, 0x40 	//PA6
	.equ clock, 0x80 	//PA7
	.equ GPIO_BSRR_OFFSET, 0x18
	.equ GPIO_BRR_OFFSET, 0x28

main:
	bl GPIO_INIT
	bl max7219_init


	mov r0, #1
	mov r1, #789
	bl max7219_send_mod



l: b l

GPIO_INIT:
	// enable AHB2 clock
	movs r0, #0x1
	ldr r1, =RCC_AHB2ENR
	str r0, [r1]
	movs r0, 0x5400
	ldr r1, =GPIOA_MODER
	ldr r2, [r1]
	and r2, #0xFFFF03FF
	orrs r2, r2, r0
	str r2, [r1]
bx lr

max7219_send:
// input parameter: r0 is address, r1 is data
// use this function to send a message to max7219
	// save r0~r9 to stack in case
	stmfd sp!, {r0-r9}
	lsl r0, r0, #8
	add r0, r0, r1
	ldr r1, =#GPIOA_MODER
	ldr r2, =#load
	ldr r3, =#data
	ldr r4, =#clock
	ldr r5, =#GPIO_BSRR_OFFSET
	ldr r6, =#GPIO_BRR_OFFSET
	mov r7, #16

	.max7219send_loop:
		mov r8, #1
		sub r9, r7, #1
		lsl r8, r8, r9
		str r4, [r1, r6]
		tst r0, r8
		beq .bit_not_set
		str r3, [r1, r5]
		b .if_done
	.bit_not_set:
		str r3, [r1,r6]
	.if_done:
		str r4, [r1, r5]
		subs r7, r7, #1
		bgt .max7219send_loop
		str r2, [r1, r6]
		str r2, [r1, r5]

	// restore val for r0-r9
	ldmfd sp!, {r0-r9}

bx lr


max7219_init:
	push {r0, r1, r2, lr}
	ldr r0, =#decode_mode
	ldr r1, =#0xFF
	bl max7219_send
	ldr r0, =#display_test
	ldr r1, =#0x0
	bl max7219_send
	ldr r0, =#scan_limit
	ldr r1, =0x7
	bl max7219_send
	ldr r0, =#intensity
	ldr r1, =#0xF
	bl max7219_send
	ldr r0, =#shutdown
	ldr r1, =0x1
	bl max7219_send
	pop {r0,r1,r2,pc}
bx lr



max7219_send_mod:
	// input parameter: r0 is address, r1 is data
	// r7, r8, r9, r10, r11 as tmp

	mov r7, #1
	mov r8, #10
	mov r9, r1

	inner_loop:
	cmp r9, #9
	bge m1
		// set width
		ldr r0, =scan_limit
		sub r11, r7, #1
		mov r1, r11
		push {lr}
		bl max7219_send
		pop {lr}

		mov r0, r7
		mov r1, r9
		push {lr}
		bl max7219_send
		pop {lr}
		bx lr
	m1:
		mov r1, r9
		sdiv r9, r9, r8
		mul r10, r9, r8
		sub r1, r1, r10
		mov r0, r7
		push {lr}
		bl max7219_send
		pop {lr}
		add r7, r7, #1

		b inner_loop
