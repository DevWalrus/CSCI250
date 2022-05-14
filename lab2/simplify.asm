# FILE:         $File$
# AUTHOR:       P. White
# CONTRIBUTORS: M. Reek, W. Carithers
# 		C. Hopkins
#
# DESCRIPTION:
#	In this experiment, you will write some code in a pair of 
#	functions that are used to simplify a fraction.
#
# ARGUMENTS:
#       None
#
# INPUT:
#	The numerator and denominator of a fraction
#
# OUTPUT:
#	The fraction in simplified form (ie 210/50 would be simplified
#	to "4 and 1/5")
#
# REVISION HISTORY:
#       Dec  13, 04         - P. White, created program
#

#
# CONSTANT DECLARATIONS
#
PRINT_INT	= 1		# code for syscall to print integer
PRINT_STRING	= 4		# code for syscall to print a string
READ_INT	= 5		# code for syscall to read an int

#
# DATA DECLARATIONS
#
	.data
into_msg:
	.ascii  "\n*************************\n"
	.ascii	  "** Fraction Simplifier **\n"
	.asciiz   "*************************\n\n"
newline:
	.asciiz "\n"
input_error:
	.asciiz "\nError with previous input, try again.\n"
num_string:
	.asciiz "\nEnter the Numerator of the fraction: "
den_string:
	.asciiz "\nEnter the Denominator of the fraction: "
res_string:
	.asciiz "\nThe simplified fraction is: "
and_string:
	.asciiz " and "
div_string:
	.asciiz "/"
#
# MAIN PROGRAM
#
	.text
	.align	2
	.globl	main
main:
        addi    $sp, $sp, -16  	# space for return address/doubleword aligned
        sw      $ra, 12($sp)    # store the ra on the stack
        sw      $s2, 8($sp)
        sw      $s1, 4($sp)
        sw      $s0, 0($sp)

	la	$a0, into_msg
        jal	print_string

ask_for_num:
	la	$a0, num_string
        jal	print_string

	li	$v0, READ_INT
	syscall
	move	$s0, $v0	# s0 will be the numerator

	slti    $t0, $v0, 0
	beq	$t0, $zero, ask_for_den

        la      $a0, input_error
	jal     print_string

	j	ask_for_num

ask_for_den:
	la	$a0, den_string
	jal	print_string

	li	$v0, READ_INT
	syscall
	move	$a1, $v0	# a1 will be the denominator

	slti	$t0, $v0, 1
	beq	$t0, $zero, den_good

        la      $a0, input_error
	jal	print_string

	j	ask_for_den

den_good:
	move	$a0, $s0	# copy the numerator into a0
	jal	simplify

	move	$s0, $v0	# save the numerator
	move	$s1, $v1	# save the denominator
	move	$s2, $t9	# save the integer part
	
        la      $a0, res_string
	jal	print_string

	move	$a0, $s2
	li	$v0, PRINT_INT
	syscall

        la      $a0, and_string
	jal	print_string

        move    $a0, $s0
	li	$v0, PRINT_INT
	syscall

        la      $a0, div_string
	jal	print_string

        move    $a0, $s1
	li	$v0, PRINT_INT
	syscall

        la      $a0, newline
	jal	print_string

        #
        # Now exit the program.
	#
        lw      $ra, 12($sp)	# clean up stack
        lw      $s2, 8($sp)
        lw      $s1, 4($sp)
        lw      $s0, 0($sp)
        addi    $sp, $sp, 16
        jr      $ra

#
# Name:		simplify 
#
# Description:	Simplify a fraction.
#
# Arguments:	a0:	the original numerator
#		a1:	the original denominator
# Returns:	v0:	the simplified numerator
#		v1:	the simplified denominator
#		t9:	the simplified integer part
#
#######################################################################
# 		NOTE: 	this function uses a non-standard return register
#			t9 will contain the integer part of the
#			simplified fraction.  The correct way to do this
#			would be to build a structure with all three 
#			values, but it is to early in the semester for
#			the students to worry about this.
#######################################################################
#
#

simplify:
        addi    $sp, $sp, -40	# allocate stack frame (on doubleword boundary)
        sw      $ra, 32($sp)    # store the ra & s reg's on the stack
        sw      $s7, 28($sp)
        sw      $s6, 24($sp)
        sw      $s5, 20($sp)
        sw      $s4, 16($sp)
        sw      $s3, 12($sp)
        sw      $s2, 8($sp)
        sw      $s1, 4($sp)
        sw      $s0, 0($sp)
	
# ######################################
# ##### BEGIN STUDENT CODE BLOCK 1 #####
        
        move    $s0, $a0        # Store the numerator in s0
        move    $s1, $a1        # Store the denominator in s0
        li      $s2, 0          # Use s2 as the integer part

