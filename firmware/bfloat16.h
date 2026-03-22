#ifndef _BFLOAT16_H
#define _BFLOAT16_H
#include <stdint.h> 

/* bfloat16_t is not a standard C type, and definatly not present by default in 
   this embedded standard lib. Defining a simulacre of bfloat16 to be manipulated
   by accelerator. */
typedef struct{
	uint8_t m :7;
	uint8_t e :8;
	uint8_t s :1;
} __attribute__((packed)) bfloat16_t;

#define BF16_MAX_EXP (uint8_t)0xFF
#define BF16_ZERO_POS (bfloat16_t){.s = 0, .e = 0, .m = 0}
#define BF16_DEFAULT BF16_ZERO_POS

_Static_assert(sizeof(float) == 4);
typedef float float32_t; 

typedef union{
	float32_t f32; 
	struct{
		uint16_t pad;
		bfloat16_t bf16;	
	};
} __attribute__((packed)) f32_bf16_u;

typedef union {
	uint16_t u16;
	bfloat16_t bf16;
}__attribute__((packed)) u16_bf16_u;

static void _validate_bf16(bfloat16_t bf);
static bfloat16_t _conv_valid_input(bfloat16_t bf);

bfloat16_t f32_to_bf16(float32_t f);
float bf16_to_f32(bfloat16_t bf);

bfloat16_t rand_bf16();
#endif // _BFLOAT16_H
