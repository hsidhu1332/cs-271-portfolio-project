TITLE String Primitives and Macros  (Proj6_sidhuhar.asm)

; Author: Harpaul Sidhu
; Last Modified: 12/10/2023
; OSU email address: sidhuhar@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:  6               Due Date: 12/10/2023
; Description: This program will take 10 inputs of signed numbers
;			   and make sure that they fit into a 32-bit integer.
;			   It will convert these string inputs into integers and
;			   then conver them back to strings to display them and display
;			   the sum and average of all these numbers.

INCLUDE Irvine32.inc



; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Gets a string from input and stores it
;
; Preconditions: a string and max length are estahblished
;
; Receives:
; prompt = string to prompt for input
; userInput = the string the input should be stored in
; length = string length
; bytesRead = number of bytes read from input
;
; returns: userInput string and the number of bytes the string contains
; ---------------------------------------------------------------------------------
mGetString		Macro prompt, userInput, length, bytesRead
	push	EDI
	push	EAX
	push	ECX
	push	EDX

	mov		EDX, prompt
	call	WriteString

	mov		EDX, userInput
	mov		ECX, length
	mov		EDI, bytesRead
	call	ReadString
	mov		[EDI], EAX

	pop		EDX
	pop		ECX
	pop		EAX
	pop		EDI
ENDM

; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Prints a stirng passed to it
;
; Preconditions: a string to print is established
;
; Receives:
; string = the string to print
;
; returns: a printed string
; ---------------------------------------------------------------------------------
mDisplayString	Macro string
	push	EDX

	mov		EDX, string
	call	WriteString

	pop		EDX
ENDM

.data
intro_1			BYTE   "PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures ",13,10,0
intro_2_1		BYTE   "Written by: Harpaul Sidhu",13,10,13,10,0
intro_2_2		BYTE   "Please provide 10 signed decimal integers. ",13,10,0
intro_2_3		BYTE   "Each number needs to be small enough to fit inside a 32 bit register. After you have finished inputting the raw numbers",13,10
				BYTE   "I will display a list of the integers, their sum, and their average value.",13,10,0
prompt_1		BYTE   "Please enter a signed number: ", 0
error_1			BYTE   "ERROR: You did not enter an signed number or your number was too big.",13,10
				BYTE   "Please try again: ",0
num_array		SDWORD 10 DUP(?)												; array of inputs
number			SDWORD ?														; number at current input
in_max			DWORD  15														; max length of input
in_length		DWORD  ?														; actual length of input
in_string		BYTE   16 DUP(?)												; input string
multi_factor	DWORD  1
display_nums	BYTE   "You entered the following numbers:",13,10,0
display_sum		BYTE   "The sum of these numbers is: ",0
display_avg		BYTE   "The truncated average is: ",0
goodbye_msg		BYTE   "Goodbye",0
current_num		SDWORD ?
num_stringrev	BYTE   100 DUP(?)												; string of number but reversded
num_string		BYTE   100 DUP(?)												; reversal of the reversed string
comma			BYTE   ", ",0
sum				SDWORD ?
average			SDWORD ?


