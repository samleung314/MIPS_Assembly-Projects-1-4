##############################################################
# Homework #3
# name: Samson Leung
# sbuid: 110490519
##############################################################
.text

##############################
# PART 1 FUNCTIONS
##############################

smiley:
    #Define your code here
	la $t0, 0xffff0000	# Memory starts at address 0xffff0001
	li $t1, 0x0f		# 0 for black background; F for white foreground
	li $t2, 0		# ASCII null char is 0
	li $t3, 0xffff00c8	# End loop value
	
smiley.loop:
	sb $t2, ($t0)		# Store ASCII null char	
	addi $t0, $t0, 1	# memory address += 1
	
	sb $t1, ($t0)		# Store color info
	addi $t0, $t0, 1	# memory address += 1
	
	beq $t0, $t3, smiley.face	# End loop when last byte reached
	
	j smiley.loop
	
# Helper macro for storing ascii and color
.macro storeFace(%x, %y)
	la $t0, %x		# X
	la $t1, %y		# Y
	sb $t2, ($t0)		# Store ascii
	sb $t3, ($t1)		# Store color
.end_macro

smiley.face: 
	# Eyes
	li $t2, 98		# ASCII 'b'
	li $t3, 0xB7		# Yellow, Grey
	
	storeFace(0xffff002E, 0xffff002F)	# (2,3)
	storeFace(0xffff0034, 0xffff0035)	# (2,6)
	storeFace(0xffff0042, 0xffff0043)	# (3,3)
	storeFace(0xffff0048, 0xffff0049)	# (3,6)
	
	# Mouth
	li $t2, 101		# ASCII 'e'
	li $t3, 0x1F		# Red, White
	
	storeFace(0xffff007C, 0xffff007D)	# (6,2)
	storeFace(0xffff0086, 0xffff0087)	# (7,3)
	storeFace(0xffff0092, 0xffff0093)	# (8,4)
	storeFace(0xffff0098, 0xffff0099)	# (8,5)
	storeFace(0xffff00A8, 0xffff00A9)	# (7,6)
	storeFace(0xffff00AA, 0xffff00AB)	# (6,7)
	
	jr $ra

##############################
# PART 2 FUNCTIONS
##############################

open_file:
    	li $v0, 13		# open file service
    	la $a0, ($a0)		# file name
   	li $a1, 0		# flag for read only
    	li $a2, 0        	# mode is ignored
   	syscall
    
    	jr $ra

close_file:
    	li $v0, 16		# close file service
    	# $a0 			file descriptor defined in main
    	syscall
    
    	jr $ra
#--------------------------------------------------------------------------#

load_map:
	# Clear game memory
	la $t0, myArray
	la $t1, myArray + 400
clearMem:
	beq $t0, $t1, clearMem.end
	sw $zero, ($t0)		# Stores zero for every word
	addi $t0, $t0, 4
	j clearMem
	
clearMem.end:
# Begin load_Map:
    	# $a0 			file descriptor defined in main
    	la $a1, buffer		# address of input buffer
    	li $a2, 1		# read one character at a time
    	
    	# $t1, t2 		# Characters: $t2 ahead of $t1
    	li $t1, -1		# Placeholder value of -1
    	li $t2, -1		# Placeholder value of -1
    	
    	li $t3, 0		# Coordinate value
    	li $t4, 0		# On y or x, 0 for y, 1 for x
    	li $t6, 0		# Bomb counter
    	li $t7, 0		# Coordinate counter
	
load_map.parse:
	li $v0, 14			# read from file service
	syscall
	bnez $v0, load_map.process		
	
	# Process $t2 at end of loop
	bltz $t2, load_map.parseEnd	# End program after done processing last char
	move $t1, $t2
	li $t2, -1			# place holder for null value cause end of file
	j caseIsNumber
		
