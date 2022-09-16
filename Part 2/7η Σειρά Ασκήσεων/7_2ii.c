#define F_CPU 8000000UL
#include <avr/io.h>
#include <util/delay.h>



void write_2_nibbles(int temp){
    int temp2;

    temp2 = PIND;
    temp2 &= 0x0F;

    PORTD = (temp & 0xF0) + temp2;

    PORTD |= 0b00001000;
    PORTD &= 0b11110111;

    temp <<= 4;
    PORTD = (temp & 0xF0) + temp2;

    PORTD |= 0b00001000;
    PORTD &= 0b11110111;
}



void lcd_data(int temp){
    PORTD |= 0b00000100;
    write_2_nibbles(temp);
    _delay_us(43);
}



void lcd_command(int temp){
    PORTD &= 0b11111011;
    write_2_nibbles(temp);
    _delay_us(39);
}



void lcd_init(){
    DDRD |= 0b11111100;

    _delay_ms(40);
    
    PORTD = 0b00110000;
    PORTD |= 0b00001000;
    PORTD &= 0b11110111;

    _delay_us(39);
    
    PORTD = 0b00110000;
    PORTD |= 0b00001000;
    PORTD &= 0b11110111;

    _delay_us(39);

    PORTD = 0b00100000;
    PORTD |= 0b00001000;
    PORTD &= 0b11110111;

    _delay_us(39);

    lcd_command(0x28);
    lcd_command(0x0C);
    lcd_command(0x01);

    _delay_us(1530);

    lcd_command(0x06);
}



void lcd_message(int msg_size, char msg[]){ //anti gia string, isws char array: char msg[]
    for (int i=0; i<msg_size; i++)  lcd_data(msg[i]);
}



void usart_init(){
    UCSRA = 0x00;
    UCSRB = (1<<RXEN) | (1<<TXEN);
    UBRRH = 0x00;
    UBRRL = 51;
    UCSRC = (1<<URSEL) | (3<<UCSZ0);
}



void usart_transmit(int temp){
    while (!(UCSRA & (1<<UDRE))){};
    UDR = temp;
}



char usart_receive(){
	while (!(UCSRA & (1<<RXC))){};
    return UDR;
}


void ADC_init(){
    ADMUX = (1<<REFS0);
    ADCSRA = (1<<ADEN) /* | (1<<ADIE) */ | (1<<ADPS2) | (1<<ADPS1) | (1<<ADPS0);
}





void set_output(int temp){          
    switch(temp){
        case 'A'    :
        case 'a'    :   DDRA = 0xFF; break;
        case 'B'    :
        case 'b'    :   DDRB = 0xFF; break;
        case 'C'    :
        case 'c'    :   DDRC = 0xFF; break;
        case 'D'    :
        case 'd'    :   DDRD = 0xFF; break;
    }
}



void output_to(int gate, int temp){
    switch(gate){
        case 'A'    :
        case 'a'    :   PORTA = temp; break;
        case 'B'    :
        case 'b'    :   PORTB = temp; break;
        case 'C'    :
        case 'c'    :   PORTC = temp; break;
        case 'D'    :
        case 'd'    :   PORTD = temp; break;
    }
}


int main(void){

	unsigned int temp,temp2;
    
    set_output('C');                //C eksodos
    usart_init();                   //Arxikopoihsh usart
    ADC_init();                     //Arxikopoihsh ADC
	lcd_init();
    
    ADCSRA |= 1<<ADSC;              //Ksekiname mia metrhsh tashs	

    while (1){                          //Ean to bit ADSC einai 1, den exei oloklhrw8ei h metrhsh, opote perimenoume
        if (!(ADCSRA & (1<<ADSC))){     //Ean to bit ADSC ginei 0, pairnoume th metrhsh
		    temp = (ADC & 0x3FFF);      //Kratame mono ta 10 teleytaia bit
                                        //Einai V = ADC*5/1024
		    temp = (temp*50)/1024;      //Epeidh 8eloume kai to prwto klasmatiko, pollaplasiazoume epipleon me to 10
		
		    temp2 = temp % 10;            //Pairnoume to teleytaio dec pshfio (sthn pragmatikothta to klasmatiko meros)
		    temp /= 10 ;                //Pairnoume o,ti menei (to akeraio meros) (me timh 0<x<5)
		    //temp %= 10;
		
		    usart_transmit(temp + '0');     //Stelnoume thn ascii timh tou akeraiou merous
		    lcd_command(0x80);
			lcd_data(temp +'0');

			usart_transmit(',');            //Stelnoume to ','
			lcd_data(',');
		
		    usart_transmit(temp2 +'0');     //Stelnoume thn ascii tou klasmatikou merous
		    lcd_data(temp2 + '0');
			
			usart_transmit('\n');           //Stelnoume allagh grammhs

            ADCSRA |= 1<<ADSC;              //Ksekiname nea metrhsh
		    //_delay_ms(100);
		}
    }

	return 0;
}
