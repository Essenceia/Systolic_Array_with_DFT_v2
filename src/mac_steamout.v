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
	localparam N = 2 // currently designed for a 2x2 array
)(
	input wire clk, 
	input wire rst_n, 

	// result from systolic array 
	input wire [N-1:0]     res_valid_i,
	input wire [2:0]       res_idx_i,
	input wire [N*W-1:0]   res_data_i,

	// output IO interface
	output wire            valid_o,
	output wire [W-1:0]    data_o

);
localparam NN = N*N;
localparam IDX_W = $clog2(2*2)

reg [W-1:0] gather_q[NN];

always @(posedge clk) begin
	if(res_valid_i) begin
		if(res_idx_i[0])
			gather_q[0] <= res_data_i[W-1:0]; 
		if (res_idx_i[1])
			{gather_q[1], gather_q[2]} <= res_data_i;
		if (res_idx_i[2])
			gather_q[3] <= res_data_i[N*W-1:W]; 
	end
end

// streamout result
reg [W-1:0] stream_q[NN];

wire            start_stream_next; 
reg             stream_valid_q;
reg [IDX_W-1:0] stream_idx_q; 

assign start_stream_next = res_idx_i[2] & res_valid_i; 

// TODO 

// output 
assign valid_o = start_stream_next | stream_valid_q;
assign data_o  = stream_q[W-1:0]; 

endmodule
