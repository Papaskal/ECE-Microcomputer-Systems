.include "m16def.inc" 	;Orismos mikroelegkth avr ATmega16
.def temp=r18 
.def temp2=r19
.def input=r20
.def F0=r21 
.def F1=r22  
 
orismos_E_E:  
clr temp  
out DDRC,temp 	;Orizoume 8yra C ws eisodo 
out PORTC,temp 	;disable pull-up antistasewn

ser temp  
out DDRA,temp 	;Orizoume 8yra A ws eksodo


log_var:  
in input,PINC 	;Diabazw eisodo kai apo8hkeyw sto temp

mov temp,input
mov F0,temp
lsr temp
and F0,temp		;AB ston F0
mov temp2,temp
lsr temp
and	temp2,temp 	;BC ston temp2
or F0,temp2		;AB + BC ston F0
mov temp2,temp
lsr temp
and temp2,temp  ;CD ston temp2 
or F0,temp2		;AB + BC + CD ston F0
mov temp2,temp
lsr temp
and temp2,temp	;DE ston temp2
or F0,temp2		;AB + BC + CD + DE ston F0
com F0			;(AB + BC + CD + DE)' ston F0

andi F0,0x01	;Apomwnonoume to LSB me maska 0000 0001

mov temp,input
mov F1,temp		;F1 <- A
lsr temp
and F1,temp		;F1 <- AB
lsr temp
and F1,temp		;F1 <- ABC
lsr temp
and F1,temp		;F1 <- ABCD
com temp
mov temp2,temp	;temp2 <- D'
lsr temp
and temp2,temp	;temp2 <- D'E'
or F1,temp2		;F1 <- ABCD + D'E'

andi F1,0x01	;Apomwnonoume to LSB me maska 0000 0001

mov temp,F0
or temp,F1		;temp <- F0 + F1 = F2
   
Eksodos:  
			 	;Topo8etoume ta apotelesmata stis katallhles 8eseis
lsl temp  		;To F2 sto bit 2, to F1 sto 1 kai to F0 sto 0
or temp,F1    
lsl temp  
or temp,F0    

out PORTA,temp 	;Eksodos sthn A
 
rjmp log_var 	;Programma synexous leitourgias
