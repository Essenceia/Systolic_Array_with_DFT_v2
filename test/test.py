# Cocotb testbench for testing the MAC and JTAG functions of this ASIC design
#
# Julia Desmazes, 2026, human made code


import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, ClockCycles, with_timeout

import random 
import mac_utils
import jtag_utils
import asyncio
from array import array 

import os
GATES = os.environ["GATES"].lower().strip()

CLK_UNIT="us"
CLK_PERIOD=10
TCK_UNIT=CLK_UNIT 
TCK_PERIOD=77
CLK_TIMEOUT_PERIOD=(CLK_PERIOD*1000)

SC_CLK_DELAY=2

def start_clk(dut):
	clock = Clock(dut.clk, CLK_PERIOD, CLK_UNIT)
	clk_task = cocotb.start_soon(clock.start()) #runs the clock "in the background" 
	return clk_task

def start_jtag_clk(dut):
	jtag_clk = Clock(dut.tck, TCK_PERIOD, TCK_UNIT)
	cocotb.start_soon(jtag_clk.start())

# Reset sequence
async def rst(dut, ena=1, start_jtag=False, start_main_clk=True):
	dut.rst_n.value = 1
	dut.tck.value = 0
	dut.tms.value = "X"
	dut.tdi.value = "X"
	clk_task = start_clk(dut)
	if start_jtag:
		dut.tms.value = 0
		dut.tdi.value = 0
		start_jtag_clk(dut)
	await ClockCycles(dut.clk, 2)
	dut.rst_n.value = 0
	await ClockCycles(dut.clk, 2)
	# set default io
	dut.data_v.value = 0
	dut.data.value = "X"*8
	dut.data_mode.value = "X"*2
	dut.ena.value = 0
	await ClockCycles(dut.clk, 10)
	dut.rst_n.value = 1
	dut.ena.value = ena
	await ClockCycles(dut.clk,10)
	if not(start_main_clk): 
		assert(clk_task.cancel())

async def read_res(dut):
	res = array('B')
	ret = array('H')#return type, convert byte to uint16
	   
	while (len(res) != mac_utils.RES_SIZE):
		if (dut.result_v.value == 1):
			x = dut.uo_out.value
			res.append(x)
		await ClockCycles(dut.clk, 1)
	ret.frombytes(res)
	return ret

async def compare_res(dut, W, I):
	expected = mac_utils.mac(W,I)

	try:
		res = await with_timeout(read_res(dut), CLK_TIMEOUT_PERIOD, CLK_UNIT) 
	except TimeoutError:
		cocotb.log.error("Result returned has stalled for read_res")
	
	cocotb.log.debug("expected vs got :")
	cocotb.log.debug(' '.join(map(str, expected)))
	cocotb.log.debug(' '.join(map(str, res)))
	assert(res == expected) 

# MAC tests 

@cocotb.test(expect_error=AssertionError if GATES == "yes" else ())
async def simple_mac_test(dut):
	await rst(dut) 
	W = array('H', [0, 1, 2, 3]) 
	I = array('H', [4, 5, 6, 7])

	await mac_utils.rst_data_addr(dut)

	# send weights 
	await mac_utils.write_config(dut, W, weight=True)

	# res can start comming in before all the data has been finished being written 
	comp_task = cocotb.start_soon(compare_res(dut, W, I))
		
	# send data
	write_task = cocotb.start_soon(mac_utils.write_config(dut, I , weight=False))
   
	await write_task
	await comp_task 
		
	await ClockCycles(dut.clk, 10)

@cocotb.test(expect_error=AssertionError if GATES == "yes" else ())
async def random_mac_test(dut):
	await rst(dut)
	await mac_utils.rst_data_addr(dut)
	for _ in range(0, 500): 
		W = array('H')
		I = array('H')
		for _ in range(0,4):
			W.append(mac_utils.biased_random(mac_utils.MIN_VAL,mac_utils.MAX_VAL))
			I.append(mac_utils.biased_random(mac_utils.MIN_VAL,mac_utils.MAX_VAL))


		# send weights 
		await mac_utils.write_config(dut, W, weight=True)
	
		# check result - results can start streaming before all the 
		# data has been written 
		comp_task = cocotb.start_soon(compare_res(dut, W, I))
		
		# send data
		write_task = cocotb.start_soon(mac_utils.write_config(dut, I , weight=False))
   
		await write_task
		await comp_task 

