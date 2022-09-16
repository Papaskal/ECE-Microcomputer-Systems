org 100h

jmp main
                                            
                                            
;*******************************************      

DEC_KEYB PROC NEAR
    
ignore_dec_keyb:
    read               ;Diabazoume xarakthra
    cmp al,'Q'         ;An einai 'Q', termatizoume
    je end_program
    
    cmp al,30h         ;Ean den einai anamesa sto 30h kai to 39h,
    jl ignore_dec_keyb ;agnooume to xarakthra kai pame sthn arxh
    cmp al,39h         ;(30h einai o ASCII gia to '0' kai 37h gia to '9')
    jg ignore_dec_keyb

    ;print al          ;Typwnoume ton egkyro xarakthra sthn o8onh 
       
    ;sub al,30h        ;Afairoume 30h wste na paroume ton ari8mo
                       ;apo thn ASCII anaparastash tou
    
    ret
DEC_KEYB ENDP

      
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
      
      
;***********************

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

print_string msg1         ;Typwnoume to zhtoumeno mhnyma
       
      
call DEC_KEYB             ;Diabazoume ta dekadika pshfia
mov dh,al                 ;Prwto pshfio ston dh
call DEC_KEYB
mov dl,al                 ;Deytero pshfio ston dl
call DEC_KEYB       
mov bl,al                 ;Trito pshfio ston bl


ignore:                   ;Diabazoume xarakthra
    read                  ;Ean einai to 'Q' termatizoume
    cmp al,'Q'
    je end_program
    
    cmp al,0Dh            ;Ean einai to [Enter], pername sto epomeno bhma
    je enter 
    
    cmp al,30h            ;Ean einai neo dekadiko pshfio...
    jl ignore
    cmp al,39h
    jg ignore             ;diaforetika agnooume kai perimenoume nea eisodo

    ;print al
       
    ;sub al,30h            ;(Metatrepoume apo ton ASCII kwdiko se pshfio)
                          ;...To prwhn prwto pshfio xanetai,
    mov dh,dl             ;to deytero ginetai prwto (apo dl ston dh)
    mov dl,bl,            ;to trito ginetai deytero (apo bl ston dl)
    mov bl,al             ;kai to neo ginetai trito (ston bl)
    jmp ignore            ;Sth synexeia, perimenoume nea eisodo
            
enter:                    ;Pairnoume ta pshfia se ASCII kai typwnoume
    ;add dh,30h           
    print dh
    sub dh,30h            ;Sth synexeia, metatrepoume apo ASCII se swstous ari8mous
    ;add dl,30h
    print dl              
    sub dl,30h
    ;add bl,30h
    print bl
    sub bl,30h
           

print_string newline      ;Allagh grammhs

print_string msg2         ;Typwnoume to deytero mhnyma

mov bh,0                  ;Ftiaxnoume ton eniaio dekadiko ari8mo
mov al,dl                 ;Pollaplasiazoume to prwto pshfio me 100
mov dl,10                 ;To deytero me 10 (kai to prwto me 1)
mul dl                    ;Kai pros8etoume tous 3 ari8mous dhmiougwntas
add bl,al                 ;ton eniaio tripshfio ari8mo
mov al,dh
mov ah,0
mov dh,100
mul dh
add ax,bx 

call print_hex       
             

print_string newline      ;Allazoume grammh
jmp almost_eternal_loop   ;Pame sthn arxh



end_program:              ;Termatizoume
    mov ax,4C00h
    int 21h

msg1: db 'GIVE 3 DEC DIGITS: $'
msg2: db 'HEX= $'
newline: db 0Ah,0Dh,'$'

