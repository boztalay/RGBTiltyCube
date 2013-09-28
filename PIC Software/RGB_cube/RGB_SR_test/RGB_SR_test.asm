;*******************************************************************************
;                                                                              *
;    Filename:         xxx.asm                                                 *
;    Date:                                                                     *
;    File Version:                                                             *
;                                                                              *
;    Author:                                                                   *
;                                                                              *
;*******************************************************************************
;                                                                              *
;    Description:                                                 			   *
;                                                                              *
;                                                                              *
;                                                                              *
;                                                                              *
;*******************************************************************************
;                                                                              *
;    Revision Information:                                                     *
;                                                                              *
;                                                                              *
;                                                                              *
;                                                                              *
;*******************************************************************************
;                                                                              *
;    Pin Assignments:                                     					   *
;                                                                              *
;*******************************************************************************

;------------------------------------------------------------------------------
; PROCESSOR DECLARATION
;------------------------------------------------------------------------------

     LIST      p=12F615              ; list directive to define processor
     #INCLUDE <P12F615.INC>          ; processor specific variable definitions

;------------------------------------------------------------------------------
; EXTERNALS
;------------------------------------------------------------------------------
	EXTERN  delayX10ms_R 

;------------------------------------------------------------------------------
; CONFIGURATION WORD SETUP
;
; Set up for a 4 MHz clock, code protection off, brownout off, MCLR functions
; as a reset, watchdog timer is off, and GPIO 4 and 5 are I/O instead of clock
;------------------------------------------------------------------------------

     __CONFIG   _CP_OFF & _BOR_OFF & _MCLRE_ON & _WDT_OFF & _PWRTE_ON & _INTRC_OSC_NOCLKOUT

;------------------------------------------------------------------------------
; VARIABLE DEFINITIONS
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; VECTORS
;------------------------------------------------------------------------------

;Effective reset vector
START	CODE	0x0000		; processor reset vector
		pagesel START
		goto    START       ; go to beginning of program

;Subroutine vectors
delayX10ms				                                           
		pagesel delayX10ms_R                                     	   
		goto    delayX10ms_R 

;------------------------------------------------------------------------------
; MAIN PROGRAM
;------------------------------------------------------------------------------

MAIN	CODE
START
		
		;Initialize I/O as general-purpose digital, default outputs
		BANKSEL	GPIO		;
		CLRF	GPIO		;Init GPIO
		BANKSEL	ANSEL		;
		CLRF	ANSEL		;digital I/O, ADC clock
							;setting ‘don’t care’
		MOVLW	b'001111'	;All GPIO as outputs (except GP3)
		MOVWF	TRISIO
		BANKSEL	GPIO		;GPIO register and port ready to use

loop	
		movlw	b'010000'
		movwf	GPIO

		movlw	b'110000'
		movwf	GPIO
		movlw	b'010000'
		movwf	GPIO

		movlw	.50
		call	delayX10ms

		movlw	b'110000'
		movwf	GPIO
		movlw	b'010000'
		movwf	GPIO

		movlw	.50
		call	delayX10ms

		movlw	b'110000'
		movwf	GPIO
		movlw	b'010000'
		movwf	GPIO

		movlw	.50
		call	delayX10ms

		movlw	b'000000'
		movwf	GPIO
		movlw	b'100000'
		movwf	GPIO
		movlw	b'000000'
		movwf	GPIO

		movlw	.50
		call	delayX10ms

		movlw	b'100000'
		movwf	GPIO
		movlw	b'000000'
		movwf	GPIO

		movlw	.50
		call	delayX10ms

		movlw	b'100000'
		movwf	GPIO
		movlw	b'000000'
		movwf	GPIO

		goto	loop
		
		goto	$

        END