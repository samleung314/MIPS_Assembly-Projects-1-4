##############################################################
# Homework #2
# name: Samson Leung
# sbuid: 110490519
##############################################################

##############################
# PART 1 FUNCTIONS 
##############################
# PART A #
atoui:
    	li $t0, 48 	# ascii 0
    	li $t1, 57 	# ascii 9
    	li $t2, 0 	# sum
    	li $t3, 10  	# 10
    	move $t4, $a0	# temp store for argument and acts as counter
    	# $t5 for processing bytes
    	li $t6, 10 
    	# $t7 for holding product
    	
	checkLoop:
	lb $t5, 0($t4)	# load each character into $t4
    	
    	blt $t5, $t0, endCheck # check to see if < ascii '0'
	bgt $t5, $t1, endCheck # check to see if > ascii '9'
	
	# sum = (sum * 10) + (char - '0')
	mult $t2, $t6
	mflo $t7		# (sum * 10)
	sub $t5, $t5, $t0	# (char - '0')
	add $t2, $t7, $t5	# (sum * 10) + (char - '0') stored in $t2
	
	addi $t4, $t4, 1	# counter++
	j checkLoop

	endCheck:
	move $v0, $t2 # Return value in $v0
	jr $ra
	
# PART B #
uitoa:
    	# $a0, uitoa_value
   	# $a1, uitoa_output (array address of the String)
   	# $a2, uitoa_outputSize
    	# $v0 address of byte immediately following last character or address of output
    	# $v1 1 if successful, else 0
    	li $t0, 10	# used for multiplication by 10
    	li $t1, 0	# COUNTER for length
    	
    	# Check length of integer
    	checkIntLength:
    		beqz $t2, checkIntLength.end	# End loop when value is 0
    		div $t2, $t0 			# $t2 = $t2/10 with no remainder
    		mflo $t2
    		addi $t1, $t1, 1		# COUNTER++
    		j checkIntLength
    	checkIntLength.end:
    		bgt $t1, $a2, uitoa.unsuccess	# End if not enough space
    		
    		move $t2, $a0			# Reset with value of $a0
    		addi $t1, $t1, -1		# Index 0
    		add $a1, $a1, $t1		# Make space in address
    		j intToString	# Start conversion from int to string
    		
   	intToString:
   		div $t2, $t0 		# $t2/10 quotient in $LO and the remainder in $HI 
    		mflo $t2 		# quotient in $t2 [$t2 = $a0 - (one's place)]
    		mfhi $t3 		# remainder in $t3
    		
    		addi $t3, $t3, 48 	# 48 is ascii '0', $t3 now contains String representation of integer
    		 
    		sb $t3, 0($a1) 		# put ascii into memory at address
    		beqz $t2, uitoa.success # End conversion when 0
 
    		addi $a1, $a1, -1 	# advance memory address left by a btye
    		j intToString 		# Loop until done
	
   	uitoa.success:
   		addi $t1, $t1, 1 # Point to byte after integer
   		add $a1, $a1, $t1 # Move pointer right
   		move $v0, $a1	# Output
		li $v1, 1	# 1 for successful
		jr $ra		# Return to main
   	
   	uitoa.unsuccess:
		move $v0, $a1	# Output unmodified
		li $v1, 0	# 0 for unsuccessful
		jr $ra		# Return to main
   	
##############################
# PART 2 FUNCTIONS 
##############################    

# PART D #      
decodeRun:
	# $a0, decodeRun_letter
    	# $a1, decodeRun_runLength
    	# $a2, decodeRun_output
    	# $v0, address of unprocessed output
    	# $v1, 1 or 0
    	
    	li $t0, 1 
    	blt $a1, $t0, decodeRun.fail	# For runLength < 1
    	
    	li $t0, 65	# ascii A
    	li $t1, 90 	# ascii Z
    	li $t2, 97	# ascii a
    	li $t3, 122	# ascii z
    	lb $t4, 0($a0) 	# load decodeRun_letter
    	
    	blt $t4, $t0, decodeRun.fail 	# check less than A
    	bgt $t4, $t3, decodeRun.fail	# check greater than z

    	bgt $t4, $t1, checka
    	j buildString
    	checka:
    	blt $t4, $t2, decodeRun.fail
    	
    	buildString:
    		beqz $a1, decodeRun.finish
    		sb $t4, 0($a2)		# Load decodeRun_letter into decodeRun_output
    		addi $a2, $a2, 1	# Advance address
    		addi $a1, $a1, -1	# Decrement counter
    		j buildString
    		 		
    	decodeRun.finish:
    		move $v0, $a2
    		li $v1, 1
    		jr $ra
    		
    	decodeRun.fail:
    		move $v0, $a2
    		li $v1, 0
   		jr $ra

