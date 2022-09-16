*******macros gnwsta apo diafaneies************

READ MACRO          
MOV AH,08H          
INT 21H             
ENDM

PRINT MACRO CHAR    
MOV DL,CHAR         
MOV AH,02H          
INT 21H
ENDM

PRINT_STR MACRO STRING   ï
MOV DX,OFFSET STRING     
MOV AH,09H
INT 21H
ENDM

EXIT MACRO               
MOV AX,4C00H             
INT 21H
ENDM     

DATA SEGMENT
   NEW_LINE DB 0AH,0DH,'$'
DATA ENDS   

CODE SEGMENT
ASSUME CS:CODE,DS:DATA,SS:STACK

MAIN PROC FAR
    BEGIN:
    MOV CL,16     ;Loop counter gia tous xarakthres
    MOV CH,00H     
    MOV BP,2000H   ;1h 8esh mnhmhs gia na apo8hkeytoun oi xarakthres
    START:
    READ           
    CMP AL,0DH     ;An path8hke to ENTER termatizoume
    JE END
        


    CMP AL,30H     ;An exei ASCII kwdiko <30H, den einai egkyros
    JL START	   ;	
    CMP AL,5AH     ;h >5A, den einai egkyros
    JG START       
    CMP AL,3AH     ;An einai 2Fh<k<3Ah, einai ari8mos
    JL CONTINUE
    CMP AL,41H     ;An einai 41h<k<5Bh, einai kefalaio gramma
    JL START       
  CONTINUE:
    PRINT AL       ;An einai egkyros, ton typwnoume
    MOV [BP],AX    ;kai ton apo8hkeyoume
    INC BP               
    LOOP START     
    

    PRINT_STR NEW_LINE 		;allagh grammhs
	
    MOV CL,16    
    MOV BP,2000H   
    LOOP1:		;Typwnoume mono tous ari8mous
    MOV AL,[BP]    
    CMP AL,39H     
    JG NEXT1      
    PRINT AL      
    NEXT1:
    INC BP         
    LOOP LOOP1


    PRINT '-'		;Typwnw to '-'

    MOV CL,16
    MOV BP,2000H   
    LOOP2:		;Metatrepoume ta grammata se peza kai ta typwnoume
    MOV AL,[BP]    
    CMP AL,41H     
    JL NEXT2
    ADD AL,20H
    PRINT AL       
    NEXT2:
    INC BP        
    LOOP LOOP2





    PRINT_STR NEW_LINE
    JMP BEGIN      
ENDP MAIN
    END:

    EXIT 
CODE ENDS