.text

# Write two's complement number to file as string of characters
    	
    	itof:
    	lhu $t0, 0($a0)		# load node value from bytes 0,1
    	srl $t1, $t0, 15	# check sign bit
    	li $t3, 0		# boolean 0 for positive

    	beqz $t1, itof.countStart	# branch if positive number
    	
    	# Convert negative number
    	
    	xori $t0, $t0, -1	# flip the bits
    	sll $t0, $t0, 16
    	srl $t0, $t0, 16
    	addi $t0, $t0, 1	# add 1
    	li $t3, 1		# boolean 1 for negative
    	
    	# Count how many places in number
    	
    	itof.countStart:
    	li $t2, -1		# place counter
    	itof.count:
    	beqz $t0, itof.countEnd
    	
    	li $t1, 10
    	div $t0, $t1
    	addi $t2, $t2, 1	# counter++
    	
    	mflo $t0		# quotient
	j itof.count
	itof.countEnd:
	
	# Convert number to string
	lh $t0, 0($a0)		# load node value from bytes 0,1
	la $t4, nodeValue	# load string holder 
	add $t4, $t4, $t2
	beqz $t3, itof.convert
	
	itof.convertNeg:
	xori $t0, $t0, -1	# flip the bits
	sll $t0, $t0, 16
    	srl $t0, $t0, 16
    	addi $t0, $t0, 1	# add 1
    	
    	addi $t4, $t4, 1	# make space for negative sign
    	li $t1, 0x2D		# negative sign
    	sb $t1, nodeValue	# store negative sign
    
	itof.convert:
	blt $t2, $0, itof.writeFile
	li $t1, 10
    	div $t0, $t1
    	
    	mflo $t0		# quotient
    	mfhi $t1		# remainder
    	addi $t1, $t1, 0x30	# convert to char
    	
    	sb $t1, ($t4)
    	addi $t4, $t4, -1
    	addi $t2, $t2, -1
    	j itof.convert

    	itof.writeFile:
    	li $v0, 15
    	move $a0, $a2
    	la $a1, nodeValue
    	li $a2, 6
    	syscall
.data
nodes2: .word 0x08FFFFF2
nodeValue: .word 10
