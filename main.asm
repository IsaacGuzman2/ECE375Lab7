

;***********************************************************
;*
;*	This is the TRANSMIT skeleton file for Lab 7 of ECE 375
;*
;*  	Rock Paper Scissors
;* 	Requirement:
;* 	1. USART1 communication
;* 	2. Timer/counter1 Normal mode to create a 1.5-sec delay
;***********************************************************
;*
;*	 Author: Gerardo Guzman
;*	   Date: 11/16/2022
;*
;***********************************************************

.include "m32U4def.inc"         ; Include definition file

;***********************************************************
;*  Internal Register Definitions and Constants
;***********************************************************
.def    mpr = r16               ; Multi-Purpose Register
.def	sent = r17				; Signal sent
.def	recieved = r18			; Signal Recieved
.def	TEMP = r19				; Multi-Purpose Register 2
.def    flag = r24
; Use this signal code between two boards for their game ready
.equ    SendReady = 0b11111111

;***********************************************************
;*  Start of Code Segment
;***********************************************************
.cseg                           ; Beginning of code segment

;***********************************************************
;*  Interrupt Vectors
;***********************************************************
.org    $0000                   ; Beginning of IVs
	 rjmp    INIT            	; Reset interrupt

.org	$0002
	rjmp	
.org	$003C
	rjmp	RECEIVE			; USART recieve routine
	reti

.org	

.org    $0056                   ; End of Interrupt Vectors

;***********************************************************
;*  Program Initialization
;***********************************************************
INIT:
	;Stack Pointer (VERY IMPORTANT!!!!)
	ldi	mpr, high(RAMEND)
	out	SPH, mpr

	ldi	mpr, low(RAMEND)
	out	SPL, mpr

	;I/O Ports

	;USART1
	;Set baudrate at 2400bps
	ldi	mpr, high(207)
	sts	UBRR1H,mpr

	ldi	mpr, low(207)
	sts	UBRR1L,mpr
		;Enable receiver and transmitter
	ldi	mpr, (1<<RXEN1)|(1<<TXEN1)|(1<<RXCIE1)|(0<<UCSZ12)
	sts	UCSR1B, mpr

		;Set frame format: 8 data bits, 2 stop bits
	ldi	mpr, (0<<UMSEL11)|(0<<UMSEL10)|(0<<UPM11)|(0<<UPM10)|(1<<USBS1)|(1<<UCSZ11)|(1<<UCSZ10)|(0<<UCPOL1)
	sts	UCSR1C, mpr
	;TIMER/COUNTER1
	;Set Normal mode
	ldi 	mpr, 0b00000000
	sts	TCCR1A, mpr

	ldi 	mpr, 0b00000100
	sts 	TCCR1A, mpr

	ldi 	mpr, high(0xFFFF)
	sts	OCR1AH, mpr

	ldi	mpr, low(0xFFFF)
	sts  	OCR1AL, mpr

	;Other
	sei

	;LCD Initialization
	rcall LCDInit
	rcall LCDClr
	ldi	TEMP, 16
	ldi	ZL, LOW(STRING_START << 1)
	ldi	ZH, HIGH(STRING_START << 1)

	ldi	YL, $00
	ldi	YH, $01

loop1: 
	lpm	mpr, Z+
	st	Y+, mpr
	dec	TEMP
	brne	loop1
	rcall	LCDBacklightOn
	rcall	LCDWrLn1
;***********************************************************
;*  Main Program
;***********************************************************
MAIN:

	;TODO: ???

		rjmp	MAIN

;***********************************************************
;*	Functions and Subroutines
;***********************************************************
;***********************************************************
;* SubRoutine: ReadySig
;* Description: This routine transmits the ready signal 
;*				
;***********************************************************
;***********************************************************
;* SubRoutine: Recieve
;* Description: This routine recieves and decodes what the 
;*				other board choose for R,P,S
;***********************************************************
RECEIVE:
		push	mpr ; Save states

		lds	recieved, UDR1	;Load in message from other board (ready, Input, etc.)

		;Check to see if other board is ready
		ldi	mpr, 0b11111111
		and	mpr, recieved
		breq	readyCheck		; If mpr is equal to recieved then it is sent to the readyCheck
		rjmp	CheckInput		; Jump to decode the command

readyCheck:
		cpi	recieved, SendReady 
		breq	setReadyFlag		; If ID matches then set flag to true
		clr	flag				; clear existing flag if incoming ready is not true
		rjmp	RecieveEND
		;Set Flag to true if ready signal is sent
setReadyFlag:
		ldi	flag, 0x01			; Load flag with true
		rjmp	CheckInput			; jump to input decoder

		;Decode inputs
CheckInput:
		cpi	flag, 0x01			; Check if ready flag is true
		brne	RecieveEND			; Branch to end of recieve routine
	
RecieveEND:
		pop	mpr				; restore states
		ret

;***********************************************************
;*	Stored Program Data
;***********************************************************

;-----------------------------------------------------------
; An example of storing a string. Note the labels before and
; after the .DB directive; these can help to access the data
;-----------------------------------------------------------
STRING_START:
    .DB	"Pick option     "		; Declaring data in ProgMem
STRING_END:

;***********************************************************
;*	Additional Program Includes
;***********************************************************
.include "LCDDriver.asm"		; Include the LCD Driver



