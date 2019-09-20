module hx8352_delay_us
(
	input  clk_1MHz,
	input  rst,
	input  step,
	input  [15:0] delay_us,
	output reg done
);
	reg  [15:0] counter_us;
	reg  [15:0] counter_load_val;
	
	reg   step_sync_reg;
	always @ (posedge clk_1MHz or posedge rst) 
	begin
		if(rst) begin
			step_sync_reg <= 0;
			counter_load_val <= 0;
		end else begin
			step_sync_reg <= step;
			counter_load_val <= delay_us;
		end
	end
	wire step_sync;
	assign step_sync = step & ~step_sync_reg;
	
   always @(posedge clk_1MHz or posedge step_sync or posedge rst)
    begin
		if (rst) begin
			done <= 1;
			counter_us <= 0;
		end
		else if (step_sync) begin
			done <= 0;
			counter_us <= counter_load_val;
		end 
		if(counter_us > 0) begin
			counter_us <= counter_us - 1;
			done <= 0;
		end else begin
			done <= 1;
		end
    end
endmodule
