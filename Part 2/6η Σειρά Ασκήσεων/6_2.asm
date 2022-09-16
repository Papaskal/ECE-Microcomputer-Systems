.include "m16def.inc"
.def temp = r16
.def temp2 = r17
.def data = r18
.def value = r24
.def counter = r18

.org 0
rjmp reset					

.DSEG
_tmp_: .byte 2 


.CSEG
rjmp main

_hundreds: .db 0x00
_tens: .db 0x00
_units: .db 0x00

no_device_msg:
.db 'N','O', ' ', 'D','e','v','i','c','e', 0x01


;-----------------------------------------Kyrios kwdikas--------------------------------------



reset:
	
	ldi temp, low(RAMEND)
	out spl, temp
	ldi temp, high(RAMEND)
	out sph, temp

	ser temp
	out ddrb,temp
	
	rcall keypad_init				;initialise keypad
	rcall lcd_init    				;initialise screen


main:
	;rcall temperature_keypad		;r25:r24 = 0xabcd, opou abcd me th seira ta 4 pshfia pou patame
    rcall temperature_sensor		;r25=(0x00 an '+' / 0xFF an '-'), r24 h timh ths 8ermokrasias epi 2
    rcall lcd_temperature			;Probolh timhs se signed dec morfh
rjmp main


;----------------------------Eidikes Routines--------------------------


temperature_keypad:

    rcall wait_for_hex_keypad		;Pairnoume hex timh apo to plhktorologio
    mov temp,r24					;Kratame to pshfio ston temp
	swap temp						;temp: MSB<->LSB, ara to prwto pshfio sta 4 MSB

    rcall wait_for_hex_keypad
	or temp,r24						;Bazoume to 2o pshfio sta 4 LSB tou temp
    push temp						;Back up ton temp (1os hex ari8mos)
	
    rcall wait_for_hex_keypad		;Pairnoume to 1o pshfio tou 2ou ari8mou
    mov temp,r24					;1o pshfio sta 4 MSB tou temp
    swap temp

    rcall wait_for_hex_keypad		;Pairnoume to 2o pshfio
    or r24,temp						;O 2os ari8mos ston r24

	pop r25							;Bazoume ton 1o ari8mo ston r25
	
	ret



temperature_sensor:
	rcall one_wire_reset				;arxikopoihsh ths suskeuhs, ean den yparxei syskeyh, r24=0x00
	ldi r25,0x80
    sbrs r24,0							
	ret									;Ean den yparxei syskeyh, r25:r24=0x8000 kai epistrefoume


	ldi r24, 0xCC						;command 0xCC: parakampsh epiloghs syskeyhs
	rcall one_wire_transmit_byte				
	ldi r24, 0x44						;command 0x44: ekkinhsh metrhshs 8ermokrasias
	rcall one_wire_transmit_byte

    check_for_temp: 					
	rcall one_wire_receive_bit			;An termatisthke h metrhsh, lambanoume 1, alliws 0
	sbrs r24,0
	rjmp check_for_temp					;Diabazw ton r24 mexris otou r24 = 1
	
    rcall one_wire_reset				;Arxikopoihsh/afypnish ths suskeuhs
	ldi r25,0x80
    sbrs r24,0
	ret									;Ean den yparxei syskeyh, r25:r24=0x8000 kai epistrefoume


	ldi r24, 0xCC						;command 0xCC: parakampsh epiloghs syskeyhs
	rcall one_wire_transmit_byte
	ldi r24, 0xBE						;command 0xBE: anagnwsh ths 8ermokrasias (16 bit)
	rcall one_wire_transmit_byte		
	
    rcall one_wire_receive_byte			;To 1o byte einai h timh
	mov temp, r24					
	
    ;ldi r24, 0xBE
	rcall one_wire_receive_byte			;To 2o byte einai epektash proshmou(0x00=+,0xFF=-)
	
	mov r25,r24							;Epektash proshmou ston r25
	mov r24,temp						;Timh ston r24

	ret



