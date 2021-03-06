#ifndef ISTACK_COMPILED
#define ISTACK_COMPILED
;###############################################################################
;# S12CBase - ISTACK - Interrupt Stack Handler                                 #
;###############################################################################
;#    Copyright 2010-2016 Dirk Heisswolf                                       #
;#    This file is part of the S12CBase framework for NXP's S12C MCU family.   #
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
;#    Early versions of S12CBase framework used to have separate stacks        #
;#    interrupt handling and subroutine calls. These two stacks have noe been  #
;#    combined to one. However the API of the separate stacks has been kept:   #
;#    => The ISTACK module implements all functions required for interrupt     #
;#       handling.                                                             #
;#    => The SSTACK module implements all functions for subroutine calls and   #
;#       temporary RAM storage.                                                #
;#                                                                             #
;#    All of the stacking functions check the upper and lower boundaries of    #
;#    the stack. Fatal errors are thrown if the stacking space is exceeded.    #
;#                                                                             #
;#    The ISTACK module no longer implements an idle loop. Instead it offers   #
;#    the macro ISTACK_WAIT to build local idle loops for drivers which        #
;#    implement blocking I/O.                                                  #
;###############################################################################
;# Version History:                                                            #
;#    April 4, 2010                                                            #
;#      - Initial release                                                      #
;#    January 8, 2011                                                          #
;#      - Combined ISTACK and SSTACK                                           #
;#    June 29, 2012                                                            #
;#      - Added support for linear PC                                          #
;#      - Added debug option "ISTACK_DEBUG"                                    #
;#      - Added option to disable stack range checks "ISTACK_NO_CHECK"         #
;#      - Added support for multiple interrupt nesting levels                  #
;#    July 27, 2012                                                            #
;#      - Added macro "ISTACK_CALL_ISR"                                        #
;#    January 16, 2016                                                         #
;#      - New generic implementation                                           #
;#    August 16, 2016                                                          #
;#      - replaced define "ISTACK_S12" by "#ifcpu"                             #
;#    Septemember 28, 2016                                                     #
;#      - S12CBASE overhaul                                                    #
;###############################################################################
;# Required Modules:                                                           #
;#    SSTACK - Subroutine stack handler                                        #
;#    RESET  - Reset handler                                                   #
;#                                                                             #
;###############################################################################
;###############################################################################
;# Stack Layout                                                                #
;###############################################################################
;        SSTACK_TOP,   +-------------------+
;        ISTACK_TOP -> |                   |
;                      |      ISTACK       |
;                      |                   |
;                      +-------------------+
;                      |                   |
;                      |                   |
;                      |                   |
;                      |                   |
;                      |      SSTACK       |
;                      |                   |
;                      |                   |
;                      |                   |
;                      |                   |
;     SSTACK_BOTTOM,   +-------------------+
;     ISTACK_BOTTOM ->

;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Wait mode when idle
;-------------------
#ifndef	ISTACK_WAI
#ifndef	ISTACK_NO_WAI
ISTACK_WAI		EQU	1 		;default is no WAI
#endif
#endif

;Range checks
;------------
;General stack range checkenable
#ifndef	ISTACK_CHECK_ON
#ifndef	ISTACK_CHECK_OFF
ISTACK_CHECK_OFF	EQU	1 		;default is off
#endif
#endif
	
;Alternative range checks for dynamic boundaries
;#mac ISTACK_BROF, 2
;	...range checking code
;#emac
;#mac ISTACK_BRUF, 2
;	...range checking code
;#emac
	
;Debug code
;----------
#ifndef	ISTACK_DEBUG_ON
#ifndef	ISTACK_DEBUG_OFF
ISTACK_DEBUG_OFF	EQU	1 		;default is off
#endif
#endif
	
;###############################################################################
;# Constants                                                                   #
;###############################################################################
;Stack allocation
;----------------
ISTACK_TOP		EQU	SSTACK_TOP
ISTACK_BOTTOM		EQU	SSTACK_BOTTOM
ISTACK_SIZE		EQU	SSTACK_SIZE

