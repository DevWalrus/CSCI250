# File:		add_ascii_numbers.asm
# Author:	K. Reek
# Contributors:	P. White, W. Carithers
#		Clinten Hopkins
#
# Updates:
#		3/2004	M. Reek, named constants
#		10/2007 W. Carithers, alignment
#		09/2009 W. Carithers, separate assembly
#
# Description:	Add two ASCII numbers and store the result in ASCII.
#
# Arguments:	a0: address of parameter block.  The block consists of
#		four words that contain (in this order):
#
#			address of first input string
#			address of second input string
#			address where result should be stored
#			length of the strings and result buffer
#
#		(There is actually other data after this in the
#		parameter block, but it is not relevant to this routine.)
#
# Returns:	The result of the addition, in the buffer specified by
#		the parameter block.
#

.align 2
.data
newline:
    .ascii "\n"
.text
	.globl	add_ascii_numbers

add_ascii_numbers:
A_FRAMESIZE = 40

#
# Save registers ra and s0 - s7 on the stack.
#
	addi 	$sp, $sp, -A_FRAMESIZE
	sw 	$ra, -4+A_FRAMESIZE($sp)
	sw 	$s7, 28($sp)
	sw 	$s6, 24($sp)
	sw 	$s5, 20($sp)
	sw 	$s4, 16($sp)
	sw 	$s3, 12($sp)
	sw 	$s2, 8($sp)
	sw 	$s1, 4($sp)
	sw 	$s0, 0($sp)
	
# ##### BEGIN STUDENT CODE BLOCK 1 #####
    
    move    $t0, $a0    # store the address of the param block in t0
    lw  $s1, 0($t0)     # load the address (not data) of input str 1 into s1
    lw  $s2, 4($t0)     # load the address of the input 2 into s2
    lw  $s3, 8($t0)     # load the address to store the result into s3
    lw  $s4, 12($t0)    # load the len of the strings into s4

    li  $t9, 1          # t9 will be a carry boolean
    li  $s5, 0          # s5 will act as a counter

str_ele_loop:
    beq $s5, $s4, done  # if the counter == len of the str, goto done
    sub $s6, $s4, $s5   # offset = len - counter
    li  $t3, 1
    sub $s6, $s6, $t3   # offset -= 1 (converting to index of str)
    add $t3, $s1, $s6   # set t3 to be the address of s1 + offset
    add $t4, $s2, $s6   # set t4 to be the address of s2 + offset

    li $t8, 48

    lb  $t3, 0($t3)     # store the str rep. of s1 in t3
    sub $t3, $t3, $t8   # store the num. rep. of the s1 letter in t3

    lb  $t4, 0($t4)     # store the str rep. of s2 in t4
    sub $t4, $t4, $t8   # store the num. rep. of the s2 letter in t4

    bne $t9, $zero, create_sum  # if t9 == 0, add 1 (the carry)
    addi    $t4, $t4, 1

create_sum:
    add $t5, $t3, $t4   # store the sum in t5 (w/ carry)

    slti    $t9, $t5, 10    # if t5 < 10 => t9 = 1

    bne $t9, $zero, save_digit  # if t5 >= 10
    li  $t3, 10
    sub $t5, $t5, $t3   # sum = sum - 10

save_digit:
    add $t6, $s3, $s6   # t6 = address of storage + offset
    addi    $t5, $t5, 48    # add ascii back to sum
    sb  $t5, 0($t6)     # store the ascii
    
    addi    $s5, $s5, 1 # increment the counter
    j str_ele_loop

done:

# ###### END STUDENT CODE BLOCK 1 ######

#
# Restore registers ra and s0 - s7 from the stack.
#
	lw 	$ra, -4+A_FRAMESIZE($sp)
	lw 	$s7, 28($sp)
	lw 	$s6, 24($sp)
	lw 	$s5, 20($sp)
	lw 	$s4, 16($sp)
	lw 	$s3, 12($sp)
	lw 	$s2, 8($sp)
	lw 	$s1, 4($sp)
	lw 	$s0, 0($sp)
	addi 	$sp, $sp, A_FRAMESIZE

	jr	$ra			# Return to the caller.
