    .data

	.global prompt
	.global uart_interrupt_init
	.global gpio_interrupt_init
	.global UART0_Handler
	.global Switch_Handler
	.global Timer_Handler		; This is needed for Lab #6
	.global output_character	; This is from your Lab #6 Library
	.global read_string		; This is from your Lab #6 Library
	.global output_string		; This is from your Lab #6 Library
	.global uart_init		; This is from your Lab #6 Library
	.global simple_read_character
	.global labGame
	.global output_string_nw
	.global parse_string
	.global int2string_nn
	.global output_string_withlen_nw
	.global tiva_pushbtn_init
	.global int2string
	.global Timer_init
	.global movCursor_down
	.global movCursor_up
	.global movCursor_right
	.global movCursor_left
	.global print_cursor_location
	.global MOD
	.global num_1_string
	.global num_2_string
	.global int2string_nn
	.global movCursor_right
	.global num_1_string
	.global num_2_string

prompt:	.string "Press SW1 or a key (q to quit)", 0
ball_data_block: .word 0
spacesMoved_block: .word 0
data_block: 	   .word 0
paddleDataBlock .word 0
game_data_block .word 0

start_prompt:	.string "BREAKOUT GAME", 0
row_instructions: .string "Select rows of bricks:", 0
rows_prompt: 	.string "[sw2] 1 row    [sw3] 2 rows    [sw4] 3 rows    [sw5] 4 rows", 0
game_instructions: .string "How to play:",0
instructions_prompt:	.string " Press a to move paddle left, press d to move paddle left, press sw1 to pause", 0
space_prompt:	.string "[PRESS SPACE TO START]",0

paddle:	.string "-----", 0
score_str: .string "Score: ", 0
score_val: .word 0

bricks: .word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;28 bricks
ran_state: .word 1


pause: .string "PAUSE", 0
pause_clear: .string "     ", 0
gameOver: .string  "GAME OVER", 0
exit_letter: .string "PRESS [e] TO END THE GAME", 0
restart_letter: .string "PRESS [r] TO RESTART THE GAME", 0
top_bottom_borders: .string "+---------------------+", 0
side_borders: .string "|                     |", 0 ;The board is 20 characters by 20 characters in size (actual size inside the walls).
cursor_position: .string 27, "[" ;set up a cursor position variable that will be 10 - 10
home: .string 27, "[1;1H",0
clear_screen: .string 27, "[2J",0 ; clear screen cursor position moved to home row 0, line 0zzz
backspace:	.string 27, "[08", 0
asterisk:	.string 27, "*", 0
saveCuror:	  .string 27, "[s",0
restoreCuror: .string 27, "[u",0
num_1_string: .string 27, "   "
num_2_string: .string 27, "   "
test_esc_string: .string 27, "[48;5;255m",0
test_esc_string1: .string 27, "[38;5;232m",0
;test_esc_string: .string 27, "[38;5;30mHello",27,"[48;5;233m",27,"[38;5;164mThere",0

	.text

ptr_to_start_prompt:	        .word start_prompt
ptr_to_row_instructions_prompt: .word row_instructions
ptr_to_rows_prompt: 	        .word rows_prompt
ptr_to_game_instructions_prompt: .word game_instructions
ptr_to_instructions_prompt:		.word instructions_prompt
ptr_to_space_prompt: 			.word space_prompt

ptr_to_paddle:		            .word paddle
ptr_to_score_str:		        .word score_str
ptr_to_score_val:		        .word score_val

ptr_to_prompt:				    .word prompt
prt_to_dataBlock: 			    .word data_block
ptr_to_game_data_block:	        .word game_data_block


ptr_to_exit_letter:				.word exit_letter
ptr_to_retart_letter:			.word restart_letter
ptr_to_gameOver: 				.word gameOver
ptr_to_pause: 					.word pause
ptr_to_pause_clear: 					.word pause_clear
ptr_to_top_bottom_borders:		.word top_bottom_borders
ptr_to_side_borders:		    .word side_borders
ptr_to_cursor_position: 	    .word cursor_position
ptr_to_clear_screen: 		    .word clear_screen
ptr_to_backspace:				.word backspace
ptr_to_asterisk:				.word asterisk
ptr_to_home: 					.word home
ptr_num_1_string: 				.word num_1_string
ptr_num_2_string: 				.word num_2_string
ptr_saveCuror:					.word saveCuror
ptr_restoreCuror:				.word restoreCuror
ptr_ball_data_block				.word ball_data_block
ptr_test_esc_string: 			.word test_esc_string
ptr_bricks:						.word bricks
ptr_ran_state					.word ran_state
ptr_test_esc_string1			.word test_esc_string1
ptr_paddleDataBlock				.word paddleDataBlock


