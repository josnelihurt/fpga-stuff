// Based on Pon P Chu - Listing 4.8
//---------------------------------------------------------------------------
// SharkBoad ExampleModule
// Josnelihurt Rodriguez - Fredy Segura Q.
// josnelihurt@gmail.com
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

module shift_reg_start_done
   #(parameter N=8)
   (
    input wire clk, reset,
    input wire [1:0] ctrl,
    input wire [N-1:0] d,
    output wire q, last_tick
   );
localparam NOP 		=2'b00;
localparam SHIFT_L 	=2'b01;
localparam SHIFT_R 	=2'b10;
localparam LOAD 	=2'b11;
   //signal declaration
   reg [N-1:0] r_reg, r_next;
   reg [N-1:0] cnt_reg, cnt_next;
   // body
   // register
   always @(posedge clk, posedge reset)
	begin
      if (reset)
      begin
        r_reg <= 0;
        cnt_reg <= 0;
      end
      else
      begin
        r_reg <= r_next;
		cnt_reg <= cnt_next;
      end
    end
   // next-state logic
   always @*
   begin
   cnt_next	= (cnt_reg == N-1) ? 0 : cnt_reg + 1;
   r_next = r_reg;
     case(ctrl)
       NOP: r_next = r_reg;                  // no op
       SHIFT_L: r_next = {r_reg[N-2:0], 1'b0};   // shift left
       SHIFT_R: r_next = {1'b0, r_reg[N-1:1]}; // shift right
       LOAD:begin
			r_next = d;                      // load
			cnt_next = 0;
		end
     endcase
   end
   // output logic
   assign q = r_reg[N-1];
   assign last_tick	= (cnt_reg == N-1);
endmodule
