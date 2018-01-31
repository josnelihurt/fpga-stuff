`timescale 1ns / 1ps
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
module matrix_ctrl(
    input wire clk,reset,
    input wire  [7:0] disp_data,
    output wire  [2:0] disp_addr,
    output mat_str,mat_rd,mat_clk,mat_oe,mat_cd,mat_clc
    );
//This memory is used for testing only It will remplaced for a 64-bit input in the module
//Here you can write to draw in the matrix

localparam NPRESS=12;				//It need to be calculated I left it on 2 for simulation

   // constant declaration

	// Internal signas declaration
	// Internal Current Row-Col values used in instantaneus refresh
   wire  		[7:0] cur_row;	//It must be changed from wires to register 
   reg	     	[7:0] cur_col;	//it will reduce giches if async changes are done
   
   /*MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM*/
   /*Prescaller for clock used in 4094 8-stage shift-and-store register*/
	
   wire		[NPRESS:0] clk_driver_next;//This clocks needs to be (1/60Hz)/8rows Cols are put it in parellel around 
   reg		[NPRESS:0] clk_driver_reg;
   always @(posedge clk, posedge reset)
		clk_driver_reg=(reset)?0:clk_driver_next;
   assign clk_driver_next = clk_driver_reg + 1;
   /* End - prescaller */
   /*VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV*/
   
   /*MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM*/
   /* FSM for driver 4094 8-stage shift-and-store */ 
	//Only 8States for the 8 data transfers
   wire 	[3:0] cnt_driver_next;
   reg		[3:0] cnt_driver_reg;
   wire 		  cnt_driver_max_tick;
   wire 		  clk_driver = clk_driver_reg[NPRESS];
   //It's importan to give an 90° delay between row/col_data assert and row/col_clk (posedge on 4094)
	always @(negedge clk_driver, posedge reset)	
		cnt_driver_reg <=(reset)?0:cnt_driver_next;
	assign cnt_driver_next 		= (cnt_driver_reg==9)?0:cnt_driver_reg + 1;//May be wee need to stop this FSM here you can do it
	assign cnt_driver_max_tick	= (cnt_driver_reg==8) ? 1 :  0;
	//Control signals assigments for the 4094 SReg
	assign mat_clc	= ~(cnt_driver_reg==9);
	assign mat_clk 	= (cnt_driver_reg<=7)?clk_driver:0;
	assign mat_rd 				= (		(cur_row >> cnt_driver_reg) )&1'b1 ;
	assign mat_cd				= (		(cur_col >> cnt_driver_reg) )&1'b1 ;
	// Strobe only on 8th state and after posedge on 4094 ;)
	assign mat_str 	= (cnt_driver_reg==8)&clk_driver;
	assign mat_oe 		= 	reset;
   /* End - FSM ... */ 
   /*VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV*/

   /*MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM*/
   /* Current row-col calculation */
   reg 		[2:0]	cnt_col_reg;
   wire		[2:0]	cnt_col_next;
	//Here is important to get a 90° delay because a posedge will chage values before
	//that the 4094 assert 8th data ;) 
	always @(posedge mat_str, posedge reset)
		cnt_col_reg <=(reset)?0:cnt_col_next;
	assign cnt_col_next	= cnt_col_reg + 1 ;
	//Re-order Col-register
	always @*
	begin
		case (cnt_col_reg)
			3'h7:cur_col=(1<<1);
			3'h6:cur_col=(1<<2);
			3'h5:cur_col=(1<<0);
			3'h4:cur_col=(1<<3);
			3'h3:cur_col=(1<<5);
			3'h2:cur_col=(1<<7);
			3'h1:cur_col=(1<<6);
			3'h0:cur_col=(1<<4);
		endcase
	end
	//Re-order row-register
	assign cur_row			= {disp_data[3],disp_data[5],disp_data[0],disp_data[6],disp_data[7],disp_data[1],disp_data[2],disp_data[4]};
	assign disp_addr		= cnt_col_reg;
endmodule
