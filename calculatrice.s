################################################################################
## calculatrice.s
################################################################################
##
## Examples (assuming 'Mars4_5.jar' is present in the current directory):
## $ echo -en "10\n+\n10\n\n" java -jar Mars4_5.jar nc calculatrice.s
## $ java -jar Mars4_5.jar nc calculatrice.s <test_001.txt 2>/dev/null
## $ java -jar Mars4_5.jar nc calculatrice.s pa "integer"
## $ java -jar Mars4_5.jar nc calculatrice.s pa "float"
##
################################################################################
##
## Copyright (c) 2019 John Doe <user@server.tld>
## This work is free. It comes without any warranty, to the extent permitted by
## applicable law.You can redistribute it and/or modify it under the terms of
## the Do What The Fuck You Want To Public License, Version 2, as published by
## Sam Hocevar. See http://www.wtfpl.net/ or below for more details.
##
################################################################################
##        DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
##                    Version 2, December 2004
##
## Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>
##
## Everyone is permitted to copy and distribute verbatim or modified
## copies of this license document, and changing it is allowed as long
## as the name is changed.
##
##            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
##   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
##
##  0. You just DO WHAT THE FUCK YOU WANT TO.
################################################################################


################################################################################
# Misc.
################################################################################
#
# I/O
# ===
#
# Input is on stdin, the expected output (and only the expected output) is on
# stdout. The output on stderr does not matter.
#
# Float functions conventions
# ===========================
#
# - Use float registers ($f0, $f1, ..., $f12, $f13, ..., $f31)
# - Place function arguments in $f12, $f13, etc.
# - Place function results in $f0, $f1
# - Double values "take" two registers: use even numbered registers
#   ($f0, $f2, $f4, ..., $f30).
#
# Float <-> integer conversion
# ===========================
#
# Two steps:
# (1) convert into an integer (but the result is stored in a float register!)
# (2) move the converted value into the appropriate register
#
#   # Convert $f12 into an integer and store it in $f13:
#   cvt.w.s $f13, $f12
#   # Move the integer into an integer register:
#   mfc1 $a0 $f13
#
# Use mtc1 and cvt.s.w to reverse the process:
#
#   mtc1 $a0 $f0
#   cvt.s.w $f0 $f0
#
# Misc. recommendations
# =====================
#
# 1. Implement basic integer operations (+, -, /, *) and calculator_integer
# 2. Implement basic floating point operations (+, -, /, *) and calculator_float
#    (Set $v0 to 1 instead of 0 at 'ignore_cli_args' to "manually" switch into
#     float mode)
# 3. Complete handle_cli_args
#
################################################################################
# Data
################################################################################

.data

# Floating point values
fp0: .float 0.0
fp1: .float 1.0
#!

# Characters
#operators: .byte '+' '-' '*' '/'
#!
#les opérations à faire
plus: .byte '+'
minus: .byte '-'
multiplication: .byte '*'
division: .byte '/'
space: .byte ' '
newline: .byte '\n'

#-------------------------------------------------------------------------------
# Strings
#-------------------------------------------------------------------------------

# Misc.
string_space: .asciiz " "
string_newline: .asciiz "\n"
string_output_prefix: .asciiz "> "
string_arg: .asciiz "arg: "
string_calculator: .asciiz "calculator: "

# Cli args
string_integer: .asciiz "integer"
string_float: .asciiz "float"
string_double: .asciiz "double"

# Operations
string_min: .asciiz "min"
string_max: .asciiz "max"
string_pow: .asciiz "pow"
string_abs: .asciiz "abs"

## chaîne de caractère pour le symbole de l'opération
op: .space 8
################################################################################
# Text
################################################################################

.text
.globl __start

__start:

# argc/argv handling
beq $a0 $0 ignore_cli_args
jal handle_cli_args
j calculator_selection

ignore_cli_args:
  li $v0 1

calculator_selection:
  # Calculator
  bne $v0 $0 calculator_select_float
  # $v0 == 0
  calculator_select_integer:
    jal calculator_integer
    j program_exit
  # $v0 != 0
  calculator_select_float:
    jal calculator_float
    j program_exit
  calculator_select_default:
    j program_exit

