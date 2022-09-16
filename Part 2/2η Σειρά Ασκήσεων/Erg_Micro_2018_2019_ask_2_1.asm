org 100h

jmp main

;*******************************************

OCT_KEYB PROC NEAR

ignore_oct_keyb:
    read                    ;Diabazoume xarakthra
    cmp al,'D'              ;An einai 'D', termatizoume 
    je end_program
    
    cmp al,30h              ;Ean den einai anamesa sto 30h kai to 37h,
    jl ignore_oct_keyb      ;agnooume to xarakthra kai pame sthn arxh
    cmp al,37h              ;(30h einai o ASCII gia to '0' kai 37h gia to '7')
    jg ignore_oct_keyb
    
    print al                ;Typwnoume ton egkyro xarakthra sthn o8onh
       
    sub al,30h              ;Afairoume 30h wste na paroume ton ari8mo
                            ;apo thn ASCII anaparastash tou

    ret
OCT_KEYB ENDP

 
PRINT_DEC PROC NEAR		;Ektypwsh dekadikou ews tessarwn pshfiwn
    push ax             ;Prokyptei me diadoxikes (akeraies) diaireseis me 10
    push bx             ;Mexris otou na mhdenistei o ari8mos
    push cx
    push dx  
    
    mov cx,0
    
loop1_print_dec:		;Kratame to ekastote ypoloipo sth stoiba
	mov dx,0
	mov bx,10
	div bx
	push dx
	inc cx
	cmp ax,0
	jne loop1_print_dec

loop2_print_dec:		;Eksagoume apo th stoiba kai typwnoume
	pop dx              ;Ena ena ta pshfia
	add dx,30h
	print dl
	loop loop2_print_dec
	
	pop dx
	pop cx
	pop bx
	pop ax
ret
PRINT_DEC endp



PRINT_OCT:			;Metatroph se oktadiko 
    push ax			;1o oktadiko pshfio: LSB tou ch kai ta dyo prwta bits tou cl
    push bx			;2o oktadiko pshfio: 3 epomena bits
    push cx			;3o oktadiko pshfio: 3 teleytaia bits
    push dx
                    ;Opote kanoume diadoxika shift gia na pairnoume ka8e fora
   ; sub bh,bh      ;3bits, ara ena pshfio oktadikou
    mov ah,02h      ;Kai metatrepoume se ASCII pros8etontas 30h
    
    mov cl,2
    shl bx,cl
    
    mov dl,bh
    add dl,30h
    int 21h
    
    sub bh,bh
    mov cl,3
    shl bx,cl
    
    mov dl,bh
    add dl,30h
    int 21h
    
    sub bh,bh
    mov cl,3
    shl bx,cl
    
    mov dl,bh
    add dl,30h       
    int 21h
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret    
END_PRINT_OCT:



;********************

read macro
    mov ah,08h
    int 21h
    mov ah,0
endm

print macro char
    push dx
    push ax

    mov dl,char
    mov ah,2
    int 21h

    pop ax
    pop dx
endm

print_string macro string_address
    push ax
    push dx
    mov dx,offset string_address
    mov ah,09h
    int 21h
    pop dx
    pop ax
endm


;********************************    

main:

almost_eternal_loop:

print_string msg1     ;Typwnoume to zhtoumeno mhnyma
       
mov cl,3
mov dx,0
call OCT_KEYB        ;Diabazoume xarakthra kai dexomaste ann einai apo '0' ews '7'
mov dl,al            ;H Oct_Keyb epishs typwnei ton egkyro xarakthra
shl dx,cl            ;Kanoume shift 3 8eseis (3 bit=1 oktadiko pshfio)
call OCT_KEYB
add dl,al            ;Pros8etoume to deytero oktadiko pshfio
shl dx,cl            ;Kai pali shift
call OCT_KEYB        
add dl,al            ;Pros8etoume kai to trito pshfio
                     ;O dx periexei to tripshfio akeraio meros
              
              
print '.'              
call OCT_KEYB        ;Diabazoume kai to tetarto pshfio (to klasmatiko meros)
mov cl,al            ;kai to bazoume sto cl

print_string newline ;Allazoume grammh

print_string msg2    

mov ax,dx            ;Typwnoume to deytero mhnyma
call PRINT_DEC       ;Metatrepoume to tripshfio akeraio meros se BCD kai typwnoume
print '.'            ;Typwnoume thn ypodiastolh


mov ah,0             ;Pollaplasiazoume to (oktadiko) klasmatiko meros
mov al,cl            ;me 1000/8
mov bx,1000          ;Ousiastika 0.N*8(okt)=N, opote N/8(dec)=0.N(oct)
mul bx               ;kai pollaplasiazoume epi 1000 gia eykolia
mov bx,8
div bx          
mov bx,ax
       
mov dx,bx       
call PRINT_DEC     ;Kai typwnoume to klasmatiko meros se dekadikh morfh





print_string newline         ;Allazoume grammh
jmp almost_eternal_loop      ;Kai pame pali sthn arxh



end_program:         ;Edw ftanoume mono ean do8ei o xarakthras termatismou
                     ;kata th diarkeia anagnwshs apo to plhktrologio
                     ;Termatizoume to programma
    mov ax,4C00h
    int 21h

msg1: db 'GIVE 4 OCTAL DIGITS: $'
msg2: db 'DECIMAL: $'
newline: db 0Ah,0Dh,'$'

