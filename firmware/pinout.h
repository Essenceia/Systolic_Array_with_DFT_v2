#ifndef _PINNOUT_H
#define _PINNOUT_H

/* define pinnout to FPGA emulation */ 
#define DATA_W        8
#define DATA_WR_BASE_PIN 0 
#define DATA_RD_BASE_PIN  8
#define CTRL_WR_VALID_PIN 16
#define CTRL_WR_MODE_PIN  17
#define CTRL_RD_VALID_PIN 26
#define BUS_CLK_PIN 28


typedef struct __attribute__((packed)) {
	uint8_t data_i;
	uint8_t res_o;
	uint8_t valid_i : 1;
	uint8_t data_mode_i : 1;
	uint8_t data_rst_addr_i : 1;
	uint8_t ready_o : 1;
	uint8_t unusued : 3;
	uint8_t padding : 3; /* rpi-pico doesn't expose pins in order, after gpio 22 the next pin is gpio 26 */ 
	uint8_t res_valid_o : 1;
	uint8_t padding1 : 5;	
} pinout_t;

_Static_assert(sizeof(pinout_t) == (32/8));

/* protocol fields mask, wiring specific */ 
#define DATA_MASK      (uint32_t) 0xFF
#define CTRL_DATA_MASK (uint32_t) 0x7



#endif //_PINNOUT_H
