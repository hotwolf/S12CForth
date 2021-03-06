#ifndef FORTH_COMPILED
#define	FORTH_COMPILED
;###############################################################################
;# S12CForth - S12CForth Framework Bundle                                      #
;###############################################################################
;#    Copyright 2010-2016 Dirk Heisswolf                                       #
;#    This file is part of the S12CForth framework for NXP's S12C MCU family.  #
;#                                                                             #
;#    S12CForth is free software: you can redistribute it and/or modify        #
;#    it under the terms of the GNU General Public License as published by     #
;#    the Free Software Foundation, either version 3 of the License, or        #
;#    (at your option) any later version.                                      #
;#                                                                             #
;#    S12CForth is distributed in the hope that it will be useful,             #
;#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
;#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            #
;#    GNU General Public License for more details.                             #
;#                                                                             #
;#    You should have received a copy of the GNU General Public License        #
;#    along with S12CForth.  If not, see <http://www.gnu.org/licenses/>.       #
;###############################################################################
;# Description:                                                                #
;#   This module bundles the S12CForth framework into a single include file    #
;#   This version of S12CForth runs on the Mini-BDM-Pod.                       #
;#                                                                             #
;#    S12CForth register assignments:                                          #
;#      IP  (instruction pounter)     = PC (subroutine theaded)                #
;#      RSP (return stack pointer)    = SP                                     #
;#      PSP (parameter stack pointer) = Y                                      #
;#  									       #
;#    Interrupts must be disabled while Y is temporarily used for other        #
;#    purposes.								       #
;#  									       #
;#    The following notation is used to describe the stack layout in the word  #
;#    definitions:                                                             #
;#                                                                             #
;#    Symbol          Data type                       Size on stack	       #
;#    ------          ---------                       -------------	       #
;#    flag            flag                            1 cell		       #
;#    true            true flag                       1 cell		       #
;#    false           false flag                      1 cell		       #
;#    char            character                       1 cell		       #
;#    n               signed number                   1 cell		       #
;#    +n              non-negative number             1 cell		       #
;#    u               unsigned number                 1 cell		       #
;#    n|u 1           number                          1 cell		       #
;#    x               unspecified cell                1 cell		       #
;#    xt              execution token                 1 cell		       #
;#    addr            address                         1 cell		       #
;#    a-addr          aligned address                 1 cell		       #
;#    c-addr          character-aligned address       1 cell		       #
;#    d-addr          double address                  2 cells (non-standard)   #
;#    d               double-cell signed number       2 cells		       #
;#    +d              double-cell non-negative number 2 cells		       #
;#    ud              double-cell unsigned number     2 cells		       #
;#    d|ud 2          double-cell number              2 cells		       #
;#    xd              unspecified cell pair           2 cells		       #
;#    colon-sys       definition compilation          implementation dependent #
;#    do-sys          do-loop structures              implementation dependent #
;#    case-sys        CASE structures                 implementation dependent #
;#    of-sys          OF structures                   implementation dependent #
;#    orig            control-flow origins            implementation dependent #
;#    dest            control-flow destinations       implementation dependent #
;#    loop-sys        loop-control parameters         implementation dependent #
;#    nest-sys        definition calls                implementation dependent #
;#    i*x, j*x, k*x 3 any data type                   0 or more cells	       #
;#  									       #
;#    Counted strings are implemented as terminated strings. String            #
;#    termination is done by setting bit 7 in the last character of the        #   
;#    string. Pointers to empty strings have the value $0000.		       #
;#  									       #
;###############################################################################
;# Required Modules:                                                           #
;#     BASE   - S12CBase framework                                             #
;#     FCORE  - Forth core words                                               #
;#     FEXCPT - Forth exceptions                                               #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Version History:                                                            #
;#    February 4, 2015                                                         #
;#      - Initial release                                                      #
;#    September 28, 2016                                                       #
;#      - Started subroutine threaded implementation                           #
;###############################################################################

