#ifndef	GPIO
#define	GPIO
;###############################################################################
;# S12CBase - GPIO - GPIO Handler (AriCalculator RevC)                         #
;###############################################################################
;#    Copyright 2010-2014 Dirk Heisswolf                                       #
;#    This file is part of the S12CBase framework for Freescale's S12(X) MCU   #
;#    families.                                                                #
;#                                                                             #
;#    S12CBase is free software: you can redistribute it and/or modify         #
;#    it under the terms of the GNU General Public License as published by     #
;#    the Free Software Foundation, either version 3 of the License, or        #
;#    (at your option) any later version.                                      #
;#                                                                             #
;#    S12CBase is distributed in the hope that it will be useful,              #
;#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
;#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
;#    GNU General Public License for more details.                             #
;#                                                                             #
;#    You should have received a copy of the GNU General Public License        #
;#    along with S12CBase.  If not, see <http://www.gnu.org/licenses/>.        #
;###############################################################################
;# Description:                                                                #
;#    This module initializes all GPIO ports of the AriCalculator hardware     #
;#    RevC (not compatible to RevA or RevB). It assumes the following I/O pin  #
;# 	configuration of the S12G MCU:                                         #
;#    Port AD:                                                                 #
;#     PAD0  - Keyboard row A (bottom)    (input        pull-up  )             #
;#     PAD1  - Keyboard row B             (input        pull-up  )             #
;#     PAD2  - Keyboard row C             (input        pull-up  )             #
;#     PAD3  - Keyboard row D             (input        pull-up  )             #
;#     PAD4  - Keyboard row E             (input        pull-up  )             #
;#     PAD5  - Keyboard row F             (input        pull-up  )             #
;#     PAD6  - Keyboard row G (top)       (input        pull-up  )             #
;#     PAD7  - NC                         (input        pull-up  )             #
;#     PAD8  - Vin                        (analog       no pull  )             #
;#     PAD9  - Vusb                       (analog       no pull  )             #
;#     PAD10 - NC                         (input        pull-up  )             # 
;#     PAD11 - NC                         (input        pull-up  )             #
;#     PAD12 - NC                         (input        pull-up  )             #
;#     PAD13 - NC                         (input        pull-up  )             #
;#     PAD14 - NC                         (input        pull-up  )             #
;#     PAD15 - NC                         (input        pull-up  )             #
;#    Port A:                                                                  #
;#     PA0 - NC                           (input        pull-up  )             #
;#     PA1 - NC                           (input        pull-up  )             #
;#     PA2 - NC                           (input        pull-up  )             #
;#     PA3 - NC                           (input        pull-up  )             #
;#     PA4 - NC                           (input        pull-up  )             #
;#     PA5 - NC                           (input        pull-up  )             #
;#     PA6 - NC                           (input        pull-up  )             #
;#     PA7 - NC                           (input        pull-up  )             #
;#    Port B:                                                                  #
;#     PB0 - NC                           (input        pull-up  )             #
;#     PB1 - NC                           (input        pull-up  )             #
;#     PB2 - NC                           (input        pull-up  )             #
;#     PB3 - NC                           (input        pull-up  )             #
;#     PB4 - NC                           (input        pull-up  )             #
;#     PB5 - NC                           (input        pull-up  )             #
;#     PB6 - NC                           (input        pull-up  )             #
;#     PB7 - NC                           (input        pull-up  )             #
;#    Port C:                                                                  #
;#     PC0 - NC                           (input        pull-up  )             #
;#     PC1 - NC                           (input        pull-up  )             #
;#     PC2 - NC                           (input        pull-up  )             #
;#     PC3 - NC                           (input        pull-up  )             #
;#     PC4 - NC                           (input        pull-up  )             #
;#     PC5 - NC                           (input        pull-up  )             #
;#     PC6 - NC                           (input        pull-up  )             #
;#     PC7 - NC                           (input        pull-up  )             #
;#    Port D:                                                                  #
;#     PD0 - NC                           (input        pull-up  )             #
;#     PD1 - NC                           (input        pull-up  )             #
;#     PD2 - NC                           (input        pull-up  )             #
;#     PD3 - NC                           (input        pull-up  )             #
;#     PD4 - NC                           (input        pull-up  )             #
;#     PD5 - NC                           (input        pull-up  )             #
;#     PD6 - NC                           (input        pull-up  )             #
;#     PD7 - NC                           (input        pull-up  )             #
;#    Port E:                                                                  #
;#     PE0 - LED (green)                  (output       high     )             #
;#     PE1 - LED (red)                    (output       high     )             #
;#    Port J:                                                                  #
;#     PJ0 - SPI port MISO                (input        pull-down)             #
;#     PJ1 - SPI port MOSI                (input        pull-down)             #
;#     PJ2 - SPI port SCK                 (input        pull-down)             #
;#     PJ3 - SPI port /SS                 (input        pull-down)             #
;#     PJ4 - NC                           (input        pull-up  )             #
;#     PJ5 - NC                           (input        pull-up  )             #
;#     PJ6 - NC                           (input        pull-up  )             #
;#     PJ7 - NC                           (input        pull-up  )             #
;#    Port M:                                                                  #
;#     PM0 - RTS                          (input        pull_down)             #
;#     PM1 - CTS                          (output       low      )             #
;#     PM2 - NC                           (input        pull_up  )             #
;#     PM3 - NC                           (input        pull_up  )             #
;#    Port P:                                                                  #
;#     PP0 - Keyboard column 5 (left)     (output       low      )             #
;#     PP1 - Keyboard column 4            (output       low      )             #
;#     PP2 - Keyboard column 3            (output       low      )             #
;#     PP3 - Keyboard column 2            (output       low      )             #
;#     PP4 - Keyboard column 1            (output       low      )             #
;#     PP5 - Keyboard column 0 (right)    (output       low      )             #
;#     PP6 - NC (used by KEYS driver)     (input        pull-up  )             #
;#     PP7 - NC (used by KEYS driver)     (input        pull-up  )             #
;#    Port S:                                                                  #
;#     PS0 - SCI RX                       (input        pull-down)             #
;#     PS1 - SCI TX                       (output       low      )             #
;#     PS2 - NC                           (input        pull-up  )             #
;#     PS3 - Display RESET                (output       low      )             #
;#     PS4 - Display A0                   (output       low      )             #
;#     PS5 - Display MOSI                 (output       low      )             #
;#     PS6 - Display SCK                  (output       low      )             #
;#     PS7 - Display /SS                  (output       high     )             #
;#    Port T:                                                                  #
;#     PT0 - SCI RX                       (input        no pull  )             #
;#     PT1 - SCI_RX                       (input        no pull  )             #
;#     PT2 - NC                           (input        pull-up  )             #
;#     PT3 - NC                           (input        pull-up  )             #
;#     PT4 - NC                           (input        pull-up  )             #
;#     PT5 - Backlight enable             (output       low      )             #
;#     PT6 - NC                           (input        pull-up  )             #
;#     PT7 - NC                           (input        pull-up  )             #
;###############################################################################
;# Required Modules:                                                           #
;#    REGDEF - Register Definitions                                            #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Version History:                                                            #
;#    August 12, 2014                                                          #
;#      - Initial release                                                      #
;#  	  (based on the S12CBase GPIO handler for the S12G-Mini-EVB)           #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################

