	.syntax	unified
	.cpu	cortex-m4
	.thumb

.text
	.global	delay_1s
	.global	GPIO_init
	.equ	RCC_AHB2ENR,	0x4002104c

	.equ	GPIOA_MODER,	0x48000000
	.equ	GPIOA_OSPEEDR,	0x48000008

	.equ	GPIOC_MODER,	0x48000800

delay_1s:
	ldr r11, =1000
	L1: ldr r12, =1000
	L2: subs r12, #1
		bne L2
		subs r11, #1
		bne L1
		bx lr


GPIO_init:
	movs	r0, 0x5
	ldr	r1, =RCC_AHB2ENR
	str	r0, [r1]

	movs	r0, 0x400
	ldr	r1, =GPIOA_MODER
	ldr	r2, [r1]
	ands	r2, r2, 0xfffff3ff
	orrs	r2, r2, r0
	str	r2, [r1]

    	ldr     r1, =GPIOC_MODER
    	ldr     r2, [r1]
    	ands    r2, r2, 0xf3ffffff
    	str     r2, [r1]

	movs	r0, 0x800
	ldr	r1, =GPIOA_OSPEEDR
	str	r0, [r1]
	bx	lr
