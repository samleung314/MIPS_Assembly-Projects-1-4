##############################################################
# Homework #4
# name: Samson Leung
# sbuid: 110490519
##############################################################
.text

##############################
# PART 1 FUNCTIONS
##############################

preorder:
   	move $t7, $a0 # $a0 = (cursor) node array address 
    	move $t8, $a1 # $a1 = node array base address
    	move $t9, $a2 # $a2 = file descriptor

    	itof:
    	lhu $t0, 0($a0)		# load node value from bytes 0,1
    	srl $t1, $t0, 15	# check sign bit
    	beqz $t1, itof.pos	# if positive or zero, branch
    	
   	# convert negative number
   	
   	xori $t0, $t0, -1	# flip the bits
    	sll $t0, $t0, 16	# get rid of extended sign bits
    	srl $t0, $t0, 16
    	addi $t0, $t0, 1	# add 1
    	
    	# print out negative sign
    	
    	li $v0, 15
    	move $a0, $a2		# load file descriptor argument
    	la $a1, negSign
    	li $a2, 1		# load max num of chars to write
    	syscall
    	
    	# convert number to char
    	
    	itof.pos:
    	la $t3, nodeStore + 5	# make space in address for number (6 bits)
    	itof.parse:
    	li $t1, 10
    	div $t0, $t1		# divide by 10 to get ones place
    	
    	mfhi $t1
    	mflo $t0
    	addi $t1, $t1, 0x30	# add '0' to convert to char
    	sb $t1, ($t3)		# store chars in nodeStore
    	addi $t3, $t3, -1	# move address down by 1
    	
    	bnez $t0, itof.parse	# loop until quotient is 0
    	
    	# write node's value to file

    	la $t3, nodeStore
    	li $t4, 6 		# counter
    	move $a0, $t9		# load file descriptor argument
    	li $a2, 1		# load max num of chars to write
    	itof.print:
    	beqz $t4, itof.end	# end printing when all numbers printed
    			
	li $v0, 15		# write to file code
	lb $t0, ($t3)
	beqz $t0, itof.printSkip # skip over leading 0s
	
	move $a1, $t3		# load char buffer address
	syscall			# Print to file
	
	itof.printSkip:
	addi $t3, $t3, 1	# advance address by 1
	addi $t4, $t4, -1	# counter++
    	j itof.print
    	
    	itof.end:
    	# write new line to file
    	
    	li $v0, 15		# call code
    	move $a0, $t9		# load file descriptor argument
    	la $a1, newLine		# load newLine char
    	li $a2, 1		# max chars to write
    	syscall
    	
    	# fetch 8-bit index left node
    	move $a0, $t7
    	move $a1, $t8
    	move $a2, $t9
    	
    	checkLeft:
    	# check for left node
    	
    		# determine the address of the left child in node array
    	move $t0, $a0		# load cursor address
    	addi $t0, $t0, 3	# left node address index
    	lbu $t0, ($t0)		# load index value
    	
    	beq $t0, 0xFF, checkRight		# if (nodeIndex != 255)
    	
    	li $t1, 4		# 4 bytes per node
    	mul $t0, $t0, $t1	# offset = 4 * index
    	add $t0, $t0, $a1	# leftNodeAddr = base + offset
    	
    			# load next left node address into cursor
    	
    	addi $sp, $sp, -8	# store $ra and cursor adddress
    	sw $ra, 0($sp)
    	sw $a0,	4($sp)
    	
    	move $a0, $t0		# load next left node address into cursor
    	
    	jal preorder		# recursive call
    	lw $ra, 0($sp)
    	lw $a0, 4($sp)		# restore cursor
    	addi $sp, $sp, 8
    	
    	checkRight:
    		# determine the address of the right child in node array
    	move $t0, $a0		# load cursor address
    	addi $t0, $t0, 2	# right node address
    	lbu $t0, ($t0)		# load index value
    	
    	beq $t0, 0xFF, return		# if (nodeIndex != 255)
    	
    	li $t1, 4		# 4 bytes per node
    	mul $t0, $t0, $t1	# offset = 4 * index
    	add $t0, $t0, $a1	# leftNodeAddr = base + offset
    	
    	
    	addi $sp, $sp, -8	# store $ra and cursor adddress
    	sw $ra, 0($sp)
    	sw $a0,	4($sp)
    	
    	move $a0, $t0		# load next right node address into cursor
    	
    	jal preorder		# recursive call
    	lw $ra, 0($sp)
    	lw $a0, 4($sp)		# restore cursor
    	addi $sp, $sp, 8
    	
    	return:
	jr $ra

##############################
# PART 2 FUNCTIONS
##############################

linear_search:
    #Define your code here
    ############################################
    # DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
    li $v0, -10
    ###########################################
    jr $ra

set_flag:
    #Define your code here
    ############################################
    # DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
    li $v0, -20
    ###########################################
    jr $ra

find_position:
    #Define your code here
    ############################################
    # DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
    li $v0, -30
    li $v1, -40
    ###########################################
    jr $ra

add_node:
    #Define your code here
    ############################################
    # DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
    li $v0, -50
    ###########################################
	jr $ra

##############################
# PART 3 FUNCTIONS
##############################

get_parent:
    #Define your code here
    ############################################
    # DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
    li $v0, -60
    li $v1, -70
    ###########################################
    jr $ra

find_min:
    #Define your code here
    ############################################
    # DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
    li $v0, -80
    li $v1, -90
    ###########################################
    jr $ra

delete_node:
    #Define your code here
    ############################################
    # DELETE THIS CODE. Only here to allow main program to run without fully implementing the function
    li $v0, -100
    ###########################################
    jr $ra

##############################
# EXTRA CREDIT FUNCTION
##############################

add_random_nodes:
    #Define your code here
    jr $ra



#################################################################
# Student defined data section
#################################################################
.data
.align 2  # Align next items to word boundary
nodeStore: .space 6
negSign: .byte 0x2D
newLine: .byte 0xA

#place any additional data declarations here

