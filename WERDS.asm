TITLE: WERDS.asm
;//Author: Ismael Contreras (completed requirements)
;//Description: The program is a variation of the game WORDLE
;//				User must guess a five letter word to win a round.
;//             Most wins out of 4 rounds is the winner.
;//
;// Extra Credit: 
;//              1. Read words in from a file and randomly pick one for single player
;//				 2. As the round is played, show the progress of words guessed. 
;//              3. Displays words guessed with colored background after every guess
;//                 Blue blackground for correct position, yellow = wrong position
;//                 Black background = letter not found in word
;//Sources: Assembly.Language.For_.x86.Processors.Kip_.R..Irvine..6ed. 
;//Date: May 11, 2022 
;//=============================================================================================

INCLUDE Irvine32.inc

newline EQU <0Ah, 0Dh>

.data

userChoice byte 0h
errormsg byte newline, "You have selected an invalid option.", newline, "Please try again.", newline, 0h
linenew byte newline, 0h
.code
main PROC
	
	call clearRegs
	call Randomize

	mov ebx, 0
	startLoop: 
	
		mov ebx, offset userChoice
		call displayMenu
		
		;// check for valid input
		cmp UserChoice, 1d			;//If under 1, invalid input
		jb invalid				
		cmp UserChoice, 3d			;//Else if under 3, valid input
		jb continue
		cmp UserChoice, 3d			;//Else if choice = 3, quit program
		jg invalid
		jmp quit							;//Else input is invalid
		
		
	invalid:
	;// error message and restart loop
		push edx
		mov edx, offset errormsg
		call writestring
		call waitMsg
		call ClrScr
		pop edx
		jmp startLoop
		
	continue:
	
		call Selection
		mov edx, offset linenew
		call writestring
		call waitmsg
		call ClrScr
		jmp startLoop
	
	quit:
exit
main ENDP
;//######################################################


;//################
Selection proc
;// Description:  Selects correct procedure to execute based on user choice.
;// Receives: AL = user option
;// Returns: Nothing, but correct procedure is selected
;// Requires: NA

	
	cmp al, 2     
	jb choice1
	jmp choice2
	
	choice1:
		call ClrScr
		call TwoPlayer
		jmp quitit

	choice2:
		call ClrScr
		call SinglePlayer
		jmp quitit


	quitit:
ret
Selection ENDP
;//######################################################



;//################
displayMenu PROC
;//Description: Displays main menu choices and returns user's option
;//Parameters: NA
;//Requires: EDX to be 0; Pushes/Pops stack to accomplish this
;//Returns: UserChoice offset in EBX

.data 
	menu byte newline,"WERDS", newline, "Main menu", 
			newline, "------------------------------------",
			newline, "1. Two Players", 
			newline, "2. Single Player",
			newline, "3. Exit",
			newline, "    Please choose an option: ", 0h
			
.code

	push edx 
	mov edx, offset menu
	call writestring
	call readdec
	mov byte ptr[ebx], al 
	pop edx 
	
ret
displayMenu ENDP
;//######################################################


;//##########
TwoPlayer PROC
;//Description: Loop for two player game
;//Parameters: NA
;//Requires: NA
;//Returns: NA
.data
	twoMode byte newline, "Two Player Mode", newline, "Rules: ", newline,
				 "1. First player chooses a word to guess", newline,
				 "2. Second player has 7 tries to guess the word", newline,
				 "3. Players switch roles each round", newline,
				 "4. 4 rounds per game", newline, 0h
			
	User1 byte  newline, "User_1 ", 0h
	User2 byte  newline, "User_2 ", 0h
	TempUser byte newline, "User 1 ", 0h
	target byte 6 dup (0h)
	count word 0h
	right byte newline, "The answer is correct!", newline, 0h
	wrong byte newline, "The answer is incorrect!", newline, 0h
	rounds byte newline, "Enter Target Word_Round #: ", 0h
	guessit byte newline, "Enter Guess_Round #: ", 0h

