	.data
	.global uart_interrupt_init
	.global gpio_interrupt_init
	.global UART0_Handler
	.global Switch_Handler
	.global Timer_Handler		; This is needed for Lab #6
	.global read_character
	.global output_character	; This is from your Lab #6 Library
	.global read_string		; This is from your Lab #6 Library
	.global output_string		; This is from your Lab #6 Library
	.global output_string_nw
	.global uart_init		; This is from your Lab #6 Library
	.global simple_read_character
	.global output_string_nw
	.global parse_string
	.global int2string_nn
	.global output_string_withlen_nw
	.global tiva_pushbtn_init
	.global int2string
	.global print_cursor_location
	.global MOD
	.global num_1_string
	.global num_2_string
	.global int2string_nn
	.global movCursor_right
	.global movCursor_up
	.global movCursor_left
	.global Timer_init
	.global enable_rgb
	.global gpio_btn_and_LED_init

ran_state: .word 1
	.text

ptr_num_1_string: 				.word num_1_string
ptr_num_2_string: 				.word num_2_string
ptr_ran_state:					.word ran_state

enable_rgb:
	PUSH 	{lr}
	;Enable clock for GPIO
	mov r0, #0xE608
	movt r0,#0x400F
	ldrb r1, [r0]
	orr r1,r1,#32
	strb r1,[r0]


	;Set direction of pins to output
	mov r0, #0x5400
	movt r0,#0x4002
	ldrB r1,[r0]	;Faults here. NOT ANYMORE BOIII
	orr r1, #14 	;1110
	strb r1,[r0]

	;Set GPIO as digital
	mov r0, #0x551C
	movt r0,#0x4002
	ldrB r1,[r0]
	orr r1, #14 	;1110
	strB r1,[r0]
	POP {lr}
	MOV pc, lr

;r0-locationX(int), r1-locationY(int)
;change_cursor(r0,r1)
print_cursor_location:
	PUSH {lr}
	PUSH {r4-r5}
	;locationX
	mov r4, r0
	;locationY
	mov r5, r1
	;print cursor_postion_string
	mov r0,#27
	;output_string_nw
	bl output_character
	mov r0, #91
	bl output_character
	;load locationX
	mov r0,r4
	ldr r1, ptr_num_1_string
	;int2string (into num1_string)
	bl int2string_nn

	;if num1 >= 10 branch
	mov r0,r4
	cmp r0, #10
	BGE num1_greater
	;else num1 less
	mov r0, #48
	bl output_character
	mov r1, #1
	ldr r0, ptr_num_1_string
	bl output_string_withlen_nw
	b locationYout

num1_greater:
	ldr r0,ptr_num_1_string
	mov r1, #2
	;output_string_nw
	bl output_string_withlen_nw

locationYout:
	;load Decimal(";")
	mov r0, #59
	;output_character
	bl output_character


	;load locationY
	mov r0,r5
	ldr r1, ptr_num_2_string
	;int2string (into num1_string)
	bl int2string_nn

	;if num2 >= 10 branch
	mov r0,r5
	cmp r0, #10
	BGE num2_greater
	;else num1 less
	mov r0, #48
	bl output_character
	mov r1, #1
	ldr r0, ptr_num_2_string
	bl output_string_withlen_nw
	b end_print_cursor

num2_greater:
	ldr r0,ptr_num_2_string
	mov r1, #2
	;output_string_nw
	bl output_string_withlen_nw



end_print_cursor:
	;output H
	mov r0, #72
	bl output_character
	;load Decimal("/0")
	mov r0, #0
	;output_character
	bl output_character
	POP {r4-r5}
	POP {lr}
	mov pc,lr



;Moves cursor by a r0 amount of places
movCursor_right:
	PUSH {lr}
	;Save spaces to move by
	mov r5,r0

loop_right:
	sub r5,r5,#1
	;output escape sequence
	mov r0,#27
	bl output_character

	;output '['
	mov r0, #91
	bl output_character
	;output value to move by
	mov r0,r5
	bl output_character
	;output ending character
	mov r0,#67
	bl output_character
	;ouptut Null byte
	mov r0,#0
	bl output_character

	cmp r5,#0
	bne loop_right

	POP {lr}
	mov pc,lr

