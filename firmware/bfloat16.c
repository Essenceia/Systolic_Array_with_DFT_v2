#include "bfloat16.h"
void _validate_bf16(bfloat16_t bf){
	assert(bf.e != BF16_MAX_EXP);
}

// converstion functions
static bfloat16_t _conv_valid_input(bfloat16_t bf){
	if (bf.e == BF16_MAX_EXP)return BF16_DEFAULT; 
	return bf;
}

bfloat16_t f32_to_bf16(float32_t f){
	f32_to_bf16 u; 
	u.f32 = f;
	return _conv_valid_input(u.bf16);
}
