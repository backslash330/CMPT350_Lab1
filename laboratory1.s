#################################
# Laboratory 1                  #
# Author: Nicholas Almeida      #
# Date: September 07, 2022      #
#                               #
# Purpose: This program will    #
# simulate a hangman game.      # 
# First, the user provides the  #
# solution word, and then       #
# guesses letters until the     #
# word is completed or the      #
# number of incorrect guesses   #
# is reached.                   #
################################# 

#The data section reserves memory locations for future reference in the program. Commonly used for static strings

.data
# the program has a fixed number of guesses
Guesses: .word 6
# Program keeps a progress string of all guessed letters
progress: .asciiz ""
secret_word: .space 12
user_guess: .space 3
counter: .space 0
intial_prompt: .asciiz "Welcome to Hangman! Please enter a word for the to guess betwwen 5 and 10 characters: "
guess_prompt: .asciiz "Please enter a letter to guess: "
progress_message: .asciiz "Progress: "
correct_guess: .asciiz "Correct guess!"
guesses_remaining: .asciiz "Guesses remaining: "
lose: .asciiz "You lose!"
nl: .asciiz "\n"

#The text section contains the instructions to execute. Most of your time will be spent in the .text section. The text section must have a main: label to function properly
.text

#the main: label tells SPIM where to begin progam execution
main:
	# Prompt the user for a 5-10 letter word
	li $v0, 4
	la $a0, intial_prompt
	syscall

	# Read the user input into the secret_word variable
	li $v0, 8
	la $a0, secret_word
	li $a1, 11
	syscall

	# loop through and remove the newline character from the end of the string
	la $t0, 0
	la $t1, 10
	la $t2, secret_word

loop:
	lb $t3, 0($t2)
	beq $t3, $t1, endloop
	addi $t2, $t2, 1
	j loop

endloop:
	sb $t0, 0($t2)

	# # print the secret word
	# li $v0, 4
	# la $a0, secret_word
	# syscall

	# print a newline
	li $v0, 4
	la $a0, nl
	syscall

	# store guesses in $t0
	lw $t0, Guesses

	# main game loop
game_loop:
	# number of guesses remaining
	li $v0, 4
	la $a0, guesses_remaining
	syscall

	# print t0
	li $v0, 1
	move $a0, $t0
	syscall

	# print a newline
	li $v0, 4
	la $a0, nl
	syscall

	# display letters guessed so far
	li $v0, 4
	la $a0, progress_message
	syscall

	# print the progress string
	li $v0, 4
	#la $a0, user_guess
	la $a0, progress
	syscall

	# print a newline
	li $v0, 4
	la $a0, nl
	syscall

	# prompt user for a letter
	li $v0, 4
	la $a0, guess_prompt
	syscall

	# read user input into user_guess
	li $v0, 8
	la $a0, user_guess
	li $a1, 2
	syscall

	# print a newline
	li $v0, 4
	la $a0, nl
	syscall

	# check if letter is in word
	# iterate through the word and delete the letter if it is in the word
	# and iterate the counter
	la $t1, secret_word
	la $t2, user_guess
	la $t3, counter

# look through the word, jump to deletion if the letter is found, otherwise increment the counter and continue
look_through_word:
	lb $t4, 0($t1)
	lb $t5, 0($t2)
	# if the word is ended, jump the end of the loop
	beq $t4, $zero, end_of_word # if the byte is zero, jump to end_of_word
	beq $t4, $t5, delete_letter # if the byte is the same as the letter, jump to delete_letter
	addi $t1, $t1, 1 
	addi $t3, $t3, 1
	j look_through_word

delete_letter:
	# if the letter is found, replace it with a underscore
	# do this by replacing the value of 0($t1) with an underscore
	li $t5, 95
	sb $t5, 0($t1)
	addi $t1, $t1, 1
	addi $t3, $t3, 1
	j look_through_word

end_of_word:

# print secret word
	li $v0, 4
	la $a0, secret_word
	syscall
# print a newline
	li $v0, 4
	la $a0, nl
	syscall



# 	la $t1, secret_word
# 	la $t2, user_guess
# 	la $t3, counter
# 	la $t4, 0

# guess_loop:
# 	lb $t5, 0($t1)
# 	beq $t5, $t4, end_guess_loop
# 	beq $t5, $t2, found_letter
# 	addi $t1, $t1, 1
# 	j guess_loop

# found_letter:
# 	# if the letter is in the word, turn it into a dash and increment the counter
# 	sb $t4, 0($t1)
# 	addi $t3, $t3, 1
# 	addi $t1, $t1, 1
# 	j guess_loop


end_guess_loop:
	# if the the counter is more then 0, print "Correct guess!"
	# and decrement the number of guesses
	beq $t3, $0, incorrect_guess
	li $v0, 4
	la $a0, correct_guess
	syscall

	# print a newline
	li $v0, 4
	la $a0, nl
	syscall

	j game_over_check


	# if the whole word is guessed, print "You win!" and exit with code 1
	# check if the secret word is only 
incorrect_guess:
	# if the letter is not in the word, print "Incorrect guess!"
	# and decrement the number of guesses
	li $v0, 4
	la $a0, incorrect_guess
	syscall

game_over_check:

	# decrement the number of guesses
	sub $t0, $t0, 1

	# if the number of guesses remaining is 0, print "You lose!" and exit with code 2
	beq $t0, $zero, lose_game

	# if the number of guesses remaining is not 0, go back to the top of the loop
	j game_loop

lose_game: 
	li $v0, 4
	la $a0, lose
	syscall

	# exit with code 2
	li $v0, 10
	li $a0, 2
	syscall


	#this block is equivalent to the "exit(0)" or "return 0" lines in a C program
	li $v0, 10 #load the "terminate program" syscall value into the v0 register
	syscall #terminate the program

	
	# decrement the number of guesses
	sub $t0, $t0, 1