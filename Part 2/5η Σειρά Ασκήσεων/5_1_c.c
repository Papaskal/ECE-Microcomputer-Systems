#define F_CPU 8000000UL
#include <avr/io.h>
#include <util/delay.h>

int tmp;


int scan_row(int temp){
    int temp2=8, temp3=0;

    temp2 <<= temp;
    PORTC = temp2;
	
	asm ("nop");
	asm ("nop");
    
    temp = (PINC & 0x0F);
	
    return temp;
}


int scan_keypad(){
    int temp, temp2;

    temp = 1;
    temp = scan_row(temp);
	
	temp <<= 12;
    temp2 = temp;

    temp = 2;
    temp = scan_row(temp);
	
	temp <<= 8;
    temp2 += temp;

    temp = 3;
    temp = scan_row(temp);
	
	temp <<= 4;
    temp2 += temp;

    temp = 4;
    temp = scan_row(temp);
	
    temp2 += temp;
    
    return temp2;
}


int scan_keypad_rising_edge(){
    int temp=0, temp2=1;
    
    temp = scan_keypad();
    _delay_ms(20);
    temp2 = scan_keypad();
    temp &= temp2;
    
    temp2 = tmp;            //Bazoume to tmp sto temp2
    tmp = temp;             //Kai to temp sto tmp (swap sthn ousia)
    temp &= ~temp2;         //Mas endiaferoun ta bit pou prin htan 0 kai twra 1

    return temp;
}


int keypad_to_ascii_reducted(int temp) {
	int i;

    if (!temp) return 0;
    for (i=0;i<16;i++){
        if (temp & 0x01) break;
        temp >>= 1;
    }
	
    if (i==1) return '0';
    if (i==4) return '7';
    return '3';         //kati akyro. To 3 einai symboliko...
}


int wait_for_keypad(){
    int temp = 0;

    while (!temp){
        temp = scan_keypad_rising_edge();
        temp = keypad_to_ascii_reducted(temp);
    }
    return temp;
}


void correct(){
    PORTA=0xFF;
    _delay_ms(4000);
	PORTA=0;
}


void incorrect(){
    int i=0;
    for (i=0;i<8;i++){
        PORTA=0xFF;
        _delay_ms(250);
        PORTA=0;
        _delay_ms(250);
    }
}


int main(void)
{   
    int flag, temp;

    DDRC = 0xF0;
    PORTC = 0;
    DDRA = 0xFF;

    temp = scan_keypad_rising_edge();

    while (1){
        flag = 1;
        temp = wait_for_keypad();
        if (temp != '0') flag=0;
        temp = wait_for_keypad();
        if (temp != '7') flag=0;

        if (flag) correct();
        else incorrect();
    }
	
	return 0;
}
