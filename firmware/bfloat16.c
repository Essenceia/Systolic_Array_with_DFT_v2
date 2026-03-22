#include "bfloat16.h"
#include "pico/assert.h" 
#define PICO_RAND_ENTROPY_SRC_ROSC 1
#include "pico/rand.h"

void _validate_bf16(bfloat16_t bf){
	hard_assert(bf.e != BF16_MAX_EXP);
	if (bf.e == 0)hard_assert(bf.m != 0);
}

// converstion functions
static bfloat16_t _conv_valid_input(bfloat16_t bf){
	if(bf.e == BF16_MAX_EXP)return BF16_DEFAULT;
	if(bf.e == 0)bf.m = 0; 
	return bf;
}

bfloat16_t f32_to_bf16(float32_t f){
	f32_bf16_u u; 
	u.f32 = f;
	return _conv_valid_input(u.bf16);
}

float bf16_to_f32(bfloat16_t bf){
	f32_bf16_u u; 
	u.bf16 = bf; 
	u.pad = 0;
	return u.f32;
}

bfloat16_t rand_bf16(){
	u16_bf16_u rand = { .u16 = 0xffff & get_rand_32() };
	return _conv_valid_input(rand.bf16); 
}
