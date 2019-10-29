module hx8352_reset_generator
(
	input  clk,
	input  rst,
	output lcd_rst,
	output lcd_rst_done
);
	wire reset_tick;
	
	`ifdef SIMULATION
		localparam RESET_COUTER_VALUE = 250;
	`else
		localparam RESET_COUTER_VALUE = 250_000;
	`endif
	
	
	counter	#(    .N(24),
				  .M(RESET_COUTER_VALUE)
			)
		counter_reset_generator_unit 
	   (
		.clk(clk), .reset(rst),
		.max_tick(reset_tick),
		.q()
	   );
   reg lcd_rst_reg;
   reg lcd_rst_done_reg;
   reg [3:0] lcd_init_counter;
   always @(posedge reset_tick or posedge rst)
    begin
        if (rst) begin
            lcd_rst_reg <= 0;            
            lcd_init_counter <= 0;
            lcd_rst_done_reg <= 0;
        end
        else begin
			if(lcd_init_counter < 3) begin
				lcd_rst_reg <= ~lcd_rst_reg;
				lcd_init_counter <= lcd_init_counter + 1;	
				lcd_rst_done_reg <= 0;
			end
			else begin 
				lcd_rst_reg <= lcd_rst_reg;
				lcd_init_counter <= lcd_init_counter;
				lcd_rst_done_reg <= 1;
			end
        end
    end
    
	assign lcd_rst = lcd_rst_reg;
	assign lcd_rst_done = lcd_rst_done_reg;
endmodule
