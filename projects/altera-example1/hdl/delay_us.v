module delay_us
(
	input  clk_1MHz,
	input  rst,
	input  step,
	input  [15:0] delay_us,
	output busy,
	output done
);
	reg  [15:0] counter_load_val;
	reg   transfer_step_reg;
	always @ (posedge clk_1MHz, posedge rst) 
	begin
		if(rst)
			transfer_step_reg <= 0;
		else
			transfer_step_reg <= step;
	end
	wire transfer_step_sync;
	assign transfer_step_sync = step & ~transfer_step_reg;
	
	always @ (posedge clk_1MHz or posedge rst) 
	begin
		if(rst) begin
			counter_load_val <= 16'hffff;
		end else begin
			counter_load_val <= counter_load_val;
			if(step)
				counter_load_val <= delay_us;
		end
	end
	
	single_shot_counter #(.N(16)) cnt_ut0(
		.clk(clk_1MHz),.rst(rst),.step(transfer_step_sync),
		.til(counter_load_val),
		.running(busy),
		.done(done)
	);
endmodule