load_map.process:
# Process characters
	move $t1, $t2			# Save previous char for comparison
	lb $t2, ($a1)			# Load next character from mem
	bltz $t1, load_map.parse	# Load the second char at start of process, $t2 is the character after $t1
	
	# START leading zeroes check
	caseLeadingZeros: #(00)
		li $t0, 48
		bne $t1, $t0, caseIsNumber	# If first char is not zero, skip leading zeroes check
		bne $t2, $t0, caseIsNumber2	# If first char is zero, and second char is not zero find out if number
		j load_map.parse		# Load the next char if 00 detected
	# END leading zeros check
	
	caseIsNumber: #(0 - 9)
		li $t0, 48
		blt $t1, $t0, case32	# Branch if < 0 - 9
		li $t0, 57
		bgt $t1, $t0, case32	# Branch if > 0 - 9
		bltz $t2, load_map.validNum	# Process last number of file
		j caseNumberNumber	# check for NumberNumber when char is a valid number
		
	caseIsNumber2: #(0 - 9)
		li $t0, 48
		blt $t2, $t0, caseNumberNumber	# If char after 0 is not a number
		li $t0, 57
		bgt $t2, $t0, caseNumberNumber	# If char after 0 is not a number
		bltz $t2, load_map.validNum	# Process last number of file
		j load_map.parse	# If char after 0 is a number
		
	caseNumberNumber: #(ex: 40, 99, 22 etc.)
		# $t1,$t2 is a NumberNumber if $t2 is not a space/tab/carriageReturn/newline
		li $t0, 32		# space
		beq $t2, $t0, load_map.validNum
		
		li $t0, 9		# tab
		beq $t2, $t0, load_map.validNum
		
		li $t0, 13		# carriageReturn
		beq $t2, $t0, load_map.validNum
		
		li $t0, 10		# newline
		beq $t2, $t0, load_map.validNum
		
		j caseError		# If $t2 is something other than a spacer then invalid
		
	case32: #(space)
		li $t0, 32
		bne $t1, $t0, case9
		j load_map.parse
	case9: #(tab)
		li $t0, 9
		bne $t1, $t0, case13
		j load_map.parse
	case13: #(carriageReturn)
		li $t0, 13
		bne $t1, $t0, case10
		j load_map.parse
	case10: #(newline)
		li $t0, 10
		bne $t1, $t0, caseError
		j load_map.parse
	caseError:
		li $v0, -1
		jr $ra			# Return to main if not valid character detected
		
load_map.validNum:
	# When a valid number is read
	addi $t7, $t7, 1		# number of coordinates ++
	addi $t1, $t1, -48		# Convert char to integer
	bnez $t4, addX			# boolean to addX when 1
	
	addY:
	li $t4, 10
	mul $t1, $t1, $t4		# y = y * 10
	add $t3, $t3, $t1		# Coordinate value += y
	
	li $t4, 1			# switch to process addX
	
	bltz $t2, caseError		# Error if last coordinate is an Y coordinate
	j load_map.parse		# now we have to get X value
	
	addX:
	add $t3, $t3, $t1		# Coordinate value += x
	
	li $t4, 0			# switch to process addY
	
	li $t8, 4			# Multiply by 4 for memory address
	mul $t3, $t3, $t8
	
	j load_map.storeArray		# store bomb in specified array value
	
load_map.storeArray:
	la $t5, myArray		# Load address of array
	add $t5, $t5, $t3		# Go to coordinate address in array (1 - 100)
	lb $t3, ($t5)
	bnez $t3, load_map.parse	# If bomb already exists skip coordinates
	
	li $t3, 0x20			# byte 0010 0000 for bomb
	sb $t3, ($t5)			# Store bomb data
	li $t3, 0			# Reset coordinate value
	addi $t6, $t6, 1		# Bomb counter++
	j load_map.parse

load_map.parseEnd:
	# Check for odd number of coordinates
	li $t1, 2
	div $t7, $t1		# coordinate counter / 2
	
	mfhi $t1		# store remainder
	bnez $t1, caseError
	
	# Check for more than 99 bombs or 0 bombs
	beqz $t6, caseError	# 0 bombs
	li $t7, 99
	bgt $t6, $t7, caseError	# > 99 bombs
	
