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


/*
void lcd_message(int msg_size, char msg[]){ //anti gia string, isws char array: char msg[]
    for (int i=0; i<msg_size; i++)  lcd_data(msg[i]);
}
*/


void lcd_message(char msg[]){
    for (int i=0; msg[i]; i++) lcd_data(msg[i]);
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


void usart_message(char msg[]){
	for (int i=0; msg[i]; i++) usart_transmit(msg[i]);
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


//-------------------------------------------------------------------


int main(void){
	int temp;

    char valid_msg[6] = {'R', 'e', 'a','d',' ','\0'};
    char invalid_msg[15] = {'I','n','v','a','l','i','d',' ','n','u','m','b','e','r','\0'};

    set_output('C');        //C Eksodos
    lcd_init();             //Arxikopoihsh lcd
	usart_init();           //Arxikopoihsh usart

    while (1){
        temp = usart_receive();     //Lambanoume apo usart
		lcd_command(0x01);          //Ka8arizoume thn o8onh
		_delay_ms(2);               //Perimenoume 2 extra msec (to clear screen 8elei 1.53 msec)
        lcd_command(0x80);          //8etoume to deikth sthn prwth 8esh ths o8onhs

        if (temp<='8' && temp>='0'){        //An do8hke ari8mos apo 0 ews 8
            lcd_message(valid_msg);      //Typwnoume to "Read "
            lcd_data(temp);                 //Typwnoume to noumero pou labame
                               
			
			usart_message(valid_msg);
			usart_transmit(temp);
			usart_transmit('\n');

			temp -= '0';				//Metatrepoume apo ascii se ari8mhtikh timh
            output_to('C',0b100000000>>(9-temp));   //Probaloume to zhtoumeno sta led C
        }
        else {
			lcd_message(invalid_msg);  	//An do8hke invalid char, typwnoume to invalid
    		usart_message(invalid_msg);
			usart_transmit('\n');	
		}
	}
	return 0;
}
