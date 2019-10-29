module ov7670_debug(
	clk,
	reset_n,
	uart_0_rxd,
	uart_0_txd,
	
	cmos_sclk,
	cmos_sdat,
	cmos_vsync,
	cmos_href,
	cmos_pclk,
	cmos_xclk,
	cmos_data,
	cmos_rst_n,
	cmos_pwdn,
	
	//sdram control
	sdram_clk,		
	sdram_cke,		
	sdram_cs_n,		
	sdram_we_n,		
	sdram_cas_n,
	sdram_ras_n,	
	sdram_dqm,
	sdram_ba,
	sdram_addr,
	sdram_dq,		
	
	//VGA port
	VGA_DCLK,			
	VGA_HS,
	VGA_VS,	
	VGA_BLANK,	
	VGA_RED,		
	VGA_GREEN,	
	VGA_BLUE,
	pio_led,
	pio_key
);

	input		clk;
	input		reset_n;
	input		uart_0_rxd;
	output	uart_0_txd;

	//cmos interface
	inout			cmos_sclk;
	inout			cmos_sdat;
	input			cmos_vsync;
	input			cmos_href;
	input			cmos_pclk;
	output		cmos_xclk;
	input	[7:0]	cmos_data;
	output		cmos_rst_n;
	output		cmos_pwdn;
	
	//sdram control
	output			sdram_clk;	
	output			sdram_cke;		
	output			sdram_cs_n;	
	output			sdram_we_n;
	output			sdram_cas_n;	
	output			sdram_ras_n;	
	output	[1:0]	sdram_dqm;		
	output	[1:0]	sdram_ba;		
	output	[12:0]	sdram_addr;
	inout	[15:0]	sdram_dq;		
	
	//lcd port
	output			VGA_DCLK;		
	output			VGA_HS;		 
	output			VGA_VS;	
	output			VGA_BLANK;
	output	[7:0]	VGA_RED;		
	output	[7:0]	VGA_GREEN;
	output	[7:0]	VGA_BLUE;
	
	input		[1:0]	pio_key;
	output	[3:0]	pio_led;
	

	wire clk_sdr_ctrl;
	
	wire clk_vga;
	wire vga_data_req;
	wire [15:0]vga_data_in;
	assign vga_data_in = sdr_rd1_rddata;
	
	assign cmos_pwdn = 1'b0;
	assign cmos_rst_n = 1'b1;
	
	wire clk_cmos;
	assign cmos_xclk = clk_cmos;
	//cmos video image capture
	wire			cmos_frame_vsync;	//cmos frame data vsync valid signal
	wire			cmos_frame_href;	//cmos frame data href vaild  signal
	wire	[15:0]cmos_frame_data;	//cmos frame data output: {cmos_data[7:0]<<8, cmos_data[7:0]}	
	wire			cmos_frame_clken;	//cmos frame data output/capture enable clock
	wire	[7:0]	cmos_fps_rate;		//cmos image output rate
	
	pll pll(
		.inclk0(clk),
		.c0(clk_sdr_ctrl),
		.c1(sdram_clk),
		.c2(clk_vga),
		.c3(clk_cmos)
	);

	mysystem u0 (
		.clk_clk           (clk),       //  clk.clk
		.reset_reset_n     (reset_n),   //  reset.reset_n
		.oc_iic_scl_pad_io (cmos_sclk), // oc_iic.scl_pad_io
		.oc_iic_sda_pad_io (cmos_sdat), //       .sda_pad_io
		.uart_0_rxd        (uart_0_rxd),// uart_0.rxd
		.uart_0_txd        (uart_0_txd),//       .txd
		.pio_key_export    (3),    // pio_key.export
      .pio_led_export    (pio_led),   // pio_led.export
		.pio_reset_out_export ()  // pio_reset_out.export
	);

