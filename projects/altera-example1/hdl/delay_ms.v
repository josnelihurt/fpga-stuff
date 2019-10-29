module delay_ms#(
	PER_MS_COUNTER_VALUE = 16'd50_000 //! Change this value if the main clk changes
   )
(
	input  clk,
	input  rst,
	input  step,
	input  [15:0] delay_ms,
	output busy,
	output reg done
);
reg [15:0] counter_load_val;
reg	transfer_step_reg;
always @ (posedge clk, posedge rst) 
	if(rst)
		transfer_step_reg <= 0;
	else
		transfer_step_reg <= step;

wire transfer_step_sync;
assign transfer_step_sync = step & ~transfer_step_reg;

localparam 
STATE_IDLE			 = 'h0,
STATE_MAIN_WAIT	 = 'h1,
STATE_WAIT_1MS	 	 = 'h2;

reg [1:0]state;
reg [32:0] per_ms_counter;
reg [15:0] ms_counter;
wire [32:0] per_ms_counter_next;
wire [15:0] ms_counter_next;

always @ (posedge clk or posedge rst) 
	if(rst) begin
		state <= STATE_IDLE;
		per_ms_counter <= 0;
		ms_counter <= 0;
	end else
		case (state)
		STATE_IDLE:begin
			done <= 1'b0;
			if(transfer_step_sync)begin
				ms_counter <= delay_ms;
				per_ms_counter <= PER_MS_COUNTER_VALUE;
				state <= STATE_MAIN_WAIT;
			end
		end
		STATE_MAIN_WAIT:begin
			if(per_ms_counter_next == 0) begin
				per_ms_counter <= PER_MS_COUNTER_VALUE;
				ms_counter <= ms_counter_next;
				if(ms_counter_next == 0) begin
					done <= 1'b1;
					state <= STATE_IDLE;
				end
			end else 
				per_ms_counter <= per_ms_counter_next;
		end
		default: state <= STATE_MAIN_WAIT;
	endcase


assign per_ms_counter_next = per_ms_counter - 1;
assign ms_counter_next = ms_counter - 1;
assign busy = state == STATE_IDLE;

endmodule
