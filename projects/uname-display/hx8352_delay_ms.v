module hx8352_delay_ms
(
	input  clk,
	input  rst,
	input  step,
	input  [7:0] delay_ms,
	output done
);
	wire base_tick;
	reg  done_reg;
	wire step_sync;
	reg  [7:0] counter_ms;
	
	reg   step_reg;
	always @ (posedge clk or posedge rst) 
	begin
		if(rst)
			step_reg <= 0;
		else
			step_reg <= step;
	end
	assign step_sync = step & ~step_reg;
	
	`ifdef SIMULATION
		localparam RESET_COUTER_VALUE = 100;
	`else
		localparam RESET_COUTER_VALUE = 500_000;
	`endif
	
	counter	#(    .N(24),
				  .M(RESET_COUTER_VALUE)
			)
		counter_base_unit 
	   (
		.clk(clk), .reset(done_reg | rst),
		.max_tick(base_tick),
		.q()
	   );
   always @(posedge base_tick or posedge step_sync or posedge rst)
    begin
		if (rst) begin
			done_reg <= 1;
			counter_ms <= 0;
		end
        else if (step_sync) begin
			done_reg <= 0;
			counter_ms <= 0;
        end
        else begin
			if(counter_ms < delay_ms) begin
				counter_ms <= counter_ms + 1;
				done_reg <= 0;
			end else begin
				counter_ms <= counter_ms;
				done_reg <= 1;
			end
        end
    end
    
	assign done = done_reg;
endmodule