.code
main PROC
	; introduction procedure
	push	OFFSET intro_1
	push	OFFSET intro_2_1
	push	OFFSET intro_2_2
	push	OFFSET intro_2_3
	call	instructions

	; setup loop for getting inputs
	mov		ECX, 10
	mov		EDI, OFFSET num_array

	_inputLoop:
		; ---------------------
		; loops to fill the array
		; with inputs
		; ---------------------
		push	OFFSET number
		push	OFFSET prompt_1
		push	OFFSET in_string
		push	in_max
		push	OFFSET in_length
		push	OFFSET error_1
		push	multi_factor
		call	ReadVal
		mov		EAX, number
		mov		[EDI], EAX
		add		EDI, 4
		loop	_inputLoop
		call	CrLf
	
	; statement for display numbers
	mDisplayString	OFFSET display_nums
	
	; setup loop to print numbers
	mov		ECX, 10
	mov		ESI, OFFSET num_array

	_print_nums:
		; ---------------------
		; loops to print the
		; numbers from the array
		; ---------------------
		mov		EBX, [ESI]
		mov		current_num, EBX
		push	OFFSET num_string
		push	OFFSET num_stringrev
		push	current_num
		call	WriteVal
		cmp		ECX, 1
		je		_no_comma
		mDisplayString	OFFSET comma
		_no_comma:
		add		ESI, 4
		loop	_print_nums
		call	CrLf
	
	; statement for sum
	mDisplayString	OFFSET display_sum
	
	; setup calculation for ssum
	mov		ESI, OFFSET num_array
	mov		EDi, OFFSET sum
	mov		ECX, 9
	mov		EAX, 0
	add		EAX, [ESI]

	; loop to get sum
	_sumLoop:
		add		ESI, 4
		add		EAX, [ESI]
		loop	_sumloop
	
	; print the sum value
	mov		[EDI], EAX
	push	OFFSET num_string
	push	OFFSET num_stringrev
	push	sum
	call	WriteVal
	call	CrLf

	; statement for the average
	mDisplayString	OFFSET display_avg

	; calculate the avearge from the sum
	mov		EAX, sum
	mov		EDX, 0
	mov		EBX, 10
	mov		ECX, 0
	cmp		EAX, 0
	jl		_negative_sum
	
	; divide the sum by 10
	_divide:
		idiv	EBX
		mov		average, EAX
		cmp		ECX, 1
		jne		_print_avg
		neg		average
	
	; print the average value
	_print_avg:
		push	OFFSET num_string
		push	OFFSET num_stringrev
		push	average
		call	WriteVal
		call	CrLf
		call	CrLf
		jmp		_done_avg

	; if the sum is negative, negate the average
	_negative_sum:
		neg		EAX
		mov		ECX, 1
		jmp		_divide

	_done_avg:
	
	;goodbye procedure
	push	OFFSET goodbye_msg
	call	goodbye

	Invoke ExitProcess,0	; exit to operating system
main ENDP


; description: prints the introduction and description
; preconditons: intro_1 and intro_2 are pushed onto the stack
; postconditions: none
; receives: [ebp+20]			intro_1 string
;			[ebp+16,12,8]		intro_2 set of strings
; returns: prints introduction and description
instructions PROC
	; stores original values on stack
	push	EBP
	mov		EBP, ESP
	
	; prints introduction
	mDisplayString		[EBP + 20]
	mDisplayString		[EBP + 16]
	mDisplayString		[EBP + 12]
	mDisplayString		[EBP + 8]
	call	CrLf
	
	; returns original values
	pop		EBP
	ret		16
instructions ENDP

; descriiption: gets the value from input and stores it in a string 
;				and converts it to an integer, this is done by
;				taking the string byte and multiplying by a factor of 10
;				starting from 1 and adding those up to get the number
; preconditons: none
; postconditions: a number is stored in the number variable
; receives	[EBP + 32]			number
;			[EBP + 28]			prompt_1
;			[EBP + 24]			in_string
;			[EBP + 20]			in_max
;			[EBP + 16]			in_length
;			[EBP + 12]			error_1
;			[EBP + 8]			multi_factor
; returns: a signed number
ReadVal PROC
	; store the orignal values
	push	EBP
	mov		EBP, ESP
	push	EDI
	push	ESI
	push	EAX
	push	EBX
	push	ECX
	push	EDX

	; print the prompt and get the number from input
	mGetString	[EBP + 28], [EBP + 24], [EBP + 20], [EBP + 16]

	_load_vars:
		; ---------------------
		; sets the intiai variables to record the number
		; also set the souce index to be at the end of the string
		; ---------------------
		mov		EAX, 0
		mov		EBX, 1
		mov		[EBP + 8], EBX
		mov		EDX, [EBP + 16]
		mov		ECX, [EDX]
		mov		ESI, [EBP + 24]
		mov		EDI, [EBP + 32]
		mov		[EDI], EAX
		add		ESI, ECX
		dec		ESI

	_get_num:
		; ---------------------
		; set direction flag to go in reverse,
		; load the final digit and multiply it by 1
		; store this number into the number variable
		; nultiply the factor by 10 and repeat for each digit
		; if the current byte is + or - jump to check for validity
		; ---------------------
		STD
		LODSB
		cmp		AL, 43					; check for + sign
		je		_positive
		cmp		AL, 45					; check for - sign
		je		_negative
		cmp		AL, 48					; if less than 48, not a number
		jl		_error
		cmp		AL, 57					; if greater than 57, not a number
		jg		_error
		sub		EAX, 48					; get the number by subtracting 48
		mov		EBX, [EBP + 8]
		mul		EBX
		add		[EDI], EAX
		js		_error					; check for overflow
		mov		EAX, [EBP + 8]
		mov		EBX, 10					; multiply multiplication factor by 10
		mul		EBX
		mov		[EBP + 8], EAX
		mov		EAX, 0
		loop	_get_num
		jmp		_done

	; check if the plus is in the first spot, if not, error
	_positive:
		cmp		ECX, 1
		jne		_error
		jmp		_done
	
	; check if the negative is in the first spot if not, error
	; negate the number variable and store it back
	_negative:
		cmp		ECX, 1
		jne		_error
		mov		EAX, [EDI]
		neg		EAX						; negate the number if needs to be
		mov		[EDI], EAX
		jmp		_done

	; any error ask for input again and print error statement
	_error:
		mov		EDX, 0
		mGetString	[EBP + 12], [EBP + 24], [EBP + 20], [EBP + 16]
		jmp		_load_vars
	
	; restore original values
	_done:
	pop		EDX
	pop		ECX
	pop		EBX
	pop		EAX
	pop		ESI
	pop		EDI
	pop		EBP
	ret		28


