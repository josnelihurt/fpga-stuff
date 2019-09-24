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
parameter tck              = 1000;       // clock period in us
//----------------------------------------------------------------------------
//
//----------------------------------------------------------------------------
reg        clk_tb;
reg        rst_tb;

wire hx8352_busy,hx8352_rs,hx8352_wr,hx8352_rd,hx8352_rst,hx8352_cs,hx8352_init_done;
wire[15:0] hx8352_data;
wire[15:0] lcd_data_in;
//----------------------------------------------------------------------------
// Device Under Test 
//----------------------------------------------------------------------------
	hx8352_controller
		uut0
		(
		.clk(clk_tb),
		.clk_1MHz(clk_tb),
		.rst(rst_tb),
		.data_in(lcd_data_in),
		.busy(hx8352_busy),
		.lcd_rs(hx8352_rs),
		.lcd_wr(hx8352_wr),
		.lcd_rd(hx8352_rd),
		.lcd_rst(hx8352_rst),
		.lcd_cs(hx8352_cs),
		.data_bus(hx8352_data[15:0]),
		.init_done(hx8352_init_done)
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
	$dumpvars(-1, uut0);
	//$dumpvars(-1,clk_tb,rst_tb);
	#0 
	rst_tb <= 1;
	
	#10000
	rst_tb <= 0;
	
	
	#(tck*500000) $finish;
	//#(tck*750_000) $finish; // xx ms
end
endmodule
