org 100h

jmp main
     

;***********************************************************

DEC_KEYB PROC NEAR
    
ignore_dec_keyb:
    read               ;Diabazoume xarakthra
    cmp al,'P'         ;An einai 'P', termatizoume
    je end_program
    
    cmp al,30h         ;Ean den einai anamesa sto 30h kai to 39h,
    jl ignore_dec_keyb ;agnooume to xarakthra kai pame sthn arxh
    cmp al,39h         ;(30h einai o ASCII gia to '0' kai 37h gia to '9')
    jg ignore_dec_keyb
    
    print al           ;Typwnoume ton egkyro xarakthra sthn o8onh
     
    sub al,30h         ;Afairoume 30h wste na paroume ton ari8mo
                       ;apo thn ASCII anaparastash tou
    
    ret
DEC_KEYB ENDP

MORE_DIGITS_X PROC NEAR ;TO APOTELESMA STON BX, TO '+' H '-' STON AX
    push cx
    push dx
    
    mov cx,0
ignore_more_digits_x:
    read               ;Diabazoume xarakthra
    cmp al,'P'         ;An einai 'P', termatizoume
    je end_program
    cmp al,'+'         ;An einai '+', epistrefoume
    je end_more_digits_x
    cmp al,'-'         ;An einai '-', epistrefoume
    je end_more_digits_x
    
    cmp cl,3           ;An eixan hdh do8ei 3, agnooume
    je ignore_more_digits_x
    
    cmp al,30h         ;Ean den einai apo '0' ews '9', agnooume
    jl ignore_more_digits_x
    cmp al,39h
    jg ignore_more_digits_x

    mov dl,al          ;Ean einai egkyros, typwnoume
    mov ah,02h
    int 21h
    mov al,dl 
       
    sub al,30h          ;Pairnoume ton ari8mo apo thn ASCII
    mov ah,0
    xchg ax,bx          ;Pollaplasiazoume epi 10 ton prohgoumeno ari8mo
    mov dx,10           ;kai pros8etoume to neo ari8mo
    mul dx              ;(etsi leitourgei to dekadiko systhma)
    add bx,ax
    inc cx              ;Ayksanoume to metrhth pshfiwn
    jmp ignore_more_digits_x
    
    
    end_more_digits_x:  ;Ean do8hke '+' h '-', epistrefoume
    
    pop dx
    pop cx
    ret
MORE_DIGITS_X ENDP 


MORE_DIGITS_Y PROC NEAR  ;TO APOTELESMA STON DX
    push bx
    push cx 
    
    mov cx,0
ignore_more_digits_y:
    read                 ;Diabazoume xarakthra
    cmp al,'P'           ;An einai 'P', termatizoume
    je end_program
    cmp al,'='           ;An einai '=', epistrefoume
    je end_more_digits_y
    
    cmp cl,3             ;An eixan hdh do8ei 3, agnooume
    je ignore_more_digits_y
    
    cmp al,30h           ;Ean den einai apo '0' ews '9', agnooume
    jl ignore_more_digits_y
    cmp al,39h
    jg ignore_more_digits_y
    
    push dx
    
    mov dl,al
    mov ah,02h            ;Ean einai egkyros, typwnoume
    int 21h
    mov al,dl
    
    pop dx 
       
    sub al,30h            ;Pairnoume ton ari8mo apo thn ASCII
    mov ah,0              ;Pollaplasiazoume epi 10 ton prohgoumeno ari8mo
    xchg ax,dx            ;kai pros8etoume to neo ari8mo
    push dx               ;(etsi leitourgei to dekadiko systhma)
    mov bx,10
    mul bx
    pop dx
    add dx,ax
    inc cx                ;Ayksanoume to metrhth pshfiwn
    jmp ignore_more_digits_y
    
    
    end_more_digits_y:         ;Ean do8hke '=', epistrefoume
    pop cx
    pop bx
    
    ret
MORE_DIGITS_Y ENDP

                
                