movCursor_left:
	PUSH {lr}
	;Save spaces to move by
	mov r5,r0
loop_left:
	sub r5,r5,#1
	;output escape sequence
	mov r0,#27
	bl output_character

	;output '['
	mov r0, #91
	bl output_character
	;output value to move by
	mov r0,r5
	bl output_character
	;output ending character
	mov r0,#68
	bl output_character
	;ouptut Null byte
	mov r0,#0
	bl output_character
	cmp r5,#0
	bne loop_left

	POP {lr}
	mov pc,lr

movCursor_up:
	PUSH {lr}

	;Save spaces to move by
	mov r5,r0
loop_up:
	sub r5, r5,#1
	;output escape sequence
	mov r0,#27
	bl output_character

	;output '['
	mov r0, #91
	bl output_character
	;output value to move by
	mov r0,r5
	bl output_character
	;output ending characterB
	mov r0,#65
	bl output_character
	;ouptut Null byte
	mov r0,#0
	bl output_character
	cmp r5,#0
	bne loop_up
	POP {lr}
	mov pc,lr

movCursor_down:
	PUSH {lr}

	;Save spaces to move by
	mov r5,r0
loop_down:
	sub r5,r5,#1
	;output escape sequence
	mov r0,#27
	bl output_character

	;output '['
	mov r0, #91
	bl output_character
	;output value to move by
	mov r0,r5
	bl output_character
	;output ending character
	mov r0,#66
	bl output_character
	;ouptut Null byte
	mov r0,#0
	bl output_character
	cmp r5,#0
	bne loop_down

	POP {lr}
	mov pc,lr

Timer_init:
	PUSH {lr}
	;Enable clock (1)->0th bit of: 0x400FE604
	MOV r0, #0xE604
	MOVT r0, #0x400F
	ldr r1, [r0]
	ORR r1, r1, #1
	str r1, [r0]

	;disable GPTMCTL TAEN (1)->1st bit of:  0x4003000C
	MOV r0, #0x000C
	MOVT r0, #0x4003
	ldr r1, [r0]
	mvn r2, #1
	and r1,r1,r2
	str r1, [r0]

	;enable 32 mbit mode (1)->1st bit of:  0x40030000
	MOV r0, #0x0000
	MOVT r0, #0x4003
	ldr r1, [r0]
	mvn r2,  #1
	and r1, r2,r1
	str r1, [r0]

	;Put timer into Periodic mode GPTMTAMR (1)->2nd bit 0x40030004
	MOV r0, #0x0004
	MOVT r0, #0x4003
	ldr r1, [r0]
	orr r1, r1, #2
	MVN r2, #1
	AND r1,r1,r2
	str r1, [r0]


	;Setup Interrupt interval period (GPTMTAILR) register0x40030028
	;set to 16M -> 16,000,000-> 0xF42400 ticks per cycle
	MOV r0, #0x0028
	MOVT r0, #0x4003
	ldr r1, [r0]
	MOV r1, #0xD400
	MOVT r1, #0x0030
	str r1, [r0]

	;Setup interrup intervbal to interrupt the processor 1->0th bit of 0x40030018
	MOV r0, #0x0018
	MOVT r0, #0x4003
	ldr r1,[r0]
	orr r1,#1
	str r1,[r0]

	;Configure timer to interrupt processor (1)->19th bit of 0xE000E100
	MOV r0, #0xE100
	MOVT r0, #0xE000
	ldr r1, [r0]
	MOV r2,#1
	lsl r2,r2,#19
	orr r1, r1, r2
	str r1, [r0]

	;Enable timer 1->1st bit of 0x4003000C
	MOV r0, #0x000C
	MOVT r0, #0x4003
	ldr r1, [r0]
	orr r1, r1, #1
	str r1, [r0]

	POP {lr}
	MOV pc,lr


