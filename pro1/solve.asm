# Filename: sovle.asm
# Author: C.Hopkins
#
# Description:  An implementation of a backtracting algorithm to solve a 6x6
#               sudoku puzzle
#
# Revisions: $Log$

STACKFRAME_8 =  8
STACKFRAME_16 = 16
STACKFRAME_24 = 24
STACKFRAME_36 = 36
BOARD_SIZE =    6
TOTAL_CELLS =   36

UNASSIGNED =    0

BOX_WIDTH = 3
BOX_HEIGHT =    2

    .globl  solve_board
    .globl  print_board

solve_board:
    addi    $sp, $sp, -STACKFRAME_24
    sw  $ra, 0($sp)
    sw  $s0, 4($sp)
    sw  $s1, 8($sp)
    sw  $s2, 12($sp)
    sw  $s3, 16($sp)
    sw  $s4, 20($sp)

    move    $s0, $a0
    li  $s1, 0  # row
    li  $s2, 0  # col

    move    $a0, $s0
    move    $a1, $s1
    move    $a2, $s2
    jal find_unassigned_loc
    move    $s1, $a1
    move    $s2, $a2
    move    $t0, $v0

    bne $t0, $zero, solve_found_unna
    li  $v0, 1
    j   solve_done

solve_found_unna:

    li  $s3, 1

solve_counter_loop:
    slti    $t0, $s3, 7
    beq $t0, $zero, solve_failed
    addi    $sp, $sp, -4
    sw  $s3, 0($sp)          # num we are on is the first thing in the stack
    move    $a0, $s0
    move    $a1, $s1
    move    $a2, $s2
    jal is_safe
    addi    $sp, $sp, 4

    move    $t0, $v0
    beq $t0, $zero, solve_next_num
    
    mul $t0, $s1, BOARD_SIZE
    add $t0, $t0, $s2
    add $t0, $t0, $s0
    sb  $s3, 0($t0)

    move    $a0, $s0
    jal solve_board
    beq $v0, $zero, not_correct_path
    j   solve_done   

not_correct_path:
    mul $t0, $s1, BOARD_SIZE
    add $t0, $t0, $s2
    add $t0, $t0, $s0
    li  $t1, UNASSIGNED
    sb  $t1, 0($t0)

solve_next_num:
    addi    $s3, $s3, 1
    j   solve_counter_loop

solve_failed:
    li  $v0, 0

solve_done:
    lw  $ra, 0($sp)
    lw  $s0, 4($sp)
    lw  $s1, 8($sp) 
    lw  $s2, 12($sp)
    lw  $s3, 16($sp)
    lw  $s4, 20($sp)
    addi    $sp, $sp, STACKFRAME_24
    jr  $ra

find_unassigned_loc:
    addi    $sp, $sp, -STACKFRAME_16
    sw  $ra, 0($sp)
    sw  $s0, 4($sp)
    sw  $s1, 8($sp)
    
    move    $s0, $a0

ful_row_loop:

    li  $t0, BOARD_SIZE
    beq $a1, $t0, ful_row_done
    li  $a2, 0

ful_col_loop:
    
    li  $t0, BOARD_SIZE
    beq $a2, $t0, ful_col_done
    mul $t0, $a1, BOARD_SIZE
    add $t0, $t0, $a2
    add $t0, $t0, $s0
    lb  $t1, 0($t0)
    li  $t2, UNASSIGNED
    bne $t1, $t2, ful_already_assigned
    j   ful_done

ful_already_assigned:

    addi    $a2, $a2, 1
    j   ful_col_loop

ful_col_done:
    
    addi    $a1, $a1, 1
    j   ful_row_loop

ful_row_done:
    li  $v0, 0

ful_done:
    
    lw  $ra, 0($sp)
    lw  $s0, 4($sp)
    lw  $s1, 8($sp)
    addi    $sp, $sp, STACKFRAME_16
    jr  $ra

    .globl is_safe

is_safe:
    addi    $sp, $sp, -STACKFRAME_24
    sw  $ra, 0($sp)
    sw  $s0, 4($sp)
    sw  $s1, 8($sp)
    sw  $s2, 12($sp)
    sw  $s3, 16($sp)
    sw  $s4, 20($sp)
    
    move    $s0, $a0
    move    $s1, $a1
    move    $s2, $a2
    lw  $s3, STACKFRAME_24($sp)
    
    
    move    $a0, $s0
    move    $a1, $s1
    move    $a2, $s3
    jal used_in_row
   
    beq $v0, $zero, is_not_uir
    li  $v0, 0
    j   is_safe_done

is_not_uir:
    move    $a0, $s0
    move    $a1, $s2
    move    $a2, $s3
    jal used_in_col
    beq $v0, $zero, is_not_uic
    li  $v0, 0
    j   is_safe_done

