
module hx8352_controller_fsm(
	input clk,
	input rst,
	output init_done,
	output reg [15:0]data_to_write,
	output command_or_data,
	output bus_step,
	output wire [15:0]delay_value,
	output wire delay_step,
	output reg lcd_cs
);
localparam 
HIGH    = 1'b1,
LOW     = 1'b0,
LCD_CMD    = 1'b0,
LCD_DATA   = 1'b1,
CMD_Product_ID								=	8'h00,
CMD_Data_read_write						=	8'h22,
STATE_INITIALIZE							= 4'd1,
STATE_IDLE									= 4'd2,
STATE_TRANSFER_CMD 						= 4'd3,
STATE_TRANSFER_PIXEL						= 4'd4,
STATE_TRANSFER_PIXEL_LOAD_CMD 		= 4'd5,
STATE_TRANSFER_PIXEL_LOAD_CMD_END	= 4'd6,
STATE_TRANSFER_PIXEL_LOAD_DATA		= 4'd7,
STATE_TRANSFER_PIXEL_LOAD_DATA_END	= 4'd8

;


reg  lcd_init_step;
wire lcd_init_working;
wire lcd_bus_step;
wire lcd_command_or_data;
wire [15:0]lcd_data_to_write;
hx8352_lcd_init 
	init_ut0( 
	.clk(clk),
	.rst(rst),
	.step(lcd_init_step),
	.delay_step(delay_step),
	.delay_value(delay_value),
	.data_to_write(lcd_data_to_write),
	.command_or_data(lcd_command_or_data),
	.working(lcd_init_working),
	.done(init_done),
	.bus_step(lcd_bus_step)
	);
	