# PART C #
decodedLength:
	# $a0, decodedLength_input
    	# $a1, decodedLength_runFlag
    	
    	# Check null string
    	lb $t0, 0($a0) # Load first character
    	lb $t1, 0($a1) # Load flag character
    	
    	beqz $t0, default # Return 0 if null String
    	
    	# Check flags
	case33:	#(!)
		li $t0, 33
		bne $t0, $t1, case35
		j done
	case35:	#(#)
		li $t0, 35
		bne $t0, $t1, case36
		j done
	case36:	#($)
		li $t0, 36
		bne $t0, $t1, case37
		j done
	case37:	#(%)
		li $t0, 37
		bne $t0, $t1, case38
		j done
	case38:	#(&)
		li $t0, 38
		bne $t0, $t1, case42
		j done
	case42:	#(*)
		li $t0, 42
		bne $t0, $t1, case64
		j done
	case64:	#(*)
		li $t0, 64
		bne $t0, $t1, case94
		j done
	case94:	#(^)
		li $t0, 94
		bne $t0, $t1, default
		j done
	default:# Return 0
		li $v0, 0
		jr $ra
	done: 
		# $t0 is now flag character
		move $t1, $a0	# $t1 contains String
		li $t2, 0 	# COUNTER
	parse:
		lb $t3, 0($t1)			# Load a character into $t3
		
		parse2:
		beqz $t3, parse.end
		
		addi $t1, $t1, 1		# Advance pointer
		beq $t3, $t0, parse.flag	# Branch if flag detected
		addi $t2, $t2, 1 		# COUNTER++
		j parse
	parse.flag:
		addi $t1, $t1, 1		# Advance pointer again to number
		move $a0, $t1			# Prepare argument for atoui
		
		addi $sp, $sp, -20		# Make space for 4 registers on stack
		sw $t0, 0($sp)			# Save $t0 on stack
		sw $t1, 4($sp)			# Save $t1 on stack
		sw $t2, 8($sp)			# Save $t2 on stack
		sw $t3, 12($sp)			# Save $t3 on stack
		sw $ra, 16($sp)			# preserve return address
		jal atoui
		lw $t0, 0($sp)			# Restore $t0 on stack
		lw $t1, 4($sp)			# Restore $t1 on stack
		lw $t2, 8($sp)			# Restore $t2 on stack
		lw $t3, 12($sp)			# Restore $t3 on stack
		lw $ra, 16($sp)			# Restore return address
		addi $sp, $sp, 20		# Deallocate stack space
		
		add $t2, $t2, $v0		# Add int to counter
		
		# Advance pointer until past numbers; when (pointer=>48 and pointer=<57)
		checkNum:
		lb $t3, 0($t1)
		li $t4, 48
		bge $t3, $t4, checkLess
		j parse2
		checkLess:
		li $t4, 57
		ble $t3, $t4, advance
		j parse2
		advance:
		addi $t1, $t1, 1
		j checkNum
	parse.end:
		addi $t2, $t2, 1 		# COUNTER++ for null char
		move $v0, $t2
		jr $ra
# PART E #     
.macro saveStack
	addi $sp, $sp, -36		# Make space for 4 registers on stack
	sw $a0, 0($sp)			# Save $a0 on stack
	sw $a1, 4($sp)			# Save $a1 on stack
	sw $a2, 8($sp)			# Save $a2 on stack
	sw $a3, 12($sp)			# Save $a3 on stack
	sw $t0, 16($sp)
	sw $t1, 20($sp)
	sw $t2, 24($sp)
	sw $t3, 28($sp)
	sw $t4, 32($sp)
	sw $ra, 36($sp)			# preserve return address
