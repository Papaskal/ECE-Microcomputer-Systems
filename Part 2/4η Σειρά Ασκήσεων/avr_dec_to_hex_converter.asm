;+interupts, xronistes

.include "m16def.inc"
.def temp = r16
.def temp2 = r17
.def temp3 = r18
.def temp4 = r19
.def counter = r20
.def flag = r21
.def data = r22
.def value = r23
.def acc = r24
.def acc2 = r25


.org 0
rjmp reset					

.DSEG
_tmp_: .byte 2 



.CSEG
rjmp main

_hundreds: .db 0x00
_tens: .db 0x00
_units: .db 0x00

msg_1:
.db "Life is pain",'\0'

msg_2:
.db "Life is bliss",'\0'


;-----------------------------------------Kyrios kwdikas--------------------------------------


reset:
	
	ldi temp, low(RAMEND)           ;Arxikopoihsh ths stoibas
	out spl, temp
	ldi temp, high(RAMEND)
	out sph, temp

	rcall lcd_init
    rcall keypad_init
	;rcall usart_init   
    ;rcall adc_init

    ldi zl,low(msg_1*2)
    ldi zh,high(msg_1*2)

    clr flag

	clr temp            ;eisodos
    out ddra,temp
    out porta,temp
    
	ser temp            ;eksodos
    out ddrb,temp
	
    ;sei

main:
    ldi acc,0x80
    rcall lcd_command
    ldi acc,high(42098)
    rcall lcd_display_hex
    ldi acc,low(42098)
    rcall lcd_display_hex
    ldi acc2,high
rjmp main     

;----------------------------Eidikes Routines--------------------------


;--------------------Genikes routines----------------------------------


set_i_bit:
    push r16

    ldi r16,0x01
    tst r24
    breq set_i_bit_end

    set_i_bit_loop:
    lsl r16
    dec r24
    brne set_i_bit_loop

    set_i_bit_end:
    mov r24,r16

    pop r16
    ret



set_x_msb:
    push r16
    
    clr r16
    tst r24
    breq set_x_msb_end

    ldi r16,0x80
    set_x_msb_loop:
    dec r24
    breq set_x_msb_end
    lsr r16
    ori r16,0x80
    rjmp set_x_msb_loop

    set_x_msb_end:
    mov r24,r16

    pop r16
    ret



set_x_lsb:
    push r16
    
    clr r16
    tst r24
    breq set_x_lsb_end

    ldi r16,0x01
    set_x_lsb_loop:
    dec r24
    breq set_x_lsb_end
    lsl r16
    ori r16,0x01
    rjmp set_x_lsb_loop

    set_x_lsb_end:
    mov r24,r16

    pop r16
    ret



leds_on:
    push r16
    ser r16
    out ddrb,r16
    out portb,r16
    pop r16
    ret



leds_off:
    push r16
    ser r16
    out ddrb,r16
    clr r16
    out portb,r16
    pop r16
    ret



leds_blink:
    push r24
    push r25
    push r20

    ldi r20,10          ;Mporw, ant' aytou na 8etw ton counter ektos routinas

    leds_blink_loop:
    rcall leds_on
    ldi r24,low(250)    ;Mporw, ant'aytou na 8etw th xronoka8ysterhsh ektos routinas
    ldi r25,high(250)
    rcall wait_msec

    rcall leds_off
    ldi r24,low(250)    ;Mporw, ant'aytou na 8etw th xronoka8ysterhsh ektos routinas
    ldi r25,high(250)
    rcall wait_msec

    dec r20
    tst r20
    brne leds_blink_loop

    pop r20
    pop r25
    pop r24
    ret


abs_diff:
    push r25

    sub r24,r25
    brcc abs_diff_end
    neg r24

    abs_diff_end:
    pop r25
    ret


multiplication:
    push r16
    push r17
    push r18

    clr r16
    clr r17
    clr r18

    tst r25
    breq multiplication_end

    multiplication_loop:
    add r16,r24
    adc r17,r18
    dec r25
    brne multiplication_loop

    multiplication_end:
    mov r24,r16
    mov r25,r17

    pop r18
    pop r17
    pop r16
    ret



division:
    push r16
	tst r25
	breq division_end
	
    ldi r16,0xff
    division_loop:
    inc r16
    sub r24,r25
    brcc division_loop

    mov r24,r16
	
	division_end:
    pop r16
    ret