;###############################################################################
;# Variables                                                                   #
;###############################################################################
			ORG 	GPIO_VARS_START, GPIO_VARS_START_LIN

GPIO_VARS_END		EQU	*
GPIO_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	GPIO_INIT, 0
		;#Urgent initializations
		MOVB	#03, PPSS 				;switch to pull-downs on PS[1:0] (TX/RX)	
		;#Port AD
		MOVW	#%1111_1100_1111_1111, ATDDIEN   	;switch unused pins to digital
		;MOVW	#$0000, PT0AD
		;MOVW	#$0000, DDR0AD
		MOVW	#%1111_1100_1111_1111, PER0AD
		;MOVW	#$0000, PPS0AD
		;MOVW	#$0000, PIE0AD
		;#Port A, B, C, D, and E
		;MOVW	#$0000, PORTA				;port A/B
		;MOVW	#$0000, DDRA				;port A/B
		;MOVW	#$0000, PORTC				;port C/D
		;MOVW	#$0000, DDRC				;port C/D
		MOVW	#$0303, PORTE 				;port E (PORTE/DDRE)
		MOVB	#$4F,   PUCR				;BKPUE|~PDPEE|PUPDE|PUPCE|PUPBE|PUPAE
		;MOVB	#$C0,   ECLKCTL
		;MOVB	#$00,	IRQCR
		;#Port J
		;MOVB	#$00,   PTJ 			
		;MOVB	#$00,   DDRJ 			
		;MOVB	#$FF	PERJ
		MOVB	#$0F,   PPSJ 			
		;MOVB	#$00FF,	PIEJ				;PIEJ/PIFJ 			
		;#Port M
		;MOVB	#$00,   PTM 			
		MOVB	#$02,   DDRM 			
		MOVW	#$0D01	PERM 				;PERM/PPSM
		;MOVB	#$02,	WOMM
		;#Port P
		;MOVB	#$00,   PTP 			
		MOVB	#$3F,   DDRP 				;drive keyboard columns low
		MOVB	#$FF	PERP
		;MOVB	#$00,   PPSP 			
		;MOVB	#$00FF,	PIEP				;PIEP/PIFP 			
		;#Port S
		MOVB	#$80, 	PTS	
		MOVB	#$FA, 	DDRS
		MOVW	#$0A01, PERS 				;PERS/PPSS
		;MOVB	#$02,	WOMS
		;#Port T
		MOVB	#$20,   PTT 			
		MOVB	#$20,   DDRT 			
		MOVB	#$DC	PERT
		;MOVB	#$00,   PPST 			

		;General setup
		LDAA	#MODC					;lock MODE register into NSC mode
		STAA	MODE		
		STAA	MODE
		MOVB	PKGCR, PKGCR 				;lock PKGCR
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
			ORG 	GPIO_CODE_START, GPIO_CODE_START_LIN

GPIO_CODE_END		EQU	*	
GPIO_CODE_END_LIN	EQU	@	

;###############################################################################
;# Tables                                                                      #
;###############################################################################
			ORG 	GPIO_TABS_START, GPIO_TABS_START_LIN

GPIO_TABS_END		EQU	*	
GPIO_TABS_END_LIN	EQU	@	
#endif
