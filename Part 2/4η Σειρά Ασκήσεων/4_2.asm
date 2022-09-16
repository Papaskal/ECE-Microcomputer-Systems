.include "m16def.inc"								
.def temp = r16										
.def ledCounter = r17								;orismos metrhth
.def unitCounter = r18							;orismos metrhth EGKURWN diakopwn (sunthhkh egkurothtas: PD0 = 1)
.def loopCounter = r19
.def temp2 = r20

.org 0												
rjmp reset							;etiketa enarkshs tou kwdika programmatos mas

.org 4
rjmp INT1_rout						;etiketa enarkshs routinas ekusphrethshs diakophs INT1

reset:
	ldi temp, high(RAMEND)			;setarisma kataxwrhth - deikth stoivas wste na deixnei sto telos ths
	out sph, temp					;diadikasia APARAITHTH efoson exoume estw kai ena upoprogramma h epitrepomenh diakoph
	ldi temp, low(RAMEND)
	out spl, temp
	
    clr ledCounter					;arxikopoihsh kyriou metrhth
	clr unitCounter					;arxikopoihsh metrhth diakoptwn
	
    clr temp						;temp <- 0000 0000
	out ddrB, temp
    out portB,temp
    out DDRD, temp					
	out PORTD, temp                 ;Disable pull up resistors
    
    ser temp						;temp <- 1111 1111
	out DDRA, temp			        ;oi thures A kai C dhlwnontai gia eksodo dedomenwn
	out DDRC, temp

    out portA,ledCounter            ;Deixnoume swstes arxikes times sta leds
    out portC,unitCounter

    ldi temp,(1<<INT1)                  ;Epitrepsh ekswterikwn diakopwn MONO tupou INT1
    out GICR,temp

    ldi temp,(1<<ISC11)|(1<<ISC10)      ;H diakoph INT1 orizoume na prokaleitai sthn anerxomenh akmh
    out MCUCR,temp

    

	sei                         ;Energopoihsh diakopwn (genika)
    												
main:
	out portA, ledCounter   ;Grafoume sta leds sth 8yra A
    
    ldi r24, low(200)
    ldi r25, high(200)							
    rcall wait_msec	        ;Kaloume xronoka8ysterhsh 0.2 sec

	inc ledCounter			;Ayksanoume ton kyrio metrhth			
	rjmp main


wait_msec:                  ;Routina xronoka8ysterhshs msec			
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

wait_usec:                  ;Routina xronoka8ysterhshs usec
	sbiw r24,1
	nop
	nop
	nop
	nop
	brne wait_usec
    ret

INT1_rout:              
    push temp           
    
    spark_check:        
	ldi temp,(1<<INTF1) 
	out GIFR, temp				
							
	ldi r24,low(5)
	ldi r25,high(5)
    rcall wait_msec
	in temp2,GIFR
    sbrc temp2,6
    rjmp spark_check

    clr unitCounter         
    ldi loopCounter,8
    in temp,pinB
    rol temp
    
    count_units:        ;To loop metraei posous 1 exoume
    ror temp            ;Se ka8e iteration, kanoume mia peristrofh kai elegxoume an to carry einai set
    sbrc temp,0         ;An einai clear, den ayksanoume to metrhth diakopwn
    inc unitCounter     ;An einai set, ayksanoume to metrhth diakopwn
    dec loopCounter     ;Meiwnoume ton loopcounter
    brne count_units    ;To loop 8a ektelestei 8 fores (afou elegxoume 8 bit)

    out portC,unitCounter   ;Grafoume sta leds sth 8yra C
    
    pop temp
	reti