reg  [3:0]  fsm_state;
reg bus_step_reg;
reg command_or_data_reg;
always @(posedge clk or posedge rst) begin
  if (rst) begin
		fsm_state <= STATE_INITIALIZE;
		lcd_init_step <= LOW;
		data_to_write <= 16'h0000;
		bus_step_reg <= LOW;
		command_or_data_reg <= LCD_CMD;
		lcd_cs <= HIGH;
  end else begin 	
		lcd_init_step <= LOW;
		case (fsm_state)
			STATE_IDLE: begin
				//if(step_sync) begin
					//if(write_cmd_reg)
						//fsm_state <= STATE_TRANSFER_CMD;
					//else

				lcd_cs <= HIGH;
				fsm_state <= STATE_TRANSFER_PIXEL;
				//end
			end
			//STATE_TRANSFER_CMD: begin
			//	bus_step <= HIGH;
			//	case (pc)
			//		8'h00:  
			//		8'h01:  {pc,command_or_data, data_to_write}     <= {pc+1,LCD_CMD,  {8'h00, cmd_in_reg}}; 
			//		8'h02:  {pc,command_or_data, data_to_write}     <= {pc+1,LCD_DATA, data_in_reg}; 
			//		8'h03:  begin //! NOP
			//				command_or_data <= LCD_CMD;
			//				data_to_write <= {8'h00, CMD_Product_ID};
			//				fsm_state <= STATE_IDLE;						
			//				end
			//		default: fsm_state <= STATE_IDLE; 
			//	endcase
			//end			
			STATE_TRANSFER_PIXEL: begin
				bus_step_reg <= LOW;
				fsm_state <= STATE_IDLE; 
			end
			STATE_TRANSFER_PIXEL_LOAD_CMD : begin
				command_or_data_reg <= LCD_CMD;
				data_to_write   <= {8'h00, CMD_Data_read_write};
				bus_step_reg <= HIGH;
				fsm_state <= STATE_TRANSFER_PIXEL_LOAD_CMD_END; 
			end 
			STATE_TRANSFER_PIXEL_LOAD_CMD_END : begin
				bus_step_reg <= LOW;
				fsm_state <= STATE_TRANSFER_PIXEL_LOAD_DATA; 
			end
			STATE_TRANSFER_PIXEL_LOAD_DATA: begin 
				command_or_data_reg <= LCD_DATA;
				data_to_write <= {16'hAABB};
				bus_step_reg <= HIGH;
				fsm_state <= STATE_TRANSFER_PIXEL_LOAD_DATA_END; 
			end
			STATE_TRANSFER_PIXEL_LOAD_DATA_END : begin
				command_or_data_reg <= LCD_CMD;
				data_to_write <= {8'h00, CMD_Product_ID};
				bus_step_reg <= LOW;
				fsm_state <= STATE_IDLE; 
			end
			STATE_INITIALIZE: begin
				lcd_cs <= LOW;
				if(init_done)
					fsm_state <= STATE_IDLE;
				else if(!lcd_init_working) begin
					lcd_init_step <= 1'b1;
				end
				if(lcd_bus_step) begin
					data_to_write <= lcd_data_to_write;
					command_or_data_reg <= lcd_command_or_data;
				end
			end
		default: fsm_state <= STATE_INITIALIZE;
		endcase
	end
end
 
assign bus_step = lcd_bus_step | bus_step_reg;
assign command_or_data = command_or_data_reg;
endmodule 


module hx8352_lcd_init( 
	input  clk,
	input  rst,
	input  step,
	output reg delay_step,
	output reg [15:0]delay_value,
	output reg command_or_data,
	output reg [15:0]data_to_write,
	output reg done,
	output reg lcd_cs,
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
;

reg enable;

always @(posedge clk or posedge rst) begin
	if (rst) begin
		enable <= 0;
	end
	else begin
		enable <= enable;
		if(step) 
			enable <= 1'b1;
		if(done) 
			enable <= 1'b0;
	end
end
wire enabled_clk;
assign enabled_clk = clk & enable; 
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
always @(posedge enabled_clk or posedge rst) begin
	if (rst) begin
		state 			<= 0;
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
		STATE_START:begin
			lcs_cs <= LOW;
			state <= STATE_LOAD_FROM_ROM;
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
				state <= STATE_TRANSFER_CMD;
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
		end
		default begin
			state <= STATE_IDLE;
		end
		endcase
	end
end


endmodule 

module init_values(
	input clk,
	input rst,
	input next,
	reg [7:0]cmd,
	reg [15:0]value,
	reg data_rdy,
	reg finish
);
localparam 
HIGH    = 1'b1,
LOW     = 1'b0,
CMD_Custom_Done								=	8'hFF,
STATE_START	= 0,
STATE_IDLE 	= 1,
STATE_LOAD	= 2,
STATE_LOADED= 3,
STATE_END 	= 0;

reg 	[]rom_address;
wire 	[]rom_cmd;
wire 	[]rom_value;
rom_init_cmd 
	rom_init_cmd_u0(
		.clk(enabled_clk),.addr(rom_address),
		.data{rom_cmd,rom_value}
	);
reg [3:0]state;
always @(posedge clk or posedge rst) begin
	if (rst) begin
		state <= STATE_START;
		data_rdy <= 0;
		finish <= 0;
	end else begin
		case begin
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
					rom_address <= rom_address+1;
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
module rom_init_cmd(
	input clk,
    input wire [7:0] addr,
    output reg [31:0] data
	);
localparam 
/* 6.1 Command set = Taken from datasheet */
CMD_Product_ID								=	8'h00,
CMD_Display_mode							=	8'h01,
CMD_Column_Address_Start_1				=	8'h02,
CMD_Column_Address_Start_2				=	8'h03,
CMD_Column_Address_End_1				=	8'h04,
CMD_Column_Address_End_2				=	8'h05,
CMD_Row_Address_Start_1					=	8'h06,
CMD_Row_Address_Start_2					=	8'h07,
CMD_Row_Address_End_1					=	8'h08,
CMD_Row_Address_End_2					=	8'h09,
CMD_Partial_Area_Start_Row_1			=	8'h0a,
CMD_Partial_Area_Start_Row_2			=	8'h0b,
CMD_Partial_Area_End_Row_1				=	8'h0c,
CMD_Partial_Area_End_Row_2				=	8'h0d,
CMD_Vertical_Scroll_Top_Fixed_Area_1=	8'h0e,
CMD_Vertical_Scroll_Top_Fixed_Area_2=	8'h0f,
CMD_Vertical_Scroll_Height_Area_1	=	8'h10,
CMD_Vertical_Scroll_Height_Area_2	=	8'h11,
CMD_Vertical_Scroll_Button_Fixed_1	=	8'h12,
CMD_Vertical_Scroll_Button_Fixed_2	=	8'h13,
CMD_Vertical_Scroll_Start_Address_1	=	8'h14,
CMD_Vertical_Scroll_Start_Address_2	=	8'h15,
CMD_Memory_Access_Control				=	8'h16,
CMD_OSC_Control_1							=	8'h17,
CMD_OSC_Control_2							=	8'h18,
CMD_Power_Control_1						=	8'h19,
CMD_Power_Control_2						=	8'h1a,
CMD_Power_Control_3						=	8'h1b,
CMD_Power_Control_4						=	8'h1c,
CMD_Power_Control_5						=	8'h1d,
CMD_Power_Control_6						=	8'h1e,
CMD_VCOM_Control							=	8'h1f,
CMD_Data_read_write						=	8'h22,
CMD_Display_Control_1					=	8'h23,
CMD_Display_Control_2					=	8'h24,
CMD_Display_Control_3					=	8'h25,
CMD_Display_Control_4					=	8'h26,
CMD_Display_Control_5					=	8'h27,
CMD_Display_Control_6					=	8'h28,
CMD_Display_Control_7					=	8'h29,
CMD_Display_Control_8					=	8'h2a,
CMD_Cycle_Control_1						=	8'h2b,
CMD_Cycle_Control_2						=	8'h2c,
CMD_Cycle_Control_3						=	8'h2d,
CMD_Cycle_Control_4						=	8'h2e,
CMD_Cycle_Control_5						=	8'h2f,
CMD_Cycle_Control_6						=	8'h30,
CMD_Cycle_Control_7						=	8'h31,
CMD_Cycle_Control_8						=	8'h32,
CMD_Cycle_Control_10						=	8'h34,
CMD_Cycle_Control_11						=	8'h35,
CMD_Cycle_Control_12						=	8'h36,
CMD_Cycle_Control_13						=	8'h37,
CMD_Cycle_Control_14						=	8'h38,
CMD_Cycle_Control_15						=	8'h39,
CMD_Interface_Control_1					=	8'h3a,
CMD_Source_Control_1						=	8'h3c,
CMD_Source_Control_2						=	8'h3d,
CMD_Gamma_Control_1						=	8'h3e,
CMD_Gamma_Control_2						=	8'h3f,
CMD_Gamma_Control_3						=	8'h40,
CMD_Gamma_Control_4						=	8'h41,
CMD_Gamma_Control_5						=	8'h42,
CMD_Gamma_Control_6						=	8'h43,
CMD_Gamma_Control_7						=	8'h44,
CMD_Gamma_Control_8						=	8'h45,
CMD_Gamma_Control_9						=	8'h46,
CMD_Gamma_Control_10						=	8'h47,
CMD_Gamma_Control_11						=	8'h48,
CMD_Gamma_Control_12						=	8'h49,
CMD_PANEL_Control							=	8'h55,
CMD_OTP_1									=	8'h56,
CMD_OTP_2									=	8'h57,
CMD_OTP_3									=	8'h58,
CMD_OTP_4									=	8'h59,
CMD_IP_Control								=	8'h5a,
CMD_DGC_LUT_WRITE							=	8'h5c,
CMD_DATA_Control							=	8'h5d,
CMD_Test_Mode								=	8'h83,
CMD_VDDD_control							=	8'h85,
CMD_Powr_driving_Control				=	8'h8A,
CMD_VGS_RES_control_1					=	8'h8B,
CMD_VGS_RES_control_2					=	8'h8C,
CMD_PWM_Control_0							=	8'h91,
CMD_PWM_Control_1							=	8'h95,
CMD_PWM_Control_2							=	8'h96,
CMD_PWM_Control_3							=	8'h97,
CMD_CABC_Period_Control_1				=	8'h6B,
CMD_CABC_Period_Control_2				=	8'h6C,
CMD_CABC_Gain1								=	8'h6F,
CMD_CABC_Gain2								=	8'h70,
CMD_CABC_Gain3								=	8'h71,
CMD_CABC_Gain4								=	8'h72,
CMD_CABC_Gain5								=	8'h73,
CMD_CABC_Gain6								=	8'h74,
CMD_CABC_Gain7								=	8'h75,
CMD_CABC_Gain8								=	8'h76,
CMD_CABC_Gain9								=	8'h77,
CMD_Custom_Delay							=	8'hFE,
CMD_Custom_Done								=	8'hFF;

// {CMD_TO_WRITE,DATA_TO_WRITE}
reg [7:0] rom [31:0];

always @(posedge clk)
	data <= rom[addr];


initial begin
    rom[] = {CMD_Test_Mode				,16'h02}; //TESTM=1 
    rom[] = {CMD_VDDD_control			,16'h03}; //VDC_SEL=011
    rom[] = {CMD_VGS_RES_control_1		,16'h01}; //STBA[7]=1,STBA[5:4]=01,STBA[1:0]=11
    rom[] = {CMD_VGS_RES_control_2		,16'h93};
    rom[] = {CMD_PWM_Control_0			,16'h01}; //DCDC_SYNC=1
    rom[] = {CMD_Test_Mode				,16'h00}; //TESTM=0
    rom[] = {CMD_Gamma_Control_1		,16'hB0}; //Gamma Setting
    rom[] = {CMD_Gamma_Control_2		,16'h03};
    rom[] = {CMD_Gamma_Control_3		,16'h10}; 
    rom[] = {CMD_Gamma_Control_5		,16'h13};
    rom[] = {CMD_Gamma_Control_6		,16'h46}};
    rom[] = {CMD_Gamma_Control_7		,16'h23};
    rom[] = {CMD_Gamma_Control_8		,16'h76}; 
    rom[] = {CMD_Gamma_Control_9		,16'h00};
    rom[] = {CMD_Gamma_Control_10		,16'h5E};
    rom[] = {CMD_Gamma_Control_11		,16'h4F};
    rom[] = {CMD_Gamma_Control_12		,16'h40};
	rom[] = {CMD_OSC_Control_1			,16'h91};//**********Power On sequence************
	rom[] = {CMD_Cycle_Control_1		,16'hF9};
	rom[] = {CMD_Custom_Delay			,16'd10_000}; // 10ms delay
	rom[] = {CMD_Power_Control_3		,16'h14};
	rom[] = {CMD_Power_Control_2		,16'h11};
	rom[] = {CMD_Power_Control_4		,16'h06};// 0d
	rom[] = {CMD_VCOM_Control			,16'h42};
	rom[] = {CMD_Custom_Delay			,16'd20_000};//20ms delay
	rom[] = {CMD_Power_Control_1		,16'h0A};
	rom[] = {CMD_Power_Control_1		,16'h1A};
	rom[] = {CMD_Custom_Delay			,16'd60_000};//60ms delay
	rom[] = {CMD_Power_Control_1		,16'h12};
	rom[] = {CMD_Custom_Delay			,16'd40_000};//40ms delay
	rom[] = {CMD_Power_Control_6		,16'h27};
	rom[] = {CMD_Custom_Delay			,16'd60_000};//60ms delay
	rom[] = {CMD_Display_Control_2		,16'h60};//**********DISPLAY ON SETTING***********
	rom[] = {CMD_Source_Control_2		,16'h40};
	rom[] = {CMD_Cycle_Control_10		,16'h38};
	rom[] = {CMD_Cycle_Control_11		,16'h38};
	rom[] = {CMD_Display_Control_2		,16'h38};
	rom[] = {CMD_Custom_Delay			,16'd40_000};//40ms delay
	rom[] = {CMD_Display_Control_2		,16'h3C};
	rom[] = {CMD_Memory_Access_Control	,16'h1C};
	rom[] = {CMD_Display_mode			,16'h06};
	rom[] = {CMD_PANEL_Control			,16'h00};
	rom[] = {CMD_Column_Address_Start_1	,16'h00};
	rom[] = {CMD_Column_Address_Start_2	,16'h00};
	rom[] = {CMD_Column_Address_End_1	,16'h00};
	rom[] = {CMD_Column_Address_End_2	,16'hEF};
	rom[] = {CMD_Row_Address_Start_1	,16'h00};
	rom[] = {CMD_Row_Address_Start_2	,16'h00};
	rom[] = {CMD_Row_Address_End_1		,16'h01};
	rom[] = {CMD_Row_Address_End_2		,16'h8F};
	rom[] = {CMD_Custom_Done		,16'h00};
   end