ReadVal ENDP

; descriiption: takes a number and converts it to a string to print it
; preconditons: an array of signed numbers is created
; postconditions: none
; receives: [EBP + 12]			current_num
;			[EBP + 8]			num_string
; returns: prints the number string
WriteVal PROC
	; local varible to calculate length and record if negative
	LOCAL div_counter: DWORD, negative: DWORD

	;store the original values
	push	EDI
	push	ESI
	push	EAX
	push	EBX
	push	ECX
	push	EDX

	; setup number and check and source and destination
	mov		div_counter, 0
	mov		negative, 0
	mov		ESI, [EBP + 8]
	mov		EDI, [EBP + 12]
	cmp		ESI, 0
	jl		_negative

	; runs for positive values and stores a negative flag
	_abs_val:
	mov		EAX, ESI
	mov		ECX, 0
	cld

	; counts the length of the number by dividing it until
	; the quotient is 0, also checks if the number is negative
	_digit_counter:
		mov		EDX, 0
		mov		EBX, 10
		idiv	EBX
		inc		ECX
		cmp		EAX, 0
		jne		_digit_counter
	
	; move the count of digits as the loop counter
	mov		div_counter, ECX
	mov		EAX, ESI

	_load_nums:
		; ---------------------
		; loops through each digit starting from
		; the last one by dividing the number by 10 and
		; storing the remainder into the string byte
		; ---------------------
		mov		EDX, 0
		mov		EBX, 10
		idiv	EBX				; divide the number by 10, remainder stored in edx
		push	EAX
		mov		EAX, EDX
		add		EAX, 48
		STOSB					; store the remainder + 48 for the ascii value
		pop		EAX
		cmp		EAX, 0			; once the quotient is 0, the number is done
		jne		_load_nums
		mov		EAX, 0
		STOSB
		jmp		_done
	
	; sets the negative flag and turns the number positive
	_negative:
		mov		negative, 1
		neg		ESI
		jmp		_abs_val

	_done:
		; ---------------------
		; sets the source to the reversed string and 
		; the destination to a new string to reverse the
		; reversed string, also store a negative sign if the flag is set
		; ---------------------
		mov		ESI, [EBP + 12]
		mov		EDI, [EBP + 16]
		cmp		negative, 1
		jne		revrev
		mov		EAX, 45
		STOSB
	
	; set the counter for the number length
	revrev:
		add		ESI, div_counter
		dec		ESI
	
	; reverse the string by changing the direction flag for each string
	; source goes backwards while they are loaded going forwards
	_revrevLoop:
		STD
		LODSB
		CLD
		STOSB
		loop	_revrevLoop
	
	CLD
	; store a null terminator
	mov		EAX, 0
	STOSB

	; print the final string
	mDisplayString		[EBP + 16]

	;retore the original values
	pop		EDX
	pop		ECX
	pop		EBX
	pop		EAX
	pop		ESI
	pop		EDI
	ret		4
WriteVal ENDP

; description: prints the goodbye strubg
; preconditons: the program has completed
; postconditions: none
; receives: [EBP + 8]		goodbye string
; returns: prints goodbye string
goodbye PROC
	push	EBP
	mov		EBP, ESP
	mDisplayString		[EBP + 8]
	pop		EBP
	ret		4
goodbye ENDP

END main
