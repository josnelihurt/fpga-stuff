

// 7SEG1_A Y13
// 7SEG2_A W13
// 7SEG3_A V13
// 7SEG_A V15
// 7SEG_B U20
// 7SEG_C W20
// 7SEG_D Y 17
// 7SEG_E W15
// 7SEG_F W17
// 7SEG_G U19
// 7SEG_P W19

module system(
	input 	clk50M, //T2
	input		push_btn, //J4
	output 	led, //E3
	output[2:0] display_7seg_anodes,
	output[7:0] display_7seg_bus
	);
	
	
	wire rst = ~push_btn;
	wire clk = clk50M;
	
	localparam RESET_COUTER_VALUE = 5_000_000;
	
	reg output_tick_reg;
	wire base_tick;
	reg [15:0] counter_reg;
	wire[15:0] counter_next;
	
	counter	#(.N(32),
				  .M(RESET_COUTER_VALUE)
			)
		counter_base_unit 
	   (
		.clk(clk50M), .reset(rst),
		.max_tick(base_tick),
		.q()
	   );
	always @(posedge base_tick or posedge rst)
    begin
		if (rst) begin
			output_tick_reg <= 0;
			counter_reg <= 0;
		end
      else begin
			output_tick_reg <= ~output_tick_reg;
			counter_reg <= counter_next;
      end
    end
	assign counter_next = counter_reg + 1;
	assign led=output_tick_reg;
	
	wire[6:0] digit1;
	wire[6:0] digit2;
	wire[6:0] digit3;
	
	/// 7 Seg handler 
	seven_segments_decoder
		seven_segments_decoder_unit_1( .digit(counter_reg[3:0]),.encoded_digit(digit1));
	seven_segments_decoder
		seven_segments_decoder_unit_2( .digit(counter_reg[7:4]),.encoded_digit(digit2));
	seven_segments_decoder
		seven_segments_decoder_unit_3( .digit(counter_reg[11:8]),.encoded_digit(digit3));
	
	wire[6:0] hex0 = ~digit3;
	wire[6:0] hex1 = ~digit2;
	wire[6:0] hex2 = ~digit1;
	// constant declaration
   // refreshing rate around 800 Hz (50 MHz/2^16)
   localparam N = 18;
	reg [7:0] sseg;
	// internal signal declaration
   reg [N-1:0] q_reg;
   wire [N-1:0] q_next;
   reg [6:0] hex_in;
	reg [2:0] cat_reg;

   // N-bit counter
   // register
   always @(posedge clk, posedge rst)
      if (rst)
         q_reg <= 0;
      else
         q_reg <= q_next;

   // next-state logic
   assign q_next = q_reg + 1;

	
	// 2 MSBs of counter to control 4-to-1 multiplexing
   // and to generate active-low enable signal
   always @*
      case (q_reg[N-1:N-2])
         2'b00:
            begin
               cat_reg =  3'b001;
               hex_in = hex0;
            end
         2'b01:
            begin
               cat_reg =  3'b010;
               hex_in = hex1;
            end
         2'b10:
            begin
               cat_reg = 3'b100;
               hex_in = hex2;
            end
         default:
            begin
               cat_reg =  3'b000;
               hex_in = hex0;
            end
       endcase
	
	/// End
	
	assign display_7seg_anodes = cat_reg; 
	assign display_7seg_bus = {1'b1,hex_in};
	
endmodule