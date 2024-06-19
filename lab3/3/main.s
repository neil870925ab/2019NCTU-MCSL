.syntax unified
.cpu cortex-m4
.thumb


.data
	passwords: .byte 0xC  //1100
.text
 	.global main
 	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOB_MODER, 0x48000400
	.equ GPIOB_ODR, 0x48000414
	.equ GPIOC_MODER, 0x48000800
	.equ GPIOC_PUPDR, 0x4800080C
	.equ GPIOC_IDR, 0x48000810

main:

		BL  GPIO_init

Press_Button_or_not:			//r3 to record whether pressing the button

		ldr r1, =GPIOB_ODR
		mov r0, #(15<<3)
		strh r0, [r1]

		ldr r2, =GPIOC_IDR
		ldr r3, [r2]
		mov r5, #1
		lsl r5, #13
		and r6, r3, r5
		cmp r6, #0				// r6 = 0 means the user has pressed the button
		bne Press_Button_or_not

		ldr r7, =passwords
		ldr r8, [r7]            // r8 records the passwords
		and r9, r3, #0xF
		eor r10, r9, #0xF       // r10 records user's input
		cmp r8, r10
		bne Blink_one_times
		beq Blink_three_times

GPIO_init:

		movs r0, #0x6			//enable port B and C
		ldr r1, =RCC_AHB2ENR
		str r0, [r1]

		ldr r1, =GPIOB_ODR
		mov r0, #(15<<3)
		strh r0, [r1]

		movs r0, #0x1540
		ldr r1, =GPIOB_MODER
		ldr r2, [r1]
		and r2, #0xFFFFC03F
		orrs r2, r2, r0
		str r2, [r1]

		ldr r1, =GPIOC_MODER
		ldr r2, [r1]
		ldr r3, =0xF3FFFF00		//and r2, #0xF3FFFF00 doesn't work
		and r2, r2, r3
		str r2, [r1]

		bx lr


Blink_one_times:

		bl DisplayLED
		bl Delay
		ldr r1, =GPIOB_ODR
		mov r0, #(15<<3)
		strh r0, [r1]
		bl Delay

		b Press_Button_or_not

Blink_three_times:

		mov r11, #3
	Loop:
		sub r11, r11, #1
		bl DisplayLED
		bl Delay
		ldr r1, =GPIOB_ODR
		mov r0, #(15<<3)
		strh r0, [r1]
		bl Delay

		cmp r11, #0
		bne Loop
		b Press_Button_or_not

DisplayLED:

		ldr r1, =GPIOB_ODR
		mov r0, #0
		strh r0, [r1]
		bx lr

Delay:

 		ldr r7, =500
 		L1:	ldr r9, =500
 			L2: subs r9, #1
 				bne L2
 			subs r7, #1
 			bne L1
 		bx lr




