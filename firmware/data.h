#ifndef _DATA_H
#define _DATA_H

#include "bfloat16.h" 

/* common data format definition library */

// TPU matrix dimentions
#define N 2
#define NN 4

typedef struct __attribute__((packed)) {
	bfloat16_t data[NN];
} data_t;


#endif // _DATA_H