.end_macro  

.macro restoreStack
	lw $a0, 0($sp)			# Restore $a0 on stack
	lw $a1, 4($sp)			# Restore $a1 on stack
	lw $a2, 8($sp)			# Restore $a2 on stack
	lw $a3, 12($sp)			# Restore $a3 on stack
	lw $t0, 16($sp)
	lw $t1, 20($sp)
	lw $t2, 24($sp)
	lw $t3, 28($sp)
	lw $t4, 32($sp)
	lw $ra, 36($sp)			# preserve return address
	addi $sp, $sp, 36		# Deallocate stack space
.end_macro 

runLengthDecode:
    # $a0, runLengthDecode_input
    # $a1, runLengthDecode_output
    # $a2, runLengthDecode_outputSize
    # $a3, runLengthDecode_runFlag
    # $v0, either 0 or 1
    	## CHECK FOR INVALID FLAG AND ACCEPTABLE INPUT LENGTH ##
	saveStack
	la $a0, ($a0) 	# Input string
	la $a1, ($a3)	# Run flag
	jal decodedLength 			# Returns 0 for invalid flag otherwise length of input
	restoreStack
	
	beqz $v0, runLengthDecode.fail		# Branch if invalid flag ($v0 = 0)
	bgt $v0, $a2, runLengthDecode.fail	# If decodedLength > runLengthDecode_outputSize then not enough space
	## --------------------------------------------------- ##
	
	## START CONVERSION INTO OUTPUT ##
	lb $t1, 0($a3) 				# Load runFlag
	
	runLengthDecode.parse:
	lb $t0, 0($a0)				# Load input char
	
	beqz $t0, runLengthDecode.parse.end	# End loop when null character
	beq $t1, $t0, startRun 			# Branch when flag detected
	sb $t0, 0($a1)				# Store char into output if not flag
	addi $a0, $a0, 1			# Advance input pointer by 1
	addi $a1, $a1, 1			# Advance input pointer by 1
	
	j runLengthDecode.parse
	
	startRun:
		addi $a0, $a0, 1 # Advance to run letter
		move $t0, $a0 	# Store run letter address
		addi $a0, $a0, 1 # Advance to run number
		
		## CONVERT RUN NUMBER TO INTEGER USING ATOUI
		saveStack
		move $a0, $a0	# Input $a0 for atoui is address of String
		jal atoui
		restoreStack
		
		## DECODE RUN LENGTH
		# $a0, decodeRun_letter
    		# $a1, decodeRun_runLength
    		# $a2, decodeRun_output
    		# $v0, address of unprocessed output
		saveStack
		move $a0, $t0 	# decodeRun_letter address
		move $a2, $a1	# decodeRun_output
		move $a1, $v0	# decodeRun_runLength integer
		jal decodeRun
		restoreStack
		
		move $a1, $v0 # Where processing left off in output
		
		# Advance pointer until past numbers; when (pointer=>48 and pointer=<57)
		startRun.move:
		lb $t0, 0($a0)	# Char from input to check
		li $t4, 48
		bge $t0, $t4, move.checkLess
		j runLengthDecode.parse
		move.checkLess:
		li $t4, 57
		ble $t0, $t4, move.advance
		j runLengthDecode.parse
		move.advance:
		addi $a0, $a0, 1
		j startRun.move
	
	runLengthDecode.parse.end:
		sb $0, 0($a1)	# Add null character
		li $v0, 1 	# CONVERSION SUCCESSFUL
		jr $ra
	
    	runLengthDecode.fail:
    		# $a1 is unmodified
    		li $v0, 0
    		jr $ra

##############################
# PART 3 FUNCTIONS 
##############################