;###############################################################################
;# Memory Layout                                                               #
;###############################################################################
;        
;      	     DS_PS_START -> +--------------+--------------+	     
;                           |          Data Space         |	     
;                           |      Control-Flow Stack     |	     
;                           |       User Dictionary       |	     
;                           |             PAD             |	     
;                           |       Parameter Stack       |	     
;              DS_PS_END -> +--------------+--------------+        
;           RS_TIB_START -> +--------------+--------------+        
;                           |       Text Input Buffer     |
;                           |        Return Stack         |
;             RS_TIB_END -> +--------------+--------------+
	
;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Non-volatile compilation
;------------------------ 
#ifndef	NVC_ON
#ifndef	NVC_OFF
NVC_ON			EQU	1 		;NVC enabled by default
#endif
#endif
	
;#S12CBASE NUM
;------------- 
#ifndef	NUM_MAX_BASE_16
#ifndef	NUM_MAX_BASE_36
NUM_MAX_BASE_36		EQU	1 		;default is 36
#endif
#endif

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;NULL pointer
;------------ 
#ifndef NULL
NULL			EQU	$0000
#endif

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FORTH_VARS_START_LIN
			ORG 	FORTH_VARS_START, FORTH_VARS_START_LIN
#else
			ORG 	FORTH_VARS_START
#endif	

FOUTER_VARS_START	EQU	*
FOUTER_VARS_START_LIN	EQU	@
			ORG	FOUTER_VARS_END, FOUTER_VARS_END_LIN

FEXCPT_VARS_START	EQU	*
FEXCPT_VARS_START_LIN	EQU	@
			ORG	FEXCPT_VARS_END, FEXCPT_VARS_END_LIN

FRS_VARS_START		EQU	*
FRS_VARS_START_LIN	EQU	@
			ORG	FRS_VARS_END, FRS_VARS_END_LIN

FTIB_VARS_START		EQU	*
FTIB_VARS_START_LIN	EQU	@
			ORG	FTIB_VARS_END, FTIB_VARS_END_LIN

FDS_VARS_START		EQU	*
FDS_VARS_START_LIN	EQU	@
			ORG	FDS_VARS_END, FDS_VARS_END_LIN

FPS_VARS_START		EQU	*
FPS_VARS_START_LIN	EQU	@
			ORG	FPS_VARS_END, FPS_VARS_END_LIN

FNVDICT_VARS_START	EQU	*
FNVDICT_VARS_START_LIN	EQU	@
			ORG	FNVDICT_VARS_END, FNVDICT_VARS_END_LIN
	
FUDICT_VARS_START	EQU	*
FUDICT_VARS_START_LIN	EQU	@
			ORG	FUDICT_VARS_END, FUDICT_VARS_END_LIN

FPAD_VARS_START		EQU	*
FPAD_VARS_START_LIN	EQU	@
			ORG	FPAD_VARS_END, FPAD_VARS_END_LIN

FCDICT_VARS_START	EQU	*
FCDICT_VARS_START_LIN	EQU	@
			ORG	FCDICT_VARS_END, FCDICT_VARS_END_LIN

FENV_VARS_START	EQU	*
FENV_VARS_START_LIN	EQU	@
			ORG	FENV_VARS_END, FENV_VARS_END_LIN

FMON_VARS_START		EQU	*
FMON_VARS_START_LIN	EQU	@
			ORG	FMON_VARS_END, FMON_VARS_END_LIN


FDOT_VARS_START		EQU	*
FDOT_VARS_START_LIN	EQU	@
			ORG	FDOT_VARS_END, FDOT_VARS_END_LIN


FCORE_VARS_START	EQU	*
FCORE_VARS_START_LIN	EQU	@
			ORG	FCORE_VARS_END, FCORE_VARS_END_LIN

FDOUBLE_VARS_START	EQU	*
FDOUBLE_VARS_START_LIN	EQU	@
			ORG	FDOUBLE_VARS_END, FDOUBLE_VARS_END_LIN

