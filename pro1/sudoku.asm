# Filename: sudoku.asm
# Author: C.Hopkins
#
# Description: A Sudoku solver using a brute force (#####) algorithm. 
#
# Revisions: $Log$

STACKFRAME_8 = 8

    .data
    .align 2
banner_str:
    .ascii  "\n**************\n"
    .ascii  "**  SUDOKU  **\n"
    .asciiz "**************\n\n"

    #.align 2 # might not be needed
initial_str:
    .asciiz "Initial Puzzle\n\n"

final_str:
    .asciiz "Final Puzzle\n\n"

impossible_str:
    .asciiz "Impossible Puzzle\n"

    .align  2

initial_board:
    .space  36    # 36 bytes for the board values

    .text
    .align  2

    .globl  main
    .globl  read_board
    .globl  print_board
    .globl  solve_board

main:
    addi    $sp, $sp, STACKFRAME_8
    sw  $ra, 0($sp)
    sw  $s0, 4($sp)

    li  $v0, 4
    la  $a0, banner_str
    syscall

    la  $a0, initial_board
    jal read_board
    move    $s0, $v0

    li  $v0, 4
    la  $a0, initial_str
    syscall

    la  $a0, initial_board
    jal print_board

    beq $s0, $zero, impossible
    
    la  $a0, initial_board
    jal solve_board
    move    $t0, $v0

    beq $t0, $zero, impossible

    li  $v0, 4
    la  $a0, final_str
    syscall
    la  $a0, initial_board
    jal print_board
    j   completed

impossible:
    li  $v0, 4
    la  $a0, impossible_str
    syscall
    
completed:
    lw  $ra, 0($sp)
    lw  $s0, 4($sp)
    addi    $sp, $sp, -STACKFRAME_8
    
    jr  $ra