# Program exit
program_exit:
  li $v0 10
  syscall

################################################################################
# Calculator main
################################################################################

## Integer calculator
##
## Inputs:
## none
##
## Outputs:
## none
calculator_integer:
  subu $sp $sp 32
  sw $ra 0($sp)
  sw $a0 4($sp)
  sw $a1 8($sp)
  sw $a2 12($sp)
  sw $s0 16($sp)
  sw $s1 20($sp)
  sw $s2 24($sp)
  sw $s3 28($sp)

  # Debugging info (integer mode) on stderr
  la $a0 string_calculator
  jal print_string_stderr
  la $a0 string_integer
  jal print_string_stderr
  jal print_newline_stderr

  calculator_integer_start:
    # Very first operand
    jal read_int
    # We save the first arg in $s0
    move $s0 $v0

  # Calculator loop
  calculator_integer_loop:

    # TODO:
    # Read operation
    #! added op for storing the value of the operation sign
    # lire l'opération à faire
	jal read_operation
	
    # Read second operand (if necessary)
    # Compute the result
    # Print the result
    # Loop or exit the program
    
    # stocker dans $t0 le premiere caractère de la chaîne
    # qui contient l'opération à faire
    lb $t0 op
   
   	# avant de comparer le charactère qu'on a stocké en $t0
   	# on va stocker dans un autre registre $t1 les charactères
   	# de chaque opération
   	# et puis on faire le branching vers l'operation qui correspond
   	# si on trouve une égalité
   
    lb $t1 plus
    beq $t0 $t1 faireAddition #!addition  
   			
    lb $t1 minus
    beq $t0 $t1 faireSubstraction #!substraction
    
    lb $t1 multiplication
    beq $t0 $t1 faireMultiplication #!multiplication
    
    lb $t1 division
    beq $t0 $t1 faireDivision #!division
    
    # puisque les opération "max" et "min" ont les deux
    # la lettre 'm' comme premiere caractère
    # on va faire un branching vers min_or_max
    # où on va determiner si l'operation lue est
    # "max" or "min" 
    la $t1 string_max
    lb $t2 0($t1)
    la $t3 string_min
    lb $t4 0($t3)
    beq $t0 $t2 min_or_max
    
    la $t1 string_pow
    lb $t2 0($t1)
    beq $t0 $t2 fairePuissance #!power
    
    la $t1 string_abs
    lb $t2 0($t1)
    beq $t0 $t2 faireAbsolue #! absolute value
    
    # si l'utilisateur va introduire une ligne vide
    # alors on va faire un branch vers program_exit
    # pour arrêter le program
    lb $t1 newline
    beq $t0 $t1 program_exit
    
