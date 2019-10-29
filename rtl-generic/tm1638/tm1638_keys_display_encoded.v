module tm1638_keys_display_encoded
(
	input		clk_1MHz,
	input		rst,
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
			.clk_1MHz(clk_1MHz),
			.rst(rst),
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
