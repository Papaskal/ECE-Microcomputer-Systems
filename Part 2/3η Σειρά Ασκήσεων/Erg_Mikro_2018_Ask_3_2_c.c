#include <avr/io.h> //Orismos mikroelegkth avr ATmega16 
unsigned char temp, A, B, C, D, E, F0, F1, F2;
 
void main(void) 
{ 
DDRC = 0x00;  	//orizoume th 8yra C ws eisodo 
PORTC = 0x00; 	//disable pull-up resistors  
DDRA = 0xFF;  	//H 8yra A ws eksodos  

while (1)		//atermwn brogxos (h syn8hkh einai panta alh8hs)
{
 
temp = PINC; 	//Diabasma eisodou   



A = temp;  	//Bazoume ta bit twn dedomenwn mas
temp = temp >> 1;  //sta LSB twn metablhtwn mas
B = temp;  	//A<-b0, B<-b1, C<-b2, D<-b3, E<-b4  
temp = temp >> 1;  
C = temp;  	   
temp = temp >> 1;  
D = temp;  	  
temp = temp >> 1;  
E = temp;  	
  
F0 = ~((A&B) | (B&C) | (C&D) | (D&E)) ;  	//F0 = (AB + BC + CD + DE)'  
F0 = F0 & 0x01;  		//Maska gia na apomonwsoume to LSB   
F1 = (A & B & C & D) | (~D & ~E); 	//F1 = ABCD + D'E' 
F1 = F1 & 0x01; 			//Apomonwsh tou LSB  
F2 = F0 | F1; 				//F2 = F0 + F1  
 
Eksodos:   
F1 = F1 << 1;  	//Topo8ethsh sthn katallhlh 8esh 
F2 = F2 << 2;  	
temp = F0 | F1 | F2;  
PORTA = temp ;    //eksodos
};
}