#!
     # ici on determine en fonction de la deuxieme charactere 
     # s'il s'agit de "max" ou de "min"
     min_or_max:
     	lb $t5 1($a0)
     	lb $t6 1($t1)
     	lb $t7 1($t3)
     	beq $t5 $t6 faireMaximum
     	beq $t5 $t7 faireMinimum
     
     # le même principe pour chaque partie de branch sauf faireAbsolue
     # on met le premier élément dans le registre $a0
     # qui est le premiere d'argument dans la fonction qui sera appellée
     # on lit le deuxième élément de l'opération
     # puis on le met dans le registre $a1, qui est le deuxième argument de la fonction appellée
     # on appelle la fonction qui correspond à l'opération à faire
     # et puis un branch vers calculator_integer_loop_end
     faireAddition:
     	move $a0 $s0
     	li $v0 5
     	syscall
     	move $a1 $v0
     	jal operation_integer_addition
     	b calculator_integer_loop_end
     	
     faireSubstraction:
     	move $a0 $s0 
     	li $v0 5
     	syscall
     	move $a1 $v0
     	jal operation_integer_substraction
     	b calculator_integer_loop_end 
     	
     faireMultiplication:
     	move $a0 $s0
     	li $v0 5
     	syscall
     	move $a1 $v0
     	jal operation_integer_multiplication
     	b calculator_integer_loop_end
   
     faireDivision:
     	move $a0 $s0
     	li $v0 5
     	syscall
     	move $a1 $v0
     	jal operation_integer_division
     	b calculator_integer_loop_end
   
     faireMaximum:
     	move $a0 $s0
     	li $v0 5
     	syscall
     	move $a1 $v0
     	jal operation_integer_maximum
     	b calculator_integer_loop_end
     	
     faireMinimum:
     	move $a0 $s0
     	li $v0 5
     	syscall
     	move $a1 $v0
     	jal operation_integer_minimum
     	b calculator_integer_loop_end
     	
     fairePuissance:
     	move $a0 $s0
     	li $v0 5
     	syscall
     	move $a1 $v0
     	jal operation_integer_pow
     	b calculator_integer_loop_end
     
     # puisqu'on a pas besoin d'un deuxiem élément
     # on va seulement appeller la fonction operation_integer_abs
     # et puis on fait un branch vers calculator_integer_loop_end
     faireAbsolue:
     	move $a0 $s0
     	jal operation_integer_abs
     	b calculator_integer_loop_end
     
     calculator_integer_loop_end:
      # Set the result as new first arg
      move $s0 $v0
      # Print result
      move $a0 $v0
      jal print_int
      jal print_newline

      # TODO: uncomment the looping jump below once you are ready
	  # Ready to loop!
      j calculator_integer_loop

  calculator_integer_exit:
    lw $ra 0($sp)
    lw $a0 4($sp)
    lw $a1 8($sp)
    lw $a2 12($sp)
    lw $s0 16($sp)
    lw $s1 20($sp)
    lw $s2 24($sp)
    lw $s3 28($sp)
    addu $sp $sp 32
    jr $ra

calculator_float:
  subu $sp $sp 24
  sw $ra 0($sp)
  sw $a0 4($sp)
  swc1 $f0 8($sp)
  swc1 $f12 12($sp)
  swc1 $f13 16($sp)
  swc1 $f3 20($sp)

  # Debugging info (float mode) on stderr
  la $a0 string_calculator
  jal print_string_stderr
  la $a0 string_float
  jal print_string_stderr
  jal print_newline_stderr

  calculator_float_start:
    # Very first operand
    jal read_float
    # We save the first arg in $f12 (arbitrarily chosen register)
    mov.s $f12 $f0

  # Calculator loop
  calculator_float_loop:

    # TODO:
    # Read operation
    # Read second operand (if necessary)
    # Compute the result
    # Print the result
    # Loop or exit the program
    jal read_operation
 
    # stocker dans $t0 le premiere caractère de la chaîne
    # qui contient l'opération à faire
    lb $t0 op
   
    # avant de comparer le charactère qu'on a stocké en $t0
   	# on va stocker dans un autre registre $t1 les charactères
   	# de chaque opération
   	# et puis on faire le branching vers l'operation qui correspond
   	# si on trouve une égalité
    
    lb $t1 plus
    beq $t0 $t1 faireAddition_float #!addition  
   			
    lb $t1 minus
    beq $t0 $t1 faireSubstraction_float #!substraction
    
    lb $t1 multiplication
    beq $t0 $t1 faireMultiplication_float #!multiplication
    
    lb $t1 division
    beq $t0 $t1 faireDivision_float #!division
    
    # puisque les opération "max" et "min" ont les deux
    # la lettre 'm' comme premiere caractère
    # on va faire un branching vers min_or_max_float
    # où on va determiner si l'operation lue est
    # "max" or "min" 
    la $t1 string_max
    lb $t2 0($t1)
    la $t3 string_min
    lb $t4 0($t3)
    beq $t0 $t2 min_or_max_float
    
    la $t1 string_pow
    lb $t2 0($t1)
    beq $t0 $t2 fairePuissance_float #!power
   
    la $t1 string_abs
    lb $t2 0($t1)
    beq $t0 $t2 faireAbsolue_float #! absolute value
 
    lb $t1 newline
    beq $t0 $t1 program_exit
	     		     		   