# Calculate adjacent bombs

	la $t0, myArray		# Address cursor
	la $t1, myArray + 400	# Base case
	li $t2, 1			# Cell cursor starts from 1
	
	# Preserve return address
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
load_map.adjacent:
	beq $t0, $t1, load_map.adjacentEnd	# Stopping case
	li $t4, 0 				# Bomb counter
	
	# CORNER CASES #
	li $t3, 1
	beq $t2, $t3, adj.cornerA		# If cursor is in top left corner
	
	li $t3, 10
	beq $t2, $t3, adj.cornerB		# If cursor is in top right corner
	
	li $t3, 91
	beq $t2, $t3, adj.cornerC		# If cursor is in bottom left corner
	
	li $t3, 100
	beq $t2, $t3, adj.cornerD		# If cursor is in bottom right corner
	
	# BORDER CASES #
	li $t3, 10
	blt $t2, $t3, adj.topEdge		# If cursor is in top border
	
	li $t3, 91
	bgt $t2, $t3, adj.botEdge		# If cursor is in bot border
	
	# Remainder in HI, cursor MOD 10
	li $t3, 10
	div $t2, $t3
	mfhi $t3
	
	beq $t3, 1, adj.leftEdge		# If cursor is in left border
	beq $t3, 0, adj.rightEdge		# If cursor is in right border
	
	# EVERYWHERE ELSE #
	j adj.mid
	
	adj.cornerA: #(1)
		la $t5, myArray + 4		# Cell 2
		jal addBomb			# Check bomb
		
		la $t5, myArray + 40	# Cell 11
		jal addBomb			# Check bomb
		
		la $t5, myArray + 44	# Cell 12
		jal addBomb			# Check bomb
		
		j adj.advance
	
	adj.cornerB: #(10)
		li $t3, -4
		la $t5, myArray($t3)	# Cell 9
		jal addBomb			# Check bomb
		
		la $t5, myArray + 40	# Cell 20
		jal addBomb			# Check bomb
		
		la $t5, myArray + 36	# Cell 19
		jal addBomb			# Check bomb
		
		j adj.advance
		
	adj.cornerC: #(91)
		li $t3, -40
		la $t5, myArray($t3)	# Cell 81
		jal addBomb			# Check bomb
		
		li $t3, -36
		la $t5, myArray($t3)	# Cell 82
		jal addBomb			# Check bomb
		
		la $t5, myArray + 4		# Cell 92
		jal addBomb			# Check bomb
		
		j adj.advance
	
	adj.cornerD: #(100)
		li $t3, -40
		la $t5, myArray($t3)	# Cell 90
		jal addBomb			# Check bomb
		
		li $t3, -44
		la $t5, myArray($t3)	# Cell 89
		jal addBomb			# Check bomb
		
		li $t3, -4
		la $t5, myArray($t3)	# Cell 99
		jal addBomb			# Check bomb
		
		j adj.advance
	
	adj.topEdge:
		la $t5, myArray + 4		# Cell +1
		jal addBomb			# Check bomb
		
		la $t5, myArray + 44	# Cell +11
		jal addBomb			# Check bomb
		
		la $t5, myArray + 40	# Cell +10
		jal addBomb			# Check bomb
		
		la $t5, myArray + 36	# Cell +9
		jal addBomb			# Check bomb
		
		li $t3, -4
		la $t5, myArray($t3)	# Cell -1
		jal addBomb			# Check bomb
		
		j adj.advance
	
	adj.botEdge:
		li $t3, -4
		la $t5, myArray($t3)	# Cell -1
		jal addBomb			# Check bomb
		
		li $t3, -44
		la $t5, myArray($t3)	# Cell -11
		jal addBomb			# Check bomb
		
		li $t3, -40
		la $t5, myArray($t3)	# Cell -10
		jal addBomb			# Check bomb
		
		li $t3, -36
		la $t5, myArray($t3)	# Cell -9
		jal addBomb			# Check bomb
		
		la $t5, myArray  + 4	# Cell +1
		jal addBomb			# Check bomb
		
		j adj.advance
	
	adj.leftEdge:
		li $t3, -40
		la $t5, myArray($t3)	# Cell -10
		jal addBomb			# Check bomb
		
		li $t3, -36
		la $t5, myArray($t3)	# Cell -9
		jal addBomb			# Check bomb
		
		la $t5, myArray + 4		# Cell +1
		jal addBomb			# Check bomb
		
		la $t5, myArray + 44	# Cell +11
		jal addBomb			# Check bomb
		
		la $t5, myArray  + 40	# Cell +10
		jal addBomb			# Check bomb
		
		j adj.advance
	
	adj.rightEdge:
		la $t5, myArray + 40	# Cell +10
		jal addBomb			# Check bomb
		
		la $t5, myArray + 36	# Cell +9
		jal addBomb			# Check bomb
		
		li $t3, -4
		la $t5, myArray($t3)	# Cell -1
		jal addBomb			# Check bomb
		
		li $t3, -44
		la $t5, myArray($t3)	# Cell -11
		jal addBomb			# Check bomb
		
		li $t3, -40
		la $t5, myArray($t3)	# Cell -10
		jal addBomb			# Check bomb
		
		j adj.advance
	
	adj.mid:
		li $t3, -40
		la $t5, myArray($t3)	# Cell -10
		jal addBomb			# Check bomb
		
		li $t3, -36
		la $t5, myArray($t3)	# Cell -9
		jal addBomb			# Check bomb
		
		la $t5, myArray +4		# Cell +1
		jal addBomb			# Check bomb
		
		la $t5, myArray +11		# Cell +11
		jal addBomb			# Check bomb
		
		la $t5, myArray +10		# Cell +10
		jal addBomb			# Check bomb
		
		la $t5, myArray +36		# Cell +9
		jal addBomb			# Check bomb
		
		li $t3, -4
		la $t5, myArray($t3)	# Cell -1
		jal addBomb			# Check bomb
		
		li $t3, -44
		la $t5, myArray($t3)	# Cell -11
		jal addBomb			# Check bomb

		j adj.advance
		
	addBomb:
	lb $t6, ($t5)				# Load game info
	srl $t6, $t6, 5				# Get rid of bits to check bomb
	
	bne $t6, 1, noBomb			# t6 is cell game info 
	addi $t4, $t4, 1			# bomb counter ++
	
	noBomb:
	jr $ra
	
	adj.advance:
	lb $t5, ($t0)
	add $t5, $t5, $t4		# Add number of bombs to byte
	sb $t5, ($t0)			# Store back in array at cursor address $t0
	
	addi $t0, $t0, 4		# Advance cell
	addi $t2, $t2, 1		# Advance cursor
	j load_map.adjacent
	
