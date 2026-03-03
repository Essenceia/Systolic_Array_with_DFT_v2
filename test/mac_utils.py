# MAC testing utils library
#
# Julia Desmazes, 2025, human made code

import cocotb
from cocotb.triggers import ClockCycles
import random 
from array import array 

N=2 # CAM array dimention 
NN = 2*2

BASE_W = 2 # Base type width in bytes

RES_SIZE = N*N*BASE_W

MODE_DATA   = 0
MODE_WEIGHT = 1
MODE_RST    = 2
MODE_ASM    = 3


# cover full range of u16
MIN_VAL = 0
MAX_VAL = 65535

# Dissable data transfert for "cycles" cycles.
# Used to simulate realistic conditions where the data transfer
# from the master (microcontroller, FPGA) would be done in bursts.
# Using the RP2040 this might occure when the PIO write sequence is
# stalled due to the DMA transfer no keeping up with the PIO write
# rate and the TX FIFO being empty. 
async def invalid_data(dut, cycles):
    for i in range(0, cycles):
        dut.uio_in.value = 0
        dut.ui_in.value = 0
        await ClockCycles(dut.clk,1)



# Generate data command configuration, sent allong each valid data
# transfer data cycle to convay metadata about the data. 
#
# --- MAC ---
#
# valid - 1 - data transfer contains valid information
#
# mode - [3:2]
# value - meaning
#     0 - cam input data
#     1 - weight
#     2 - rst
#     3 - asm
#
# --- JTAG --- 
# tdi - 4 - input data 
# tms - 5 - fsm transition selection
#
def get_cmd(valid=True, mode=MODE_DATA, tdi=False, tms=False):
    ret = 0
    if valid:
        ret |= 1 << 1
    ret |= mode << 2
    if tdi:
        ret |= 1 << 4
    if tms: 
        ret |= 1 << 5

    return ret

# Signed to Unsigned
def stou(n): 
  return int.from_bytes(n.to_bytes(1, 'little', signed=True), 'little', signed=False)

# Configure weight values.
#
# In practice it is not necessary for the weight config to be 
# done before each MAC operation, the same weights can be re-used for
# multiple MAC operations.
#
# Data on the other hand must be re-sent for every configuration. If 
# we had more area and the macro we could store it in proximity to the 
# array. Since weights have better temporal locality, the tradeoff was
# made in favor of the weights. 
async def write_config(dut, X, weight=True):
    mode = MODE_WEIGHT if weight == True else MODE_DATA 
    assert(len(X) == NN) 
    config = X.tobytes()

    cocotb.log.info("config %s", config)

    for i in range(0,NN*BASE_W):
        if (random.randrange(0,100) > 75):
            await invalid_data(dut, random.randrange(1,5)) 
        dut.ui_in.value = (config[i] << 1) & 0xFE
        uio_in = get_cmd(valid=True, mode=mode) | (config[i] >> 7 & 0x01)
        dut.uio_in.value = uio_in
        cocotb.log.debug("write config %d:%s %s", i, config[i], uio_in)
        await ClockCycles(dut.clk,1)
    dut.uio_in.value = 0

async def rst_data_addr(dut):
    dut.uio_in.value = get_cmd(valid=True, mode=MODE_RST)
    await ClockCycles(dut.clk, 1)


# bias random towards smaller number to get better coverage of math operations
def biased_random(min, max):
    assert(min <= -15)
    assert(max >= 15)
    if (random.randint(0,1)):
        return random.randint(-5,5)
    if (random.randint(0,1)):
        return random.randint(-8,8)
    if (random.randint(0,1)):
        return random.randint(-10,10)
    return random.randint(min, max)
   


def clamp(x): 
    if (x >= MAX_VAL): 
        return MAX_VAL
    return x

def mac(W,I):
    res = array('H', [0,0,0,0])
    assert(len(W) == NN)
    assert(len(I) == NN)
    for x in range(0,N):
        for y in range(0,N):
            for ix in range(0,N):
                mul = clamp(I[y*N+ix]*W[ix*N+x])
                tmp = clamp(res[y*N+x] +  mul)
                res[y*N+x] = tmp
    return res
