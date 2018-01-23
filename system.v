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
	input       uart_rx, 
	input       uart_tx,
	output		[2:0] leds,
	
	//! ============ L-SIDE ============  
	//! === Bank ===
	input 		io9,
	input 		io5,
	input 		io4,
	input 		io3,
	input 		io2,
	input 		io38,
	input 		io95,
	input 		io94,
	//! === Bank ===
	input 		io92,
	input 		io91,
	input 		io90,
	input 		i89,
	input 		i88,
	input 		io86,
	input 		io85,
	input 		io84,
	//! === Bank ===
	input 		io83,
	input 		io79,
	input 		io78,
	input 		io71,
	input 		io70,
	output 		io68,//tn1638_strobe
	inout 		io67,//tm1638_io
	output 		io66,//tm1638_clk
	
	
	//! ============ R-SIDE ============ 
	//! === Bank ===
	input 		io10,
	input 		io11,
	input 		io12,
	input 		io15,
	input 		io16,
	input 		io17,
	input 		io18,
	input 		io22,
	//! === Bank ===
	input 		io23,
	input 		i25,
	input 		io26,
	input 		i30,
	input 		io32,
	input 		io33,
	input 		io34,
	input 		io35,
	//! === Bank ===
	input 		io36,
	input 		io40,
	input 		io41,
	input 		io44,
	input 		io53,
	input 		io57,
	input 		io58,
	input 		io60
);
  localparam [6:0]
	S_1     = 7'b0000110,
	S_2     = 7'b1011011,
	S_3     = 7'b1001111,
	S_4     = 7'b1100110,
	S_5     = 7'b1101101,
	S_6     = 7'b1111101,
	S_7     = 7'b0000111,
	S_8     = 7'b1111111,
	S_BLK   = 7'b0000000;

//---------------------------------------------------------------------------
// General Purpose IO
//---------------------------------------------------------------------------

wire n_rst=~rst;

wire counter_tm1638_ovf;
counter	#(    .N(32),
              .M(10) 
   		)
	counter_unit0 
   (
    .clk(clk), .reset(n_rst),
    .max_tick(counter_tm1638_ovf),
    .q()
   );

wire counter_1hz_unit_ovf;
counter	#(    .N(32), // number of bits in counter
              .M(5000000) // Remember for simulation 50000 = frec(counter_tm1638_ovf)=>1KHz, for implementation use 50000000 => 1 Hz 
   		)
	counter_1hz_unit 
   (
    .clk(clk), .reset(n_rst),
    .max_tick(counter_1hz_unit_ovf),
    .q()
   );
wire[7:0] counter_leds;
wire[32:0] counter_low_frec;
assign counter_leds = counter_low_frec[7:0];
counter	#(    .N(32), 
              .M(32'hFFFF_FFFF)
   		)
	ccounter_leds_unit 
   (
    .clk(counter_1hz_unit_ovf), .reset(n_rst),
    .max_tick(),
    .q(counter_low_frec)
   );
    
    
    wire tm1638_strobe;
    wire tm1638_clk;
    wire tm1638_data_io;
    assign io67 = tm1638_data_io;
    assign io68 = tm1638_strobe;
    assign io66 = tm1638_clk;
    
	wire [7:0] tm1638_keys;
	tm1638_keys_display_encoded
		tm1638_keys_display_encoded_unit0
		(
		.clk_5MHz(counter_tm1638_ovf),
		.n_rst(n_rst),
		.display_off(1'b0),
		.display_level(3'b100),
		.display_value(counter_low_frec),
		.dots(counter_leds),
		.leds_green(counter_leds),
		.leds_red(tm1638_keys),
		.keys(tm1638_keys),
		.tm1638_strobe(tm1638_strobe),
		.tm1638_clk(tm1638_clk),
		.tm1638_data_io(tm1638_data_io)
		);
	
	//
	//tm1638_keys_display
	//	tm1638_keys_display_unit_0
	//	(
	//		.clk_5MHz(counter_tm1638_ovf),
	//		.n_rst(n_rst),
	//		.display_level({1'b0, counter_leds[2:0]}),
	//		.digit1({1'b0,S_1}),
	//		.digit2({1'b0,S_2}),
	//		.digit3({1'b0,S_3}),
	//		.digit4({1'b0,S_4}),
	//		.digit5({1'b0,S_5}),
	//		.digit6({1'b0,S_6}),
	//		.digit7({1'b0,S_7}),
	//		.digit8({1'b0,S_8}),
	//		.leds_green(counter_leds),
	//		.leds_red(tm1638_keys),		
	//		.keys(tm1638_keys),
	//		.tm1638_strobe(tm1638_strobe),
	//		.tm1638_clk(tm1638_clk),
	//		.tm1638_data_io(tm1638_data_io)
	//	);
//----------------------------------------------------------------------------
// Wires Assigments
//----------------------------------------------------------------------------
assign leds = counter_leds[2:0];

endmodule
