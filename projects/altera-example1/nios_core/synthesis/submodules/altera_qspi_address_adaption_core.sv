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


// $Id: //acds/main/ip/pgm/altera_epcq_controller2/altera_qspi_address_adaption_core.sv#6 $
// $Revision: #6 $
// $Date: 2017/02/23 $
// $Author: tgngo $

`timescale 1ns / 1ns

module altera_qspi_address_adaption_core #(
    parameter CS_WIDTH          = 1,
    parameter ENABLE_4BYTE_ADDR = 1,
    parameter ADDR_WIDTH        = 22,
    parameter ASI_WIDTH         = 1,
    parameter DEVICE_FAMILY     = "CYCLONE V",
    parameter ASMI_ADDR_WIDTH   = 22,
    parameter CHIP_SELS         = 1
)(
    input                                               clk,
    input                                               reset,
                                                        
    // ports to access csr                                  
    input                                               avl_csr_write,
    input                                               avl_csr_read,
    input           [3:0]                               avl_csr_addr,
    input           [31:0]                              avl_csr_wrdata,
    output  logic   [31:0]                              avl_csr_rddata,
    output  logic                                       avl_csr_rddata_valid,
    output  logic                                       avl_csr_waitrequest,
                                                        
    // ports to access memory                   
    input                                               avl_mem_write,
    input                                               avl_mem_read,
    input           [ADDR_WIDTH-1:0]                    avl_mem_addr,           
    input           [31:0]                              avl_mem_wrdata,
    input           [3:0]                               avl_mem_byteenable,
    input           [6:0]                               avl_mem_burstcount,
    output          [31:0]                              avl_mem_rddata,
    output  logic                                       avl_mem_rddata_valid,
    output  logic                                       avl_mem_waitrequest,
    
    // interrupt signal
    output  logic                                       irq,
    output  logic   [3:0]                               chip_select,
    // ASMI PARALLEL interface
    output logic    [5:0]                               asmi_csr_addr,      
    output logic                                        asmi_csr_read,         
    input           [31:0]                              asmi_csr_rddata,     
    output logic                                        asmi_csr_write,        
    output logic    [31:0]                              asmi_csr_wrdata,    
    input                                               asmi_csr_waitrequest,  
    input                                               asmi_csr_rddata_valid,

    output logic    [31:0]                              asmi_mem_addr,
    output logic                                        asmi_mem_read,         
    input           [31:0]                              asmi_mem_rddata,     
    output logic                                        asmi_mem_write,        
    output logic    [31:0]                              asmi_mem_wrdata,    
    output logic    [3:0]                               asmi_mem_byteenable,   
    output logic    [6:0]                               asmi_mem_burstcount,   
    input                                               asmi_mem_waitrequest,  
    input                                               asmi_mem_rddata_valid
);
    localparam LOCAL_ADDR_WIDTH = ADDR_WIDTH+2;
    localparam CSR_DATA_WIDTH   = 32;
    localparam LAST_ADDR_BIT    = (ASMI_ADDR_WIDTH == 24) ? 15 :
                                    (ASMI_ADDR_WIDTH == 32) ? 23 : 15;

    logic access_csr_status;
    logic access_csr_flag_status;
    // This is not used in new IP, but for backward compatibility and request from firmware team's request
    // still keep this.
    logic access_csr_sid; 
    logic access_csr_rdid;
    logic access_csr_mem_op;
    logic access_isr;
    logic access_imr;
    logic access_sce;
    logic access_device_id_0, access_device_id_1, access_device_id_2, access_device_id_3, access_device_id_4;
    logic write_device_id_0_combi, read_device_id_0_combi, write_device_id_1_combi, read_device_id_1_combi, write_device_id_2_combi, read_device_id_2_combi, write_device_id_3_combi, read_device_id_3_combi, write_device_id_4_combi, read_device_id_4_combi;
    logic read_status_combi, read_flag_status_combi, write_flag_status_combi, read_rdid_combi, read_isr_combi, read_imr_combi, write_isr_combi, write_imr_combi, write_sce_combi, write_en_combi, write_sid_combi, read_sid_combi;
    logic bulk_erase_combi;
    logic sector_erase_combi;
    logic sector_protect_combi;
    logic asmi_csr_op;
    logic illegal_write_combi, illegal_erase_combi;
    logic m_illegal_write_combi, m_illegal_erase_combi;
    logic read_op_without_flash;
    logic avl_csr_rddata_valid_local;
    logic read_sce_combi;
    logic read_csr_mem_op_combi;
    logic write_csr_mem_op_combi;
    logic illegal_write_reg, illegal_erase_reg, m_illegal_write_reg, m_illegal_erase_reg;
    logic [31:0]  avl_csr_rddata_local;
    logic waitrequest_local;
    logic read_mem_combi, write_mem_combi;
    logic [ADDR_WIDTH-1:0] temp_mem_addr;
    // +-------------------------------------------------------
    // | Reset trigger: detect when reset has been asserted
    // +-------------------------------------------------------
    logic reset_trigger;
    logic reset_trigger_dly;
    logic reset_trigger_pulse;
    logic rff;
    logic [5:0]     asmi_csr_addr_rst_op;
    logic           asmi_csr_write_rst_op;
    logic [31:0]    asmi_csr_wrdata_rst_op;
    logic [5:0]     asmi_csr_addr_csr_op;
    logic           asmi_csr_write_csr_op;
    logic [31:0]    asmi_csr_wrdata_csr_op;

    always_ff @(posedge clk or posedge reset)
    begin
        if (reset)
            {reset_trigger, rff} <= 2'b11;
        else
        {reset_trigger, rff} <= {rff, 1'b0};
    end
    always_ff @(posedge clk)
    begin
        reset_trigger_dly <= reset_trigger;
    end
    // 1 -> 0 reset trigger detection
    assign reset_trigger_pulse = !reset_trigger && reset_trigger_dly;

    // +--------------------------------------------------
    // | Enable 4-byte addressing out of reset
    // +--------------------------------------------------
    logic rst_op_active;
    generate 
        if (ENABLE_4BYTE_ADDR) begin
            // State machine enable 4 byte address
            // To be improved, for now limit is 3 flashes devices
            typedef enum bit [9:0]
            {
                ST_IDLE             = 10'b0000000001,
                ST_SELECT_CHIP_1    = 10'b0000000010,
                ST_WE_CHIP_1        = 10'b0000000100,
                ST_EN_4BYTES_CHIP_1 = 10'b0000001000,
                ST_SELECT_CHIP_2    = 10'b0000010000,
                ST_WE_CHIP_2        = 10'b0000100000,
                ST_EN_4BYTES_CHIP_2 = 10'b0001000000,
                ST_SELECT_CHIP_3    = 10'b0010000000,
                ST_WE_CHIP_3        = 10'b0100000000,
                ST_EN_4BYTES_CHIP_3 = 10'b1000000000
             } t_state;
            t_state state, next_state;
            // +--------------------------------------------------
            // | State Machine: update state
            // +--------------------------------------------------
            // |
            always_ff @(posedge clk or posedge reset) begin
                if (reset)
                    state <= ST_IDLE;
                else
                    state <= next_state;
            end
            // +--------------------------------------------------
            // | State Machine: next state condition
            // +--------------------------------------------------
            always_comb begin
                next_state  = ST_IDLE;
                case (state)
                    ST_IDLE: begin
                        next_state  = ST_IDLE;
                        if (reset_trigger_pulse)
                            next_state = ST_SELECT_CHIP_1;
                    end
                    ST_SELECT_CHIP_1: begin 
                        next_state = ST_SELECT_CHIP_1;
                        if (!asmi_csr_waitrequest) begin
                            next_state = ST_WE_CHIP_1;
                        end
                    end
                    ST_WE_CHIP_1: begin 
                        next_state = ST_WE_CHIP_1;
                        if (!asmi_csr_waitrequest) begin
                            next_state = ST_EN_4BYTES_CHIP_1;
                        end
                    end
                    ST_EN_4BYTES_CHIP_1: begin 
                        next_state = ST_EN_4BYTES_CHIP_1;
                        if (!asmi_csr_waitrequest) begin
                            if (CHIP_SELS > 1) 
                                next_state = ST_SELECT_CHIP_2;
                            else
                                next_state = ST_IDLE;
                        end
                    end
                    ST_SELECT_CHIP_2: begin 
                        next_state = ST_SELECT_CHIP_2;
                        if (!asmi_csr_waitrequest) begin
                            next_state = ST_WE_CHIP_2;
                        end
                    end
                    ST_WE_CHIP_2: begin 
                        next_state = ST_WE_CHIP_2;
                        if (!asmi_csr_waitrequest) begin
                            next_state = ST_EN_4BYTES_CHIP_2;
                        end
                    end
                    ST_EN_4BYTES_CHIP_2: begin 
                        next_state = ST_EN_4BYTES_CHIP_2;
                        if (!asmi_csr_waitrequest) begin
                            if (CHIP_SELS > 2) 
                                next_state = ST_SELECT_CHIP_3;
                            else
                                next_state = ST_IDLE;
                        end
                    end
                    ST_SELECT_CHIP_3: begin 
                        next_state = ST_SELECT_CHIP_3;
                        if (!asmi_csr_waitrequest) begin
                            next_state = ST_WE_CHIP_3;
                        end
                    end
                    ST_WE_CHIP_3: begin 
                        next_state = ST_WE_CHIP_3;
                        if (!asmi_csr_waitrequest) begin
                            next_state = ST_EN_4BYTES_CHIP_3;
                        end
                    end
                    ST_EN_4BYTES_CHIP_3: begin 
                        next_state = ST_EN_4BYTES_CHIP_3;
                        if (!asmi_csr_waitrequest)
                            next_state = ST_IDLE;
                    end
                endcase // case (state)
            end // always_comb
            // +-------------------------------------------------------
            // | State machine: state outputs
            // +-------------------------------------------------------
            always_comb begin
                asmi_csr_addr_rst_op    = '0;
                asmi_csr_write_rst_op   = '0;
                asmi_csr_wrdata_rst_op  = '0;
                rst_op_active           = '0;
                case (state)
                    ST_IDLE: begin
                        asmi_csr_addr_rst_op    = '0;
                        asmi_csr_write_rst_op   = '0;
                        asmi_csr_wrdata_rst_op  = '0;
                        rst_op_active           = '0;
                    end
        
                    ST_SELECT_CHIP_1: begin
                        asmi_csr_addr_rst_op    = 6'd8;
                        asmi_csr_write_rst_op   = 1'b1;
                        asmi_csr_wrdata_rst_op  = 32'h00000000;
                        rst_op_active           = 1'b1;
                    end
                    ST_WE_CHIP_1: begin 
                        asmi_csr_addr_rst_op    = 6'd0;
                        asmi_csr_write_rst_op   = 1'b1;
                        asmi_csr_wrdata_rst_op  = 32'h00000001;
                        rst_op_active           = 1'b1;
                    end
                    ST_EN_4BYTES_CHIP_1: begin
                        asmi_csr_addr_rst_op    = 6'd19;
                        asmi_csr_write_rst_op   = 1'b1;
                        asmi_csr_wrdata_rst_op  = 32'h00000001;
                        rst_op_active           = 1'b1;
                    end
                    ST_SELECT_CHIP_2: begin
                        asmi_csr_addr_rst_op    = 6'd8;
                        asmi_csr_write_rst_op   = 1'b1;
                        asmi_csr_wrdata_rst_op  = 32'h00000010;
                        rst_op_active           = 1'b1;
                    end
                    ST_WE_CHIP_2: begin 
                        asmi_csr_addr_rst_op    = 6'd0;
                        asmi_csr_write_rst_op   = 1'b1;
                        asmi_csr_wrdata_rst_op  = 32'h00000001;
                        rst_op_active           = 1'b1;
                    end
                    ST_EN_4BYTES_CHIP_2: begin
                        asmi_csr_addr_rst_op    = 6'd19;
                        asmi_csr_write_rst_op   = 1'b1;
                        asmi_csr_wrdata_rst_op  = 32'h00000001;
                        rst_op_active           = 1'b1;
                    end
                    ST_SELECT_CHIP_3: begin
                        asmi_csr_addr_rst_op    = 6'd8;
                        asmi_csr_write_rst_op   = 1'b1;
                        asmi_csr_wrdata_rst_op  = 32'h00000020;
                        rst_op_active           = 1'b1;
                    end
                    ST_WE_CHIP_3: begin 
                        asmi_csr_addr_rst_op    = 6'd0;
                        asmi_csr_write_rst_op   = 1'b1;
                        asmi_csr_wrdata_rst_op  = 32'h00000001;
                        rst_op_active           = 1'b1;
                    end
                    ST_EN_4BYTES_CHIP_3: begin
                        asmi_csr_addr_rst_op    = 6'd19;
                        asmi_csr_write_rst_op   = 1'b1;
                        asmi_csr_wrdata_rst_op  = 32'h00000001;
                        rst_op_active           = 1'b1;
                    end
                endcase
            end
        assign waitrequest_local = !(state == ST_IDLE);
        end
        else begin 
            always_ff @(posedge clk) begin 
                asmi_csr_addr_rst_op    <= '0;
                asmi_csr_write_rst_op   <= '0;
                asmi_csr_wrdata_rst_op  <= '0;
                rst_op_active           <= '0;
                waitrequest_local       <= '0;
            end
        end
    endgenerate

    // +-------------------------------------------------------
    // | Output signals to ASMI
    // +-------------------------------------------------------
    assign asmi_csr_op      = bulk_erase_combi || sector_erase_combi || sector_protect_combi || write_en_combi || write_flag_status_combi || write_sce_combi;
    assign asmi_csr_addr    = rst_op_active ? asmi_csr_addr_rst_op : asmi_csr_addr_csr_op;
    assign asmi_csr_read    = read_status_combi || read_rdid_combi || read_flag_status_combi || read_device_id_0_combi || read_device_id_1_combi || read_device_id_2_combi || read_device_id_3_combi || read_device_id_4_combi;
    assign asmi_csr_write   = rst_op_active ? asmi_csr_write_rst_op : asmi_csr_op;
    assign asmi_csr_wrdata  = rst_op_active ? asmi_csr_wrdata_rst_op : asmi_csr_wrdata_csr_op;
    // These are read operations that do not get data from flashes
    // - isr, imr
    // - read from CSR that is write only - return last written value
    assign read_op_without_flash = read_isr_combi || read_imr_combi || read_sce_combi || read_csr_mem_op_combi || read_sid_combi;

    // +-------------------------------------------------------
    // | EPCQ Controller2 Logic
    // +-------------------------------------------------------
    // access CSR decoding logic
    assign access_csr_status        = (avl_csr_addr == 4'd0);
    assign access_csr_sid           = (avl_csr_addr == 4'd1);
    assign access_csr_rdid          = (avl_csr_addr == 4'd2);
    assign access_csr_mem_op        = (avl_csr_addr == 4'd3);
    assign access_isr               = (avl_csr_addr == 4'd4);
    assign access_imr               = (avl_csr_addr == 4'd5);
    assign access_sce               = (avl_csr_addr == 4'd6);
    assign access_csr_flag_status   = (avl_csr_addr == 4'd7);
    assign access_device_id_0       = (avl_csr_addr == 4'd8);
    assign access_device_id_1       = (avl_csr_addr == 4'd9);
    assign access_device_id_2       = (avl_csr_addr == 4'd10);
    assign access_device_id_3       = (avl_csr_addr == 4'd11);
    assign access_device_id_4       = (avl_csr_addr == 4'd12);
        
    // read csr logic   
    assign read_status_combi        = (avl_csr_read && access_csr_status && ~avl_csr_waitrequest);
    assign read_flag_status_combi   = (avl_csr_read && access_csr_flag_status && ~avl_csr_waitrequest);
    assign write_flag_status_combi  = (avl_csr_write && access_csr_flag_status && ~avl_csr_waitrequest);
    assign read_rdid_combi          = (avl_csr_read && access_csr_rdid && ~avl_csr_waitrequest);
    assign read_isr_combi           = (avl_csr_read && access_isr && ~avl_csr_waitrequest);
    assign read_imr_combi           = (avl_csr_read && access_imr && ~avl_csr_waitrequest);
    assign write_isr_combi          = (avl_csr_write && access_isr && ~avl_csr_waitrequest);
    assign write_imr_combi          = (avl_csr_write && access_imr && ~avl_csr_waitrequest);
    assign write_sce_combi          = (avl_csr_write && access_sce && ~avl_csr_waitrequest);
    // not directly interact with flash and write only
    assign read_sce_combi           = (avl_csr_read && access_sce && ~avl_csr_waitrequest);
    assign write_csr_mem_op_combi   = (avl_csr_write && access_csr_mem_op && ~avl_csr_waitrequest);
    assign read_csr_mem_op_combi    = (avl_csr_read && access_csr_mem_op && ~avl_csr_waitrequest);

    assign write_device_id_0_combi  = (avl_csr_write && access_device_id_0 && ~avl_csr_waitrequest);
    assign read_device_id_0_combi   = (avl_csr_read && access_device_id_0 && ~avl_csr_waitrequest);
    assign write_device_id_1_combi  = (avl_csr_write && access_device_id_1 && ~avl_csr_waitrequest);
    assign read_device_id_1_combi   = (avl_csr_read && access_device_id_1 && ~avl_csr_waitrequest);
    assign write_device_id_2_combi  = (avl_csr_write && access_device_id_2 && ~avl_csr_waitrequest);
    assign read_device_id_2_combi   = (avl_csr_read && access_device_id_2 && ~avl_csr_waitrequest);
    assign write_device_id_3_combi  = (avl_csr_write && access_device_id_3 && ~avl_csr_waitrequest);
    assign read_device_id_3_combi   = (avl_csr_read && access_device_id_3 && ~avl_csr_waitrequest);
    assign write_device_id_4_combi  = (avl_csr_write && access_device_id_4 && ~avl_csr_waitrequest);
    assign read_device_id_4_combi   = (avl_csr_read && access_device_id_4 && ~avl_csr_waitrequest);
    // Dummy csr operation, silicon id
    assign write_sid_combi          = (avl_csr_write && access_csr_sid && ~avl_csr_waitrequest);
    assign read_sid_combi           = (avl_csr_read && access_csr_sid && ~avl_csr_waitrequest);

    // write csr logic
    assign bulk_erase_combi     = (avl_csr_write && access_csr_mem_op && ~avl_csr_waitrequest && avl_csr_wrdata[1:0] == 2'b01);
    assign sector_erase_combi   = (avl_csr_write && access_csr_mem_op && ~avl_csr_waitrequest && avl_csr_wrdata[1:0] == 2'b10);
    assign sector_protect_combi = (avl_csr_write && access_csr_mem_op && ~avl_csr_waitrequest && avl_csr_wrdata[1:0] == 2'b11);
    assign write_en_combi       = (avl_csr_write && access_csr_mem_op && ~avl_csr_waitrequest && avl_csr_wrdata[2:0] == 3'b100);
    // address remapped
    always_comb begin
        asmi_csr_addr_csr_op    = '0;
        asmi_csr_wrdata_csr_op  = '0;
        case (avl_csr_addr)
            // RD_STATUS
            4'd0: begin  
                asmi_csr_addr_csr_op    = 6'd3;
                asmi_csr_wrdata_csr_op  = '0;
            end
            // RD_SID : not used now since we remove EPCS
            4'd1: begin  
                asmi_csr_addr_csr_op    = 6'd0;
                asmi_csr_wrdata_csr_op  = '0;
            end
            // RD_RID -> memory ID for EPCQ and device ID for QSPI controller
            4'd2: begin 
                asmi_csr_addr_csr_op    = 6'd22;
                asmi_csr_wrdata_csr_op  = '0;
            end
            // MEM_OP: sector protect, sector erase and bulk erase
            4'd3: begin
                asmi_csr_wrdata_csr_op  = '0;
                if (bulk_erase_combi)
                    asmi_csr_addr_csr_op    = 6'd17;
                else if (sector_erase_combi) begin
                    asmi_csr_addr_csr_op    = 6'd4;
                    // set lower 16 bits to zero so that erase at starting address of each sector
                    asmi_csr_wrdata_csr_op = {avl_csr_wrdata[LAST_ADDR_BIT : 8], {16{1'b0}}};   
                end
                else if (sector_protect_combi) begin
                    asmi_csr_addr_csr_op    = 6'd21;
                    // BP3, TB, BP2, BP1, BP0
                    asmi_csr_wrdata_csr_op  = {{1{1'b0}}, avl_csr_wrdata[11], avl_csr_wrdata[12], avl_csr_wrdata[10:8], {2{1'b0}}};
                end
                else if (write_en_combi) begin
                    asmi_csr_addr_csr_op    = 6'd0;
                    asmi_csr_wrdata_csr_op  = 32'h1;
                end
            end
            // ISR
            4'd4: begin 
                asmi_csr_addr_csr_op    = '0;
                asmi_csr_wrdata_csr_op  = '0;
            end
            // IMR
            4'd5: begin 
                asmi_csr_addr_csr_op    = '0;
                asmi_csr_wrdata_csr_op  = '0;
            end
            // CHIP_SELECT
            4'd6: begin 
                asmi_csr_addr_csr_op    = 6'd8;
                asmi_csr_wrdata_csr_op  = 32'h00000000;
                if ((avl_csr_wrdata[2:0] == 3'b001) || (avl_csr_wrdata[2:0] == 3'b000))
                    asmi_csr_wrdata_csr_op[7:4]  = 4'h0;
                else if (avl_csr_wrdata[2:0] == 3'b010)
                    asmi_csr_wrdata_csr_op[7:4]  = 4'h1;
                else if (avl_csr_wrdata[2:0] == 3'b100)
                    asmi_csr_wrdata_csr_op[7:4]  = 4'h2;
            end
            // Flag status
            4'd7: begin
                if (write_flag_status_combi) begin
                    asmi_csr_addr_csr_op    = 6'd16;
                    asmi_csr_wrdata_csr_op  = '0;
                end
                else if (read_flag_status_combi) begin
                    asmi_csr_addr_csr_op    = 6'd15;
                    asmi_csr_wrdata_csr_op  = '0; 
                end
                else begin 
                    asmi_csr_addr_csr_op    = '0;
                    asmi_csr_wrdata_csr_op  = '0;
                end
            end
            4'd8: begin 
                asmi_csr_addr_csr_op    = 6'd23;
                asmi_csr_wrdata_csr_op  = '0;
            end
            4'd9: begin 
                asmi_csr_addr_csr_op    = 6'd24;
                asmi_csr_wrdata_csr_op  = '0;
            end
            4'd10: begin 
                asmi_csr_addr_csr_op    = 6'd25;
                asmi_csr_wrdata_csr_op  = '0;
            end
            4'd11: begin 
                asmi_csr_addr_csr_op    = 6'd26;
                asmi_csr_wrdata_csr_op  = '0;
            end
            4'd12: begin 
                asmi_csr_addr_csr_op    = 6'd27;
                asmi_csr_wrdata_csr_op  = '0;
            end                        
        endcase // case (state)
    end // always_comb

    // +-------------------------------------------------------
    // | ISR logic
    // +-------------------------------------------------------
    // 16.1 does not support illegal_write/erase since dont have time, deassrt all for now
    logic asmi_illegal_write;
    logic asmi_illegal_erase;
    assign asmi_illegal_write   = '0;
    assign asmi_illegal_erase   = '0;

    assign illegal_write_combi  = (asmi_illegal_write) ? 1'b1 :
                                    (write_isr_combi && avl_csr_wrdata[1]) ? 1'b0 : 
                                        illegal_write_reg;
    assign illegal_erase_combi  = (asmi_illegal_erase) ? 1'b1 :
                                    (write_isr_combi && avl_csr_wrdata[0]) ? 1'b0 : 
                                        illegal_erase_reg;
    assign m_illegal_write_combi= (write_imr_combi) ? avl_csr_wrdata[1] : m_illegal_write_reg;
    assign m_illegal_erase_combi= (write_imr_combi) ? avl_csr_wrdata[0] : m_illegal_erase_reg;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            illegal_write_reg           <= '0;
            illegal_erase_reg           <= '0;
            m_illegal_write_reg         <= '0;
            m_illegal_erase_reg         <= '0;
        end
        else begin
            illegal_write_reg           <= illegal_write_combi;
            illegal_erase_reg           <= illegal_erase_combi;
            m_illegal_write_reg         <= m_illegal_write_combi;
            m_illegal_erase_reg         <= m_illegal_erase_combi;
        end
    end
    // interrupt signal
    assign irq = (illegal_write_reg && m_illegal_write_reg) || (illegal_erase_reg && m_illegal_erase_reg);
    // +-------------------------------------------------------
    // | CSR read logic
    // +-------------------------------------------------------
    // Since above use combi logic to convert to ASMI, here store write data for those write only csr
    logic [31:0] write_csr_mem_op_wrdata_reg;
    logic [31:0] write_sce_combi_wrdata_reg;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            write_csr_mem_op_wrdata_reg <= '0;
            write_sce_combi_wrdata_reg  <= '0;
            avl_csr_rddata_valid_local  <= '0;
        end
        else begin
            avl_csr_rddata_valid_local  <= read_op_without_flash;
            if (write_csr_mem_op_combi)
                write_csr_mem_op_wrdata_reg <= avl_csr_wrdata;
            if (write_sce_combi)
                write_sce_combi_wrdata_reg  <= avl_csr_wrdata;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            avl_csr_rddata_local <= {CSR_DATA_WIDTH{1'b0}};
        end
        else begin
            if (read_isr_combi) begin
                avl_csr_rddata_local <= {{CSR_DATA_WIDTH-2{1'b0}}, illegal_write_reg, illegal_erase_reg};
            end
            if (read_imr_combi) begin
                avl_csr_rddata_local <= {{CSR_DATA_WIDTH-2{1'b0}}, m_illegal_write_reg, m_illegal_erase_reg};
            end
            if (read_csr_mem_op_combi) begin 
                avl_csr_rddata_local <= write_csr_mem_op_wrdata_reg;
            end
            if (read_sce_combi) begin 
                avl_csr_rddata_local <= write_sce_combi_wrdata_reg;
            end
            if (read_sid_combi) begin
                avl_csr_rddata_local <= {CSR_DATA_WIDTH{1'b0}};
            end
        end
    end

    // +-------------------------------------------------------
    // | EPCQ Controller2 CSR Output signals
    // +-------------------------------------------------------
    assign avl_csr_waitrequest  = asmi_csr_waitrequest || waitrequest_local;
    assign avl_csr_rddata_valid = asmi_csr_rddata_valid || avl_csr_rddata_valid_local;
    assign avl_csr_rddata       = avl_csr_rddata_valid_local ? avl_csr_rddata_local : asmi_csr_rddata;

    // +-------------------------------------------------------------------------------------------------------------
    // | MEM Write and Read logic
    // +-------------------------------------------------------------------------------------------------------------
    // read/write memory combi logic
    assign read_mem_combi       = (avl_mem_read && ~avl_mem_waitrequest);
    assign write_mem_combi      = (avl_mem_write && ~avl_mem_waitrequest);

        // chip select
    generate if (DEVICE_FAMILY == "Arria 10") begin
        always @(posedge clk or posedge reset) begin
            if (reset) begin
                chip_select            <= {CS_WIDTH{1'b0}};
            end 
    // to pack the address space this is needed
            else if (write_mem_combi || read_mem_combi) begin
                if (CHIP_SELS == 1 )                    
                    chip_select            <= 4'd0;
                else if (CHIP_SELS == 2 && avl_mem_addr[ADDR_WIDTH-1] == 0) 
                    chip_select            <= 4'd0;
                else if (CHIP_SELS == 2 && avl_mem_addr[ADDR_WIDTH-1] == 1) 
                    chip_select            <= 4'd1;
                else if (CHIP_SELS == 3 && avl_mem_addr[ADDR_WIDTH-1] == 1) 
                    chip_select            <= 4'd2;
                else if (CHIP_SELS == 3 && avl_mem_addr[ADDR_WIDTH-1:ADDR_WIDTH-2] == 0)    
                    chip_select            <= 4'd0;
                else if (CHIP_SELS == 3 && avl_mem_addr[ADDR_WIDTH-1:ADDR_WIDTH-2] == 1)    
                    chip_select            <= 4'd1;
                else
                    chip_select            <= 4'h0;
            end
        end
    // decoder ring  if the CHIP_SEL is only 1 then avalon address is the temp address
    //      if the chipsele is 2 then need to remove top address bit
    //      if the chipelect is 3 then remove the top 2 address bits.  
    assign temp_mem_addr    = CHIP_SELS == 1 ? avl_mem_addr:( CHIP_SELS == 2 ? {1'b0,avl_mem_addr[ADDR_WIDTH-2:0]}:{2'b00,avl_mem_addr[ADDR_WIDTH-3:0]});
    end
    else begin
        always @(posedge clk) begin
            chip_select                <= {CS_WIDTH{1'b0}};
        end
        assign temp_mem_addr    = avl_mem_addr;
    end
    endgenerate

    // +-------------------------------------------------------
    // | EPCQ Controller2 MEM Output signals
    // +-------------------------------------------------------
    assign avl_mem_rddata           = asmi_mem_rddata;
    assign avl_mem_rddata_valid     = asmi_mem_rddata_valid;
    assign avl_mem_waitrequest      = asmi_mem_waitrequest || waitrequest_local;

    //assign asmi_mem_addr            = temp_mem_addr;
    assign asmi_mem_addr            = {{31-ADDR_WIDTH{1'b0}}, temp_mem_addr};
    

    assign asmi_mem_read            = avl_mem_read & !avl_mem_waitrequest;
    assign asmi_mem_write           = avl_mem_write & !avl_mem_waitrequest;
    assign asmi_mem_wrdata          = avl_mem_wrdata;
    assign asmi_mem_byteenable      = avl_mem_byteenable;
    assign asmi_mem_burstcount      = avl_mem_burstcount;

endmodule

    
    // assign csr_wr_enable                = (csr_addr == 6'd0);
    // assign csr_wr_disable               = (csr_addr == 6'd1);
    // assign csr_wr_status                = (csr_addr == 6'd2);
    // assign csr_rd_status                = (csr_addr == 6'd3);
    // assign csr_sector_erase             = (csr_addr == 6'd4);
    // assign csr_subsector_erase          = (csr_addr == 6'd5);
    // assign csr_isr                      = (csr_addr == 6'd6);
    // assign csr_ier                      = (csr_addr == 6'd7);
    // assign csr_control                  = (csr_addr == 6'd8);
    // // These CSRs are reserved or not avaiable in some configuration, 
    // // User write to these, nothing. Read will be return dummy values
    // // This avoids system hang
    // assign csr_status                   = (csr_addr == 6'd9);
    // assign csr_com_10                   = (csr_addr == 6'd10);
    // assign csr_com_11                   = (csr_addr == 6'd11);
    // assign csr_com_12                   = (csr_addr == 6'd12);
    // // These register can be double meanings. So cannot use specific name.
    // // Fro some devices, they do some specific operation, but from some, 
    // // they are unavaiablein RTL, development, check on those localparam to decide if this 
    // // register enable or disable. 
    // // The mapping here shown each csr_misc_xx meaning, when generate the IP.
    // // csr_misc_13    : wr_NVCR
    // // csr_misc_14    : rd_NVCR
    // // csr_misc_15    : rd_flag_status
    // // csr_misc_16    : clr_flag_status
    // // csr_misc_17    : bulk_erase/chip_erase
    // // csr_misc_18    : NA
    // // csr_misc_19    : 4bytes_addr_en
    // // csr_misc_20    : 4bytes_addr_ex
    // // csr_misc_21    : sector_protect
    // // csr_misc_22    : rd_memory_capacity_id
    // assign csr_misc_13                  = (csr_addr == 6'd13);
    // assign csr_misc_14                  = (csr_addr == 6'd14);
    // assign csr_misc_15                  = (csr_addr == 6'd15);
    // assign csr_misc_16                  = (csr_addr == 6'd16);
    // assign csr_misc_17                  = (csr_addr == 6'd17);
    // assign csr_misc_18                  = (csr_addr == 6'd18);
    // assign csr_4bytes_addr_en           = (csr_addr == 6'd19);
    // assign csr_4bytes_addr_ex           = (csr_addr == 6'd20);
    // assign csr_sector_protect           = (csr_addr == 6'd21);
    // // For EPCQ, this is read memory capacity
    // assign csr_rd_device_id             = (csr_addr == 6'd22);
    // // If EPCQ, these CSRs are not avaiable, read return 0
    // // These CSRs are turn on/off deopend the local parame CSR_EXTRA_EN
    // assign csr_device_id_data_0         = (csr_addr == 6'd23);
    // assign csr_device_id_data_1         = (csr_addr == 6'd24);
    // assign csr_device_id_data_2         = (csr_addr == 6'd25);
    // assign csr_device_id_data_3         = (csr_addr == 6'd26);
    // assign csr_device_id_data_4         = (csr_addr == 6'd27);
