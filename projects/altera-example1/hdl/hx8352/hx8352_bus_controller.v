module hx8352_bus_controller
(
	input  clk,
	input  rst,
	input  [15:0] data_input,
	input  data_command,
	input  transfer_step,
	
	output reg busy,
	output reg done,
	output reg [15:0] data_output,
	output reg lcd_wr,
	output lcd_rs,
	output lcd_rd
);
    localparam [2:0]
        STATE_IDLE      				= 3'h0,
        STATE_LOAD_DATA 				= 3'h1,
        STATE_WR_LOW						= 3'h2,
        STATE_WR_LOW_END				= 3'h3
				;
	localparam 
        HIGH    = 1'b1,
        LOW     = 1'b0;


reg [2:0]fsm_bus_step;
always @(posedge clk or posedge rst) begin
  if (rst) begin
		lcd_wr<=HIGH;
		busy <= LOW;
		data_output<=16'h0000;
		done <= LOW;
	end else begin 	
		case(fsm_bus_step) 
		STATE_IDLE: begin
			busy <= LOW;
			done <= LOW;
			if (transfer_step) begin
				fsm_bus_step <= STATE_LOAD_DATA;
				busy <= HIGH;
			end
		end
		STATE_LOAD_DATA: begin
			data_output <= data_input;
			fsm_bus_step <= STATE_WR_LOW;	
		end
		STATE_WR_LOW: begin
			lcd_wr <= LOW;
			fsm_bus_step <= STATE_WR_LOW_END;
		end
		STATE_WR_LOW_END:begin 
			lcd_wr<=HIGH;
			busy <= LOW;
			done <= HIGH;
			fsm_bus_step <= STATE_IDLE;
		end
		default:
			fsm_bus_step <= STATE_IDLE;
		endcase
	end
end
assign lcd_rs = data_command;
assign lcd_rd = HIGH;//Never shold be low because this never will be readed
endmodule
