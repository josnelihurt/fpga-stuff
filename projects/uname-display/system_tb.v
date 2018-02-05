//----------------------------------------------------------------------------
//
//----------------------------------------------------------------------------

/*#
# SharkBoad
# Copyright (C) 2012 Bogotá, Colombia
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#*/

`timescale 1 ns / 100 ps

module system_tb;

//----------------------------------------------------------------------------
// Parameter (may differ for physical synthesis)
//----------------------------------------------------------------------------
parameter tck              = 20;       // clock period in ns
parameter uart_baud_rate   = 1152000;  // uart baud rate for simulation 

parameter clk_freq = 1000000000 / tck; // Frequenzy in HZ
//----------------------------------------------------------------------------
//
//----------------------------------------------------------------------------
reg        clk_tb;
reg        rst_tb;
wire[2:0]  led_tb;
reg 	   io5_tb;
wire tm1638_data_io_tb;
//----------------------------------------------------------------------------
// UART STUFF (testbench uart, simulating a comm. partner)
//----------------------------------------------------------------------------
wire         uart_rxd_tb;
wire         uart_txd_tb;

//----------------------------------------------------------------------------
// Device Under Test 
//----------------------------------------------------------------------------
system #(
	.clk_freq	(	clk_freq	),
	.uart_baud_rate	(	uart_baud_rate	)
) dut  (
	.clk50MHz(	clk_tb	),
	.io5( io5_tb ),
	.io67(tm1638_data_io_tb),
	// Debug
	.rst(	rst_tb	),
	.leds(	led_tb	)
	// Uart
);

localparam 
	LCD_CMD  = 1'b0,
	LCD_DATA = 1'b1;

wire n_rst;
assign n_rst = ~rst_tb;

wire [15:0] hx8352_data;
reg hx8352_data_command_tb;
wire hx8352_rs;
wire hx8352_wr;
wire hx8352_rd;
reg lcd_cs;
reg lcd_rst;
reg hx8352_transfer_step;
hx8352_controller
	hx8352_controller_unit0
	(
	.clk(clk_tb),
	.rst(n_rst),
	.lcd_rs(hx8352_rs),
	.lcd_wr(hx8352_wr),
	.lcd_rd(hx8352_rd)
	);

/* Clocking device */
// Remember this is only for simulation. It never will be syntetizable //
initial         clk_tb <= 0;
always #(tck/2) clk_tb <= ~clk_tb;

/* Simulation setup */
initial begin
	//set the file for loggin simulation data
	$dumpfile("system_tb.vcd"); 
	//$monitor("%b,%b,%b",clk_tb,rst_tb,led_tb);
	//export all signals in the simulation viewer
	$dumpvars(-1, hx8352_controller_unit0);
	//$dumpvars(-1,clk_tb,rst_tb);
	#0  io5_tb <= 1;
	#0  rst_tb <= 0;
	#0 	lcd_cs <= 1;
	#70 rst_tb <= 1;
	#80 rst_tb <= 0;
	#90 rst_tb <= 1;
	
	
	#100  lcd_cs <= 0;
	
	#100 	  lcd_cs <= 1;
	
	#(tck*100_000) $finish;
	//#(tck*750_000) $finish; // xx ms
end
endmodule