#ifcpu	S12X
;S12X stack layout:
;        +----------------+
;        |      CCRh      | SP+0
;        +----------------+
;        |      CCRl      | SP+1
;        +----------------+
;        |       B        | SP+2
;        +----------------+
;        |       A        | SP+3
;        +----------------+
;        |       Xh       | SP+4
;        +----------------+
;        |       Xl       | SP+5
;        +----------------+
;        |       Yh       | SP+6
;        +----------------+
;        |       Yl       | SP+7
;        +----------------+
;        |      RTNh      | SP+8
;        +----------------+
;        |      RTNl      | SP+9
;        +----------------+ 	
ISTACK_FRAME_SIZE	EQU	10
ISTACK_FRAME_CCR	EQU	0	
ISTACK_FRAME_D		EQU	2	
ISTACK_FRAME_X		EQU	4	
ISTACK_FRAME_Y		EQU	6	
ISTACK_FRAME_RTN	EQU	8	
#else	
;S12 stack layout:
;        +----------------+
;        |      CCR       | SP+0
;        +----------------+
;        |       B        | SP+1
;        +----------------+
;        |       A        | SP+2
;        +----------------+
;        |       Xh       | SP+3
;        +----------------+
;        |       Xl       | SP+4
;        +----------------+
;        |       Yh       | SP+5
;        +----------------+
;        |       Yl       | SP+6
;        +----------------+
;        |      RTNh      | SP+7
;        +----------------+
;        |      RTNl      | SP+8
;        +----------------+ 	
ISTACK_FRAME_SIZE	EQU	9
ISTACK_FRAME_CCR	EQU	0	
ISTACK_FRAME_D		EQU	1	
ISTACK_FRAME_X		EQU	3	
ISTACK_FRAME_Y		EQU	5	
ISTACK_FRAME_RTN	EQU	7	
#endif

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef ISTACK_VARS_START_LIN
			ORG 	ISTACK_VARS_START, ISTACK_VARS_START_LIN
#else
			ORG 	ISTACK_VARS_START
ISTACK_VARS_START_LIN	EQU	@
#endif	

ISTACK_VARS_END		EQU	*
ISTACK_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
;#--------------
#macro	ISTACK_INIT, 0
			;Set stack pointer
			LDS	#ISTACK_BOTTOM	
			;Enable interrupts
			CLI
#emac	

;#Boundary checks
;#---------------
#ifnmac ISTACK_BROF
;#Branch on stack overflow	
; args:   1: required stack capacity (bytes)
;         2: branch address
; result: none
; SSTACK: none
;         X, Y, and D are preserved
#macro	ISTACK_BROF, 2
#ifdef ISTACK_TOP	
			CPS	#ISTACK_TOP+\1 		;=> 2 cycles	 3 bytes
			BLO	\2	      		;=> 3 cycles	 4 bytes
					      		;  ---------	--------
					      		;   5 cycles	 7 bytes
#endif
#emac

#ifnmac ISTACK_BRUF
;#Branch on stack underflow	
; args:   1: required stack capacity (bytes)
;         2: branch address
; result: none
; SSTACK: none
;         X, Y, and D are preserved
#macro	ISTACK_BRUF, 2
			CPS	#ISTACK_BOTTOM+\1 	;=> 2 cycles	 3 bytes
			BHI	\2	      		;=> 3 cycles	 4 bytes
					      		;  ---------	--------
					      		;   5 cycles	 7 bytes
#emac

#ifnmac	ISTACK_PREPUSH
;#Check stack before push operation	
; args:   1: required stack capacity (bytes)
; result: none
; SSTACK: none
;         X, Y, and D are preserved
#macro	ISTACK_PREPUSH, 1 //number of bytes to push
			ISTACK_BROF	\1, OF
#ifdef	ISTACK_DEBUG_ON
			JOB	DONE
OF			BGND
DONE			EQU	*	
#else
OF			EQU	ISTACK_OF
#endif
#emac
#endif

#ifnmac	ISTACK_PREPULL
;#Check stack before pull operation	
; args:   1: expecteded stack content (bytes)
; result: none
; SSTACK: none
;         X, Y, and D are preserved
#macro	ISTACK_PREPULL, 1 //number of bytes to pull
			ISTACK_BRUF	\1, UF