# PART G #             
encodeRun:
	# $a0, encodeRun_letter 	checked
    	# $a1, encodeRun_runLength 	checked
    	# $a2, encodeRun_output
    	# $a3, encodeRun_runFlag	checked
    	# $v0, output address
    	# $v1, 0 or 1
    	# CHECK encodeRun_runLength < 1 #
    	li $t0, 1
    	blt $a1, $t0, encodeRun.fail	
    	
    	# CHECK RUN LETTER VALID IN 65 - 90 and  97 - 122 #
    	lb $t4, 0($a0) 	# load encodeRun_letter
    	
    	li $t0, 65	# ascii A
    	li $t1, 90 	# ascii Z
    	li $t2, 97	# ascii a
    	li $t3, 122	# ascii z
 
    	blt $t4, $t0, encodeRun.fail 	# check less than 97 A
    	bgt $t4, $t3, encodeRun.fail	# check greater than 122 z

    	bgt $t4, $t1, encodeRun.checka		# check greater than 90 Z
    	j encodeRun.buildString
    	encodeRun.checka:
    	blt $t4, $t2, encodeRun.fail	# check less than 97 z

    	# CHECK FLAGS
    	lb $t1, 0($a3) 	# load encodeRun_runFlag
	encodeRun.case33:	#(!)
		li $t0, 33
		bne $t0, $t1, encodeRun.case35
		j encodeRun.buildString
	encodeRun.case35:	#(#)
		li $t0, 35
		bne $t0, $t1, encodeRun.case36
		j encodeRun.buildString
	encodeRun.case36:	#($)
		li $t0, 36
		bne $t0, $t1, encodeRun.case37
		j encodeRun.buildString
	encodeRun.case37:	#(%)
		li $t0, 37
		bne $t0, $t1, encodeRun.case38
		j encodeRun.buildString
	encodeRun.case38:	#(&)
		li $t0, 38
		bne $t0, $t1, encodeRun.case42
		j encodeRun.buildString
	encodeRun.case42:	#(*)
		li $t0, 42
		bne $t0, $t1, encodeRun.case64
		j encodeRun.buildString
	encodeRun.case64:	#(@)
		li $t0, 64
		bne $t0, $t1, encodeRun.case94
		j encodeRun.buildString
	encodeRun.case94:	#(^)
		li $t0, 94
		bne $t0, $t1, encodeRun.fail
    	encodeRun.buildString:
    		li $t0, 3
    		ble $a1, $t0, encodeRun.short	# Branch if encodeRun_runLength <=3
    		
    		lb $t1, 0($a3) 			# load encodeRun_runFlag 
    		sb $t1, 0($a2)			# Store the flag (!)
    		addi $a2, $a2, 1		# advance memory
    		
    		lb $t1, 0($a0)			# load encodeRun_letter 
    		sb $t1, 0($a2)			# Store the letter (A)
    		addi $a2, $a2, 1		# advance memory
    		
    		# Convert encodeRun_runLength to String
    		saveStack
    		move $a0, $a1	# load encodeRun_runLength into $a0
    		move $a1, $a2	# load encodeRun_output address into $a1
    		li $a2, 4	# set uitoa_outputSize to 4 since no runs are more than 99 in length
    		jal uitoa
    		restoreStack
    		
    		move $a2, $v0
    		
    		j encodeRun.end
    	encodeRun.short:
    		beqz $a1, encodeRun.end	# end when length is 0
    		lb $t1, 0($a0)		# encodeRun_letter 
    		sb $t1, 0($a2)		# encodeRun_output
    		addi $a2, $a2, 1	# advance memory
    		addi $a1, $a1, -1 	# COUNTER
    		j encodeRun.short
    		
    	encodeRun.end:
    		move $v0, $a2	# Return address of output if unmodified
    		li $v1, 1	# 1 for success
    		jr $ra
    		
    	encodeRun.fail:
    		move $v0, $a2	# Return address of output if unmodified
    		li $v1, 0	# 0 for fail
    		jr $ra