lcd_temperature: 
    cpi r25,0x80						;Ean r25=0x80 kai r24=0x00
    brne valid_temperature_value		;Tote grafoume "NO Device"
    tst r24
    brne valid_temperature_value		;Diaforetika, kanoume kolpa me thn timh

    rcall no_device_message				
										
	ret


    valid_temperature_value:
	push r24				;r24 exei thn timh, kanw back up
	push r25				;r25 exei to proshmo, kanw back up

	ldi r24, 0x80			;epistrofh tou AC sth thesi 0x00 ths DDRAM, wste na grapsoume apo thn arxh ths othonis
	rcall lcd_command

	pop r25
	push r25

	ldi r24,'+'				;Ean o r25 == 0x00, grafoume '+' 
	ldi temp,0x00
    cpse r25,temp			;Diaforetika, grafoume '-'
    ldi r24,'-'
    rcall lcd_data

	pop r25
	pop r24
	push r24
	
	sbrc r25,0				;Ean o r25=0xFF, exoume arnhtiko
    neg r24					;opote kanoume symplhrwma ws pros 2
	
    
	lsr r24                     ;Diairw dia 2 gia na parw th swsth 8ermokrasia
    rcall convert_bin_to_dec_unsigned	;Pairnoume ta epimerous dekadika pshfia tou ari8mo    

	ldi xl,low(_hundreds)
	ldi xh,high(_hundreds)
	ld temp2,x
    mov data,temp2				;Metatrepoume to plh8os twn ekatontadwn se ascii
    rcall convert_hex_to_ascii	
    mov r24,data
    rcall lcd_data					;Kai grafoume sthn o8onh



	ldi xl,low(_tens)
	ldi xh,high(_tens)
	ld temp2,x
    mov data,temp2					;Metatrepoume to plh8os twn dekadwn se ascii
    rcall convert_hex_to_ascii
    mov r24,data
    rcall lcd_data					;Kai grafoume sthn o8onh


	ldi xl,low(_units)
	ldi xh,high(_units)
	ld temp2,x
    mov data,temp2					;Metatrepoume to plh8os twn monadwn se ascii
    rcall convert_hex_to_ascii
    mov r24,data
    rcall lcd_data					;Kai grafoume sthn o8onh


	pop r24
	sbrc r24,0				;Ean h timh teleiwnei se 1, ara exoume peritto ari8mo,
	rcall point_5			;bazoume .5 sto telos

    ldi r24, 0xB2			;0xB2 einai o ascii kwdikos tou anw kyklou
    rcall lcd_data
    ldi r24,'C'				;Grafoume kai to 'C'
    rcall lcd_data

    ldi r24,' '				;Grafoume 3 ' ' gia na sbhsoume tyxon epipleon
    rcall lcd_data			;xarakthres pou exoun ksemeinei sthn o8onh
	ldi r24,' '				;(ant' aytou, 8a mporousame na sbhnoume oloklhrh
    rcall lcd_data			;thn o8onh prin ksekinhsoume na grafoume)
	ldi r24,' '
    rcall lcd_data

	ret



no_device_message:
	ldi zh, high(no_device_msg*2)	;Deixnoume sthn prwth 8esh mnhmhs tou msg
	ldi zl, low(no_device_msg*2)			
	
	ldi counter, 9					;epanalipsi 9 fores (mia gia kathe xarakthra)
	
	ldi r24, 0x80					;epistrofh tou AC sth thesi 0x00 ths DDRAM, wste na grapsoume apo thn arxh ths othonis
	rcall lcd_command
    
    message_loop:					;9 iterations
	lpm r24, Z						;Se ka8e iteration, grafoume ton char
	rcall lcd_data					;apo th dedomenh 8esh mnhmhs
	adiw zl, 1						;kai meta pername sthn epomenh 8esh
	dec counter
	brne message_loop

    ret


point_5:							;Edw apla grafoume '.5'
	ldi r24,'.'
	rcall lcd_data
	ldi r24,'5'
	rcall lcd_data

	ret


;--------------------Genikes routines-----------------



keypad_init:
	ldi temp, 0b11110000			;Ta 4 MSB ths C eksodoi
	out DDRC,temp					;Ta 4 LSB ths C eisodoi

	clr temp
	out PORTC, temp

	ret



wait_for_hex_keypad:
	ldi r24, 20
	rcall scan_keypad_rising_edge
	rcall keypad_to_hex										
	cpi r24,0x10					;ean den exei paththei kanena plhktro, o r24 8a exei thn timh 0x10
	breq wait_for_hex_keypad		;opote ksanadiabazoume apo to plhktrologio
	ret



convert_bin_to_dec_unsigned:
	ldi temp2, 0xff					;arxikopoihsh metrhtwn dekadwn, ekatontadwn					
    ldi xl, low(_hundreds)
    ldi xh, high(_hundreds)
    ekat:							;Se ka8e iteration, afairoume 100 kai ayksanoume kata 1 to metrhth ekatontadwn
	    inc temp2
	    subi value, 0x64			;Afairoume 100
	    brpl ekat
	    ldi temp, 0x64
	    add value, temp				;Pros8etoume 100 gia na dior8wsoume to arnhtiko ypoloipo
        st X,temp2
        ldi temp2,0xFF 
    
    dek:
	    inc temp2					;Se ka8e iteration, afairoume 10 kai ayksanoume kata 1 to metrhth twn dekadwn
	    subi value, 0x0a			;Afairoume 10
	    brge dek
	    ldi temp, 0x0a
	    add value, temp				;Pros8etoume 10 gia na dior8wsoume to arnhtiko ypoloipo 
    
        ldi xl, low(_tens)
        ldi xh, high(_tens)
        st X,temp2
    

    mon:
        ldi xl, low(_units)
        ldi xh, high(_units)
	    st X, value			;O,ti emeine einai oi units

    ret



