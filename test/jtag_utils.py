# JTAG testing utils library 
#
# Julia Desmazes, 2025, human made code

import cocotb
from cocotb.triggers import ClockCycles
import random 

EXTEST = 0
IDCODE = 1
SAMPLE_PRELOAD = 2
USER_REG = 3
BYPASS = 7
IR_L = 3 

# number of input and output pins
PIN_IN_N = 11
PIN_OUT_N = 9
# Boundary scan chain length 
BSC_LENGTH = PIN_IN_N + PIN_OUT_N 

USER_REG_W = 8

def set_cmd(dut,tms=False, tdi=False):
	if (tms):
	    dut.tms.value = 1
	else:
		dut.tms.value = 0
	if (tdi):
	    dut.tdi.value = 1
	else: 
		dut.tdi.value = 0

# jtag tap is placed in rst after at least 5 TMS transitions
# then transition the fsm to idle
async def rst_jtag_tap(dut):
	x = random.randint(5, 20)
	for _ in range(0,x):
	    set_cmd(dut,tms=True)
	    await ClockCycles(dut.tck, 1)
	
	set_cmd(dut,tms=False)
	await ClockCycles(dut.tck, 1)
   
   
# assumes we are starting our command from the idle position
async def set_ir(dut, ir, irl=IR_L):
	# idle 
	set_cmd(dut,tms=True)
	await ClockCycles(dut.tck, 1)
   
	# dr select
	set_cmd(dut,tms=True)
	await ClockCycles(dut.tck, 1)
 
	# ir select 
	set_cmd(dut,tms=False)
	await ClockCycles(dut.tck, 1)
	
	# capture ir
	set_cmd(dut,tms=False)
	await ClockCycles(dut.tck, 1)
   
	# shift ir
	for i in range(0, irl):
	    tdi = (ir >> i) & 0x1
	    set_cmd(dut,tms=(i == irl-1), tdi=(tdi == 1))
	    await ClockCycles(dut.tck, 1)
	
	# exit 1r
	set_cmd(dut,tms=True)
	await ClockCycles(dut.tck, 1)
	
	# update ir
	set_cmd(dut,tms=False)
	await ClockCycles(dut.tck, 1)

	# got back to idle
	set_cmd(dut,tms=False)
	await ClockCycles(dut.tck, 1)

# starting from idle, read the data register of length drl
async def read_dr(dut, drl, tdi_buffer=bytearray(0), bypass_read=False):
	ret = 0
   
	if (len(tdi_buffer) == 0):
	    tdi_buffer = bytearray(drl)

	# idle 
	set_cmd(dut,tms=True)
	await ClockCycles(dut.tck, 1)
   
	# dr select
	set_cmd(dut,tms=False)
	await ClockCycles(dut.tck, 1)
	 
	# capture dr
	set_cmd(dut,tms=False)
	await ClockCycles(dut.tck, 1)
	
	# shift dr
	for i in range(0, drl):
		set_cmd(dut,tms=(i == drl-1), tdi=(tdi_buffer[i] == 1))
		await ClockCycles(dut.tck, 1)
		if i : 
			tdo = dut.tdo.value
			if not(bypass_read):
				ret |= int(tdo) << i-1
	
	# exit 1r
	set_cmd(dut,tms=True)
	await ClockCycles(dut.tck, 1)
	
	tdo = dut.tdo.value
	if not(bypass_read):
		ret |= int(tdo) << drl-1
	
	# update dr
	set_cmd(dut,tms=False)
	await ClockCycles(dut.tck, 1)

	# got back to idle
	set_cmd(dut,tms=False)
	await ClockCycles(dut.tck, 1)

	return ret

# decode and pretty print idcode format 
# { version 4b, part_num 16b, manifacturer_id 11b, 1'b1 }
#
def decode_idcode(idcode):
	assert(idcode & 0x1)
	idcode = idcode >> 1
	manif = idcode & 0x7ff
	idcode = idcode >> 11
	part = idcode & 0xffff
	idcode = idcode >> 16
	v = idcode & 0xf
	return v, part, manif

def pretty_print_idcode(v, part, manif):
	cocotb.log.debug("idcode: { version %s, part num %s, manifacturer id %s}", hex(v), hex(part), hex(manif))

async def get_idcode(dut):
	await set_ir(dut, IDCODE, IR_L)
	cocotb.log.debug("start read dr")
	idcode = await read_dr(dut, 32)
	v, p, m = decode_idcode(idcode)
	pretty_print_idcode(v,p,m)
	return v,p, m

async def test_bypass(dut):
	await set_ir(dut, BYPASS)

	# go to shift dr mode
	
	# idle 
	set_cmd(dut,tms=True)
	await ClockCycles(dut.tck, 1)
   
	# dr select
	set_cmd(dut,tms=False)
	await ClockCycles(dut.tck, 1)
 
	# capture dr
	set_cmd(dut,tms=False)
	await ClockCycles(dut.tck, 1)
   
	# shift dr
	x = random.randint(2, 50)
	tdi_buffer = bytearray(0)
	tdo_buffer = bytearray(0)
	# write tdi in and tdo
	for i in range(0, x):
		tdi = random.randint(0,1)
		if i != x-1:
			tdi_buffer.append(tdi)
		set_cmd(dut,tms=(i == x-1), tdi=(tdi == 1))
		await ClockCycles(dut.tck, 1)
		if ( i > 1 ) :
			tdo = dut.tdo.value
			tdo_buffer.append(tdo)
   
	# exit 1r
	set_cmd(dut,tms=True)
	await ClockCycles(dut.tck, 1)
	tdo = dut.tdo.value
	tdo_buffer.append(tdo) 

	# check bypass results, input should match output
	cocotb.log.debug("tdi %s", tdi_buffer)
	cocotb.log.debug("tdo %s", tdo_buffer)
	assert(tdi_buffer == tdo_buffer) 
	 
	# update dr
	set_cmd(dut,tms=False)
	await ClockCycles(dut.tck, 1)

	# got back to idle
	set_cmd(dut,tms=False)
	await ClockCycles(dut.tck, 1)


