;*******************************************************************************
;                                                                              *
;    Filename:         delayX10ms.asm                                          *
;    Date:             December 19, 2010                                       *
;    File Version:     0.1                                                     *
;                                                                              *
;    Author:           Ben Oztalay                                             *
;                                                                              *
;*******************************************************************************
;                                                                              *
;    Architecture:     Midrange PIC                                            *
;    Processor:        PIC12F615 (probably broader range)                      *
;                                                                              *
;*******************************************************************************
;                                                                              *
;    Description:      Delays for X(10ms), where X is passed in W              *
;                                                                              *
;                                                                              *
;    					                                                       *
;                                                                              *
;    Returns:          W = 0                                                   *
;    Assumes:          4MHz clock                                              *
;                                                                              *
;*******************************************************************************
;                                                                              *
;    Copy under EXTERNALS section:						                       *
;              EXTERN  delayX10ms_R     			                           *
;                                                                              *
;    Copy under subroutine vectors section:		                               *
;          delayX10ms				                                           *
;              pagesel delayX10ms_R                                     	   *
;              goto    delayX10ms_R                                            *
;                                                                              *
;*******************************************************************************
     
     #INCLUDE <P12F615.INC>          ; processor specific variable definitions

	 GLOBAL delayX10ms_R

;------------------------------------------------------------------------------
; VARIABLE DEFINITIONS
;------------------------------------------------------------------------------
		UDATA
dc1		res 1		;delay loop counters
dc2		res 2
dc3		res 3

;------------------------------------------------------------------------------
; CODE
;------------------------------------------------------------------------------	

		CODE

delayX10ms_R
		banksel	dc3
		movwf	dc3		;W into the outmost loop's counter, which counts 10ms cycles
						;	Actual delay in each cycle is 10.015ms
dly2	movlw	.13		;Decimal 13 into the second loop's counter, which counts 767us cycles
		movwf	dc2		;	(13 X 767us = 10009us = 10.09ms)
		clrf	dc1		;Ready inner loop, set up counter for 256 cycles
dly1	decfsz	dc1,f
		goto	dly1	;End inner loop
		decfsz	dc2,f
		goto 	dly1	;End second loop
		decfsz	dc3,f
		goto	dly2	;End outer loop

		retlw	0		;Return 0 in W		

		END