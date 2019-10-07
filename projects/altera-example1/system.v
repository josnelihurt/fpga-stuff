
module system(
	input clk_50M,
	input key0,
	//input key1,
	output led,
	output [7:0]display_7seg_bus,
	output [2:0]display_7seg_anodes,
	output [15:0]probe_bus,
	output [1:0] probe_bus2,
	// tm1638 board
	output tm1638_clk,
	inout tm1638_data_io,
	output tm1638_strobe,
	//lcd board
	output 	[15:0]hx8352_data,
	output 	hx8352_rs,
	output 	hx8352_wr,
	output 	hx8352_rd,
	output 	hx8352_cs,
	output 	hx8352_rst
	);
	wire rst = ~key0;
	wire clk_200M;
	wire clk_10M;
	wire clk_5M;
	wire clk_1M;
	wire clk_1H;
	
	clock_divider clk_divider_0(.clk_50M(clk_50M), .rst(rst), .clk_out(clk_1H));
	
	`ifdef SIMULATION
		
	`else
        PLL pll_unit0(
		        .areset(rst),
		        .inclk0(clk_50M),
		        .c0(clk_200M),
		        .c1(clk_10M),
		        .c2(clk_5M),
		        .c3(clk_1M),
		        .locked()
	        );
	`endif
	
	wire[31:0] nios_pio_0, nios_pio_lcd;
	nios_core nios_core_u0(
		.clk_clk(clk_50M),       //   clk.clk
		.reset_reset_n(1'b1),  // reset.reset_n
		.pio_0_external_connection_export(nios_pio_0),
		.pio_lcd_control_external_connection_export(nios_pio_lcd)
	);
	
	
	wire [31:0]hx8352_dbg;
	wire[31:0] counter_1s;
	counter #(.N(32),.M(1024))
		counter_base_unit1
	   (
		.clk(clk_1H), .reset(rst),
		.max_tick(),
		.q(counter_1s)
	   );	
	
	wire hx8352_init_done;
	wire hx8352_busy;	
	wire hx8352_step;
	wire [3:0] hx8352_cmd_in;
	wire [15:0] hx8352_data_in;
	
	assign hx8352_step	=nios_pio_lcd[31];
	assign hx8352_cmd_in	=nios_pio_lcd[19:16];
	assign hx8352_data_in=nios_pio_lcd[15:0];
	
	hx8352_controller
		hx8352_u0
		(
		.clk(clk_50M), .rst(rst),
		.step(hx8352_step),.data_in(hx8352_data_in),.cmd_in(hx8352_cmd_in),	
		.busy(hx8352_busy),
		.lcd_rs(hx8352_rs),
		.lcd_wr(hx8352_wr),
		.lcd_rd(hx8352_rd),
		.lcd_rst(hx8352_rst),
		.lcd_cs(hx8352_cs),
		.data_bus(hx8352_data[15:0]),
		.debug_instruction_step(hx8352_dbg),
		.init_done(hx8352_init_done)
		);
	seven_segments_handler 
		seven_segments_handler_unit0
		(
		.clk_1MHz(clk_1M),
		.rst(rst),
		.input_hex(hx8352_dbg[27:16]),
		.dots(3'b000),
		.display_7seg_anodes(display_7seg_anodes),
		.display_7seg_bus(display_7seg_bus)
		);
	wire[7:0] tm1638_keys;
	tm1638_keys_display_encoded
		tm1638_keys_display_encoded_unit0
		(
		.clk_1MHz(clk_1M),
		.rst(rst),
		.display_off(1'b0),
		.display_level(3'b100),
		.display_value(nios_pio_0),//{debug_instruction_step, hx8352_data}),
		.dots(8'h00),
		.leds_green({ hx8352_cs, hx8352_rst, hx8352_rs, hx8352_wr, hx8352_rd, clk_1H, counter_1s[1], counter_1s[0]}),
		.leds_red(8'h00),
		.keys(tm1638_keys),
		
		.tm1638_strobe(tm1638_strobe),
		.tm1638_clk(tm1638_clk),
		.tm1638_data_io(tm1638_data_io)
		);
	hardware hardware_u0();
	assign led = clk_1H;
	assign probe_bus[15:0] = {hx8352_dbg[15:0]};
	assign probe_bus2[0] = clk_1H;
	assign probe_bus2[1] = clk_1H;
endmodule