load_map.adjacentEnd:
la $t0, myArray + 100	# 9 CHANGEs
la $t2, myArray
move $t3, $a1
arrayCopy:
lb $t1, ($t2)
sb $t1, ($t3)
addi $t2, $t2, 1
addi $t3, $t3, 1
blt $t2, $t0, arrayCopy
	# Initialize cursor_row and cursor_col
	sw $zero, cursor_row
	sw $zero, cursor_col
	# Restore return address
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra

##############################
# PART 3 FUNCTIONS
##############################

init_display:
	la $t0, 0xffff0000	# Starting address [0,
	la $t1, 0xffff00c7	# Ending address   ,199]
	
	li $t2, 0x0		# null char
	li $t3, 0x77		# Grey background, grey foreground
	
init_display.start:
	bgt $t0, $t1, init_display.end
	
	sb $t2, ($t0)		# Store null char in [x,
	addi $t0, $t0, 1	# Advance address by 1
	
	sb $t3, ($t0)		# Store color in ,y]
	addi $t0, $t0, 1	# Advance address by 1
	j init_display.start
	
init_display.end:
	# Calculate cursor address
	
	lw $t0, cursor_row	# address = y
	li $t1, 10
	mul $t0, $t0, $t1	# address = y*10
        lw $t1, cursor_col
        add $t0, $t0, $t1		# address = address + x
        addi $t0, $t0, 0xffff0001	# address += 0xffff0002 offset by 1

	li $t1, 0xB7			# set cursor to yellow
	sb $t1, ($t0)		
    	jr $ra

# SET CELL FUNCTION
set_cell:
	# a0 = row; a1 = column; a2 = char; a3 = foreground color; $sp = background color
	# Check valid args
	
	bltz $a0, set_cell.invalid
	bgt $a0, 9, set_cell.invalid
	
	bltz $a1, set_cell.invalid
	bgt $a1, 9, set_cell.invalid
	
	bltz $a3, set_cell.invalid
	bgt $a3, 16, set_cell.invalid
	
	lb $t0, ($sp)
	bltz $t0, set_cell.invalid
	bgt $t0, 16, set_cell.invalid
	
	# Convert coordinates in address
	move $t0, $a0		# address = y
	li $t1, 10	
	mul $t0, $t0, $t1	# address = y*10
	
	move $t1, $a1		# load x
	add $t0, $t0, $t1	# address = address + x
	
	addi $t0, $t0, 0xffff0000	# address += 0xffff0000
	
	# Set character
	sb $a2, ($t0)	
	addi $t0, $t0, 1	# Advance address by 1
	
	# Set color	
	lw $t1, ($sp)		# Load background color

	sll $t1, $t1, 4
	add $t1, $t1, $a3	# Combine with foreground color
	
	sb $t1, ($t0)		# Store color data
	j set_cell.valid

set_cell.invalid:
	li $v0, -1
	jr $ra
set_cell.valid:
	li $v0, -0
    	jr $ra

# REVEAL MAP FUNCTION
reveal_map:
    	bltz $a0, reveal_map.lost
   	beqz $a0, reveal_map.going
    	bgtz $a0, reveal_map.won
    	
