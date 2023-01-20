.include "common.s"

.data
.align 2

KEYBOARD_CONTROL: .word 0xFFFF0000
KEYBOARD_DATA: .word 0xFFFF0004
DISPLAY_CONTROL:    .word 0xFFFF0008
DISPLAY_DATA:       .word 0xFFFF000C
TIME: .word 0xFFFF0018
TIMECMP: .word 0xFFFF0020	
INTERRUPT_ERROR:	.asciz "Error: Unhandled interrupt with exception code: "
INSTRUCTION_ERROR:	.asciz "\n   Originating from the instruction at address: "

levelcheck: .word 0
startflag: .word 0
updatescreen: .word 0

timebudget1: .asciz "120"
bonustime1: .asciz "8"

timebudget2: .asciz "030"
bonustime2: .asciz "5"

timebudget3: .asciz "015"
bonustime3: .asciz "3"

curtime: .asciz "000"
curbonus: .asciz "0"
score: .asciz "000"

Brick:      .asciz "#"
Head: 		.asciz "@"
body:		.asciz "*"
headposx: .word 9
headposy: .word 5
body1posx: .word 8
body1posy: .word 5
body2posx: .word 7
body2posy: .word 5
body3posx: .word 6
body3posy: .word 5
pressedkey: .ascii "d"
apple: .asciz "a"
appleposx: .word 0
appleposy: .word 0
SelectLevel: .asciz "Please enter 1, 2 or 3 to choose the level and start the game"
clear: .asciz "                                                             "
clearmatrixline: .asciz"                   "
seconds: .asciz "seconds"
points: .asciz "points"

.text


#---------------------------------------------------------------------------------------------
# snakeGame
#
# Subroutine description: This subroutine activates the conditions to enable interrupts and prints the level select message
# 
#   Args:
#  		None
#
# Register Usage
#      	t0: stores the address for handler to put in utvec
#      	a0: address of the SelectLevel string
#      	a1: row to print on
#	a2: the column to start printing on
#
# Return Values:
#	None
#---------------------------------------------------------------------------------------------
snakeGame:
	# stack
	addi sp, sp, -4
	sw ra, 0(sp)
	
	# enabling bits for interrupts
	la t0, handler
	csrw t0, 5
	csrwi 0, 1
	csrwi 4, 0x00000110
	
	# printing selectlevel string
	la a0, SelectLevel
	li a1, 0
	li a2, 0
	jal printStr

#---------------------------------------------------------------------------------------------
# game
#
# Subroutine description: This subroutine enables keyboard interrupts and handles which level will be executed
# 
#   Args:
#  		None
#
# Register Usage
#      	t0:
#		-stores the address for KEYBOARD_CONTROL global var
#		-stores the address for levelcheck global var
#	t1: 	
#		- stores 1, to enable user level interrupts
#		- stores 1, to enable keyboard interrupts
#		- stores 1, 2, 3 to check which level needs to be executed respectively.
# Return Values:
#	None
#---------------------------------------------------------------------------------------------
game:
	# enables user level interupts
	li t1, 1
	csrw t1, 0

	# enables keyboard interrupts
	lw t0, KEYBOARD_CONTROL
	li t1, 2
	sw t1, 0(t0)

	# loads the value from global variable level check
	# if the value is 1, 2 or 3 execute the respective levels else loop
	lw t0, levelcheck
	li t1, 1
	beq t1, t0, lvl1main
	li t1, 2
	beq t1, t0, lvl2main
	li t1, 3
	beq t1, t0, lvl3main
	j game

#---------------------------------------------------------------------------------------------
# lvl1main
#
# Subroutine description: This subroutine sets up the variables needed for level 1
# 
#   Args:
#  		None
#
# Register Usage
#	a0: stores the address for clear global var
#      	a1: row to print on
#	a2: the column to start printing on
#      	t0: stores the address for curtime global var
#	t1: stores the address for timebudget1 global var
#	t2: stores the value from timebudget to put it in curtime
# Return Values:
#	None
#---------------------------------------------------------------------------------------------
lvl1main:
	# clearing the main screen to print the new level screen
	la a0, clear
	li a1, 0
	li a2, 0
	jal printStr
	jal printAllWalls
	
	# storing the timeconstraint of level into curtime
	la t0, curtime
	la t1, timebudget1
	lb t2, 0(t1)
	sb t2, 0(t0)
	lb t2, 1(t1)
	sb t2, 1(t0)
	lb t2, 2(t1)
	sb t2, 2(t0)

	j timerstart
	