subtraction_loop:
        slt     $t0, $s0, $s1
        bne     $t0, $zero, subtraction_loop_done
        addi    $s2, $s2, 1
        sub     $s0, $s0, $s1
        j subtraction_loop

subtraction_loop_done:
        beq     $s0, $zero, set_denom_one       # if the num is 0, set the denom to 1
        beq     $s1, $zero, set_num_one         # elif the denom is 0, set the num to 1
        
        move    $a0, $s0        # else use the gcd to calculate the num and denom
        move    $a1, $s1
        jal     find_gcd
        move    $s3, $v0        # Store the GCD in s3
        div     $s0, $s0, $s3   # Div the num by the gcd
        div     $s1, $s1, $s3   # Div the denom by the gcd
        j set_returns_simplify

set_denom_one:
        li $s1, 1
        j set_returns_simplify

set_num_one:
        li $s0, 1

set_returns_simplify:
        move    $v0, $s0        # Store the num in the appropriate v register
        move    $v1, $s1        # Store the denom in the appropriate v register
        move    $t9, $s2        # Store the integer part in the "appropriate" t register
        j simplify_done

# ###### END STUDENT CODE BLOCK 1 ######
# ######################################

simplify_done:
        lw      $ra, 32($sp)    # restore the ra & s reg's from the stack
        lw      $s7, 28($sp)
        lw      $s6, 24($sp)
        lw      $s5, 20($sp)
        lw      $s4, 16($sp)
        lw      $s3, 12($sp)
        lw      $s2, 8($sp)
        lw      $s1, 4($sp)
        lw      $s0, 0($sp)
        addi    $sp, $sp, 40    # clean up stack
	jr	$ra

#
# Name:		find_gcd 
#
# Description:	computes the GCD of the two inputed numbers
# Arguments:  	a0	The first number
#		a1	The second number
# Returns: 	v0	The GCD of a0 and a1.
#

find_gcd:
        addi	$sp, $sp, -40	# allocate stackframe (doubleword aligned)
        sw      $ra, 32($sp)    # store the ra & s reg's on the stack
        sw      $s7, 28($sp)
        sw      $s6, 24($sp)
        sw      $s5, 20($sp)
        sw      $s4, 16($sp)
        sw      $s3, 12($sp)
        sw      $s2, 8($sp)
        sw      $s1, 4($sp)
        sw      $s0, 0($sp)

# ######################################
# ##### BEGIN STUDENT CODE BLOCK 2 #####

        move $s0, $a0           # Store the first number in s0
        move $s1, $a1           # Store the second number in s1

gcd_while_loop:
        beq $s0, $s1, gcd_while_done
        sub $s2, $s0, $s1       # s2 is representing our D variable
        sra $t0, $s2, 31        # Shifting right allows us to set t0 to be the
                                # value 0x0 or 0xfffffff, if its the former we
                                # we know the number is positive, if its the
                                # latter we know its negitive, we need to 
                                # subtract the number from 0
        beq $t0, $zero, positive_num
        sub $s2, $zero, $s2     # s2 now definitly has abs(s0-s1)

positive_num:
        slt $t1, $s1, $s0       # t1 is 1 if s1 < s0
        beq $t1, $zero, set_num_2_to_d  # if s1 >= s0, set s1 (num2) to d
        move $s0, $s2           # Set s0 (num1) to s2 (d)
        j positive_num_done

set_num_2_to_d:
        move $s1, $s2           # Set s1 (num2) to s2 (d)

positive_num_done:
        j gcd_while_loop

gcd_while_done:
        move $v0, $s0           # Store the gcd in the appropriate v register

# ###### END STUDENT CODE BLOCK 2 ######
# ######################################

find_gcd_done:
        lw      $ra, 32($sp)    # restore the ra & s reg's from the stack
        lw      $s7, 28($sp)
        lw      $s6, 24($sp)
        lw      $s5, 20($sp)
        lw      $s4, 16($sp)
        lw      $s3, 12($sp)
        lw      $s2, 8($sp)
        lw      $s1, 4($sp)
        lw      $s0, 0($sp)
        addi    $sp, $sp, 40    # clean up the stack
	jr	$ra

#
# Name;		print_number 
#
# Description:	This routine reads a number then a newline to stdout
# Arguments:	a0:  the number to print
# Returns:	nothing
#
print_number:

        li 	$v0, PRINT_INT
        syscall			#print a0

        la	$a0, newline
        li      $v0, PRINT_STRING
        syscall                 #print a newline

        jr      $ra

#
# Name;		print_string 
#
# Description:	This routine prints out a string pointed to by a0
# Arguments:	a0:  a pointer to the string to print
# Returns:	nothing
#
print_string:

        li 	$v0, PRINT_STRING
        syscall			#print a0

        jr      $ra
