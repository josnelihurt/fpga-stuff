module counter_to_zero#(
    parameter N=8 // number of bits in counter
   )(
	input clk,
	input rst,
	input step,
	input [N-1:0] from,
	output done
);
reg  [N-1:0] counter_us;
wire [N-1:0] counter_us_next;
reg running_reg;

always @(posedge clk or posedge rst or posedge step or posedge done) begin
	if (rst) begin
		counter_us <= 0;
		running_reg <= 0;
	end
	else begin
		running_reg <= 1;
		if(done) begin
			running_reg <= 0;
		end
		if (step) begin
			counter_us <= from;
		end else begin
			counter_us <= counter_us_next;
		end
	end
end
assign counter_us_next = (running_reg) ? counter_us - 1 : 0;
assign done = counter_us == 0;

endmodule 

module hx8352_delay_us
(
	input  clk_1MHz,
	input  rst,
	input  step,
	input  [15:0] delay_us,
	output done
);
	reg  [15:0] counter_load_val;
	
	always @ (posedge clk_1MHz or posedge rst) 
	begin
		if(rst) begin
			counter_load_val <= 0;
		end else begin
			counter_load_val <= delay_us;
		end
	end
	
	wire step_sync;
	
	edge_detect 
		edge_detect_uut(
			.async_sig(step),
			.clk(clk_1MHz),
			.rise(step_sync),
			.fall()
			);	
	counter_to_zero #(.N(16)) counter_to_zero_u0(
		.clk(clk_1MHz),.rst(rst),.step(step_sync),
		.from(delay_us),
		.done(done)
	);
endmodule
