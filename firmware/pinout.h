#ifndef _PINNOUT_H
#define _PINNOUT_H

/* define pinnout to FPGA emulation */ 
#define BUS_DATA_W        8
#define DATA_WR_BASE_PIN  0 
#define DATA_RD_BASE_PIN  8
#define CTRL_WR_BASE_PIN  16
#define CTRL_WR_VALID_PIN 16
#define CTRL_WR_MODE_PIN  17
#define CTRL_RD_VALID_PIN 26
#define BUS_CLK_PIN       28


typedef struct __attribute__((packed)) {
	uint8_t data_i; // wr data
	uint8_t res_o; // rd data
	uint8_t valid_i : 1; // wr valid
	uint8_t data_mode_i : 2;// wr mode
	uint8_t unusued : 4; // jtag ( not driven by rpi )
	uint8_t padding : 3; /* rpi-pico doesn't expose pins in order, after gpio 22 the next pin is gpio 26 */ 
	uint8_t res_valid_o : 1;// rd valid
	uint8_t unused1 : 5;	
} pinout_t;

_Static_assert(sizeof(pinout_t) == (32/8));



#endif //_PINNOUT_H
