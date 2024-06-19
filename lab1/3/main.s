.data
	arr1: .byte 0x19, 0x34, 0x14, 0x32, 0x52, 0x23, 0x61, 0x29
	arr2: .byte 0x18, 0x17, 0x33, 0x16, 0xFA, 0x20, 0x55, 0xAC
.text
	.global main	//r1=i, r2=j, r3=arr[i], r4=arr[j], r5=counter (how many numbers haven't been sorted)

swap:
	movs r6, r3		//r6=temp register
	movs r3, r4
	movs r4, r6
	b store

check:
	sub r5, r5, #1
	cmp r5, #1		//when r5=1, it means only one number(at the far left) hasn't been sorted.(It represents the bubble sort is done)
	bne do_sort
	bx lr

do_sort:
	movs r1, #0
	movs r2, #1
	sort:
		ldrb r3, [r0, r1]
		ldrb r4, [r0, r2]
		cmp r3, r4
		bhi swap
		store:
			strb r3, [r0, r1]
			strb r4, [r0, r2]
		push:
			add r1, r1, #1
			add r2, r1, #1
			cmp r2, r5
			beq check
			bne sort

main:
	movs r5, #8
	ldr r0, =arr1
	bl do_sort
	movs r5, #8
	ldr r0, =arr2
	bl do_sort

L: b L
