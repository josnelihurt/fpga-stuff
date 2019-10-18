
module nios_core (
	clk_clk,
	pio_0_external_connection_export,
	pio_lcd_control_external_connection_export,
	reset_reset_n);	

	input		clk_clk;
	output	[31:0]	pio_0_external_connection_export;
	output	[31:0]	pio_lcd_control_external_connection_export;
	input		reset_reset_n;
endmodule
