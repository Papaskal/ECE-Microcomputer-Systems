.include "m16def.inc"								; prosthhkh arxeiou kefalidas gia xeirismo kataxwrhtwn eisodou - eksodou mesw twn sumvolikwn etiketwn tous
.def temp = r16
.def counter = r17									; metrhths 8 epanalhpsewn tou 0.5 sec pou xrhsimopoieitai otan o kwdikos einai lanthasmenos
.def flag = r18										; logikh metavlhth - shmaia me periexomeno: EGKUROS kwdikos: 1111 1111, AKUROS kwdikos: 0000 0000

.DSEG
_tmp_: .byte 2 

.CSEG
rjmp main


wait_usec:    
	sbiw r24 ,1
	nop
	nop
	nop
	nop
	brne wait_usec
	ret


wait_msec: 
	push r24
	push r25
	ldi r24 , low(998)
	ldi r25 , high(998)
	rcall wait_usec
	pop r25
	pop r24
	sbiw r24 , 1
	brne wait_msec
	ret


scan_row: 
	ldi r25 , 0x08
back_:
	lsl r25
	dec r24
	brne back_ 
	out PORTC , r25
	nop 
	nop
	in r24 , PINC
	andi r24 ,0x0f
	ret


scan_keypad: 
	ldi r24 , 0x01
	rcall scan_row 
	swap r24
	mov r27 , r24
	ldi r24 ,0x02
	rcall scan_row 
	add r27 , r24
	ldi r24 , 0x03
	rcall scan_row 
	swap r24
	mov r26 , r24
	ldi r24 ,0x04
	rcall scan_row 
	add r26 , r24
	movw r24 , r26
	ret


scan_keypad_rising_edge: 
	mov r22 ,r24
	rcall scan_keypad									; klhsh routinas diavasmatos plhktrologiou gia piesmenous diakoptes
	push r24											; apothukeush sth stoiva twn 16 xarakthrwn tou plhktrologiou
	push r25
	mov r24 ,r22
	ldi r25 ,0
	rcall wait_msec 
	rcall scan_keypad									; ksana klhsh routinas diavasmatos plhktrologiou gia piesmenous diakoptes
	pop r23
	pop r22 
	and r24 ,r22 
	and r25 ,r23 
	ldi r26 ,low(_tmp_)									; fortwsh katastashs diakopwn sthn PROHGOUMENH klhsh ths routinas sto zeugos kataxwrhtwn r27:r26
	ldi r27 ,high(_tmp_)
	ld r23 ,X+
	ld r22 ,X
	st X ,r24											; apothukeush sth RAM ths neas katastashs twn diakoptwn
	st -X ,r25
	com r23 
	com r22												; euresh diakoptwn pou MOLIS exoun paththei
	and r24 ,r22
	and r25 ,r23
	ret


keypad_to_ascii:
    movw r26,r24
    ldi r24,'*'
    sbrc r26,0
    ret
    ldi r24,'0'
    sbrc r26,1
    ret
    ldi r24,'#'
    sbrc r26,2
    ret
    ldi r24,'D'
    sbrc r26,3
    ret
    ldi r24,'7'
    sbrc r26,4
    ret
    ldi r24,'8'
    sbrc r26,5
    ret
    ldi r24,'9'
    sbrc r26,6
    ret
    ldi r24,'C'
    sbrc r26,7
    ret
    ldi r24,'4'
    sbrc r27,0
    ret
    ldi r24,'5'
    sbrc r27,1
    ret
    ldi r24,'6'
    sbrc r27,2
    ret
    ldi r24,'B'
    sbrc r27,3
    ret
    ldi r24,'1'
    sbrc r27,4
    ret
    ldi r24,'2'
    sbrc r27,5
    ret
    ldi r24,'3'
    sbrc r27,6
    ret
    ldi r24,'A'
    sbrc r27,7
    ret
    clr r24
    ret


;***********************************************************************************************

leds_on:												; routina anamatos twn leds ths thuras A
	ser temp
	out PORTA, temp
	ret



leds_off:												; routina svhsimatos twn leds ths thuras A
	clr temp
	out PORTA, temp
	ret


; edw kanoume synexes polling sto plhktrologio, mexri na patithei kapoio koumpi
; h plhroforia gia to koumpi pou paththike epistrefetai akrivws opws thn epistrefei kai h scan_keypad_rising_edge,
; stous kataaxwrites r24 kai r25.
wait_for_keypad:
	ldi r24, 20
	rcall scan_keypad_rising_edge
	rcall keypad_to_ascii										
	tst r24							; ean den exei paththei kanena plhktro, ksana diavase to plhktrologio
	breq wait_for_keypad
	ret

//============================================================================//
//########################### MAIN PROGRAM ###################################//
//============================================================================//

main:
	ldi temp, low(RAMEND)							; arxikopoihsh deikth stoivas, diadikasia APARAITHTH kathws exoume klhsh TOULAXISTON enos upoprogrammatos
	out spl, temp
	ldi temp, high(RAMEND)
	out sph, temp
	ldi temp, (1<<PC7)|(1<<PC6)|(1<<PC5)|(1<<PC4)	; eksodoi ta 4 MSB, eisodoi ta 4 LSB ths thura PC
	out DDRC, temp
	clr temp
	out PORTC, temp									; apenergopoihsh pull-up antistasewn (diadikasia mh aparaithth en telei)
	ser temp
	out DDRA, temp									; PORTA eksodos
	
	rcall scan_keypad_rising_edge					; klhsh gia thn arxikopoihsh tou _tmp_ se 0000
	
eternal_loop:
	ser flag										; flag <- 0xFF

	rcall wait_for_keypad							; ean den paththhke to 0, tote flag = 0
	ldi temp,'0'
	cpse r24, temp
	clr flag
													; mas exei erthei to 0 kai perimenoume to 7, wste na exoume egkurh sunolika plhktrologhsh
	rcall wait_for_keypad							; ean den paththhke to 7, tote flag = 0
	ldi temp,'7'
	cpse r24, temp
	clr flag
	
	tst flag										; ean flag = 0, o kwdikos einai lathos
	breq incorrect_password							; kai kane alma sto tmhma diaxeirhshs tou lathous
	
correct_password:									; alliws einai swstos
	rcall leds_on									; anamma twn leds ths thuras A
	
	ldi r24, low(4000)								; xronokathisterisi 4 seconds
	ldi r25, high(4000)
	rcall wait_msec
	
	rcall leds_off									; svhsimo twn leds ths thuras A
	rjmp eternal_loop								; synexis leitourgeia
	
incorrect_password:
	ldi counter, 8									; orismos plithous epanalipsewn sto 8
	
blink_loop:									
	ldi r24, low(250)
	ldi r25, high(250)
	rcall leds_on									; opote, ektelountai 8 epanalhpseis pou h kathemia
	rcall wait_msec									; krataei 0.25+0.25=0.5 sec, ara synolikos xronos 8*0.5=4 sec
	
	rcall leds_off
	ldi r24, low(250)
	ldi r25, high(250)
	rcall wait_msec
	dec counter
	brne blink_loop									; ulopoihsh domhs epanalhpshs do - while me ton metrhth counter apo to 8 ews KAI to 1 (sto 0 vgainei ektos loop)
	
	rjmp eternal_loop								; synexhs leitourgeia
