
//lcd_rd => lcd read enable
//lcd_wr => lcd read 0, write 1
module hx8352_controller
(
	input  clk,
	input  rst,
	input  [7:0] cmd_in,
	input  cmd_step,
	input  [15:0] data_in,	
	input  data_step,
	output busy,
	output [15:0] data_bus,
	output lcd_rs,
	output lcd_wr,
	output lcd_rd,
	output lcd_rst,
	output lcd_cs,
	output init_done,
	output [31:0]debug_instruction_step
);		
	wire data_step_sync, cmd_step_sync;
	edge_detect 
		edge_data_step(.async_sig(data_step),.clk(clk),
			.rise(data_step_sync),.fall());
	
	edge_detect 
		edge_cmd_step(.async_sig(cmd_step),.clk(clk),
			.rise(cmd_step_sync),.fall());
	
	// Data Synchronization
	wire [15:0] data_in_sync;
	wire [7:0]	cmd_in_sync;
	hx8352_controller_data_sync 
	data_sync_ut0(
	.clk(clk),.rst(rst),
	.cmd_in(cmd_in),.data_in(data_in), 
	.cmd_in_sync(cmd_in_sync),.data_in_sync(data_in_sync)
	);
	
	// Bus
	wire command_or_data, bus_controller_step, bus_busy, bus_done;
	wire [15:0]data_to_write;
	hx8352_bus_controller 
		hx8352_bus_u0
		(
			.clk(clk),
			.rst(rst),
			.data_input(data_to_write),
			.data_command(command_or_data),
			.transfer_step(bus_controller_step),
			.busy(bus_busy),
			.done(bus_done),
			.data_output(data_bus),
			.lcd_rs(lcd_rs),
			.lcd_wr(lcd_wr),
			.lcd_rd(lcd_rd)
		);
	// Delay
	wire [15:0] delay_value;
	wire delay_step;
	wire delay_done;
	wire delay_busy;
    delay_ms #(.PER_MS_COUNTER_VALUE(32'd50_000))
	   delay_u0
	   (.clk(clk),.rst(rst),
		.step(delay_step),.delay_ms(delay_value),
		.busy(delay_busy),.done(delay_done)
	   );
	// Fsm
	hx8352_main_fsm 
		fsm_u0(
		.clk(clk),.rst(rst),.bus_done(bus_done),.delay_done(delay_done),
		.data_in(data_in_sync), .cmd_in(cmd_in_sync),
		.data_step(data_step_sync), .cmd_step(cmd_step_sync),
		.init_done(init_done),
		.data_to_write(data_to_write),.command_or_data(command_or_data),.bus_step(bus_controller_step),
		.delay_value(delay_value),.delay_step(delay_step),
		.lcd_cs(lcd_cs), .lcd_rst(lcd_rst)
		);
		
	assign busy = bus_busy | bus_busy | delay_busy; 
	assign debug_instruction_step = { data_bus[7:0],
												lcd_wr,busy,lcd_rs,lcd_rd,
												lcd_cs,lcd_rst,command_or_data,clk};
endmodule