#---------------------------------------------------------------------------------------------
# lvl2main
#
# Subroutine description: This subroutine sets up the variables needed for level 2
# 
#   Args:
#  		None
#
# Register Usage
#	a0: stores the address for clear global var
#      	a1: row to print on
#	a2: the column to start printing on
#      	t0: stores the address for curtime global var
#	t1: stores the address for timebudget2 global var
#	t2: stores the value from timebudget to put it in curtime
# Return Values:
#	None
#---------------------------------------------------------------------------------------------
lvl2main:
	# clearing the main screen to print the new level screen
	la a0, clear
	li a1, 0
	li a2, 0
	jal printStr
	jal printAllWalls

	# storing the timeconstraint of level into curtime
	la t0, curtime
	la t1, timebudget2
	lb t2, 0(t1)
	sb t2, 0(t0)
	lb t2, 1(t1)
	sb t2, 1(t0)
	lb t2, 2(t1)
	sb t2, 2(t0)

	j timerstart

#---------------------------------------------------------------------------------------------
# lvl3main
#
# Subroutine description: This subroutine sets up the variables needed for level 3
# 
#   Args:
#  		None
#
# Register Usage
#	a0: stores the address for clear global var
#      	a1: row to print on
#	a2: the column to start printing on
#      	t0: stores the address for curtime global var
#	t1: stores the address for timebudget3 global var
#	t2: stores the value from timebudget to put it in curtime
# Return Values:
#	None
#---------------------------------------------------------------------------------------------
lvl3main:
	# clearing the main screen to print the new level screen
	la a0, clear
	li a1, 0
	li a2, 0
	jal printStr
	jal printAllWalls
	
	# storing the timeconstraint of level into curtime
	la t0, curtime
	la t1, timebudget3
	lb t2, 0(t1)
	sb t2, 0(t0)
	lb t2, 1(t1)
	sb t2, 1(t0)
	lb t2, 2(t1)
	sb t2, 2(t0)

	j timerstart

#---------------------------------------------------------------------------------------------
# timerstart
#
# Subroutine description: This subroutine prints the time, score and the first apple
# 
#   Args:
#  		None
#
# Register Usage
#	a0: 
#		-stores the address for different global variables to print stuff
#		-stores the returned random number from random function
#      	a1: row to print on
#	a2: the column to start printing on
#      	t0: stores the address for TIME global var
#	t1: stores the address for TIMECMP global var
#	t2: stores the value from timebudget to put it in curtime
# Return Values:
#	None
#---------------------------------------------------------------------------------------------
timerstart:
	# initiates the first timer interrupt
	lw t0, TIME
	lw t0, 0(t0)
	addi t0, t0, 1000
	lw t1, TIMECMP
	sw t0, 0(t1)
	
	# prints the string "seconds"
	la a0, seconds
	li a1, 1
	li a2, 28
	jal printStr
	
	# prints the string that contains our score	
	la a0, score
	li a1, 0
	li a2, 24
	jal printStr
	
	# print the string "points"
	la a0, points
	li a1, 0
	li a2, 28
	jal printStr
	
	#calculating the row position of the first apple
	jal random
	mv a1, a0
	addi a1, a1, 1
	la t0, appleposy
	sw a1, 0(t0)
	
	# calculating the column position of the first apple
	jal random
	mv a2, a0
	addi a2, a2, 1
	la t0, appleposx
	sw a2, 0(t0)
	
	# printing the first apple
	lbu a0, apple
	jal printChar

	j printscreen

