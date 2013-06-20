;###############################################################################
;# S12CBase - MMAP - Memory Map (SIMHC12)                                      #
;###############################################################################
;#    Copyright 2010 Dirk Heisswolf                                            #
;#    This file is part of the S12CBase framework for Freescale's S12C MCU     #
;#    family.                                                                  #
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
;#    This module module performs all the necessary steps to initialize the    #
;#    device after each reset.                                                 #
;###############################################################################
;# Required Modules:                                                           #
;#    REGDEF - Register Definitions                                            #
;#                                                                             #
;# Requirements to Software Using this Module:                                 #
;#    - none                                                                   #
;###############################################################################
;# Version History:                                                            #
;#    November 15, 2012                                                            #
;#      - Initial release                                                      #
;###############################################################################
;  Flash Memory Map:
;  -----------------  
;                     HC12A4           
;                +-------------+ $0000       
;                |  Registers  |       
;                +-------------+ $0200      
;                |/////////////|       
;             R+ +-------------+ $0800      
;             A| |  Variables  |       
;             M+ +-------------+ $0C00      
;                |/////////////|       
;              + +-------------+ $F000
;             E| |    Code     |       
;             E| +-------------+ 
;             P| |  Tables     |       
;             R| +-------------+
;             O| |/////////////|       
;             M| +-------------+ $FFC0      
;              | |  Vectors    |       
;              + +-------------+         

;###############################################################################
;# Configuration                                                               #
;###############################################################################

;###############################################################################
;# Constants                                                                   #
;###############################################################################
;# Memory sizes
MMAP_REG_SIZE		EQU	$0200
MMAP_RAM_SIZE		EQU	$0400
MMAP_EEPROM_SIZE	EQU	$1000
	
;# Memory Locations
MMAP_REG_START		EQU	$0000
MMAP_RAM_START		EQU	$0800
MMAP_EEPROM_START	EQU	$F000
	
;###############################################################################
;# Security and Protection                                                     #
;###############################################################################

;###############################################################################
;# Variables                                                                   #
;###############################################################################
#ifdef MMAP_VARS_START_LIN
			ORG 	MMAP_VARS_START, MMAP_VARS_START_LIN
#else
			ORG 	MMAP_VARS_START
MMAP_VARS_START_LIN	EQU	@			
#endif	

MMAP_VARS_END		EQU	*
MMAP_VARS_END_LIN	EQU	@

;###############################################################################
;# Macros                                                                      #
;###############################################################################
;#Initialization
#macro	MMAP_INIT, 0
			CLR	INITRG
			MOVB	#((MMAP_RAM_START>>8)&$F8), INITRM	
			;MOVB	#(((MMAP_EEPROM_START>>8)&$F1)|$01), INITEE ;keep whatever reset value	
#emac	

;###############################################################################
;# Code                                                                        #
;###############################################################################
#ifdef MMAP_CODE_START_LIN
			ORG 	MMAP_CODE_START, MMAP_CODE_START_LIN
#else
			ORG 	MMAP_CODE_START
MMAP_CODE_START_LIN	EQU	@			
#endif	

MMAP_CODE_END		EQU	*	
MMAP_CODE_END_LIN	EQU	@	

;###############################################################################
;# Tables                                                                      #
;###############################################################################
#ifdef MMAP_TABS_START_LIN
			ORG 	MMAP_TABS_START, MMAP_TABS_START_LIN
#else
			ORG 	MMAP_TABS_START
MMAP_TABS_START_LIN	EQU	@			
#endif	

MMAP_TABS_END		EQU	*	
MMAP_TABS_END_LIN	EQU	@	

