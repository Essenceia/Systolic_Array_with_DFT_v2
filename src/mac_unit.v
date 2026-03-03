/* 
 * Multiply accumulate systolic array unit
 * 
 * Julia Desmazes, 2025, this code is human made
 */

`timescale 1ns / 1ps
`default_nettype none 

module mac_unit #(
	parameter W = 8,
	parameter IO_W = 8 // weight use IO_W for input and are shifted in
	)(
	input wire clk, 

	input wire           step_i, 
	
	input wire [W-1:0]   data_i, //right side input data
	input wire [W-1:0]   data_top_i, // top input data

	input wire            wr_weight_v_i,	
	input wire [IO_W-1:0] weight_i, 

	input wire  [1:0]    jtag_ureg_addr_i, 
	output logic [W-1:0] jtag_ureg_data_o, 

	output wire [W-1:0]  data_o, // left side output data, will become the right side input data of the next unit leftwards
	output wire [W-1:0]  res_o // result, become the top input data for the next unit bellow
); 
reg  [W-1:0] data_q, add_q;
reg  [W-1:0] weight_q;
wire [W-1:0] mul;

always @(posedge clk) 
	if (step_i) data_q <= data_i;

always @(posedge clk) 
	if (step_i) add_q <= data_top_i; // critical path end 

always @(posedge clk) 
	if (wr_weight_v_i) weight_q <= {weight_i, weight_q[W-1:IO_W]};

`ifdef COCOTB
/* Replacing floating point model with unsigned integer math 
 * for cocotb since we don't have a good golden model 
 * in python for bf16, bf16 implementations used a clamped down
 * version of f32 which would result in the accumulation of 
 * the different precision rounding error though the network.
 * Additionally, float math has already been thoughly verified, 
 * this testbench is focused on checking the array's behavior
 * and this is indifrent to the underlying base type as long as 
 * the data width is identical. */
wire [W-1:0] mul_raw_carry, mul_raw; 
assign {mul_raw_carry, mul_raw} = weight_q * data_q; 
// clamping
assign mul = |mul_raw_carry ? {W{1'b1}} : mul_raw; 

wire add_raw_carry; 
wire [W-1:0] add_raw; 
assign {add_raw_carry, add_raw} = mul + add_q;
assign res_o = add_raw_carry ? {W{1'b1}}: add_raw; 
`else
// bfloat16 multiplication 
bf16_mul m_mul(
	.sa_i(weight_q[15]),
	.ea_i(weight_q[14:7]),
	.ma_i(weight_q[6:0]),

	.sb_i(data_q[15]),
	.eb_i(data_q[14:7]),
	.mb_i(data_q[6:0]),

	.s_o(mul[15]),
	.e_o(mul[14:7]),
	.m_o(mul[6:0])	
);

// bfloat16 addition 
bf16_add m_add(
	.sa_i(mul[15]),
	.ea_i(mul[14:7]),
	.ma_i(mul[6:0]),

	.sb_i(add_q[15]),
	.eb_i(add_q[14:7]),
	.mb_i(add_q[6:0]),

	.s_o(res_o[15]),
	.e_o(res_o[14:7]),
	.m_o(res_o[6:0])
);
`endif

assign data_o = data_q;

// jtag user register interface, expected to be used when mac clock is stalled
always @(*) begin
	case(jtag_ureg_addr_i) 
		2'b00: jtag_ureg_data_o = weight_q; 
		2'b01: jtag_ureg_data_o = data_q; 
		2'b10: jtag_ureg_data_o = add_q; 
		2'b11: jtag_ureg_data_o = mul;
	endcase 
end
endmodule
