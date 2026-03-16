#ifndef _DATA_H
#define _DATA_H

#include "bfloat16.h" 

/* common data format definition library */

// TPU matrix dimentions
#define N 2
#define NN 4

#define DATA_TYPE bfloat16_t 
#define DATA_W (size_t) (sizeof(DATA_TYPE)*(size_t)NN)

typedef union __attribute__((packed)) {
	bfloat16_t bf[NN];
	uint8_t u[2*NN];
} data_t;

_Static_assert(sizeof(data_t) == 2*NN);

#endif // _DATA_H
