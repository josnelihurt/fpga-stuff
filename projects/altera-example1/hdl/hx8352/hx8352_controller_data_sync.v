module hx8352_controller_data_sync(
	input  clk,
	input  rst,
	input  [7:0]  cmd_in,
	input  [15:0] data_in, 
	output reg [7:0] cmd_in_sync,
	output reg [15:0] data_in_sync
);
	
always @(posedge clk or posedge rst) begin
	if(rst) begin
		cmd_in_sync <= 0;
		data_in_sync <= 0;
	end else begin
		cmd_in_sync <= cmd_in;
		data_in_sync <= data_in;
	end
end
endmodule 
