module hx8352_controller_fsm_enabler(
	input wire clk,
	input wire rst,
	input wire lcd_rst_done,
	input wire bus_busy,
	input wire delay_busy,
	input wire delay_done,
	output wire clk_enabled
);
wire lcd_rst_done_rise;
edge_detect 
	edge_detect_u0
	(
	.async_sig(lcd_rst_done),
	.clk(clk),
	.rise(lcd_rst_done_rise),
	.fall()
	);

reg fsm_enable;
always @(posedge clk or posedge rst) begin
	if(rst) begin
		fsm_enable <= 1'b0;
	end else begin
		fsm_enable <= fsm_enable;	
			
		if(delay_done || lcd_rst_done_rise ) 
			fsm_enable <= 1'b1;
			
		if(delay_busy)
			fsm_enable <= 1'b0;	
		
	end
end
assign clk_enabled = !bus_busy & !delay_busy & clk;
endmodule 