#!
     #! since the sign of both operations starts with m, we also have to compare the second letter
     min_or_max_float:
     	lb $t5 1($a0)
     	lb $t6 1($t1)
     	lb $t7 1($t3)
     	beq $t5 $t6 faireMaximum_float
     	beq $t5 $t7 faireMinimum_float		
     
     # le même principe pour chaque partie de branch sauf faireAbsolue_float	
     # on met le premier élément dans le registre $f12
     # qui est le premiere d'argument dans la fonction qui sera appellée
     # on lit le deuxième élément de l'opération
     # puis on le met dans le registre $f13, qui est le deuxième argument de la fonction appellée
     # on appelle la fonction qui correspond à l'opération à faire
     # et puis un branch vers calculator_integer_loop_end
     faireAddition_float:
     	jal read_float
     	mov.s $f13 $f0
     	jal operation_float_addition
     	b calculator_float_loop_end
     	
     faireSubstraction_float:
     	jal read_float
		mov.s $f13 $f0
		jal operation_float_substraction
		b calculator_float_loop_end
	
     faireMultiplication_float:
     	jal read_float
     	mov.s $f13 $f0
     	jal operation_float_multiplication
		b calculator_float_loop_end
	
     faireDivision_float:
     	jal read_float
		mov.s $f13 $f0
		jal operation_float_division
		b calculator_float_loop_end
    
    faireMaximum_float:
     	jal read_float
		mov.s $f13 $f0
		jal operation_float_maximum
		b calculator_float_loop_end
	
     faireMinimum_float:
     	jal read_float
		mov.s $f13 $f0
		jal operation_float_minimum
		b calculator_float_loop_end
	
      fairePuissance_float:
     	jal read_float
		mov.s $f13 $f0
		jal operation_float_pow
		b calculator_float_loop_end
	
      # puisqu'on a pas besoin d'un deuxiem élément
      # on va seulement appeller la fonction operation_integer_abs
      # et puis on fait un branch vers calculator_integer_loop_end
      faireAbsolue_float:
       jal operation_float_abs
       b calculator_float_loop_end
    
    calculator_float_loop_end:
      # Set the result as 'new first arg'
      mov.s $f3 $f0
      # Print result
      mov.s $f12 $f0
      jal print_float
      jal print_newline

      # TODO: uncomment the looping jump below once you are ready

      # Ready to loop!
      j calculator_float_loop

  calculator_float_exit:
    lw $ra 0($sp)
    lw $a0 4($sp)
    lwc1 $f0 8($sp)
    lwc1 $f12 12($sp)
    lwc1 $f13 16($sp)
    lwc1 $f3 20($sp)
    addu $sp $sp 24
    jr $ra

################################################################################
# CLI
################################################################################

