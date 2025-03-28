TITLE Project 6 - String Primitives and Macros     (Proj6_vanhaoe.asm)

; Author: Ethan Van Hao
; Last Modified: 3/15/2025
; OSU email address: vanhaoe@oregonstate.edu
; Course number/section:   CS271 Section 402
; Project Number: 6 - String Primitives and Macros      Due Date: 3/16/25
; Description: This program asks to be given a properly ASCII-formatted file to read and process.
;              The program uses LODSB to properly go through each byte in the given file and converts the 
;			   ASCII values into a numerical integer to be printed onto the console. The integers
;			   are then placed into an array that is read backwards and printed onto the console
;			   with its values separated by a global constant delimiter. The program can also
;			   detect if the file is not able to be opened and closes itself. The program then
;			   says goodbye and ends.

INCLUDE Irvine32.inc

;----------------------------------------------------------------------
;Name: mGetString
;
;Displays an input prompt and stores user input. 
;
;Preconditions: 
;	Valid length of input string.
;
;Receives: 
;	prompt:				Adress of prompt string
;	maxLength:			Maximum number of characters
;
;Returns: 
;	keyInput:			User's input string
;	bytesRead:			Number of bytes read from the user
;
;----------------------------------------------------------------------
mGetString MACRO prompt, keyInput, maxLength, bytesRead
	pushad
	mov		edx, prompt
	call	WriteString
	mov		edx, keyInput
	mov		ecx, maxLength
	call	ReadString
	mov		DWORD PTR [bytesRead], eax
	popad
ENDM

;----------------------------------------------------------------------
;Name: mDisplayString
;
;Prints the string that was passed as a parameter to the macro.
;
;Preconditions: 
;	String is stored in a specified memory location.
;
;Receives: 
;	printString:		Address of the string to be printed
;
;Returns: 
;	String is printed onto the console.
;
;----------------------------------------------------------------------
mDisplayString MACRO printString
	push	edx
	mov		edx, printString
	call	WriteString
	pop		edx
ENDM

;----------------------------------------------------------------------
;Name: mDisplayChar
;
;Prints the ASCII-formatted character that is passed as an immediate or constant
;
;Preconditions: 
;	Parameter must be a valid ASCII character.
;
;Receives: 
;	char:				Character to be displayed
;
;Returns: 
;	Char is printed onto the console.
;----------------------------------------------------------------------
mDisplayChar MACRO char
	push	eax
	mov		al, char
	call	WriteChar
	pop		eax
ENDM

TEMPS_PER_DAY = 24
DELIMITER = ','

.data

programmer		BYTE	"Project 6 - String Primitives and Macros By Ethan Van Hao", 0
intro1			BYTE	"Welcome! We are here to correct the data that our itern has acquired.", 0
intro2			BYTE	"I will read a file that stores a series of temperature values separated by a delimiter.", 0
instruc1		BYTE	"The file provided must be properly ASCII-formatted. ", 0
instruc2		BYTE	"I will then reverse the order of the data and provide the correct order of temperature readings!", 0
filenamePrompt	BYTE	"Please enter the name of the file to be fixed: ", 0
results			BYTE	"Here is the proper order of the temperatures!", 0
goodbye			BYTE	"Hopefully that solved the problem, goodbye!", 0
errorMsg		BYTE	"Error opening file.", 0

filename		BYTE	50 DUP(0)
bytesRead		DWORD	?
fileBuffer		BYTE	1000 DUP(0)
fileHandle		HANDLE	?
tempArray		SDWORD	TEMPS_PER_DAY DUP(0)