#---------------------------------------------------------------------------------------------
# gamePlay
#
# Subroutine description: This subroutine reenables keyboard interrupts, and updates screen 
#			  if the updatescreen flag is 1. It also checks if the snake ate the
#			  apple or if the snake ran into a wall then end the game.
# 
#   Args:
#  		None
#
# Register Usage
#	a0: stores the value of the globalvar apple
#      	a1: row position of the apple
#	a2: column position of the appple
#      	t0:
#		-stores the value for KEYBOARD_CONTROL global var
#		-stores the value for updatescreen global var
#	t1:
#		- stores 1, to enable user level interrupts
#		- stores 1, to enable keyboard interrupts
# Return Values:
#	None
#---------------------------------------------------------------------------------------------
gamePlay:
	# enables user level interupts
	li t1, 1
	csrw t1, 0
	
	# enables keyboard interrupts
	lw t0, KEYBOARD_CONTROL
	li t1, 2
	sw t1, 0(t0)
	
	# checks if the update screen flag is 1 then update the screen else continue
	lw t0, updatescreen
	bne t0, zero, printscreen
	
	# check if the apple is eaten or not
	lw a1, appleposy
	lw a2, appleposx
	lbu a0, apple
	jal printChar
	jal checkEating
	
	#check if the snake ran into the wall or not
	jal wallCol

	j gamePlay

#---------------------------------------------------------------------------------------------
# printscreen
#
# Subroutine description: updates to be made to the screen
# 
#   Args:
#  		None
#
# Register Usage
#	a0: stores the addresses of different global variable strings to print
#      	a1: row position of the string
#	a2: column position of the string
#      	t0: stores the value of the pressedkey gloabl var
#	t1: stores the hex values of w, a, s and d respectively to check if either of those have been pressed or not
# Return Values:
#	None
#---------------------------------------------------------------------------------------------
printscreen:
	#prints the time remaining
	la a0, curtime
	li a1, 1
	li a2, 24
	jal printStr

	# clears the inside of the matrix[from line 427 to line 462]
	la a0, clearmatrixline
	li a1, 1
	li a2, 1
	jal printStr
	la a0, clearmatrixline
	li a1, 2
	li a2, 1
	jal printStr
	la a0, clearmatrixline
	li a1, 3
	li a2, 1
	jal printStr
	la a0, clearmatrixline
	li a1, 4
	li a2, 1
	jal printStr
	la a0, clearmatrixline
	li a1, 5
	li a2, 1
	jal printStr
	la a0, clearmatrixline
	li a1, 6
	li a2, 1
	jal printStr
	la a0, clearmatrixline
	li a1, 7
	li a2, 1
	jal printStr
	la a0, clearmatrixline
	li a1, 8
	li a2, 1
	jal printStr
	la a0, clearmatrixline
	li a1, 9
	li a2, 1
	jal printStr

	# loads the last pressed key
	lb t0, pressedkey
	
	# checks if the pressed key is among w, a, s or d
	li t1, 0x77
	beq t0, t1, moveWmain
	li t1, 0x73
	beq t0, t1, moveSmain
	li t1, 0x64
	beq t0, t1, moveDmain
	li t1, 0x61
	beq t0, t1, moveAmain

continue:	#continuation of the printscreen if the branches are not taken
	
	# prints the snake of the snake [480-499]
	la a0, Head
	lbu a0, 0(a0)
	lw a1, headposy
	lw a2, headposx
	jal printChar
	la a0, body
	lbu a0, 0(a0)
	lw a1, body1posy
	lw a2, body1posx
	jal printChar
	la a0, body
	lbu a0, 0(a0)
	lw a1, body2posy
	lw a2, body2posx
	jal printChar
	la a0, body
	lbu a0, 0(a0)
	lw a1, body3posy
	lw a2, body3posx
	jal printChar

	# sets the updatescreen flg back to 0 after the screen hass been updated
	la t0, updatescreen
	li t2, 0
	sw t2, 0(t0)
	
	# checks if the timer is 0 then end the game
	la t0, curtime
	lb t1, 0(t0)
	add t2, zero, t1
	lb t1, 1(t0)
	add t2, t2, t1
	lb t1, 2(t0)
	add t2, t2, t1
	li t3, 0x90
	beq t2, t3, gameEnd
	j gamePlay

