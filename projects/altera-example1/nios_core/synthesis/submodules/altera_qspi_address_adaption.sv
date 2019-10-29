// (C) 2001-2018 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


`timescale 1ns / 1ns

module altera_qspi_address_adaption #(
	parameter CS_WIDTH		= 1,
	parameter ENABLE_4BYTE_ADDR = 1,
	parameter ADDR_WIDTH	= 22,
	parameter ASI_WIDTH		= 1,
	parameter DEVICE_FAMILY = "CYCLONE V",
	parameter ASMI_ADDR_WIDTH = 22,
	parameter CHIP_SELS = 1
)(
	input                  clk,
	input                  reset,
	                                        			
	// ports to access csr                        			
	input                  avl_csr_write,
	input                  avl_csr_read,
	input [3:0]            avl_csr_addr,
	input [31:0]           avl_csr_wrdata,
	output reg [31:0]      avl_csr_rddata,
	output reg             avl_csr_rddata_valid,
	output reg             avl_csr_waitrequest,
	                                        			
	// ports to access memory        			
	input                  avl_mem_write,
	input                  avl_mem_read,
	input [ADDR_WIDTH-1:0] avl_mem_addr,
	input [31:0]           avl_mem_wrdata,
	input [3:0]            avl_mem_byteenable,
	input [6:0]            avl_mem_burstcount,
	output [31:0]          avl_mem_rddata,
	output logic           avl_mem_rddata_valid,
	output logic           avl_mem_waitrequest,
	
	// interrupt signal
	output logic           irq,
	output logic [3:0]     chip_select,
	
	// ASMI PARALLEL interface
	output logic [5:0]     asmi_csr_addr, 
	output logic           asmi_csr_read, 
	input [31:0]           asmi_csr_rddata, 
	output logic           asmi_csr_write, 
	output logic [31:0]    asmi_csr_wrdata, 
	input                  asmi_csr_waitrequest, 
	input                  asmi_csr_rddata_valid,
	output logic [31:0]    asmi_mem_addr, 
	output logic           asmi_mem_read, 
	input [31:0]           asmi_mem_rddata, 
	output logic           asmi_mem_write, 
	output logic [31:0]    asmi_mem_wrdata, 
	output logic [3:0]     asmi_mem_byteenable, 
	output logic [6:0]     asmi_mem_burstcount, 
	input                  asmi_mem_waitrequest, 
    input                  asmi_mem_rddata_valid

);

	reg temp_mem_write, temp_mem_read, mem_write, mem_read, back_pressured_ctrl;
	reg [ADDR_WIDTH-1:0] temp_mem_addr, mem_addr;		
	reg [31:0] temp_mem_wrdata, mem_wrdata;
	reg [3:0] temp_mem_byteenable, mem_byteenable;
	reg [6:0] temp_mem_burstcount, mem_burstcount;
	
	wire back_pressured, temp_csr_waitrequest, temp_mem_waitrequest;

	//-------------------- Arbitration logic between avalon csr and mem interface -----------
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			back_pressured_ctrl		<= 1'b0;
		end 
		else if (back_pressured) begin
			back_pressured_ctrl		<= 1'b1;
		end
		else if (~temp_csr_waitrequest) begin
			back_pressured_ctrl		<= 1'b0;
		end
	end

	always @(posedge clk or posedge reset) begin
		if (reset) begin
			mem_write 			<= 1'b0;
			mem_read 			<= 1'b0;
			mem_addr			<= {ADDR_WIDTH{1'b0}};
			mem_wrdata			<= {32{1'b0}};
			mem_byteenable		<= {4{1'b0}};
			mem_burstcount		<= {7{1'b0}};
		end 
		else if ((avl_csr_write || avl_csr_read) && ~avl_csr_waitrequest && (avl_mem_write || avl_mem_read) && ~avl_mem_waitrequest) begin
			// to back pressure master
			mem_write 			<= avl_mem_write;
			mem_read 			<= avl_mem_read;
			mem_addr			<= avl_mem_addr;
			mem_wrdata			<= avl_mem_wrdata;
			mem_byteenable		<= avl_mem_byteenable;
			mem_burstcount		<= avl_mem_burstcount;
		end
	end
	
	assign back_pressured	   = ((avl_csr_write || avl_csr_read) && ~temp_csr_waitrequest && (avl_mem_write || avl_mem_read)) ? 1'b1 : 1'b0; // to back pressure controller
	assign avl_csr_waitrequest = (~avl_csr_write && ~avl_csr_read && back_pressured_ctrl) ? 1'b1 : temp_csr_waitrequest;
	//assign avl_mem_waitrequest = (back_pressured_ctrl) ? 1'b1 : temp_mem_waitrequest;
	assign temp_mem_write	   = (back_pressured) ? 1'b0 : (back_pressured_ctrl) ? mem_write : avl_mem_write;
	assign temp_mem_read	   = (back_pressured) ? 1'b0 : (back_pressured_ctrl) ? mem_read : avl_mem_read;
	assign temp_mem_addr	   = (back_pressured) ? {ADDR_WIDTH{1'b0}} : (back_pressured_ctrl) ? mem_addr : avl_mem_addr;
	assign temp_mem_wrdata	   = (back_pressured) ? {32{1'b0}} : (back_pressured_ctrl) ? mem_wrdata : avl_mem_wrdata;
	assign temp_mem_byteenable = (back_pressured) ? {4{1'b0}} : (back_pressured_ctrl) ? mem_byteenable : avl_mem_byteenable;
	assign temp_mem_burstcount = (back_pressured) ? {7{1'b0}} : (back_pressured_ctrl) ? mem_burstcount : avl_mem_burstcount;
	
	
	//---------------------------------------------------------------------------------------//
	
	altera_qspi_address_adaption_core #(
		.CS_WIDTH		   	(CS_WIDTH),
		.DEVICE_FAMILY     	(DEVICE_FAMILY),
		.ADDR_WIDTH        	(ADDR_WIDTH),
		.ASMI_ADDR_WIDTH   	(ASMI_ADDR_WIDTH),
		.ASI_WIDTH         	(ASI_WIDTH),
		.CHIP_SELS	 		(CHIP_SELS),
		.ENABLE_4BYTE_ADDR 	(ENABLE_4BYTE_ADDR)
	) addr_adaption (
		.clk                  		(clk),
		.reset                		(reset),
		.avl_csr_read         		(avl_csr_read),
		.avl_csr_waitrequest  		(temp_csr_waitrequest),
		.avl_csr_write        		(avl_csr_write),        
		.avl_csr_addr         		(avl_csr_addr),         
		.avl_csr_wrdata       		(avl_csr_wrdata),       
		.avl_csr_rddata       		(avl_csr_rddata),       
		.avl_csr_rddata_valid 		(avl_csr_rddata_valid), 
		.avl_mem_write        		(avl_mem_write),        
		.avl_mem_burstcount   		(avl_mem_burstcount),   
		.avl_mem_waitrequest  		(avl_mem_waitrequest),  
		.avl_mem_read         		(avl_mem_read),         
		.avl_mem_addr         		(avl_mem_addr),         
		.avl_mem_wrdata       		(avl_mem_wrdata),
		.avl_mem_byteenable   		(avl_mem_byteenable),
		.avl_mem_rddata       		(avl_mem_rddata),       
		.avl_mem_rddata_valid 		(avl_mem_rddata_valid), 
		.irq                  		(irq),
		.chip_select 				(chip_select),
		.asmi_csr_addr        		(asmi_csr_addr),      
		.asmi_csr_read         		(asmi_csr_read),         
		.asmi_csr_rddata      		(asmi_csr_rddata),     
		.asmi_csr_write        		(asmi_csr_write),        
		.asmi_csr_wrdata      		(asmi_csr_wrdata),    
		.asmi_csr_waitrequest 		(asmi_csr_waitrequest),  
		.asmi_csr_rddata_valid		(asmi_csr_rddata_valid),
		.asmi_mem_addr        		(asmi_mem_addr),      
		.asmi_mem_read         		(asmi_mem_read),         
		.asmi_mem_rddata      		(asmi_mem_rddata),     
		.asmi_mem_write        		(asmi_mem_write),        
		.asmi_mem_wrdata      		(asmi_mem_wrdata),    
		.asmi_mem_byteenable  		(asmi_mem_byteenable),   
		.asmi_mem_burstcount  		(asmi_mem_burstcount),   
		.asmi_mem_waitrequest 		(asmi_mem_waitrequest),  
		.asmi_mem_rddata_valid 		(asmi_mem_rddata_valid)
	);                                                

endmodule
