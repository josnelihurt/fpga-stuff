
//lcd_rd => lcd read enable
//lcd_wr => lcd read 0, write 1
module hx8352_controller
(
	input  clk,
	input  rst,
	
	input  step,
	input  [3:0] cmd_in,
	input  [15:0] data_in,
	
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
	wire step_sync;
	edge_detect 
		edge_data_step(.async_sig(step),.clk(clk),
			.rise(step_sync),.fall());
	
	
	// Data Synchronization
	reg [3:0]	cmd_in_sync;
	reg [15:0]	data_in_sync;
	
	always @(posedge clk or posedge rst)
	if(rst) begin
		cmd_in_sync <= 0;
		data_in_sync <= 0;
	end else begin
		cmd_in_sync <= cmd_in;
		data_in_sync <= data_in;
	end
	
	
	
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
		.step(step_sync), .data_in(data_in_sync), .cmd_in(cmd_in_sync),
		
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
