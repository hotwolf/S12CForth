#ifndef FNVDICT_COMPILED
#define FNVDICT_COMPILED
;###############################################################################
;# S12CForth - FNVDICT - Non-Volatile Dictionary and User Variables            #
;###############################################################################
;#    Copyright 2009-2016 Dirk Heisswolf                                       #
;#    This file is part of the S12CForth framework for NXP's S12C MCU          #
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
;#    This module implements the non-volatile user dictionary and user         #
;#    variables.                                                               # 
;#                                                                             #
;#                                                                             #
;#    S12CForth register assignments:                                          #
;#      IP  (instruction pounter)     = PC (subroutine theaded)                #
;#      RSP (return stack pointer)    = SP                                     #
;#      PSP (parameter stack pointer) = Y                                      #
;#  									       #
;#    Interrupts must be disabled while Y is temporarily used for other        #
;#    purposes.								       #
;#  									       #
;#    S12CForth system variables:                                              #
;#                                                                             #
;#    Non-Volatile compile strategy:                                           #
;#    The non-volatile dictionary space is allocated after scanning the flash  #
;#    memory. When the NVDICT is selected as compile target, the UDICT is      #
;#    cleared and used as a buffer for compilation. During this buffered       #
;#    compilation, the data pointer is tracked in the variable DP. The compile #
;#    pointer is tracked in the variable CP. Dictionary entries in the compile #
;#    in interpretation state. Look-ups in compile state will return address   #
;#    translated CFAs pointing to the intended location within the flash       #
;#    space. Then the compilation of a code sequence is finished, the compile  #
;#    buffer is copied into the flash as a string.                             #
;#                                                                             #
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
;# Version History:                                                            #
;#    April 23, 2009                                                           #
;#      - Initial release                                                      #
;#    October 6, 2016                                                          #
;#      - Started subroutine threaded implementation                           #
;###############################################################################
;# Required Modules:                                                           #
;#    BASE - S12CBase framework                                                #
;#    FPS    - Forth parameter stack                                           #
;#    FRS    - Forth return stack                                              #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################

;###############################################################################
;# Memory Layout                                                               #
;###############################################################################
;        
;                           FNVDICT_INFO field:
;      	                    +--------------+--------------+	     
;    	                    |   Next FNVDICT_INFO Field   | +0		  
;      	                    +--------------+--------------+	     
;                           |             DP              | +2		  
;      	                    +--------------+--------------+	     
;                           |       NVDICT_LAST_NFA       | +4
;      	                    +--------------+--------------+	     
;               
;                           NVDICT mapping:
;      	                    +--------------+--------------+	     
;          NVDIDCT_START -> |     FNVDICT_INFO Field      |
;                = $8000    +--------------+--------------+	     
;                           |              |              |
;                           |       NVDICT Section        |	     
;                           |              |              |	     
;                           |              v              |	     
;                           +--------------+--------------+	     
;                           |       Phrase Alignment      |	     
;                           +--------------+--------------+	     
;                           |    FFNVDICT_INFO Field      |
;                           +--------------+--------------+	     
;                           |              |              |
;                           |       NVDICT Section        |	     
;                           |              |              |	     
;                           |              v              |	     
;                           +--------------+--------------+	     
;                           |       Phrase Alignment      |	     
;                           +--------------+--------------+	     
;                           .	                          .
;                           .	                          .
;                        -+-+--------------+--------------+	     
;                         | |                             |	  
;     n*NVDICT_PHRASE_SIZE| |     Unprogrammed Flash      |
;                         | |                             |
;                        -+-+--------------+--------------+   
;            NVDIDCT_END -> |    Page validation Phrase   |	     
;                           +--------------+--------------+	     
;                  $C000 ->      
;   		  	    
;                           Word format:
;                           +--------------+
;                     NFA-> |   Previous   |	
;                           |     NFA      | 
;                           |              | 
;                           +--------------+
;                   NFA+2-> |     Name     | 
;                           |              | 
;                           |     MSB-     | 
;                           | terminated   | 
;                           |    string    | 
;                           |              | 
;                           +--------------+
;                      IF-> |  Info Field  |	
;                           +--------------+
;                      CF-> |              | 
;                           |  Code Field  | 
;                           |              | 
;                           +--------------+   
	
;###############################################################################
;# Configuration                                                               #
;###############################################################################
;Non-volatile dictionary 
#ifndef	NVDICT_ON
#ifndef	NVDICT_OFF
NVDICT_ON		EQU	1 		;NVDICT enabled by default
#endif
#endif

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;NVM phrase size 
NVDICT_PHRASE_SIZE	EQU	NVM_PHRASE_SIZE

;Memory boundaries
NVDICT_START		EQU	$8000			;start of the dictionary
NVDICT_END		EQU	$C000-NVDICT_PHRASE_SIZE;end of the dictionary
	
