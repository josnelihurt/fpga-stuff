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
	input  [7:0] color,
	
	
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
	counter	#(    .N(3),
			  .M(4)
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
					32'h0001:  {cs_reg, instruction_step}     <= {1'b0, 16'h000F};
					32'h000F:  {data_command, data_input}     <= {LCD_CMD,  16'h0083};
					32'h0010:  {data_command, data_input}     <= {LCD_DATA, 16'h0002};//TESTM=1 
					32'h0012:  {data_command, data_input}     <= {LCD_CMD,  16'h0085};
					32'h0013:  {data_command, data_input}     <= {LCD_DATA, 16'h0003};//VDC_SEL=011
					32'h0014:  {data_command, data_input}     <= {LCD_CMD,  16'h008B};
					32'h0015:  {data_command, data_input}     <= {LCD_DATA, 16'h0001};
					32'h0016:  {data_command, data_input}     <= {LCD_CMD,  16'h008C};
					32'h0017:  {data_command, data_input}     <= {LCD_DATA, 16'h0093};//STBA[7]=1,STBA[5:4]=01,STBA[1:0]=11
					32'h0018:  {data_command, data_input}     <= {LCD_CMD,  16'h0091};
					32'h0019:  {data_command, data_input}     <= {LCD_DATA, 16'h0001};//DCDC_SYNC=1
					32'h001a:  {data_command, data_input}     <= {LCD_CMD,  16'h0083};
					32'h001b:  {data_command, data_input}     <= {LCD_DATA, 16'h0000}; //TESTM=0
					32'h001c:  {data_command, data_input}     <= {LCD_CMD,  16'h003E};//Gamma Setting
					32'h001d:  {data_command, data_input}     <= {LCD_DATA, 16'h00B0};
					32'h001e:  {data_command, data_input}     <= {LCD_CMD,  16'h003F};
					32'h001f:  {data_command, data_input}     <= {LCD_DATA, 16'h0003};
					32'h0020:  {data_command, data_input}     <= {LCD_CMD,  16'h0040};
					32'h0021:  {data_command, data_input}     <= {LCD_DATA, 16'h0010};
					32'h0022:  {data_command, data_input}     <= {LCD_CMD,  16'h0042};
					32'h0023:  {data_command, data_input}     <= {LCD_DATA, 16'h0013};
					32'h0024:  {data_command, data_input}     <= {LCD_CMD,  16'h0043};
					32'h0025:  {data_command, data_input}     <= {LCD_DATA, 16'h0046};
					32'h0026:  {data_command, data_input}     <= {LCD_CMD,  16'h0044};
					32'h0027:  {data_command, data_input}     <= {LCD_DATA, 16'h0023};
					32'h0028:  {data_command, data_input}     <= {LCD_CMD,  16'h0045};
					32'h0029:  {data_command, data_input}     <= {LCD_DATA, 16'h0076};
					32'h002a:  {data_command, data_input}     <= {LCD_CMD,  16'h0046};
					32'h002b:  {data_command, data_input}     <= {LCD_DATA, 16'h0000};
					32'h002c:  {data_command, data_input}     <= {LCD_CMD,  16'h0047};
					32'h002d:  {data_command, data_input}     <= {LCD_DATA, 16'h005E};
					32'h002e:  {data_command, data_input}     <= {LCD_CMD,  16'h0048};
					32'h002f:  {data_command, data_input}     <= {LCD_DATA, 16'h004F};
					32'h0030:  {data_command, data_input}     <= {LCD_CMD,  16'h0049};
					32'h0031:  {data_command, data_input}     <= {LCD_DATA, 16'h0040};
					32'h0032:  {data_command, data_input}     <= {LCD_CMD,  16'h0017};//**********Power On sequence************
					32'h0033:  {data_command, data_input}     <= {LCD_DATA, 16'h0091};
					32'h0034:  {data_command, data_input}     <= {LCD_CMD,  16'h002B};
					32'h0035:  {data_command, data_input}     <= {LCD_DATA, 16'h00F9};
					32'h0036:  {delay_step,  delay_value}     <= {1'b1, 8'd10};//! Delay 10 ms
					32'h0037:  {data_command, data_input}     <= {LCD_CMD,  16'h001B};
					32'h0038:  {data_command, data_input}     <= {LCD_DATA, 16'h0014};
					32'h0039:  {data_command, data_input}     <= {LCD_CMD,  16'h001A};
					32'h003a:  {data_command, data_input}     <= {LCD_DATA, 16'h0011};
					32'h003b:  {data_command, data_input}     <= {LCD_CMD,  16'h001C};
					32'h003c:  {data_command, data_input}     <= {LCD_DATA, 16'h0006}; // 0d
					32'h003e:  {data_command, data_input}     <= {LCD_CMD,  16'h001F};
					32'h003f:  {data_command, data_input}     <= {LCD_DATA, 16'h0042};
					32'h0040:  {delay_step,  delay_value}     <= {1'b1, 8'd20};//! Delay 20 ms
					32'h0041:  {data_command, data_input}     <= {LCD_CMD,  16'h0019};
					32'h0042:  {data_command, data_input}     <= {LCD_DATA, 16'h000A};
					32'h0043:  {data_command, data_input}     <= {LCD_CMD,  16'h0019};
					32'h0044:  {data_command, data_input}     <= {LCD_DATA, 16'h001A};
					32'h0045:  {delay_step,  delay_value}     <= {1'b1, 8'd40};//! Delay 40 ms
					32'h0046:  {data_command, data_input}     <= {LCD_CMD,  16'h0019};
					32'h0047:  {data_command, data_input}     <= {LCD_DATA, 16'h0012};
					32'h0048:  {delay_step,  delay_value}     <= {1'b1, 8'd40};//! Delay 40 ms
					32'h0049:  {data_command, data_input}     <= {LCD_CMD,  16'h001E};
					32'h004a:  {data_command, data_input}     <= {LCD_DATA, 16'h0027};
					32'h004b:  {delay_step,  delay_value}     <= {1'b1, 8'd100};//! Delay 100 ms
					32'h004c:  {data_command, data_input}     <= {LCD_CMD,  16'h0024};//**********DISPLAY ON SETTING***********
					32'h004d:  {data_command, data_input}     <= {LCD_DATA, 16'h0060};					
					32'h004e:  {data_command, data_input}     <= {LCD_CMD,  16'h003D};
					32'h004f:  {data_command, data_input}     <= {LCD_DATA, 16'h0040};					
					32'h0050:  {data_command, data_input}     <= {LCD_CMD,  16'h0034};
					32'h0051:  {data_command, data_input}     <= {LCD_DATA, 16'h0038};					
					32'h0052:  {data_command, data_input}     <= {LCD_CMD,  16'h0035};
					32'h0053:  {data_command, data_input}     <= {LCD_DATA, 16'h0038};					
					32'h0054:  {data_command, data_input}     <= {LCD_CMD,  16'h0024};
					32'h0055:  {data_command, data_input}     <= {LCD_DATA, 16'h0038};
					32'h0056:  {delay_step,  delay_value}     <= {1'b1, 8'd40};//! Delay 40 ms					
					32'h0057:  {data_command, data_input}     <= {LCD_CMD,  16'h0024};
					32'h0058:  {data_command, data_input}     <= {LCD_DATA, 16'h003C};					
					32'h0059:  {data_command, data_input}     <= {LCD_CMD,  16'h0016};
					32'h005a:  {data_command, data_input}     <= {LCD_DATA, 16'h001C};					
					32'h005b:  {data_command, data_input}     <= {LCD_CMD,  16'h0001};
					32'h005c:  {data_command, data_input}     <= {LCD_DATA, 16'h0006};					
					32'h005e:  {data_command, data_input}     <= {LCD_CMD,  16'h0055};
					32'h005f:  {data_command, data_input}     <= {LCD_DATA, 16'h0000};					
					32'h0060:  {data_command, data_input}     <= {LCD_CMD,  16'h0002};
					32'h0061:  {data_command, data_input}     <= {LCD_DATA, 16'h0000};
					32'h0062:  {data_command, data_input}     <= {LCD_CMD,  16'h0003};
					32'h0063:  {data_command, data_input}     <= {LCD_DATA, 16'h0000};
					32'h0064:  {data_command, data_input}     <= {LCD_CMD,  16'h0004};
					32'h0065:  {data_command, data_input}     <= {LCD_DATA, 16'h0000};
					32'h0066:  {data_command, data_input}     <= {LCD_CMD,  16'h0005};
					32'h0067:  {data_command, data_input}     <= {LCD_DATA, 16'h00EF};					
					32'h0068:  {data_command, data_input}     <= {LCD_CMD,  16'h0006};
					32'h0069:  {data_command, data_input}     <= {LCD_DATA, 16'h0000};
					32'h006a:  {data_command, data_input}     <= {LCD_CMD,  16'h0007};
					32'h006b:  {data_command, data_input}     <= {LCD_DATA, 16'h0000};
					32'h006c:  {data_command, data_input}     <= {LCD_CMD,  16'h0008};
					32'h006d:  {data_command, data_input}     <= {LCD_DATA, 16'h0001};
					32'h006e:  {data_command, data_input}     <= {LCD_CMD,  16'h0009};
					32'h006f:  {data_command, data_input}     <= {LCD_DATA, 16'h008F};					
					32'h0070:  {data_command, data_input}     <= {LCD_CMD,  16'h0022};
					32'h0071:  {data_command, data_input}     <= {LCD_CMD,  16'h0003};	// set scan mode xstart xend				
					32'h0072:  {data_command, data_input}     <= {LCD_DATA, 16'h0000};  // x0 L
					32'h0073:  {data_command, data_input}     <= {LCD_CMD,  16'h0006};  
					32'h0074:  {data_command, data_input}     <= {LCD_DATA, 16'h0000};  // y0 H
					32'h0075:  {data_command, data_input}     <= {LCD_CMD,  16'h0007};  
					32'h0076:  {data_command, data_input}     <= {LCD_DATA, 16'h0000};  // y0 L
					32'h0078:  {data_command, data_input}     <= {LCD_CMD,  16'h0005};   
					32'h0079:  {data_command, data_input}     <= {LCD_DATA, 16'h00EF};  // x1  
					32'h007a:  {data_command, data_input}     <= {LCD_CMD,  16'h0008};  
					32'h007b:  {data_command, data_input}     <= {LCD_DATA, 16'h0001};  // y1 H
					32'h007c:  {data_command, data_input}     <= {LCD_CMD,  16'h0009}; 
					32'h008d:  {data_command, data_input}     <= {LCD_DATA, 16'h008F};  // y1 L
					32'h008e:  {data_command, data_input}     <= {LCD_CMD,  16'h0022}; 
					
					16'h008f:  {data_command, data_input}     <= {LCD_DATA, {8'hAA ,color} };
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
    
    assign transfer_step = counter_value[0] & enable_transfer & delay_done & ~delay_step;
	assign debug_instruction_step = instruction_step;
	assign lcd_cs = cs_reg;
endmodule



