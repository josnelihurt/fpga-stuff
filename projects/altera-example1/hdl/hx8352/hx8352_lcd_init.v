
module hx8352_lcd_init( 
	input  clk,
	input  rst,
	input  step,
	input  bus_done,
	input	 delay_done,
	output reg delay_step,
	output reg [15:0]delay_value,
	output reg command_or_data,
	output reg [15:0]data_to_write,
	output reg done,
	output reg lcs_cs,
	output reg bus_step
	);
localparam 
HIGH    = 1'b1,
LOW     = 1'b0,
LCD_CMD    = 1'b0,
LCD_DATA   = 1'b1,
CMD_Custom_Delay							=	8'hFE,
STATE_START =0,
STATE_IDLE =1,
STATE_LOAD_DATA =2,
STATE_PROCESS_CMD =3,
STATE_TRANSFER_CMD =4,
STATE_TRANSFER_CMD_WAIT_FOR_BUS =5,
STATE_TRANSFER_DATA =6,
STATE_TRANSFER_DATA_WAIT_FOR_BUS =7,
STATE_TRANSFER_DELAY =8,
STATE_TRANSFER_DELAY_WAIT_FOR =9,
STATE_END =10,
STATE_WAIT_TO_START = 12;


reg [3:0]state;
reg init_val_step;
wire [7:0]  init_cmd;
wire [15:0] init_val;
wire init_data_rdy,init_data_finish;
init_values init_values_u0(
	.clk(clk),.rst(rst),
	.next(init_val_step),
	.cmd(init_cmd),.value(init_val),.data_rdy(init_data_rdy),.finish(init_data_finish)
);
always @(posedge clk or posedge rst) begin
	if (rst) begin
		state 			<= STATE_WAIT_TO_START;
		delay_step 		<= 0;
		delay_value 	<= 0;
		command_or_data	<= 0;
		data_to_write	<= 0;
		done 			<= 0;
		bus_step 		<= 0;
		lcs_cs			<= 1;
		init_val_step 	<= 0;
	end else begin
		case(state)
		STATE_WAIT_TO_START:begin
			if(step)
				state <= STATE_START;
		end
		STATE_START:begin
			lcs_cs <= LOW;
			state <= STATE_IDLE;
		end
		STATE_IDLE:begin
			if(init_data_finish)begin
				state <= STATE_END;
			end else begin 
				state <= STATE_LOAD_DATA;
				init_val_step <= HIGH;
			end
		end
		STATE_LOAD_DATA:begin
			init_val_step <= LOW;
			if(init_data_rdy)
				state <= STATE_PROCESS_CMD;
			else
				state <= STATE_LOAD_DATA;
		end
		STATE_PROCESS_CMD:begin
			if(init_cmd == CMD_Custom_Delay)
				state <= STATE_TRANSFER_DELAY; 
			else
				state <= STATE_TRANSFER_CMD;
		end
		STATE_TRANSFER_CMD:begin
			command_or_data	<= LCD_CMD;
			bus_step <= HIGH;
			data_to_write <= init_cmd;
			state <= STATE_TRANSFER_CMD_WAIT_FOR_BUS;
		end
		STATE_TRANSFER_CMD_WAIT_FOR_BUS:begin
			bus_step <= LOW;
			if(bus_done)
				state <= STATE_TRANSFER_DATA;
			else
				state <= STATE_TRANSFER_CMD_WAIT_FOR_BUS;
		end
		STATE_TRANSFER_DATA:begin 
			command_or_data	<= LCD_DATA;
			bus_step <= HIGH;
			data_to_write <= init_val;
			state <= STATE_TRANSFER_DATA_WAIT_FOR_BUS;
		end
		STATE_TRANSFER_DATA_WAIT_FOR_BUS:begin 
			bus_step <= LOW;
			if(bus_done)
				state <= STATE_IDLE;
			else
				state <= STATE_TRANSFER_DATA_WAIT_FOR_BUS;
		end
		STATE_TRANSFER_DELAY:begin
			delay_step <= HIGH;
			delay_value <= init_val;
			state <= STATE_TRANSFER_DELAY_WAIT_FOR;
		end

		STATE_TRANSFER_DELAY_WAIT_FOR:begin
			delay_step <= LOW;
			if(delay_done)
				state <= STATE_IDLE;
			else
				state <= STATE_TRANSFER_DELAY_WAIT_FOR;
		end
		STATE_END:begin
			lcs_cs <= HIGH;
			state <= STATE_END;
			done <= HIGH;
		end
		default begin
			state <= STATE_IDLE;
		end
		endcase
	end
end


endmodule 