.code
	mov count, 0
	push ecx
	mov ecx, 4 ;// 4 rounds
	mov eax, 0 ;// track score for user 1
	mov ebx, 0 ;// track score for user 2
	call ClrScr
	mov edx, offset twoMode
	call writestring
	call waitmsg
	call ClrScr

	GameLoop:
			
			call clrscr
			push eax
			mov ax, count
			inc eax
			mov edx, offset rounds
			call writestring 
			call writedec
			mov count, ax
			pop eax

			mov edx, offset User1
			call GetWord
			call clrscr
			mov ebp, offset target
			push ecx
			mov ecx, 5
			push esi
			push eax

		L1: ;// moving word target word to ebp, leaving edx for guesses
			mov al, byte ptr [edx + esi]
			mov byte ptr [ebp + esi], al
			inc esi
			loop L1

		mov ecx, 7  ;// 7 guesses 

		mov ax, count
		mov edx, offset guessit
		call writestring
		call writedec
		pop eax
		pop esi

		Guessing:
			push eax
			mov edx, offset User2
			call GetWord
			call compareWords
			cmp eax, 1
			je Correct
			pop eax
			loop Guessing

		Incorrect:
			mov edx, offset wrong
			inc eax
			jmp EndRound

		Correct: 
			pop eax
			mov edx, offset right
			inc ebx

		EndRound:
			call writestring
			call waitmsg

		Swap:		
			
			push esi
			push edi
			mov ecx, LengthOf User1
			mov esi,OFFSET User1 
			mov edi,OFFSET TempUser 
			rep movsb
			mov ecx, LengthOf User2
			mov esi, OFFSET User2
			mov edi, OFFSET User1
			rep movsb
			mov ecx, LengthOf TempUser
			mov esi, OFFSET TempUser
			mov edi, OFFSET User2
			rep movsb
			pop edi
			pop esi

			pop ecx
			xchg eax, ebx
			dec ecx
			jnz GameLoop

	Quit:
	
	mov edx, offset User1
	push edx
	mov edx, offset User2
	call clrScr
	call ShowScore
	pop edx
	pop ecx


 ret
 TwoPlayer ENDP
;//######################################################

;//##########
SinglePlayer PROC
;//Description: Single Player game loop
;//Parameters: NA
;//Requires: NA
;//Returns: NA
.data
	singleMode byte newline, "Single Player Mode", newline, "Rules: ", newline,
				 "1. List of words is read in from words.txt", newline,
				 "2. A random word is chosen.", newline,
				 "3. Player has 7 tries to guess the word", newline,
				 "4. 4 rounds per game", newline, 0h
	roundNum byte newline, "Enter Guesses_Round #", 0h
	wordList byte 1000 dup (0h)
	tempwerd byte 6 dup (0h)
	User byte newline, 0h
	Your byte newline, "You ", 0h
	Comp byte newline, "Computer ", 0h
	OutOF byte " OUT OF 4 ROUNDS CORRECT", 0h
	winer byte newline, newline, "You Win", newline , 0h
	lostPC byte newline, newline, "You Lost", newline, 0h
	rnd word 0h
.code

	
	
	call ClrScr
	mov edx, offset singleMode
	call writestring
	call waitmsg
	call ClrScr

	mov rnd, 0
	mov edi, OFFSET wordList  
	call ReadInWords

	push esi
	push edi
	push eax
	push ebx
	push ecx

	mov ecx, 4 ;// 4 rounds
	mov ebx, 0 ;// score keeper

	getrandWord:
		call ClrScr
		push eax
		mov ax, rnd
		inc eax
		mov edx, offset roundNum
		call writestring 
		call writedec
		mov rnd, ax
		pop eax
		
		mov eax, 209d     ;// 44 words in file
		call RandomRange

		mov esi, offset wordList
		mov edi, offset tempwerd
		add esi, eax

	nextWord:
		mov al, [esi]
		inc esi
		cmp al, 0Ah
		jne nextWord

	L1:
		mov al, [esi]
		mov [edi], al
		inc esi
		inc edi
		cmp al, 20h
		jne L1

	push ecx	
	mov ebp, offset tempwerd
	mov ecx, 7  ;// 7 guesses 
	
	Guessing:
			push eax
			push edx
			mov edx, offset User
			call GetWord
			call compareWords
			cmp eax, 1
			je Correct
			pop edx
			pop eax
			loop Guessing

	Incorrect:
			mov edx, offset wrong
			jmp EndTurn

	Correct: 
			pop edx
			pop eax
			mov edx, offset right
			inc ebx

	EndTurn:
		   call writestring
		   call waitmsg
		   pop ecx
		   dec ecx
		   jnz getrandWord

	EndGame:

	mov eax, ebx
	call clrscr
	cmp eax, 2
	jg Winner

	Lost:
		mov edx, offset lostPC
		call writestring
		call writedec
		mov edx, offset OutOf
		call writestring
		jmp quit

	Winner:

		mov edx, offset winer
		call writestring
		call writedec
		mov edx, offset OutOf
		call writestring

	quit:
		pop ecx
		pop ebx
		pop eax
		pop edi
		pop esi

 ret
 SinglePlayer ENDP
