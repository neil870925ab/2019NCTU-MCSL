.syntax unified
.cpu cortex-m4
.thumb

.data
	user_stack_bottom: .zero 128
	expr_result: .word 0

.text
	.global main
	postfix_expr:	.asciz	"70         1 - "
	.align

main:
	ldr r0, =postfix_expr
	ldr r1, =user_stack_bottom
	ldr r5, =expr_result
	mov r6, #10
	//	r13 is the stack pointer
	
	// r2 is like str[n]'s val
	// r10 is the sign bit
	// while loop
	start:
	ldrb r2, [r0]	//load the first char of postfix_expr

	cmp r2, #0
	beq	end

		// add 1 if is a blank
		cmp r2, ' '
		itt eq
		addeq r0,r0,#1
		beq start

		// see if it's a negative num
		// r3 for r0 + 1
		cmp r2, '-'
		itte eq
		addeq r3,r0,#1
		ldrbeq r2, [r3]
		bne next
			cmp r2, ' '		
			beq pminus	// postfix_arthmicts
			// condition for negative number
			add r0,r0,#1	// update r0
			b atoi_neg
			go_back_neg:
			neg r12,r12
			push {r12}
			b start

		next:

		// single '+' sign
		cmp r2,'+'
			beq ppostive


		// postive number
		b atoi_pos
		go_back_pos:
		push {r12}
		b start
	end:

	ldr r5, [sp]



program_end:
	B   program_end



atoi_neg:
// make r12 the reault
// make r11 a tmp val
mov r12,#0
start_loop_atoi:
	ldrb r2, [r0]
	cmp r2, ' '
	beq end_loop_atoi
	mul r12,r12,r6
	sub r11,r2,'0'
	add r12,r12,r11
	add r0,r0,#1
	b start_loop_atoi
end_loop_atoi:
b go_back_neg


atoi_pos:
// make r12 the reault
// make r11 a tmp val
mov r12,#0
start_loop_atoi_p:
	ldrb r2, [r0]
	cmp r2, ' '
	beq end_loop_atoi_p
	mul r12,r12,r6
	sub r11,r2,'0'
	add r12,r12,r11
	add r0,r0,#1
	b start_loop_atoi_p
end_loop_atoi_p:
b go_back_pos



// r7 r8 are for two popped value,
// r9 is for tmp result
pminus:
	ldr r7, [sp]
	ldr r8, [sp,#4]
	sub r9, r8, r7
	pop {r7, r8}
	push {r9}
	add r0,r0,#1
b start

ppostive:
	ldr r7, [sp]
	ldr r8, [sp,#4]
	add r9, r7, r8
	pop {r7,r8}
	push {r9}
	add r0,r0,#1
b start
