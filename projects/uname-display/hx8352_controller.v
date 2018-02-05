module hx8352_controller
(
	input  clk,
	input  rst,
	input  step,
	input  write_cmd,
	input  [7:0] cmd_in,
	input  [15:0] data_in,	
	
	output busy,
	output [15:0] data_output,
	output lcd_rs,
	output lcd_wr,
	output lcd_rd,
	output lcd_rst,
	output lcd_cs,
	output [15:0]debug_instruction_step
);	
	reg  [15:0] data_to_write;
	reg  command_to_write;
	wire  transfer_step;
	wire  lcd_rst_done;
	wire  bus_busy;
	
	localparam 
        LCD_CMD    = 1'b0,
        LCD_DATA   = 1'b1;
    /* 6.1 Command set = Taken from datasheet */
	localparam	
			CMD_Product_ID						=	8'h00,
			CMD_Display_mode					=	8'h01,
			CMD_Column_Address_Start_1			=	8'h02,
			CMD_Column_Address_Start_2			=	8'h03,
			CMD_Column_Address_End_1			=	8'h04,
			CMD_Column_Address_End_2			=	8'h05,
			CMD_Row_Address_Start_1				=	8'h06,
			CMD_Row_Address_Start_2				=	8'h07,
			CMD_Row_Address_End_1				=	8'h08,
			CMD_Row_Address_End_2				=	8'h09,
			CMD_Partial_Area_Start_Row_1		=	8'h0a,
			CMD_Partial_Area_Start_Row_2		=	8'h0b,
			CMD_Partial_Area_End_Row_1			=	8'h0c,
			CMD_Partial_Area_End_Row_2			=	8'h0d,
			CMD_Vertical_Scroll_Top_Fixed_Area_1=	8'h0e,
			CMD_Vertical_Scroll_Top_Fixed_Area_2=	8'h0f,
			CMD_Vertical_Scroll_Height_Area_1	=	8'h10,
			CMD_Vertical_Scroll_Height_Area_2	=	8'h11,
			CMD_Vertical_Scroll_Button_Fixed_1	=	8'h12,
			CMD_Vertical_Scroll_Button_Fixed_2	=	8'h13,
			CMD_Vertical_Scroll_Start_Address_1	=	8'h14,
			CMD_Vertical_Scroll_Start_Address_2	=	8'h15,
			CMD_Memory_Access_Control			=	8'h16,
			CMD_OSC_Control_1					=	8'h17,
			CMD_OSC_Control_2					=	8'h18,
			CMD_Power_Control_1					=	8'h19,
			CMD_Power_Control_2					=	8'h1a,
			CMD_Power_Control_3					=	8'h1b,
			CMD_Power_Control_4					=	8'h1c,
			CMD_Power_Control_5					=	8'h1d,
			CMD_Power_Control_6					=	8'h1e,
			CMD_VCOM_Control					=	8'h1f,
			CMD_Data_read_write					=	8'h22,
			CMD_Display_Control_1				=	8'h23,
			CMD_Display_Control_2				=	8'h24,
			CMD_Display_Control_3				=	8'h25,
			CMD_Display_Control_4				=	8'h26,
			CMD_Display_Control_5				=	8'h27,
			CMD_Display_Control_6				=	8'h28,
			CMD_Display_Control_7				=	8'h29,
			CMD_Display_Control_8				=	8'h2a,
			CMD_Cycle_Control_1					=	8'h2b,
			CMD_Cycle_Control_2					=	8'h2c,
			CMD_Cycle_Control_3					=	8'h2d,
			CMD_Cycle_Control_4					=	8'h2e,
			CMD_Cycle_Control_5					=	8'h2f,
			CMD_Cycle_Control_6					=	8'h30,
			CMD_Cycle_Control_7					=	8'h31,
			CMD_Cycle_Control_8					=	8'h32,
			CMD_Cycle_Control_10				=	8'h34,
			CMD_Cycle_Control_11				=	8'h35,
			CMD_Cycle_Control_12				=	8'h36,
			CMD_Cycle_Control_13				=	8'h37,
			CMD_Cycle_Control_14				=	8'h38,
			CMD_Cycle_Control_15				=	8'h39,
			CMD_Interface_Control_1				=	8'h3a,
			CMD_Source_Control_1				=	8'h3c,
			CMD_Source_Control_2				=	8'h3d,
			CMD_Gamma_Control_1					=	8'h3e,
			CMD_Gamma_Control_2					=	8'h3f,
			CMD_Gamma_Control_3					=	8'h40,
			CMD_Gamma_Control_4					=	8'h41,
			CMD_Gamma_Control_5					=	8'h42,
			CMD_Gamma_Control_6					=	8'h43,
			CMD_Gamma_Control_7					=	8'h44,
			CMD_Gamma_Control_8					=	8'h45,
			CMD_Gamma_Control_9					=	8'h46,
			CMD_Gamma_Control_10				=	8'h47,
			CMD_Gamma_Control_11				=	8'h48,
			CMD_Gamma_Control_12				=	8'h49,
			CMD_PANEL_Control					=	8'h55,
			CMD_OTP_1							=	8'h56,
			CMD_OTP_2							=	8'h57,
			CMD_OTP_3							=	8'h58,
			CMD_OTP_4							=	8'h59,
			CMD_IP_Control						=	8'h5a,
			CMD_DGC_LUT_WRITE					=	8'h5c,
			CMD_DATA_Control					=	8'h5d,
			CMD_Test_Mode						=	8'h83,
			CMD_VDDD_control					=	8'h85,
			CMD_Powr_driving_Control			=	8'h8A,
			CMD_VGS_RES_control_1				=	8'h8B,
			CMD_VGS_RES_control_2				=	8'h8C,
			CMD_PWM_Control_0					=	8'h91,
			CMD_PWM_Control_1					=	8'h95,
			CMD_PWM_Control_2					=	8'h96,
			CMD_PWM_Control_3					=	8'h97,
			CMD_CABC_Period_Control_1			=	8'h6B,
			CMD_CABC_Period_Control_2			=	8'h6C,
			CMD_CABC_Gain1						=	8'h6F,
			CMD_CABC_Gain2						=	8'h70,
			CMD_CABC_Gain3						=	8'h71,
			CMD_CABC_Gain4						=	8'h72,
			CMD_CABC_Gain5						=	8'h73,
			CMD_CABC_Gain6						=	8'h74,
			CMD_CABC_Gain7						=	8'h75,
			CMD_CABC_Gain8						=	8'h76,
			CMD_CABC_Gain9						=	8'h77;    
        
        
	hx8352_reset_generator
		hx8352_reset_generator_unit
		(
			.clk(clk),
			.rst(rst),
			.lcd_rst(lcd_rst),
			.lcd_rst_done(lcd_rst_done)
		);

	hx8352_controller_bus_controller 
		hx8352_controller_bus_controller_unit
		(
			.clk(clk),
			.rst(~lcd_rst_done),
			.data_input(data_to_write),
			.data_command(command_to_write),
			.transfer_step(transfer_step),
			.busy(bus_busy),
			.data_output(data_output),
			.lcd_rs(lcd_rs),
			.lcd_wr(lcd_wr),
			.lcd_rd(lcd_rd)
		);
	assign busy = bus_busy & ~lcd_rst_done;
	
	wire init_commands_clk;
	reg enable_load_reg;	
	
	always @(posedge clk or posedge rst)
	begin
		if(rst) begin
			enable_load_reg <= 0;
			data_in_reg <= 0;
		end
		else begin
			enable_load_reg <= init_commands_clk;
		end
	end
	
	assign init_commands_clk = ~enable_load_reg;
	
	
	
	wire  step_sync;
	reg   step_reg;	
	reg   write_cmd_reg;
	reg  [7:0] cmd_in_reg;
	reg  [15:0] data_in_reg;
	
	always @(posedge init_commands_clk or posedge init_commands_reset)
	begin
		if(init_commands_reset) begin
			step_reg <= 0;
			cmd_in_reg <= 0;
			data_in_reg <= 0;
			write_cmd_reg <= 0;
		end
		else begin
			step_reg <= step;
			cmd_in_reg <= cmd_in;
			data_in_reg <= data_in;
			write_cmd_reg <= write_cmd;
		end
	end
	
	assign step_sync = step & ~step_reg;	
	
	reg [7:0] delay_value;
	reg delay_step;
	wire delay_done;
    hx8352_delay_ms
	   hx8352_delay_ms_unit
	   (
		.clk(clk),
		.rst(rst),
		.step(delay_step),
		.delay_ms(delay_value),
		.done(delay_done)
	   );
	localparam 
		HIGH    = 1'b1,
		LOW     = 1'b0,
		STATE_INITIALIZE	= 3'b000,
		STATE_IDLE			= 3'b001,
		STATE_TRANSFER_CMD 	= 3'b010,
		STATE_TRANSFER_PIXEL= 3'b011;
	
	wire        init_commands_reset;
	reg         cs_reg;
    reg 		enable_load_reg;
    reg  [2:0]  state;
	reg  [7:0] instruction_step;
    wire [7:0] instruction_step_next;
    
    assign init_commands_reset = rst | ~lcd_rst_done;
	assign instruction_step_next = instruction_step + 1;
    
    always @(posedge init_commands_clk or posedge init_commands_reset) begin
        if (init_commands_reset) begin
            instruction_step <= 8'b0;
            data_to_write <= 16'h0;
            enable_load_reg <= 0;
            delay_step <= 0;
            delay_value <= 8'h0;
            cs_reg <= 1;
            state <= STATE_INITIALIZE;
        end else begin
        
			if(delay_done) begin
				enable_load_reg <= ~enable_load_reg;
				cs_reg <= cs_reg;
			end else begin
				enable_load_reg <= enable_load_reg;
				delay_step <= 0;
				cs_reg <= HIGH;
			end
			
			case (state) begin
				STATE_IDLE: begin
					if(step_sync) begin
						if(write_cmd_reg) begin 
							state <= STATE_TRANSFER_CMD;
						end 
						else begin
							state <= STATE_TRANSFER_PIXEL;						
						end
					end
				end
				STATE_TRANSFER_CMD:begin
				
				end			
				STATE_TRANSFER_PIXEL:begin
				
				end
				STATE_INITIALIZE: begin
					if (enable_load_reg & delay_done) begin
						case (instruction_step)
							32'h0001:  {cs_reg, instruction_step}     <= {LOW, 16'h000F};
							32'h000F:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Test_Mode}};
							32'h0010:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h02}};//TESTM=1 
							32'h0012:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_VDDD_control}};
							32'h0013:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h03}};//VDC_SEL=011
							32'h0014:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_VGS_RES_control_1}};
							32'h0015:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h01}};
							32'h0016:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_VGS_RES_control_2}};
							32'h0017:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h93}};//STBA[7]=1,STBA[5:4]=01,STBA[1:0]=11
							32'h0018:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_PWM_Control_0}};
							32'h0019:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h01}};//DCDC_SYNC=1
							32'h001a:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Test_Mode}};
							32'h001b:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h00}}; //TESTM=0
							32'h001c:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Gamma_Control_1}};//Gamma Setting
							32'h001d:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'hB0}};
							32'h001e:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Gamma_Control_2}};
							32'h001f:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h03}};
							32'h0020:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Gamma_Control_3}};
							32'h0021:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h10}};
							32'h0022:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Gamma_Control_5}};
							32'h0023:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h13}};
							32'h0024:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Gamma_Control_6}};
							32'h0025:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h46}};
							32'h0026:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Gamma_Control_7}};
							32'h0027:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h23}};
							32'h0028:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Gamma_Control_8}};
							32'h0029:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h76}};
							32'h002a:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Gamma_Control_9}};
							32'h002b:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h00}};
							32'h002c:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Gamma_Control_10}};
							32'h002d:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h5E}};
							32'h002e:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Gamma_Control_11}};
							32'h002f:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h4F}};
							32'h0030:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Gamma_Control_12}};
							32'h0031:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h40}};
							32'h0032:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00,CMD_OSC_Control_1}};//**********Power On sequence************
							32'h0033:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h91}};
							32'h0034:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Cycle_Control_1}};
							32'h0035:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'hF9}};
							32'h0036:  {delay_step,  delay_value}     <= {1'b1, 8'd10};//! Delay 10 ms
							32'h0037:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Power_Control_3}};
							32'h0038:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h14}};
							32'h0039:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Power_Control_2}};
							32'h003a:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h11}};
							32'h003b:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Power_Control_4}};
							32'h003c:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h06}}; // 0d
							32'h003e:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_VCOM_Control}};
							32'h003f:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h42}};
							32'h0040:  {delay_step,  delay_value}     <= {1'b1, 8'd20};//! Delay 20 ms
							32'h0041:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Power_Control_1}};
							32'h0042:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h0A}};
							32'h0043:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Power_Control_1}};
							32'h0044:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h1A}};
							32'h0045:  {delay_step,  delay_value}     <= {1'b1, 8'd40};//! Delay 40 ms
							32'h0046:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Power_Control_1}};
							32'h0047:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h12}};
							32'h0048:  {delay_step,  delay_value}     <= {1'b1, 8'd40};//! Delay 40 ms
							32'h0049:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Power_Control_6}};
							32'h004a:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h27}};
							32'h004b:  {delay_step,  delay_value}     <= {1'b1, 8'd100};//! Delay 100 ms
							32'h004c:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Display_Control_2}};//**********DISPLAY ON SETTING***********
							32'h004d:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h60}};					
							32'h004e:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Source_Control_2}};
							32'h004f:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h40}};					
							32'h0050:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Cycle_Control_10}};
							32'h0051:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h38}};					
							32'h0052:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Cycle_Control_11}};
							32'h0053:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h38}};					
							32'h0054:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Display_Control_2}};
							32'h0055:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h38}};
							32'h0056:  {delay_step,  delay_value}     <= {1'b1, 8'd40};//! Delay 40 ms					
							32'h0057:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Display_Control_2}};
							32'h0058:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h3C}};					
							32'h0059:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Memory_Access_Control}};
							32'h005a:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h1C}};					
							32'h005b:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Display_mode}};
							32'h005c:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h06}};					
							32'h005e:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_PANEL_Control}};
							32'h005f:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h00}};					
							32'h0060:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Column_Address_Start_1}};
							32'h0061:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h00}};
							32'h0062:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Column_Address_Start_2}};
							32'h0063:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h00}};
							32'h0064:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Column_Address_End_1}};
							32'h0065:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h00}};
							32'h0066:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Column_Address_End_2}};
							32'h0067:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'hEF}};					
							32'h0068:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Row_Address_Start_1}};
							32'h0069:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h00}};
							32'h006a:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Row_Address_Start_2}};
							32'h006b:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h00}};
							32'h006c:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Row_Address_End_1}};
							32'h006d:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h01}};
							32'h006e:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Row_Address_End_2}};
							32'h006f:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h8F}};					
							32'h0070:  {cs_reg, command_to_write, data_to_write, state}     <= {HIGH, LCD_CMD,  {8'h00, CMD_Product_ID}, STATE_IDLE}; //! NOP
						endcase
					
					end	else begin
						cs_reg <= cs_reg;						
					end
				end
			end
			
			if(delay_done) begin
				instruction_step <= instruction_step_next;
			end else begin
				instruction_step <= instruction_step;
			end
        end
    end
    
    assign transfer_step = enable_load_reg & delay_done & ~delay_step;
	assign debug_instruction_step = instruction_step;
	assign lcd_cs = cs_reg;
endmodule
/*
//! Initialization done 
32'h0071:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Column_Address_Start_2}};	// set scan mode xstart xend				
32'h0072:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h00}};  // x0 L
32'h0073:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Row_Address_Start_1}};  
32'h0074:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h00}};  // y0 H
32'h0075:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Row_Address_Start_2}};  
32'h0076:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h00}};  // y0 L
32'h0078:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Column_Address_End_2}};   
32'h0079:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'hEF}};  // x1  
32'h007a:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Row_Address_End_1}};  
32'h007b:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h01}};  // y1 H
32'h007c:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Row_Address_End_2}}; 
32'h008d:  {command_to_write, data_to_write}     <= {LCD_DATA, {8'h00, 8'h8F}};  // y1 L
32'h008e:  {command_to_write, data_to_write}     <= {LCD_CMD,  {8'h00, CMD_Data_read_write}}; 
*/