;;NVC variable 
;NVC_VOLATILE		EQU	FALSE
;NVC_NON_VOLATILE	EQU	TRUE

	
;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef FNVDICT_VARS_START_LIN
			ORG 	FNVDICT_VARS_START, FNVDICT_VARS_START_LIN
#else
			ORG 	FNVDICT_VARS_START
FNVDICT_VARS_START_LIN	EQU	@
#endif	
#ifdef NVDICT_ON	
	
#endif	
FNVDICT_VARS_END	EQU	*
FNVDICT_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization (executed along with ABORT action)
;===============
#macro	FNVDICT_INIT, 0
;#ifdef NVDICT_ON
;			LDD	NVDICT_START 		;first NVDICT word -> D
;			CPD	#$FFFF			;check if any info field exists
;			BEQ	DEFAULT			;no info field
;LOOP			TFR	D, X			;FNVDICT_INFO_NEXT -> X
;			LDD	0,X			;next info field -> D
;			CPD	#$FFFF			;check if next info field exists
;			BNE	LOOP			;iterate through all info fields
;			;Read FNVDICT_INFO field (info foeld in X) 
;			STX	FNVDICT_INFO 		;read last info field
;			MOVW	2,X, DP			;initialize DP
;			JOB	DONE			;done
;#end
;			;Default initialization
;DEFAULT			MOVW	#$0000, FNVDICT_INFO	;default initialization
;			MOVW	#UDICT_PS_START, DP	;initialize DP
;DONE			EQU	*			;done
#emac

;#Abort action (to be executed in addition of QUIT action)
;=============
#macro	FNVDICT_ABORT, 0
#emac
	
;#Quit action
;============
#macro	FNVDICT_QUIT, 0
#emac

;#System integrity monitor
;=========================
#macro	FNVDICT_MON, 0
#emac
	
;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef FNVDICT_CODE_START_LIN
			ORG 	FNVDICT_CODE_START, FNVDICT_CODE_START_LIN
#else
			ORG 	FNVDICT_CODE_START
FNVDICT_CODE_START_LIN	EQU	@
#endif

;######
;#IO
;===
;#Pause SCI communication (non-blocking)
; args:   none
; result: C-flag: set if pause entry is complete
; SSTACK: 3 bytes
;         X, Y, and D are preserved
FNVDICT_PAUSE_IO_NB	EQU	SCI_PAUSE_NB

;#Pause SCI communication (blocking)
; args:   none
; result: none
; SSTACK: 5 bytes
;         X, Y, and D are preserved
FNVDICT_PAUSE_IO_BL	EQU	SCI_PAUSE_BL

;#Resume SCI communication
; args:   none
; result: none
; SSTACK: 2 bytes
;         X, Y, and D are preserved
FNVDICT_RESUME_IO	EQU	SCI_RESUME

;#NVM
;====
;#Copy data to NVM
; args:   X: source address in RAM
;	  Y: destination address 
;	  D: number of bytes to copy
; result: C-flag: set if successful
; SSTACK: 8 bytes
;         All registers are preserved
FNVDICT_PROGRAM_NVM	EQU	NVM_PROGRAM

;#Erase NVM data
; args:   none
; result: C-flag: set if successful
; SSTACK: 6 bytes
;         All registers are preserved
FNVDICT_ERASE_NVM	EQU	NVM_ERASE

;#########
;# Words #
;#########

