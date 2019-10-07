
module nios_core (
	clk_clk,
	reset_reset_n,
	pio_0_external_connection_export,
	pio_lcd_control_external_connection_export);	

	input		clk_clk;
	input		reset_reset_n;
	output	[31:0]	pio_0_external_connection_export;
	output	[31:0]	pio_lcd_control_external_connection_export;
endmodule
