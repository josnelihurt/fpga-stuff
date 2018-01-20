//---------------------------------------------------------------------------
// SharkBoad SystemModule
//
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
#  _________.__                  __   __________                       .___
# /   _____/|  |__ _____ _______|  | _\______   \ _________ _______  __| _/
# \_____  \ |  |  \\__  \\_  __ \  |/ /|    |  _//  _ \__  \\_  __ \/ __ | 
# /        \|   Y  \/ __ \|  | \/    < |    |   (  <_> ) __ \|  | \/ /_/ | 
#/_______  /|___|  (____  /__|  |__|_ \|______  /\____(____  /__|  \____ | 
#        \/      \/     \/           \/       \/           \/           \/ 
#
*/
module system
#(
	parameter	clk_freq	= 50000000,
	parameter	uart_baud_rate	= 57600
) (
	input		clk,
	input		rst,
	input 		io9,
	input 		io5,
	input 		io4,
	// UART
	//input             uart_rxd, 
	//output            uart_txd,
	// Debug 
	output	[2:0] leds,
	output tm1638_strobe,
	inout  tm1638_data_io,
	output tm1638_clk
);
//---------------------------------------------------------------------------
// General Purpose IO
//---------------------------------------------------------------------------
wire counter_unit0_ovf;
wire n_rst=~rst;
counter	#(    .N(32), // number of bits in counter
              .M(500000) // Remember for simulation 50000 = frec(counter_unit0_ovf)=>1KHz, for implementation use 50000000 => 1 Hz 
   		)
	counter_unit0 
   (
    .clk(clk), .reset(n_rst),
    .max_tick(counter_unit0_ovf),
    .q()
   );
   
parameter C_FCK = 50_000_000 ;

wire [ 7:0] board_keys;
reg [ 7:0] board_keys_reg;

wire tm1638_data_oe ;
wire tm1638_data_input;
wire tm1638_data_output;
assign tm1638_data_io = ( tm1638_data_oe ) ? tm1638_data_output : 1'bZ ; //DIO
   
   //signal declaration
   reg [31:0] counter_reg;
   wire [31:0] counter_next;
   
   always @(posedge counter_unit0_ovf, posedge n_rst)
      if (n_rst)
         counter_reg <= 0;
      else
         counter_reg <= counter_next;
         
   // next-state logic
   assign counter_next = counter_reg + 1;

   always @(posedge counter_unit0_ovf, posedge n_rst)
      if (n_rst)
         board_keys_reg <= 8'b0;
      else
         board_keys_reg <= board_keys;



    reg [7:0]   SUP_DIGITS ;
    
	tm1638 tm1638_unit0 (
			.clk            (clk),
			.rst            (rst),
			.data_latch     (data_latch),
			.data           (data_sig),
			.rw             (rw),
			.busy           (busy),
			.sclk           (sclk),
			.dio_out        (dio_out),
			.dio_in         (dio_in)
	);

TM1638_LED_KEY_DRV #(
          .C_FCK    ( C_FCK         )// Hz
        , .C_FSCLK  ( 1_000_000     )// Hz
        , .C_FPS    ( 250           )// cycle(Hz)
    ) tm1638_ctrl_unit0 (
          .clk(clk)
        , .n_rst(rst)
        , .dots_input(board_keys_reg)
        , .leds_input( counter_reg[7:0])
        , .display_data_input(counter_reg[31:0])
        , .SUP_DIGITS_i(SUP_DIGITS)
        , .enable_bin2bcd( io5 )
        , .tm1638_data_input (tm1638_data_input)
        , .tm1638_data_output ( tm1638_data_output )
        , .tm1638_data_oe( tm1638_data_oe)
        , .tm1638_clk( tm1638_clk )
        , .tm1638_strobe( tm1638_strobe )
        , .key_values( board_keys)
    ) ;

    generate
        genvar g_idx ;
        for (g_idx=0 ; g_idx<8 ; g_idx=g_idx+1)begin :gen_SUPS
            always @ (posedge clk)
                    SUP_DIGITS[g_idx] <= board_keys[ g_idx ] ;
        end
    endgenerate 



//----------------------------------------------------------------------------
// Wires Assigments
//----------------------------------------------------------------------------
assign leds = counter_reg[2:0];

endmodule
