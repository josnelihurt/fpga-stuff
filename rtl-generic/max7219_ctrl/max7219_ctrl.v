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
    input wire  [3:0] intensity,
    output wire  [2:0] disp_addr,
    output max7219_din,max7219_ncs,max7219_clk
    );
//This memory is used for testing only It will remplaced for a 64-bit input in the module
//Here you can write to draw in the matrix

localparam NPRESS	=2;				//It need to be calculated I left it on 2 for simulation
localparam NOP 		=2'b00;
localparam SHIFT_L 	=2'b01;
localparam SHIFT_R 	=2'b10;
localparam LOAD 	=2'b11;
   // constant declaration
	// Internal signas declaration
	// Internal Current Row-Col values used in instantaneus refresh
   wire  		[7:0] cur_row;	//It must be changed from wires to register 
   reg	     	[3:0] cur_col_reg;	//it will reduce giches if async changes are done
   reg 			[3:0] cur_col_next;
   reg 				  ncs;
   assign cur_row = disp_data;
   /*MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM*/
   /*Prescaller for clock used serial comunication @10MHz Max*/
   wire		[NPRESS:0] clk_driver_next;
   reg		[NPRESS:0] clk_driver_reg;
   	wire clk_driver;
   always @(posedge clk, posedge reset)
		clk_driver_reg=(reset)?0:clk_driver_next;
   assign clk_driver_next = clk_driver_reg + 1;
   assign clk_driver = clk_driver_next[NPRESS];
   /* End - prescaller */
   /*VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV*/
	reg [15:0] serial_data_reg;
   /*MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM*/
   /* Shift Reg*/
   reg [1:0] ctrl_sr;
   wire ctrl_sr_done;
	shift_reg_start_done #(.N(16))
	shift_reg_start_done_unit_0(
		.clk(clk_driver), .reset(reset),
		.ctrl(ctrl_sr),
		.d(serial_data_reg),
		.q(max7219_din),
		.last_tick(ctrl_sr_done)
	);
   /* Shift Reg*/
   /*VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV*/
   
   /*MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM*/
   /* FSM for driver 16-stage shift-and-store */ 
   // symbolic state declaration
   	localparam MAX_STATES=8;
	localparam [MAX_STATES-1:0] START 						= 8'h0  ,
								DIS_SHUTDOWN				= 8'hC0 ,
								DIS_SHUTDOWN_WAIT2FINISH	= 8'hC1 ,
								SET_SCAN_MODE				= 8'hB0 ,
								SET_SCAN_MODE_WAIT2FINISH 	= 8'hB1 ,
								INTENSITY					= 8'hA0 ,
								INTENSITY_WAIT2FINISH		= 8'hA1 , 
								SET_DECODE_MODE				= 8'h90 ,
								SET_DECODE_MODE_WAIT2FINISH	= 8'h91 ,
								DISPLAY_TEST				= 8'hF1 ,
								DISPLAY_TEST_WAIT2FINISH	= 8'hF2 ,
								DISPLAY_TEST_OFF			= 8'hF3 ,
								DISPLAY_TEST_OFF_WAIT2FINISH= 8'hF4 ,
								MAIN_LOOP					= 8'h1 ,
								UPDATE_FRAME				= 8'h10 ,
								UPDATE_FRAME_WAIT2FINISH	= 8'h11 ,
								STOP						= 8'hFF ;
	//signal declaration
	reg [MAX_STATES-1:0] state_reg, state_next;	
	//state register
    always @(posedge clk_driver, posedge reset)	
		if (reset)
		begin
			state_reg <= START;
			cur_col_reg <= 0;
		end
		else
		begin
			state_reg <= state_next;
			cur_col_reg <= cur_col_next;
		end
	//next-state logic
	always @*
	begin
		state_next = state_reg;
		cur_col_next = cur_col_reg;
		serial_data_reg <= 0;
		ncs = 1;
		case (state_reg)
		START:begin
			ctrl_sr = NOP;
			ncs = 1;
			state_next = DIS_SHUTDOWN;
		end
		DIS_SHUTDOWN:begin//Disabe the shutdown mode
			serial_data_reg <= {8'hC,8'h1};//check
			ctrl_sr = LOAD;
			ncs = 1;
			state_next = DIS_SHUTDOWN_WAIT2FINISH;
		end
		DIS_SHUTDOWN_WAIT2FINISH:begin
			ctrl_sr = SHIFT_L;//MSB first
			ncs = 0;
			if (ctrl_sr_done)
				state_next = SET_SCAN_MODE;
		end
		SET_SCAN_MODE:begin
			//No decode. It will only be set for 7-Segments
			serial_data_reg <= {8'hB,8'h7};//check
			ctrl_sr = LOAD;
			ncs = 1;
			state_next = SET_SCAN_MODE_WAIT2FINISH;
		end
		SET_SCAN_MODE_WAIT2FINISH:begin
			ctrl_sr = SHIFT_L;//MSB first
			ncs = 0;
			if (ctrl_sr_done)
				state_next = INTENSITY;
		end
		INTENSITY:begin
			serial_data_reg <= {8'hA,4'h0,intensity};//check
			ctrl_sr = LOAD;
			ncs = 1;
			state_next = INTENSITY_WAIT2FINISH;
		end
		INTENSITY_WAIT2FINISH:begin
		ctrl_sr = SHIFT_L;//MSB first
		ncs = 0;
			if (ctrl_sr_done)
				state_next = SET_DECODE_MODE;
		end
		SET_DECODE_MODE:begin
			//No decode. It will only be set for 7-Segments
			serial_data_reg <= {8'h9,8'h0};
			ctrl_sr = LOAD;
			ncs = 1;
			state_next = SET_DECODE_MODE_WAIT2FINISH;
		end
		SET_DECODE_MODE_WAIT2FINISH:begin
			ctrl_sr = SHIFT_L;//MSB first
			ncs = 0;
			if (ctrl_sr_done)
				state_next = DISPLAY_TEST_OFF;
		end
		/*Display test secuence */
		DISPLAY_TEST:begin
			serial_data_reg <= {8'hF,8'h1};
			ctrl_sr = LOAD;
			ncs = 1;
			state_next = DISPLAY_TEST_WAIT2FINISH;
		end
		DISPLAY_TEST_WAIT2FINISH:begin
			ctrl_sr = SHIFT_L;//MSB first
			ncs = 0;
			if (ctrl_sr_done)
				state_next = DISPLAY_TEST_OFF;
		end
		DISPLAY_TEST_OFF:begin
			serial_data_reg <= {8'hF,8'h0};//Normal op
			ctrl_sr = LOAD;
			ncs = 1;
			state_next = DISPLAY_TEST_OFF_WAIT2FINISH;
		end
		DISPLAY_TEST_OFF_WAIT2FINISH:begin
			ctrl_sr = SHIFT_L;//MSB first
			ncs = 0;
			if (ctrl_sr_done)
				state_next = MAIN_LOOP;
		end
		//Main Loop. Send the Intensity level
		MAIN_LOOP:begin
			cur_col_next=1;
			ncs = 1;
			state_next = UPDATE_FRAME;
		end
		UPDATE_FRAME:begin
			serial_data_reg <= {4'h0,cur_col_reg,cur_row};
			ncs = 1;
			ctrl_sr = LOAD;
			if (cur_col_reg == 9)
				state_next = START;
			else
				state_next = UPDATE_FRAME_WAIT2FINISH;
				
		end
		UPDATE_FRAME_WAIT2FINISH:begin
		ctrl_sr = SHIFT_L;//MSB first
		ncs = 0;
			if (ctrl_sr_done)
			begin
				cur_col_next = cur_col_reg + 1;
				state_next = UPDATE_FRAME;
			end
		end

		STOP:begin
		ncs = 1;
		state_next = STOP;
		end
		default: state_next = START;
		
		endcase
	end
   /* End - FSM ... */ 
   /*VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV*/

   /*MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM*/
   /* Current row-col calculation */
	assign disp_addr = cur_col_reg - 1;
	assign max7219_ncs = ncs;
	assign max7219_clk = ~clk_driver;
endmodule
