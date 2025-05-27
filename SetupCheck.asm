TITLE VS Setup Check     (SetupCheck.asm)

; Author: 	Ethan Van Hao
; Last Modified:	1/9/2025
; Course number/section:   CS271 Section 402
; Description: This file is provided to enable you to verify your
;              VS Install is running properly.

INCLUDE Irvine32.inc

.data
Greeting		BYTE	"Welcome to the VS Setup Checker! We'll run a few things" 
				BYTE	" to make sure everything works.",13,10,0
Prompt1		BYTE	"Please enter a number in the range 1...1000000: ",0
Out1			BYTE	"Here's your value. Thanks for playing: ",0
uVal1			DWORD	0


.code
main PROC
	MOV	EDX, OFFSET Greeting
	Call	WriteString
	Call	CrLf
	MOV	EDX, OFFSET Prompt1
	Call	WriteString
	Call	ReadDec
	MOV	uVal1, EAX
	Call	CrLf
	MOV	EDX, OFFSET Out1
	Call	WriteString
	MOV	EAX, uVal1
	Call	WriteDec
	Call	CrLf
	Call	CrLf

	Invoke ExitProcess,0	; exit to operating system
main ENDP


END main
