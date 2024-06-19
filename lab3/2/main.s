.syntax unified
.cpu cortex-m4
.thumb

//r11 represent previous value of leds, r12 represent current value of leds
.data
	leds: .byte 0
.text
 	.global main
 	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOB_MODER, 0x48000400
	.equ GPIOB_OTYPER, 0x48000404
	.equ GPIOB_OSPEEDR, 0x48000408
	.equ GPIOB_PUPDR, 0x4800040C
	.equ GPIOB_ODR, 0x48000414

	.equ GPIOC_MODER, 0x48000800
	.equ GPIOC_PUPDR, 0x4800080C
	.equ GPIOC_IDR, 0x48000810


 main:  BL   GPIO_init
		MOVS R1, #1
 		LDR R0, =leds
 		STRB R1, [R0]

 Loop: //TODO: Write the display pattern into leds variable
   		BL DisplayLED
   		BL   Delay
   		B Loop

 GPIO_init:   //TODO: Initial LED GPIO pins as output

		movs r0, #0x6			//enable port B and C
		ldr r1, =RCC_AHB2ENR
		str r0, [r1]

		ldr r1, =GPIOB_ODR
		mov r0, #(7<<4)
		strh r0, [r1]

		movs r0, #0x1540
		ldr r1, =GPIOB_MODER
		ldr r2, [r1]
		and r2, #0xFFFFC03F
		orrs r2, r2, r0
		str r2, [r1]

		ldr r1, =GPIOC_MODER
		ldr r2, [r1]
		and r2, #0xF3FFFFFF
		str r2, [r1]

		ldr r1, =GPIOC_PUPDR
		mov r2, #(1<<26)
		str r2, [r1]



		b Delay

 		BX LR

 DisplayLED: //TODO: Display LED by leds

 		ldr r10, =leds
 		ldr r12, [r10]

		cmp r12, #1
		beq leds_1
		cmp r12, #3
		beq leds_3
		cmp r12, #6
		beq leds_6
		cmp r12, #12
		beq leds_12
		cmp r12, #24
		beq leds_24

 		bx lr

 leds_1:

		mov r11, r12
		lsl r12, #1
		add r12, r12, #1
		str r12, [r10]

		ldr r1, =GPIOB_ODR
		eor r5, r12, #15
		lsl r5, #3
		str r5, [r1]

		bx lr

 leds_3:

 		cmp r11, #6
 		beq backto_1
 		goto_6:
 			mov r11, r12
			lsl r12, #1
			str r12, [r10]

			ldr r1, =GPIOB_ODR
			eor r5, r12, #15
			lsl r5, #3
			str r5, [r1]

			bx lr
		backto_1:
 			mov r11, r12
			lsr r12, #1
			str r12, [r10]

			ldr r1, =GPIOB_ODR
			eor r5, r12, #15
			lsl r5, #3
			str r5, [r1]

			bx lr
 leds_6:

 		cmp r11, #12
 		beq backto_3
 		goto_12:
 			mov r11, r12
			lsl r12, #1
			str r12, [r10]

			ldr r1, =GPIOB_ODR
			eor r5, r12, #15
			lsl r5, #3
			str r5, [r1]

			Bx lr
		backto_3:
 			mov r11, r12
			lsr r12, #1
			str r12, [r10]

			ldr r1, =GPIOB_ODR
			eor r5, r12, #15
			lsl r5, #3
			str r5, [r1]

			bx lr

 leds_12:

 		cmp r11, #24
 		beq backto_6
 		goto_24:
 			mov r11, r12
			lsl r12, #1
			str r12, [r10]

			ldr r1, =GPIOB_ODR
			eor r5, r12, #15
			lsl r5, #3
			str r5, [r1]

			bx lr
		backto_6:
 			mov r11, r12
			lsr r12, #1
			str r12, [r10]

			ldr r1, =GPIOB_ODR
			eor r5, r12, #15
			lsl r5, #3
			str r5, [r1]

			bx lr

 leds_24:

		mov r11, r12
		lsr r12, #1
		str r12, [r10]

		ldr r1, =GPIOB_ODR
		eor r5, r12, #15
		lsl r5, #3
		str r5, [r1]

		bx lr



 Delay:    //TODO
 		ldr r5, =1000
 		L1:	ldr r6, =1000
 			L2: subs r6, #1
 				bne L2
  			ldr r1, =GPIOC_IDR
			ldr r2, [r1]
//			and r2, r2, #0x2000
//			lsr r2, #13
            cmp r2, #0
 			bne cont_delay
 									//when user starts pushing the button
 //reset_counter_r3:
 			mov r3, #1
 determine_pause:
  			ldr r1, =GPIOC_IDR
			ldr r2, [r1]
            cmp r2, #0
 			bne cont_delay
 			lsl r3, #1
 			cmp r3, #16
 //			bhi reset_counter_r3
 			bne determine_pause
 hold_until_left_1:
  			ldr r1, =GPIOC_IDR
			ldr r2, [r1]
			lsr r2, #13
            cmp r2, #1
            bne	hold_until_left_1	    //user hasn't left from the button yet
 pause:								//the leds will pause
  			ldr r1, =GPIOC_IDR
			ldr r2, [r1]
 			cmp r2, #0
 			bne pause

 //reset_counter_r4:
 			mov r4, #1
 determine_resume:
  			ldr r1, =GPIOC_IDR
			ldr r2, [r1]
            cmp r2, #0
 			bne pause
 			lsl r4, #1
 			cmp r4, #16
 //			bhi reset_counter_r4
 			bne determine_resume
 hold_until_left_2:
  			ldr r1, =GPIOC_IDR
			ldr r2, [r1]
			lsr r2, #13
            cmp r2, #1
            bne	hold_until_left_2
 			bx lr

 cont_delay:
 			subs r5, #1
 			bne L1
 		bx lr






