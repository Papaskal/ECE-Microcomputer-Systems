org 100h

jmp main



;*****************************

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

uppercases db 17 dup (?)     ;Orizoume pinaka pou 8a krataei ta kefalaia
lowercases db 17 dup (?)     ;Orizoume pinaka pou 8a krataei ta mikra
numbers db 17 dup (?)        ;Orizoume pinaka pou 8a krataei tous ari8mous

n dw 0                       ;Orizoume metablhth pou 8a metraei to plh8os twn ari8mwn
u dw 0                       ;Orizoume metablhth pou 8a metraei to plh8os twn kefalaiwn
l dw 0                       ;Orizoume metablhth pou 8a metraei to plh8os twn mikrwn
s dw 0                       ;Orizoume metablhth pou 8a metraei to plh8os olwn synolika
m db 0                       ;Orizoume metablhth pou 8a krataei to min sto teleytaio bhma

almost_eternal_loop:


mov n,0                    ;Arxikopoioume tis metablhtes
mov l,0
mov u,0
mov s,0




   
char_keyb:
cmp s,16                    ;Ean exoun do8ei 16 chars, perimenoume to [Enter]
je wait_enter
   
read                        ;Diaforetika diabazoume
cmp al,0Dh                  ;Ean einai [Enter], pername sto epomeno bhma
je break
cmp al,'*'                  ;Ean einai '*', termatizoume
je end_program
cmp al,' '                  ;Ean einai ' ' pername sto "space"
je space

cmp al,30h                  ;Ean einai ari8mos, pername sto "number"
jl char_keyb
cmp al,39h
jle number

cmp al,'A'                  ;Ean einai kefalaio, pername sto "uppercase"
jl char_keyb
cmp al,'Z'
jle uppercase

cmp al,'a'                  ;Ean einai mikro, pername sto "lowercase"
jl char_keyb
cmp al,'z'
jle lowercase

jmp char_keyb               ;Ean den einai tipota apo ta parapanw, to agnooume


space:                      ;Ean path8hke ' ', to typwnoume,
print al                    ;alla den to apo8hkeyoume pou8ena
inc s                       ;To metrame ws xarakthra (gia to orio twn 16)
jmp char_keyb             
             
number:                     ;Ean do8hke ari8mos
print al                    ;To typwnoume
inc s                       ;To metrame ws xarakthra (gia to orio twn 16)
inc n                       ;Ayksanoume to n (plh8os ari8mwn)
mov si,n                    
mov numbers [si],al         ;Kai to topo8etoume ston pinaka numbers
jmp char_keyb               ;Kai epistrefoume
                                             
                                             
uppercase:                  ;Ean do8hke kefalaio gramma
print al                    ;To typwnoume
inc s                       ;To metrame ws xarakthra (gia to orio twn 16)
inc u                       ;Ayksanoume to u (plh8os kefalaiwn)
mov si,u      
mov uppercases [si],al      ;Kai to topo8etoume ston pinaka uppercases
jmp char_keyb               ;Kai epistrefoume
                                                       
                                                       
lowercase:                  ;Ean do8hke mikro gramma
print al                    ;To typwnoume
inc s                       ;To metrame ws xarakthra (gia to orio twn 16)
inc l                       ;Ayksanoume to l (plh8os mikrwn)
mov si,l      
mov lowercases [si],al      ;Kai to topo8etoume ston pinaka lowercases
jmp char_keyb               ;Kai epistrefoume 
                
    

wait_enter:                 ;Ftanoume edw ean symplhrw8hkan 16 xarakthres
read                        ;Diabazoume apo to plhktroligio
cmp al,'*'                  ;Ean einai '*', termatizoume
je end_program
cmp al,0Dh                  ;Ean einai [Enter], pername sto epomeno bhma
jne wait_enter              ;Diaforetika, anamenoume

break:
print_string newline        ;Allazoume grammh
        
cmp u,0                     ;Ean den do8hke kanena kefalaio, prospername
je no_uppe        
        
mov dx,0
mov cx,u                    ;To loop 8a ginei u fores (opou u to plh8os twn kefalaiwn)
loop_u:                     ;Se ka8e iteration, typwnoume ena stoixeio apo ton pinaka
inc dx                      ;kai proxwrame sto epomeno
mov si,dx
mov bl, uppercases [si]
print bl             
loop loop_u         

print '-'    

no_uppe:                   
cmp l,0                    ;Ean den do8hke kanena mikro, prospername
je no_lowe    
   
mov dx,0
mov cx,l                   ;To loop 8a ginei l fores (opou l to plh8os twn mikrwn)
loop_l:                    ;Se ka8e iteration, typwnoume ena stoixeio apo ton pinaka
inc dx                     ;kai proxwrame sto epomeno
mov si,dx
mov bl, lowercases [si]
print bl             
loop loop_l             

print '-'


no_lowe:        
cmp n,0                    ;Ean den do8hke kanena ari8mos, prospername
je no_numbe         
        
mov dx,0
mov cx,n                   ;To loop 8a ginei n fores (opou n to plh8os twn ari8mwn)
loop_n:                    ;Se ka8e iteration, typwnoume ena stoixeio apo ton pinaka
inc dx                     ;kai proxwrame sto epomeno
mov si,dx
mov bl, numbers [si]
print bl             
loop loop_n             
                    
                    
print_string newline       ;Allazoume grammh 

mov bh,3Ah                 ;O ASCII 3Ah einai akribws megalyteros apo to '9'   
mov dx,0                   ;Ousiastika arxikopoioume to min sto 10
mov cx,n 
loop_min_1:                ;To loop 8a ginei n fores (opou n to plh8os twn ari8mwn)
inc dx                     ;Se ka8e iteration, pairnoume ena stoixeio
mov si,dx                  ;kai to sygkrinoume me to min (paradosiakh eyresh elaxistou)
mov bl, numbers [si]
cmp bl,bh
jnl end_min_1
mov bh,bl
mov ax,si
mov numbers [si],bl
end_min_1:             
loop loop_min_1
mov si,ax                ;Bazoume to 10d sth 8esh tou min, 
mov numbers[si],3Ah      ;wste na mhn bgei to idio sto deytero perasma       
mov m,bh                 ;Kratame thn timh tou min (sth metablhth m)
mov u,ax                 ;Kratame th 8esh tou min  (sth metablhth u)

cmp n,1                  ;Ean do8hke mono enas ari8mos, prospername
je monos_arithmos

mov bh,3Ah               ;Briskoume to neo min ston pinaka     
mov dx,0                 ;H diadikasia einai akribws idia me to prwto perasma
mov cx,n 
loop_min_2:
inc dx   
mov si,dx
mov bl, numbers [si]
cmp bl,bh
jnl end_min_2
mov bh,bl
mov ax,si
mov numbers [si],bl
end_min_2:             
loop loop_min_2             
;print bh               ;H timh tou 2ou min einai ston bh
                        ;kai h 8esh tou ston ax

cmp ax,u                ;Sygkrinoume tis 8eseis twn 2 min
jg ayksousa             ;Gia na doume poio htan prwto
print bh                ;Typwnoume analoga
monos_arithmos:
print m  
jmp no_numbe
ayksousa:
print m
print bh

                               
         
no_numbe:

print_string newline      ;Allazoume grammh
jmp almost_eternal_loop   ;Pame sthn arxh



end_program:           ;Termatizoume to programma
    mov ax,4C00h
    int 21h


newline db 0Ah,0Dh,'$'