reveal_map.lost:
	move $t0, $a1	# save the address of array
	li $a0, 0
	li $a1, 0
	la $t8, myArray 	#array address counter
	move $t9, $ra
	
	column:
	bgt $a1, 9, row
	
	# check flag
	lb $t2, ($t8)
	sll $t2, $t2, 4
	beq $t2, 1, redFlag
	beq $t2, 3, greenFlag
	j checkBomb		# if no flag, check bomb
	
	redFlag:
	li $a2, 0x66		# flag char
	li $a3, 0xF		# foreground white
	addi $sp, $sp, -4
	li $t2, 0x9		# background bright red
	sw $t2, ($sp)
	jal set_cell
	addi $sp, $sp, 4	# Deallocate
	
	greenFlag:
	li $a2, 0x66		# flag char
	li $a3, 0xF		# foreground white
	addi $sp, $sp, -4
	li $t2, 0xA		# background bright green
	sw $t2, ($sp)
	jal set_cell
	addi $sp, $sp, 4	# Deallocate
	
	checkBomb:
	lb $t2, ($t8)
	sll $t2, $t2, 5
	beq $t2, 1, revealBomb
	j numberBombs		# If no bombs
	
	revealBomb:
	li $a2, 0x62		# bomb char
	li $a3, 0x7		# foreground grey
	addi $sp, $sp, -4
	li $t2, 0x0		# background black
	sw $t2, ($sp)
	jal set_cell
	addi $sp, $sp, 4	# Deallocate
	
	numberBombs:
	lb $t2, ($t8)
	srl $t2, $t2, 4
	li $t3, 16
	div $t2, $t3
	mflo $t2		# number of bombs
	addi $t2, $t2, 0x30	# add with ascii 0
	
	move $a2, $t2		# num char
	li $a3, 0xD		# foreground bright magenta
	addi $sp, $sp, -4
	li $t2, 0x0		# background black
	sw $t2, ($sp)
	jal set_cell
	addi $sp, $sp, 4	# Deallocate
	
	addi $t8, $t8, 1	# address ++
	addi $a1, $a1, 1	# column ++
	j column
	
	row:
	bgt $a0, 9, reveal_map.lost.end
	addi $a0, $a0, 1	# row ++
	j column
	
reveal_map.lost.end:
	# Exploded bomb
	lw $a0, cursor_row
    	lw $a1, cursor_col
    	li $a2, 0x62		# bomb ascii
    	li $a3, 0x9		# foreground color bright red
    	addi $sp, $sp, -4	# allocate space
    	li $t0, 0xF		# background color white
    	sw $t0, ($sp)
    	jal set_cell
    	addi $sp, $sp, 4	# Deallocate bytes
    	
	move $ra, $t9
	jr $ra

reveal_map.won:
	j smiley
reveal_map.going:
    	jr $ra


##############################
# PART 4 FUNCTIONS
##############################

perform_action:
	lw $t0, cursor_row	# y
	lw $t8, cursor_col	# x
	li $t7, 0		# final coordinate
	
    	move $t9, $a0	# store array_cells
    	beq $a1, 0x77, up
    	beq $a1, 0x61, left
    	beq $a1, 0x73, down
    	beq $a1, 0x64, right
    	beq $a1, 0x72, reveal
    	beq $a1, 0x66, flag
    
    	up:
    	addi $t0, $t0, -1
    	sw $t0, cursor_row
    	li $t1, 10
	mul $t0, $t0, $t1	# address = y*10
	bltz $t0, actionBreak
    	j actionDone
    
    	left:
    	addi $t8, $t8, -1
    	sw $t8, cursor_col
    	j actionDone
    
    	down:
    	addi $t0, $t0, 1
    	sw $t0, cursor_row
    	li $t1, 10
	mul $t0, $t0, $t1	# address = y*10
	bgt $t0, 100, actionBreak
    	j actionDone
    
    	right:
    	addi $t8, $t8, 1
    	sb $t8, cursor_col
    	j actionDone
    
    	reveal:
    	j actionDone
    
    	flag:
    	j actionDone

actionDone:
	add $t0, $t0, $t8		# address
	addi $t0, $t0, 0xffff0001	# address += 0xffff0001 offset by 1 for color

	li $t1, 0xB7			# set cursor to yellow
	sb $t1, ($t0)
	li $v0, 0	
    	jr $ra
    	
actionBreak:
	li $v0, -1
	jr $ra

game_status:
    li $v0, 0
    jr $ra

##############################
# PART 5 FUNCTIONS
##############################

search_cells:
    #Define your code here
    jr $ra


#################################################################
# Student defined data section
#################################################################
.data
.align 2  # Align next items to word boundary
cursor_row: .word -1
cursor_col: .word -1
myArray: .space 100 # 1 CHANGE
buffer: .byte 1
#place any additional data declarations here