def set_random_input_pin_data(dut):
	pin_i = bytearray(0)
	for i in range(0, PIN_IN_N):
	    x = random.randint(0,1)
	    pin_i.append(x)
	dut.data_v.value = pin_i[0]
	dut.data_mode.value = pin_i[2] << 1 | pin_i[1]
	dut.data.value = pin_i[10] < 7 | pin_i[9] << 6 | pin_i[8] << 5 |pin_i[7] << 4 |pin_i[6] << 3 | pin_i[5] << 2 | pin_i[4] << 1 | pin_i[3]
	pin_i.reverse()
	return pin_i 

def set_random_output_pin_data():
	pin_o = bytearray(0)
	for i in range(0, PIN_OUT_N):
		pin_o.append(random.randint(0,1))
	io_v = pin_o[8] << 7 
	o_v = pin_o[0] << 7 | pin_o[1] << 6 | pin_o[2] << 5 | pin_o[3] << 4 | pin_o[4] << 3 | pin_o[5] << 2 | pin_o[6] << 1 | pin_o[7]  
	pin_o = pin_o.ljust(BSC_LENGTH, b"\x00")
	return o_v, io_v, pin_o

async def test_bsc(dut, extest=True):
	# set ir
	if (extest):
		await set_ir(dut, EXTEST) 
	else:	
		await set_ir(dut, SAMPLE_PRELOAD) 

	# set random data to in
	dut.data.value = random.randint(0, 255) 

	 # idle 
	set_cmd(dut,tms=True)
	await ClockCycles(dut.tck, 1)
   
	# dr select
	set_cmd(dut,tms=False)
	await ClockCycles(dut.tck, 1)
 
	# capture dr - sample data on the external pins

	# set data on the input pins to a known state
	expected_bsc_in = set_random_input_pin_data(dut)
	set_cmd(dut,tms=False) 
	await ClockCycles(dut.tck, 1)
   
	uo_out, uio_out, tdi_buffer = set_random_output_pin_data()
	cocotb.log.info("tdi buffer %s %d %d", tdi_buffer, len(tdi_buffer), tdi_buffer[8])

	# shift dr, write expected output pin data over tdi
	# capture shifted out values writen over input pins over tdo
	tdo_buffer = bytearray(0)
	
	# write tdi in and tdo
	for i in range(0, BSC_LENGTH):
		set_cmd(dut,tms=(i == BSC_LENGTH-1), tdi=(tdi_buffer[i] == 1))
		cocotb.log.debug("tdi i %d %s", i, tdi_buffer[i])
		await ClockCycles(dut.tck, 1)
		tdo = dut.tdo.value
		if (i-1 > PIN_OUT_N-1):
			cocotb.log.info("tdo i %d %s", i, tdo)
			tdo_buffer.append(tdo)
	
	# exit 1r
	set_cmd(dut,tms=True)
	await ClockCycles(dut.tck, 1)
   
	tdo = dut.tdo.value
	tdo_buffer.append(tdo) 
	 
	# check captured bits values match inputs
	cocotb.log.info("expected %s",expected_bsc_in)
	cocotb.log.info("got	   %s",tdo_buffer)
	assert(expected_bsc_in == tdo_buffer)
 
	# update dr
	set_cmd(dut,tms=False)
	await ClockCycles(dut.tck, 1)

	# check output pin's are the same
	if not(extest):
		uio_out = dut.uio_out.value
		uo_out = dut.uo_out.value

	# got back to idle
	set_cmd(dut,tms=False)
	await ClockCycles(dut.tck, 1)
	
	# check output diven pins
	cocotb.log.debug("uio_out %s", uio_out)
	cocotb.log.debug("uo_out %s",  uo_out)
	assert(uo_out == dut.uo_out.value) 
	# mask out tdo, for sample preload values can be X
	if (extest):
	    assert(uio_out == (int(dut.uio_out.value) & 0xbf)) 
	else :
	    assert(uio_out[7] == dut.uio_out.value[7]) 


async def scan_user_reg(dut, unit_addr, reg_addr, first_user_reg_read=False):
	if first_user_reg_read:
	    await set_ir(dut, USER_REG)
	
	assert(unit_addr >= 0 and unit_addr <= 3)
	assert(reg_addr >= 0 and reg_addr <= 3)
	addr = unit_addr << 2 | reg_addr
	tdi_buffer = bytearray(USER_REG_W)
	for x in range(0, USER_REG_W):
	    tdi_buffer[x] |= addr >> x & 0x1
	assert(len(tdi_buffer) == USER_REG_W)
	
	user_reg =  await read_dr(dut, USER_REG_W, tdi_buffer, first_user_reg_read)
	
	return user_reg
	 
	 
