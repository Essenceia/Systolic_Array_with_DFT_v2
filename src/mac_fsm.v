/* 
 * Multiply accumulate systolic array top of size NxN FSM
 * 
 * Orchastrates the MAC behavior
 *
 * This code will be simplified by synth, maximizing readability
 * 
 * Julia Desmazes, 2026, this code is human made
 */

`timescale 1ns / 1ps

module mac_fsm #(
	parameter IO_W = 8,
	parameter W = 16,
	localparam N = 2,
	localparam NN = N*N
)(
	input wire clk, 
	input wire rst_n, 
	input wire ena,

	input wire       data_v_i, 
	input wire [1:0] data_mode_i, 

	output wire [NN-1:0] wr_weight_v_o,
	output wire [N-1:0]  wr_data_v_o,

	output wire mac_step_o, // cam step through 

	output wire [N-1:0] res_rd_o,
	output wire [N-1:0] res_wr_o // output streaming

);
/* data modes */
localparam MODE_DATA   = 2'd0;
localparam MODE_WEIGHT = 2'd1;
localparam MODE_RST    = 2'd2;
localparam MODE_ASM    = 2'd3;

localparam MAX_UNIT_IDX = NN;
localparam UNIT_IDX_W   = $clog2(MAX_UNIT_IDX);  
localparam DATA_IDX_W   = $clog2(MAX_UNIT_IDX*(W/IO_W));

/* rst all write addr */
wire rst_addr; 
assign rst_addr = data_v_i & (data_mode_i == MODE_RST);

/* weight write logic */
wire               wr_weight_v;
reg [DATA_IDX-1:0] wr_weight_idx_q;
reg                wr_weight_idx_carry_unused;
reg [NN-1:0]       wr_weight_unit_v;

assign wr_weight_v = data_v_i & (data_mode_i == MODE_WEIGHT);
always @(posedge clk) 
	if (~rst_n |  rst_addr ) wr_weight_idx_q <= {DATA_IDX_W{1'b0}};
	else if (wr_weight_v) {wr_weight_idx_carry_unused, wr_weight_idx_q} <= wr_weight_idx_q + {{DATA_IDX_W-1{1'b0}}, 1'b1};

always @(*) begin
	case(wr_weight_idx_q[DATA_IDX_W-:UNIT_IDX_W])
		2'd0: wr_weight_unit_v <= 4'b0001;
		2'd1: wr_weight_unit_v <= 4'b0010;
		2'd2: wr_weight_unit_v <= 4'b0100;
		2'd3: wr_weight_unit_v <= 4'b1000;
	endcase
end

assign wr_weight_v_o = {NN{wr_weight_v}} & wr_weight_unit_v;

/* data write logic
 *
 * Control storage located in the streamin module. 
 * Capture incoming data over 8 bit wide bus and feed it to the
 * systolic array. */
wire                  wr_data_v;
reg  [DATA_IDX_W-1:0] wr_data_idx_q;
reg                   wr_data_idx_carry_unused;
reg  [N-1:0]          wr_data_row_v;

assign wr_data_v = data_v_i & (data_mode_i == MODE_DATA);

always @(posedge clk) 
	if (~rst_n | rst_addr ) wr_data_idx_q <= {DATA_IDX_W{1'b0}};
	else if (wr_data_v) {wr_data_idx_carry_unused, wr_data_idx_q} <= wr_data_idx_q + {{DATA_IDX_W-1{1'b0}}, 1'b1};

always @(*) begin
	case(wr_data_idx_q[DATA_IDX_W-:UNIT_IDX_W])
		2'd0: wr_data_row_v <= 2'b01;
		2'd1: wr_data_row_v <= 2'b01;
		2'd2: wr_data_row_v <= 2'b10;
		2'd3: wr_data_row_v <= 2'b10;
	endcase
end

assign wr_data_v_o = {N{wr_data_v}} & wr_data_row_v;

/* N dimention dependant logic 
 *
 * MAC steps, depend on data arrival sequence */
reg last_step_q;
reg mac_step_q;
reg en_q;
always @(posedge clk) 
	en_q <= ena;

always @(posedge clk) 
	last_step_q <= wr_data_v & en_q & (wr_data_idx_q == {2'd3, 1'b1}); 

always @(posedge clk) begin
	if (en_q & wr_data_v)  begin
		case(wr_data_idx_q) 
			{2'd0,1'b1}:  mac_step_q <= 1'b1;// 0,0 
			{2'd2,1'b1}:  mac_step_q <= 1'b1;//1,0 + 0,1
			{2'd3,1'b1}:  mac_step_q <= 1'b1;//1,1 + last_step next cycle
			default: mac_step_q <= last_step_q;
		endcase
	end
end
assign mac_step_o = mac_step_q;

/* Streamout sequencer 
 * Depends on data arrival + mac step though */ 

endmodule