@cocotb.test(expect_error=AssertionError if GATES == "yes" else ())
async def random_mac_reuse_weights_test(dut):
	await rst(dut)
	await mac_utils.rst_data_addr(dut)
	for _ in range(0, 20): 
		W = array('H')
		for _ in range(0,4):
			W.append(mac_utils.biased_random(mac_utils.MIN_VAL,mac_utils.MAX_VAL))
		await mac_utils.write_config(dut, W, weight=True)

		for _ in range(0, 50): 
			I = array('H')
			for _ in range(0,4):
				I.append(mac_utils.biased_random(mac_utils.MIN_VAL,mac_utils.MAX_VAL))
	
			# check result - results can start streaming before all the 
			# data has been written 
			comp_task = cocotb.start_soon(compare_res(dut, W, I))
			# write data
			write_task = cocotb.start_soon(mac_utils.write_config(dut, I , weight=False))
   
			await write_task
			await comp_task 


# JTAG tests
# read out idcode 
async def jtag_read_idcode(dut):
	v, p, m = await jtag_utils.get_idcode(dut)
	assert(v == 2)
	assert(p == 0xbeef) 
	assert(m == 0x6b)

# test bypass mode ( required by spec ) 
async def jtag_test_bypass(dut):
	await jtag_utils.test_bypass(dut)

# test extest: bounday scan :) ( required by spec ) 
async def jtag_extest(dut):
	return 0
	#await jtag_utils.test_bsc(dut, extest=True)

# test sample preload: bounday scan :) ( also required by spec ) 
async def jtag_sample_preload(dut):
	return 0
	#await jtag_utils.test_bsc(dut, extest=False)

@cocotb.test()
async def jtag_simple_test(dut):
	await rst(dut, start_jtag=True)
	await jtag_utils.rst_jtag_tap(dut)
	await jtag_test_bypass(dut) # jtag ir is set to idcode by default, start with bypass test to increase verification coverage
	await jtag_read_idcode(dut)
	await jtag_extest(dut)
	await jtag_sample_preload(dut)

@cocotb.test()
async def jtag_random_test(dut):
	await rst(dut, start_jtag=True)
	await jtag_utils.rst_jtag_tap(dut)
	for _ in range(0, 100):
		ir = random.randint(0,3)
		match ir: 
			case 0:
				await jtag_test_bypass(dut) # jtag ir is set to idcode by default, start with bypass test to increase verification coverage
			case 1:
				await jtag_read_idcode(dut)
			case 2:
				await jtag_extest(dut)
			case 3:
				await jtag_sample_preload(dut)


@cocotb.test()
async def jtag_user_reg_test(dut):
	await rst(dut, start_jtag=True)
	await jtag_utils.rst_jtag_tap(dut)

	for _ in range(0, 20):
		W = array('H')
		I = array('H')
		for _ in range(0,4):
			W.append(mac_utils.biased_random(mac_utils.MIN_VAL,mac_utils.MAX_VAL))
			I.append(mac_utils.biased_random(mac_utils.MIN_VAL,mac_utils.MAX_VAL))

		# send weights 
		await mac_utils.write_config(dut, W, weight=True)
	   
		for _ in range(0, 10): 
			first = True
			unit_next = random.randint(0,3)
			 
			read_reg = await jtag_utils.scan_user_reg(dut, unit_next , 0, first)
			if not(first):
				cocotb.log.debug("read reg %s / %s", read_reg, W[0])
				assert(read_reg == W[unit])

			unit = unit_next
			first = False


@cocotb.test()
async def jtag_scan_chain_test(dut):
	await rst(dut, start_jtag=True, start_main_clk=False)
	await jtag_utils.rst_jtag_tap(dut)
	assert(SC_CLK_DELAY/2 < TCK_PERIOD)
	# read scan chain length from design localparam, will depend on verilog define and if we are using the mock scan chain
	# present without the gate level simulation
	sc_length = dut.DUT_SC_LENGTH.value.to_unsigned()
	await jtag_utils.test_scan_chain(dut,sc_length,  dut.clk, SC_CLK_DELAY, CLK_UNIT)
	cocotb.log.info(cocotb.argv)
	cocotb.log.info(GATES)
