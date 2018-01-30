module hx8352_controller_bus_controller
(
	input  clk,
	input  rst,
	input  [15:0] data_input,
	input  data_command,
	input  transfer_step,
	
	output busy,
	output [15:0] data_output,
	output lcd_rs,
	output lcd_wr,
	output lcd_rd
);
	reg   transfer_step_reg;
	always @ (posedge clk, posedge rst) 
	begin
		if(rst)
			transfer_step_reg <= 0;
		else
			transfer_step_reg <= transfer_step;
	end
	assign transfer_step_sync = transfer_step & ~transfer_step_reg;


    localparam [2:0]
        STATE_IDLE      		= 3'h0,
        STATE_LOAD_DATA 		= 3'h1,
        STATE_LCD_CLK_TICK	 	= 3'h2;
	
	localparam 
        HIGH    = 1'b1,
        LOW     = 1'b0;
	reg [1:0] cur_state, next_state;
	reg [15:0] lcd_data_reg, lcd_data_next;
	reg lcd_rs_reg,  lcd_rs_next;
	reg lcd_wr_reg,  lcd_wr_next;
	reg lcd_rd_reg,  lcd_rd_next;
	reg lcd_busy_reg,  lcd_busy_next;

	always @(*)
    begin
		lcd_wr_next = HIGH;
		lcd_rd_next = HIGH;
		lcd_rs_next = HIGH;
		lcd_busy_next = LOW;
        next_state = cur_state;
		lcd_data_next = lcd_data_reg;
		
        case(cur_state)
            STATE_IDLE: 
            begin
                if (transfer_step_sync) 
                begin
                    next_state = STATE_LOAD_DATA;
                    lcd_busy_next = HIGH;
                end
            end
            STATE_LOAD_DATA:
            begin
				lcd_rs_next = data_command;
				lcd_data_next = data_input;
				next_state = STATE_LCD_CLK_TICK;
				lcd_busy_next = HIGH;
			end
            STATE_LCD_CLK_TICK:
            begin
				lcd_rs_next = lcd_rs_reg;
				next_state = STATE_IDLE;
				lcd_busy_next = HIGH;
				lcd_wr_next = LOW;
            end
            default:
                next_state = STATE_IDLE;
        endcase
    end

    always @(posedge clk, posedge rst)
    begin
        if (rst)
        begin
            cur_state <= STATE_IDLE;
            lcd_rs_reg <= LOW;
            lcd_wr_reg <= LOW;
            lcd_rd_reg <= LOW;
            lcd_data_reg <= 16'h0;
            
        end
        else
        begin
            cur_state <= next_state;
            lcd_rs_reg <= lcd_rs_next;
            lcd_wr_reg <= lcd_wr_next;
            lcd_rd_reg <= lcd_rd_next;
            lcd_data_reg <= lcd_data_next;
        end
    end

assign data_output = lcd_data_reg;
assign lcd_rs = lcd_rs_reg;
assign lcd_wr = lcd_wr_reg;
assign lcd_rd = lcd_rd_reg;

endmodule
