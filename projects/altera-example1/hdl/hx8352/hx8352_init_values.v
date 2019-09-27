
module init_values(
	input clk,
	input rst,
	input next,
	output reg [7:0]cmd,
	output reg [7:0]value,
	output reg data_rdy,
	output reg finish
);
localparam 
HIGH    = 1'b1,
LOW     = 1'b0,
CMD_Custom_Done =	8'hFF,
STATE_START	= 0,
STATE_IDLE 	= 1,
STATE_LOAD	= 2,
STATE_LOADED= 3,
STATE_END 	= 4;

reg 	[7:0]rom_address;
wire 	[7:0]rom_cmd;
wire 	[7:0]rom_value;
rom_init_cmd 
	rom_init_cmd_u0(
		.clk(clk),.addr(rom_address),
		.data({rom_cmd,rom_value})
	);
reg [3:0]state;
always @(posedge clk or posedge rst) begin
	if (rst) begin
		state <= STATE_START;
		data_rdy <= 0;
		finish <= 0;
	end else begin
		case (state)
		STATE_START: begin
			rom_address <= 0;
			state <= STATE_IDLE;
		end
		STATE_IDLE: begin
			data_rdy <= 0;
			if(rom_cmd == CMD_Custom_Done)begin
				state <= STATE_END;
				finish <= 1;
			end else begin
				if(next) begin
					rom_address <= rom_address + 1'b1;
					state <= STATE_LOAD;
				end
			end
		end
		STATE_LOAD: begin
			cmd <= rom_cmd;
			value <= rom_value;
			state <= STATE_LOADED;
		end	
		STATE_LOADED: begin
			data_rdy <= 1;
			state <= STATE_IDLE;
		end
		STATE_END: begin
			state <= STATE_END;
		end
		default: begin
			state <= STATE_IDLE;
		end 	
		endcase
	end
end

endmodule