moveWmain: # updates the body position of the snake if w is pressed

	# stores the coordinates of the second "*" in the position of third "*"
	lw t1, body2posx
	lw t2, body2posy
	la t3, body3posx
	la t4, body3posy
	sw t1, 0(t3)
	sw t2, 0(t4)

	# stores the coordinates of the first "*" in the position of second "*"
	lw t1, body1posx
	lw t2, body1posy
	la t3, body2posx
	la t4, body2posy
	sw t1, 0(t3)
	sw t2, 0(t4)

	# stores the coordinates of the head in the position of first "*"
	lw t1, headposx
	lw t2, headposy
	la t3, body1posx
	la t4, body1posy
	sw t1, 0(t3)
	sw t2, 0(t4)
	
	# decreases the y coordinate of the head to move it upwards
	la t1, headposy
	lw t2, 0(t1)
	addi t2, t2, -1
	sw t2, 0(t1)

	j continue

moveSmain: # updates the body position of the snake if s is pressed

	# stores the coordinates of the second "*" in the position of third "*"
	lw t1, body2posx
	lw t2, body2posy
	la t3, body3posx
	la t4, body3posy
	sw t1, 0(t3)
	sw t2, 0(t4)

	# stores the coordinates of the first "*" in the position of second "*"
	lw t1, body1posx
	lw t2, body1posy
	la t3, body2posx
	la t4, body2posy
	sw t1, 0(t3)
	sw t2, 0(t4)

	# stores the coordinates of the head in the position of first "*"
	lw t1, headposx
	lw t2, headposy
	la t3, body1posx
	la t4, body1posy
	sw t1, 0(t3)
	sw t2, 0(t4)

	# increases the y coordinate of the head to move it dwonwards
	la t1, headposy
	lw t2, 0(t1)
	addi t2, t2, 1
	sw t2, 0(t1)

	j continue

moveDmain: # updates the body position of the snake if d is pressed

	# stores the coordinates of the second "*" in the position of third "*"
	lw t1, body2posx
	lw t2, body2posy
	la t3, body3posx
	la t4, body3posy
	sw t1, 0(t3)
	sw t2, 0(t4)

	# stores the coordinates of the first "*" in the position of second "*"
	lw t1, body1posx
	lw t2, body1posy
	la t3, body2posx
	la t4, body2posy
	sw t1, 0(t3)
	sw t2, 0(t4)

	# stores the coordinates of the head in the position of first "*"
	lw t1, headposx
	lw t2, headposy
	la t3, body1posx
	la t4, body1posy
	sw t1, 0(t3)
	sw t2, 0(t4)

	# increases the x coordinate of the head to move it rightwards
	la t1, headposx
	lw t2, 0(t1)
	addi t2, t2, 1
	sw t2, 0(t1)

	j continue

moveAmain: # updates the body position of the snake if a is pressed

	# stores the coordinates of the second "*" in the position of third "*"
	lw t1, body2posx
	lw t2, body2posy
	la t3, body3posx
	la t4, body3posy
	sw t1, 0(t3)
	sw t2, 0(t4)

	# stores the coordinates of the first "*" in the position of second "*"
	lw t1, body1posx
	lw t2, body1posy
	la t3, body2posx
	la t4, body2posy
	sw t1, 0(t3)
	sw t2, 0(t4)

	# stores the coordinates of the head in the position of first "*"
	lw t1, headposx
	lw t2, headposy
	la t3, body1posx
	la t4, body1posy
	sw t1, 0(t3)
	sw t2, 0(t4)

	# decreases the x coordinate of the head to move it leftwards
	la t1, headposx
	lw t2, 0(t1)
	addi t2, t2, -1
	sw t2, 0(t1)

	j continue

gameEnd:
	# restoring registers from stack
	lw ra, 0(sp)
	addi sp, sp, 4

	ret

#---------------------------------------------------------------------------------------------
# random
#
# Subroutine description: calculates the random values for the co ordinates of apples
# 
#   Args:
#		None
#
# Register Usage
#      	t0: stores the value of the XiVar gloabl var
#	t1: stores the value of the aVar global var
#	t2: stores the value of the cVar global var
#	t3: stores the value of the mVar global var
# Return Values:
#	a0: pseudo random number between 0 and 8
#---------------------------------------------------------------------------------------------
random:
	# loading values into registers
	lw t0, XiVar
	lw t1, aVar
	lw t2, cVar
	lw t3, mVar
	
	#Xi = ((a*(X(i-1)))+c)%m
	mul t0, t0, t1
	add t0, t0, t2
	rem t0, t0, t3

	#storing the value of Xi in Xi var
	la t4, XiVar
	sw t0, 0(t4)
	
	#returning a0: Xi
	mv a0, t0
	ret