convert_hex_to_ascii:					;Metatrepoume hex ari8mo se ascii
    cpi data,0x0A						;Elegxoume an einai megalytero apo 0x0A
    brlo convert_hex_to_ascii_next		;An einai megalytero dhladh ena apo ta A,B,C,D,E,F
    ldi temp,0x37						;Pros8etoume 0x37
    add data,temp
    ret
    convert_hex_to_ascii_next:			;An einai mikrotero apo to 0x0A, dhladh dekadiko pshfio
	ori data,0x30						;ousiastika pros8etoume 0x30 
    ret


;----------------------------------Etoimes Routines----------------------

;-----------------------------------------Routines xronoka8ysterhshs----------------------

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

;-------------------------------------Etoimes routines hex plhktrologiou--------------------------

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

keypad_to_ascii:				;Apla elegxoume ena ena ta koumpia kai dinoume thn antistoixh hex timh
    movw r26,r24				;Stamatame otan broume to prwto egkyro koumpi
    ldi r24,'*'					;(proteraiothta grammh apo katw pros ta panw ki epeita sthlh aristera pros deksia)
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


keypad_to_hex:				;Apla elegxoume ena ena ta koumpia kai dinoume thn antistoixh hex timh
    movw r26,r24			;Stamatame otan broume to prwto egkyro koumpi
    ldi r24, 0x0E			;(proteraiothta grammh apo katw pros ta panw ki epeita sthlh aristera pros deksia)
    sbrc r26,0
    ret
    ldi r24,0
    sbrc r26,1
    ret
    ldi r24,0x0F
    sbrc r26,2
    ret
    ldi r24,0x0D
    sbrc r26,3
    ret
    ldi r24,7
    sbrc r26,4
    ret
    ldi r24,8
    sbrc r26,5
    ret
    ldi r24,9
    sbrc r26,6
    ret
    ldi r24,0x0C
    sbrc r26,7
    ret
    ldi r24,4
    sbrc r27,0
    ret
    ldi r24,5
    sbrc r27,1
    ret
    ldi r24,6
    sbrc r27,2
    ret
    ldi r24,0x0B
    sbrc r27,3
    ret
    ldi r24,1
    sbrc r27,4
    ret
    ldi r24,2
    sbrc r27,5
    ret
    ldi r24,3
    sbrc r27,6
    ret
    ldi r24,0x0A
    sbrc r27,7
    ret
    ldi r24,0x10
    ret


;--------------------------------------------Etoimes routines o8onhs LCD-------------------------

write_2_nibbles:
	push r24
	in r25, PIND 
	andi r25, 0x0f 
	andi r24, 0xf0 
	add r24, r25 
	out PORTD, r24
	sbi PORTD, PD3
	cbi PORTD, PD3
	pop r24 
	swap r24 
	andi r24, 0xf0 
	add r24, r25
	out PORTD, r24
	sbi PORTD, PD3 
	cbi PORTD, PD3
	ret
	
    

lcd_data:
	sbi PORTD, PD2 
	rcall write_2_nibbles 
	ldi r24, 43
	ldi r25, 0 
	rcall wait_usec
	ret	
	

lcd_command:
	cbi PORTD ,PD2 
	rcall write_2_nibbles 
	ldi r24, 39 
	ldi r25, 0 
	rcall wait_usec 
	ret	
	

lcd_init:
	ldi temp, 0b11111100			;PROS8HKH: eksodoi ta 6 MSB, eisodoi ta 2 LSB ths thuras PORTD (gia xrhsh ths LCD)
	out DDRD, temp					

	ldi r24, 40 
	ldi r25, 0 
	rcall wait_msec 
	ldi r24, 0x30 
	out PORTD, r24 
	sbi PORTD, PD3 
	cbi PORTD, PD3 
	ldi r24, 39
	ldi r25, 0 
	rcall wait_usec 
	ldi r24, 0x30
	out PORTD, r24
	sbi PORTD, PD3
	cbi PORTD, PD3
	ldi r24, 39
	ldi r25, 0
	rcall wait_usec
	ldi r24, 0x20 
	out PORTD, r24
	sbi PORTD, PD3
	cbi PORTD, PD3
	ldi r24, 39
	ldi r25, 0
	rcall wait_usec
	ldi r24, 0x28 
	rcall lcd_command 
	ldi r24, 0x0c 
	rcall lcd_command
	ldi r24, 0x01 
	rcall lcd_command
	ldi r24, low(1530)
	ldi r25, high(1530)
	rcall wait_usec
	ldi r24, 0x06 
	rcall lcd_command 
	ret