CMOS_Capture_RGB565	
#(
	.CMOS_FRAME_WAITCNT		(4'd10)				//Wait n fps for steady(OmniVision need 10 Frame)
)
u_CMOS_Capture_RGB565
(
	//global clock
	.clk_cmos				(clk_cmos),			//24MHz CMOS Driver clock input
	.rst_n					(reset_n),	//global reset

	//CMOS Sensor Interface
	.cmos_pclk				(cmos_pclk),  		//24MHz CMOS Pixel clock input
	.cmos_xclk				(cmos_xclk),		//24MHz drive clock
	.cmos_din				(cmos_data),		//8 bits cmos data input
	.cmos_vsync				(cmos_vsync),		//L: vaild, H: invalid
	.cmos_href				(cmos_href),		//H: vaild, L: invalid
	
	//CMOS SYNC Data output
	.cmos_frame_vsync		(cmos_frame_vsync),	//cmos frame data vsync valid signal
	.cmos_frame_href		(cmos_frame_href),	//cmos frame data href vaild  signal
	.cmos_frame_data		(cmos_frame_data),	//cmos frame RGB output: {{R[4:0],G[5:3]}, {G2:0}, B[4:0]}	
	.cmos_frame_clken		(cmos_frame_clken),	//cmos frame data output/capture enable clock
	
	//user interface
	.cmos_fps_rate			(cmos_fps_rate)		//cmos image output rate
);

	wire sdr_wr1_clk;
	assign sdr_wr1_clk = cmos_pclk;
	
	wire [15:0]sdr_wr1_wrdata;
	assign sdr_wr1_wrdata = cmos_frame_data;
	
	wire sdr_wr1_wrreq;
	assign sdr_wr1_wrreq = cmos_frame_clken;
	
	wire sdr_wr2_clk;
	assign sdr_wr2_clk = 1'b0;
	
	wire [15:0]sdr_wr2_wrdata;
	assign sdr_wr2_wrdata = 16'd0;

	wire sdr_wr2_wrreq;
	assign sdr_wr2_wrreq = 1'b0;

	wire sdr_rd1_clk;
	assign sdr_rd1_clk = clk_vga;
	
	wire sdr_rd1_rdreq;
	assign sdr_rd1_rdreq = vga_data_req;
	
	wire [15:0]sdr_rd1_rddata;	
	
	wire sdr_rd2_clk;
	assign sdr_rd2_clk = 1'b0;
	
	wire sdr_rd2_rdreq;
	assign sdr_rd2_rdreq = 1'b0;

	wire [15:0]sdr_rd2_rddata;

	Sdram_Control_4Port Sdram_Control_4Port(
		//	HOST Side
		.CTRL_CLK(clk_sdr_ctrl),	//输入参考时钟，默认100M，如果为其他频率，请修改sdram_pll核设置
		.RESET_N(reset_n),	//复位输入，低电平复位

		//	FIFO Write Side 1
		.WR1_DATA(sdr_wr1_wrdata),			//写入端口1的数据输入端，16bit
		.WR1(sdr_wr1_wrreq),					//写入端口1的写使能端，高电平写入
		.WR1_ADDR(0),			//写入端口1的写起始地址
		.WR1_MAX_ADDR(640*480),		//写入端口1的写入最大地址
		.WR1_LENGTH(256),			//一次性写入数据长度
		.WR1_LOAD(~reset_n),			//写入端口1清零请求，高电平清零写入地址和fifo
		.WR1_CLK(sdr_wr1_clk),				//写入端口1 fifo写入时钟
		.WR1_FULL(),			//写入端口1 fifo写满信号
		.WR1_USE(),				//写入端口1 fifo已经写入的数据长度

		//	FIFO Write Side 2
		.WR2_DATA(sdr_wr2_wrdata),			//写入端口2的数据输入端，16bit
		.WR2(sdr_wr2_wrreq),					//写入端口2的写使能端，高电平写入
		.WR2_ADDR(0),			//写入端口2的写起始地址
		.WR2_MAX_ADDR(640*480),		//写入端口2的写入最大地址
		.WR2_LENGTH(8),			//一次性写入数据长度
		.WR2_LOAD(1'b0),			//写入端口2清零请求，高电平清零写入地址和fifo
		.WR2_CLK(sdr_wr2_clk),				//写入端口2 fifo写入时钟
		.WR2_FULL(),			//写入端口2 fifo写满信号
		.WR2_USE(),				//写入端口2 fifo已经写入的数据长度

		//	FIFO Read Side 1
		.RD1_DATA(sdr_rd1_rddata),			//读出端口1的数据输出端，16bit
		.RD1(sdr_rd1_rdreq),					//读出端口1的读使能端，高电平读出
		.RD1_ADDR(0),			//读出端口1的读起始地址
		.RD1_MAX_ADDR(640*480),		//读出端口1的读出最大地址
		.RD1_LENGTH(256),			//一次性读出数据长度
		.RD1_LOAD(~reset_n),			//读出端口1 清零请求，高电平清零读出地址和fifo
		.RD1_CLK(sdr_rd1_clk),				//读出端口1 fifo读取时钟
		.RD1_EMPTY(),			//读出端口1 fifo读空信号
		.RD1_USE(),				//读出端口1 fifo已经还可以读取的数据长度

		//	FIFO Read Side 2
		.RD2_DATA(),			//读出端口2的数据输出端，16bit
		.RD2(1'b0),					//读出端口2的读使能端，高电平读出
		.RD2_ADDR(),			//读出端口2的读起始地址
		.RD2_MAX_ADDR(),		//读出端口2的读出最大地址
		.RD2_LENGTH(),			//一次性读出数据长度
		.RD2_LOAD(),			//读出端口2清零请求，高电平清零读出地址和fifo
		.RD2_CLK(1'b0),				//读出端口2 fifo读取时钟
		.RD2_EMPTY(),			//读出端口2 fifo读空信号
		.RD2_USE(),				//读出端口2 fifo已经还可以读取的数据长度

		//	SDRAM Side
		.SA(sdram_addr),		//SDRAM 地址线，
		.BA(sdram_ba),		//SDRAM bank地址线
		.CS_N(sdram_cs_n),		//SDRAM 片选信号
		.CKE(sdram_cke),		//SDRAM 时钟使能
		.RAS_N(sdram_ras_n),	//SDRAM 行选中信号
		.CAS_N(sdram_cas_n),	//SDRAM 列选中信号
		.WE_N(sdram_we_n),		//SDRAM 写请求信号
		.DQ(sdram_dq),		//SDRAM 双向数据总线
		.DQM(sdram_dqm)		//SDRAM 数据总线高低字节屏蔽信号
	);	

	VGA_CTRL_640_480_24bit VGA_CTRL(
		.Clk25M(clk_vga),	//系统输入时钟25MHZ
		.Rst_n(reset_n),	//复位输入，低电平复位
		.data_in({vga_data_in[15:11],3'd0,vga_data_in[10:5],2'd0,vga_data_in[4:0],3'd0}),	//待显示数据
		.hcount(),		//VGA行扫描计数器
		.vcount(),		//VGA场扫描计数器
		.VGA_RGB({VGA_RED, VGA_GREEN, VGA_BLUE}),	//VGA数据输出
		.VGA_HS(VGA_HS),		//VGA行同步信号
		.VGA_VS(VGA_VS),		//VGA场同步信号
		.VGA_BLANK(VGA_BLANK),
		.VGA_DCLK(VGA_DCLK),
		.dat_act(vga_data_req)
	);
	
endmodule
