# Filename: utils.asm
# Author: C.Hopkins
#
# Description:  A library of utilities functions to process and output sudoku
#               boards.
#
# Revisions: $Log$

STACKFRAME_8 =  8
STACKFRAME_16 = 16
STACKFRAME_24 = 24
STACKFRAME_36 = 36
BOARD_SIZE =    6
TOTAL_CELLS =   36

    .data
    .align 2

row_delim_str:
    .asciiz "+-----+-----+\n"

col_delim:
    .asciiz "|"

space:
    .asciiz " "

new_line:
    .asciiz "\n"

invalid_input_str:
    .asciiz "ERROR: bad input value, Sudoku terminating\n"

    .text
    .align  2

#
# Name: read_board
#
# Description:  Takes in an address to save a board to and reads in 36 ints
#               saving them as bytes to the address.
#
# Arguments:    a0: addr of the space for the board (at least 36 bytes)
#
# Returns:  none
#

    .globl  is_safe
    .globl  read_board

read_board:
    addi    $sp, $sp, -STACKFRAME_24
    sw  $ra, 0($sp)
    sw  $s0, 4($sp)
    sw  $s1, 8($sp)
    sw  $s2, 12($sp)
    sw  $s3, 16($sp)
    
    move    $s0, $a0    # s0 = pointer to board
    
    li  $s1, 0  # counter
    li  $s3, 1  # valid board

read_loop:
    slti    $t1, $s1, TOTAL_CELLS
    beq $t1, $zero, read_done
    li  $v0, 5
    syscall
    move    $s2, $v0

    slti    $t4, $s2, 7             # test if num out of range
    beq $t4, $zero, invalid_input
    slti    $t4, $s2, 0
    bne $t4, $zero, invalid_input

    beq $s2, $zero, post_check
    
    addi    $sp, $sp, -4
    sw  $s2, 0($sp)

    move    $a0, $s0
    div $a1, $s1, BOARD_SIZE
    rem $a2, $s1, BOARD_SIZE
    jal is_safe
    addi    $sp, $sp, 4
    move    $t4, $v0
    bne $t4, $zero, post_check
    li  $s3, 0

post_check:
    add $t2, $s1, $s0
    sb  $s2, 0($t2)
    addi    $s1, $s1, 1
    j   read_loop

read_done:

    move    $v0, $s3

    lw  $ra, 0($sp)
    lw  $s0, 4($sp)
    lw  $s1, 8($sp)
    lw  $s2, 12($sp)
    lw  $s3, 16($sp)
    addi    $sp, $sp, STACKFRAME_24
    jr  $ra

invalid_input:
    la  $a0, invalid_input_str
    li  $v0, 4
    syscall
    li  $v0, 17
    li  $a0, -1
    syscall

#
# Name: print_board
#
# Description:  Takes in an pointer to a board to and prints out the board
#               in the format given in the write up. The format looks like:
#
#               +-----+-----+
#               |x x x|x x x|
#               |x x x|x x x|
#               +-----+-----+
#               |x x x|x x x|
#               |x x x|x x x|
#               +-----+-----+
#               |x x x|x x x|
#               |x x x|x x x|
#               +-----+-----+
#               
#               The x's will be replaced with numbers if the value is between
#               1 and 6 (the valid values of the board) or a space if 0 (the
#               value denoting a space to solve.
#
# Arguments:    a0: pointer to a board (36 bytes in size)
#
# Returns:  none
#

    .globl print_board

print_board:
    addi    $sp, $sp, -STACKFRAME_36
    sw  $ra, 0($sp)
    sw  $s0, 4($sp)
    sw  $s1, 8($sp)
    sw  $s2, 12($sp)
    sw  $s3, 16($sp)
    sw  $s4, 20($sp)
    sw  $s5, 24($sp)
    sw  $s6, 28($sp)
    sw  $s7, 32($sp)
    
    move    $s0, $a0        # store the pointer in s0

    li  $s6, BOARD_SIZE # 6 rows per board
    li  $s4, 2          # every 2 rows add a row delim
    li  $s3, 3          # every 3 cells change a space to a col delim

print_loop:
    
    li  $s5, 0
row_loop:
    beq $s5, $s6, row_loop_done # if row count == 6, finalize board
    rem $t0, $s5, $s4           # t0 = counter % 2
    bne $t0, $zero, no_row_delim    # if counter % 2 == 0, print row delim
    li  $v0, 4          
    la  $a0, row_delim_str
    syscall                 # print row delim
    
no_row_delim:

    li  $s1, 0  # cell loop counter

cell_loop:
    beq $s1, $s6, cell_loop_done    # if cell count == 6, start next row
    rem $t0, $s1, $s3           # t0 = counter % 3
    beq $t0, $zero, print_bar   # if counter % 3 == 0, print "|" instead of " "
    li  $v0, 4                  
    la  $a0, space
    syscall                     # print " "
    j   print_cell

print_bar: 
    li  $v0, 4
    la  $a0, col_delim
    syscall                     # print "|"

print_cell:
    lb  $a0, 0($s0)     # load next cell
    addi $s0, $s0, 1    # move to next cell for next read
    
    beq $a0, $zero, print_no_num    #if value == 0 print " " instead
    li  $v0, 1
    syscall             # print " "
    j   done_printing_cell

print_no_num:
    li  $v0, 4
    la  $a0, space
    syscall             # print value
    
done_printing_cell:

    addi    $s1, $s1, 1 # inc cell counter
    j   cell_loop       # process next cell

cell_loop_done:
    
    li  $v0, 4
    la  $a0, col_delim
    syscall             # print final "|" for the line
    
    li  $v0, 4
    la  $a0, new_line
    syscall             # print a "\n" to being the next row
    
    addi    $s5, $s5, 1 # inc row counter 
    j   row_loop        # process next row

row_loop_done:
    
    li  $v0, 4
    la  $a0, row_delim_str  # print final row delim (for bottom of board)
    syscall

    li  $v0, 4
    la  $a0, new_line       # print an extra "\n" for formatting
    syscall


print_done:
    lw  $ra, 0($sp)
    lw  $s0, 4($sp)
    lw  $s1, 8($sp)
    lw  $s2, 12($sp)
    lw  $s3, 16($sp)
    lw  $s4, 20($sp)
    lw  $s5, 24($sp)
    lw  $s6, 28($sp)
    lw  $s7, 32($sp)
    addi    $sp, $sp, STACKFRAME_36
    jr  $ra
     
