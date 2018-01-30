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
		localparam RESET_COUTER_VALUE = 100_000;
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
	input  clk2,
	input  rst,
		
	output busy,
	output [15:0] data_output,
	output lcd_rs,
	output lcd_wr,
	output lcd_rd,
	output lcd_rst,
	output lcd_cs,
	output [15:0]debug_instruction_step
);
	wire clk2_ovf;
	counter	#(    .N(24),
			  .M(50)
		)
		counter_clk2
	   (
		.clk(clk2), .reset(rst),
		.max_tick(clk2_ovf),
		.q()
	   );
	wire clk;
	reg clk_reg;
	always @(posedge clk2_ovf or posedge rst)
	begin
		if(rst)
			clk_reg <= 0;
		else
			clk_reg <= clk;
	end
	
	
	`ifdef SIMULATION
		assign clk = clk2;
	`else
		assign clk = ~clk2;
	`endif
	
	
	reg  [15:0] data_input;
	reg  data_command;
	wire  transfer_step;
	wire  lcd_rst_done;
	
	localparam 
        LCD_CMD    = 1'b0,
        LCD_DATA   = 1'b1;
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
	counter	#(    .N(24),
			  .M(100)
		)
		counter_reset_generator_unit 
	   (
		.clk(clk), .reset(rst),
		.max_tick(init_commands_clk),
		.q()
	   );
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
    reg  [7:0]  counter_value;
	reg  [15:0] instruction_step;
    wire [15:0] instruction_step_next;
    
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
				counter_value <= counter_value + 1;
				cs_reg <= cs_reg;
			end else begin
				counter_value <= counter_value;
				delay_step <= 0;
				cs_reg <= 1;
			end
			
			
			enable_transfer <= enable_transfer;
			if (counter_value[0] & delay_done) begin
				case (instruction_step)
					16'h0001:  {cs_reg, instruction_step}     <= {1'b0, 16'h000F};
					16'h000F:  {data_command, data_input}     <= {LCD_CMD,  16'h0083};
					16'h0010:  {data_command, data_input}     <= {LCD_DATA, 16'h0002};//TESTM=1 
					16'h0012:  {data_command, data_input}     <= {LCD_CMD,  16'h0085};
					16'h0013:  {data_command, data_input}     <= {LCD_DATA, 16'h0003};//VDC_SEL=011
					16'h0014:  {data_command, data_input}     <= {LCD_CMD,  16'h008B};
					16'h0015:  {data_command, data_input}     <= {LCD_DATA, 16'h0001};
					16'h0016:  {data_command, data_input}     <= {LCD_CMD,  16'h008C};
					16'h0017:  {data_command, data_input}     <= {LCD_DATA, 16'h0093};//STBA[7]=1,STBA[5:4]=01,STBA[1:0]=11
					16'h0018:  {data_command, data_input}     <= {LCD_CMD,  16'h0091};
					16'h0019:  {data_command, data_input}     <= {LCD_DATA, 16'h0001};//DCDC_SYNC=1
					16'h001a:  {data_command, data_input}     <= {LCD_CMD,  16'h0083};
					16'h001b:  {data_command, data_input}     <= {LCD_DATA, 16'h0000}; //TESTM=0
					16'h001c:  {data_command, data_input}     <= {LCD_CMD,  16'h003E};//Gamma Setting
					16'h001d:  {data_command, data_input}     <= {LCD_DATA, 16'h00B0};
					16'h001e:  {data_command, data_input}     <= {LCD_CMD,  16'h003F};
					16'h001f:  {data_command, data_input}     <= {LCD_DATA, 16'h0003};
					16'h0020:  {data_command, data_input}     <= {LCD_CMD,  16'h0040};
					16'h0021:  {data_command, data_input}     <= {LCD_DATA, 16'h0010};
					16'h0022:  {data_command, data_input}     <= {LCD_CMD,  16'h0042};
					16'h0023:  {data_command, data_input}     <= {LCD_DATA, 16'h0013};
					16'h0024:  {data_command, data_input}     <= {LCD_CMD,  16'h0043};
					16'h0025:  {data_command, data_input}     <= {LCD_DATA, 16'h0046};
					16'h0026:  {data_command, data_input}     <= {LCD_CMD,  16'h0044};
					16'h0027:  {data_command, data_input}     <= {LCD_DATA, 16'h0023};
					16'h0028:  {data_command, data_input}     <= {LCD_CMD,  16'h0045};
					16'h0029:  {data_command, data_input}     <= {LCD_DATA, 16'h0076};
					16'h002a:  {data_command, data_input}     <= {LCD_CMD,  16'h0046};
					16'h002b:  {data_command, data_input}     <= {LCD_DATA, 16'h0000};
					16'h002c:  {data_command, data_input}     <= {LCD_CMD,  16'h0047};
					16'h002d:  {data_command, data_input}     <= {LCD_DATA, 16'h005E};
					16'h002e:  {data_command, data_input}     <= {LCD_CMD,  16'h0048};
					16'h002f:  {data_command, data_input}     <= {LCD_DATA, 16'h004F};
					16'h0030:  {data_command, data_input}     <= {LCD_CMD,  16'h0049};
					16'h0031:  {data_command, data_input}     <= {LCD_DATA, 16'h0040};
					16'h0032:  {data_command, data_input}     <= {LCD_CMD,  16'h0017};//**********Power On sequence************
					16'h0033:  {data_command, data_input}     <= {LCD_DATA, 16'h0091};
					16'h0034:  {data_command, data_input}     <= {LCD_CMD,  16'h002B};
					16'h0035:  {data_command, data_input}     <= {LCD_DATA, 16'h00F9};
					16'h0036:  {delay_step,  delay_value}     <= {1'b1, 8'd10};//! Delay 10 ms
					16'h0037:  {data_command, data_input}     <= {LCD_CMD,  16'h001B};
					16'h0038:  {data_command, data_input}     <= {LCD_DATA, 16'h0014};
					16'h0039:  {data_command, data_input}     <= {LCD_CMD,  16'h001A};
					16'h003a:  {data_command, data_input}     <= {LCD_DATA, 16'h0011};
					16'h003b:  {data_command, data_input}     <= {LCD_CMD,  16'h001C};
					16'h003c:  {data_command, data_input}     <= {LCD_DATA, 16'h0006}; // 0d
					16'h003e:  {data_command, data_input}     <= {LCD_CMD,  16'h001F};
					16'h003f:  {data_command, data_input}     <= {LCD_DATA, 16'h0042};
					16'h0040:  {delay_step,  delay_value}     <= {1'b1, 8'd20};//! Delay 20 ms
					16'h0041:  {data_command, data_input}     <= {LCD_CMD,  16'h0019};
					16'h0042:  {data_command, data_input}     <= {LCD_DATA, 16'h000A};
					16'h0043:  {data_command, data_input}     <= {LCD_CMD,  16'h0019};
					16'h0044:  {data_command, data_input}     <= {LCD_DATA, 16'h001A};
					16'h0045:  {delay_step,  delay_value}     <= {1'b1, 8'd40};//! Delay 40 ms
					16'h0046:  {data_command, data_input}     <= {LCD_CMD,  16'h0019};
					16'h0047:  {data_command, data_input}     <= {LCD_DATA, 16'h0012};
					16'h0048:  {delay_step,  delay_value}     <= {1'b1, 8'd40};//! Delay 40 ms
					16'h0049:  {data_command, data_input}     <= {LCD_CMD,  16'h001E};
					16'h004a:  {data_command, data_input}     <= {LCD_DATA, 16'h0027};
					16'h004b:  {delay_step,  delay_value}     <= {1'b1, 8'd100};//! Delay 100 ms
					16'h004c:  {data_command, data_input}     <= {LCD_CMD,  16'h0024};//**********DISPLAY ON SETTING***********
					16'h004d:  {data_command, data_input}     <= {LCD_DATA, 16'h0060};					
					16'h004e:  {data_command, data_input}     <= {LCD_CMD,  16'h003D};
					16'h004f:  {data_command, data_input}     <= {LCD_DATA, 16'h0040};					
					16'h0050:  {data_command, data_input}     <= {LCD_CMD,  16'h0034};
					16'h0051:  {data_command, data_input}     <= {LCD_DATA, 16'h0038};					
					16'h0052:  {data_command, data_input}     <= {LCD_CMD,  16'h0035};
					16'h0053:  {data_command, data_input}     <= {LCD_DATA, 16'h0038};					
					16'h0054:  {data_command, data_input}     <= {LCD_CMD,  16'h0024};
					16'h0055:  {data_command, data_input}     <= {LCD_DATA, 16'h0038};
					16'h0056:  {delay_step,  delay_value}     <= {1'b1, 8'd40};//! Delay 40 ms					
					16'h0057:  {data_command, data_input}     <= {LCD_CMD,  16'h0024};
					16'h0058:  {data_command, data_input}     <= {LCD_DATA, 16'h003C};					
					16'h0059:  {data_command, data_input}     <= {LCD_CMD,  16'h0016};
					16'h005a:  {data_command, data_input}     <= {LCD_DATA, 16'h001C};					
					16'h005b:  {data_command, data_input}     <= {LCD_CMD,  16'h0001};
					16'h005c:  {data_command, data_input}     <= {LCD_DATA, 16'h0006};					
					16'h005e:  {data_command, data_input}     <= {LCD_CMD,  16'h0055};
					16'h005f:  {data_command, data_input}     <= {LCD_DATA, 16'h0000};					
					16'h0060:  {data_command, data_input}     <= {LCD_CMD,  16'h0002};
					16'h0061:  {data_command, data_input}     <= {LCD_DATA, 16'h0000};
					16'h0062:  {data_command, data_input}     <= {LCD_CMD,  16'h0003};
					16'h0063:  {data_command, data_input}     <= {LCD_DATA, 16'h0000};
					16'h0064:  {data_command, data_input}     <= {LCD_CMD,  16'h0004};
					16'h0065:  {data_command, data_input}     <= {LCD_DATA, 16'h0000};
					16'h0066:  {data_command, data_input}     <= {LCD_CMD,  16'h0005};
					16'h0067:  {data_command, data_input}     <= {LCD_DATA, 16'h00EF};					
					16'h0068:  {data_command, data_input}     <= {LCD_CMD,  16'h0006};
					16'h0069:  {data_command, data_input}     <= {LCD_DATA, 16'h0000};
					16'h006a:  {data_command, data_input}     <= {LCD_CMD,  16'h0007};
					16'h006b:  {data_command, data_input}     <= {LCD_DATA, 16'h0000};
					16'h006c:  {data_command, data_input}     <= {LCD_CMD,  16'h0008};
					16'h006d:  {data_command, data_input}     <= {LCD_DATA, 16'h0001};
					16'h006e:  {data_command, data_input}     <= {LCD_CMD,  16'h0009};
					16'h006f:  {data_command, data_input}     <= {LCD_DATA, 16'h008F};					
					16'h0070:  {data_command, data_input}     <= {LCD_CMD,  16'h0022};
					16'h0071:  {data_command, data_input}     <= {LCD_CMD,  16'h0001};					
					16'h0072:  {data_command, data_input}     <= {LCD_CMD,  16'h002A}; // set scan mode xstart xend
					16'h0073:  {data_command, data_input}     <= {LCD_DATA, 16'h0000}; // start x
					16'h0074:  {data_command, data_input}     <= {LCD_DATA, 16'h0000}; // start x
					16'h0075:  {data_command, data_input}     <= {LCD_DATA, 16'h0000}; // end x
					16'h0076:  {data_command, data_input}     <= {LCD_DATA, 16'h00EF}; // end x 239					
					16'h0078:  {data_command, data_input}     <= {LCD_CMD,  16'h002B}; // set scan mode ystart yend
					16'h0079:  {data_command, data_input}     <= {LCD_DATA, 16'h0000}; // start y 
					16'h007a:  {data_command, data_input}     <= {LCD_DATA, 16'h0000}; // start y
					16'h007e:  {data_command, data_input}     <= {LCD_DATA, 16'h0001}; // end y
					16'h007f:  {data_command, data_input}     <= {LCD_DATA, 16'h008F}; // end y				
					16'h0080:  {data_command, data_input}     <= {LCD_CMD,  16'h002C};
					
					//16'h0081:  {data_command, data_input}     <= {LCD_DATA, 16'hAAAA};
					//16'h0082:  {data_command, data_input}     <= {LCD_DATA, 16'hAAAA};
					//16'h0083:  {data_command, data_input}     <= {LCD_DATA, 16'hAAAA};
					//16'h0084:  {data_command, data_input}     <= {LCD_DATA, 16'hAAAA};
					//16'h0085:  {data_command, data_input}     <= {LCD_DATA, 16'hAAAA};
					//16'h0086:  {data_command, data_input}     <= {LCD_DATA, 16'hAAAA};
					//16'h0087:  {data_command, data_input}     <= {LCD_DATA, 16'hAAAA};
					//16'h0088:  {data_command, data_input}     <= {LCD_DATA, 16'hAAAA}; 
					//16'h0089:  {data_command, data_input}     <= {LCD_DATA, 16'hAAAA}; 
					//16'h008a:  {data_command, data_input}     <= {LCD_DATA, 16'hAAAA}; 
					//16'h008b:  {data_command, data_input}     <= {LCD_DATA, 16'hAAAA}; 
					//16'h008c:  {data_command, data_input}     <= {LCD_DATA, 16'hAAAA}; 
					//16'h008d:  {data_command, data_input}     <= {LCD_DATA, 16'hAAAA}; 
					//16'h008e:  {data_command, data_input}     <= {LCD_DATA, 16'hAAAA}; 
					//16'h008f:  {data_command, data_input}     <= {LCD_DATA, 16'hAAAA}; 
				
					//16'h0078:  {data_command, data_input}     <= {LCD_CMD,  16'h002C};
					//Lcd_Write_Com(0x00,0x2a);
					//Lcd_Write_Data(0x00,x1>>8);	    //start X
					//Lcd_Write_Data(0x00,x1);	    //start X
					//Lcd_Write_Data(0x00,x2>>8);	    //end X
					//Lcd_Write_Data(0x00,x2);	    //end X
					//Lcd_Write_Com(0x00,0x2b);
					//Lcd_Write_Data(0x00,y1>>8);	    //start Y
					//Lcd_Write_Data(0x00,y1);	    //start Y
					//Lcd_Write_Data(0x00,y2>>8);	    //end Y
					//Lcd_Write_Data(0x00,y2);	    //end Y
					//Lcd_Write_Com(0x00,0x2c); 			
					
					
					16'h0090:  {cs_reg, enable_transfer} <= {1'b1 , 1'b0};
					16'h0091:  {data_command, instruction_step} <= {HIGH, 16'h0090};
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
    
    assign transfer_step = counter_value[0] & enable_transfer & delay_done & ~delay_step;
	assign debug_instruction_step = instruction_step;
	assign lcd_cs = cs_reg;
endmodule



