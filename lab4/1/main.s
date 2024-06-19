.syntax unified
.cpu cortex-m4
.thumb

.data
	// put 0to f 7-seg pattern here
	arr: .byte 0x7e, 0x30, 0x6d, 0x79, 0x33, 0x5b, 0x5f, 0x70, 0x7f, 0x7b, 0x77, 0x1f, 0x4e, 0x3d, 0x4f, 0x47

.text
 	.global main
 	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOA_MODER, 0x48000000

	.equ decode_mode, 0x9
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


	ldr r2, =#0

loop:
	b Display0toF
	b loop

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

Display0toF:
	mov r0, #1
	ldr r9, =arr
	ldrb r1, [r9, r2]
	push {r2}
	bl max7219_send
	bl delay
	pop {r2}
	add r2, r2, #1
	cmp r2, #16
	bne Display0toF
	mov r2, #0
b loop

max7219_send:
// input parameter: r0 is address, r1 is data
// use this function to send a message to max7219
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
bx lr


max7219_init:
	push {r0, r1, r2, lr}
	ldr r0, =#decode_mode
	ldr r1, =#0x0
	bl max7219_send
//	ldr r0, =#display_test
//	ldr r1, =#0x1
//	bl max7219_send
//	ldr r0, =#display_test
//	ldr r1, =#0x0
//	bl max7219_send
	ldr r0, =#scan_limit
	ldr r1, =0x0
	bl max7219_send
	ldr r0, =#intensity
	ldr r1, =#0xF
	bl max7219_send
//	ldr r0, =#intensity
//	ldr r1, =#0x8
//	bl max7219_send
	ldr r0, =#shutdown		//open
	ldr r1, =0x1
	bl max7219_send
	pop {r0,r1,r2,pc}
bx lr

//	r11, r12 as delay tmp
delay:
	ldr r11, =1000
	L1: ldr r12, =1000
	L2: subs r12, #1
		bne L2
		subs r11, #1
		bne L1
		bx lr


