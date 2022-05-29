# WORDLE - x86 Assembly Language
WORDLE - the word guessing game

Wordle is a web-based word game created and developed by Welsh software engineer Josh Wardle and owned and published by The New York Times Company since 2022.

This game challenges people to guess a five-letter word in seven tries. 

This version has both a signle player and two player mode. 

The single player mode takes a random word from a .txt file, which the user has to guess. The game has 4 rounds with 7 attempts each round.

The two player mode requires one person to set the word while the other guesses. This goes on for four rounds while alternating who guesses and sets the words.

## Single Player: 
###### 1. The goal is to guess a random 5 letter word. There will be 4 rounds. To begin, enter a five-letter word.
###### 2. You have 7 attempts to guess the word.
###### 3. If a letter is found in both the word and your guess, it will be highlighted either blue or yellow.
###### 4. If the letter is in the correct position, it will be highlighted blue. Otherwise, it is highlighted yellow.
###### 5. To win the game, correctly guess 3 out of 4 words. 


## Two Players: 
###### 1. The goal is to guess a random 5 letter word. There will be 4 alternating rounds. 
###### 2. To begin, User 1 will set the word, while User 2 guesses the word.
###### 3. If a letter is found in both the word and your guess, it will be highlighted either blue or yellow.
###### 4. If the letter is in the correct position, it will be highlighted blue. Otherwise, it is highlighted yellow.
###### 5. If the word is guessed correctly, the guesser earns a point. Otherwise, the User who set the word earns a point.
###### 6. Once a round is over, User 1 and User 2 will alternate roles for the following round.
###### 5. To win the game, win 3 out of 4 rounds. 


