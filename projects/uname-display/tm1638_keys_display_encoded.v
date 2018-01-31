module seven_segments_decoder
(
	input [3:0] digit,
	output reg [6:0] encoded_digit
);
    // endcoder for  LED7-segment
    //   a 		          0 		
    // f     b          5     1
    //    g                6
    // e     c          4     2
    //    d                3 
    localparam [6:0]
		S_0     = 7'b0_11_1_11_1,
		S_1     = 7'b0_00_0_11_0,
		S_2     = 7'b1_01_1_01_1,
		S_3     = 7'b1_00_1_11_1,
		S_4     = 7'b1_10_0_11_0,
		S_5     = 7'b1_10_1_10_1,
		S_6     = 7'b1_11_1_10_1,
		S_7     = 7'b0_00_0_11_1,
		S_8     = 7'b1_11_1_11_1,
		S_9     = 7'b1_10_1_11_1,
		S_A     = 7'b1_11_0_11_1,
		S_B     = 7'b1_11_1_10_0,
		S_C     = 7'b1_01_1_00_0,
		S_D     = 7'b1_01_1_11_0,
		S_E     = 7'b1_11_1_00_1,
		S_F     = 7'b1_11_0_00_1,
		S_BLK   = 7'b0_00_0_00_0;
	always @*
	begin
		case (digit)
			4'h0: encoded_digit = S_0;
			4'h1: encoded_digit = S_1;
			4'h2: encoded_digit = S_2;
			4'h3: encoded_digit = S_3;
			4'h4: encoded_digit = S_4;
			4'h5: encoded_digit = S_5;
			4'h6: encoded_digit = S_6;
			4'h7: encoded_digit = S_7;
			4'h8: encoded_digit = S_8;
			4'h9: encoded_digit = S_9;
			4'hA: encoded_digit = S_A;
			4'hB: encoded_digit = S_B;
			4'hC: encoded_digit = S_C;
			4'hD: encoded_digit = S_D;
			4'hE: encoded_digit = S_E;
			4'hF: encoded_digit = S_F;
		endcase	
	end
endmodule

module tm1638_keys_display_encoded
(
	input		clk_5MHz,
	input		n_rst,
	input 		display_off,
    input [2:0] display_level,
	input [31:0] display_value,
	input [7:0] dots,
	input [7:0] leds_green,
	input [7:0] leds_red,

    output [7:0] keys,
    output tm1638_strobe,
    output tm1638_clk,
    inout  tm1638_data_io
);	
	wire [7:0] tm1638_keys;
	
	wire [6:0] digit1;
    wire [6:0] digit2;
    wire [6:0] digit3;
    wire [6:0] digit4;
    wire [6:0] digit5;
    wire [6:0] digit6;
    wire [6:0] digit7;
    wire [6:0] digit8;
    
    seven_segments_decoder
		seven_segments_decoder_unit_1( .digit(display_value[3:0]),.encoded_digit(digit1));
    seven_segments_decoder
		seven_segments_decoder_unit_2( .digit(display_value[7:4]),.encoded_digit(digit2));
    seven_segments_decoder
		seven_segments_decoder_unit_3( .digit(display_value[11:8]),.encoded_digit(digit3));
    seven_segments_decoder
		seven_segments_decoder_unit_4( .digit(display_value[15:12]),.encoded_digit(digit4));
    seven_segments_decoder
		seven_segments_decoder_unit_5( .digit(display_value[19:16]),.encoded_digit(digit5));
    seven_segments_decoder
		seven_segments_decoder_unit_6( .digit(display_value[23:20]),.encoded_digit(digit6));
    seven_segments_decoder
		seven_segments_decoder_unit_7( .digit(display_value[27:24]),.encoded_digit(digit7));
    seven_segments_decoder
		seven_segments_decoder_unit_8( .digit(display_value[31:28]),.encoded_digit(digit8));
	
	tm1638_keys_display
		tm1638_keys_display_unit_0
		(
			.clk_5MHz(clk_5MHz),
			.n_rst(n_rst),
			.display_level({display_off, display_level}),
			.digit1({dots[0], digit8}),
			.digit2({dots[1], digit7}),
			.digit3({dots[2], digit6}),
			.digit4({dots[3], digit5}),
			.digit5({dots[4], digit4}),
			.digit6({dots[5], digit3}),
			.digit7({dots[6], digit2}),
			.digit8({dots[7], digit1}),
			.leds_green(leds_green),
			.leds_red(leds_red),		
			.keys(keys),
			.tm1638_strobe(tm1638_strobe),
			.tm1638_clk(tm1638_clk),
			.tm1638_data_io(tm1638_data_io)
		);
endmodule
