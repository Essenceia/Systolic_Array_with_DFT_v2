#ifndef _DATA_RD_UTILS
#define _DATA_RD_UTILS

#include "pico/stdlib.h"
#include "hardware/pio.h"
#include "data.h"

#define PIO_FIFO_W 4 // Bytes

// init dma
uint init_rd_dma_channel(PIO pio, uint sm);

// setup dma stream to capture result
void setup_rd_dma_res_stream(uint dma_chan, size_t l, uint8_t* buffer, size_t bl, PIO pio, uint sm);

// read hash from already setup read stream 
void read_res(data_t* res, uint8_t* buffer, size_t bl, uint dma_chan);

#endif // _DATA_RD_UTILS