checkEating: # checks in the snake ate the apple or not

	# stack
	addi sp, sp, -4
	sw ra, 0(sp)
	
	#loading the position of head
	lw t0, headposx
	lw t1, headposy
	
	# loading the position of apple
	lw t2, appleposx
	lw t3, appleposy
	
	# if the position of apples and head is the same
	bne t0, t2, EatingEnd
	bne t1, t3, EatingEnd
	
	# print the head over the apple
	li a0, 0x40
	mv a1, t3
	mv a2, t2
	jal printChar

increaseScore:	#increases the score by 1
    la t0, score
    addi t0, t0, 2
increaseScoreLoop:
    lbu t1, 0(t0)
    addi t1, t1, 1
    li t3, 0x3A
    blt t1, t3, scoreIncreased
    li t3, 0x30
    sb t3, 0(t0)
    addi t0, t0, -1
    j increaseScoreLoop

scoreIncreased:	#stores the increased score val
    sb t1, 0(t0)

bonusadd:	# adds the bonus time to curtime
	la t0, curbonus
    lbu t0, 0(t0)
    li t1, 0x30
    sub t0, t0, t1
    la t3, curtime
    addi t3, t3, 2
    li t4, 0 # remainder
bonusloop:
    lbu t1, 0(t3)
    add t1, t1, t0
    add t1, t1, t4
    li t2, 0x3A
    blt t1, t2, donebonus
    li t2, 0x30
    sub t1, t1, t2
    li t2, 10
    remu t5, t1, t2
    divu t4, t1, t2
    li t0, 0
    addi t5, t5, 0x30
    sb t5, 0(t3)
    addi t3, t3, -1
    j bonusloop
    
donebonus:
    sb t1, 0(t3)
    j eatingcont

eatingcont: # continue the eating loop stores all the increased values

	# prints new score
	la a0, score
	li a1, 0
	li a2, 24
	jal printStr

	#prints new time
	la a0, curtime
	li a1, 1
	li a2, 24
	jal printStr

	# prints new apple
	jal random
	mv a1, a0
	addi a1, a1, 1
	la t0, appleposy
	sw a1, 0(t0)
	jal random
	mv a2, a0
	addi a2, a2, 1
	la t0, appleposx
	sw a2, 0(t0)
	lbu a0, apple
	jal printChar


EatingEnd:
	#restoring the registers from the stack
	lw ra, 0(sp)
	addi sp, sp, 4
	ret

wallCol: # checks if the snake head collides with the wall or not
	
	# loads snake head position
	lw t0, headposy
	lw t1, headposx
	
	# checks if the snake head is at the walls then end the game
	li t2, 0
	li t3, 10
	ble t0, t2, gameEnd
	bge t0, t3, gameEnd
	li t2, 0
	li t3, 20
	ble t1, t2, gameEnd
	bge t1, t3, gameEnd
	ret

handler:
    csrrwi zero, 0, 0
    csrrw t0, 0x40, t0			# t0 <-> uscratch
    sw t1, -24(t0)			# saving t1 in the kernel stack
    addi t1, t0, -24			# bringing the stack down for storing register values and storing the kernel stack pointer (decreamented) in t1
    csrrw t0, 0x40, t0			# t0 <-> uscratch (uscratch contains the original kernel stack pointer (non decreamented)) and t0 contains the User t0 value

    # Saving registers
    sw t0, 20(t1)
    sw t2, 16(t1)
    sw t3, 12(t1)
    sw t4, 8(t1)
    sw a0, 4(t1)

    li t0, 0
    csrrw t4, 0x42, t0    		# Move Cause to t4 and clear it
    li t0, 0x7FFFFFFF			# mask to get the Exception code
    and a0, t4, t0      		# Extract Exception Code field

    li t2, 4
    beq a0, t2, timer			# check if the exception code is 4
    li t2, 8
    beq a0, t2, keyboard 		# checks if the exception code is 8
    j handlerTerminate