.code
main PROC
	;Introductions
	mDisplayString	OFFSET programmer
	call			CrLf
	call			CrLf
	mDisplayString	OFFSET intro1
	call			CrLf
	mDisplayString	OFFSET intro2
	call			CrLf
	mDisplayString	OFFSET instruc1
	call			CrLf
	mDisplayString	OFFSET instruc2
	call			CrLf
	call			CrLf

	;Get Filename
	mGetString		OFFSET filenamePrompt, OFFSET filename, SIZEOF filename, OFFSET bytesRead

	;Open File
	mov				edx, OFFSET filename
	call			OpenInputFile
	cmp				eax, INVALID_HANDLE_VALUE
	je				error								;jump to error if INVALID_HANDLE_VALUE raises
	mov				fileHandle, eax

	;Read File
	mov				edx, OFFSET fileBuffer
	mov				ecx, LENGTHOF fileBuffer
	call			ReadFromFile
	jc				error
	mov				bytesRead, eax

	;Close File
	mov				eax, fileHandle
	call			CloseFile

	;Parse Temps Procedure Stacking
	push			OFFSET fileBuffer
	push			OFFSET tempArray
	call			ParseTempsFromString

	;Display Results
	call			CrLf
	mDisplayString	OFFSET results
	call			CrLf

	;Print Reverse Temps Procedure Stacking
	push			OFFSET tempArray
	call			WriteTempsReverse

	;End Program
	jmp				exit_program

error:
	mDisplayString	OFFSET errorMsg

exit_program:
	call			CrLf
	call			CrLf
	mDisplayString	OFFSET goodbye

	Invoke ExitProcess,0	; exit to operating system
main ENDP

;----------------------------------------------------------------------
;ParseTempsFromString
;
;Converts a string of ASCII-formatted numbers to their numeric value representations and 
;stores them into an array.
;
;Preconditions: 
;	fileBuffer contains a string with proper ASCII-formatted numbers.
;	tempArray has enough allocated space for TEMPS_PER_DAY.
;
;Postconditions: 
;	tempArray contains the converted numerical values.
;
;Receives: 
;	[EBP+12]	= fileBuffer
;	[EBP+8]		= tempArray
;	[EBP+4]		= return adress
;	[EBP]		= old ebp
;
;Returns: 
;	An array with the converted numerical value representations.
;
;----------------------------------------------------------------------

ParseTempsFromString PROC
	push			ebp
	mov				ebp, esp							;establish new stack
	pushad												

	mov				esi, [ebp+12]						;fileBuffer
	mov				edi, [ebp+8]						;tempArray
	mov				ecx, TEMPS_PER_DAY

parse_loop:
	;reset variables for new temp
	xor				eax, eax
	xor				edx, edx
	xor				ebx, ebx

	;check for negative sign
	lodsb												;load first char
	cmp				al, '-'
	jne				digit_processing
	mov				ebx, 1
	lodsb												;load next char

digit_processing:
	;convert ASCII digits to int
	cmp				al, DELIMITER
	je				store_value							;end if delimiter
	cmp				al, 0
	je				store_value							;end if null

	sub				al, '0'
	imul			edx, 10
	add				edx, eax
	lodsb
	jmp				digit_processing

store_value:
	test			ebx, ebx
	jz				positive_value						;check if neg
	neg				edx

positive_value:
	;store converted value in array
	mov				[edi], edx
	add				edi, 4

	;loop until temps are processed
	loop			parse_loop

	popad
	pop				ebp
	ret				8
ParseTempsFromString ENDP

;----------------------------------------------------------------------
;WriteTempsReverse
;
;Prints an SDWORD integer array to the console that has its integers separated by
;a delimiter character. It is printed in the reverse order that it is stored in the
;array.
;
;Preconditions: 
;	tempArray contains TEMPS_PER_DAY SDWORD integers.
;
;Postconditions: 
;	tempArray is printed in reverse order to the console.
;
;Receives: 
;	[EBP+8]		= tempArray
;	[EBP+4]		= return adress
;	[EBP]		= old ebp
;
;Returns: 
;	The tempArray is printed in reverse to the console with its elements separated by a
;	delimiter.
;
;----------------------------------------------------------------------
WriteTempsReverse PROC
	push			ebp
	mov				ebp, esp
	push			esi
	push			ecx
	push			eax

	mov				esi, [ebp+8]						;start of array
	add				esi, (TEMPS_PER_DAY-1)*4			;start at last element
	mov				ecx, TEMPS_PER_DAY

print_loop:
	;print current temp
	mov				eax, [esi]
	call			WriteInt							;display sign	

	;print delimiter
	mDisplayChar	DELIMITER

	;move to previous array element
	sub				esi, 4
	loop			print_loop

	pop				eax
	pop				ecx
	pop				esi
	pop				ebp
	ret				4
WriteTempsReverse ENDP

END main
