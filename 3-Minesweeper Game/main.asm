.data

input_message: .asciiz "w - up\na - left\ns - down\nd - right\nr - reveal\nf - flag\nEnter your action: "
file_error: .asciiz "The file provided is either missing or in an invalid format."
invalid_action: .asciiz "The action performed is invalid."

user_input: .space 1

.align 3
filename: .space 4
cells_array2: .space 100

.text

# Helper macro for grabbing command line arguments
.macro load_args
	lw	$t0,	0($a1)
	sw	$t0,	filename
.end_macro

.globl main

main:
	# store the filename given on the command line
	load_args()

	# open the file we stored
	lw	$a0,	filename
	jal	open_file
	# save the file descriptor that was returned
	move	$s0,	$v0
	bltz	$s0,	invalid_file_error

	# load the map from the file we opened
	move	$a0,	$s0
	la	$a1,	cells_array2
	jal	load_map
	bltz	$v0,	invalid_file_error

	# close the file
	move	$a0,	$s0
	jal	close_file

	# set the display to all covered and init the cursor
	jal	init_display

	while_game:
		# prompt player for input
		la	$a0,	input_message
		li	$v0,	4
		syscall

		# get next character from the command line
		li	$v0,	12
		sb	$v0,	user_input
		syscall

		#perform_action based on user input
		move	$a1,	$v0
		la	$a0,	cells_array2
		jal	perform_action
		beqz	$v0,	continue

		# inform the user they have selected an invalid action
		la	$a0,	invalid_action
		li	$v0,	4
		syscall

		# since we got bad input, jump back to prompt them again
		j	while_game

		continue:

		# the user successfully performed an action, so check game status
		la	$a0,	cells_array2
		jal	game_status

		# the game is ongoing, jump back to prompt for next action
		beqz	$v0,	while_game

	# call reveal_map because the game was won or lost
	# v0 still has the return from game_status
	move	$a0,	$v0
	la	$a1,	cells_array2
	jal	reveal_map

	j	exit

	invalid_file_error:
	# inform the user the file was bad (nonexistant, malformed, etc.)
	la	$a0,	file_error
	li	$v0,	4
	syscall

	exit:
	li	$v0,	10
	syscall

.include "hw3.asm"
