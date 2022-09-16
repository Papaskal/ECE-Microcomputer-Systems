org 100h

jmp main

;********* macros gnwsta apo diafaneies ***********

read macro
    mov ah,08h
    int 21h
endm

print macro char
    push ax
    push dx
    mov dl,char
    mov ah,2
    int 21h
    pop dx
    pop ax
endm

print_str macro string
    push ax
    push dx
    mov dx,offset string
    mov ah,9
    int 21h
    pop dx
    pop ax
endm

exit macro
    mov ax,4C00h
    int 21h
endm

HEX_KEYB PROC NEAR
    push dx
ignore:
    read
    cmp al,'N'
    je end_program
    
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
    
end_program:
    pop dx
    pop ax
    jmp end
HEX_KEYB ENDP
;********************************

print_dec:
    add dl,30h
    mov ah,02h
    int 21h
    
    ret
end_print_dec:


show_result:
    mov cx,0
    digit:
    mov dx,0
    mov bx,10d
    div bx
    push dx
    inc cx
    cmp ax,0
    jne digit

    dec cx
    cmp cx,0
    jz next:
    
    print_digit:
    pop dx
    call print_dec
    loop print_digit
    
next:
    print '.'
    pop dx
    call print_dec
    ret
end_show_result:

main:

print_str message

invalid_char:
mov ah,01h
int 21h
cmp al,'N'
je end
cmp al,'Y'
jne invalid_char

eternal_loop:

call HEX_KEYB
cmp al,'N'
je end
mov dh,al
call HEX_KEYB
mov dl,al
cmp al,'N'
je end
call HEX_KEYB
cmp al,'N'
je end                  ; dh = first heximal digit
                        ; dl = second heximal digit
                        ; al = third heximal digit
print_str newline_start

mov cl,4
shl dl,cl
or dl,al
mov ax,dx

cmp ax,2047		; Typos prwths perioxhs [0,2047]:
jg second_area		; T= (1000)/4095 *A/D

mov dx,10000d
mul dx
mov cx,4095d
div cx

call show_result

jmp eternal_loop

second_area:		; Typos deyterhs perioxhs [2048,3685]:
cmp ax,3685d		; T = (500/4095)*A/D + 250
jg third_area

mov dx,5000d
mul dx
mov cx,4095d
div cx
add ax,2500d

call show_result

jmp eternal_loop


third_area:		; Typos triths perioxhs [2047,4094]:
cmp ax,4095		; T = (3000/4095) *A/D - 2000
jge error

mov dx,30000d
mul dx
mov cx,4095d
div cx
sub ax,20000d


call show_result

jmp eternal_loop

error:				;8a emfanisoume error MONO sto 4095
print_str error_message

jmp eternal_loop


end:
exit


; DATA SPACE

input: db 0,0,0,0
message: db 'START(Y,N):$'
error_message: db 'ERROR$'
newline_start: db 0Ah,0Dh,'$'
newline: db 0Dh,'$'
backspaces: db 8,8,8,8,8,8,'$'

