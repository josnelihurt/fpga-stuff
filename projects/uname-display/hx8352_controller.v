module hx8352_delay_ms
(
	input  clk,
	input  rst,
	input  step,
	input  [7:0] delay_ms,
	output done
);
	wire base_tick;
	reg  done_reg;
	wire step_sync;
	reg  [7:0] counter_ms;
	
	reg   step_reg;
	always @ (posedge clk or posedge rst) 
	begin
		if(rst)
			step_reg <= 0;
		else
			step_reg <= step;
	end
	assign step_sync = step & ~step_reg;
	
	`ifdef SIMULATION
		localparam RESET_COUTER_VALUE = 100;
	`else
		localparam RESET_COUTER_VALUE = 500_000;
	`endif
	
	counter	#(    .N(24),
				  .M(RESET_COUTER_VALUE)
			)
		counter_base_unit 
	   (
		.clk(clk), .reset(done_reg | rst),
		.max_tick(base_tick),
		.q()
	   );
   always @(posedge base_tick or posedge step_sync or posedge rst)
    begin
		if (rst) begin
			done_reg <= 1;
			counter_ms <= 0;
		end
        else if (step_sync) begin
			done_reg <= 0;
			counter_ms <= 0;
        end
        else begin
			if(counter_ms < delay_ms) begin
				counter_ms <= counter_ms + 1;
				done_reg <= 0;
			end else begin
				counter_ms <= counter_ms;
				done_reg <= 1;
			end
        end
    end
    
	assign done = done_reg;
endmodule

module hx8352_controller
(
	input  clk,
	input  rst,
	input  [15:0] color,	
	
	output busy,
	output [15:0] data_output,
	output lcd_rs,
	output lcd_wr,
	output lcd_rd,
	output lcd_rst,
	output lcd_cs,
	output [15:0]debug_instruction_step
);	
	reg  [15:0] data_input;
	reg  data_command;
	wire  transfer_step;
	wire  lcd_rst_done;
	
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
			.data_input(data_input),
			.data_command(data_command),
			.transfer_step(transfer_step),
			.busy(busy),
			.data_output(data_output),
			.lcd_rs(lcd_rs),
			.lcd_wr(lcd_wr),
			.lcd_rd(lcd_rd)
		);
		
	
	wire init_commands_clk;
	reg init_commands_clk_reg;
	always @(posedge clk or posedge rst)
	begin
		if(rst)
			init_commands_clk_reg <= 0;
		else
			init_commands_clk_reg <= init_commands_clk;
	end
	
	assign init_commands_clk = ~init_commands_clk_reg;
	
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
		START_LINE = 222;
	
	wire        init_commands_reset;
	reg         enable_transfer;
	reg         cs_reg;
    reg  counter_value;
	reg  [31:0] instruction_step;
    wire [31:0] instruction_step_next;
    
    assign init_commands_reset = rst | ~lcd_rst_done;
	assign instruction_step_next = instruction_step + 1;
    
    always @(posedge init_commands_clk or posedge init_commands_reset) begin
        if (init_commands_reset) begin
            instruction_step <= 6'b0;
            data_input <= 16'h0;
            counter_value <= 0;
            delay_step <= 0;
            delay_value <= 8'h0;
            enable_transfer <= 1;
            cs_reg <= 1;
        end else begin
			if(delay_done) begin
				counter_value <= ~counter_value;
				cs_reg <= cs_reg;
			end else begin
				counter_value <= counter_value;
				delay_step <= 0;
				cs_reg <= 1;
			end
			
			
			enable_transfer <= enable_transfer;
			if (counter_value & delay_done) begin
				case (instruction_step)
					32'h0001:  {cs_reg, instruction_step}     <= {1'b0, 16'h000F};
					32'h000F:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Test_Mode}};
					32'h0010:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h02}};//TESTM=1 
					32'h0012:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_VDDD_control}};
					32'h0013:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h03}};//VDC_SEL=011
					32'h0014:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_VGS_RES_control_1}};
					32'h0015:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h01}};
					32'h0016:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_VGS_RES_control_2}};
					32'h0017:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h93}};//STBA[7]=1,STBA[5:4]=01,STBA[1:0]=11
					32'h0018:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_PWM_Control_0}};
					32'h0019:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h01}};//DCDC_SYNC=1
					32'h001a:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Test_Mode}};
					32'h001b:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h00}}; //TESTM=0
					32'h001c:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Gamma_Control_1}};//Gamma Setting
					32'h001d:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'hB0}};
					32'h001e:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Gamma_Control_2}};
					32'h001f:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h03}};
					32'h0020:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Gamma_Control_3}};
					32'h0021:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h10}};
					32'h0022:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Gamma_Control_5}};
					32'h0023:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h13}};
					32'h0024:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Gamma_Control_6}};
					32'h0025:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h46}};
					32'h0026:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Gamma_Control_7}};
					32'h0027:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h23}};
					32'h0028:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Gamma_Control_8}};
					32'h0029:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h76}};
					32'h002a:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Gamma_Control_9}};
					32'h002b:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h00}};
					32'h002c:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Gamma_Control_10}};
					32'h002d:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h5E}};
					32'h002e:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Gamma_Control_11}};
					32'h002f:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h4F}};
					32'h0030:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Gamma_Control_12}};
					32'h0031:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h40}};
					32'h0032:  {data_command, data_input}     <= {LCD_CMD,  {8'h00,CMD_OSC_Control_1}};//**********Power On sequence************
					32'h0033:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h91}};
					32'h0034:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Cycle_Control_1}};
					32'h0035:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'hF9}};
					32'h0036:  {delay_step,  delay_value}     <= {1'b1, 8'd10};//! Delay 10 ms
					32'h0037:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Power_Control_3}};
					32'h0038:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h14}};
					32'h0039:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Power_Control_2}};
					32'h003a:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h11}};
					32'h003b:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Power_Control_4}};
					32'h003c:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h06}}; // 0d
					32'h003e:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_VCOM_Control}};
					32'h003f:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h42}};
					32'h0040:  {delay_step,  delay_value}     <= {1'b1, 8'd20};//! Delay 20 ms
					32'h0041:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Power_Control_1}};
					32'h0042:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h0A}};
					32'h0043:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Power_Control_1}};
					32'h0044:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h1A}};
					32'h0045:  {delay_step,  delay_value}     <= {1'b1, 8'd40};//! Delay 40 ms
					32'h0046:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Power_Control_1}};
					32'h0047:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h12}};
					32'h0048:  {delay_step,  delay_value}     <= {1'b1, 8'd40};//! Delay 40 ms
					32'h0049:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Power_Control_6}};
					32'h004a:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h27}};
					32'h004b:  {delay_step,  delay_value}     <= {1'b1, 8'd100};//! Delay 100 ms
					32'h004c:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Display_Control_2}};//**********DISPLAY ON SETTING***********
					32'h004d:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h60}};					
					32'h004e:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Source_Control_2}};
					32'h004f:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h40}};					
					32'h0050:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Cycle_Control_10}};
					32'h0051:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h38}};					
					32'h0052:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Cycle_Control_11}};
					32'h0053:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h38}};					
					32'h0054:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Display_Control_2}};
					32'h0055:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h38}};
					32'h0056:  {delay_step,  delay_value}     <= {1'b1, 8'd40};//! Delay 40 ms					
					32'h0057:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Display_Control_2}};
					32'h0058:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h3C}};					
					32'h0059:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Memory_Access_Control}};
					32'h005a:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h1C}};					
					32'h005b:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Display_mode}};
					32'h005c:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h06}};					
					32'h005e:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_PANEL_Control}};
					32'h005f:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h00}};					
					32'h0060:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Column_Address_Start_1}};
					32'h0061:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h00}};
					32'h0062:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Column_Address_Start_2}};
					32'h0063:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h00}};
					32'h0064:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Column_Address_End_1}};
					32'h0065:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h00}};
					32'h0066:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Column_Address_End_2}};
					32'h0067:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'hEF}};					
					32'h0068:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Row_Address_Start_1}};
					32'h0069:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h00}};
					32'h006a:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Row_Address_Start_2}};
					32'h006b:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h00}};
					32'h006c:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Row_Address_End_1}};
					32'h006d:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h01}};
					32'h006e:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Row_Address_End_2}};
					32'h006f:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h8F}};					
					32'h0070:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Data_read_write}};
					//! Initialization done 
					32'h0071:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Column_Address_Start_2}};	// set scan mode xstart xend				
					32'h0072:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h00}};  // x0 L
					32'h0073:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Row_Address_Start_1}};  
					32'h0074:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h00}};  // y0 H
					32'h0075:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Row_Address_Start_2}};  
					32'h0076:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h00}};  // y0 L
					32'h0078:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Column_Address_End_2}};   
					32'h0079:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'hEF}};  // x1  
					32'h007a:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Row_Address_End_1}};  
					32'h007b:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h01}};  // y1 H
					32'h007c:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Row_Address_End_2}}; 
					32'h008d:  {data_command, data_input}     <= {LCD_DATA, {8'h00, 8'h8F}};  // y1 L
					32'h008e:  {data_command, data_input}     <= {LCD_CMD,  {8'h00, CMD_Data_read_write}}; 
					
					16'h008f:  {data_command, data_input}     <= {LCD_DATA, color };
					
					//32'h0001_778f:  {cs_reg, enable_transfer} <= {1'b1 , 1'b0};
					32'h0001_7790:  {data_command, instruction_step} <= {HIGH, 32'h0071};
				endcase
			end	else begin
				cs_reg <= cs_reg;
				if(delay_done) begin
					instruction_step <= instruction_step_next;
				end else begin
					instruction_step <= instruction_step;
				end
			end
        end
    end
    
    assign transfer_step = counter_value & enable_transfer & delay_done & ~delay_step;
	assign debug_instruction_step = instruction_step;
	assign lcd_cs = cs_reg;
endmodule



