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

module univ_shift_reg
   #(parameter N=8)
   (
    input wire clk, reset,
    input wire [1:0] ctrl,
    input wire [N-1:0] d,
    output wire [N-1:0] q
   );

   //signal declaration
   reg [N-1:0] r_reg, r_next;

   // body
   // register
   always @(posedge clk, posedge reset)
      if (reset)
         r_reg <= 0;
      else
         r_reg <= r_next;
   // next-state logic
   always @*
     case(ctrl)
       2'b00: r_next = r_reg;                  // no op
       2'b01: r_next = {r_reg[N-2:0], d[0]};   // shift left
       2'b10: r_next = {d[N-1], r_reg[N-1:1]}; // shift right
       default: r_next = d;                    // load
     endcase
   // output logic
   assign q = r_reg;

endmodule
