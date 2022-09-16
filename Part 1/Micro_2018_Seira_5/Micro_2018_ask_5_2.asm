;*****************Macros apo diafaneies**********

READ MACRO          
MOV AH,08H           
INT 21H             
ENDM

PRINT MACRO CHAR
PUSH DX
PUSH AX
MOV DL,CHAR         
MOV AH,02H          
INT 21H
POP AX
POP DX
ENDM

PRINT_STR MACRO STRING   
MOV DX,OFFSET STRING     
MOV AH,09H
INT 21H
ENDM

EXIT MACRO               
MOV AX,4C00H             
INT 21H
ENDM 
 

DATA SEGMENT 
    TABLE DB 256 DUP(?)
DATA ENDS

CODE SEGMENT
ASSUME CS:CODE,DS:DATA 


 
MAIN PROC NEAR

	MOV CX,255		;Apo8hkeyw tous zhtoumenous ari8mous ston TABLE
	MOV AL,254
	MOV BX,0
	LOOP_TABLE:
	MOV TABLE[BX],AL
	INC BX
	DEC AL
	LOOP LOOP_TABLE
	MOV TABLE[BX],255


;PART a
	MOV BX,0
	MOV AX,0
	MOV CX,0
	MOV DX,0
	LOOP_ADD:		;A8roizw ola ta artia stoixeia
	MOV DL,1H
	AND DL,TABLE[BX]
	CMP DL,0H
	JNE PERITTOS
	MOV DL,TABLE[BX]
	ADD AX,DX		;To a8roisma ston AX
	INC CL			;O CL metraei to plh8os twn artiwn ari8mwn
	PERITTOS:
	INC BX
	CMP BX,256
	JB LOOP_ADD
	
	DIV CL			;A8roisma/plh8os = mesos oros

	MOV DL,AL		;Ektypwsh se HEX
	AND DL,0F0H
	MOV CX,4
	ROL DL,CL
	CALL PRINT_HEX

	MOV DL,AL
	AND DL,0FH
	CALL PRINT_HEX

	PRINT 0AH
	PRINT 0DH
	
;PART b
	MOV BX,0
	MOV AX,0
	MOV CX,256
	MOV DX,255
	
	LOOP_COMP:		;Elegxw diadoxika olous tous ari8mous k
	CMP AL,TABLE[BX]
	JA NEXT
	MOV AL,TABLE[BX]	;An AL<k => AL=k
	NEXT:
	CMP DL,TABLE[BX]
	JB NEXT2
	MOV DL,TABLE[BX]	;An DL>k => DL=k
	NEXT2:
	INC BX
	LOOP LOOP_COMP

	MOV BL,DL

	MOV DL,AL		;Ektypwsh twn Hex ari8mwn
	AND DL,0F0H
	MOV CX,4
	ROL DL,CL
	CALL PRINT_HEX

	MOV DL,AL
	AND DL,0FH
	CALL PRINT_HEX

	PRINT ' '
	
	MOV DL,BL
	AND DL,0F0H
	MOV CX,4
	ROL DL,CL
	CALL PRINT_HEX

	MOV DL,BL
	AND DL,0FH
	CALL PRINT_HEX


	


    EXIT
MAIN ENDP

PRINT_HEX PROC NEAR		;Ektypwsh hex ari8mou
    cmp dl,9
    jg addr1p
    add dl,30h
    jmp addr2p
addr1p:
    add dl,37h
addr2p:
    print dl
    ret
PRINT_HEX endp

CODE ENDS
END MAIN
    
    