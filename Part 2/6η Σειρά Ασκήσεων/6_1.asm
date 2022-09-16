.include "m16def.inc"							; prosthhkh arxeiou kefalidas gia xeirismo thurwn E/E mesw twn sumvolikwn etiketwn tous
.def temp = r16
.def temp2 = r17

.org 0
rjmp reset


reset:
	ldi temp, high(ramend)							; arxikopoihsh deikth stoivas, diadikasia APARAITHTH efoson exoume klhsh toulaxiston enos upoprogrammatos
	out sph, temp
	ldi temp, low(ramend)
	out spl, temp



main:
    rcall temperature_routine_6_1
	rcall output_6_1_routine
rjmp main


;*************************Eidikes routines*******************************


temperature_routine_6_1:
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
	push r24					        ;Thn kanoume back up
	
    ;ldi r24, 0xBE
	rcall one_wire_receive_byte			;To 2o byte einai epektash proshmou(0x00=+,0xFF=-)
	
	mov r25,r24							;Epektash proshmou ston r25
	pop r24     						;Timh ston r24

	ret



output_6_1_routine:
    sbrc r25, 0						;An to lsb tou r25 einai 1, tote r25=0xFF kai exoume arnhtiko 
	dec r24							;se 2's complement, opote afairoume 1 gia 1's complement 

	;lsr r24						;Diairesh dia 2 gia na paroume th swsth akeraia 8ermokrasia

    ser temp                        ;temp := 0xFF
    ldi temp2,0x80
	cpse r25,temp2                  ;Ean o r25 dinei 0x80, dhladh den exoume syndesei syskeyh
    mov temp,r24                    ;Bazoume ston kataxwrhth r24 thn timh 0xFF (de mas to zhthse kaneis)
    mov r24,temp

    ser temp						;orismos ths PORTB ws thuras eksodou
    out DDRB, temp    
	out PORTB, r24					;Eksodos h timh ths 8ermokrasias (h 0xFF an den exoume syskeyh)

	ret


;************************************ Etoimes routines *****************************************

; 
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

wait_usec:
	sbiw r24, 1
	nop
	nop
	nop
	nop
	brne wait_usec
	ret

wait_msec: 
	push r24
	push r25
	ldi r24, low(998)
	ldi r25, high(998)
	rcall wait_usec
	pop r25
	pop r24
	sbiw r24, 1
	brne wait_msec
	ret

