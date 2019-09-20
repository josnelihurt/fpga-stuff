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

reg[15:0] delay_us;
reg delay_step;
wire delay_done;

//----------------------------------------------------------------------------
// Device Under Test 
//----------------------------------------------------------------------------
hx8352_delay_us 
	delay_uut(
	.clk_1MHz(clk_tb),
	.rst(rst_tb),
	.step(delay_step),
	.delay_us(delay_us),
	.done(delay_done)
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
	$dumpvars(-1, delay_uut);
	//$dumpvars(-1,clk_tb,rst_tb);
	#0 
	rst_tb <= 1;
	delay_step <= 0;
	delay_us <= 16'd10_000;
	
	#10000
	rst_tb <= 0;
	rst_tb <= 0;
	
	#20000
	delay_step <= 1;
	#30000
	delay_step <= 0;
	
	
	#(tck*100_000) $finish;
	//#(tck*750_000) $finish; // xx ms
end
endmodule