## Handle CLI arguments (currently just prints them...)
##
## Inputs:
## $a0: argc
## $a1: argv
##
## Outputs:
## $v0: 0 if we choose integer mode, 1 if we choose float mode
handle_cli_args:
  subu $sp $sp 20
  sw $ra 0($sp)
  sw $a0 4($sp)
  sw $a1 8($sp)
  sw $s0 12($sp)
  sw $s1 16($sp)

  # Copy argc and argv in $s0 and $s1
  move $s0 $a0
  move $s1 $a1
  # Set default return value
  li $v0 0

  handle_cli_args_loop:
    beq $s0 $0 handle_cli_args_exit

    # Debugging info on stderr
    handle_cli_args_loop_debug:
      # Print the prefix "arg: "
      la $a0 string_arg
      jal print_string_stderr
      # Print current arg on stderr
      lw $a0 ($s1)
      jal print_string_stderr
      jal print_space_stderr
      jal print_newline_stderr

    # Process the current argument
    handle_cli_args_loop_current_arg_handling:
      # Compare the argument with authorized values
      # Set $v0 and exit if an authorized value is detected
      #
      # TODO
      bne $s0 1 program_exit
      move $a0 $s1
      jal strlen
      move $t3 $v0 # ici on met la taille dans $t3
      addi $t3 $t3 1
      lw $s4 0($s1)
      move $s1 $s4
      move $a0 $s1
      li $t3 5
      la $s3 string_float
      
      handle_loop:
      	li $t9 1
      	beq $t3 $t9 handle_cli_args_exit
      	lb $t4 0($s1)
      	lb $t5 0($s3)
      	move $a0 $t4
      	move $a0 $t5
      	
      	bne $t4 $t5 end_loop2
      	addi $s1 $s1 1
      	addi $s3 $s3 1
      	li $v0 1
      	subi $t3 $t3 1
      	j handle_loop
      	
      	 end_loop2:
      	 	la $s3 string_integer
      	 	
      	handle_loop2:
      	beqz $t3 handle_cli_args_exit
      	lb $t4 0($s1)
      	lb $t5 0($s3)
      	bne $t4 $t5 program_exit
      	addi $s1 $s1 1
      	addi $s3 $s3 1
      	li $v0 0
      	subi $t3 $t3 1
      	j handle_loop2 

    handle_cli_args_loop_end:
      # Move on to the next argument (akin to argc--, argv++)
      add $s0 $s0 -1
      add $s1 $s1 4
      j handle_cli_args_loop

  handle_cli_args_exit:
    lw $ra 0($sp)
    lw $a0 4($sp)
    lw $a1 8($sp)
    lw $s0 12($sp)
    lw $s1 16($sp)
    addu $sp $sp 20
    jr $ra

################################################################################
# I/O
################################################################################

#-------------------------------------------------------------------------------
# stdout
#-------------------------------------------------------------------------------

## Print a string on stdout
##
## Inputs:
## $a0: string
##
## Outputs:
## none
print_string:
  subu $sp $sp 8
  sw $ra 0($sp)
  sw $a0 4($sp)

  li $v0 4
  syscall

  print_string_exit:
    lw $ra 0($sp)
    lw $a0 4($sp)
    addu $sp $sp 8
    jr $ra

## Print a newline on stdout
##
## Inputs:
## none
##
## Outputs:
## none
print_newline:
  subu $sp $sp 8
  sw $ra 0($sp)
  sw $a0 4($sp)

  la $a0 string_newline
  jal print_string

  print_newline_exit:
    lw $ra 0($sp)
    lw $a0 4($sp)
    addu $sp $sp 8
    jr $ra

## Print a space on stdout
##
## Inputs:
## none
##
## Outputs:
## none
print_space:
  subu $sp $sp 8
  sw $ra 0($sp)
  sw $a0 4($sp)

  la $a0 string_space
  jal print_string

  print_space_exit:
    lw $ra 0($sp)
    lw $a0 4($sp)
    addu $sp $sp 8
    jr $ra

## Print an integer on stdout
##
## Inputs:
## $a0: integer
##
## Outputs:
## none
print_int:
  subu $sp $sp 8
  sw $ra 0($sp)
  sw $a0 4($sp)

  li $v0 1
  syscall

  print_int_exit:
    lw $ra 0($sp)
    lw $a0 4($sp)
    addu $sp $sp 8
    jr $ra

## Print a float (single precision) on stdout
##
## Inputs:
## $f12: float
##
## Outputs:
## none
print_float:
  subu $sp $sp 8
  sw $ra 0($sp)
  swc1 $f12 4($sp)

  li $v0 2
  syscall

  print_float_exit:
    lw $ra 0($sp)
    lwc1 $f12 4($sp)
    addu $sp $sp 8
    jr $ra

#-------------------------------------------------------------------------------
# stderr
#-------------------------------------------------------------------------------

## Print a string on stderr
##
## Inputs:
## $a0: string
##
## Outputs:
## none
print_string_stderr:
  subu $sp $sp 8
  sw $ra 0($sp)
  sw $a0 4($sp)

  jal strlen
  move $a2 $v0
  move $a1 $a0
  li $a0 2
  # syscall 15 (write to file)
  # a0: file descriptor
  # a1: address of buffer
  # a2: number of characters to write
  li $v0 15
  syscall

  print_string_stderr_exit:
    lw $ra 0($sp)
    lw $a0 4($sp)
    addu $sp $sp 8
    jr $ra