;//######################################################

;//##########
ReadInWords PROC
;//Description: Reads in words from a file "words.txt" and places buffer
;//Parameters: NA
;//Requires: Offset of wordList array in edi
;//Returns: list of words
;//Site-Source: Assembly.Language.For_.x86.Processors.Kip_.R..Irvine..6ed. Chapter 5 pgs 142-145
.data
buf byte 1000 dup (?)
bytesRead DWORD ?
filename byte "words.txt", 0h
fileHandle DWORD ?
promptRead byte newline, "Reading in list of words from file words.txt" , newline, 0h
.code
	readinfile:
		push eax
		push edx
		push ecx
		mov edx,offset  promptRead
		call writestring
		call waitmsg
		mov edx, offset filename
		call OpenInputFile
		mov fileHandle, eax
		mov edx, offset buf
		mov ecx, 1000
		call ReadFromFile
		mov bytesRead, eax
		jc WriteWindowsMsg 
		mov eax, fileHandle
		call CloseFile
		pop ecx
		pop edx
		pop eax

	swap:		
		push esi
		push ecx
		mov ecx, LengthOf buf
		mov esi, OFFSET buf 
		rep movsb
		pop ecx
		pop esi

		;//push edx
		;//mov edx, offset buf
		;//call clrscr
		;//call writestring 
		;//call waitmsg
		call clrscr
		;//pop edx
 ret
 ReadInWords ENDP
;//######################################################


;//##########
GetWord PROC
;//Description:  Prompts user for input. Reads in word from current user.
;//Parameters: EDX = UserName of Current User
;//Requires: ECX = 0, 
;//Returns: Offset of word input from user in EDX
.data

	WordPrompt byte "Please enter a five letter word: ", 0h
	
	targetWord byte 15 dup (0h)
.code
	
	push eax
	push ecx
	push esi
	start:
		
		mov esi, 0
		call writestring
		push edx
		mov edx, offset WordPrompt
		call writestring
		mov ecx, 30
		mov edx, offset targetWord
		call readstring
		
		cmp eax, 5
		je CheckInput
	
	Invalid:

		call InputError
		call ClrScr
		pop edx
		jmp start

	CheckInput:
		mov al, [edx + esi]
		cmp al, 65d
		jb Invalid
		cmp al, 91d
		jb LowerCase
		cmp al, 97d
		jb Invalid
		cmp al, 122d
		jg Invalid
		inc esi
		cmp esi, 4
		jg continue
		jmp CheckInput


   LowerCase:
		add eax, 20h
		mov byte ptr[edx + esi], al
		inc esi
		cmp esi, 4
		jg continue
		jmp CheckInput
	continue: 
		pop edx
		pop esi
		pop ecx
		pop eax
		mov edx, offset targetWord
	
	  
 ret
 GetWord ENDP
;//######################################################

;// ===================================================
compareWords PROC
;// Description: Compares two strings to see if letters match
;// Receives: offset of guess in edx, offset of target in ebp
;// Returns: bool in eax
;// Requires: eax = 0h, ecx = 5d, ebx = 0h, esi = 0h
;//           
 
.data