keyboard:	#decide which screen is to be handled intro or play screen
	lw t0, startflag
	li t2, 1
	beq t0, t2, moves
	j startgame

startgame:	# checks which key is pressed
	# loads keyboard data into t0
	lw t0, KEYBOARD_DATA
	lbu t0, 0(t0)
	
	# if key pressed is 1
	li t2, 0x31
	beq t0, t2, lvl1
	
	#if key pressed is 2
	li t2, 0x32
	beq t0, t2, lvl2
	
	#if key pressed is 3
	li t2, 0x33
	beq t0, t2, lvl3

	j handlerEnd

lvl1:
	# set the level flag to 1
	la t0, levelcheck
	li t2, 1
	sw t2, 0(t0)
	
	# set the curbonus to bonus time for level 1
	la t0, curbonus
	lbu t2, bonustime1
	sb t2, 0(t0)
	
	# set the start flag to 1
	la t0, startflag
	li t2, 1
	sw t2, 0(t0)

	j handlerEnd

lvl2:
	# set the level flag to 2
	la t0, levelcheck
	li t2, 2
	sw t2, 0(t0)

	# set the curbonus to bonus time for level 2
	la t0, curbonus
	lbu t2, bonustime2
	sb t2, 0(t0)

	# set the start flag to 1
	la t0, startflag
	li t2, 1
	sw t2, 0(t0)

	j handlerEnd

lvl3:
	# set the level flag to 3
	la t0, levelcheck
	li t2, 3
	sw t2, 0(t0)

	# set the curbonus to bonus time for level 3
	la t0, curbonus
	lbu t2, bonustime3
	sb t2, 0(t0)

	# set the start flag to 1
	la t0, startflag
	li t2, 1
	sw t2, 0(t0)

	j handlerEnd

moves:	# key checks for w, a, s, d
	
	# load keyboard data in t0
	lw t0, KEYBOARD_DATA
	lbu t0, 0(t0)
	
	# checks if the keypressed is w, a, s, d
	li t2, 0x77
	beq t0, t2, moveW
	li t2, 0x73
	beq t0, t2, moveS
	li t2, 0x61
	beq t0, t2, moveA
	li t2, 0x64
	beq t0, t2, moveD

	j handlerEnd

moveW: # sets the pressedkey flag to the hex code for w if the key pressed is w
	la t0, pressedkey
	li t2, 0x77
	sb t2, 0(t0)

	j handlerEnd

moveS: # sets the pressedkey flag to the hex code for s if the key pressed is s
	la t0, pressedkey
	li t2, 0x73
	sb t2, 0(t0)

	j handlerEnd

moveA: # sets the pressedkey flag to the hex code for a if the key pressed is a
	la t0, pressedkey
	li t2, 0x61
	sb t2, 0(t0)

	j handlerEnd

moveD: # sets the pressedkey flag to the hex code for d if the key pressed is d
	la t0, pressedkey
	li t2, 0x64
	sb t2, 0(t0)

	j handlerEnd

timer:	#decreases the remaining time by string manipulation
	la t0, curtime
	addi t0, t0, 2

subloop:
	lb t2, 0(t0)
	addi t2, t2, -1
	li t3, 0x2F
	bgt t2, t3, loopdone
	li t3, 0x39
	sb t3, 0(t0)
	addi t0, t0, -1
	j subloop

loopdone:
	sb t2, 0(t0)
	
	# sets the update screen flag to 1 since the screen needs to be updated every second after the game has started
	la t0, updatescreen
	li t2, 1
	sw t2, 0(t0)
	
	# makes a newtime interrupt after the initial time interrupt this keeps making the new interrupts every second
   	lw t0, TIME
	lw t0, 0(t0)
	addi t0, t0, 1000
	lw t2, TIMECMP
	sw t0, 0(t2)
	j handlerEnd