## Print a newline on stderr
##
## Inputs:
## none
##
## Outputs:
## none
print_newline_stderr:
  subu $sp $sp 8
  sw $ra 0($sp)
  sw $a0 4($sp)

  la $a0 string_newline
  jal print_string_stderr

  print_newline_stderr_exit:
    lw $ra 0($sp)
    lw $a0 4($sp)
    addu $sp $sp 8
    jr $ra

## Print a space on stderr
##
## Inputs:
## none
##
## Outputs:
## none
print_space_stderr:
  subu $sp $sp 8
  sw $ra 0($sp)
  sw $a0 4($sp)

  la $a0 string_space
  jal print_string_stderr

  print_space_stderr_exit:
    lw $ra 0($sp)
    lw $a0 4($sp)
    addu $sp $sp 8
    jr $ra

print_result_prefix:
  subu $sp $sp 8
  sw $ra 0($sp)
  sw $a0 4($sp)

  la $a0 string_output_prefix
  jal print_string_stderr

  print_result_prefix_exit:
    lw $ra 0($sp)
    lw $a0 4($sp)
    addu $sp $sp 8
    jr $ra

#-------------------------------------------------------------------------------
# misc.
#-------------------------------------------------------------------------------

## Read an integer
##
## Inputs:
## none
##
## Outputs:
## $v0: read integer
read_int:
  li $v0 5
  syscall
  jr $ra

## Read a float
##
## Inputs:
## none
##
## Outputs:
## $f0: read float
read_float:
  li $v0 6
  syscall
  jr $ra
  
#!
# fonction pour lire l'operation à faire
read_operation:
	li $v0 8
	la $a0 op
	li $a1 8
	syscall
	jr $ra
	
################################################################################
# Strings
################################################################################

## Ignore spaces in a string
##
## Inputs:
## $a0: null terminated string
##
## Outputs:
## $v0: first non-space character
ignore_spaces:
  subu $sp $sp 8
  sw $ra 0($sp)
  sw $a0 4($sp)

  la $t0 space
  lb $t0 0($t0)

  move $v0 $a0
  ignore_spaces_loop:
    lb $t1 0($v0)
    beq $t0 $0 ignore_spaces_exit
    bne $t0 $t1 ignore_spaces_exit
    addu $v0 $v0 1
    j ignore_spaces_loop

  ignore_spaces_exit:
    lw $ra 0($sp)
    lw $a0 4($sp)
    addu $sp $sp 8
    jr $ra

## strlen
##
## Inputs:
## $a0: input null terminated string
##
## Outputs:
## $v0: string length
strlen:
  subu $sp $sp 8
  sw $ra 0($sp)
  sw $a0 4($sp)

  move $v0 $0

  strlen_loop:
    lb $t1 0($a0)
    beq $t1 $0 strlen_exit
    add $v0 $v0 1
    add $a0 $a0 1
    j strlen_loop

  strlen_exit:
    lw $ra 0($sp)
    lw $a0 4($sp)
    addu $sp $sp 8
    jr $ra

## Simplified strncmp
##
## Simplified strncmp outputs a boolean value as opposed to the common behaviour
## (Usually it outpus 0 for perfect match or either a negative or positive
## value if the (sub)strings do not exactly match)
##
## Inputs:
## $a0: string 1
## $a1: string 2
## $a2: n
##
## Outputs:
## $v0: boolean
simple_strncmp:
  subu $sp $sp 16
  sw $ra 0($sp)
  sw $a0 4($sp)
  sw $a1 8($sp)
  sw $a2 12($sp)

  # Initialize result to true
  li $v0 1

  simple_strncmp_loop:
    # Have we compared n characters?
    ble $a2 $0 simple_strncmp_exit

    # Load the characters for comparison
    lb $t0 0($a0)
    lb $t1 0($a1)

    # Characters differ
    # TODO
    
    # Identical characters
    # TODO

  simple_strncmp_exit_of_string:
    # (Sub)Strings match
    li $v0 1
    j simple_strncmp_exit

  simple_strncmp_false:
    # (Sub)Strings do not match
    li $v0 0
    j simple_strncmp_exit

  simple_strncmp_exit:
    lw $ra 0($sp)
    lw $a0 4($sp)
    lw $a1 8($sp)
    lw $a2 12($sp)
    addu $sp $sp 16
    jr $ra

