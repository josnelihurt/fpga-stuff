module single_shot_counter#(
    parameter N=8 // number of bits in counter
   )(
	input clk,
	input rst,
	input step,
	input [N-1:0] til,
	output running,
	output done
);
reg  [N-1:0] counter_us;
reg [N-1:0] counter_us_next;

reg enable;
always @(posedge clk or posedge rst) begin
	if (rst) begin
		enable <= 0;
	end
	else begin
		enable <= enable;
		if(done) begin
			enable <= 1'b0;
		end
		
		if(step) begin
			enable <= 1'b1;
		end
		
	end
end
always @(posedge clk or posedge rst) begin
	if (rst) begin
		counter_us <= 0;
	end
	else begin
		counter_us <= counter_us_next;
	end
end

always @(*) begin
	if(step & !enable) begin
		counter_us_next = 0;
	end else begin
		if(enable)
			counter_us_next = counter_us + 1'b1;
		else
			counter_us_next = 0;
	end
end

//assign counter_us_next = (step & !enable) ? 1'b0 : counter_us + 1'b1;
assign done = (counter_us == til) && enable;
assign running = enable;

endmodule 