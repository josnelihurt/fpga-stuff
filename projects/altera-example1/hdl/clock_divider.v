
module clock_divider(clk_50M, rst, clk_out);
input clk_50M;
input rst;
output reg clk_out;
reg[27:0] counter=28'd0;
parameter DIVISOR = 28'd50_000_000;
always @(posedge clk_50M, posedge rst)
begin
	if(rst) begin
		counter <= 28'd0;
	end
	else
	begin
		counter <= counter + 28'd1;
		if(counter>=(DIVISOR-1))
		begin
			counter <= 28'd0;
		end
	end
end
wire clk_out_next;
assign clk_out_next = (counter<DIVISOR/2)?1'b0:1'b1;
always @(posedge clk_50M, posedge rst) begin
	if(rst) begin
		clk_out <= 1'b0;
	end else begin
		clk_out <= clk_out_next;
	end
end
endmodule 