labGame:	; This is your main routine which is called from your C wrapper
	PUSH {lr}   		; Store lr to stack

	BL uart_init
	bl tiva_pushbtn_init
	BL uart_interrupt_init
	BL gpio_interrupt_init
  
	BL print_start_menu

	

	ldr r0, ptr_test_esc_string
	bl output_string_nw

	;Clear screen
	LDR r0, ptr_to_clear_screen ;clear the screen and moves cursor to 0,0
	BL output_string
	ldr r0, ptr_to_home
	bl output_string_nw

	LDR r0, ptr_to_gameOver
	BL output_string

	ldr r0, ptr_test_esc_string1
	bl output_string_nw

	ldr r0, ptr_to_home
	bl output_string_nw


	BL print_hui

	mov r0, #2
	bl print_all_bricks

	ldr r0, ptr_test_esc_string
	bl output_string_nw

	;start game
	bl Timer_init

	;Test print color


loop:
	LDR r0, ptr_paddleDataBlock	
	LDRB r1, [r0, #3]
	CMP r1, #4
	BEQ game_ended ;if game state = 4 that means e was pressed in game over menu end the game
	B loop 		   ; else loop again

game_ended:
	POP {lr}
	MOV pc, lr



Timer_Handler:

	; Your code for your Timer handler goes here.  It is not needed
	; for Lab #5, but will be used in Lab #6.  It is referenced here
	; because the interrupt enabled startup code has declared Timer_Handler.
	; This will allow you to not have to redownload startup code for
	; Lab #6.  Instead, you can use the same startup code as for Lab #5.
	; Remember to preserver registers r4-r11 by pushing then popping
	; them to & from the stack at the beginning & end of the handler.

	;Preserve registers
	PUSH {lr}
	PUSH {r4-r11}

	;Clear timer interrupt (1)->0th bit of 0x40030024
	MOV r0 ,#0x0024
	MOVT r0, #0x4003
	LDR r1, [r0]
	ORR r1, #1
	str r1,[r0]

	;update random sta
	ldr r0, ptr_ran_state
	ldr r0, [r0,#0]
	add r0, r0,#1
	ldr r1, ptr_ran_state
	str r0, [r1,#0]

	bl ball_movement



	POP {r4-r11}
	POP {lr}
	BX LR



Switch_Handler:

	; Your code for your UART handler goes here.
	; Remember to preserver registers r4-r11 by pushing then popping
	; them to & from the stack at the beginning & end of the handler
	PUSH {lr}
	PUSH {r4-r11}


	;clear interrupt register GPIOICR
	MOV r0, #0x541C
	MOVT r0, #0x4002
	LDR r1,[r0]
	ORR r1, r1,#16
	STR r1, [r0]



	LDR r0, ptr_paddleDataBlock	; if switch pressed check game state
	LDRB r1, [r0, #3]
	
	CMP r1, #3 ;if game state = 1 or 2 then pause
	BNE pause
	B exit_switch_handler ;exit handler after returning

	CMP r1, #3 ;if game state = 3 currently then unpause
	BEQ unpause
	B exit_switch_handler ;exit handler after returning


	 
exit_switch_handler:
	POP {r4-r11}
	POP {lr}
	BX lr       	; Return

UART0_Handler:

	PUSH {lr}
	; Remember to preserver registers r4-r11 by pushing then popping
	; them to & from the stack at the beginning & end of the handler
	PUSH {r4-r11}

	;Clear Interrupt: Set the bit 4 (RXIC) in the UART Interrupt Clear Register (UARTICR)
	;UART0 Base Address: 0x4000C000
	;UARTICR Offset: 0x044
	;UART0 Bit Position: Bit 4

	MOV r0, #0xC000
	MOVT r0, #0x4000
	LDR r2, [r0, #0x44]
	ORR r2, r2, #16		;bit 4 has 1
	STR r2, [r0, #0x44]	;clearing interrupt bit


	BL keystroke_access ;see game state and keystroke and do corresponding action

	B direction_end
direction_end:			;note: if the char is NONE of the above, the direction remains the same
	POP{r4-r11}
	POP {lr}
	BX lr

exit:
	MOV r0, r9
	BL output_string
	;move the counter for # of moves into the register that int2string uses as an argument
	;int2string on that register
paddle_move_right:
	;paddle movement illusion is created by writing a " - " character to the right of the paddle end
	;and erasing the left most " - " character
	PUSH {lr}
	ldr r2, ptr_paddleDataBlock		;r2 has a pointer to the data block
	LDRB r0, [r2]
	LDRB r1, [r2, #1]						;loading paddle coordinates into r0 and r1
	CMP r1, #18
	BGE paddle_move_right_end				;CHECK IF PADDLE END IS NOT AT THE RIGHT BORDER

	BL print_cursor_location
	MOV r0, #5					;move cursor to paddleEnd location +1 , gathered from data block
	BL movCursor_right

	MOV r0, #45					;- char =45
	BL output_character				;print the - character

	MOV r0, #5
	BL movCursor_left

	MOV r0, #127							; ascii delete = 127
	BL output_character						;delete the first - character

	ldr r2, ptr_paddleDataBlock		;r2 has a pointer to the data block
	LDRB r1, [r2, #1]
	ADD r1, r1, #1
	STRB r1, [r2, #1]					;paddleStart=paddleStart+1

paddle_move_right_end:
	POP{lr}
	MOV pc, lr

paddle_move_left:
	;paddle movement illusion is created by writing a " - " character to the left of the paddle
	;and erasing the right most " - " character
	PUSH {lr}
	ldr r2, ptr_paddleDataBlock		;loading datablock address into r2
	LDRB r0, [r2]
	LDRB r1, [r2, #1]						;loading the paddle coordinates into r0 and r1

	CMP r1, #2								;CHECK IF PADDLE START IS NOT AT THE LEFT BORDER
	BEQ paddle_move_left_end


	BL print_cursor_location				;move cursor to paddleStart location -1
	MOV r0, #1
	BL movCursor_left

	MOV r0, #45								;- char =45
	BL output_character						;print the - character

	MOV r0, #5						;move cursor to paddleEnd
	BL movCursor_right

	MOV r0, #127								;ascii delete= 127, ascii backspace=8
	BL output_character

	ldr r2, ptr_paddleDataBlock		;loading datablock address into r2
	LDRB r1, [r2, #1]
	SUB r1, r1, #1
	STRB r1, [r2, #1]							;paddleStart= paddleStart-1

paddle_move_left_end:
	POP{lr}
	MOV pc, lr
;print_all_bricks
;	Description:
;		Prints all bricks from 0-->27 to the teminal with randomly generated colors
;		while also storing brick info in memory
print_all_bricks:
	PUSH {lr}

	mov r3,r0
	mov r0,#0
	mov r1,#0
	ldr r2,ptr_bricks

pab_loop
	push {r0-r3}
	bl print_brick
	pop {r0-r3}

	add r0,r0,#1
	cmp r0,#7
	bne pab_loop
	add r1,r1,#1
	mov r0, #0
	cmp r1, r3
	bne pab_loop


	POP {lr}
	mov pc,lr
***************************HELER SUBROUTINES ****************************************
;print_brick
;	Description
;		Printes a randomly colored brick at the cursor location that
;		coorosponds to the brick coordinate location. Also stores the brick coordinateX
;		brick coordinateY, and randomly selected brick color at the corresponding brick
;		whos base pointer is r2.
;
;	inputs
;		r0- x brick coordinate location
;		r1- y brick coordinate location
;		r2 - pointer to start of bricks in memory
;
;
;		brickMemoryLocation = r2 + offset
;		offset = (r0 + 7(r1))*4
;		brickCursorStartX = 3(r0) + 2
;		brickCursorStartY = r1 + 3
print_brick:
	push {lr}
	PUSH {r4}



	;r3 = random number
	push {r0-r2}
	bl ran_4
	bl num2colorcode
	mov r3, r0
	pop {r0-r2}

	;calc pointer offset
	mov r4, #7
	MUL r4,r4,r1
	add r4, r4,r0
	MOV R5,#4
	MUL r4, r5,r4
	add r2,r4,r2

	;store brick info in memory
	;color
	STRB r3, [r2,#2]	;ADGUST

	;set brick to on
	mov r4, #1
	STRB r4, [r2,#3]


	;calculate cursor locations
	;r0 = 3(r0) + 2
	MOV r4, #3
	MUL r0, r0, r4
	ADD r0, r0, #2

	;r1 = r1 + 3
	add r1,r1,#3

	mov r4, r0
	mov r0,r1
	mov r1,r4

	;Store x position in memory
	STRB r0, [r2,#0]
	;Store y position in memory
	STRB r1, [r2,#1]

	;print color
	;Move color to r2
	mov r2, r3
	push {r0-r3}
	bl print_color
	pop {r0-r3}


	;incrament x
	add r1,r1,#1
	;print color
	push {r0-r3}
	bl print_color
	pop {r0-r3}
	;incrament x
	add r1,r1,#1
	;print color
	push {r0-r3}
	bl print_color
	pop {r0-r3}


	POP {r4}
	pop {lr}
	mov pc,lr

;Clear brick
;	-Description:
;		Clear the brick at the brick coordinate provided
;	-Inputs:
;		r0 - Brick x coordinate
;		r1 - Brick y coordinate
;		r2 - Bricks base pointer
clear_brick
	PUSH {lr}

	;Calculate brick location in memory
	;brickpointer = r0 + 7(r1) +r2
	mov r4, #7
	mul r4,r1,r1
	add r4, r4,r0
	add r4, r2,r4


	;set brick as not printed
	mov r5,#0
	STRB r5, [r4,#3]


	;calculate cursor location
	bl brick2cursor

	;go to cursor location
	PUSH {r0-r3}
	bl print_cursor_location
	POP {r0-r3}


	;move right by 3 spaces
	PUSH {r0-r3}
	MOV r0, #3
	bl movCursor_right
	POP {r0-r3}

	;Delete 3 times
	PUSH {r0-r3}
	mov r0, #127
	bl output_character
	POP {r0-r3}

	PUSH {r0-r3}
	mov r0, #127
	bl output_character
	POP {r0-r3}

	PUSH {r0-r3}
	mov r0, #127
	bl output_character
	POP {r0-r3}


	;cursor is now back to the start of the brick cursor position r0,r1
	;print 3 white(game background color) spaces
	PUSH {r0-r3}
	mov r2, #255
	bl print_color
	POP {r0-r3}

	add r1,r1,#1
	PUSH {r0-r3}
	mov r2, #255
	bl print_color
	POP {r0-r3}

	add r1,r1,#1
	PUSH {r0-r3}
	mov r2, #255
	bl print_color
	POP {r0-r3}


	POP {lr}
	mov pc,lr

;ran_
;	Description
;		Returns a random number in the inclusive interval [0,4]
;		4 can be easily changed to any number (to change the interval)
;		by changing the modulus modifier
ran_4:
	push {lr}

	;The seed

	ldr r0, ptr_ran_state
	ldr r0, [r0,#0]

	;seed = seed ^ (seed << 12)
	lsl r1, r0, #12
	EOR r0, r0,r1

	;seed = seed ^ seed >> 15
	lsr r1, r0, #15
	EOR r0, r0, r1

	;seed = (seed ^ seed << 3)%modulus
	lsl r1,r0,#3
	EOR r0,r0,r1
	mov r1, #5
	bl MOD

	ldr r1, ptr_ran_state
	str r0, [r1,#0]

	pop {lr}
	mov pc,lr
;print_color
;	-Printes the foreground color of a cursor location on the terminal
;	-code format: ESC[38;5;160m
;	-Inputs
;		-r0: cursorX
;		-r1: cursorY
;		-r2: color code
print_color:
	push {lr}
	push {r4-r5}
	mov r5,r2


	;go to particular cursor location
	bl print_cursor_location


	;change cursor color
	mov r0, #27
	bl output_character	;output ESC

	mov r0, #91
	bl output_character ;output '['

	;output 48 for foreground
	mov r0, #52
	bl output_character
	mov r0, #56
	bl output_character
	;output ;
	mov r0, #59
	bl output_character
	;output 5 for foreground
	mov r0, #53
	bl output_character
	;output ;
	mov r0, #59
	bl output_character
	;ouptut given code
	mov r0, r5
	ldr r1, ptr_num_1_string
	bl int2string_nn
	mov r1,r0
	ldr r0, ptr_num_1_string
	bl output_string_withlen_nw
	;output m
	mov r0, #109
	bl output_character

	;print a space
	mov r0, #32
	bl output_character

	;output null
	mov r0, #0
	bl output_character

	;change cursor bacground color back to black
	mov r0, #27
	bl output_character	;output ESC
	mov r0, #91
	bl output_character ;output '['
	;output 48 for foreground
	mov r0, #52
	bl output_character
	mov r0, #56
	bl output_character
	;output ;
	mov r0, #59
	bl output_character
	;output 5 for foreground
	mov r0, #53
	bl output_character
	;output ;
	mov r0, #59
	bl output_character
	;ouptut black code
	mov r0, #232
	ldr r1, ptr_num_1_string
	bl int2string_nn
	ldr r0, ptr_num_1_string
	mov r1, #3
	bl output_string_withlen_nw

	;output null
	mov r0, #0
	bl output_character

	pop {r4-r5}
	pop {lr}
	mov pc,lr


;brick2cursor
;	Description
;		- Translates the brick coordinate (with shape (4,7)) location  to its
;		  corresponding starting cursor (with shape (4,21)) location
;			brickCursorStartX = 3(r0) + 2
;			brickCursorStartY = r1 +3
;	Inputs
;		r0 - brick x coordinate
;		r1 - brick y coordinate
;	Outputs
;		r0- cursor x coordinate
;		r1 -cursor y ccoorinate
brick2cursor:
	PUSH {lr}

	PUSH {r4}
	;calculate cursor locations
	;r0 = 3(r0)  +  2
	MOV r4, #3
	MUL r0, r0, r4
	ADD r0, r0, #2


	;r1 = r1 + 3
	add r1,r1,#3

	;cursor plane is reflected on the diagnol line eg: x->y y->x
	mov r4, r0
	mov r0,r1
	mov r1,r4

	POP {r4}
	POP {LR}
	MOV pc,lr
;cursor2brick
;	Description
;		- Translates the starting cursor coordinate (with shape (4,21)) location  to its
;		  corresponding  brick (with shape (4,7)) location
;			brickX = (r0 -2)/3
;			brickY = r1 - 3
;
;	Outputs
;		r0 - brick x coordinate
;		r1 - brick y coordinate
;	Inputs
;		r0- cursor x coordinate
;		r1 -cursor y ccoorinate
cursor2brick:
	PUSH {lr}
	POP {lr}
	mov pc,lr
;num2colorcode
;	Description:
;		Stores the number stored in r0 in the interval [0,4] to the color codes
;		{red,green,purple,blue,yellow} respectively in r0
num2colorcode:
	PUSH {lr}

	;check red
	cmp r0, #0
	bne n2cc_not_0
	mov r0, #1
	b n2cc_end
n2cc_not_0
	;check ggreen
	cmp r0, #1
	bne n2cc_not_1
	mov r0, #2
	b n2cc_end
n2cc_not_1
	;check purple
	cmp r0, #2
	bne n2cc_not_2
	mov r0, #5
	b n2cc_end
n2cc_not_2

	;check blue
	cmp r0, #3
	bne n2cc_not_3
	mov r0, #4
	b n2cc_end
n2cc_not_3

	;check yellow
	cmp r0, #4
	bne n2cc_not_4
	mov r0, #3
	b n2cc_end
n2cc_not_4

n2cc_end
	pop {LR}
	mov pc,lr



;Print_borders
print_hui:
    PUSH{lr}

	;move cursor to middle of the first row
	MOV r0, #0 ; x = 6 (or 7 depending on indexing)
	MOV r1, #6 ; y = 0
	BL print_cursor_location
	
	LDR r0, ptr_to_score_str ;print "Score: " 
	BL output_string

	;int2string on score
	LDR r0, ptr_to_score_val
	BL int2string
	;print output of int2string
	;LDR r0, whatever the output of int2string is in
	;BL output_string

	;move cursor to start of second row to start printing the board
	;MOV r0, #1 ;x value
	;MOV r1, #0 ;y value


    LDR r0, ptr_to_top_bottom_borders ;move top and bottom border to the register used as an argument in output_string
    BL output_string ; branch to output_string

    MOV r1, #0 ;move 0 into r1 (or any free register) to use as a counter

    LDR r0, ptr_to_side_borders ; move side borders to the register used as an argument in output_string (could do it in the loop but this is a bit faster i think)
    BL side_loop ; branch to loop that will print out the sides of the board

side_loop:
    CMP r1, #16  
    BEQ bottom ;if all the sides are done we just have to print the bottom border

    PUSH {r0-r4}
    LDR r0, ptr_to_side_borders
    BL output_string ;r0 should already hold the side borders
    POP {r0-r4}
    ADD r1, r1, #1 ;increment counter
    B side_loop ;Loop again to check if all side borders have been printed

bottom:
    LDR r0, ptr_to_top_bottom_borders ;move top and bottom border to the register used as an argument in output_string
    BL output_string ; branch to output_string

insert_paddle:
	LDR r0, ptr_paddleDataBlock ;store paddle location
	MOV r1, #17
	STRB r1, [r0, #0]
	MOV r1, #10
	STRB r1, [r0, #1]

	;put paddle into its expected position 
	MOV r0, #17 ;xvalue
	MOV r1, #10 ;yvalue (if top left of terminal = 0,0)
	BL print_cursor_location

	LDR r0, ptr_to_paddle ;starting inital position 
	BL output_string


insert_asterisk:
	MOV r0, #10 ;yvalue
	MOV r1, #12 ;xvalue 
	BL print_cursor_location

	MOV r0, #42
	BL output_character
	;Move back (update: not needed since output_character should overwrite the whitespace
	;mov r0, #8
	;bl output_character

	;Check borders
	;bl border_check

	;inistialize ball location
	LDR r0, ptr_ball_data_block
	MOV r1, #10
	STRB r1, [r0, #0]
	MOV r1, #12
	STRB r1, [r0, #1]
	MOV r2, #1
	STRB r2, [r0, #2]
	MOV r2, #0
	STRB r2, [r0, #3]



   	POP {lr}
	MOV pc, lr



ball_movement:
	PUSH{lr} ; start 
	;get x and y position and direction for x and y add each direction to its corresponding position (ie xposition + xdirection)

	LDR r2, ptr_ball_data_block 
	LDRSB r0,[r2, #0] ; X location
	LDRSB r1, [r2, #1] ; Y location
	add r1,r1,#1
	BL print_cursor_location ;move cursor to current asterisk

	MOV r0, #127 ;delete to get rid of the old asterisk
	BL output_character

	LDR r2, ptr_ball_data_block ;load the data block again incase register r2 was changed in one of the past branches
	LDRSB r0,[r2, #0] ; get X location again because the branches might have changed register value
	LDRSB r1,[r2, #2] ; X direction (min, max = -2, 2)
	ADD r0, r1, r0
	STRB r0,[r2, #0] ; store the new x location into the 1st byte of the block

	LDRSB r0,[r2, #1] ; Y location
	LDRSB r1,[r2, #3] ; Y direction (min, max = -2, 2)
	ADD r0, r1, r0
	STRB r0,[r2, #1] ; store the new y location into the 2nd byte of the block


	BL ball_border_check
	BL print_ball

	POP {lr}
	MOV pc, lr
ball_border_check:
	PUSH {lr}

	LDR r0, ptr_ball_data_block ;load the data block again incase register r2 was changed in one of the past branches
	LDRSB r1,[r0, #0] ; get new X location again because the branches might have changed register value
	
	CMP r1, #3 ;compare new x location with row right under top border
	BLT top ;if it is less than this value this means the border is hit or passed 
	
	;BOTTOM BORDER WILL BE CHECKED BY PADDLE CHECK
	
	LDRSB r1, [r0, #1] ;compare new y coordinate with both 1 and 21 for left and right borders
	
	CMP r1, #1
	BLT left
	
	CMP r1, #21
	BGT right

	B exit1
	

top:
	MOV r1, #3 ;in this case we want to set the x location to 2 which is the highest the ball should be at
	STRB r1,[r0, #0]
	
	LDRSB r2, [r0, #2] ;get direction bit to negate it
	MOV r1, #-1 ;get negative one in a register
	MUL  r2, r2, r1 ;multiply direction bit with -1 to negate it
	STRB r2, [r0,#2] 
	
	LDRSB r1, [r0, #1] ;compare new y coordinate with both 1 and 21 for left and right borders (edgcase if we were at a corner and we went over both a side and the top)
	
	CMP r1, #0
	BLE left
	
	CMP r1, #21
	BGT right
	
	B exit1 ;if it is not at a top corner then exit this subroutine


left:
	LDR r0, ptr_ball_data_block ;load the data block again incase register r2 was changed in one of the past branches
	LDRSB r1,[r0, #1]
	MOV r1, #2 ;in this case we want to set the y location to 1 which is the leftmost location the ball should be at
	STRB r1,[r0, #1]
	
	LDRSB r2, [r0, #3] ;get direction bit to negate it
	MOV r1, #-1 ;get negative one in a register
	MUL  r2, r2, r1 ;multiply direction bit with -1 to negate it
	STRB r2, [r0,#3] 
	
	;no additional checks since top bottom was checked first and bottom will be done by paddle check
	B exit1

right:

	MOV r1, #21 ;in this case we want to set the y location to 21 which is the rightmost location the ball should be at	
	STRB r1,[r0, #1]
	
	LDRSB r2, [r0, #3] ;get direction bit to negate it
	MOV r1, #-1 ;get negative one in a register
	MUL  r2, r2, r1 ;multiply direction bit with -1 to negate it
	STRB r2, [r0,#3] 
	
	;no additional checks since top bottom was checked first and bottom will be done by paddle check
	B exit1

exit1:
	POP {lr}
	MOV pc, lr


print_ball:
	PUSH {lr}
	
	LDR r2, ptr_ball_data_block 
	LDRSB r0,[r2, #0] ; Final X location after intial update and border checks
	LDRSB r1, [r2, #1] ; Final Y location after intial update and border checks
	BL print_cursor_location ;move cursor to where asterisk should be
	
	MOV r0, #42
	BL output_character
	
	POP {lr}
	MOV pc, lr


pause:
	; print pause
	; turn led blue
	PUSH {lr}

	;disable timer
	MOV r0 ,#0x000C
	MOVT r0, #0x4003
	LDR r1, [r0]
	ORR r1, #0 ;to disable timer
	STR r1,[r0]

	;set game state to paused
	LDR r0, ptr_paddleDataBlock	
	MOV r1, #3
	STRB r1, [r0, #3]

	;move cursor
	MOV r0, #8 ;yvalue 
	MOV r1, #12 ;xvalue 
	BL print_cursor_location

	;print "PAUSE" to center of screen
	MOV r0, ptr_to_pause
	BL output_string_nw

	;LED = blue 0x40025000
	MOV r1, #0x5000
	MOVT r1, #0x4002
	MOV r0, #0x04 ; blue
	STRB r0, [r1]

	POP {lr}
	MOV pc, lr


unpause:
	PUSH {lr}

	;set game state to unpaused they should be back in game so set to 1
	LDR r0, ptr_paddleDataBlock	
	MOV r1, #1
	STRB r1, [r0, #3]

	;move cursor
	MOV r0, #8 ;yvalue 
	MOV r1, #12 ;xvalue 
	BL print_cursor_location

	;print "     " to center of screen to get rid of the "PAUSE" 
	MOV r0, ptr_to_pause_clear
	BL output_string_nw

	;move ball back to its location (in case "Pause" string was overwriting the ball)
	LDR r2, ptr_ball_data_block
	LDRB r0, [r2, #0]
	LDRB r1, [r2, #1]
	BL print_cursor_location
	

	;enable timer
	MOV r0 ,#0x000C
	MOVT r0, #0x4003
	LDR r1, [r0]
	ORR r1, #0 ;to disable timer
	STR r1,[r0]
	
	POP {lr}
	MOV pc, lr
	;we want to restore the location of the ball we also want to restore the old color of the light (if ball had hit a red brick before pause it should be red again after pause
	; we also need to know how to stop the timer_handler from working during pause otherwise ball will keep moving 
	; we also want to disable keystrokes otherwise player can move the paddle during pause


keystroke_access:
	PUSH{lr}

	BL simple_read_character		;retrieving the character pressed r0
	MOV r3, r0 ;store char read in r3

	LDR r0, ptr_paddleDataBlock	
	LDRB r1, [r0, #3]
	;check game state 0 = start 1 = in game 2 = game over menu 3 = paused
	CMP r1, #0
	BL check_space
	CMP r1, #1
	BL check_a_d
	CMP r1, #2
	BL check_end

	BL keystroke_made ;if game state = 3 user tried to press keyboard during pause do nothing

check_a_d:
		CMP r3, #100		;if char== 'd'
		BNE check_a_char
		BL paddle_move_right	;MOVE PADDLE RIGHT
		B keystroke_made
	check_a_char:
		CMP r3, #97		;if char== 'a'
		BNE keystroke_made ;if not a or d during the game then its invalid input do nothing
		BL paddle_move_left		;MOVE PADDLE LEFT 
		B keystroke_made

check_space:
	CMP r3, #32
	BNE keystroke_made

	;set game state to in game
	LDR r0, ptr_paddleDataBlock	
	MOV r1, #1 
	STRB r1, [r0, #3]

	;print hui and bricks
	BL print_hui 	;CALL START GAME SUBROUTINE
	BL print_all_bricks
	B keystroke_made

check_end:
	CMP r3, #101		;if char != 'e'
	BNE check_r_char

	;else e was pressed
	LDR r0, ptr_paddleDataBlock	
	LDRB r1, [r0, #3]
	MOV r1, #4 ;user pressed e, set to 4 for the loop to catch and end the game
	STRB r1, [r0, #3]
	B keystroke_made
	
	check_r_char:
		CMP r0, #114	;if char != 'r' e or r not pressed in game over menu iinvalid input do nothing
		BNE keystroke_made

		BL print_start_menu ;else r was pressed and we restart the game
		B keystroke_made
keystroke_made:
	POP {lr}
	MOV pc, lr

game_over:	
	PUSH {lr}
	
	;set the bit = to 2 to make sure they cannot press a or d or spacebar
	LDR r0, ptr_paddleDataBlock	
	LDRB r1, [r0, #3]
	MOV r1, #2
	STRB r1, [r0, #3]
	
	;Clear screen
	LDR r0, ptr_to_clear_screen ;clear the screen and moves cursor to 0,0
	BL output_string
	ldr r0, ptr_to_home
	bl output_string_nw

	;move cursor to middle of screen
	MOV r0, #10 ;xvalue
	MOV r1, #8 ;yvalue 8 so the space char in "GAME OVER" is in the center of the screen 
	BL print_cursor_location
			
	
	;		"GAME OVER"
	; 		"PRESS [e] TO END THE GAME"
	;  		"PRESS [r] TO RESTART THE GAME"
	LDR ptr_to_gameOver
	BL output_string
	LDR ptr_to_retart_letter
	BL output_string
	LDR ptr_to_exit_letter
	BL output_string
	
	
	POP {lr}
	MOV pc, lr

	
new_life:
	PUSH{lr}

	;check amount of lives left, if 0 branch to game over
	LDR r0, ptr_to_game_data_block	
	LDRB r1, [r0, #0] ;lives are in bit 0
	CMP r1, #0 ;if lives are equal to 0
	BEQ game_over ;branch to game_over print game over menu 
	
	;else
	SUB r1, r1, #1 ;subtract lives by 1 and store
	STRB r1, [r0, #0] 

	LDR r0, ptr_ball_data_block ;update paddle location to start location
	MOV r1, #17
	STRB r1, [r0, #0]
	MOV r1, #10
	STRB r1, [r0, #1]

	;put paddle into its expected position 
	MOV r0, #17 ;xvalue (18 for bottom row)
	MOV r1, #10 ;yvalue (if top left of terminal = 0,0)
	BL print_cursor_location

	LDR r0, ptr_to_paddle ;starting inital position 
	BL output_string

	MOV r0, #10 ;yvalue
	MOV r1, #12 ;xvalue 
	BL print_cursor_location

	MOV r0, #42
	BL output_character
	;Move back (update: not needed since output_character should overwrite the whitespace
	;mov r0, #8
	;bl output_character

	;inistialize ball location
	LDR r0, ptr_ball_data_block
	MOV r1, #10
	STRB r1, [r0, #0]
	MOV r1, #12
	STRB r1, [r0, #1]
	MOV r2, #1
	STRB r2, [r0, #2]
	MOV r2, #0
	STRB r2, [r0, #3]
	
	
	POP {lr}
	MOV pc, lr

print_start_menu:
	PUSH {lr}

	;set game state to start game
	LDR r0, ptr_paddleDataBlock	
	MOV r1, #0 ;game state set to start game
	STRB r1, [r0, #3]

	;Clear screen first
	LDR r0, ptr_to_clear_screen ;clear the screen and moves cursor to 0,0
	BL output_string
	ldr r0, ptr_to_home
	bl output_string_nw
	
	;move cursor to middle of screen
	MOV r0, #10 ;xvalue
	MOV r1, #6 ;yvalue 6 so the "u" char in "Breakout Game" is in the center of the screen 
	BL print_cursor_location
	#output "Breakout Game"
	LDR r0, ptr_to_start_prompt 
	BL output_string

	;move cursor to one row down middle of screen
	MOV r0, #11 ;xvalue
	MOV r1, #1 ;yvalue 
	BL print_cursor_location
	LDR r0, ptr_to_row_instructions_prompt
	BL output_string

	MOV r0, #12 ;xvalue
	MOV r1, #5 ;yvalue (+ 4 spaces for a tab)
	BL print_cursor_location
	LDR r0, ptr_to_rows_prompt 
	BL output_string

	MOV r0, #13 ;xvalue
	MOV r1, #1 ;yvalue 
	BL print_cursor_location
	LDR r0, ptr_to_game_instructions_prompt
	BL output_string
	

	MOV r0, #14 ;xvalue
	MOV r1, #5 ;yvalue (+ 4 spaces for a tab)
	BL print_cursor_location
	LDR r0, ptr_to_instructions_prompt
	BL output_string


	MOV r0, #15 ;xvalue
	MOV r1, #1 ;yvalue (+ 4 spaces for a tab)
	BL print_cursor_location
	LDR r0, ptr_to_space_prompt
	BL output_string

	POP {lr}
	MOV pc, lr

	.end
