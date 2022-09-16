.include "m16def.inc"
.def minl = r19			; edw apothikeyontai oi monades twn leptwn
.def minh = r20			; edw oi dekades twn leptwn
.def secl = r21			; edw oi monades twn deyteroleptwn
.def sech = r22			; kai edw oi dekades twn deyteroleptwn
.def temp = r16
.def counter = r17
.def input = r18

.CSEG

jmp main

Message:
; oi xarakthres einai 13 se plhthos, opote apothikeuoume to 01 sto telos, gia na yparxei svsth eythigrammish twn leksewn
; ths program memory
.db '0', '0', ' ', 'M', 'I', 'N', ':', '0', '0', ' ', 'S', 'E', 'C', 0x01


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


write_2_nibbles: 
	push r24
	in r25 ,PIND
	andi r25 ,0x0f
	andi r24 ,0xf0
	add r24 ,r25
	out PORTD ,r24
	sbi PORTD ,PD3
	cbi PORTD ,PD3
	pop r24
	swap r24
	andi r24,0xF0
	add r24 ,r25
	out PORTD ,r24
	sbi PORTD ,PD3
	cbi PORTD ,PD3
	ret


lcd_data: 
	sbi PORTD ,PD2
	rcall write_2_nibbles
	ldi r24 ,43
	ldi r25 ,0
	rcall wait_usec 
	ret


lcd_command: 
	cbi PORTD ,PD2
	rcall write_2_nibbles
	ldi r24 ,39
	ldi r25 ,0
	rcall wait_usec
	ret


lcd_init:     
	ldi r24 ,40
	ldi r25 ,0
	rcall wait_msec

	ldi r24 ,0x30
	out PORTD ,r24
	sbi PORTD ,PD3
	cbi PORTD ,PD3
	ldi r24 ,39
	ldi r25 ,0
	rcall wait_usec

	ldi r24 ,0x30 
	out PORTD ,r24 
	sbi PORTD ,PD3 
	cbi PORTD ,PD3 
	ldi r24 ,39 
	ldi r25 ,0 
	rcall wait_usec 

	ldi r24 ,0x20
	out PORTD ,r24 
	sbi PORTD ,PD3 
	cbi PORTD ,PD3 
	ldi r24 ,39 
	ldi r25 ,0 
	rcall wait_usec 

	ldi r24 ,0x28
	rcall lcd_command

	ldi r24 ,0x0c
	rcall lcd_command 

	ldi r24 ,0x01
	rcall lcd_command 

	ldi r24 ,low(1530) 
	ldi r25 ,high(1530) 
	rcall wait_usec 

	ldi r24 ,0x06
	rcall lcd_command

	ret 


; routina gia thn ektypwsh tou mynhmatos "00 MIN: 00 SEC" sthn othoni
initialize_message:
	ldi zh, high(Message*2)			; xrhsimopoioume ton klassiko tropo gia access se synexomena dedomena ths program
	ldi zl, low(Message*2)			; memory, opws ton gnvrizoume apo to 6o eksamhno
	
	ldi counter, 13					; epanalipsi 13 fores (mia gia kathe xarakthra)
	
	ldi r24, 0x80					; epistrofh tou AC sth thesi 0x00 ths DDRAM, wste na grapsoume apo thn arxh ths othonis
	rcall lcd_command
parse_loop:
	lpm r24, Z
	rcall lcd_data
	adiw zl, 1
	dec counter
	brne parse_loop
	
	ldi secl,'0';						; kanoume reset profanws kai stous kataxwrhtes poy exoun th metrhsh mas, 
	ldi sech,'0'						; afou kai aytoi prepei na mhdenistoun
	ldi minl,'0'
	ldi minh,'0'
	ret


