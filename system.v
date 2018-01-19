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
	// UART
	//input             uart_rxd, 
	//output            uart_txd,
	// Debug 
	output	[2:0] leds,
	output tm1638_strobe,
	output tm1638_data,
	output tm1638_clk
);
//---------------------------------------------------------------------------
// General Purpose IO
//---------------------------------------------------------------------------
wire counter_unit0_ovf;
wire n_rst=~rst;
counter	#(    .N(32), // number of bits in counter
              .M(5000000) // Remember for simulation 50000 = frec(counter_unit0_ovf)=>1KHz, for implementation use 50000000 => 1 Hz 
   		)
	counter_unit0 
   (
    .clk(clk), .reset(n_rst),
    .max_tick(counter_unit0_ovf),
    .q()
   );
   
   
   //signal declaration
   reg [2:0] r_reg;
   wire [2:0] r_next;
   
   always @(posedge counter_unit0_ovf, posedge n_rst)
      if (n_rst)
         r_reg <= 0;
      else
         r_reg <= r_next;
         
   // next-state logic
   assign r_next = r_reg + 1;



parameter C_FCK = 50_000_000 ;


TM1638_LED_KEY_DRV #(
          .C_FCK    ( C_FCK         )// Hz
        , .C_FSCLK  ( 1_000_000     )// Hz
        , .C_FPS    ( 250           )// cycle(Hz)
    ) tm1638_ctrl_unit0 (
          .clk             ( clk            )
        , .n_rst          ( rst         )
        , .DIRECT7SEG0_i    ( 7'b0111111 )
        , .DIRECT7SEG1_i    ( 7'b0000110 )
        , .DIRECT7SEG2_i    ( 7'b1011011 )
        , .DIRECT7SEG3_i    ( 7'b1001111 )
        , .DIRECT7SEG4_i    ( 7'b1100110 )
        , .DIRECT7SEG5_i    ( 7'b1101101 )
        , .DIRECT7SEG6_i    ( 7'b1111101 )
        , .DIRECT7SEG7_i    ( 7'b0100111 )
        , .DOTS_i           ( KEYS     )
        , .LEDS_i           ( 8'hAA     )
        , .BIN_DAT_i        ( {
                                  4'h0
                                , 4'h5
                                , 4'hE
                                , 4'h3
                                , 4'h0
                                , 4'hA
                                , 4'h7
                                , 4'h8
                             })
        , .SUP_DIGITS_i     ()
        , .ENCBIN_XDIRECT_i ( 1'b1)
        , .BIN2BCD_ON_i     ( 1'b1 )
        , .MISO_i           ( )
        , .tm1638_data           ( tm1638_data )
        , .MOSI_OE_o        ( )
        , .tm1638_clk           ( tm1638_clk )
        , .tm1638_strobe             ( tm1638_strobe )
        , .KEYS_o           ( )
    ) ;





//----------------------------------------------------------------------------
// Wires Assigments
//----------------------------------------------------------------------------
assign leds = r_reg;

endmodule