handlerEnd:
    # restore the registers
    lw t0, 20(t1)
    lw t2, 16(t1)
    lw t3, 12(t1)
    lw t4, 8(t1)
    lw a0, 4(t1)
    lw t1, 0(t1)
    
    # since we already restored the original kernel stack pointer we can return
    uret


handlerTerminate:
	# Print error msg before terminating
	li     a7, 4
	la     a0, INTERRUPT_ERROR
	ecall
	li     a7, 34
	csrrci a0, 66, 0
	ecall
	li     a7, 4
	la     a0, INSTRUCTION_ERROR
	ecall
	li     a7, 34
	csrrci a0, 65, 0
	ecall
handlerQuit:
	li     a7, 10
	ecall	# End of program








#---------------------------------------------------------------------------------------------
# printAllWalls
#
# Subroutine description: This subroutine prints all the walls within which the snake moves
# 
#   Args:
#  		None
#
# Register Usage
#      s0: the current row
#      s1: the end row
#
# Return Values:
#	None
#---------------------------------------------------------------------------------------------
printAllWalls:
	# Stack
	addi   sp, sp, -12
	sw     ra, 0(sp)
	sw     s0, 4(sp)
	sw     s1, 8(sp)
	# print the top wall
	li     a0, 21
	li     a1, 0
	li     a2, 0
	la     a3, Brick
	lbu    a3, 0(a3)
	jal    ra, printMultipleSameChars

	li     s0, 1	# s0 <- startRow
	li     s1, 10	# s1 <- endRow
printAllWallsLoop:
	bge    s0, s1, printAllWallsLoopEnd
	# print the first brick
	la     a0, Brick	# a0 <- address(Brick)
	lbu    a0, 0(a0)	# a0 <- '#'
	mv     a1, s0		# a1 <- row
	li     a2, 0		# a2 <- col
	jal    ra, printChar
	# print the second brick
	la     a0, Brick
	lbu    a0, 0(a0)
	mv     a1, s0
	li     a2, 20
	jal    ra, printChar
	
	addi   s0, s0, 1
	jal    zero, printAllWallsLoop

printAllWallsLoopEnd:
	# print the bottom wall
	li     a0, 21
	li     a1, 10
	li     a2, 0
	la     a3, Brick
	lbu    a3, 0(a3)
	jal    ra, printMultipleSameChars

	# Unstack
	lw     ra, 0(sp)
	lw     s0, 4(sp)
	lw     s1, 8(sp)
	addi   sp, sp, 12
	jalr   zero, ra, 0


#---------------------------------------------------------------------------------------------
# printMultipleSameChars
# 
# Subroutine description: This subroutine prints white spaces in the Keyboard and Display MMIO Simulator terminal at the
# given row and column.
# 
#   Args:
#   a0: length of the chars
# 	a1: row - The row to print on.
# 	a2: col - The column to start printing on.
#   a3: char to print
#
# Register Usage
#      s0: the remaining number of cahrs
#      s1: the current row
#      s2: the current column
#      s3: the char to be printed
#
# Return Values:
#	None
#---------------------------------------------------------------------------------------------
printMultipleSameChars:
	# Stack
	addi   sp, sp, -20
	sw     ra, 0(sp)
	sw     s0, 4(sp)
	sw     s1, 8(sp)
	sw     s2, 12(sp)
	sw     s3, 16(sp)

	mv     s0, a0
	mv     s1, a1
	mv     s2, a2
	mv     s3, a3

# the loop for printing the chars
printMultipleSameCharsLoop:
	beq    s0, zero, printMultipleSameCharsLoopEnd   # branch if there's no remaining white space to print
	# Print character
	mv     a0, s3	# a0 <- char
	mv     a1, s1	# a1 <- row
	mv     a2, s2	# a2 <- col
	jal    ra, printChar
		
	addi   s0, s0, -1	# s0--
	addi   s2, s2, 1	# col++
	jal    zero, printMultipleSameCharsLoop

# All the printing chars work is done
printMultipleSameCharsLoopEnd:	
	# Unstack
	lw     ra, 0(sp)
	lw     s0, 4(sp)
	lw     s1, 8(sp)
	lw     s2, 12(sp)
	lw     s3, 16(sp)
	addi   sp, sp, 20
	jalr   zero, ra, 0