.code 

	
	push ebx
	push esi
	push ecx
	mov esi, 0
	mov eax, 0
	mov ecx, 5

	

	IsItFullMatch:
		mov ebx, 0h
		mov al, byte ptr [edx + esi]
		mov bl, byte ptr [ebp + esi]
		cmp bl, al                 
		jne NEXT

		mov ebx,white + (blue * 16)
		call ColorPrint
		inc esi
		loop IsItFullMatch

	IsFullMatch:
		mov eax, 1
		jmp quit
		
	
	;// if equal, print out BlueBackground
	NEXT:
		
		mov al, byte ptr [edx + esi]
		cmp al, byte ptr [ebp + esi]
		je PrintBlue

		push esi
		mov esi, 0
		push ecx
		mov ecx, 5

		IsCharInWord: 
			cmp al, byte ptr [ebp + esi]
			je PrintYellow
			inc esi
			loop IsCharInWord

		NotInWord:
			mov  ebx, white + (black * 16)
			call ColorPrint	
			jmp Continue

		PrintYellow:
			mov  ebx, black + (yellow * 16)
			call ColorPrint
			jmp Continue

		PrintBlue:
			mov ebx, white + (blue * 16)
			call ColorPrint
			inc esi
			loop NEXT
	jmp incorrect
	Continue:
		pop ecx
		pop esi
		inc esi
		loop NEXT
		
	;//Not fullMatch eax = 0
	incorrect: 
		mov eax, 0

	quit:
		push eax
		mov eax, white + (black * 16) ;// reset text background color
		call SetTextColor
		pop eax
		pop ecx
		pop esi
		pop ebx

	
ret
compareWords ENDP
;/################

;//##########
InputError PROC
;//Description: Displays an error message
;//Parameters: NA
;//Requires: NA
;//Returns: NA
.data
	errMsg byte "ERROR. The word must be 5 letters long with alpha characters only", newline, 0h 

.code
	
	push edx
	mov edx, offset errMsg
	call writestring 
	call waitmsg
	pop edx

 ret 
 InputError ENDP
 ;//######################################################

 ;//##########
ColorPrint PROC
;//Description: Prints character in al with desired background color.
;//Parameters: NA
;//Requires: al = character, ebx = background color value
;//Returns: NA
.data
	color dword 0h
	char byte 1 dup (0h)
	line byte 7ch, 0h

.code
		
		push edx
		mov edx, offset char
		mov byte ptr [edx], al
		push eax
		mov  eax,ebx
		call SetTextColor
		call writestring
		pop eax
		pop edx

 ret
 ColorPrint ENDP
;//######################################################

;//##########
ShowScore PROC
;//Description: Displays score and winner
;//Parameters: NA
;//Requires: edx = Offset of User1 & 2 in stack, ebx = Score User2, eax = Score User1
;//Returns: NA
.data
	win1 byte newline, "User1 is the WINNER!!", newline, 0h
	win2 byte newline, "User2 is the WINNER!!", newline, 0h
	tie byte newline, "TIE GAME, flipping coin to determine winner...", newline, 0h
	score1 byte newline, "User1 score: ", 0h
	score2 byte newline, "User2 score: ", 0h
.code
	
		push edx
	
		cmp eax, ebx
		jb User2Wins
		cmp eax, ebx
		jg User1Wins

		TieRandomWin:
			mov edx, offset tie
			call writestring
			call waitmsg
			call ClrScr
			push eax
			push ebx
			mov ax, 1000
			call RandomRange
			mov edx, 0
			mov ebx, 2
			div ebx
			pop ebx 
			pop eax
			cmp edx, 0
			jg User2Wins


		User1Wins:
			mov edx, offset win1
			call writestring
			jmp PrintScores

		User2Wins:
			mov edx, offset win2
			call writestring
			

		PrintScores:
			mov edx, offset score1
			call writestring
			call writedec
			mov edx, offset score2
			mov eax, ebx
			call writestring
			call writedec
			
		pop edx





 ret
 ShowScore ENDP
;//######################################################


;//##########
clearRegs PROC
;//Description: Clears registers to be used 
;//Parameters: NA
;//Requires: NA
;//Returns: Cleared registers
.code
 mov eax, 0
 mov ecx, 0
 mov edx, 0
 mov edi, 0
 mov esi, 0

 ret
 clearRegs ENDP
;//######################################################



END main
