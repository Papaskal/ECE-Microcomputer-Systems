#include <avr/io.h>
#include <avr/interrupt.h>

volatile unsigned char temp, input, leds, flag=0, state=0;

ISR(INT0_vect)			//Routina eksyphrethshs diakophs INT0
{
    if (!flag){			//An to flag einai clear (ara einai to prwto pathma)
		flag=0xFF;		//8etoume to flag
    	TCCR1B = 0x05;	//8emoume taxythta xronisth CLK/1024
    	leds = 0x80;	//Anaboume to MSB led
    	PORTA = leds;	//Kai 8etoume to xronisth na yperxeilisei
    	TCNT1H = 0xA4;	//meta apo 3 sec
    	TCNT1L = 0x72;
	}
	else {
		TCCR1B = 0x05;	//Diaforetika, kanoume renew
        leds = 0xFF;	//8etoume taxythta xronisth CLK/1024
        PORTA = leds;	
        TCNT1H = 0xF0;	//Anaboume ola ta led
        TCNT1L = 0xBD;	//meta apo 0.5 sec
	}
}

ISR(TIMER1_OVF_vect)
{
    if (PORTA == 0x80){		//An einai anammeno MONO to MSB led
		leds = 0x00;		//ayto shmainei pws yperxeilisame meta apo 3 sec
        PORTA = leds;		//Ara sbhnoume ta led
        TCCR1B = 0x00;		//Stamatame to xronisth
    	flag = 0x00;		//Kai kanoume clear to flag
	}		        
    else {					//Diaforetika, efoson yperxeilise kai den einai anammeno mono to MSB.
        leds = 0x80;		//ayto shmainei pws yperxeilise meta apo ta 0.5 sec
        PORTA = leds;		//Opote anaboume to MSB (mono)
        TCNT1H = 0xB3;		//Kai 8etoume to xronisth na yperxeilisei meta apo 2.5 sec
        TCNT1L = 0xB5;		//efoson exoun perasei hdh 0.5 sec (0.5 + 2.5 = 3 sec)
    }
}

int main(void)
{
    DDRB = 0x00;		//H B ws eisodos
    PORTB = 0x00;
	DDRD = 0x00;		// port D = input
	PORTD = 0x00;		// disable pull-up resistances

	DDRA = 0xFF;		// port A = output

    TCCR1B = 0x00;		//Sigoureyomaste pws o xronisths de metraei

    GICR = (1<<INT0);	//Enable th diakoph INT0
    MCUCR = 0x03;		//H INT0 ginetai sthn anerxomenh akmh
	TIMSK = (1<<TOIE1);	//Enable th diakoph yperxeilishs tou timer 1

    sei();				//Ka8oliko enable twn diakopwn
	
	while (1) {
		input = (PINB&0x01);		//To input 8a exei thn eisodo mas atm
		state = state | input;	 	//To state 8a ginei 1 h eisodos mas ginei 1 kai
									//8a parameinei 1 akoma ki an eisodos mhdenistei
        
		if (!input && state){		//Ann to koumpi path8hke kai afe8hke:	
			state = 0x00;			//Clear to state (ikanopoih8hke h syn8hkh)
		
			if (!flag){				//An to flag einai clear (ara einai to prwto pathma)
				flag=0xFF;			//8etoume to flag
            	TCCR1B = 0x05;		//8emoume taxythta xronisth CLK/1024
            	leds = 0x80;		//Anaboume to MSB led
            	PORTA = leds;
            	TCNT1H = 0xA4;		//Kai 8etoume to xronisth na yperxeilisei
            	TCNT1L = 0x72;		//meta apo 3 sec
			}
			else {					//Diaforetika, kanoume renew
				TCCR1B = 0x05;		//8etoume taxythta xronisth CLK/1024
            	leds = 0xFF;		//Anaboume ola ta led
            	PORTA = leds;
            	TCNT1H = 0xF0;		//Kai 8etoume to xronisth na yperxeilisei
            	TCNT1L = 0xBD;		//meta apo 0.5 sec
	        }
		}

    }
	return 0;
}
