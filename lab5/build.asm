# File:		build.asm
# Author:	K. Reek
# Contributors:	P. White,
#		W. Carithers,
#		C. Hopkins
#
# Description:	Binary tree building functions.
#
# Revisions:	$Log$


	.text			# this is program code
	.align 2		# instructions must be on word boundaries

# 
# Name:		add_elements
#
# Description:	loops through array of numbers, adding each (in order)
#		to the tree
#
# Arguments:	a0 the address of the array
#   		a1 the number of elements in the array
#		a2 the address of the root pointer
# Returns:	none
#

	.globl	add_elements
	
add_elements:
	addi 	$sp, $sp, -16
	sw 	$ra, 12($sp)
	sw 	$s2, 8($sp)
	sw 	$s1, 4($sp)
	sw 	$s0, 0($sp)

#***** BEGIN STUDENT CODE BLOCK 1 ***************************
#
# Insert your code to iterate through the array, calling build_tree
# for each value in the array.  Remember that build_tree requires
# two parameters:  the address of the variable which contains the
# root pointer for the tree, and the number to be inserted.
#
# Feel free to save extra "S" registers onto the stack if you need
# more for your function.
#

    addi    $sp, $sp, -4
    sw  $s3, 0($sp)

    move    $s3, $a2        # store the addr of the root ptr in s3
    move    $s2, $a0        # store the add of the array in s2
    move    $s1, $a1        # store the num of elemets in s1
    move    $s0, $zero      # create a counter reg (s0)

add_loop_begin:
    beq $s0, $s1, add_real_done # if the counter = num of elements, quit
    
    mul $t0, $s0, 4     # to calculate the addr of the element to grab, mult
    add $t0, $s2, $t0   # the counter by 4 add add it to the addr of the array
    lw  $t1, 0($t0)     # grab the element at that new addr
    
    move    $a1, $t1       # move the value of the element into t1
    move    $a0, $s3       # a0 = a pointer to the addr of the root node
    jal build_tree      # call build tree with the current element

    addi    $s0, $s0, 1 # increment the counter
    j   add_loop_begin    # loop
    

#
# If you saved extra "S" reg to stack, make sure you restore them
#
add_real_done:
    lw  $s3, 0($sp)
    addi    $sp, $sp, 4
#***** END STUDENT CODE BLOCK 1 *****************************

add_done:

	lw 	$ra, 12($sp)
	lw 	$s2, 8($sp)
	lw 	$s1, 4($sp)
	lw 	$s0, 0($sp)
	addi 	$sp, $sp, 16
	jr 	$ra

#***** BEGIN STUDENT CODE BLOCK 2 ***************************

# 
# Name:		build_tree
#
# Description:	adds an element to the tree
#
# Arguments:	a0 the address of the root pointer
#   		    a1 element to add to the tree
# Returns:	none
#

    .globl build_tree
    .globl allocate_mem

build_tree:

	addi 	$sp, $sp, -20
	sw 	$ra, 16($sp)
    sw  $s3, 12($sp)
	sw 	$s2, 8($sp)
	sw 	$s1, 4($sp)
	sw 	$s0, 0($sp)

    move    $s2, $a0    # t0 holds the pointer to the root node
    move    $s3, $a1    # s3 holds the value of the new node
    lw  $s1, 0($s2)     # s1 holds the addr of the root node

    li  $a0, 3          
    jal allocate_mem    # allocate 3 words
    move    $s0, $v0    # s0 holds the pointer to the new node

    sw  $s3, 0($s0)     # set the value into the node
    sw  $zero, 4($s0)   # set the left child to NULL
    sw  $zero, 8($s0)   # set the right child to NULL

    bne $s1, $zero, insert_ele_norm     # if s1 == 0 (new tree)
    sw  $s0, 0($s2)                     # make this node the root
    j   build_tree_done                 # cleanup + return
    

insert_ele_norm:                        # else, insert the node normally
    move    $t0, $s1    # t0 holds the addr of the node we are looking at
    move    $t1, $zero  # t1 hold the parent of the current node (init NULL)

build_tree_loop:
    move    $t1, $t0                    # parent = current
    lw  $t2, 0($t1)                     # t2 = parent->value
    slt $t3, $s3, $t2                   # t3 == 1 if new_val < parent_val
    bne $t3, $zero, left_side_search    # if t3 == 0, search right side
    
    slt $t3, $t2, $s3                   # t3 == 1 if parent_val < new_val
    bne $t3, $zero, right_side_search   # if t3 == 0, search right side
    
    j   build_tree_done # if they are euqal, just quit, ignoring the mem leak

left_side_search:
    lw  $t0, 4($t1)                 # set current = parent->left_node
    bne $t0, $zero, build_tree_loop # if left_node != null, loop again
    sw  $s0, 4($t1)                 # set parent->left_node = new_node addr
    j   build_tree_done               # cleanup + reutrn

right_side_search:
    lw  $t0, 8($t1)                 # set current = parent->right_node
    bne $t0, $zero, build_tree_loop # if right_node != null, loop again
    sw  $s0, 8($t1)                 # set parent->right_node = new_node addr
    j   build_tree_done               # cleanup + return

build_tree_done:
    lw 	$ra, 16($sp)
    lw  $s3, 12($sp)
	lw 	$s2, 8($sp)
	lw 	$s1, 4($sp)
	lw 	$s0, 0($sp)
	addi 	$sp, $sp, 20
    
    jr  $ra

#***** END STUDENT CODE BLOCK 2 *****************************
