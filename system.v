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
	output reg tm1638_strobe,
	inout  tm1638_data_io,
	output tm1638_clk
);
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
counter	#(    .N(8), // number of bits in counter
              .M(255) // Remember for simulation 50000 = frec(counter_tm1638_ovf)=>1KHz, for implementation use 50000000 => 1 Hz 
   		)
	ccounter_leds_unit 
   (
    .clk(counter_1hz_unit_ovf), .reset(n_rst),
    .max_tick(),
    .q(counter_leds)
   );
   

	localparam 
        HIGH    = 1'b1,
        LOW     = 1'b0;

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

    localparam [7:0]
        C_READ  = 8'b0100_0010,
        C_WRITE = 8'b0100_0000,
        C_DISP  = 8'b1000_1111,
        C_ADDR  = 8'b1100_0000;

    localparam CLK_DIV = 19; // speed of scanner


    reg [5:0] instruction_step;
    reg [7:0] tm1638_keys;
	wire  [7:0] tm1638_leds_green;
	assign tm1638_leds_green = counter_leds;

	wire  [7:0] tm1638_leds_red;
	assign tm1638_leds_red = tm1638_keys;
    reg [CLK_DIV:0] counter;

    // set up tristate IO pin for display
    //   tm_dio     is physical pin
    //   dio_in     for reading from display
    //   dio_out    for sending to display
    //   tm1638_data_oe      selects input or output
	reg tm1638_data_oe ;
	wire tm1638_data_input;
	wire tm1638_data_output;
		
	assign tm1638_data_io = ( tm1638_data_oe ) ? tm1638_data_output : 1'bZ ; //DIO
	assign tm1638_data_input = tm1638_data_io;
    // setup tm1638 module with it's tristate IO
    //   tm_in      is read from module
    //   tm_out     is written to module
    //   tm_latch   triggers the module to read/write display
    //   tm1638_data_oe      selects read or write mode to display
    //   busy       indicates when module is busy
    //                (another latch will interrupt)
    //   tm_clk     is the data clk
    //   dio_in     for reading from display
    //   dio_out    for sending to display
    //
    //   tm_data    the tristate io pin to module
    reg tm_latch;
    wire busy;
    wire [7:0] tm_data, tm_in;
    reg [7:0] tm_out;
    wire [7:0] digit1;
    wire [7:0] digit2;
    wire [7:0] digit3;
    wire [7:0] digit4;
    wire [7:0] digit5;
    wire [7:0] digit6;
    wire [7:0] digit7;
    wire [7:0] digit8;

    assign tm_in = tm_data;
    assign tm_data = tm1638_data_oe ? tm_out : 8'hZZ;

	assign digit1 = {1'b0, S_8};
	assign digit2 = {1'b0, S_8};
	assign digit3 = {1'b0, S_8};
	assign digit4 = {1'b0, S_8};
	assign digit5 = {1'b0, S_8};
	assign digit6 = {1'b0, S_7};
	assign digit7 = {1'b0, S_6};
	assign digit8 = {1'b0, counter_leds[7:0]};

    tm1638 u_tm1638 (
        .clk(counter_tm1638_ovf),
        .rst(n_rst),
        .data_latch(tm_latch),
        .data(tm_data),
        .rw(tm1638_data_oe),
        .busy(busy),
        .sclk(tm1638_clk),
        .dio_in(tm1638_data_input),
        .dio_out(tm1638_data_output)
    );

    always @(posedge counter_tm1638_ovf, posedge n_rst) begin
        if (n_rst) begin
            instruction_step <= 6'b0;
            tm1638_strobe <= HIGH;
            tm1638_data_oe <= HIGH;

            counter <= 0;
            tm1638_keys <= 8'b0;

        end else 
        begin

            if (counter[0] && ~busy) 
            begin
                case (instruction_step)
                    // *** KEYS ***
                    1:  {tm1638_strobe, tm1638_data_oe}     <= {LOW, HIGH};
                    2:  {tm_latch, tm_out} <= {HIGH, C_READ}; // read mode
                    3:  {tm_latch, tm1638_data_oe}  <= {HIGH, LOW};

                    //  read back tm1638_keys S1 - S8
                    4:  {tm1638_keys[7],tm1638_keys[3]} <= {tm_in[0], tm_in[4]};
                    5:  {tm_latch}         <= {HIGH};
                    6:  {tm1638_keys[6],tm1638_keys[2]} <= {tm_in[0], tm_in[4]};
                    7:  {tm_latch}         <= {HIGH};
                    8:  {tm1638_keys[5],tm1638_keys[1]} <= {tm_in[0], tm_in[4]};
                    9:  {tm_latch}         <= {HIGH};
                    10: {tm1638_keys[4],tm1638_keys[0]} <= {tm_in[0], tm_in[4]};
                    11: {tm1638_strobe}    <= {HIGH};

                    // *** DISPLAY ***
                    12: {tm1638_strobe, tm1638_data_oe}     <= {LOW, HIGH};
                    13: {tm_latch, tm_out} <= {HIGH, C_WRITE}; // write mode
                    14: {tm1638_strobe}            <= {HIGH};

                    15: {tm1638_strobe, tm1638_data_oe}     <= {LOW, HIGH};
                    16: {tm_latch, tm_out} <= {HIGH, C_ADDR}; // set addr 0 pos

                    17: {tm_latch, tm_out} <= {HIGH, digit1};           // Digit 
                    18: {tm_latch, tm_out} <= {HIGH, {6'b0, tm1638_leds_red[7], tm1638_leds_green[7]}}; // LED
                    
                    19: {tm_latch, tm_out} <= {HIGH, digit2};           // Digit 
                    20: {tm_latch, tm_out} <= {HIGH, {6'b0, tm1638_leds_red[6], tm1638_leds_green[6]}}; // LED

                    21: {tm_latch, tm_out} <= {HIGH, digit3};           // Digit 
                    22: {tm_latch, tm_out} <= {HIGH, {6'b0, tm1638_leds_red[5], tm1638_leds_green[5]}}; // LED

                    23: {tm_latch, tm_out} <= {HIGH, digit4};           // Digit 
                    24: {tm_latch, tm_out} <= {HIGH, {6'b0, tm1638_leds_red[4], tm1638_leds_green[4]}}; // LED

                    25: {tm_latch, tm_out} <= {HIGH, digit5};           // Digit 
                    26: {tm_latch, tm_out} <= {HIGH, {6'b0, tm1638_leds_red[3], tm1638_leds_green[3]}}; // LED

                    27: {tm_latch, tm_out} <= {HIGH, digit6};           // Digit 
                    28: {tm_latch, tm_out} <= {HIGH, {6'b0, tm1638_leds_red[2], tm1638_leds_green[2]}}; // LED

                    29: {tm_latch, tm_out} <= {HIGH, digit7};           // Digit 
                    30: {tm_latch, tm_out} <= {HIGH, {6'b0, tm1638_leds_red[1], tm1638_leds_green[1]}}; // LED

                    31: {tm_latch, tm_out} <= {HIGH, digit8};           // Digit 
                    32: {tm_latch, tm_out} <= {HIGH, {6'b0, tm1638_leds_red[0], tm1638_leds_green[0]}}; // LED

                    33: {tm1638_strobe}            <= {HIGH};

                    34: {tm1638_strobe, tm1638_data_oe}     <= {LOW, HIGH};
                    35: {tm_latch, tm_out} <= {HIGH, C_DISP}; // display on, full bright
                    36: {tm1638_strobe, instruction_step} <= {HIGH, 6'b0};

                endcase

                instruction_step <= instruction_step + 1;

            end else if (busy) 
            begin
                // pull latch low next clock cycle after module has been
                // latched
                tm_latch <= LOW;
            end

            counter <= counter + 1;
        end
    end

//----------------------------------------------------------------------------
// Wires Assigments
//----------------------------------------------------------------------------
assign leds = counter_leds[2:0];

endmodule