modulo:
	tst r25
	breq modulo_end

    sub r24,r25
    brcc modulo
    add r24,r25
    
	modulo_end:
	ret



get_ms_nibble:
    swap r24
    andi r24,0x0F
    ret



get_ls_nibble:
    andi r24,0x0F
    ret



count_aces:
    push r16
    push r20

    ldi r20,8
    clr r16
    count_aces_count:
    sbrc r24,0
    inc r16
    lsr r24
    dec r20
    brne count_aces_count

    mov r24,r16
    pop r20
    pop r16

    ret



count_zeros:
    push r16
    push r20

    ldi r20,8
    clr r16
    count_zeros_count:
    sbrs r24,0
    inc r16
    lsr r24
    dec r20
    brne count_zeros_count

    mov r24,r16
    pop r20
    pop r16

    ret 



convert_hex_to_ascii:					;Metatrepoume hex ari8mo se ascii
    cpi r24,0x0A						;Elegxoume an einai megalytero apo 0x0A
    brlo convert_hex_to_ascii_next		;An einai megalytero dhladh ena apo ta A,B,C,D,E,F
    push r16
    ldi r16,0x37						;Pros8etoume 0x37
    add r24,r16
    pop r16
    ret

    convert_hex_to_ascii_next:			;An einai mikrotero apo to 0x0A, dhladh dekadiko pshfio
	ori r24,0x30						;ousiastika pros8etoume 0x30 
    
	ret



convert_bin_to_dec_unsigned:
    push xh
    push xl
    push r16
    push r17
    push r24

	ldi r17, 0xff					;arxikopoihsh metrhtwn dekadwn, ekatontadwn					
    ldi xl, low(_hundreds)
    ldi xh, high(_hundreds)
    ekat:							;Se ka8e iteration, afairoume 100 kai ayksanoume kata 1 to metrhth ekatontadwn
	    inc r17
	    subi r24, 0x64			;Afairoume 100
	    brcc ekat
	    ldi r16, 0x64
	    add r24, r16				;Pros8etoume 100 gia na dior8wsoume to arnhtiko ypoloipo
        st X,r17
        ldi r17,0xFF 
    
    dek:
	    inc r17					;Se ka8e iteration, afairoume 10 kai ayksanoume kata 1 to metrhth twn dekadwn
	    subi r24, 0x0a			;Afairoume 10
	    brcc dek
	    ldi r16, 0x0a
	    add r24, r16				;Pros8etoume 10 gia na dior8wsoume to arnhtiko ypoloipo 
    
        ldi xl, low(_tens)
        ldi xh, high(_tens)
        st X,r17
    
    mon:
        ldi xl, low(_units)
        ldi xh, high(_units)
	    st X, r24			;O,ti emeine einai oi units


    pop r24
    pop r17
    pop r16
    pop xl
    pop xh
    ret



get_hundreds:                      ;Meta apo klhsh ths convert_bin_to_dec_unsigned
	push xl
    push xh
    
    ldi xl,low(_hundreds)          ;h 8esh mnhmhs _hundreds exei to plh8os twn ekatontadwn
	ldi xh,high(_hundreds)         ;Epistrefoume to plh8os twn ekatontadwn ston r24         
	ld r24,x

    pop xh
    pop xl
    ret



get_tens:                       ;Meta apo klhsh ths convert_bin_to_dec_unsigned
	push xl
    push xh

    ldi xl,low(_tens)           ;h 8esh mnhmhs _tens exei to plh8os twn dekadwn
    ldi xh,high(_tens)          ;Epistrefoume to plh8os twn dekadwn ston r24
    ld r24,x
    
    pop xh
    pop xl
    ret



get_units:                      ;Meta apo klhsh ths convert_bin_to_dec_unsigned
	push xl
    push xh

	ldi xl,low(_units)          ;h 8esh mnhmhs _units exei to plh8os twn monadwn
	ldi xh,high(_units)         ;Epistrefoume to plh8os twn monadwn ston r24         
	ld r24,x

    pop xh
    pop xl
    ret


;----------------------------------Etoimes routines xronoka8ysterhshs--------------------------


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


;-------------------------------------Routines keypad------------------------------------


keypad_set:
    push r16
    ldi r16, 0b11110000			;Ta 4 MSB ths C eksodoi
	out DDRC,r16				;Ta 4 LSB ths C eisodoi

	clr r16
	out PORTC,r16
    pop r16
    ret  