;FFLOAT_VARS_START	EQU	*
;FFLOAT_VARS_START_LIN	EQU	@
;			ORG	FFLOAT_VARS_END, FFLOAT_VARS_END_LIN

;FTOOLS_VARS_START	EQU	*
;FTOOLS_VARS_START_LIN	EQU	@
;			ORG	FTOOLS_VARS_END, FTOOLS_VARS_END_LIN

;FFACIL_VARS_START	EQU	*
;FFACIL_VARS_START_LIN	EQU	@
;			ORG	FFACIL_VARS_END, FFACIL_VARS_END_LIN
	
FORTH_VARS_END		EQU	*	
FORTH_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;;#Busy/Idle signal 
;#ifnmac	FORTH_SIGNAL_BUSY
;#ifmac	LED_BUSY_ON
;#macro FORTH_SIGNAL_BUSY, 0
;			LED_BUSY_ON 
;#emac
;#endif	
;#endif	
;#ifnmac	FORTH_SIGNAL_IDLE
;#ifmac	LED_BUSY_OFF
;#macro FORTH_SIGNAL_IDLE, 0
;			LED_BUSY_OFF 
;#emac
;#endif	
;#endif	
	
;#Break handler
#ifnmac	SCI_BREAK_ACTION	
#macro	SCI_BREAK_ACTION, 0
	;FOUTER_INVOKE_ABORT
#emac
#endif	

;#Initialization (to be executed in addition of ABORT action)
#macro	FORTH_INIT, 0
	FOUTER_INIT
	FEXCPT_INIT
	FRS_INIT
	FTIB_INIT
	FDS_INIT
	FPS_INIT
	FNVDICT_INIT
	FUDICT_INIT
	FPAD_INIT
	FCDICT_INIT
	FENV_INIT
	FMON_INIT
	FDOT_INIT
	FCORE_INIT
	FDOUBLE_INIT
	;FFLOAT_INIT
	;FTOOLS_INIT
	;FFACIL_INIT
#emac

;#Abort action (to be executed in addition of QUIT action)
#macro	FORTH_ABORT, 0
	FOUTER_ABORT
	FEXCPT_ABORT
	FRS_ABORT
	FTIB_ABORT
	FDS_ABORT
	FPS_ABORT
	FNVDICT_ABORT
	FUDICT_ABORT
	FPAD_ABORT
	FCDICT_ABORT
	FENV_ABORT
	FMON_ABORT
	FDOT_ABORT
	FCORE_ABORT
	FDOUBLE_ABORT
	;FFLOAT_ABORT
	;FTOOLS_ABORT
	;FFACIL_ABORT
#emac
	
;#Quit action
#macro	FORTH_QUIT, 0
	FOUTER_QUIT
	FEXCPT_QUIT
	FRS_QUIT
	FTIB_QUIT
	FDS_QUIT
	FPS_QUIT
	FNVDICT_QUIT
	FUDICT_QUIT
	FPAD_QUIT
	FCDICT_QUIT
	FENV_QUIT
	FMON_QUIT
	FDOT_QUIT
	FCORE_QUIT
	FDOUBLE_QUIT
	;FFLOAT_QUIT
	;FTOOLS_QUIT
	;FFACIL_QUIT
#emac
	
;#System integrity monitor
#macro	FORTH_MON, 0
	FOUTER_MON
	FEXCPT_MON
	FRS_MON
	FTIB_MON
	FDS_MON
	FPS_MON
	FNVDICT_MON
	FUDICT_MON
	FPAD_MON
	FCDICT_MON
	FENV_MON
	FMON_MON
	FDOT_MON
	FCORE_MON
	FDOUBLE_MON
	;FFLOAT_MON
	;FTOOLS_MON
	;FFACIL_MON
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FORTH_CODE_START_LIN
			ORG 	FORTH_CODE_START, FORTH_CODE_START_LIN
#else
			ORG 	FORTH_CODE_START
#endif	

