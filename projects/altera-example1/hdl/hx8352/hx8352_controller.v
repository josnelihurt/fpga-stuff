
//lcd_rd => lcd read enable
//lcd_wr => lcd read 0, write 1
module hx8352_controller
(
	input  clk,
	input  clk_1MHz,
	input  rst,
	input  [7:0] cmd_in,
	input  [15:0] data_in,	
	output busy,
	output [15:0] data_output,
	output lcd_rs,
	output lcd_wr,
	output lcd_rd,
	output lcd_rst,
	output lcd_cs,
	output init_done,
	output [31:0]debug_instruction_step
);		
	wire  [15:0] data_in_reg;
	// Data Synchronization
	hx8352_controller_data_sync 
	data_sync_ut0(
	.clk(clk),.rst(rst),
	.cmd_in(),.data_in(data_in), 
	.cmd_in_sync(),.data_in_sync(data_in_reg)
	);
	
	wire  lcd_rst_done;     
	hx8352_reset_generator
		hx8352_reset_generator_unit(
			.clk(clk),
			.rst(rst),
			.lcd_rst(lcd_rst),
			.lcd_rst_done(lcd_rst_done)
		);
	
	// Bus
	wire command_or_data;
	wire [15:0]data_to_write;
	wire bus_controller_step;
	wire bus_busy;
	hx8352_bus_controller 
		hx8352_bus_u0
		(
			.clk(clk),
			.rst(~lcd_rst_done),
			.data_input(data_to_write),
			.data_command(command_or_data),
			.transfer_step(bus_controller_step),
			.busy(bus_busy),
			.data_output(data_output),
			.lcd_rs(lcd_rs),
			.lcd_wr(lcd_wr),
			.lcd_rd(lcd_rd)
		);
	// Delay
	wire [15:0] delay_value;
	wire delay_step;
	wire delay_done;
	wire delay_busy;
    delay_us
	   delay_u0
	   (.clk_1MHz(clk_1MHz),.rst(rst),
		.step(delay_step),.delay_us(delay_value),
		.busy(delay_busy),.done(delay_done)
	   );
	// Enabler
	wire fsm_clk;
	hx8352_controller_fsm_enabler 
		enabler_u0(.clk(clk),.rst(rst),
		.lcd_rst_done(lcd_rst_done),.bus_busy(bus_busy),.delay_busy(delay_busy),.delay_done(delay_done),
		.clk_enabled(fsm_clk));
	// Fsm
	wire fsm_rst ;
   assign fsm_rst = rst | ~lcd_rst_done;
	hx8352_controller_fsm 
		fsm_u0(
		.clk(fsm_clk),.rst(fsm_rst),
		.init_done(init_done),
		.data_to_write(data_to_write),
		.command_or_data(command_or_data),
		.bus_step(bus_controller_step),
		.delay_value(delay_value),
		.delay_step(delay_step),
		.lcd_cs(lcd_cs)
		);
		
	assign busy = bus_busy | ~lcd_rst_done | bus_busy | delay_busy; 
	assign debug_instruction_step = { data_to_write[7:0],
												lcd_wr,busy,lcd_rs,lcd_rd,
												lcd_cs,lcd_rst,command_or_data,fsm_clk};
endmodule
