;Kinhsh Lsb pros Msb kai antistrofa
;Eksodos sthn A
;An to B0 einai 1, stamatame

.include "m16def.inc"
.def temp = r16

ldi temp,low(RAMEND)     ;Arxikopoihsh stoibas
out SPL,temp             ;8eloume stoiba giati 8a xrhsimopoihsoume routines
ldi temp,high(RAMEND)    ;(kata thn klhsh routinas, apo8hkeyetai sth stoiba
out SPH,temp             ;h timh tou pc wste na mporoume na epistrepsoume)


clr temp
out DDRB,temp	;B eisodos
out PORTB,temp	;disable pull-up antistasewn

ser temp
out DDRA,temp	;A eksodos

ldi temp,0x01	
out portA, temp	;Anaboume to LSB led

rcall Delay		;Xronoka8ysterhsh 500msec

Aristera:
sbic PINB,0		
rjmp Aristera	;8a ftasoume edw ann to PINB,0 einai set

lsl temp		;Aristero shift
out portA, temp	;kai anaboume

rcall Delay 	;Xronoka8ysterhsh

cpi temp,0x80	;Elegxoume an exoume ftasei to MSB led
brne Aristera


Deksia:
sbic PINB,0
rjmp Deksia		;8a ftasoume edw ann to PINB,0 einai set


lsr temp		;Shift deksia
out portA,temp	;kai anaboume

rcall Delay		;Xronoka8ysterhsh

cpi temp,0x01	;Elegxoume an exoume ftasei to LSB led
brne Deksia
rjmp Aristera


Delay:			;Ylopoioume dikia mas routina xronoka8ysterhshs 500msec
	push r26	;Efoson exoume syxnothta 8MHz
	push r25	;Xreiazomaste 4.000.000 kykloys gia na petyxoyme
	push r24	;xronoka8ysterhsh 0.5 sec
	ldi r24,0b01010000	; R25:R24 <- 50000
	ldi r25,0b11000011	;Eena iteration pairnei 0.01 msec, opote elegxoume
	                    ;th xronoka8ysterhsh mesw tou R25:R24
	loop_delay:		;Ekteloume 50000 fores to loop me 80 kyklous
		ldi r26,19
		loop_delay_int:
			nop
			subi r26,1
			brne loop_delay_int
		sbiw r24,1
		brne loop_delay
	
	pop r24
	pop r25
	pop r26

	ret