; routina gia th swsth ayksisi kata 1 ths metrhshs, h opoia vrisketai stous kataxwrhtes secl,sech,minl,minh
counter_increment:
	inc secl						; ayksisi kata 1 tou secl, se kathe periptwsh
	ldi temp,0x3a
	cpse secl, temp					; an den eftase to 10 akoma, tote eimaste ok. Alliws...
	ret

	ldi secl,0x30;						; mhdenismos twn monadwn twn deyteroleptwn,
	inc sech						; kai ayksisi kata 1 twn dekadwn
	ldi temp,0x36
	cpse sech, temp						; an oi dekades den eftasan akoma to 6, tote kai pali eimaste ok. Alliws...
	ret

	ldi sech,0x30						; mgdenismos kai twn dekadwn twn deyteroleptwn
	inc minl						; kai ayksisi kata 1 twn monadwn twn leptwn.
	ldi temp,0x3a
	cpse minl, temp					; omoia me parapanw, elegxos an eftasan to 10.
	ret					; An oxi, telos. An nai, tote...
	
	ldi minl,0x30						; mhdenismos twn monadwn twn leptwn
	inc minh						; kai increment tis dekades twn leptwn.
	ldi temp, 0x36
	cpse minh, temp						; Teleytaios elegxos. An oi dekades twn leptwn den eftasan to 6, tote telos,
	ret

	ldi minh,0x30						; alliws, mhdenizontai kai oi dekades twn leptwn (periptwsh 59:59 -> 00:00)
	ret


; routina pou typwnei sthn othoni thn current timh ths metrhshs mas, poy einai stous secl,sech,minl,minh
counter_to_lcd:
	; ta 2 prwta pshfia (minh kai minl) prepei na typwthoun stiw prwtes 2 theseis ths othonis
	; opote prepei na ta apothikeysoume stis theseis 0x00 kai 0x01 ths DDRAM
	ldi r24, 0x80					; etsi, epanaferoume ton AC na deixnei sti thesi 0x00 ths DDRAM
	rcall lcd_command
	mov r24, minh					; kai stelnoume ta 2 pshfia
	rcall lcd_data
	mov r24, minl
	rcall lcd_data

	; paromoia, ta pshfia twn deyteroleptwn (sech, secl) prepei na typwthoun meta to ':', opote
	; prepei na ta apothikeysoume stis theseis 0x07 kai 0x08 ths DDRAM
	ldi r24, 0x87					; etsi, vazoume ton AC na deixnei sti thesi 0x07 ths DDRAM
	rcall lcd_command
	mov r24, sech					; kai stelnoume ta 2 pshfia
	rcall lcd_data
	mov r24, secl
	rcall lcd_data

	ret
	
;****************************************** MAIN PROGRAM ****************************************
main:
	ldi temp, high(RAMEND)			; arxikopoihsh ths stoivas
	out sph, temp
	ldi temp, low(RAMEND)
	out spl, temp
	
	ser temp
	out DDRD, temp					; orismos ths PORTD ws eksodou, gia thn epikoinwnia me thn othoni
	clr temp
	out DDRA, temp					; orismos ths PORTA ws eisodou
	
	rcall lcd_init					; arxikopoihsh ths othonis
	rcall initialize_message		; arxikopoihsh tou mynhmatos (00 MIN:00 SEC)
	
eternal_loop:
	sbic PINA, 0					; an exei paththei to PB7, tote kaloume thn initialize_message gia na mhdenistei
	rcall initialize_message		; to mhnyma sthn othoni, alla kai oi kataxvrhtes minh,minl,sech,secl
	sbic PINA, 0
	rjmp eternal_loop				; kai epistrefoume sthn arxh.
	
	sbis PINA, 7					; oso den exei paththei to PB0, perimenoume, me epistrofh sto eternal_loop.
	rjmp eternal_loop				; otan paththei, proxwrame

	ldi r24, low(1000)				; kathysterhsh enos deyteroleptou
	ldi r25, high(1000)
	rcall wait_msec

	rcall counter_increment			; increment ton metrhth mas (minh,minl,sech,secl)
	rcall counter_to_lcd			; kai typwma tou sthn othoni

	rjmp eternal_loop				; epistrofh sto eternal_loop
	
