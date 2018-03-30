##############################################################
# Do NOT place any functions in this file!
# This file is NOT part of your homework 2 submission.
#
# Modify this file or create new files to test your functions.
##############################################################

.data
str_input: .asciiz "Input: "
str_result: .asciiz "Result: "
str_return: .asciiz "Return: "

# atoui
atoui_header: .asciiz "\n\n********* atoui *********\n"
atoui_input: .ascii "42355asdgfasdg"

# uitoa
uitoa_header: .asciiz "\n\n********* uitoa *********\n"
.align 2
uitoa_value: .word 987654321
uitoa_output: .asciiz "jeA8SAsd9123aslas"
.align 2
uitoa_outputSize: .word 10

# decodedLength
decodedLength_header: .asciiz "\n\n********* decodedLength *********\n"
decodedLength_input: .asciiz "sss!j4q!F5" # Should return 14
decodedLength_runFlag: .ascii "!"

# decodeRun
decodeRun_header: .asciiz "\n\n********* decodeRun *********\n"
decodeRun_letter: .ascii "i"
.align 2
decodeRun_runLength: .word 10
decodeRun_output: .asciiz "asd9u2j,as,j213se!"


# runLengthDecode
runLengthDecode_header: .asciiz "\n\n********* runLengthDecode *********\n"
runLengthDecode_input: .asciiz "sss!j10q!F5" # Length = 19 + 1 null
runLengthDecode_output: .asciiz "jhjkhasd987(!@q2j312kja214asasHJU!#Kasjd21"
.align 2
runLengthDecode_outputSize: .word 20
runLengthDecode_runFlag: .ascii "!"

# encodedLength
encodedLength_header: .asciiz "\n\n********* encodedLength *********\n"
encodedLength_input: .asciiz "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAababab" # Length = 16 + 1 null 

# encodeRun
encodeRun_header: .asciiz "\n\n********* encodeRun *********\n"
encodeRun_letter: .ascii "A"
.align 2
encodeRun_runLength: .word 5
encodeRun_output: .asciiz "JASDo823das[23]4[d!!13qdfas21qdqewsf[aes234[faeasdfaaa113"
encodeRun_runFlag: .ascii "!"

# runLengthEncode
runLengthEncode_header: .asciiz "\n\n********* runLengthEncode *********\n"
runLengthEncode_input: .asciiz "sssjjjjqFFFFF"
runLengthEncode_output: .asciiz "f78raewkuiO*A&*(QAWE2qp8947kjdfs244"
.align 2
runLengthEncode_outputSize: .word 13
runLengthEncode_runFlag: .ascii "!"

# Constants
.eqv QUIT 10
.eqv PRINT_STRING 4
.eqv PRINT_INT 1
.eqv NULL 0x0

.macro print_string(%address)
    li $v0, PRINT_STRING
    la $a0, %address
    syscall
.end_macro

.macro print_string_reg(%reg)
    li $v0, PRINT_STRING
    la $a0, 0(%reg)
    syscall
.end_macro

.macro print_newline
    li $v0, 11
    li $a0, '\n'
    syscall
.end_macro

.macro print_space
    li $v0, 11
    li $a0, ' '
    syscall
.end_macro

.macro print_int(%register)
    li $v0, 1
    add $a0, $zero, %register
    syscall
.end_macro

.macro print_char_addr(%address)
    li $v0, 11
    lb $a0, %address
    syscall
.end_macro

.macro print_char_reg(%reg)
    li $v0, 11
    move $a0, %reg
    syscall
.end_macro

.text
.globl main

main:

    ############################################
    # TEST CASE for atoui
    ############################################
    print_string(atoui_header)
    la $a0, atoui_input
    jal atoui

    move $t0, $v0
    print_string(str_return)
    print_int($t0)
    print_newline

    ############################################
    # TEST CASE for uitoa
    ############################################
    print_string(uitoa_header)
    lw $a0, uitoa_value
    la $a1, uitoa_output
    lw $a2, uitoa_outputSize
    jal uitoa

    move $t0, $v0
    move $t1, $v1

    print_string(str_return)
    print_string_reg($t0)   # will cause a crash until uitoa is implemented
    print_newline
    print_string(str_return)
    print_int($t1)
    print_newline

    ############################################
    # TEST CASE for decodedLength
    ############################################
    print_string(decodedLength_header)
    la $a0, decodedLength_input
    la $a1, decodedLength_runFlag
    jal decodedLength

    move $t0, $v0
    print_string(str_return)
    print_int($t0)
    print_newline()

    ############################################
    # TEST CASE for decodeRun
    ############################################
    print_string(decodeRun_header)
    la $a0, decodeRun_letter
    lw $a1, decodeRun_runLength
    la $a2, decodeRun_output
    move $s0, $a2 # make copy of memory address so we can print the string after function returns
    jal decodeRun

    # since $v0 points to an unprocessed part of output[] there is no sense in printing it
    move $t1, $v1

    print_string(str_return)
    print_int($t1)
    print_newline()
    
    

    print_string(str_result)
    print_string_reg($s0)
    print_newline()

    ############################################
    # TEST CASE for runLengthDecode
    ############################################
    print_string(runLengthDecode_header)
    la $a0, runLengthDecode_input
    la $a1, runLengthDecode_output
    lw $a2, runLengthDecode_outputSize
    la $a3, runLengthDecode_runFlag
    move $s0, $a1  # make copy of memory address so we can print the string after function returns
    jal runLengthDecode

    move $t0, $v0

    print_string(str_return)
    print_int($t0)
    print_newline()
    print_string(str_result)
    print_string_reg($s0)
    print_newline()

    ############################################
    # TEST CASE for encodedLength
    ############################################
    print_string(encodedLength_header)
    la $a0, encodedLength_input
    jal encodedLength

    move $t0, $v0
    print_string(str_return)
    print_int($t0)
    print_newline()

    ############################################
    # TEST CASE for encodeRun
    ############################################
    print_string(encodeRun_header)
    la $a0, encodeRun_letter
    lw $a1, encodeRun_runLength
    la $a2, encodeRun_output
    la $a3, encodeRun_runFlag
    move $s0, $a2  # make copy of memory address so we can print the string after function returns
    jal encodeRun

    move $t1, $v1
    print_string(str_return)
    print_int($t1)
    print_newline()
    print_string(str_result)
    print_string_reg($s0)
    print_newline()

    ############################################
    # TEST CASE for runLengthEncode
    ############################################
    print_string(runLengthEncode_header)
    la $a0, runLengthEncode_input
    la $a1, runLengthEncode_output
    lw $a2, runLengthEncode_outputSize
    la $a3, runLengthEncode_runFlag
    move $s0, $a1  # make copy of memory address so we can print the string after function returns
    jal runLengthEncode

    move $t1, $v0

    print_string(str_return)
    print_int($t1)
    print_newline()
    print_string(str_result)
    print_string_reg($s0)
    print_newline()
   
    # Exit main
    li $v0, QUIT
    syscall

#################################################################
# Student-defined functions will be included starting here
#################################################################

.include "hw2.asm"