keypad_init:
    push r16
    push r24
    push r25

	ldi r16, 0b11110000			;Ta 4 MSB ths C eksodoi
	out DDRC,r16				;Ta 4 LSB ths C eisodoi

	clr r16
	out PORTC, r16

    rcall scan_keypad_rising_edge
    
    pop r25
    pop r24
    pop r16
	ret



wait_for_hex_keypad:
	ldi r24, 20
	rcall scan_keypad_rising_edge
    
    push r26
    push r27
	rcall keypad_to_hex										
	pop r27
    pop r26
    
    cpi r24,0x10					;ean den exei paththei kanena plhktro, o r24 8a exei thn timh 0x10
	breq wait_for_hex_keypad		;opote ksanadiabazoume apo to plhktrologio
	ret


wait_for_ascii_keypad:
	ldi r24, 20
	rcall scan_keypad_rising_edge
    
    push r26
    push r27
	rcall keypad_to_ascii										
	pop r27
    pop r26
    
    cpi r24,0x00					;ean den exei paththei kanena plhktro, o r24 8a exei thn timh 0x00
	breq wait_for_ascii_keypad		;opote ksanadiabazoume apo to plhktrologio
	ret


wait_for_dec_keypad:
	ldi r24, 20
	rcall scan_keypad_rising_edge
    
    push r26
    push r27
	rcall keypad_to_hex										
	pop r27
    pop r26
    
    cpi r24,0x0a					;ean den exei paththei kanena egkyro plhktro, o r24 8a exei thn timh > 0x0a
	brcc wait_for_dec_keypad		;opote ksanadiabazoume apo to plhktrologio
	ret


;-------------Etoimes routines keypad------------


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
    push r22
    push r23
    push r26
    push r27

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
	
    pop r27
    pop r26
    pop r23
    pop r22
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


;--------------------------------------------Routines o8onhs LCD------------------------------

lcd_conv_write:
    push r24
    rcall convert_hex_to_ascii
    rcall lcd_data
    pop r24
    ret


lcd_message:
    push r24
    push zh
    push zl


    lcd_message_loop:
    lpm r24,Z+
    ;adiw zl,1
    tst r24
    breq lcd_message_end
    rcall lcd_data
    rjmp lcd_message_loop
    lcd_message_end:
    pop zl
    pop zh
    pop r24
    
    ret


lcd_clear:
    push r24
    push r25

    ldi r24,0x01
    rcall lcd_command
    ldi r24,low(1530)
    ldi r25,high(1530)
    rcall wait_usec

    pop r25
    pop r24
    ret


lcd_display_dec_2:
    push r24
    rcall convert_bin_to_dec_unsigned
    rcall get_tens
    rcall convert_hex_to_ascii
    rcall lcd_data
    rcall get_units
    rcall convert_hex_to_ascii
    rcall lcd_data
    pop r24
    ret


lcd_display_dec_3:
    push r24
    rcall convert_bin_to_dec_unsigned
    rcall get_hundreds
    rcall convert_hex_to_ascii
    rcall lcd_data
    rcall get_tens
    rcall convert_hex_to_ascii
    rcall lcd_data
    rcall get_units
    rcall convert_hex_to_ascii
    rcall lcd_data
    pop r24
    ret


lcd_display_hex:
    push r24
    rcall get_ms_nibble
    rcall convert_hex_to_ascii
    rcall lcd_data
    pop r24
    push r24
    rcall get_ls_nibble
    rcall convert_hex_to_ascii
    rcall lcd_data
    pop r24
    ret


lcd_display_dec_2_no_zeros:
    push r24
    rcall convert_bin_to_dec_unsigned
    rcall get_tens
    tst r24
    breq lcd_display_dec_2_no_zeros_next
    rcall convert_hex_to_ascii
    rcall lcd_data
    
    lcd_display_dec_2_no_zeros_next:
    rcall get_units
    rcall convert_hex_to_ascii
    rcall lcd_data
    pop r24
    ret


lcd_display_dec_3_no_zeros:
    push r24
    
    rcall convert_bin_to_dec_unsigned
    rcall get_hundreds
    breq lcd_display_dec_3_no_zeros_next_1
    rcall convert_hex_to_ascii
    rcall lcd_data
    
    rcall get_tens
    rcall convert_hex_to_ascii
    rcall lcd_data
    rcall get_units
    rcall convert_hex_to_ascii
    rcall lcd_data
    
    pop r24
    ret

    lcd_display_dec_3_no_zeros_next_1:
    rcall get_tens
    tst r24
    breq lcd_display_dec_3_no_zeros_next_2
    rcall convert_hex_to_ascii
    rcall lcd_data

    lcd_display_dec_3_no_zeros_next_2:
    rcall get_units
    rcall convert_hex_to_ascii
    rcall lcd_data

    pop r24
    ret