################################################################################
# Integer Operations
################################################################################

## Inputs:
## $a0: operand 1
## $a1: operand 2
##
## Outputs:
## $v0: $a1 + $a2
operation_integer_addition:
  add $v0 $a0 $a1
  jr $ra

operation_integer_substraction:
  # TODO
  #!
  sub $v0 $a0 $a1
  jr $ra

operation_integer_multiplication:
  # TODO
  #!
  mul $v0 $a0 $a1
  jr $ra

operation_integer_division:
  # TODO
  #!
  div $v0 $a0 $a1
  jr $ra

operation_integer_minimum:
  # TODO
  # on va comparer les deux arguments
  # si $a0 est plus petit alors on va garder la valeur de $a0
  # sinon, on va garder la valeur de $a1
  ble $a0 $a1 premier_min
  ble $a1 $a0 deuxiem_min
  
  premier_min:
  	move $v0 $a0
  	jr $ra
  deuxiem_min:
  	move $v0 $a1	 
  	jr $ra

operation_integer_maximum:
  # TODO
  # on va comparer les deux arguments
  # si $a0 est plus grand alors on va garder la valeur de $a0
  # sinon, on va garder la valeur de $a1
  bge $a0 $a1 premier_max
  bge $a1 $a0 deuxiem_max
  
  premier_max:
  	move $v0 $a0
  	jr $ra
  	
  deuxiem_max:
   	move $v0 $a1 
	jr $ra

operation_integer_pow:
  # TODO

  # cas particulier, si le deuxieme argument est égal à 0
  # on va directement faire un branch vers puissance_zero
  # qui va renvoier la valeur 1
  beqz $a1 puissance_zero
  
  # on fait des copies des valeurs reçues en argument
  la $t0 ($a0)
  la $t1 ($a1)
  # stock the value 1
  li $t2 1
  
  # on va multiplier de $t1 fois
  # ($t1 étant le registre où on a stocké la valeur de la puissance)
  # la valeur de $a0
  loop:
  	ble $t1 $t2 end_loop
  	mul $t0 $t0 $a0
  	addi $t1 $t1 -1
  	b loop
  
  end_loop:
  	move $v0 $t0	
  	jr $ra

  puissance_zero:
  	li $t0 1
  	move $v0 $t0
  	jr $ra	

operation_integer_abs:
  # TODO
  move $t0 $a0
  # si le nombre est plus grand que 0
  # alors il est positive
  # donc on va renvoyer sa valeur, sans la modifier
  bgtz $t0 positive
  
  # si le nombre est negative 
  # on va faire la substraction entre la valeur réçue et 0
  # pour obtenir sa valeur positive
  bltz $t0 negative
  
  positive:
  	move $v0 $t0
  	jr $ra
  negative:
  	sub $t0 $zero $t0
  	move $v0 $t0
  	jr $ra


################################################################################
# Floating Point Operations
################################################################################

## Float addition
##
## Inputs
## $f12: first argument
## $f13: second argument
##
## Outputs
## $f0: $f12 + $f13
operation_float_addition:
  add.s $f0 $f12 $f13
  jr $ra

## Float substraction
##
## Inputs
## $f12: first argument
## $f13: second argument
##
## Outputs
## $f0: $f12 - $f13
operation_float_substraction:
  # TODO
  sub.s $f0 $f12 $f13
  jr $ra

## Float multiplication
##
## Inputs
## $f12: first argument
## $f13: second argument
##
## Outputs
## $f0: $f12 * $f13
operation_float_multiplication:
  # TODO
  mul.s $f0 $f12 $f13
  jr $ra

