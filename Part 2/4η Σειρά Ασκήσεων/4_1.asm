.include "m16def.inc"								
.def temp = r16										
.def ledCounter = r17				;orismos metrhth
.def intrCounter = r18				;orismos metrhth EGKURWN diakopwn (sunthhkh egkurothtas: PD0 = 1)
.def temp2 = r19

.org 0												
rjmp reset							;etiketa enarkshs tou kwdika programmatos mas

.org 2
rjmp INT0_rout						;etiketa enarkshs routinas ekusphrethshs diakophs INT0

reset:
	ldi temp, high(RAMEND)			;setarisma kataxwrhth - deikth stoivas wste na deixnei sto telos ths
	out sph, temp					;diadikasia APARAITHTH efoson exoume estw kai ena upoprogramma h epitrepomenh diakoph
	ldi temp, low(RAMEND)
	out spl, temp
	
    clr ledCounter					;Arxikopoihsh kyriou metrhth
	clr intrCounter					;Arxikopoihsh metrhth egkurwn diakopwn
	
    clr temp						;temp <- 0000 0000
	out DDRD, temp					;H 8yra D dhlwnetai gia eisodo dedomenwn
	out PORTD, temp                 ;Disable pull up resistors

    ser temp						;temp <- 1111 1111
	out DDRA, temp					;oi 8yres A kai B dhlwnontai gia eksodo dedomenwn
	out DDRB, temp

    out portA,ledCounter				
    out portB,intrCounter

	ldi temp,(1<<INT0)				;Epitrepsh ekswterikwn diakopwn MONO tupou INT0
    out GICR,temp


    ldi temp,(1<<ISC01)|(1<<ISC00)  ;H diakoph INT1 orizoume na prokaleitai sthn anerxomenh akmh
    out MCUCR,temp

  
	sei								;Energopoihsh diakopwn (genika)
    												
main:
	out portA, ledCounter	;Grafoume sta leds sth 8yra A
    
	ldi r24, low(200)		;Kaloume xronoka8ysterhsh 0.2 sec
    ldi r25, high(200)							
	rcall wait_msec					
	
	inc ledCounter			;Ayksanoume ton kyrio metrhth						
	rjmp main


wait_msec:					;Routina xronoka8ysterhshs msec	
	push r24
	push r25
	ldi r24,low(998)
	ldi r25,high(998)

    rcall wait_usec
	pop r25
	pop r24
	sbiw r24,1
	brne wait_msec
	ret

wait_usec:				;Routina xronoka8ysterhshs usec
	sbiw r24,1
	nop
	nop
	nop
	nop
	brne wait_usec
    ret

INT0_rout:              
    push temp           
                        
    spark_check:        
	ldi temp,(1<<INTF0)          ;Eprepe na 8esw to bit sto 1 opws leei sto paradeigma??? Giati?
	out GIFR, temp				
							
	ldi r24,low(5)
	ldi r25,high(5)
    rcall wait_msec
    in temp2,GIFR
	sbrc temp2,6
    rjmp spark_check

    sbis pinD,0				;Ean to bit 0 ths eisodou D einai cleared
    rjmp exit_intr			;tote termatizoume th diakoph xwris allagh
							;Diaforetika an to bit 0 einai set,
    inc intrCounter			;ayksanoume to metrhth diakopwn
    out portB,intrCounter	;kai grafoume sta leds sth 8yra B
    
    exit_intr:
    pop temp
	reti
