module seven_segments_handler(
	input clk_1MHz,
	input rst,
	input[11:0] input_hex,
	input[2:0]  dots,
	output reg[2:0] display_7seg_anodes,
	output reg[7:0] display_7seg_bus
);
	wire [6:0]digit1,digit2,digit3;
	/// 7 Seg handler 
	seven_segments_decoder
		seven_segments_decoder_unit_1( .digit(input_hex[3:0]),.encoded_digit(digit1));
	seven_segments_decoder
		seven_segments_decoder_unit_2( .digit(input_hex[7:4]),.encoded_digit(digit2));
	seven_segments_decoder
		seven_segments_decoder_unit_3( .digit(input_hex[11:8]),.encoded_digit(digit3));
	
	wire[6:0] hex0 = ~digit3;
	wire[6:0] hex1 = ~digit2;
	wire[6:0] hex2 = ~digit1;
	reg [7:0] sseg;
	
	wire [2:0] counter_out;
	counter #(.N(2),.M(4))
		counter_7seg_ut0(
	    .clk(clk_1MHz), .reset(rst),
		 .max_tick(),.q(counter_out)
		);


	
	// 2 MSBs of counter to control 4-to-1 multiplexing
   // and to generate active-low enable signal
   always @*
      case (counter_out)
         2'b00:
            begin
               display_7seg_anodes =  3'b001;
               display_7seg_bus = {~dots[2] ,hex0};
            end
         2'b01:
            begin
               display_7seg_anodes =  3'b010;
               display_7seg_bus = {~dots[1] ,hex1};
            end
         2'b10:
            begin
               display_7seg_anodes = 3'b100;
               display_7seg_bus = {~dots[0] ,hex2};
            end
         default:
            begin
               display_7seg_anodes =  3'b000;
               display_7seg_bus = {~dots[2] ,hex0};
            end
       endcase
	

endmodule 