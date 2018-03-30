#################################################################
# HW#4 Part 2: Testing Main for helper functions
#################################################################
.text
.globl main

main:
	#################################################################
	# linear_search
	#################################################################

	la $a0, flag_array_0
	li $a1, 32 # the entire 32 bits of the flag array are valid
	jal linear_search
	# print return value
	move $a0, $v0
	li $v0, 1
	syscall
	# print newline
	li $v0, 4
	la $a0, endl
	syscall
	la $a0, flag_array_0
	li $a1, 27 # only the first 27 bits of the flag array are valid
	jal linear_search
	# print return value
	move $a0, $v0
	li $v0, 1
	syscall
	# print 2 newlines
	li $v0, 4
	la $a0, endl
	syscall
	syscall

	#################################################################
	# set_flag
	#################################################################

	la $a0, flag_array_size16
	li $a1, 5
	li $a2, 1
	li $a3, 16
	jal set_flag
	# print return value
	move $a0, $v0
	li $v0, 1
	syscall
	# print newline
	li $v0, 4
	la $a0, endl
	syscall
	# print binary
	lbu $a0, flag_array_size16
	li $v0, 35
	syscall
	# print 2 newline
	li $v0, 4
	la $a0, endl
	syscall
	syscall

	#################################################################
	# find_position
	#################################################################
	la $a0, nodes2
	li $a1, 0
	li $a2, 19 # determine where 19 should go in the BST - not a repeat
	jal find_position

	# save return values
	move $s1, $v0
	move $s2, $v1

	# print return value
	move $a0, $s1
	li $v0, 1
	syscall

	# print newline
	li $v0, 4
	la $a0, endl
	syscall

	# print return value
	move $a0, $s2
	li $v0, 1
	syscall

	# print 2 newline
	li $v0, 4
	la $a0, endl
	syscall
	syscall


	la $a0, nodes2
	li $a1, 0
	li $a2, 3 # determine where 3 should go in the BST - repeat
	jal find_position

	# save return values
	move $s1, $v0
	move $s2, $v1

	# print return value
	move $a0, $s1
	li $v0, 1
	syscall

	# print newline
	li $v0, 4
	la $a0, endl
	syscall

	# print return value
	move $a0, $s2
	li $v0, 1
	syscall

	# print 2 newline
	li $v0, 4
	la $a0, endl
	syscall
	syscall

done:
	li $v0, 10
	syscall

#################################################################
# PART 2 Testing BSTs
#################################################################
.data
endl: .asciiz "\n"

.align 2

nodes2: .word 0x01060008 0x02030003 0xFFFF0001 0x04050006 0xFFFF0004 0xFFFF0007 0xFF07000A 0x08FF000E 0xFFFF000D #root 0, sample tree

# Additional testing cases
nodes1: .word 0xFFFF0001 # root node with 0 children - root 0
nodes3: .word 0x01FF0001 0xFFFF0002 # root node with 1 left child - root 0
nodes4: .word 0xFF010001 0xFFFF0003 # root node with 1 right child - root 0
nodes5: .word 0xFF030001 0xFFFF000F 0xFF010007 0xFF020003 # completely unbalanced tree - linked list to right (with nodes mixed up) - root 0
nodes6: .word 0x02FF0001 0x03FF0004 0x01FF0002 0xFFFF0008 # completely unbalanced tree - linked list to left (with nodes mixed up) - root 0
nodes7: .word 0x01060008 0x0203FFFD 0xFFFF0001 0x0405FFFA 0xFFFF0004 0xFFFFFFF9 0xFF07000A 0x08FFFFF2 0xFFFF000D # sample tree w/ negative nodes - root 0
nodes8: .word 0xFFFF0004 0x02030003 0xFFFF0001 0x00050006 0x01060008 0xFFFF0007 0xFF07000A 0x08FF000E 0xFFFF000D # sample tree - root 4


.align 2
alloc_size: .word 255 #maxSize of alloc_mem
to_byte_bound1: .space 1 # flag arrays pushed off word boundary
#GUARANTEED BYTE BOUNDARY, NOT WORD BOUNDARY, FOR FLAG ARRAYS
alloc_mem_flag_array: .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		    	    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		    	    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		    	    0, 0	# 8 words = 32 bytes = 256 bits (1 bit not needed at end)

flag_array_0: .byte 0xFF, 0xFF, 0xFF, 0x3F
flag_array_size16: .byte 0x82, 0x44

#################################################################
# Student defined functions will be included starting here
#################################################################

.include "hw4.asm"