#ifdef	ISTACK_DEBUG_ON
			JOB	DONE
UF			BGND
DONE			EQU	*	
#else
UF			EQU	ISTACK_UF
#endif
#emac
#endif

;#Wait until any interrupt has been serviced
; args:   none
; SSTACK: none
;         X, Y, and D are preserved
#macro	ISTACK_WAIT, 0
#ifdef	ISTACK_CHECK_ON
			ISTACK_PREPUSH	ISTACK_FRAME_SIZE
#endif
			;Wait for the next interrupt
#ifmac COP_SERVICE
			COP_SERVICE			;already taken care of by WAI
#endif
			CLI		
#ifdef	ISTACK_WAI
			WAI
#endif
#emac
	
;#Return from interrupt
; args:   none
; ISTACK: -9 (S12)/-10 (S12X)
;         X, Y, and D are pulled from the interrupt stack
#macro	ISTACK_RTI, 0
#ifdef	ISTACK_CHECK_ON
			ISTACK_PREPULL	ISTACK_FRAME_SIZE
#endif
			;End ISR
			RTI
#emac	

;#Enable interrupts if there is space for one more stack frame
; args:   none
; SSTACK: none
;         X, Y, and D are preserved
#macro	ISTACK_CLI, 0
			ISTACK_BROF ISTACK_FRAME_SIZE, DONE
			CLI
DONE			EQU	*
#emac	

;#Replace return address in stack frame
; args:   1: new return address (any address mode)
; ISTACK: none
;         X, Y, and D are preserved
#macro	ISTACK_REPLACE_RTN, 1
			MOVW	\1, ISTACK_RTN,SP
#emac	

;#Insert return address into stack frame
; args:   1: new return address (any address mode)
; ISTACK: none
;         X, Y, and D are preserved
#macro	ISTACK_INSERT_RTN, 1
#ifcpu	S12X
			MOVW	ISTACK_FRAME_CCR,SP, 2,-SP
#else			
			MOVB	ISTACK_FRAME_CCR,SP, 2,-SP
#endif
			MOVW	(2+ISTACK_FRAME_D),SP, ISTACK_FRAME_D,SP
			MOVW	(2+ISTACK_FRAME_X),SP, ISTACK_FRAME_X,SP
			MOVW	(2+ISTACK_FRAME_Y),SP, ISTACK_FRAME_Y,SP
			MOVW	\1,                    ISTACK_FRAME_RTN,SP
	
#emac	
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef ISTACK_CODE_START_LIN
			ORG 	ISTACK_CODE_START, ISTACK_CODE_START_LIN
#else
			ORG 	ISTACK_CODE_START
ISTACK_CODE_START_LIN	EQU	@
#endif
	
;#Handle stack overflows
#ifdef	ISTACK_CHECK_ON
#ifdef	ISTACK_DEBUG_OFF
ISTACK_OF		EQU	*
			RESET_FATAL	ISTACK_MSG_OF ;throw a fatal error
#endif
#endif

;#Handle stack underflows
#ifdef	ISTACK_CHECK_ON
#ifdef	ISTACK_DEBUG_OFF
ISTACK_UF		EQU	*
			RESET_FATAL	ISTACK_MSG_UF ;throw a fatal error
#endif
#endif
	
ISTACK_CODE_END		EQU	*
ISTACK_CODE_END_LIN	EQU	@
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef ISTACK_TABS_START_LIN
			ORG 	ISTACK_TABS_START, ISTACK_TABS_START_LIN
#else
			ORG 	ISTACK_TABS_START
ISTACK_TABS_START_LIN	EQU	@
#endif	

;#Error Messages
#ifdef	ISTACK_CHECK_ON
#ifdef	ISTACK_DEBUG_OFF
ISTACK_MSG_OF		RESET_MSG	"Interrupt stack overflow"
ISTACK_MSG_UF		RESET_MSG	"Interrupt stack underflow"
#endif
#endif
	
ISTACK_TABS_END		EQU	*
ISTACK_TABS_END_LIN	EQU	@
#endif