lcd_display_hex_no_zeros:
    push r24
    rcall get_ms_nibble
    tst r24
    breq lcd_display_hex_no_zeros_next
    rcall convert_hex_to_ascii
    rcall lcd_data
    pop r24
    push r24
    
    lcd_display_hex_no_zeros_next:
    rcall get_ls_nibble
    rcall convert_hex_to_ascii
    rcall lcd_data
    pop r24
    ret

;---------Etoimes routines lcd------------


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
    push r24
    push r25

	sbi PORTD, PD2 
	rcall write_2_nibbles 
	ldi r24, 43
	ldi r25, 0 
	rcall wait_usec

    pop r25
    pop r24
	ret	
	

lcd_command:
    push r24
    push r25

	cbi PORTD ,PD2 
	rcall write_2_nibbles 
	ldi r24, 39 
	ldi r25, 0 
	rcall wait_usec

    pop r25
    pop r24 
	ret	
	

lcd_init:
    push r24
    push r25

	ldi r16, 0b11111100			;PROS8HKH: eksodoi ta 6 MSB, eisodoi ta 2 LSB ths thuras PORTD (gia xrhsh ths LCD)
	out DDRD, r16					

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
	
    pop r25
    pop r24
    ret

;--------------------------------------Routines 8ermometrou----------------------------------------

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


;------------Etoimes routines 8ermometrou----------

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


;------------------------------------Etoimes routines usart--------------------------


; Routine: usart_init
; Description:
; This routine initializes the
; usart as shown below.
; ------- INITIALIZATIONS -------
;
; Baud rate: 9600 (Fck= 8MHz)
; Asynchronous mode
; Transmitter on
; Reciever on
; Communication parameters: 8 Data ,1 Stop , no Parity
; --------------------------------
; parameters: None.
; return value: None.
; registers affected: r24
; routines called: None
usart_init:
clr r24 ; initialize UCSRA to zero
out UCSRA ,r24
ldi r24 ,(1<<RXEN) | (1<<TXEN) ; activate transmitter/receiver
out UCSRB ,r24
ldi r24 ,0 ; baud rate = 9600
out UBRRH ,r24
ldi r24 ,51
out UBRRL ,r24
ldi r24 ,(1 << URSEL) | (3 << UCSZ0) ; 8-bit character size,
out UCSRC ,r24 ; 1 stop bit
ret



; Routine: usart_transmit
; Description:
; This routine sends a byte of data
; using usart.
; parameters:
; r24: the byte to be transmitted
; must be stored here.
; return value: None.
; registers affected: r24
; routines called: None.
usart_transmit:
sbis UCSRA ,UDRE ; check if usart is ready to transmit
rjmp usart_transmit ; if no check again, else transmit
out UDR ,r24 ; content of r24
ret




; Routine: usart_receive
; Description:
; This routine receives a byte of data
; from usart.
; parameters: None.
; return value: the received byte is
; returned in r24.
; registers affected: r24
; routines called: None.
usart_receive:
sbis UCSRA ,RXC ; check if usart received byte
rjmp usart_receive ; if no check again, else read
in r24 ,UDR ; receive byte and place it in
ret 



;--------------------------------------------------Etoimes routines ADC------------------------


; Routine: ADC_init
; Description:
; This routine initializes the
; ADC as shown below.
; ------- INITIALIZATIONS -------
;
; Vref: Vcc (5V for easyAVR6)
; Selected pin is A0
; ADC Interrupts are Enabled
; Prescaler is set as CK/128 = 62.5kHz
; --------------------------------
; parameters: None.
; return value: None.
; registers affected: r24
; routines called: None
ADC_init:
Ldi r24,(1<<REFS0) ; Vref: Vcc
Out ADMUX,r24 ;MUX4:0= 00000 forA0.
;ADC is Enabled (ADEN=1)
;ADC Interrupts are Enabled (ADIE=1)
;SetPrescaler CK/128 = 62.5Khz (ADPS2:0=111)
ldi r24,(1<<ADEN)|(1<<ADIE)|(1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0)
out ADCSRA,r24
ret



