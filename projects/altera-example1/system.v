
module system(
	input clk_50M,
	input key0,
	input            	RESET_N,
	//input key1,
	output led,
	output [7:0]display_7seg_bus,
	output [2:0]display_7seg_anodes,
	output [15:0]probe_bus,
	output [1:0] probe_bus2,
	// tm1638 board
	output tm1638_clk,
	inout tm1638_data_io,
	output tm1638_strobe,
	//lcd board
	output 	[15:0]hx8352_data,
	output 	hx8352_rs,
	output 	hx8352_wr,
	output 	hx8352_rd,
	output 	hx8352_cs,
	output 	hx8352_rst,
	
	///////// DRAM /////////
	output    [12:0]	DRAM_ADDR,
	output    [1:0] 	DRAM_BA,
	output            DRAM_CAS_N,
	output          	DRAM_CKE,
	output            DRAM_CLK,
	output        		DRAM_CS_N,
	inout     [15:0]	DRAM_DQ,
	output            DRAM_LDQM,
	output            DRAM_RAS_N,
	output            DRAM_UDQM,
	output            DRAM_WE_N
	//dataflash
//	output data_flash_spi_clk,
//	output data_flash_spi_cs,
//	inout data_flash_spi_data0,
//	inout data_flash_spi_asdo
	);
	wire rst = ~key0;
	wire clk_200M;
	wire clk_10M;
	wire clk_5M;
	wire clk_1M;
	wire clk_1H;
	wire clk_sdram;
	
	clock_divider clk_divider_0(.clk_50M(clk_50M), .rst(rst), .clk_out(clk_1H));
	
	`ifdef SIMULATION
		
	`else
        PLL pll_unit0(
		        .areset(rst),
		        .inclk0(clk_50M),
		        .c0(clk_200M),
		        .c1(clk_10M),
		        .c2(clk_100M),
		        .c3(clk_1M),
				  .c4(clk_sdram),
		        .locked()
	        );
	`endif

//=======================================================
//  NIOS SYSTEM
//=======================================================
//	wire [3:0]data_flash_data;
	wire[31:0] nios_pio_0, nios_pio_lcd;

	nios_core nios_core_u0(
		.clk_clk(clk_50M),       //   clk.clk
		.reset_reset_n(1'b1),  // reset.reset_n
		//.pio_0_external_connection_export(nios_pio_0),
		//.pio_lcd_control_external_connection_export(nios_pio_lcd),
		
	);
//	
//	assign data_flash_spi_data = data_flash_data[0];
//	assign data_flash_spi_asdo = data_flash_data[1];
	//
//=======================================================
//  REG/WIRE declarations
//=======================================================
wire  [15:0]  writedata;
wire  [15:0]  readdata;
wire          write;
wire          read;
wire          clk_test;
assign clk_test = clk_100M;
//	SDRAM frame buffer
Sdram_Control	sdram_controler_u1	(	
	//	HOST Side
	.REF_CLK(clk_50M), .RESET_N(RESET_N),
	//	FIFO Write Side 
	.WR_DATA(writedata),
	.WR(write),
	.WR_ADDR(0),
	.WR_MAX_ADDR(24'h1ffffff),
	.WR_LENGTH(9'h80),
	.WR_LOAD(!RESET_N),
	.WR_CLK(clk_test),
	//	FIFO Read Side 
	.RD_DATA(readdata),
	.RD(read),
	.RD_ADDR(0),			//	Read odd field and bypess blanking
	.RD_MAX_ADDR(24'h1ffffff),
	.RD_LENGTH(9'h80),
	.RD_LOAD(!RESET_N),
	.RD_CLK(clk_test),
	//	SDRAM Side
	.SA(DRAM_ADDR),
	.BA(DRAM_BA),
	.CS_N(DRAM_CS_N),
	.CKE(DRAM_CKE),
	.RAS_N(DRAM_RAS_N),
	.CAS_N(DRAM_CAS_N),
	.WE_N(DRAM_WE_N),
	.DQ(DRAM_DQ),
	.DQM({DRAM_UDQM,DRAM_LDQM}),
	.SDR_CLK(DRAM_CLK)	);
wire  test_start_n;

wire  sdram_test_pass;
wire  sdram_test_fail;
wire  sdram_test_complete;
/*
PLL01 u0(
	.areset(1'b0),
	.inclk0(CLOCK_50),
	.c0(clk_test),
	.locked()
);
*/

RW_Test u2(
      .clk(clk_test),
		.rst(!RESET_N),
		.iBUTTON(test_start_n),
      .write(write),
		.writedata(writedata),
	   .read(read),
		.readdata(readdata),
      .drv_status_pass(sdram_test_pass),
		.drv_status_fail(sdram_test_fail),
		.drv_status_test_complete(sdram_test_complete),
		.c_state(rw_test_state)
);
	

assign test_start_n = key0;
//=======================================================
//  HX8352 lcd controller
//=======================================================
wire [31:0]hx8352_dbg;
wire[31:0] counter_1s;
counter #(.N(32),.M(1024))
	counter_base_unit1
	(
	.clk(clk_1H), .reset(rst),
	.max_tick(),
	.q(counter_1s)
	);	

wire hx8352_init_done;
wire hx8352_busy;	
wire hx8352_step;
wire [3:0] hx8352_cmd_in;
wire [15:0] hx8352_data_in;
// 0000_0000_0000_0000
//	31....16_15.......0 

assign hx8352_step	=nios_pio_lcd[31];
assign hx8352_cmd_in	=nios_pio_lcd[19:16];
assign hx8352_data_in=nios_pio_lcd[15:0];

hx8352_controller
	hx8352_u0
	(
	.clk(clk_50M), .rst(rst),
	.step(hx8352_step),.data_in(hx8352_data_in),.cmd_in(hx8352_cmd_in),	
	.busy(hx8352_busy),
	.lcd_rs(hx8352_rs),
	.lcd_wr(hx8352_wr),
	.lcd_rd(hx8352_rd),
	.lcd_rst(hx8352_rst),
	.lcd_cs(hx8352_cs),
	.data_bus(hx8352_data[15:0]),
	.debug_instruction_step(hx8352_dbg),
	.init_done(hx8352_init_done)
	);
seven_segments_handler 
	seven_segments_handler_unit0
	(
	.clk_1MHz(clk_1M),
	.rst(rst),
	.input_hex({8'h0,rw_test_state}),
	.dots(3'b000),
	.display_7seg_anodes(display_7seg_anodes),
	.display_7seg_bus(display_7seg_bus)
	);
wire[7:0] tm1638_keys;
tm1638_keys_display_encoded
	tm1638_keys_display_encoded_unit0
	(
	.clk_1MHz(clk_1M),
	.rst(rst),
	.display_off(1'b0),
	.display_level(3'b100),
	.display_value(nios_pio_lcd),//{debug_instruction_step, hx8352_data}),
	.dots(8'h00),
	.leds_green({ 2'b00,tm1638_keys[0],clk_1H,hx8352_init_done,sdram_test_pass,sdram_test_fail,sdram_test_complete}),
	.leds_red(0),
	.keys(tm1638_keys),
	
	.tm1638_strobe(tm1638_strobe),
	.tm1638_clk(tm1638_clk),
	.tm1638_data_io(tm1638_data_io)
	);
//hardware hardware_u0();
assign led = !(sdram_test_complete & sdram_test_pass);
assign probe_bus[15:0] = {hx8352_dbg[15:0]};
assign probe_bus2[0] = clk_1H;
assign probe_bus2[1] = clk_1H;
endmodule
