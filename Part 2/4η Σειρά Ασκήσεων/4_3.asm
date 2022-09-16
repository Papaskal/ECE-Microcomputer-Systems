;8etoume ton prescaler na diairei/epivradunei th suxnothta tou rologiou ths cpu (8MHz) me to 1024: 8MHz / 1024 = 7812,5 Hz.

;Me auth thn epilogh, o 16bitos TimerCouNTer register TCNT1 gia na:
;a. uperxeilhsei sta 0,5 secs, tha prepei na metrhsei 0,5 * 7812,5 = 3906,25 kuklous
;b. uperxeilhsei sta 2,5 secs, tha prepei na metrhsei 2,5 * 7812,5 = 19531,25 kuklous
;c.	uperxeilhsei sta 3,0 secs, tha prepei na metrhsei 3 * 7812,5 = 23437,5 kuklous

;Wstoso, o TCNT1 uperxeilizei molis metrhsei 65536 (0x0000 ->...-> 0xFFFF -> 0x0000)
;ara, oi swstes ARXIKES times pou prepei na tou dothoun prin ksekinhsei na metraei pros ta panw einai:
;a. halfSec = 65536 - 3906,25 = 61629,75 ~ 61629
;b. twoAndHalfSec = 65536 - 19531,25 = 46005,75 ~ 46005
;c. threeSec = 65536 - 23437,5 = 42098,5 ~ 42098

.include "m16def.inc"							
.def temp = r16									
.def leds = r17
.def flag = r18							

.equ twoAndHalfSec = 46005			;Orismos statherwn timwn pou tha odhghthoun ston 16bito xronisth Timer 1
.equ halfSec = 61629				;me vash thn parapanw sullogistikh poreia
.equ threeSec = 42098

.org 0								;Orismos dianusmatwn arxikopoihshs, ekswterikhs diakophs kai diakophs xronisth
rjmp reset
.org 2
rjmp INT0_rout
.org 0x10
rjmp timer1_rout

reset:
	ldi temp, high(ramend)			;Arxikopoihsh deikth stoivas, wste na deixnei sto telos ths SRAM, diadikasia APARAITHTH efoson
	out sph, temp					;Exoume klhsh estw enos upoprogrammatos h exoume energopoihsei thn uposthriksh diakopwn
	ldi temp, low(ramend)
	out spl, temp
	
    clr temp
	out ddrB, temp					;Oi thures B kai D thures eisodou dedomenwn
	out ddrD, temp
	out portB, temp					;Disable ta pull-up resistors
	out portD, temp
	out TCCR1B, temp                ;Sigoureyomaste pws den trexei o xronisths

	out TCNT1H, temp				;Arxikopoioume to xronisth sto 0
	out TCNT1L, temp	


    ser temp
	out ddrA, temp					;H thura A thura eksodou dedomenwn
	
	clr flag

	ldi temp, (1<<INT0)
	out GICR, temp					;Epitrepsh ekswterikwn diakopwn MONO tupou INT0
	ldi temp, 0b00000011
	out MCUCR, temp					;H diakoph INT0 orizoume na prokaleitai sthn anerxomenh akmh
	
    ldi temp, (1<<TOIE1)            ;Energopoihsh diakophs yperxeilishs tou timer1
    out TIMSK,temp
	sei 							;Energopoihsh diakopwn (genika)
	

main:
	sbis pinB,0	    				;Oso to bit 0 ths 8yras B einai cleared, perimenoume
    rjmp main
	
	button_push:					;Edw to bit exei ginei set
	sbic pinB,0						;Kai perimenoume mexri na ksanaginei clear
	rjmp button_push

    ldi temp,0b00000101             ;Ksekiname to xronisth
	out TCCR1B, temp                ;me syxnothta CLK/1024
    

	sbrc flag,0
	rjmp renew
	
	ldi leds,0x80					;An to flag einai 0, einai to prwto pathma
	out portA,leds					;Anaboume to MSB led
	ser flag						;8etoume to flag
	ldi temp, high(threeSec)		;arxikopoihsh tou TCNT1
	out TCNT1H, temp				;gia uperxeilish meta apo 3 sec
	ldi temp, low(threeSec)
	out TCNT1L, temp	

	rjmp main

	renew:							;An to flag einai set, kanoume renew
    ser leds                        ;Anaboume ola ta leds sthn A                
    out portA, leds
    ldi temp, high(halfSec)			;arxikopoihsh tou TCNT1
	out TCNT1H, temp				;gia uperxeilish meta apo 0.5 sec
	ldi temp, low(halfSec)
	out TCNT1L, temp	

	rjmp main						;programma diarkous leitourgias

INT0_rout:                          ;Edw ksekiname (h ananewnoume ta led)
    push temp

    ldi temp,0b00000101             ;Ksekiname to xronisth
	out TCCR1B, temp


	sbrc flag,0
	rjmp renew_intr
	
	ldi leds,0x80					;An to flag einai clear, einai to prwto pathma
	out portA,leds					;Anaboume mono to MSB led
	ser flag						;Kai 8etoume to flag
	ldi temp, high(threeSec)		;arxikopoihsh tou TCNT1
	out TCNT1H, temp				;gia uperxeilish meta apo 3 sec
	ldi temp, low(threeSec)
	out TCNT1L, temp	
	
	pop temp
	reti

	renew_intr:
    ser leds                        ;Anaboume ola ta led
    out portA, leds
    ldi temp, high(halfSec)			;arxikopoihsh tou TCNT1
	out TCNT1H, temp		    	;gia uperxeilish meta apo 0.5 sec
	ldi temp, low(halfSec)
	out TCNT1L, temp	
                                    ;Ta ypoloipa 8a ta analabei h routina eksyphrethshs
    pop temp                        ;ths diakophs yperxeilishs tou xronisth
    reti

timer1_rout:                        ;O xronisths molis eftase sto orio
	sbrs leds,0						;Ean to bit 0 sta leds einai 0, kanoume jump
	rjmp next_phase
    
    ldi leds,0x80                   ;Diaforetika, an to bit 0 einai set, sthn pragmatikothta ola ta bit einai set
    out portA, leds                 ;Dhladh twra oloklhrwnontai ta prwta 0.5 sec
                                    ;Opote anaboume to MSB led (sbhnontas ta ypoloipa) kai 8etoume ton timer gia akoma 2.5 sec
    ldi temp, high(twoAndHalfSec)	;arxikopoihsh tou TCNT1
	out TCNT1H, temp				;gia uperxeilish meta apo 2.5 sec
	ldi temp, low(twoAndHalfSec)
	out TCNT1L, temp	
    reti

    next_phase:             ;Edw ftanoume an to bit 0 sta leds einai cleared, dhladh eimastan sth deyterh fash
    clr leds                ;(ennowntas pws mono to MSB led einai anammeno atm)
    out portA,leds             ;Sbhnoume ola ta led
    clr flag
	
	clr temp                
	out TCCR1B, temp        ;Kai stamatame to xronisth
	
    reti					;Clear to flag
    
