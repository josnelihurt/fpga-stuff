//--------------------------------------------------------------------------------------------
//
//
//      Input file      : 
//      Component name  : oc_i2c_master
//      Author          : 
//      Company         : 
//
//      Description     : 
//
//
//--------------------------------------------------------------------------------------------


`define AVALON_IF

module oc_i2c_master(

`ifdef AVALON_IF
//Avalon common
	av_clk,
	av_reset,

	av_address,
	av_chipselect,
	av_write,
	av_read,
	av_writedata,
	av_readdata,
	av_waitrequest_n,
	av_irq,
	
`else
	wb_ack_o, 
	wb_adr_i, 
	wb_clk_i, 
	wb_cyc_i, 
	wb_dat_i, 
	wb_dat_o, 
//	wb_err_o, 
	wb_rst_i, 
	wb_stb_i, 
	wb_we_i, 
	wb_inta_o,
`endif

	scl_pad_io,
	sda_pad_io
);

`ifdef AVALON_IF
     //Avalon common
	input                   av_clk;
	input                   av_reset;
	//Avalon control port
	input  [2:0]            av_address;
	input                   av_chipselect;
	input                   av_write;
	input                   av_read;
	input  [7:0]           av_writedata;
	output [7:0]           av_readdata;
	output                  av_waitrequest_n;
	output                  av_irq;

`else
   output        wb_ack_o;
   input [2:0]   wb_adr_i;
   input         wb_clk_i;
   input         wb_cyc_i;
   input [31:0]  wb_dat_i;
   output [31:0] wb_dat_o;
//   output        wb_err_o;
   input         wb_rst_i;
   input         wb_stb_i;
   input         wb_we_i;
   output        wb_inta_o;
`endif

	inout         scl_pad_io;
   inout         sda_pad_io;

   wire          scl_pad_i;
   wire          scl_pad_o;
   wire          scl_padoen_o;
   wire          sda_pad_i;
   wire          sda_pad_o;
   wire          sda_padoen_o;
   wire          arst_i;

//   assign wb_err_o = 0;
   
   
	i2c_master_top i2c_top_inst(
		`ifdef AVALON_IF
			.wb_clk_i(av_clk),
			.wb_rst_i(av_reset),
			.wb_adr_i(av_address[2:0]),
			.wb_dat_i(av_writedata[7:0]),
			.wb_dat_o(av_readdata[7:0]),
			.wb_cyc_i(av_write | av_read),
			.wb_stb_i(av_chipselect & (av_write | av_read)),
			.wb_we_i(av_write & ~av_read),
			.wb_ack_o(av_waitrequest_n),
			.wb_inta_o(av_irq),
		`else
			.wb_clk_i(wb_clk_i), 
			.wb_rst_i(wb_rst_i), 
			.wb_adr_i(wb_adr_i), 
			.wb_dat_i(wb_dat_i[7:0]), 
			.wb_dat_o(wb_dat_o[7:0]),
			.wb_cyc_i(wb_cyc_i), 		
			.wb_stb_i(wb_stb_i), 
			.wb_we_i(wb_we_i), 
			.wb_ack_o(wb_ack_o), 
			.wb_inta_o(wb_inta_o),
		`endif
			.arst_i(arst_i), 		
			.scl_pad_i(scl_pad_i), 
			.scl_pad_o(scl_pad_o), 
			.scl_padoen_o(scl_padoen_o), 
			.sda_pad_i(sda_pad_i), 
			.sda_pad_o(sda_pad_o), 
			.sda_padoen_o(sda_padoen_o)
	);
   
   assign arst_i = 1'b1;
   assign scl_pad_io = (((scl_padoen_o) != 1'b0)) ? 1'bZ : 
                       scl_pad_o;
   assign sda_pad_io = (((sda_padoen_o) != 1'b0)) ? 1'bZ : 
                       sda_pad_o;
   assign scl_pad_i = scl_pad_io;
   assign sda_pad_i = sda_pad_io;
   
endmodule
