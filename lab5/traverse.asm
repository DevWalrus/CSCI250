# File:		traverse_tree.asm
# Author:	K. Reek
# Contributors:	P. White,
#		W. Carithers,
#		C. Hopkins
#
# Description:	Binary tree traversal functions.
#
# Revisions:	$Log$


# CONSTANTS
#

# traversal codes
PRE_ORDER  = 0
IN_ORDER   = 1
POST_ORDER = 2

	.text			# this is program code
	.align 2		# instructions must be on word boundaries

#***** BEGIN STUDENT CODE BLOCK 3 *****************************

#
# Make sure to add any .globl that you need here
#
    .globl traverse_tree
#
# Put your traverse_tree subroutine here.
# 

    .data
    .align 2
traversal_tbl:  # the table acting as our switch statement, holding the addr's
                # of the different traversal methods
    .word traverse_preorder, traverse_inorder, traverse_postorder

    .text
    .align 2

#
# Name: traverse_tree
#
# Description:  using a selected mode of traversal, process every element in
#               a binary tree
#
# Arguments:    a0: addr of the root node
#               a1: addr of the "visit" function, the function that processed a
#                   node
#               a1: int representing a traversal method
#                   0 - preorder
#                   1 - inorder
#                   2 - postorder
#
# Returns:  none
#

traverse_tree:
    addi    $sp, $sp, -24   # 2 extra areas for arguments if needed
    sw  $ra, 12($sp)
    sw  $s2, 8($sp)
    sw  $s1, 4($sp)
    sw  $s0, 0($sp)

    mul $t0, $a2, 4         # We are basically using a switch statement, so
                            # we mult the input number ( the traversal method )
                            # by 4 to get the location of the traversal to take
    la  $t1, traversal_tbl  # load the tbl addr we are using ( the switch tbl )
    add $t2, $t0, $t1       # t2 = tbl addr + offset determined by input int
    lw  $s0, 0($t2)         # load the addr at that point ( s0 has the addr of
                            # the traversal method's label)
    jalr    $s0             # jump to the traversal method

    lw  $ra, 12($sp)    # restore the s regs and stackframe
    lw  $s2, 8($sp)
    lw  $s1, 4($sp)
    lw  $s0, 0($sp)
    addi    $sp, $sp, 24
    jr  $ra

#
# Name: traverse_preorder
#
# Description:  using a preorder style of traversal, visit all of the nodes and
#               process them using the provided function
#
#               Preorder process:
#                   - Visit the root node
#                   - Visit all the nodes in the left subtree
#                   - Visit all the nodes in the right subtree
#
# Arguments:    a0: addr of the root node
#               a1: addr of the "visit" function, the function that processed a
#                   node
#
# Returns:  none
#

traverse_preorder:
    addi    $sp, $sp, -24   # 2 extra areas for arguments if needed
    sw  $ra, 12($sp)
    sw  $s2, 8($sp)
    sw  $s1, 4($sp)
    sw  $s0, 0($sp)  

    move    $s0, $a0    
    move    $s1, $a1

    beq $s0, $zero, preorder_done   # if root == null, we're done
    
    move    $a0, $s0    # a0 = node to process (print or print & add)
    jalr    $s1         # jump to the processing function

    lw  $a0, 4($s0)         # s0 = addr of the left node
    move    $a1, $s1        # a1 = addr of the processing function
    jal traverse_preorder   # recurse to process the left node
    
    lw  $a0, 8($s0)         # s0 = addr of the right node
    move    $a1, $s1        # a1 = addr of the processing function
    jal traverse_preorder   # recurse to process the right node

preorder_done:
    lw  $ra, 12($sp)
    lw  $s2, 8($sp)
    lw  $s1, 4($sp)
    lw  $s0, 0($sp)
    addi    $sp, $sp, 24
    jr  $ra

#
# Name: traverse_inorder
#
# Description:  using a inorder style of traversal, visit all of the nodes and
#               process them using the provided function
#
#               Inorder process:
#                   - Visit all the nodes in the left subtree
#                   - Visit the root node
#                   - Visit all the nodes in the right subtree
#
# Arguments:    a0: addr of the root node
#               a1: addr of the "visit" function, the function that processed a
#                   node
#
# Returns:  none
#

traverse_inorder:
    addi    $sp, $sp, -24   # 2 extra areas for arguments if needed
    sw  $ra, 12($sp)
    sw  $s2, 8($sp)
    sw  $s1, 4($sp)
    sw  $s0, 0($sp)  

    move    $s0, $a0
    move    $s1, $a1

    beq $s0, $zero, inorder_done    # if root == null, we're done
    
    lw  $a0, 4($s0)         # s0 = addr of the left node
    move    $a1, $s1        # a1 = addr of the processing function
    jal traverse_inorder    # recurse to process the left node
    
    move    $a0, $s0    # a0 = node to process (print or print & add)
    jalr    $s1         # jump to the processing function

    lw  $a0, 8($s0)         # s0 = addr of the right node
    move    $a1, $s1        # a1 = addr of the processing function
    jal traverse_inorder    # recurse to process the right node

inorder_done:
    lw  $ra, 12($sp)
    lw  $s2, 8($sp)
    lw  $s1, 4($sp)
    lw  $s0, 0($sp)
    addi    $sp, $sp, 24
    jr  $ra

#
# Name: traverse_postorder
#
# Description:  using a postorder style of traversal, visit all of the nodes and
#               process them using the provided function
#
#               Postorder process:
#                   - Visit all the nodes in the left subtree
#                   - Visit the root node
#                   - Visit all the nodes in the right subtree
#
# Arguments:    a0: addr of the root node
#               a1: addr of the "visit" function, the function that processed a
#                   node
#
# Returns:  none
#

traverse_postorder:
    addi    $sp, $sp, -24   # 2 extra areas for arguments if needed
    sw  $ra, 12($sp)
    sw  $s2, 8($sp)
    sw  $s1, 4($sp)
    sw  $s0, 0($sp)  

    move    $s0, $a0
    move    $s1, $a1

    beq $s0, $zero, postorder_done  # if root == null, we're done
    
    lw  $a0, 4($s0)         # s0 = addr of the left node
    move    $a1, $s1        # a1 = addr of the processing function
    jal traverse_postorder  # recurse to process the left node
    
    lw  $a0, 8($s0)         # s0 = addr of the right node
    move    $a1, $s1        # a1 = addr of the processing function
    jal traverse_postorder  # recurse to process the right node

    move    $a0, $s0    # a0 = node to process (print or print & add)
    jalr    $s1         # jump to the processing function

postorder_done:
    lw  $ra, 12($sp)
    lw  $s2, 8($sp)
    lw  $ra, 12($sp)
    lw  $s2, 8($sp)
    lw  $s1, 4($sp)
    lw  $s0, 0($sp)
    addi    $sp, $sp, 24
    jr  $ra

#***** END STUDENT CODE BLOCK 3 *****************************
