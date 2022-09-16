.include "m16def.inc"
.def temp = r16
.def value = r17
.def counter = r18
.def monades = r19
.def dekades = r20
.def ekatontades = r21
.def data = r23

.org 0
rjmp reset					


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

;********************************************;

convert_hex_to_ascii:					;Metatrepoume hex ari8mo se ascii
    cpi data,0x0A						;Elegxoume an einai megalytero apo 0x0A
    brlo convert_hex_to_ascii_next		;An einai megalytero dhladh ena apo ta A,B,C,D,E,F
    ldi temp,0x37						;Pros8etoume 0x37
    add data,temp
    ret
    convert_hex_to_ascii_next:			;An einai mikrotero apo to 0x0A, dhladh dekadiko pshfio
	ori data,0x30						;ousiastika pros8etoume 0x30 
    ret


wait_for_hex_keypad:
	ldi r24, 20
	rcall scan_keypad_rising_edge
	rcall keypad_to_hex										
	cpi r24,0x10							;ean den exei paththei kanena plhktro, o r24 8a exei thn timh 0x10
	breq wait_for_hex_keypad				;opote ksanadiabazoume apo to plhktrologio
	ret


convert_bin_to_dec_unsigned:
	ldi dekades, 0xff				;arxikopoihsh dekadwn kai ekatontadwn -klassikh diadikasia gia metatroph binary se dekadiko
	ldi ekatontades, 0xff					
    ekat:							;Se ka8e iteration, afairoume 100 kai ayksanoume kata 1 to metrhth ekatontadwn
	    inc ekatontades
	    subi value, 0x64			;Afairoume 100
	    brpl ekat
	    ldi temp, 0x64
	    add value, temp				;Pros8etoume 100 gia na dior8wsoume to arnhtiko ypoloipo
    dek:
	    inc dekades					;Se ka8e iteration, afairoume 10 kai ayksanoume kata 1 to metrhth twn dekadwn
	    subi value, 0x0a			;Afairoume 10
	    brge dek
	    ldi temp, 0x0a
	    add value, temp				;Pros8etoume 10 gia na dior8wsoume to arnhtiko ypoloipo 
    mon:
	    mov monades, value			;O,ti emeine einai oi monades
	
    ret


reset:
	ldi temp, low(RAMEND)
	out spl, temp
	ldi temp, high(RAMEND)
	out sph, temp
	ldi temp, 0b11111100					;eksodoi ta 6 MSB, eisodoi ta 2 LSB ths thuras PORTD (gia xrhsh tou screen)
	out DDRD, temp
	ldi temp, 0b11110000	
	out DDRC,temp	
	
	ser temp
	out DDRB,temp

	clr temp
	out PORTC, temp
	out DDRA, temp							;PORTA eisodos
	rcall lcd_init    						;initialize screen

main:

    ldi r24,0x80							// prosthikh: bazoume ton AC deikth ths DDRAM sthn arxh oste na emfanisei apo thn arxh
	rcall lcd_command
											
	rcall wait_usec 


    rcall wait_for_hex_keypad
    mov value,r24							//To prwto pshfio (se ari8mhtikh timh) sta 4 MSB tou value
    swap value

    mov data,r24							//To prwto pshfio ston data
    rcall convert_hex_to_ascii				//Kai to metatrepoume se ascii
    mov temp,data							//Kai to apo8hkeyoume ston temp

    rcall wait_for_hex_keypad
    or value,r24                        //To value exei to swsto synoliko input
    
	mov data,r24						//To deytero pshfio (ari8mhtiko) ston data
	mov r24,temp						//To prwto pshfio (se ascii ston r24)
    rcall lcd_data						//Grafoume to prwto pshfio sthn o8onh

    rcall convert_hex_to_ascii			//Metatrepoume to deytero pshfio se ascii (ston data)
    
    mov r24,data						//To grafoume ston r24
    rcall lcd_data						//Kai to grafoume sthn o8onh

    ldi r24, '='						;ektupwnoume to '='
	rcall lcd_data

    ldi r24,'+'							;Fortwnoume to '+' ston r24
    sbrc value,7						;An to MSB einai set (kai ara arnhtikos ari8mos)
    ldi r24,'-'							;tote, fortwnoume to '-' ant aytou
    rcall lcd_data						;Grafoume to '+' h '-' sthn o8onh

    sbrc value,7						;An to MSB einai set (kai ara arnhtikos ari8mos)
    neg value							;tote symplhrwnoume ws pros 2
    
	out portB, value

    rcall convert_bin_to_dec_unsigned	;Pairnoume ta epimerous dekadika pshfia tou ari8mou
    
	out portB,ekatontades
    mov data,ekatontades				;Metatrepoume to plh8os twn ekatontadwn se ascii
    rcall convert_hex_to_ascii	
    mov r24,data
    rcall lcd_data						;Kai grafoume sthn o8onh

    mov data,dekades					;Metatrepoume to plh8os twn dekadwn se ascii
    rcall convert_hex_to_ascii
    mov r24,data
    rcall lcd_data						;Kai grafoume sthn o8onh

    mov data,monades					;Metatrepoume to plh8os twn monadwn se ascii
    rcall convert_hex_to_ascii
    mov r24,data
    rcall lcd_data						;Kai grafoume sthn o8onh

	rjmp main							;h diadikasia einai sunexhs

	
