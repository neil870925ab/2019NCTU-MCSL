#include "stm32l476xx.h"
extern void GPIO_init();
extern void max7219_init();
extern void max7219_send(unsigned char address, unsigned char data);
int Map[4][4] = {{1,2,3,10}, {4,5,6,11}, {7,8,9,12}, {15,0,14,13}};

void keypad_init(){

	RCC->AHB2ENR = RCC->AHB2ENR|0x6;	//enable a,b,c

	GPIOB->MODER=GPIOB->MODER&0xFFFFFF00;	//pb 0 1 2 3 as output
	GPIOB->MODER=GPIOB->MODER|0x55;
	GPIOB->PUPDR=GPIOB->PUPDR&0xFFFFFF00;
	GPIOB->PUPDR=GPIOB->PUPDR|0x55;
	GPIOB->OSPEEDR=GPIOB->OSPEEDR|0x55;
	GPIOB->ODR=GPIOB->ODR|0xF;

	GPIOC->MODER=GPIOC->MODER&0xFFFFFF00;	//pc 0 1 2 3as input
	GPIOC->PUPDR=GPIOC->PUPDR&0xFFFFFF00;
	GPIOC->PUPDR=GPIOC->PUPDR|0xAA;


}

int display(int data, int num_digs){

	if(num_digs >= 0 && num_digs <= 8){

		int fac = 10000000;
		for(int i = 8; i > num_digs; i--){
			max7219_send(i, 15);            //'15' means '1111', which is blank in decode mode.
			fac = fac / 10;
		}
		for (int i = num_digs; i > 0; i--){
			int num = data / fac;
			max7219_send(i, num);
			data = data % fac;
			fac = fac / 10;
		}
		return 0;
	}
	else{
		return -1;
	}

}

int display_Blank(){

	for(int i = 1; i <= 8; i++){
		max7219_send(i,0xF);
	}
	return 0;
}

char keypad_scan(){
    int row = 0,col = 0;
    char val = -1;
    int counter;

	GPIOB->ODR=GPIOB->ODR|0xF;
	int flag = GPIOC->IDR&0xF;
	if(flag){
		counter = 1000;
   		while(counter!=0){
   			flag = GPIOC->IDR&0xF;
   			counter--;
   		}
   		if(flag){
	        for(row = 0; row < 4; row++){
	            for(col = 0; col < 4 ; col++){
	            	GPIOB->ODR=GPIOB->ODR&0x0;
	            	GPIOB->ODR=GPIOB->ODR|(1<<col);
	            	flag = GPIOC->IDR&0xF;
	                int flag_shift_row = flag >> row;		// if flag == b1000 (the col 3 (pc3) has been pressed), so right-shift three times.
	                int pressed = flag_shift_row&1;		// to check if it's been pressed

	                if(pressed){
	                    val = Map[row][col];
	                    int num;
	                    if(val >= 10){
	                    	num = 2;
	                    }
	                    else{
	                    	num = 1;
	                    }

	                    display(val, num);
	                    return val;
	                }
	            }
	        }
	    }

    }
    else{
    	display_Blank();
    	return -1;
    }

}

int main(){
	GPIO_init();
	max7219_init();
	keypad_init();
	while(1){
		keypad_scan();
	}
}
