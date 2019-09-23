
module clock_divider(clk_50M, rst, clk_out);
input clk_50M;
input rst;
output clk_out;
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
assign clk_out = (counter<DIVISOR/2)?1'b0:1'b1;
endmodule 