## Float division
##
## Inputs
## $f12: first argument
## $f13: second argument
##
## Outputs
## $f0: $f12 / $f13
operation_float_division:
  # TODO
  div.s $f0 $f12 $f13
  jr $ra

## Float minimum
##
## Inputs
## $f12: first argument
## $f13: second argument
##
## Outputs
## $f0: min($f12, $f13)
operation_float_minimum:
  # TODO
  # on fait la comparaison entre les deux valeurs
  # pour determiner la valeur la plus petite
  # et en c on va garder la valeur de la comparaison
  c.le.s $f12 $f13
  
  # si on a true alors on va garder la valeur de $f12
  bc1t premier_min_float
  
  # sinon on va garder la valeur de $f13
  bc1f deuxiem_min_float
  
  premier_min_float:
  	mov.s $f0 $f12
  	jr $ra
  
  deuxiem_min_float:
  	mov.s $f0 $f13
  	jr $ra

## Float maximum
##
## Inputs
## $f12: first argument
## $f13: second argument
##
## Outputs
## $f0: max($f12, $f13)
operation_float_maximum:
  # TODO
  # on fait la comparaison entre les deux valeur
  # pour determiner la valeur la plus grande
  # et en c on va garder la valeur la plus grand
  c.le.s $f12 $f13
  # si on a true, ça veut dire que le deuxieme est plus grand
  # donc on va stocker sa valeur
  bc1t deuxiem_max_float
  # sinon on va prendre l'autre valeur
  bc1f premier_max_float
  
  premier_max_float:
  	mov.s $f0 $f12
  	jr $ra
  
  deuxiem_max_float:
  	mov.s $f0 $f13
	jr $ra

operation_float_pow:
  # TODO
  # on va garder les valeurs 0 dans le registre $f1
  # et la valeur 1 dans les registres $f2 et $f3
  l.s $f1 fp0
  l.s $f2 fp1
  l.s $f3 fp1
  
  # si le deuxiem élément qui correspond à la puissance est égal à 0
  c.eq.s $f13 $f1
  
  # alors on va renvoyer la valeur 1
  bc1t puissance_zero_float
  
  # sinon on va calculer le resultat
  bc1f puissance_difzero_float	  
  
  puissance_difzero_float:
  	# on va determiner si la valeur de $f13 qui correspond à la puissance
  	# est égal à 0 (conditin d'arrêt de la boucle)
  	c.le.s $f13 $f1
  	
  	# si $f13 n'est pas égal à 0, on va continuer de calculer le resultat
  	bc1f flooppow
  	
  	# sinon, on va sortir de la boucle
  	bc1t ffinlooppow 
  	flooppow:
  		# chaque fois on va multiplier par la valeur de $f12
  		# qui correspond à la valeur de la base
  		mul.s $f3 $f3 $f12
  		sub.s $f13 $f13 $f2
  		j puissance_difzero_float
  	
  	ffinlooppow:
  		# si on est sorti de la boucle
  		# on va renvoyer la valeur du calcul
  		mov.s $f0 $f3
  		jr $ra

    puissance_zero_float:
  	    mov.s $f0 $f2
  	    jr $ra
		
operation_float_abs:
  # TODO
  # on va stocker dans $f1 la valeur 0
  l.s $f1 fp0
  
  # et on fait une copie de la valeur de $f12
  # le seul argument, puisqu'on a pas besoin d'un deuxiem élément
  mov.s $f11 $f12
  
  # si la valeur qu'on a réçue en paramètre est plus petit que 0  
  c.lt.s $f11 $f1
  
  # on va determiner la valeur absolue
  bc1t negative_float
  bc1f positive_float
  
  positive_float:
  	# si le nombre est positif
  	# on va tout simplement renvoyer sa valeur
  	mov.s $f0 $f12
  	jr $ra
  negative_float:
  	# si le nombre n'est pas positif
  	# on va faire le substraction entre 0 et sa valeur
  	# pour determiner la valeur absolue
  	# et puis on va renvoyer la valeur absolue
  	sub.s $f12 $f1 $f12
  	mov.s $f0 $f12
  	jr $ra
  

# vim:ft=mips

