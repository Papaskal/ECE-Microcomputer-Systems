/*
Eksodos sto PortB
Eisodos apo PortD
sw0 aristerh peristrofh
sw1 deksia peistrofh
sw2 anabei mono to led7
sw3 anabei mono to led0
Proteraiothta sw3->sw1
*/

#include <avr/io.h>

int main(void)
{


	DDRD = 0x00;		// port D = input
	PORTD = 0x00;		// disable pull-up resistances
	
	DDRB = 0xFF;		// port B = output
	
	unsigned char input, output = 0x01, state = 0, temp;
	
	while (1) {
		PORTB = output;
		
		input = (PIND & 0x0F);		//To input 8a exei to paron input mas
		state = state | input;		//Gia ka8e bit, an to input ginei 1, estw mia fora, 
									//to state 8a parameinei 1 akoma ki an to input ksanaginei 0

		temp = state;
		
		int button;
		for (button = 3; button >= 0; button--) {
			if ( (temp & 0x08) && !(input & 0x08) ) break;	//Edw gia ka8e bit me th seira proteraiothtas
			temp = temp << 1;								//Elegxoume an to input egine kapoia stigmh 1
			input = input << 1;								//Kai meta pali 0
		}
		//An to loop teleiwsei xwris break, button == -1, opote den energopoeitai kamia case
		
		switch (button) {		//Epiteloume thn antistoixh leitourgia.
			case 0:
				output = (output << 1) | (output >> 7); // peristrofh aristera
				state = state & 0x0E;	//kai mhdenizoume to bit tou state pou ikanopoihsame
				break;
			case 1:
				output = (output >> 1) | (output << 7); //peristrofh deksia
				state = state & 0x0D;
				break;
			case 2:
				output = 0x80;			// anamma MSB led
				state = state & 0x0B;
				break;
			case 3:
				output = 0x01;			// anamma LSB led
				state = state & 0x07;
				break;
		}
		
	}
	return 0;
}
