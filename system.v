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
wire counter_unit0_ovf;
wire n_rst=~rst;
counter	#(    .N(32), // number of bits in counter
              .M(5) // Remember for simulation 50000 = frec(counter_unit0_ovf)=>1KHz, for implementation use 50000000 => 1 Hz 
   		)
	counter_unit0 
   (
    .clk(clk), .reset(n_rst),
    .max_tick(counter_unit0_ovf),
    .q()
   );
   
wire [ 7:0] board_keys;
reg [ 7:0] board_keys_reg;

   
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


//top test_unit(
//    .clk(counter_unit0_ovf),
//    .tm1638_strobe(tm1638_strobe),
//    .tm_clk(tm1638_clk),
//    .tm_dio(tm1638_data_io));
//    reg [7:0]   SUP_DIGITS ;


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
        C_READ  = 8'b01000010,
        C_WRITE = 8'b01000000,
        C_DISP  = 8'b10001111,
        C_ADDR  = 8'b11000000;

    localparam CLK_DIV = 19; // speed of scanner


    reg [5:0] instruction_step;
    reg [7:0] keys;

    reg [7:0] larson;
    reg larson_dir;
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

    assign tm_in = tm_data;
    assign tm_data = tm1638_data_oe ? tm_out : 8'hZZ;

    tm1638 u_tm1638 (
        .clk(counter_unit0_ovf),
        .rst(n_rst),
        .data_latch(tm_latch),
        .data(tm_data),
        .rw(tm1638_data_oe),
        .busy(busy),
        .sclk(tm1638_clk),
        .dio_in(tm1638_data_input),
        .dio_out(tm1638_data_output)
    );

    // handles displaying 1-8 on a display location
    // and animating the decimal point
    task display_digit;
        input [2:0] key;
        input [6:0] segs;

        begin
            tm_latch <= HIGH;

            if (keys[key])
                tm_out <= {1'b1, S_BLK[6:0]}; // decimal on
            else
                tm_out <= {1'b0, segs}; // decimal off
        end
    endtask

    // handles animating the LEDs 1-8
    task display_led;
        input [2:0] dot;

        begin
            tm_latch <= HIGH;
            tm_out <= {7'b0, larson[dot]};
        end
    endtask

    always @(posedge counter_unit0_ovf, posedge n_rst) begin
        if (n_rst) begin
            instruction_step <= 6'b0;
            tm1638_strobe <= HIGH;
            tm1638_data_oe <= HIGH;

            counter <= 0;
            keys <= 8'b0;
            larson_dir <= 0;
            larson <= 8'b00010000;

        end else 
        begin
            if (&counter) 
            begin
                larson_dir <= larson[6] ? 0 : larson[1] ? 1 : larson_dir;

                if (larson_dir)
                    larson <= {larson[6:0], larson[7]};
                else
                    larson <= {larson[0], larson[7:1]};
            end

            if (counter[0] && ~busy) 
            begin
                case (instruction_step)
                    // *** KEYS ***
                    1:  {tm1638_strobe, tm1638_data_oe}     <= {LOW, HIGH};
                    2:  {tm_latch, tm_out} <= {HIGH, C_READ}; // read mode
                    3:  {tm_latch, tm1638_data_oe}  <= {HIGH, LOW};

                    //  read back keys S1 - S8
                    4:  {keys[7], keys[3]} <= {tm_in[0], tm_in[4]};
                    5:  {tm_latch}         <= {HIGH};
                    6:  {keys[6], keys[2]} <= {tm_in[0], tm_in[4]};
                    7:  {tm_latch}         <= {HIGH};
                    8:  {keys[5], keys[1]} <= {tm_in[0], tm_in[4]};
                    9:  {tm_latch}         <= {HIGH};
                    10: {keys[4], keys[0]} <= {tm_in[0], tm_in[4]};
                    11: {tm1638_strobe}            <= {HIGH};

                    // *** DISPLAY ***
                    12: {tm1638_strobe, tm1638_data_oe}     <= {LOW, HIGH};
                    13: {tm_latch, tm_out} <= {HIGH, C_WRITE}; // write mode
                    14: {tm1638_strobe}            <= {HIGH};

                    15: {tm1638_strobe, tm1638_data_oe}     <= {LOW, HIGH};
                    16: {tm_latch, tm_out} <= {HIGH, C_ADDR}; // set addr 0 pos

                    17: display_digit(3'd7, S_1); // Digit 1
                    18: display_led(3'd0);        // LED 1

                    19: display_digit(3'd6, S_2); // Digit 2
                    20: display_led(3'd1);        // LED 2

                    21: display_digit(3'd5, S_3); // Digit 3
                    22: display_led(3'd2);        // LED 3

                    23: display_digit(3'd4, S_4); // Digit 4
                    24: display_led(3'd3);        // LED 4

                    25: display_digit(3'd3, S_5); // Digit 5
                    26: display_led(3'd4);        // LED 5

                    27: display_digit(3'd2, S_6); // Digit 6
                    28: display_led(3'd5);        // LED 6

                    29: display_digit(3'd1, S_7); // Digit 7
                    30: display_led(3'd6);        // LED 7

                    31: display_digit(3'd0, S_8); // Digit 8
                    32: display_led(3'b111);        // LED 8

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
assign leds = counter_reg[2:0];

endmodule
