org 100h

jmp main

PRINT_DEC:			;Metatroph se dekadiko
    push ax			;Eyresh monadwn, dekadwn, ekatontadwm mesw
    push bx			;diadoxikwn diairesewn me 10d
    push cx
    push dx
    
    sub bh,bh
    mov ax,bx
    mov dl,10
    div dl
    mov dh,ah
    sub ah,ah
    
    div dl          ; al->hundreds
                    ; ah->tens
                    ; dh->units
    push ax
    mov ah,02h
    
    mov dl,al
    add dl,30h
    mov ah,02h
    int 21h
    
    pop ax
    mov dl,ah
    mov ah,02h
    
    add dl,30h
    int 21h
    xchg dh,dl
    add dl,30h
    int 21h
        
    pop dx
    pop cx
    pop bx
    pop ax
    ret
END_PRINT_DEC:

PRINT_OCT:			;Metatroph se oktadiko 
    push ax			;1o oktadiko pshfio: 0 kai ta dyo prwta pshfia tou 8-bit ari8mou
    push bx			;2o oktadiko pshfio: 3 epomena bits
    push cx			;3o oktadiko pshfio: 3 teleytaia bits
    push dx
    
    sub bh,bh
    mov ah,02h
    
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


PRINT_BIN:			;Gia na typwsw se dyadiko, apla
    push ax			;olis8ainw ton ari8mo kai ektypwnw 8 fores
    push bx
    push cx
    push dx
    
    mov cx,8
    mov ah,02h
    
for_loop:
    sub bh,bh
    shl bx,1
    mov dl,bh
    add dl,30h
    int 21h
    loop for_loop
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
END_PRINT_BIN:


;********* macros gnwsta apo diafaneies ***********

read macro
    mov ah,08h
    int 21h
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

HEX_KEYB PROC NEAR
    push dx
ignore:
    read
    cmp al,'Q'
    je end_program
    
    cmp al,30h
    jl ignore
    cmp al,39h
    jg addr1

    mov dl,al
    mov ah,02h
    int 21h
    mov al,dl 
       
    sub al,30h
    jmp addr2
addr1:
    cmp al,'A'
    jl ignore
    cmp al,'F'
    jg ignore

    mov dl,al
    mov ah,02h
    int 21h
    mov al,dl 

    sub al,37h
addr2:
    pop dx
    ret
HEX_KEYB ENDP
;********************************    

main:

almost_eternal_loop:

call HEX_KEYB
mov dh,al
call HEX_KEYB
mov dl,al

;add dl,30h
;mov ah,02h
;int 21h
;sub dl,30h

;mov cl,8
;rol dx,cl
;add dl,30h
;int 21h
;sub dl,30h

print '='

mov cl,4	;Ftiaxnw ton eniaio ari8mo kai ton apo8hkeyw sto dl
shl dl,cl
shr dx,cl

mov bl,dl

call PRINT_DEC

print '='

call PRINT_OCT

print '='

call PRINT_BIN

print_string newline
jmp almost_eternal_loop



end_program:
    pop dx
    pop ax
    mov ax,4C00h
    int 21h

newline: db 0Ah,0Dh,'$'

