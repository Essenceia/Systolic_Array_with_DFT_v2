/* MAC data streamin 
 * maps GPIO io onto systollic array input 
 */
module mac_streamin #(
	parameter IN_W = 8,
	parameter W = 16, 
	localparam N = 2
)(
	input wire clk, 
	
	// GPIO interface
	input wire            data_valid_i,
	input wire [IN_W-1:0] data_i,

	// FSM interface
	input wire [N-1:0]    data_idx_onehot_i,

	// to systolic array 
	output wire [N*W-1:0]  data_o
);
reg [N*W-1:0] buf_q;

// would rather have a pre-compiler to generate this code
always @(posedge clk) begin
	if (data_valid_i & data_idx_onehot_i[0])
		buf_q[W-1:0] <= {data_i, buf_q[W-1:IN_W]};
	if (data_valid_i & data_idx_onehot_i[1])
		buf_q[2*W-1:W] <= {data_i, buf_q[2*W-1:IN_W+W]};
end

assign data_o = buf_q; 
endmodule
