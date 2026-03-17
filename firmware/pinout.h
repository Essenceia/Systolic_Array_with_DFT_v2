#ifndef _PINNOUT_H
#define _PINNOUT_H

/* define pinnout to FPGA emulation */ 
#define BUS_DATA_W        8

/* gpio base pins */
#define DATA_WR_BASE_PIN  0 
#define DATA_RD_BASE_PIN  8
#define CTRL_WR_BASE_PIN  16
#define CTRL_WR_VALID_PIN 16
#define CTRL_WR_MODE_PIN  17
#define CTRL_RD_VALID_PIN 19

#define BUS_CLK_PIN       28 // JC7 


typedef struct __attribute__((packed)) {
	uint8_t data_i;         // wr data  GP[7:0]  -> JADX 
	uint8_t res_o;          // rd data  GP[15:8] -> JA
	uint8_t valid_i : 1;    // wr valid GP[16]   -> JB[JB1]
	uint8_t data_mode_i : 2;// wr mode  GP[18:17]-> JB[JB3:JB2]
	uint8_t res_valid_o : 1;// rd valid GP[19]   -> JB[JB4]
	uint8_t unusued :12;    //    -     GP[31:20]
} pinout_t;

_Static_assert(sizeof(pinout_t) == (32/8));

#endif //_PINNOUT_H