FOUTER_CODE_START	EQU	*
FOUTER_CODE_START_LIN	EQU	@
			ORG	FOUTER_CODE_END, FOUTER_CODE_END_LIN

FEXCPT_CODE_START	EQU	*
FEXCPT_CODE_START_LIN	EQU	@
			ORG	FEXCPT_CODE_END, FEXCPT_CODE_END_LIN

FRS_CODE_START		EQU	*
FRS_CODE_START_LIN	EQU	@
			ORG	FRS_CODE_END, FRS_CODE_END_LIN

FTIB_CODE_START		EQU	*
FTIB_CODE_START_LIN	EQU	@
			ORG	FTIB_CODE_END, FTIB_CODE_END_LIN

FDS_CODE_START		EQU	*
FDS_CODE_START_LIN	EQU	@
			ORG	FDS_CODE_END, FDS_CODE_END_LIN

FPS_CODE_START		EQU	*
FPS_CODE_START_LIN	EQU	@
			ORG	FPS_CODE_END, FPS_CODE_END_LIN

FNVDICT_CODE_START	EQU	*
FNVDICT_CODE_START_LIN	EQU	@
			ORG	FNVDICT_CODE_END, FNVDICT_CODE_END_LIN
	
FUDICT_CODE_START	EQU	*
FUDICT_CODE_START_LIN	EQU	@
			ORG	FUDICT_CODE_END, FUDICT_CODE_END_LIN

FPAD_CODE_START		EQU	*
FPAD_CODE_START_LIN	EQU	@
			ORG	FPAD_CODE_END, FPAD_CODE_END_LIN

FCDICT_CODE_START	EQU	*
FCDICT_CODE_START_LIN	EQU	@
			ORG	FCDICT_CODE_END, FCDICT_CODE_END_LIN

FENV_CODE_START	EQU	*
FENV_CODE_START_LIN	EQU	@
			ORG	FENV_CODE_END, FENV_CODE_END_LIN

FMON_CODE_START		EQU	*
FMON_CODE_START_LIN	EQU	@
			ORG	FMON_CODE_END, FMON_CODE_END_LIN


FDOT_CODE_START		EQU	*
FDOT_CODE_START_LIN	EQU	@
			ORG	FDOT_CODE_END, FDOT_CODE_END_LIN


FCORE_CODE_START	EQU	*
FCORE_CODE_START_LIN	EQU	@
			ORG	FCORE_CODE_END, FCORE_CODE_END_LIN

FDOUBLE_CODE_START	EQU	*
FDOUBLE_CODE_START_LIN	EQU	@
			ORG	FDOUBLE_CODE_END, FDOUBLE_CODE_END_LIN

;FFLOAT_CODE_START	EQU	*
;FFLOAT_CODE_START_LIN	EQU	@
;			ORG	FFLOAT_CODE_END, FFLOAT_CODE_END_LIN

;FTOOLS_CODE_START	EQU	*
;FTOOLS_CODE_START_LIN	EQU	@
;			ORG	FTOOLS_CODE_END, FTOOLS_CODE_END_LIN

;FFACIL_CODE_START	EQU	*
;FFACIL_CODE_START_LIN	EQU	@
;			ORG	FFACIL_CODE_END, FFACIL_CODE_END_LIN

FORTH_CODE_END		EQU	*	
FORTH_CODE_END_LIN	EQU	@
	
;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef FORTH_TABS_START_LIN
			ORG 	FORTH_TABS_START, FORTH_TABS_START_LIN
#else
			ORG 	FORTH_TABS_START
#endif	

FOUTER_TABS_START	EQU	*
FOUTER_TABS_START_LIN	EQU	@
			ORG	FOUTER_TABS_END, FOUTER_TABS_END_LIN

FEXCPT_TABS_START	EQU	*
FEXCPT_TABS_START_LIN	EQU	@
			ORG	FEXCPT_TABS_END, FEXCPT_TABS_END_LIN