is_not_uic:
    addi    $sp, $sp, -4
    sw  $s3, 0($sp)

    li  $t1, BOX_HEIGHT
    rem $t1, $s1, $t1
    sub $t1, $s1, $t1
    
    li  $t2, BOX_WIDTH
    rem $t2, $s2, $t2
    sub $t2, $s2, $t2

    move    $a0, $s0
    move    $a1, $t1
    move    $a2, $t2
    jal used_in_box
    addi    $sp, $sp, 4
    beq $v0, $zero, is_not_uib
    li  $v0, 0
    j   is_safe_done

is_not_uib:
    mul $t0, $s1, BOARD_SIZE
    add $t0, $t0, $s2
    add $t0, $t0, $s0
    lb  $t1, 0($t0)
   
    li  $t0, UNASSIGNED
    beq $t0, $t1, is_safe_unna
    li  $v0, 0
    j   is_safe_done

is_safe_unna:
    li  $v0, 1
    

is_safe_done:
    lw  $ra, 0($sp)
    lw  $s0, 4($sp)
    lw  $s1, 8($sp) 
    lw  $s2, 12($sp)
    lw  $s3, 16($sp)
    lw  $s4, 20($sp)
    addi    $sp, $sp, STACKFRAME_24
    jr  $ra

used_in_row:
    addi    $sp, $sp, -STACKFRAME_16
    sw  $ra, 0($sp)
    sw  $s0, 4($sp)
    sw  $s1, 8($sp)

    li  $s0, 0
    move    $s1, $a0
uir_loop:
    slti    $t0, $s0, BOARD_SIZE
    beq $t0, $zero, uir_not_found
    mul $t0, $a1, BOARD_SIZE
    add $t0, $t0, $s0
    add $t0, $t0, $s1
    lb  $t1, 0($t0)

    bne $t1, $a2, uir_not_num
    li  $v0, 1
    j   uir_done

uir_not_num:
    addi    $s0, $s0, 1
    j   uir_loop
    

uir_not_found:
    li  $v0, 0

uir_done:
    lw  $ra, 0($sp)
    lw  $s0, 4($sp)
    lw  $s1, 8($sp)
    addi    $sp, $sp, STACKFRAME_16
    jr  $ra


used_in_col:
    addi    $sp, $sp, -STACKFRAME_16
    sw  $ra, 0($sp)
    sw  $s0, 4($sp)
    sw  $s1, 8($sp)

    li  $s0, 0
    move    $s1, $a0
uic_loop:
    slti    $t0, $s0, BOARD_SIZE
    beq $t0, $zero, uic_not_found
    mul $t0, $s0, BOARD_SIZE
    add $t0, $t0, $a1
    add $t0, $t0, $s1
    lb  $t1, 0($t0)

    bne $t1, $a2, uic_not_num
    li  $v0, 1
    j   uir_done

uic_not_num:
    addi    $s0, $s0, 1
    j   uic_loop

uic_not_found:
    li  $v0, 0

uic_done:
    lw  $ra, 0($sp)
    lw  $s0, 4($sp)
    lw  $s1, 8($sp)
    addi    $sp, $sp, STACKFRAME_16
    jr  $ra

used_in_box:
    addi    $sp, $sp, -STACKFRAME_24
    sw  $ra, 0($sp)
    sw  $s0, 4($sp)
    sw  $s1, 8($sp)
    sw  $s2, 12($sp)
    sw  $s3, 16($sp)
    sw  $s4, 20($sp)
    
    move    $s0, $a0
    lw  $s1, STACKFRAME_24($sp)

    li  $s2, 0
uib_row_loop:
    slti    $t0, $s2, BOX_HEIGHT
    beq $t0, $zero, uib_not_found
    li  $s3, 0
uib_col_loop:
    slti    $t0, $s3, BOX_WIDTH
    beq $t0, $zero, uib_col_done
    
    add $t0, $a1, $s2
    mul $t0, $t0, BOARD_SIZE

    add $t1, $a2, $s3
    add $t1, $t0, $t1

    add $t2, $t1, $s0
    lb  $t2, 0($t2)

    bne $t2, $s1, uib_not_num
    li  $v0, 1
    j   uib_done

uib_not_num:

    addi    $s3, $s3, 1
    j   uib_col_loop

uib_col_done:
    addi    $s2, $s2, 1
    j   uib_row_loop

uib_not_found:
    li  $v0, 0
    
uib_done:
    
    lw  $ra, 0($sp)
    lw  $s0, 4($sp)
    lw  $s1, 8($sp) 
    lw  $s2, 12($sp)
    lw  $s3, 16($sp)
    lw  $s4, 20($sp)
    addi    $sp, $sp, STACKFRAME_24
    jr  $ra