# PART F #
encodedLength:
	# $t0 = temp store for comparison; $t1 = pointer
	lb $t0, 0($a0)	# Load first character into temp
	li $t2, 0	# RUN COUNTER
	li $t3, 0	# String length counter
	beqz $t0, encodedLength.null	# End when input is empty
	
	countSame.new:
	lb $t0, 0($a0)	# Load new character into temp
	beqz $t0, encodedLength.end	# End when null char reached
	countSame:
	lb $t1, 0($a0)			# Load char into pointer
	bne $t1, $t0, countSame.end	# End when diff char reached
	
	addi $t2, $t2, 1	# RUN COUNTER++
	addi $a0, $a0, 1	# Advance pointer
	j countSame
	
	countSame.end:
	li $t0, 3
	ble $t2, $t0, countSame.noRun	# Run is too short for encoding
	addi $t3, $t3, 2		# COUNTER+2 for run flag and letter (!a)
	
	countIntLength:
	beqz $t2, countSame.new		# End integer place count when RUN COUNTER is 0
	li $t0, 10
	div $t2, $t0			# Remove a integer place
	mflo $t2			# RUN COUNTER with one less place (resets RUN COUNTER to 0 when it reaches 0)
	addi $t3, $t3, 1		# COUNTER++ for integer place
	j countIntLength
	
	countSame.noRun:		
	add $t3, $t3, $t2		# Add short run into String counter
	li $t2, 0			# Reset RUN COUNTER
	j countSame.new
	
	encodedLength.end:
	addi $t3, $t3, 1	# Add 1 for null character
	move $v0, $t3		# Return 0 for empty
    	jr $ra
	
	encodedLength.null:
	move $v0, $t3		# Return 0 for empty
    	jr $ra      

# PART H #
runLengthEncode:
	# $a0, runLengthEncode_input
    	# $a1, runLengthEncode_output
    	# $a2, runLengthEncode_outputSize
    	# $a3, runLengthEncode_runFlag
    	
    	# CHECK ENOUGH MEMORY #	
    	saveStack
    	move $a0, $a0
    	jal encodedLength
    	restoreStack
    	
    	bgt $v0, $a2, runLengthEncode.fail	# Branch if runLengthEncode_input's length > runLengthEncode_outputSize
    	
    	# CHECK FLAG #
    	lb $t2, 0($a3)	# Load runLengthEncode_runFlag
    	
    	li $t0, 33
    	beq $t2, $t0, section1
    	
    	li $t0, 35
    	beq $t2, $t0, section1
    	
    	li $t0, 36
    	beq $t2, $t0, section1
    	
    	li $t0, 37
    	beq $t2, $t0, section1
    	
    	li $t0, 38
    	beq $t2, $t0, section1
    	
    	li $t0, 42
    	beq $t2, $t0, section1
    	
    	li $t0, 64
    	beq $t2, $t0, section1
    	
    	li $t0, 94
    	beq $t2, $t0, section1
    	
    	j runLengthEncode.fail
    	# ------------------------------------------ #
    	
    	section1:
    		lb $t0, 0($a0)	# Comparison char
    		beqz $t0, runLengthEncode.end
    		li $t1, 0	# RUN COUNTER
    		
    	section2:
    		lb $t2, 0($a0)	# Pointer
    		bne $t0, $t2, runLengthEncode.buildString	# Encode section of same chars
    		addi $a0, $a0, 1	# Advance pointer right
    		addi $t1, $t1, 1	# RUN COUNTER++
    		j section2
    	
    	runLengthEncode.buildString:
    		# Preserve in $t5-9
    		move $t5, $a0
    		move $t6, $a1
    		move $t7, $a2
    		move $t8, $a3
    		move $t9, $ra
    		
    		# Do Encode Run
    		addi $a0, $a0, -1	# $a0, encodeRun_letter address
    		move $a2, $a1		# $a2, encodeRun_output address
    		
    		move $a1, $t1		# $a1, encodeRun_runLength int
    		
    		move $a3, $a3		# $a3, encodeRun_runFlag address
    		jal encodeRun
    		
    		# Restore from $t5-9
    		move $a0, $t5
    		move $a1, $t6
    		move $a2, $t7
    		move $a3, $t8
    		move $ra, $t9
    		
    		move $a1, $v0	# Advance to unprocessed part
    		j section1
    		
    	runLengthEncode.end:
    		# Add a null char
    		li $t0, 0
    		sb $t0, ($a1)
    		
    		li $v0, 1	
    		jr $ra	
    	runLengthEncode.fail:
    		li $v0, 0	# 0 for fail
    		jr $ra
    
.data 
.align 2