#------------------------------------------------------------------------------
# printStr
#
# Subroutine description: Prints a string in the Keyboard and Display MMIO Simulator terminal at the
# given row and column.
#
# Args:
# 	a0: strAddr - The address of the null-terminated string to be printed.
# 	a1: row - The row to print on.
# 	a2: col - The column to start printing on.
#
# Register Usage
#      s0: The address of the string to be printed.
#      s1: The current row
#      s2: The current column
#      t0: The current character
#      t1: '\n'
#
# Return Values:
#	None
#
# References: This peice of code is adjusted from displayDemo.s(Zachary Selk, Jul 18, 2019)
#------------------------------------------------------------------------------
printStr:
	# Stack
	addi   sp, sp, -16
	sw     ra, 0(sp)
	sw     s0, 4(sp)
	sw     s1, 8(sp)
	sw     s2, 12(sp)

	mv     s0, a0
	mv     s1, a1
	mv     s2, a2

# the loop for printing string
printStrLoop:
	# Check for null-character
	lb     t0, 0(s0)
	# Loop while(str[i] != '\0')
	beq    t0, zero, printStrLoopEnd

	# Print Char
	mv     a0, t0
	mv     a1, s1
	mv     a2, s2
	jal    ra, printChar

	addi   s0, s0, 1	# i++
	addi   s2, s2, 1	# col++
	jal    zero, printStrLoop

printStrLoopEnd:
	# Unstack
	lw     ra, 0(sp)
	lw     s0, 4(sp)
	lw     s1, 8(sp)
	lw     s2, 12(sp)
	addi   sp, sp, 16
	jalr   zero, ra, 0



#------------------------------------------------------------------------------
# printChar
#
# Subroutine description: Prints a single character to the Keyboard and Display MMIO Simulator terminal
# at the given row and column.
#
# Args:
# 	a0: char - The character to print
#	a1: row - The row to print the given character
#	a2: col - The column to print the given character
#
# Register Usage
#      s0: The character to be printed.
#      s1: the current row
#      s2: the current column
#      t0: Bell ascii 7
#      t1: DISPLAY_DATA
#
# Return Values:
#	None
#
# References: This peice of code is adjusted from displayDemo.s(Zachary Selk, Jul 18, 2019)
#------------------------------------------------------------------------------
printChar:
	# Stack
	addi   sp, sp, -16
	sw     ra, 0(sp)
	sw     s0, 4(sp)
	sw     s1, 8(sp)
	sw     s2, 12(sp)
	# save parameters
	mv     s0, a0
	mv     s1, a1
	mv     s2, a2

	jal    ra, waitForDisplayReady

	# Load bell and position into a register
	addi   t0, zero, 7	# Bell ascii
	slli   s1, s1, 8	# Shift row into position
	slli   s2, s2, 20	# Shift col into position
	or     t0, t0, s1
	or     t0, t0, s2	# Combine ascii, row, & col
	
	# Move cursor
	lw     t1, DISPLAY_DATA
	sw     t0, 0(t1)
	jal    waitForDisplayReady	# Wait for display before printing
	
	# Print char
	lw     t0, DISPLAY_DATA
	sw     s0, 0(t0)
	
	# Unstack
	lw     ra, 0(sp)
	lw     s0, 4(sp)
	lw     s1, 8(sp)
	lw     s2, 12(sp)
	addi   sp, sp, 16
	jalr   zero, ra, 0



#------------------------------------------------------------------------------
# waitForDisplayReady
#
# Subroutine description: A method that will check if the Keyboard and Display MMIO Simulator terminal
# can be writen to, busy-waiting until it can.
#
# Args:
# 	None
#
# Register Usage
#      t0: used for DISPLAY_CONTROL
#
# Return Values:
#	None
#
# References: This peice of code is adjusted from displayDemo.s(Zachary Selk, Jul 18, 2019)
#------------------------------------------------------------------------------
waitForDisplayReady:
	# Loop while display ready bit is zero
	lw     t0, DISPLAY_CONTROL
	lw     t0, 0(t0)
	andi   t0, t0, 1
	beq    t0, zero, waitForDisplayReady
	jalr   zero, ra, 0
