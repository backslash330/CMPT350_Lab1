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
#how much checking do we need to do

# do we need to assume malicious input??
# do we treat upper and lower as different or the same?
# how much formatting would they like?

#The data section reserves memory locations for future reference in the program. Commonly used for static strings

.data
# the program has a fixed number of guesses
Guesses: .word 6
# Program keeps a progress string of all guessed letters
progress: .space 6
progress_counter: .word 0
secret_word: .space 12
user_guess: .space 64
intial_prompt: .asciiz "Welcome to Hangman! Please enter a word for the to guess between 5 and 10 characters: "
guess_prompt: .asciiz "Please enter a letter to guess: "
progress_message: .asciiz "Progress: "
correct_message: .asciiz "Correct guess!"
incorrect_message: .asciiz "Incorrect guess!"
guesses_remaining: .asciiz "Guesses remaining: "
lose: .asciiz "Out of Guesses! You lose!"
win: .asciiz "You guessed the whole word! You win!"
nl: .asciiz "\n"

#The text section contains the instructions to execute. Most of your time will be spent in the .text section. The text section must have a main: label to function properly
.text

#the main: label tells SPIM where to begin progam execution
main:
	# Prompt the user for a 5-10 letter word
	li $v0, 4 # load immediate value 4 into $v0
	la $a0, intial_prompt # load address of intial_prompt into $a0
	syscall

	# Read the user input into the secret_word variable
	li $v0, 8 # load immediate value 8 into $v0
	la $a0, secret_word # load address of secret_word into $a0
	li $a1, 11 # load immediate value 11 into $a1
	syscall

	# loop through and remove the newline character from the end of the string
	la $t0, 10 # load address of 10 into $t0
	la $t1, secret_word # load address of secret_word into $t1
	li $t6, 0 # Length of secret word counter. load immediate value 0 into $t6

loop:
	lb $t2, 0($t1) # load byte at address 0($t1)  into $t2
	beq $t2, $t0, endloop # if $t2 is equal to $t0, jump to endloop
	addi $t6, $t6, 1 # increment $t6 by 1
	addi $t1, $t1, 1 # add immediate 1 to $t1
	j loop # jump to loop

endloop:
	sb $zero, 0($t1) # store byte $zero at address 0($t1)

	# store guesses in $t0
	lw $t0, Guesses # load word Guesses into $t0

	# main game loop
game_loop:
	# number of guesses remaining
	li $v0, 4 # load immediate value 4 into $v0
	la $a0, guesses_remaining  # load address of guesses_remaining into $a0
	syscall

	# print t0
	li $v0, 1 # load immediate value 1 into $v0
	move $a0, $t0 # move $t0 (Guesses) into $a0
	syscall

	# print a newline
	li $v0, 4 # load immediate value 4 into $v0
	la $a0, nl # load address of nl into $a0
	syscall

	# display letters guessed so far
	la $a0, progress_message # load address of progress_message into $a0
	syscall

	# print the progress string
	la $a0, progress # load address of progress into $a0
	syscall

	# print a newline
	la $a0, nl # load address of nl into $a0
	syscall

	# prompt user for a letter
	la $a0, guess_prompt # load address of guess_prompt into $a0
	syscall

	# read user input into user_guess
	li $v0, 8 # load immediate value 8 into $v0
	la $a0, user_guess # load address of user_guess into $a0
	li $a1, 65	# load immediate value 2 into $a1
	syscall

	# store the users guess into the progress space 
	la $t1, user_guess
	lb $t2, 0($t1)
	lb $t3, progress_counter
	sb $t2, progress($t3)
	addi $t3, $t3, 1
	sb $t3, progress_counter

	# check if letter is in word
	# iterate through the word and delete the letter if it is in the word
	# and iterate the counter
	la $t1, secret_word # load address of secret_word into $t1
	la $t2, user_guess # load address of user_guess into $t2
	li $t3, 0 # create counter. load byte $zero into $t3

# look through the word, jump to deletion if the letter is found, otherwise increment the counter and continue
look_through_word:
	lb $t4, 0($t1) # load byte at address 0($t1) into $t4
	lb $t5, 0($t2) # load byte at address 0($t2) into $t5
	# if the word is ended, jump the end of the loop
	beq $t4, $zero, end_of_word # if the byte is zero, jump to end_of_word
	beq $t4, $t5, delete_letter # if the byte is the same as the letter, jump to delete_letter
	addi $t1, $t1, 1  # add immediate 1 to $t1
	j look_through_word # jump to look_through_word

delete_letter:
	# if the letter is found, replace it with a underscore
	# do this by replacing the value of 0($t1) with an underscore
	li $t5, 95 # load immediate value 95 (underscore) into $t5
	sb $t5, 0($t1) # store byte $t5 at address 0($t1)
	addi $t1, $t1, 1 # add immediate 1 to $t1
	addi $t3, $t3, 1 # add immediate 1 to $t3
	j look_through_word # jump to look_through_word

end_of_word:

	# if the the counter is more then 0, print "Correct guess!"
	# and decrement the number of guesses
	li $v0, 4	# load immediate value 4 into $v0
	beq $t3, $0, incorrect_guess
	la $a0, correct_message
	syscall

	# print a newline
	la $a0, nl
	syscall

	j game_over_check


	# if the whole word is guessed, print "You win!" and exit with code 1
	# check if the secret word is only 
incorrect_guess:
	# if the letter is not in the word, print "Incorrect guess!"
	# and decrement the number of guesses
	la $a0, incorrect_message
	syscall

	# print new line
	la $a0, nl
	syscall

game_over_check:
	# check to see if the game is won
	# loop over the word and count the number of underscores into $t7
	la $t1, secret_word # load address of secret_word into $t1
	# loop through the word and count the number of underscores
	li $t7, 0 # load immediate value 0 into $t7
		# loop through the word and count the number of underscores
loop_check:
	lb $t4, 0($t1) # load byte at address 0($t1) into $t4
	beq $t4, $zero, end_check # if the byte is zero, jump to end_check
	beq $t4, 95, letter_found # if the byte is underscore, jump to letter_found
	addi $t1, $t1, 1 # add immediate 1 to $t1
	j loop_check # jump to loop_check
letter_found:
	addi $t7, $t7, 1 # add immediate 1 to $t7
	addi $t1, $t1, 1 # add immediate 1 to $t1
	j loop_check # jump to loop_check

end_check:
	# if $t7 is equal to $t6 then the whole word is guessed and the game is won
	beq $t7, $t6, win_game # if $t7 is equal to $t6, jump to game_won

	# decrement the number of guesses
	sub $t0, $t0, 1

	# if the number of guesses remaining is 0, print "You lose!" and exit with code 2
	beq $t0, $zero, lose_game

	# if the number of guesses remaining is not 0, go back to the top of the loop
	j game_loop

lose_game: 
	la $a0, lose
	syscall

	# exit with code 2
	li $v0, 10
	li $a0, 2
	syscall

win_game:
	la $a0, win
	syscall

	# print new line 
	la $a0, nl
	syscall

	# exit with code 1
	li $v0, 10
	li $a0, 1
	syscall