;;Word: NV{ ( -- )
;;Remove the UDICT and switch to the non-volatile compile strategy.
;;IF_NV_OPEN		REGULAR
;CF_NV_OPEN		EQU	*
;#ifdef NVDICT_ON
;			;Set strategy 
;			MOVW	#NV_COMPILE, STRATEGY 	;non-volatile compilation
;			;Set last NFA 
;			LDX	FNVDICT_INFO 		;current info field -> X
;			MOVW	4,X, FUDICT_LAST_NFA 	;set last NFA
;			;Reset UDICT 
;			LDD	DP 			;DP -> D
;			ADDD	#6			;skip past info field
;			STD	CP_SAVE			;DP -> CP_SAVE
;			STD	CP			;DP -> CP
;			;Set compile offset (CP in D) 
;			SUBD	[FNVDICT_INFO] 		;compile offset -> D
;			STD	FUDICT_OFFSET		;update compile offset
;#endif	
;			RTS				;done
;
;;Word: }NV ( -- )
;;Flush the NV compile buffer into the NVDICT  and switch to the volatile compile
;;strategy.
;;IF_NV_CLOSE		REGULAR
;CF_NV_CLOSE		EQU	*
;#ifdef NVDICT_ON
;			;Start to pausr communication 
;			JOBSR	FNVDICT_PAUSE_IO_NB 	;first atempt
;			;Calculate compile information
;			; +--------------+--------------+	     
;			; |  Byte Count of Compilation  | +0
;			; +--------------+--------------+	     
;			; |        Source  Address      | +2
;			; +--------------+--------------+	     
;			; |        Target Address       | +4
;			; +--------------+--------------+	     
;			; |             PSP             | +6
;			; +--------------+--------------+	     
;			LDX	FNVDICT_INFO 		;current info field -> X
;			PSHY				;PSP                -> 6,SP
;			LDD	0,X			;target address     -> D
;			PSHD				;target address     -> 4,SP
;			LDD	2,X			;source address     -> D
;			PSHD				;source address     -> 2,SP
;			LDD	CP			;CP                 -> D
;			SUBD	2,X			;byte count         -> D
;			PSHD				;byte count         -> 0,SP
;			ADDD	#(NVM_PHRASE_SIZE-1)	;align to phrase size
;			ANDB	#~(NVM_PHRASE_SIZE-1)	;
;			SUBD	FUDICT_OFFSET		;next info field    -> D
;			;Compose new info field (current info field in X, next info fiels in D))
;			; +--------------+--------------+	     
;			; |    Next FNVDICT_INFO Field  | +0		  
;			; +--------------+--------------+	     
;			; |             DP              | +2		  
;			; +--------------+--------------+	     
;			; |       NVDICT_LAST_NFA       | +4
;			; +--------------+--------------+	     
;			LDX	2,X 			;new info field -> X	
;			STD	0,X			;store next info field
;			MOVW	DP, 2,X			;store DP
;			MOVW	FUDICT_LAST_NFA, 4,X	;store last NFA
;			;Halt all communication to block interrupts 
;			JOBSR	FNVDICT_PAUSE_IO_BL 	;second atempt
;			;Copy code to NVM
;			PULD				;byte count -> D
;			PULX				;source address -> X
;			SEI				;start of atomic sequence
;			PULY				;target address -> Y
;			JOBSR	FNVDICT_PROGRAM_NVM	;copy code to NVM
;			PULY				;restore PSP
;			CLI				;end of atomic sequence
;			;Initialize NVDICT and UDICT 
;			FNVDICT_INIT 			;initialize NVDICT
;			FUDICT_INIT			;initialize UDICT
;#endif	
;			RTS

;Word: LU-NVCBUF ( c-addr u -- xt | c-addr u false )
;Look up a name in the non-volentile compile buffer. The name is referenced by
;the start address c-addr and the character count u. If successful the resulting
;execution token xt is returned. Otherwise the name reference remains on the
;parameter stack along with a false flag.
IF_LU_NVCBUF		REGULAR
CF_LU_NVCBUF		EQU	*
			MOVW	#$0000, 2,-Y
			RTS

;Word: LU-NVDICT ( c-addr u -- xt | c-addr u false )
;Look up a name in the NVDICT dictionary. The name is referenced by the start
;address c-addr and the character count u. If successful the resulting execution
;token xt is returned. Otherwise the name reference remains on the parameter
;stack along with a false flag.
;IF_LU_NVDICT		REGULAR
;CF_LU_NVDICT		EQU	*
;			;Check u ( c-addr u )
;			LDD	0,Y			;check if u is zero
;			BEQ	CF_LU_NVDICT_1 		;empty seaech string (search failed)
;			;Initialize interator structure ( c-addr u )
;			; +--------+--------+
;			; |    Iterator     | SP+0
;			; +--------+--------+
;			; | Compile Offset  | SP+2
;			; +--------+--------+
;			LDX	FNVDICT_INFO 		;current info field -> X
;			CPX	#$FFFF			;check for empty NVDICT
;			BEQ	CF_LU_NVDICT_1		;NVDICT is empty
;			LDX	4,X			;last NFA -> X
;			JMP	CF_LU_UDICT_1		;see CF_LU_UDICT
;CF_LU_NVDICT_1		MOVW	#FALSE	2,-Y		;return FALSE flag
;CF_LU_NVDICT_2		RTS				;done

;Word: WORDS-NVDICT ( -- )
;List the definition names in the NVDICT dictionary.
;IF_WORDS_NVDICT		REGULAR
;CF_WORDS_NVDICT		EQU	*
;			LDX	FNVDICT_INFO 		;current info field -> X
;			CPX	#$FFFF			;check for empty NVDICT
;			BEQ	CF_WORDS_NVDICT_1	;NVDICT is empty
;			LDX	4,X			;last NFA -> X
;			JOB	CF_WORDS_UDICT_1		;see CF_WORDS_UDICT
;CF_WORDS_NVDICT_1	EQU	CF_LU_NVDICT_2		;done
	
	
FNVDICT_CODE_END	EQU	*
FNVDICT_CODE_END_LIN	EQU	@

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef FNVDICT_TABS_START_LIN
			ORG 	FNVDICT_TABS_START, FNVDICT_TABS_START_LIN
#else
			ORG 	FNVDICT_TABS_START
FNVDICT_TABS_START_LIN	EQU	@
#endif	

FNVDICT_TABS_END		EQU	*
FNVDICT_TABS_END_LIN	EQU	@
#endif
