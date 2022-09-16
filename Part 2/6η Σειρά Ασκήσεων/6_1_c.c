#define F_CPU 8000000UL
#include <avr/io.h>
#include <util/delay.h>

//********************************************************

int one_wire_receive_byte(){
    int temp = 0;
    for (int i=0; i<8; i++){
        temp |= one_wire_receive_bit()<<i;
    }

    return temp;
}



int one_wire_receive_bit(){
    volatile int temp;
    
    DDRA |= 0b00010000;
    PORTA &= 0b11101111;
    _delay_us(2);

    DDRA &= 0b11101111;
    PORTA &= 0b11101111;
    _delay_us(10);

    if (PINA & 0b00010000) temp = 1;
    else temp = 0;

    _delay_us(49);

    return temp;
}



void one_wire_transmit_byte(int temp){
    temp &= 0xFF;
    for (int i=0; i<8; i++){
        one_wire_transmit_bit(temp>>i);
    }
}



void one_wire_transmit_bit(int temp){

    temp &= 0x01;

    DDRA |= 0b00010000;
    PORTA &= 0b11101111;
    _delay_us(2);

    if (temp) PORTA |= 0b00010000;
    else PORTA &= 0b11101111;
    _delay_us(58);

    DDRA &= 0b11101111;
    PORTA &= 0b11101111;
    _delay_us(1);
}



int one_wire_reset(){
    volatile int temp;
    
    DDRA |= 0b00010000;
    PORTA &= 0b11101111;
    _delay_us(480);

    DDRA &= 0b11101111;
    PORTA &= 0b11101111;
    _delay_us(100);

    temp = PINA;
    _delay_us(380);
    
    if (temp & 0b00010000) return 0;
    return 1;
}

//************************************

int temperature_sensor(){
    int temp;
    
    if (!one_wire_reset()) return 0x8000;       //An paroume pisw 0, den exoume syskeyh, opote epistrefoume 0x8000

    one_wire_transmit_byte(0xCC);               //command 0xCC: parakampsh epiloghs syskeyhs
    one_wire_transmit_byte(0x44);               //command 0x44: ekkinhsh metrhshs 8ermokrasias

    while (!one_wire_receive_bit()){};          //Perimenw mexri na parw 1, opote kai termatizetai h metrhsh

    if (!one_wire_reset()) return 0x8000;       //An paroume pisw 0, den exoume syskeyh, opote epistrefoume 0x8000

    one_wire_transmit_byte(0xCC);               //command 0xCC: parakampsh epiloghs syskeyhs
    one_wire_transmit_byte(0xBE);               //command 0xBE: anagnwsh ths 8ermokrasias (16 bit)

    temp = one_wire_receive_byte();             //1o byte: h timh, to bazoume sta 8 LSB

    temp |= (one_wire_receive_byte()<<8);       //2o byte: epektash proshmo, to bazoume sta 8 MSB

    return temp;    
}



void output_6_1_routine(int temp){
    DDRB = 0xFF;
    if ((temp & 0xFF00) == 0xFF00) PORTB = ((temp-1) & 0xFF);   //An ston 16-bit ta 8 MSB einai 0xFF, exoume arnhtiko
	else if(temp == 0x8000) PORTB = 0xFF;                       //An exoume 0x8000, den exoume syskeyh
    else PORTB = (temp & 0xFF);                                 //Diaforetika, ola komple opws einai
}


//************************************************


int main(void){   
    int temp;         

	DDRB = 0xFF;
	PORTB = 0;

    while (1){
        temp = temperature_sensor();
        output_6_1_routine(temp);
    }
	
	return 0;
}
