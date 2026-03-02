/* MAC data streamout 
 * Used to guaranty data is streamed to MCU 
 * gappless, this helps save on MCU <-> ASIC
 * handshaking logic and an extra pin. 
 * 
 * This does come at the cost of some extra 
 * result latency and logic. 
 */ 
module mac_streamout #(
	parameter W = 16,
	parameter OUT_W = 8,
	localparam N = 2 // currently designed for a 2x2 array
)(
	input wire clk, 

	// result from systolic array 
	input wire [2:0]       res_rd_seq_v_i,
	input wire [N*W-1:0]   res_data_i,

	// output IO interface
	output wire             valid_o,
	output wire [OUT_W-1:0] data_o

);
localparam NN = N*N;
reg [W-1:0] gather_q[NN];

always @(posedge clk) begin
	if(res_rd_seq_v_i[0])
		gather_q[0] <= res_data_i[W-1:0]; 
	if (res_rd_seq_v_i[1])
		{gather_q[1], gather_q[2]} <= res_data_i;
	if (res_rd_seq_v_i[2])
		gather_q[3] <= res_data_i[N*W-1:W]; 
end

// streamout result
localparam MAX_IDX = ((NN)*(W/OUT_W)) + 1; 
localparam IDX_W   = $clog2(MAX_IDX);
localparam [IDX_W-1:0] RST_IDX = MAX_IDX;

reg [NN*W-1:0]   stream_q;
wire             mv_gather_to_stream_next;
reg              mv_gather_to_stream_q;
reg  [IDX_W-1:0] stream_idx_q;
wire [IDX_W-1:0] stream_idx_next;
wire             stream_idx_underflow;
wire [IDX_W-1:0] stream_idx_sub1;

assign mv_gather_to_stream_next = res_rd_seq_v_i[2]; 
always @(posedge clk) 
	mv_gather_to_stream_q <= mv_gather_to_stream_next;

assign {stream_idx_underflow, stream_idx_sub1} = stream_idx_q - {{IDX_W-1{1'b0}},1'd1};
assign stream_idx_next = stream_idx_underflow ? {IDX_W{1'd0}} : stream_idx_sub1;
always @(posedge clk) begin 
	if (mv_gather_to_stream_q) begin
		stream_q <= {gather_q[3], gather_q[2], gather_q[1], gather_q[0]};
		stream_idx_q <= RST_IDX;
	end else begin
		stream_q <= {{OUT_W{1'bX}}, stream_q[NN*W-1:OUT_W]};
		stream_idx_q <= stream_idx_next;
	end
end

// TODO: add option to reduce output switching freq / 2 ? 

// add extra ff layer to help improve increase positive
// slack on output valid path, need as much as we can if we
// want to push output GPIO Fmax
reg out_valid_q; 
always @(posedge clk)
	out_valid_q <= mv_gather_to_stream_q | |stream_idx_next; // valid is asserted a cycle before data start being sent 

// output 
assign valid_o = out_valid_q;
assign data_o  = stream_q[OUT_W-1:0]; 

`ifdef FORMAL
	sva_idx_onehot0: assert($onehot0(res_rd_seq_v_i));
`endif
endmodule