uart_interrupt_init:
	PUSH {lr}
	;Set the Receive Interrupt Mask (RXIM) bit in the UART Interrupt Mask Register (UARTIM)
	;UART0 Base Address: 0x4000C000
	;UARTIM offset: 0x038
	;RXIM bit position: 4
	MOV r0, #0xC000
	MOVT r0, #0x4000

	MOV r1, #16		;bit 4 is 1

	LDRB r2, [r0, #0x038]

	ORR r2, r1, r2

	STRB r2, [r0, #0x038]


	;Configure Processor to Allow the UART to Interrupt Processor
	;EN0 Base Address: 0xE000E000
	;EN0 Offset: 0x100
	;UART0 Bit Position: Bit 5

	MOV r0, #0xE000
	MOVT r0, #0xE000

	MOV r1, #32				;bit 5 has 1

	LDRB r2, [r0, #0x100]

	ORR r2, r1, r2

	STRB r2, [r0, #0x100]

	POP {lr}
	MOV pc, lr


gpio_interrupt_init:
	PUSH {lr}
	; Your code to initialize the SW1 interrupt goes here
	; Don't forget to follow the procedure you followed in Lab #4
	; to initialize SW1.



	;enable interrupt sensitivitye register GPIOIS
	MOV r0, #0x5404
	MOVT r0, #0x4002
	LDR r1, [r0]
	BIC  r1,r1, #16
	STR r1,[r0]

	;Enable interupt direction(s) gpioibe ;Consider removing this when debugging
	MOV r0, #0x5408
	MOVt r0, #0x4002
	LDR r1, [r0]
	BIC r1,r1,#16
	STR r1,[r0]

	;Enable rising edge interrupt GPIOIV
	MOV r0, #0x540C
	MOVt r0, #0x4002
	LDR r1, [r0]
	BIC r1,#16
	STR r1,[r0]

	;Enable nterrupt GPIOIM
	MOV r0, #0x5410
	MOVt r0, #0x4002
	LDR r1, [r0]
	ORR r1,r1,#16
	STR r1,[r0]



	;Convfigure Procesor to Allow GPIO Port F to interrupt processor
	MOV r0, #0xE100
	MOVt r0, #0xE000
	LDR r1, [r0]
	MOV r2, #1
	LSL r2, r2, #30
	ORR r1,r1, r2 ;lol 2^30
	STR r1,[r0]

	POP {lr}
	MOV pc, lr



simple_read_character:

	PUSH{lr}
	;Load UARTDR base register
	MOV r1, #0xC000
	MOVT r1, #0x4000

	;Load lower byte from UARTDR into r0
	LDRB r0, [r1]

	POP{lr}
	MOV PC,LR      	; Return


;Inputs:
;outputs: r0 - character from uart
;Used (unpreservered)Registers:
read_character:

	;Read charactor from uart and store in r0
	PUSH {lr}   ; Store register lr on stack

FLAGCHECK:
	;Load UARTFR base register
	MOV r1, #0xC000
	MOVT r1, #0x4000

	;Get UART0 flag byte
	LDRB r2, [r1,#0x18]

	;Check Flag(RxFE) to ensure buffer is full (when RxFE is 0)
	;Store mask of (16 & flagRegister)
	AND r3, r2, #0x10


	;Branch to  flagcheck if resultMask is 16
	CMP r3,#0x10
	BEQ FLAGCHECK

	;Load lower byte from UARTDR into r0
	LDRB r0, [r1,#0]




	POP {lr}
	mov pc, lr

output_string_nw:
;transmits a NULL-terminated ASCII string for display in PuTTy.
;The base address of the string should be passed into the routine in r0.

	PUSH {lr}   ; Store register lr on stack
	PUSH {r4}	; pushing r4 to make a copy of base address (currently in r0)

	MOV r4, r0	;making copy of base address in r4
	MOV r2, #0
Outputting_nw:
	LDRB r0, [r4]		; loading the character from the base address in r4
	BL output_character	;call output_character
	ADD r4, r4, #1;		increment r4's address by 1

	LDRB r1, [r4]
	CMP r1, r2			;checking if data in r4 is NULL
	BNE Outputting_nw		; if it is not, go back


	POP{r4}
	POP {lr}
	mov pc, lr

output_string_withlen_nw:
;transmits a ASCII string for display in PuTTy.
;The base address of the string should be passed into the routine in r0
;length of string is stored in r1

	PUSH {lr}   ; Store register lr on stack
	PUSH {r4,r5}	; pushing r4 to make a copy of base address (currently in r0)

	mov r5,r1

	MOV r4, r0	;making copy of base address in r4
Outputting_withlen_nw:
	LDRB r0, [r4]		; loading the character from the base address in r4
	BL output_character	;call output_character
	ADD r4, r4, #1;		increment r4's address by 1
	sub r5, r5, #1
	CMP r5, #0			;checking if data in r4 is NULL
	BNE Outputting_withlen_nw		; if it is not, go back


	POP{r4,r5}
	POP {lr}
	mov pc, lr

output_string:
;transmits a NULL-terminated ASCII string for display in PuTTy.
;The base address of the string should be passed into the routine in r0.

	PUSH {lr}   ; Store register lr on stack
	PUSH {r4}	; pushing r4 to make a copy of base address (currently in r0)

	MOV r4, r0	;making copy of base address in r4
	MOV r2, #0
Outputting:
	LDRB r0, [r4]		; loading the character from the base address in r4
	BL output_character	;call output_character
	ADD r4, r4, #1;		increment r4's address by 1

	LDRB r1, [r4]
	CMP r1, r2			;checking if data in r4 is NULL
	BNE Outputting		; if it is not, go back

	;Print newline
	;push registers
	PUSH {r0,r1}
	MOV r0, #10
	;r0 = outputChar
	bl output_character
	POP {r0,r1}

	;Print carriage return
	;push registers
	PUSH {r0,r1}
	MOV r0, #13
	;r0 = outputChar
	bl output_character
	POP {r0,r1}

	POP{r4}
	POP {lr}
	mov pc, lr


; Your code for your read_string routine is placed here
;Theres def a shorter way to do this...
;Inputs: r0 - base address to store string
read_string:
	PUSH {lr}   ; Store register lr on stack

	push {r0}
	;r0  = read_character()
	bl read_character

	;r1 = r0
	MOV r1, r0

	;POP old r0 prior to read_character
	POP {r0}

	;end if char == /0
	CMP r1, #0
	BEQ read_string_finish

	;else output char and store byte
	;push registers
	PUSH {r0,r1}
	MOV r0,r1
	;r0 = outputChar
	bl output_character
	POP {r0,r1}

	;Pop registers

	STRB r1, [r0]




read_string_loop1:
	;incrament mem pointer
	ADD r0, r0, #1

	;Push r0 prior to calling read_char
	PUSH {r0}

	;r0  = read_character()
	BL read_character

	;r1 = char
	MOV r1, r0

	;POP old r0 prior to read_character
	POP {r0}

	;Check if its the enter char
	cmp r1, #13

	;End loop if char == enter char
	BEQ read_string_finish

	;else output char and store byte
	;push registers
	PUSH {r0,r1}
	MOV r0,r1
	;r0 = outputChar
	bl output_character
	POP {r0,r1}

	;Store byte
	STRB r1, [r0]


	;Just in case ARM is weird
	CMP r1, #13

	;Branch back to loopStart
	BNE read_string_loop1

read_string_finish:
	;incrament mem pointer
	;ADD r0, r0, #0x1

	;Store null byte
	MOV r1, #0x0
	STRB r1, [r0]

	;Print newline
	;push registers
	PUSH {r0,r1}
	MOV r0, #10
	;r0 = outputChar
	bl output_character
	POP {r0,r1}

	;Print carriage return
	;push registers
	PUSH {r0,r1}
	MOV r0, #13
	;r0 = outputChar
	bl output_character
	POP {r0,r1}

	;Yay
	POP {lr}
	mov pc, lr



; Your code for your output_character routine is placed here
output_character:
; transmits a character from the UART to PuTTy.  The character is passed in r0

	PUSH {lr}   ; Store register lr on stack
	PUSH {r4}
	; Your code to output a character to be displayed in PuTTy
	; is placed here.  The character to be displayed is passed
	; into the routine in r0.
	MOV r1, #0xC000
	MOVT r1, #0x4000; r1 has UARTFR Address
	MOV r4, #32

TestFlag:
	LDRB r3, [r1, #0x18]		;r3 has the UARTFR data byte
	AND r3, r3, #32		;Masking r3 to only have the TxFF bit
	CMP r3, r4
	BEQ TestFlag		;testing if bit 5 is 1, if it is, go back to TestFlag

	MOV r1, #0xC000		; r1 has the UARTDR address
	MOVT r1, #0x4000
	STRB r0, [r1]		; store r0 into UARTDR data segment

	;update random sta
	ldr r0, ptr_ran_state
	ldr r0, [r0,#0]
	add r0, r0,#1
	ldr r1, ptr_ran_state
	str r0, [r1,#0]
	POP {r4}
	POP {lr}
	mov pc, lr

; Your code for your uart_init routine is placed here
;Inputs:
;Outputs:
uart_init:
	PUSH {lr}  ; Store register lr on stack

	;(*((volatile uint32_t *)(0x400FE618))) = 1;
	MOV r0,#0xE618
	MOVT r0,#0x400F
	MOV r1,#1
	STR r1, [r0]

	;/* Enable clock to PortA  */
	;(*((volatile uint32_t *)(0x400FE608))) = 1;
	MOV r0,#0xE608
	MOVT r0,#0x400F
	MOV r1,#1
	STR r1, [r0]

	;/* Disable UART0 Control  */
	;(*((volatile uint32_t *)(0x4000C030))) = 8;
	MOV r0, #0xC030
	MOVT r0, #0x4000
	MOV r1, #8
	STR r1, [r0]

	;/* Set UART0_IBRD_R for 115,200 baud */
	;(*((volatile uint32_t *)(0x4000C024))) = 8;
	MOV r0, #0xC024
	MOVT r0, #0x4000
	MOV r1,#8
	STR r1,[r0]

	;/* Set UART0_FBRD_R for 115,200 baud */
	;(*((volatile uint32_t *)(0x4000C028))) = 44;
	MOV r0,#0xC028
	MOVT r0,#0x4000
	MOV r1,#44
	STR r1,[r0]

	;/* Use System Clock */
	;(*((volatile uint32_t *)(0x4000CFC8))) = 0;
	MOV r0,#0xCFC8
	MOVT r0,#0x4000
	MOV r1,#0
	STR r1,[r0]

	;/* Use 8-bit word length, 1 stop bit, no parity */
	;(*((volatile uint32_t *)(0x4000C02C))) = 0x60;
	MOV r0, #0xC02C
	MOVT r0, #0x4000
	MOV r1,#0x60
	STR r1,[r0]

	;/* Enable UART0 Control  */
	;(*((volatile uint32_t *)(0x4000C030))) = 0x301;
	MOV r0,#0xC030
	MOVT r0,#0x4000
	MOV r1, #0x301
	STR r1,[r0]


    ;/*************************************************/
	;/* The OR operation sets the bits that are OR'ed */
	;/* with a 1.  To translate the following lines   */
	; to assembly, load the data, OR the data with  */
	;/* the mask and store the result back.           */
    ;/*************************************************/

	;/* Make PA0 and PA1 as Digital Ports  */
	;(*((volatile uint32_t *)(0x4000451C))) |= 0x03;
	MOV r1, #0x03
	MOV r0, #0x451C
	MOVT r0, #0x4000

	;Temp = *(volatile uint32_t *)(0x4000451C)
	ldr r2, [r0]

	;Temp = Temp | 0x03
	ORR r2, r2,r1

	;*(volatile uint32_t *)(0x4000451C) = Temp = (volatile uint32_t *)(0x4000451C) |  0x03
 	STR r2, [r0]


	;/* Change PA0,PA1 to Use an Alternate Function  */
	;(*((volatile uint32_t *)(0x40004420))) |= 0x03;
	MOV r1, #0x03
	MOV r0, #0x4420
	MOVT r0, #0x4000

	;Temp = *(volatile uint32_t *)(0x40004420)
	ldr r2, [r0]

	;Temp = Temp | 0x03
	ORR r2, r2,r1

	;*(volatile uint32_t *)(0x40004420) = Temp = (volatile uint32_t *)(0x40004420) |  0x03
 	STR r2, [r0]


	;/* Configure PA0 and PA1 for UART  */
	;(*((volatile uint32_t *)(0x4000452C))) |= 0x11; c
	MOV r1, #0x11
	MOV r0, #0x452c
	MOVT r0, #0x4000

	;Temp = *(volatile uint32_t *)(0x4000452C)
	ldr r2, [r0]

	;Temp = Temp | 0x11
	ORR r2, r2,r1

	;*(volatile uint32_t *)(0x4000452C) = Temp = (volatile uint32_t *)(0x4000452C) |  0x11
 	STR r2, [r0]



	;Print instructions to the screen
	;no
	POP {lr}
	mov pc, lr

;****************************************************************HELPER SUBROUTINES************************************************************************
;*****************************************************************************************************
gpio_btn_and_LED_init:
;initializes the four push buttons on the Alice EduBase board, the four LEDs on the AliceEduBase board,
;the momentary push button on the Tiva board (SW1), and the RGB LED on the Tiva board. It should NOT
;initialize the keypad.  That code is provided for you and can be downloaded from the course website.


;PushButtons: Port D, pins 0-3 (buttons 2 to 5)
;LEDs: Port B, pins 0-3
	PUSH {lr} ; Store register lr on stack

	bl tiva_pushbtn_init
	;enabling clock for port B and D
	;clock control register base address: 0x400FE608
	MOV r0, #0xE608
	MOVT r0, #0x400F

	LDRB r1, [r0]
	MOV r2, #0xA
	ORR r1, r1, r2		;port B is pin 1 and port D is pin 3
	STRB r1, [r0]


	;initialize LEDs
	MOV r0, #0x5000
	MOVT r0, #0x4000	;base adddress of port B is 0x40005000

	LDRB r1, [r0, #0x400]
	ORR r1, r1, #0xF	;direction of pins 0-3 should be 1 for output
	STRB r1, [r0, #0x400] ;offset of data direction register is 0x400

	LDRB r1, [r0, #0x51C]
	ORR r1, r1, #0xF
	STRB r1, [r0, #0x51C] ;configuring pins 0-3 to be digital (digital register offset is 0x51C)

	LDRB r1, [r0, #0x510]
	ORR r1, r1, #0xF
	STRB r1, [r0, #0x510]	;configuring pullup resistor (pullup register offset is 0x510)

	;initialize PushButtons
	MOV r0, #0x7000
	MOVT r0, #0x4000		;Base adddress for port D is 0x40007000

	LDRB r1, [r0, #0x400]
	MVN r3, #0xF			;direction of pins 0-3 must be 0 for input
	AND r1, r1, r3
	STRB r1, [r0, #0x400]	;configuring pins 0-3 to be input

	LDRB r1, [r0, #0x51C]
	ORR r1, r1, #0xF		;writing 1 to pins for enable digital and pullup resistor
	STRB r1, [r0, #0x51C]	;configuring pins 0-3 to be digital (digital register offset is 0x51C)

	LDRB r1, [r0, #0x510]
	AND r1, r1, r3
	;ORR r1, r1, #0xF
	STRB r1, [r0, #0x510]	;(dis)configuring pullup resistor (pullup register offset is 0x510)

	POP {lr}
	MOV pc, lr

;Your code for your int2string routine is placed here
;Inputs: r0 - Integer to store as a string
;		 r1 - Address to store 32-byte
;
;Used Registers:
int2string:
	PUSH {lr}   ; Store register lr on stack
	PUSH {r4}

	;Store copy of base address
	MOV r4,r1

	CMP r0, #0
	beq int_is_zero

	;Push r0 and r1 before the call to integer_digits
	PUSH {r0,r1}

	;r1 = integer_digits(r0,r1-doesntmatter)
	MOV r1, #0x0
	BL integer_digit

	;Store (numDigits - 1) in r2
	SUB r2, r0, #0x1

	;Pop old r0 & r1 from stack
	POP {r0,r1}


int2StringLoop1:
	;Push r0,r1,r2 prior to calling nth digit
	PUSH {r0,r1,r2}

	;MOV r2(nth digit to find) to r1
	MOV r1,r2

	;r0(nth place digit),r1(num digits) = integerDigit(r0(dec),r1(n))
	BL integer_digit


	;Store result + AsciiHexOffset in r3
	ADD r3,r1,#48

	;Pop r0,r1,r2 POST integerDigit call
	POP {r0,r1,r2}

	;Store lower byte of r3 into memory pointed to by r1
	STRB r3, [r1]

	;Incrament mem address r1
	ADD r1,r1,#0x1

	;Decrament nth place r2
	SUB r2,r2,#0x1

	;Branch to int2StringLoop1 if r2 < 0  (or ==-1)
	CMP r2,#-1
	BNE int2StringLoop1
	;Else
	b store_null

int_is_zero:
	MOV r2, #48
	STRB r2, [r1]
	ADD r1, r1,#1


store_null:
	;Store NULL and then exit EXIT
	MOV r0,#0
	STRB r0,[r1]

	;Reset to base address
	MOV r1,r4

	POP {r4}
	POP {lr}
	mov pc, lr

;Your code for your int2string routine is placed here
;Inputs: r0 - Integer to store as a string
;		 r1 - Address to store 32-byte
;outputs:
;	r0 - length of string
;
;no null byte at the end
;
;Used Registers:
int2string_nn:
	PUSH {lr}   ; Store register lr on stack
	PUSH {r4-r5}

	;Store copy of base address
	MOV r4,r1



	CMP r0, #0
	beq int_is_zero_nn

	;initialize length to be atleast one dige
	mov r5,#1

	;Push r0 and r1 before the call to integer_digits
	PUSH {r0,r1}

	;r1 = integer_digits(r0,r1-doesntmatter)
	MOV r1, #0x0
	BL integer_digit

	;store numDigits in r5
	mov r5,r0
	;Store (numDigits - 1) in r2
	SUB r2, r0, #0x1

	;Pop old r0 & r1 from stack
	POP {r0,r1}


int2StringLoop1_nn:
	;Push r0,r1,r2 prior to calling nth digit
	PUSH {r0,r1,r2}

	;MOV r2(nth digit to find) to r1
	MOV r1,r2

	;r0(nth place digit),r1(num digits) = integerDigit(r0(dec),r1(n))
	BL integer_digit


	;Store result + AsciiHexOffset in r3
	ADD r3,r1,#48

	;Pop r0,r1,r2 POST integerDigit call
	POP {r0,r1,r2}

	;Store lower byte of r3 into memory pointed to by r1
	STRB r3, [r1]

	;Incrament mem address r1
	ADD r1,r1,#0x1

	;Decrament nth place r2
	SUB r2,r2,#0x1

	;Branch to int2StringLoop1 if r2 < 0  (or ==-1)
	CMP r2,#-1
	BNE int2StringLoop1_nn
	;Else
	mov r0,r5
	b store_null_nn

int_is_zero_nn:
	MOV r2, #48
	STRB r2, [r1]
	ADD r1, r1,#1
	mov r0,#1

store_null_nn:
;Reset to base address

	POP {r4-r5}
	POP {lr}
	mov pc, lr


;Integer_digit
;Inputs: r0	- Decimal value
;		 r1 - n place in decimal value to find
;
;Outputs: r0 - nth place digit in decimal value
;		  r1 - number of digits to place
integer_digit:			; Your code for the integer_digit routine goes here.
	PUSH{lr}
	CMP r0, #0
	BEQ ALMOSTFINISH
	cmp r0,#10
	BLT ALMOSTFINISH1
	MOV r2, #10			;10
	MOV r3, #1			 ;Decimal digit counter
	MOV r4, r0			;inital r0 with deciaml place to be shifted


countDigLoop:			;Loop until r4 is shifted to the left most digit

	ADD r3, r3, #1		;Incrament r3
	SDIV r4, r4, r2		;Shift r4 by one decimal place


	CMP r4, #10			;r4 will be at its left most digit when r4 < 10
	BGE countDigLoop

						;Num of decimal digits stored in r3
	PUSH {r0,r1}
	bl nthPlace

	MOV r4, r0
	POP {r0,r1}
	MOV r0, r3
	MOV r1, r4

	b FINISH
ALMOSTFINISH:
	mov r0, #0
	mov r1, #0

ALMOSTFINISH1:
	MOV r1,r0
	MOV r0,#1

FINISH:
	POP {lr}
	MOV pc, lr


nthPlace:				;find the digit in the r1 = nth place of r0(r2 used
	PUSH {lr}
	PUSH {r2,r3,r4}
	MOV r2,r0
	MOV r3,r1


	MOV r0, #10
	bl POW			;r0 = 10^r1(n)


	SDIV r0, r2, r0	;r0 = val/10^n & r1 = n
	MOV r1, #10
	PUSH {r0,r1}			;Store r0 & r1
	bl MOD				; r0 = r0 mod 10
	MOV r2, r0			;Move result from r0 to r2
	POP {r0,r1}			; Get r0 and r1 back


	;r0 = divided val, r1 = 10 , r2 = dvidedVal mod 10

	CMP r2, #0
	BEQ endNthPlaceLoop
	MOV r3, #0
nthPlaceLoop:

	ADD r3, r3, #1
	SUB r0, r0, #1
	push {r0,r1}
	MOV r1, #10
	BL MOD
	MOV r2, r0
	POP {r0,r1}
	CMP r2, #0
	BNE nthPlaceLoop

endNthPlaceLoop:
	MOV r0,r3
	pop {r2,r3,r4}
	pop {lr}
	MOV pc, lr

MOD:					;Take r0 = r0 mod r1		(r0 & r1 as arguments. r2 is used)
	PUSH {lr}
	PUSH {r2}
	SDIV r2, r0, r1		;r2 = floor(r0/r1)
	MUL r1, r1, r2		;r1 = r1 * r2
	SUB r0,	r0, r1		;r0 = r0 mod r1
	POP {r2}
	POP {lr}
	MOV pc, lr

POW:					;r0 has base, r1 has exponential
	PUSH {lr}
	PUSH {r2}
	MOV r2, #1
	CMP r1, #0		;Stop if the exponential is 0
	BEQ donePow1

powLoop:
					;Push the registers that were used in the subroutine
	MUL r2, r2, r0
	SUB r1, r1, #1
	CMP r1, #0
	BNE powLoop			;Stop if the exponential is 0



donePow1: 				;Pow exit
	MOV r0, r2			;Return stored in r0
	POP {r2}
	POP {lr}
	MOV pc,lr

tiva_pushbtn_init:
	PUSH {lr}
	;enabling clock for port F
	;SYSCTL_RCGC_GPIO address: 0x400FE608
	MOV r1, #0xE608
	MOVT r1, #0x400F
	;port F is pin 5
	LDRB r2, [r1]
	ORR r2, r2, #0x20	; pin 5 must be 1 to enable clock
	STRB r2, [r1]


	;Setting pin 4 as Input (as it is reading data from the board)
	; Port F base address: 0x40025000
	MOV r1, #0x5000
	MOVT r1, #0x4002
	;data direction register adress offset: 0x400
	;push button SW1 is pin 4
	LDRB r2, [r1, #0x400]
	MVN r3, #0x10
	AND r2, r2, r3		;pin 4 must be 0 to be INPUT
	STRB r2, [r1, #0x400]

	;Setting pin 4 as digital
	;Digital enable Register offset: 0x51C
	LDRB r2, [r1, #0x51C]
	ORR r2, r2, #0x10	;pin 4 must be 1 to enable digital
	STRB r2, [r1, #0x51C]

	;Configuring pullup resistor
	;offset: 0x510
	LDRB r2, [r1, #0x510]
	ORR r2, r2, #0x10	;pin 4 must be 1 to enable pullup resistor
	STRB r2, [r1, #0x510]
	POP {lr}
	MOV pc,lr


read_tiva_pushbutton:
	;read_from_push_btn reads from the momentary push button (SW1) on the Tiva board
;returns a one (1) in r0 if the button is currently being pressed and a zero (0) if it is not.

;push button SW1: PORT F PIN 4
;Port F base address: 0x40025000

	PUSH {lr}
	MOV r1, #0x5000
	MOVT r1, #0x4002
	LDRB r2, [r1, #0x3FC]
	AND r2, r2, #0x10	;masking pin 4 data
	MOV r0, #0			; r0 is 0 for now...
	CMP r2, #0x10		;checking if pin 4 reads 1
	BEQ read_tiva_pushbutton_end		; if it is, it can just end because r0 was set to 0
	MOV r0, #1			; if it is not, return 1 in r0

read_tiva_pushbutton_end:

	POP {lr}
	MOV pc, lr

parse_string: ; start
    PUSH {lr}       ; save the return
	STRB r2, [r0,r1]
    pop {lr}        ; return
    mov pc, lr



;****************************************************************END HELPER SUBROUTINES************************************************************************



	.end
