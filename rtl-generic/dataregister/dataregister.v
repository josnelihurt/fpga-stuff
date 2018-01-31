//---------------------------------------------------------------------------
// SharkBoad ExampleModule
// Josnelihurt Rodriguez - Fredy Segura Q.
// josnelihurt@gmail.com
// Top Level Design for the Xilinx Spartan 3-100E Device
//---------------------------------------------------------------------------

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

/*
  _________.__                  __   __________                       .___
 /   _____/|  |__ _____ _______|  | _\______   \ _________ _______  __| _/
 \_____  \ |  |  \\__  \\_  __ \  |/ /|    |  _//  _ \__  \\_  __ \/ __ | 
 /        \|   Y  \/ __ \|  | \/    < |    |   (  <_> ) __ \|  | \/ /_/ | 
/_______  /|___|  (____  /__|  |__|_ \|______  /\____(____  /__|  \____ | 
        \/      \/     \/           \/       \/           \/           \/ 

*/
// Based on Pong P. Chu - FPGA Prototyping by Verilog Examples

module	datadegister #(
	parameter DATAWIDTH = 1
	)
	(	input				clk,rst,tg_tick,
		input		[DATAWIDTH-1:0]	d,
		output reg	[DATAWIDTH-1:0]	q 
	);
wire next_q;
always @(posedge clk, posedge rst)
	begin
		if(rst)
		begin
			q<='h0;
		end
		else	if(tg_tick)
				q<=next_q;
			else
				q<=q;
	end
assign next_q=~q;
endmodule
