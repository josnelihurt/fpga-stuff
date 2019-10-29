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