PRINT_HEX PROC NEAR
    push ax                ;8a pairnoume ka8e fora 4 bits kai 8a typwnoume
    push bx                ;afou 4 dyadika bits einai ena hex pshfio
    push cx
    push dx
    
    mov dl,4
    mov dh,0
    mov cx,3
    
    loop1_print_hex:       ;Gia ta tria prwta pshfia
    mov bh,0               ;den typwnoume arxika mhdenika,
    mov bl,ah              ;dhladh den ksekiname na typwnoume mexri
    shl ax,4               ;na broume mh mhdeniko ari8mo
    shr bl,4
    cmp bl,0
    jne loop2_print_hex
    loop loop1_print_hex
    
    mov bl,ah              ;To tetarto pshfio, to typwnoume sigoura
    shr bl,4               ;Akoma kai an o telikos ari8mos einai 0000h
    mov cx,0               ;8eloume na typw8ei ena 0
    loop2_print_hex:
    inc cx
    loop3_print_hex:
    push ax
    mov ax,bx
    call print_hex_digit
    pop ax
    
    mov bh,0
    mov bl,ah
    shl ax,4
    shr bl,4
    
    loop loop3_print_hex
    
    pop dx
    pop cx
    pop bx
    pop ax
    
    ret
PRINT_HEX endp  


PRINT_HEX_DIGIT PROC NEAR		;Ektypwsh hex pshfiou
    push ax                     ;8ewroume pws dinetai egkyro pshfio
                                ;(se morfh 4 dyadikwn bit ston al)
    cmp al,9                    ;Apla pros8etoume 30h an einai apo 0 ews 9
    jg addr1_print_hex_digit
    add al,30h
    jmp addr2_print_hex_digit
addr1_print_hex_digit:
    add al,37h                  ;H 37h an einai apo A ews F
addr2_print_hex_digit:          ;Gia na prokypsei o swstos kwdikos ASCII
    print al                    ;Kai typwnoume
    
    pop ax
    ret
PRINT_HEX_DIGIT endp 
      
      
      
 
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

mov ax,0 
mov bx,0
mov cx,0
mov dx,0

call dec_keyb           ;Pairnoume to prwto pshfio tou x (apaitoume toulaxiston 1)
mov bl,al
call more_digits_x      ;Pros8etoume mexri 3 pshfia ston x kai x->[bx]
mov cl,al               ;[al]='+' h [al]='-' 
print al                ;Typwnoume to '+' h to '-'
call dec_keyb           ;Pairnoume to prwto pshfio tou y (apaitoume toulaxiston 1)
mov dl,al
call more_digits_y      ;Pros8etoume mexri 3 pshfia ston y kai y->[dx]
print '='               ;Typwnoume to '='


cmp cl,'+'              ;Ean eixe do8ei '+',
je add_xy               ;pame sthn pros8esh
sub bx,dx               ;Diaforetika eixe do8ei '-', opote afairoume

jnc thetikos
print '-'               ;Ean to apotelesma einai arnhtiko
mov ch,10               ;typwnoume '-' (kai 8etoume ena flag ston ch)
neg bx                  ;kai symplhrwnoume ws pros 2 ton ari8mo
jmp thetikos


   
add_xy:   
add bx,dx               ;Edw ftanoume an eixe do8ei '+' opote pros8etoume
      
thetikos:               ;Edw typwnoume se hex morfh
mov ax,bx
call print_hex      

print '='              ;Typwnoume '='

cmp ch,10              ;Ean [ch]=10, tote eixame arnhtiko (diaforetika 8a einai 0) 
jne thetikos_dec
print '-'              ;opote kai typwnoume '-'

thetikos_dec:      
mov dx,bx              ;Typwnoume ton ari8mos se BCD morfh
call print_dec

print_string newline   ;Allazoume grammh
jmp almost_eternal_loop  ;Ftou ki ap thn arxh



end_program:            ;Termatizoume to programma

    mov ax,4C00h
    int 21h

newline db 0Ah,0Dh,'$'