FRS_TABS_START		EQU	*
FRS_TABS_START_LIN	EQU	@
			ORG	FRS_TABS_END, FRS_TABS_END_LIN

FTIB_TABS_START		EQU	*
FTIB_TABS_START_LIN	EQU	@
			ORG	FTIB_TABS_END, FTIB_TABS_END_LIN

FDS_TABS_START		EQU	*
FDS_TABS_START_LIN	EQU	@
			ORG	FDS_TABS_END, FDS_TABS_END_LIN

FPS_TABS_START		EQU	*
FPS_TABS_START_LIN	EQU	@
			ORG	FPS_TABS_END, FPS_TABS_END_LIN

FNVDICT_TABS_START	EQU	*
FNVDICT_TABS_START_LIN	EQU	@
			ORG	FNVDICT_TABS_END, FNVDICT_TABS_END_LIN
	
FUDICT_TABS_START	EQU	*
FUDICT_TABS_START_LIN	EQU	@
			ORG	FUDICT_TABS_END, FUDICT_TABS_END_LIN

FPAD_TABS_START		EQU	*
FPAD_TABS_START_LIN	EQU	@
			ORG	FPAD_TABS_END, FPAD_TABS_END_LIN

FCDICT_TABS_START	EQU	*
FCDICT_TABS_START_LIN	EQU	@
			ORG	FCDICT_TABS_END, FCDICT_TABS_END_LIN

FENV_TABS_START		EQU	*
FENV_TABS_START_LIN	EQU	@
			ORG	FENV_TABS_END, FENV_TABS_END_LIN

FMON_TABS_START		EQU	*
FMON_TABS_START_LIN	EQU	@
			ORG	FMON_TABS_END, FMON_TABS_END_LIN


FDOT_TABS_START		EQU	*
FDOT_TABS_START_LIN	EQU	@
			ORG	FDOT_TABS_END, FDOT_TABS_END_LIN

FCORE_TABS_START	EQU	*
FCORE_TABS_START_LIN	EQU	@
			ORG	FCORE_TABS_END, FCORE_TABS_END_LIN

FDOUBLE_TABS_START	EQU	*
FDOUBLE_TABS_START_LIN	EQU	@
			ORG	FDOUBLE_TABS_END, FDOUBLE_TABS_END_LIN

;FFLOAT_TABS_START	EQU	*
;FFLOAT_TABS_START_LIN	EQU	@
;			ORG	FFLOAT_TABS_END, FFLOAT_TABS_END_LIN

;FTOOLS_TABS_START	EQU	*
;FTOOLS_TABS_START_LIN	EQU	@
;			ORG	FTOOLS_TABS_END, FTOOLS_TABS_END_LIN

;FFACIL_TABS_START	EQU	*
;FFACIL_TABS_START_LIN	EQU	@
;			ORG	FFACIL_TABS_END, FFACIL_TABS_END_LIN

FORTH_TABS_END		EQU	*	
FORTH_TABS_END_LIN	EQU	@

;###############################################################################
;# Includes                                                                    #
;###############################################################################
#include ./fouter.s					;outer interpreter
#include ./fexcpt.s					;exceptions
#include ./frs.s					;return stack
#include ./ftib.s					;text input buffer
#include ./fds.s					;data space 
#include ./fps.s					;parameter stack 
#include ./fnvdict.s	 				;non-volatile dictionary
#include ./fudict.s					;user dictionary
#include ./fpad.s					;scratch pad
#include ./fcdict.s					;core dictionary
#include ./fcdict_tree.s				;core dictionary search tree
#include ./fenv.s					;environment queries
#include ./fenv_tree.s					;envuronment search tree
#include ./fmon.s					;consistency monitor
#include ./fdot.s					;print routines 
#include ./fcore.s					;core words
#include ./fdouble.s					;double-number words
;#include ./ffloat.s					;floating point words
;#include ./ftools.s					;programming tools words
;#include ./ffacil.s					;facility words
#endif
	
