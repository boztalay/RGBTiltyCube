;*******************************************************************************
;                                                                              *
;    Filename:         RGB_cube.asm                                            *
;    Date:             December 21, 2010                                       *
;    File Version:     1.0                                                     *
;                                                                              *
;    Author:           Ben Oztalay                                             *
;                                                                              *
;*******************************************************************************
;                                                                              *
;    Description:      The microcontroller will accept input from an           *
;                      accelerometer, then change the color of RGB LEDs using  *
;                      PWM to create a plexiglass cube that changes color as   *
;                      it's tilted                                             *
;                                                                              *
;*******************************************************************************
;                                                                              *
;    Revision Information:                                                     *
;                      0.1 - File created                                      *
;                      1.0 - Project Complete                                  *
;                                                                              *
;                                                                              *
;*******************************************************************************
;                                                                              *
;    Pin Assignments:  Pin 7 - AN0, Axis 1 of accelerometer      			   *
;                      Pin 6 - AN1, Axis 2 of accelerometer                    *
;                      Pin 5 - AN2, Axis 3 of accelerometer                    *
;                      Pin 3 - GP4, output, SR data                            *
;                      Pin 2 - GP5, output, SR clock                           *
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

;------------------------------------------------------------------------------
; CONFIGURATION WORD SETUP
;
; Set up for a 8 MHz clock, code protection off, brownout off, MCLR functions
; as a reset, watchdog timer is off, and GPIO 4 and 5 are I/O instead of clock
;------------------------------------------------------------------------------

     __CONFIG   _CP_OFF & _BOR_OFF & _MCLRE_ON & _WDT_OFF & _PWRTE_ON & _INTRC_OSC_NOCLKOUT

;------------------------------------------------------------------------------
; VARIABLE DEFINITIONS
;------------------------------------------------------------------------------
		UDATA
red_brt	res 1
blu_brt	res 1
grn_brt	res 1
red_on	res 1
blu_on	res 1
grn_on	res 1
steps	res 1
out_reg	res 1
temp	res 1
ADC_RESH res 1
color_sel	res 1

;------------------------------------------------------------------------------
; VECTORS
;------------------------------------------------------------------------------

;Effective reset vector
START	CODE	0x0000		; processor reset vector
		pagesel START
		goto    START       ; go to beginning of program

;Subroutine vectors

;------------------------------------------------------------------------------
; MAIN PROGRAM
;------------------------------------------------------------------------------

MAIN	CODE
START

		BANKSEL TRISIO 		;
		MOVLW 	b'001111' 	;Set GP0 to input
		MOVWF	TRISIO
		BANKSEL ANSEL		;
		MOVLW	B'01010001' ;ADC Frc/16 clock,
		MOVWF 	ANSEL 		;and GP0 as analog
		BANKSEL ADCON0 		;
		MOVLW 	B'00000111' ;Left justify,
		MOVWF 	ADCON0 		;Vdd Vref, AN0, On

		banksel GPIO		;Initialize GPIO
		clrf	GPIO	

		;reset the brightness counters
		banksel red_brt
		clrf	red_brt
		clrf	grn_brt
		clrf	blu_brt
	
		;Reset color_sel
		clrf	color_sel

cycle_top ;Main loop
		movlw	b'010000'   ;Reset all output registers to 00_01_0000		
		movwf	red_on
		movwf	grn_on
		movwf	blu_on
		clrf	steps		;Reset the steps counter
		clrf	out_reg		;Reset the output register

		banksel ADCON0
		BSF 	ADCON0,GO 	;Start conversion

step_top ;Step loop for PWM
		
		;Comparing the brightness values to the current step in the PWM cycle
		banksel steps
		movf	steps, W	;Move steps counter into W
		subwf	red_brt, W	;Subtract W (steps) from red_brt, store in W
		btfss	STATUS, C	;If the carry bit is 0 (steps > red_brt) clear red_on
		clrf	red_on		;red_on set to zero
		
		movf	steps, W	;Move steps counter into W
		subwf	grn_brt, W	;Subtract W (steps) from grn_brt, store in W
		btfss	STATUS, C	;If the carry bit is 0 (steps > grn_brt) clear grn_on
		clrf	grn_on		;grn_on set to zero

		movf	steps, W	;Move steps counter into W
		subwf	blu_brt, W	;Subtract W (steps) from blu_brt, store in W
		btfss	STATUS, C	;If the carry bit is 0 (steps > blu_brt) clear blu_on
		clrf	blu_on		;blu_on set to zero	

		;Output the RGB on/off values to the shift register
		movf	red_on, W	;Move red_on to W
		banksel GPIO
		movwf	GPIO		;Place red_on on GPIO, setting up the data to be clocked in
		bsf		GPIO, .5
		clrf	GPIO

		banksel grn_on
		movf	grn_on, W	;Move grn_on to W
		banksel GPIO
		movwf	GPIO		;Place grn_on on GPIO, setting up the data to be clocked in
		bsf		GPIO, .5
		clrf	GPIO

		banksel blu_on
		movf	blu_on, W	;Move blu_on to W
		banksel GPIO
		movwf	GPIO		;Place blu_on on GPIO, setting up the data to be clocked in
		bsf		GPIO, .5
		clrf	GPIO

		;Delay to finish up the cycle with proper timing
		movlw	.40			;Set the temporary register to 40
		banksel temp
		movwf	temp
dly1
		decfsz	temp, f		;Decrement it, if zero go out of the loop, otherwise loop back around
		goto dly1			;Makes a delay of about 120 cycles

		incfsz	steps, f	;Increment steps, if it's zero (back around past 255), skip the loop break, otherwise goto the top
		goto step_top		;Break the loop ;Disregard comments
		goto cycle_end		;Go back to the top with new steps value

cycle_end ;End of the cycle stuff, messing with brightness values before going back for another cycle
		
		banksel ADCON0
adc_tst	BTFSC 	ADCON0,NOT_DONE 	;Is conversion done?
		GOTO 	adc_tst		;No, test again
		BANKSEL ADRESH 		;
		MOVF 	ADRESH,W 	;Read upper 8 bits
		banksel ADC_RESH
		MOVWF 	ADC_RESH 	;Store in GPR space

		MOVLW	.50
		subwf	ADC_RESH,f	;Apply a negative 50 offset to the value

		rlf		color_sel	;Roll color_sel over two bits, then OR it with 01h
		rlf		color_sel
		movlw	01h
		iorwf	color_sel,W	;Then put that on ADCON0
		movwf	ADCON0		;This changes which analog input is being read
		rrf		color_sel	;Roll color_sel back
		rrf		color_sel

		banksel red_brt
		movf	color_sel,W
		sublw	.0
		btfsc	STATUS,Z
		goto 	make_red

		banksel grn_brt
		movf	color_sel,W
		sublw	.1
		btfsc	STATUS,Z
		goto 	make_grn

		banksel blu_brt
		movf	color_sel,W
		sublw	.2
		btfsc	STATUS,Z
		goto 	make_blu

make_red
		movf	ADC_RESH,W
		movwf	red_brt
		goto	continue

make_grn
		movf	ADC_RESH,W
		movwf	grn_brt
		goto	continue

make_blu
		movf	ADC_RESH,W
		movwf	blu_brt

continue
		incf	color_sel	;Increment color_sel
		movf	color_sel,W	;Put color_sel in W
		sublw	.3			;Subtract W from 3
		btfsc	STATUS,Z	;If the result wasn't 0 (color_sel != 3), then don't reset color_sel
		clrf	color_sel		

		goto	cycle_top	;Go back for another PWM cycle
			

        END