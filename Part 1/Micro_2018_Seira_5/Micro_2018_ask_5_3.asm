org 100h

jmp main

print macro char
    push dx
    mov dl,char
    mov ah,2
    int 21h
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

read macro
    mov ah,08h
    int 21h
endm

HEX_KEYB PROC NEAR		;Diabasma hex ari8mou
    push dx
ignore:
    read
    
    cmp al,30h
    jl ignore
    cmp al,39h
    jg addr1

    sub al,30h
    jmp addr2
addr1:
    cmp al,'A'
    jl ignore
    cmp al,'F'
    jg ignore
    sub al,37h
addr2:
    pop dx
    ret
HEX_KEYB ENDP

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

PRINT_DEC_4 PROC NEAR		;Ektypwsh dekadikou tessarwn pshfiwn
    push bx
    push cx
    
    mov cx,0
    mov ax,dx
addr2d:
	mov dx,0
	mov bx,10
	div bx
	push dx
	inc dx
	inc cx
	cmp ax,0
	jne addr2d
addr3d:
	pop dx
	add dx,30h
	print dl
	loop addr3d
	
	pop cx
	pop bx
ret
PRINT_DEC_4 endp

main:
eternal_loop:

call HEX_KEYB	;1o pshfio tou x
mov bh,al
call HEX_KEYB	;2o pshfio tou x
mov bl,al

call HEX_KEYB	;1o pshfio tou y
mov ch,al
call HEX_KEYB	;2o pshfio tou y
mov cl,al

print_string msg1
mov dl,bh
call PRINT_HEX
mov dl,bl
call PRINT_HEX

print_string msg2
mov dl,ch
call PRINT_HEX
mov dl,cl
call PRINT_HEX

print_string newline

mov dx,cx	;ftiaxnw ton eniaio ari8mo y ston dl
mov cl,4
shl dl,cl
shr dx,cl

shl bl,cl	;ftiaxnw ton eniaio ari8mo x ston bl
shr bx,cl
mov cx,dx

sub bh,bh
sub ch,ch

mov dx,bx		;x+y
add dx,cx
print_string msg3
call PRINT_DEC_4

print_string msg4
mov dx,bx		;x-y
sub dx,cx
cmp bx,cx
jnb thetikos
neg dx			;an o ari8mos einai arnhtikos, pairnw to symplhrwma ws pros 2
print '-'		;kai bazw ena '-' mprosta

thetikos:
call PRINT_DEC_4

print_string newline
jmp eternal_loop

end_main:

; DATA SPACE

msg1: db 'x=$'
msg2: db ' y=$'
msg3: db 'x+y=$'
msg4: db ' x-y=$'
newline: db 0Ah,0Dh,'$'
