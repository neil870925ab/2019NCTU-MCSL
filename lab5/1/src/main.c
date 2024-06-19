//These functions inside the asm file
extern void GPIO_init();
extern void max7219_init();
extern void max7219_send(unsigned char address, unsigned char data);
/**
* TODO: Show data on 7-seg via max7219_send
* Input:
* data: decimal value
* num_digs: number of digits will show on 7-seg
* Return:
* 0: success
* -1: illegal data range(out of 8 digits range)
*/

int display(int data, int num_digs){

	if(num_digs >= 0 && num_digs <= 8){

		int fac = 10000000;
		for(int i = 8; i > num_digs; i--){	//if student id = 0613246 (7 words) and num_digs = 8, show one blank before '0'.
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

int main(){

	int student_id = 613246;
	GPIO_init();
	max7219_init();
	display(student_id, 7);

}

