##############################################################
# Homework #4
# name: Samson Leung
# sbuid: 110490519
##############################################################
.text

##############################
# PART 1 FUNCTIONS
##############################
.macro storeArgs
	move $t7, $a0		# preserve $a0
    	move $t8, $a1		# preserve $a1
    	move $t9, $a2		# preserve $a2
.end_macro

.macro restoreArgs
	move $a0, $t7		# restore $a0
    	move $a1, $t8		# restore $a1
    	move $a2, $t9		# restore $a2
.end_macro

preorder:
    	itof:
    		lhu $t0, 0($a0)		# load node value from bytes 0,1
    		srl $t1, $t0, 15	# get sign bit
    		beqz $t1, itof.pos	# if not negative, branch
    		
    		# convert negative number
    		
    		xori $t0, $t0, -1	# flip the bits
    		sll $t0, $t0, 16	# get rid of extended sign bits
    		srl $t0, $t0, 16
    		addi $t0, $t0, 1	# add 1
    		
    		# print out negative sign
    		
    		storeArgs
    		li $v0, 15		# syscall code
    		move $a0, $a2		# load file descriptor argument
    		la $a1, negSign		# load negative sign
    		li $a2, 1		# load max num of chars to write
    		syscall
		restoreArgs
    		
    		# convert number to character
    		
    		itof.pos:
    		la $t3, nodeStore + 5	# store number backwards in address (6 bits)
    		
    		itof.convert:
    		li $t1, 10
    		div $t0, $t1		# divide by 10 to get ones place
    		
    		mfhi $t1		# get remainder
    		mflo $t0		# get quotient
    		
    		addi $t1, $t1, 0x30	# add '0' to convert to char
    		sb $t1, ($t3)		# store chars in nodeStore
    		addi $t3, $t3, -1	# move address down by 1
    		
    		bnez $t0, itof.convert	# loop until quotient is 0
    		
    		# write number to file
    		storeArgs
    		move $a0, $a2		# load file descriptor argument
    		li $a2, 1		# load max num of chars to write		
    		
    		la $t0, nodeStore	# load buffer address
    		li $t1, 6		# counter of characters
    		
    		itof.print:
    		
    		beqz $t1, itof.end	# end printing when all numbers printed
    			
		li $v0, 15		# syscall code
		lb $t2, ($t0)		# get character from buffer
		beqz $t2, itof.printSkip # skip over leading 0s
	
		move $a1, $t0		# load char buffer address
		syscall			# Print to file
	
		itof.printSkip:
		addi $t0, $t0, 1	# advance address by 1
		addi $t1, $t1, -1	# counter++
		
    		j itof.print
    		
    		itof.end:
    		restoreArgs
    		
    		storeArgs
    		li $v0, 15		# syscall code
    		move $a0, $a2		# load file descriptor argument
    		la $a1, newLine		# load newLine char
    		li $a2, 1		# max chars to write
    		syscall
    		restoreArgs
    	
    	# check for left child
    	
    	checkLeft:
    		# determine the address of the left child in node array
    		move $t0, $a0		# load cursor address
    		addi $t0, $t0, 3	# calculate left node address
    		lbu $t0, ($t0)		# load left child index value
    	
    		beq $t0, 0xFF, checkRight	# if (nodeIndex = 255) branch
    		
    		li $t1, 4		# 4 bytes per node
    		mul $t0, $t0, $t1	# offset = 4 * index
    		add $t0, $t0, $a1	# leftNodeAddr = base + offset
    		
    		addi $sp, $sp, -8	# store $ra and cursor adddress
    		sw $ra, 0($sp)
    		sw $a0,	4($sp)
    		
    		move $a0, $t0		# load next left node address into cursor
    		
    		jal preorder		# recursive call
    		lw $ra, 0($sp)		# restore cursor and return address
    		lw $a0, 4($sp)
    		addi $sp, $sp, 8
    	
    	# check for right child
    	
    	checkRight:
    		# determine the address of the right child in node array
    		move $t0, $a0		# load cursor address
    		addi $t0, $t0, 2	# calculate right node address
    		lbu $t0, ($t0)		# load left child index value
    	
    		beq $t0, 0xFF, return	# if (nodeIndex = 255) branch
    		
    		li $t1, 4		# 4 bytes per node
    		mul $t0, $t0, $t1	# offset = 4 * index
    		add $t0, $t0, $a1	# rightNodeAddr = base + offset
    		
    		addi $sp, $sp, -8	# store $ra and cursor adddress
    		sw $ra, 0($sp)
    		sw $a0,	4($sp)
    		
    		move $a0, $t0		# load next left node address into cursor
    		
    		jal preorder		# recursive call
    		lw $ra, 0($sp)		# restore cursor and return address
    		lw $a0, 4($sp)
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
nodeStore: .space 6	# stores max 6 chars
negSign: .byte 0x2D	# dash character
newLine: .byte 0xA	# newline character

#place any additional data declarations here