;--------------------------------------Etoimes routines 8ermometrou----------------------------------------

; File Name: one_wire.asm
; Title: one wire protocol
; Target mcu: atmega16
; Development board: easyAVR6
; Assembler: AVRStudio assembler
; Description:
; Routine: one_wire_receive_byte
; Description:
; This routine generates the necessary read
; time slots to receives a byte from the wire.
; return value: the received byte is returned in r24.
; registers affected: r27:r26 ,r25:r24
; routines called: one_wire_receive_bit
one_wire_receive_byte:
ldi r27 ,8
clr r26
loop_:
rcall one_wire_receive_bit
lsr r26
sbrc r24 ,0
ldi r24 ,0x80
or r26 ,r24
dec r27
brne loop_
mov r24 ,r26
ret
; Routine: one_wire_receive_bit
; Description:
; This routine generates a read time slot across the wire.
; return value: The bit read is stored in the lsb of r24.
; if 0 is read or 1 if 1 is read.
; registers affected: r25:r24
; routines called: wait_usec
one_wire_receive_bit:
sbi DDRA ,PA4
cbi PORTA ,PA4 ; generate time slot
ldi r24 ,0x02
ldi r25 ,0x00
rcall wait_usec
cbi DDRA ,PA4 ; release the line
cbi PORTA ,PA4
ldi r24 ,10
; wait 10 ?s
ldi r25 ,0
rcall wait_usec
clr r24
; sample the line
sbic PINA ,PA4
ldi r24 ,1
push r24
ldi r24 ,49
; delay 49 ?s to meet the standards
ldi r25 ,0
; for a minimum of 60 ?sec time slot
rcall wait_usec ; and a minimum of 1 ?sec recovery time
pop r24
ret

; Routine: one_wire_transmit_byte
; Description:
; This routine transmits a byte across the wire.
; parameters:
; r24: the byte to be transmitted must be stored here.
; return value: None.
; registers affected: r27:r26 ,r25:r24
; routines called: one_wire_transmit_bit
one_wire_transmit_byte:
mov r26 ,r24
ldi r27 ,8
_one_more_:
clr r24
sbrc r26 ,0
ldi r24 ,0x01
rcall one_wire_transmit_bit
lsr r26
dec r27
brne _one_more_
ret
; Routine: one_wire_transmit_bit
; Description:
; This routine transmits a bit across the wire.
; parameters:
; r24: if we want to transmit 1
; then r24 should be 1, else r24 should
; be cleared to transmit 0.
; return value: None.
; registers affected: r25:r24
; routines called: wait_usec
one_wire_transmit_bit:
push r24
; save r24
sbi DDRA ,PA4
cbi PORTA ,PA4 ; generate time slot
ldi r24 ,0x02
ldi r25 ,0x00
rcall wait_usec
pop r24
; output bit
sbrc r24 ,0
sbi PORTA ,PA4
sbrs r24 ,0
cbi PORTA ,PA4
ldi r24 ,58
; wait 58 ?sec for the
ldi r25 ,0
; device to sample the line
rcall wait_usec
cbi DDRA ,PA4 ; recovery time
cbi PORTA ,PA4
ldi r24 ,0x01
ldi r25 ,0x00
rcall wait_usec
ret

; Routine: one_wire_reset
; Description:
; This routine transmits a reset pulse across the wire
; and detects any connected devices.
; parameters: None.
; return value: 1 is stored in r24
; if a device is detected, or 0 else.
; registers affected r25:r24
; routines called: wait_usec
one_wire_reset:
sbi DDRA ,PA4 ; PA4 configured for output
cbi PORTA ,PA4 ; 480 ?sec reset pulse
ldi r24 ,low(480)
ldi r25 ,high(480)
rcall wait_usec
cbi DDRA ,PA4 ; PA4 configured for input
cbi PORTA ,PA4
ldi r24 ,100
; wait 100 ?sec for devices
ldi r25 ,0
; to transmit the presence pulse
rcall wait_usec
in r24 ,PINA ; sample the line
push r24
ldi r24 ,low(380) ; wait for 380 ?sec
ldi r25 ,high(380)
rcall wait_usec
pop r25
clr r24
sbrs r25 ,PA4
ldi r24 ,0x01
ret





