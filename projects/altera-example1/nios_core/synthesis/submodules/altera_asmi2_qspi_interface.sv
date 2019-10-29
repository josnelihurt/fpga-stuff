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



`timescale 1 ns / 1 ns
module altera_asmi2_qspi_interface #(
    parameter DEV_FAMILY    = "Arria 10",   
    parameter NCS_LENGTH    = 3,            // number of FPGA SPI NCS interfaces
    parameter DATA_LENGTH   = 4,            // number of FPGA SPI Data interfaces
    parameter MODE_LENGTH   = 1,             // SPI Data interfaces in used for selected mode
    parameter ENABLE_SIM_MODEL    = "false"       // use of embedded flash model
) (
    input               clk,
    input               reset,

    input [1:0]         in_cmd_channel,     // WY: not using, remove
    input               in_cmd_eop,
    output logic        in_cmd_ready,
    input               in_cmd_sop,
    input [7:0]         in_cmd_data,
    input               in_cmd_valid,

    output logic [7:0]  out_rsp_data,   
    input               out_rsp_ready,      // WY: flash could not be backpressure, remove
    output logic        out_rsp_valid,

    input [3:0]         chip_select,        // Chip select values
    
    input [4:0]         dummy_cycles,
    input               qspi_interface_en,
    input               require_rdata
);
    
    localparam RW_COUNTER_WIDTH         = 4;        // use for read or write 
    localparam WAIT_COUNTER_WIDTH       = 5;        // use for wait
    localparam BYTE_CLK		            = 4'h8;	
    localparam DATA_CLK                 = 4'h8;

    typedef enum logic [11:0]
    {STATE_IDLE, STATE_OPCODE, STATE_FIRST_DATA, STATE_WDATA, STATE_LOAD_DATA, STATE_DUMMY_CLK, 
        STATE_SWITCH_OE, STATE_RDATA, STATE_LOAD_RDATA, STATE_PRE_COMPLETE, STATE_COMPLETE} current_t;
    current_t current_state, next_state;

    logic                   oe_wire;

    logic ncs_active_state;     
    logic [15:0]            ncs_active_wire;
   
    logic [NCS_LENGTH-1:0]  ncs_wire;
    logic [NCS_LENGTH-1:0]  ncs_reg;
    
    logic [DATA_LENGTH-1:0] dataout_wire;
    logic [DATA_LENGTH-1:0] dataoe_wire;
    logic [DATA_LENGTH-1:0] datain_wire;
    
    logic [MODE_LENGTH-1:0] outgoing_data;
    logic [MODE_LENGTH-1:0] incoming_data;
    
    logic [7:0] dataout_reg;
    logic [7:0] datain_reg;
    
    logic [RW_COUNTER_WIDTH-1:0] write_cnt_q;
    logic [RW_COUNTER_WIDTH-1:0] write_cnt_next;
    logic [RW_COUNTER_WIDTH-1:0] write_cnt_val;
    logic write_cnt_done;
    
    logic [WAIT_COUNTER_WIDTH-1:0] wait_cnt_q;
    logic [WAIT_COUNTER_WIDTH-1:0] wait_cnt_next;
    logic [WAIT_COUNTER_WIDTH-1:0] wait_cnt_val;
    logic wait_cnt_done;
    
    logic [RW_COUNTER_WIDTH-1:0] read_cnt_q;
    logic [RW_COUNTER_WIDTH-1:0] read_cnt_next;
    logic [RW_COUNTER_WIDTH-1:0] read_cnt_val;
    logic read_cnt_done;
    
    logic last_data;
    logic xip_fast_rw;
    
    // Use to indicate last write data, not timing critical
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            last_data <= '0;
        else if (in_cmd_eop && in_cmd_valid && in_cmd_ready)
            last_data <= 1'b1;
        else if (current_state == STATE_COMPLETE)
            last_data <= '0;
    end
    
    // Use dummy_cycles > '0 to decide whether this is XIP fast read/write.
    // If yes, split the data after sending opcode. Not timing critical.
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            xip_fast_rw <= '0;
        else if (in_cmd_sop && in_cmd_valid && in_cmd_ready && (dummy_cycles > '0))
            xip_fast_rw <= 1'b1;
        else if (current_state == STATE_COMPLETE)
            xip_fast_rw <= '0;
    end
    

// *********************************************************************************   
//      RTL State Machine
// *********************************************************************************
// STATE_IDLE       : Idle state that wait for valid startofpacket.
//                      If in_cmd_sop and in_cmd_valid are asserted, go to STATE_OPCODE.
// STATE_OPCODE     : Send 8-bits opcode to flash (6-bits in this state, remaining 2-bits in next states). 
//				        If more than one data, go to STATE_FIRST_DATA.
//				        Else if have data to read, go to STATE_RDATA.
//                      Else, go to STATE_PRE_COMPLETE.
// STATE_FIRST_DATA : Send second last of previous data to flash. Load new data to shiftreg, go to STATE_WDATA.
// STATE_WDATA      : Send last of previous data to flash. Continue send new 8-bits data to flash (6-bits in this state, remaining 2-bits in next states).
//				        If more data, go back to STATE_LOAD_DATA.
//				        Else if hit valid endofpacket,
//					        If require_rdata is asserted and  
//                              If dummy_cycles is not 0, go to STATE_DUMMY_CLK.
//                              Else go to STATE_RDATA.
//                          Else go to STATE_PRE_COMPLETE.
// STATE_LOAD_DATA  : Send second last of previous data to flash. Load new data to shiftreg, go to STATE_WDATA.
// STATE_DUMMY_CLK  : Wait for dummy clock cycles count as stated in dummy_cycles, go to STATE_SWITCH_OE.
// STATE_SWITCH_OE  : Switch dataoe to input mode, go to STATE_RDATA.
// STATE_RDATA      : Read 8-bits data, go to STATE_LOAD_RDATA.
// STATE_LOAD_RDATA	: Load data to out_rsp_data.
//				        If require_rdata is still asserted, go to STATE_RDATA
//				        else, go to STATE_COMPLETE.
// STATE_PRE_COMPLETE   : Send second last data to flash, go to STATE_COMPLETE.
// STATE_COMPLETE   : Send last data to flash andd pull-high ncs, before going back to STATE_IDLE.
    always_comb begin
        in_cmd_ready = '0;
        next_state   = current_state;
        
        case (current_state)
            STATE_IDLE: begin
                in_cmd_ready = 1'b1;
                if (in_cmd_sop && in_cmd_valid)
                    next_state      = STATE_OPCODE;
            end
            
            STATE_OPCODE: begin
                if (write_cnt_done) begin
                    if (last_data)
                        if (~require_rdata)
                            next_state = STATE_PRE_COMPLETE;
                        else
                            next_state = STATE_RDATA;  
                    else
                        next_state  = STATE_FIRST_DATA;
                end
            end
            
            STATE_FIRST_DATA: begin
                in_cmd_ready = 1'b1;
                if (in_cmd_valid)
                    next_state  = STATE_WDATA;
            end
            
            STATE_WDATA: begin                
                if (write_cnt_done) begin
                    if (last_data) begin
                        if (require_rdata) begin
                            if (dummy_cycles > '0)
                                next_state = STATE_DUMMY_CLK;
                            else 
                                next_state = STATE_RDATA;      
                        end
                        else
                            next_state = STATE_PRE_COMPLETE;
                    end
                    else
                        next_state  = STATE_LOAD_DATA;
                end
            end
            
            STATE_LOAD_DATA: begin
            	in_cmd_ready = 1'b1;
                if (in_cmd_valid)
                    next_state  = STATE_WDATA;
            end
            
            STATE_DUMMY_CLK: begin
                if (wait_cnt_done) 
                    next_state      = STATE_SWITCH_OE;
            end
            
            STATE_SWITCH_OE: begin
                next_state = STATE_RDATA;
            end
            
            STATE_RDATA: begin
                if (~require_rdata) 
                    next_state = STATE_COMPLETE;
                else if (read_cnt_done)
                    next_state = STATE_LOAD_RDATA;
            end
            
            STATE_LOAD_RDATA: begin                    
                if (require_rdata) 
                    next_state = STATE_RDATA;
                else
                    next_state = STATE_COMPLETE;
            end
            
            STATE_PRE_COMPLETE:
                next_state = STATE_COMPLETE;
            
            STATE_COMPLETE:
                next_state = STATE_IDLE;
        endcase
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= STATE_IDLE;
        else
            current_state <= next_state;
    end
    
 
// *********************************************************************************
//      oe, active low, qspi_interface_en must be registered in previous component
// ********************************************************************************* 
    assign oe_wire  = ~qspi_interface_en;

    
// *********************************************************************************
//      ncs, active low, launch at negedge    
// ********************************************************************************* 
    //log base 2    
    function integer log2;
      input integer val;
      begin
         log2 = 0;
         while (val > 0) begin
            val = val >> 1;
            log2 = log2 + 1;
         end
      end
    endfunction
    
    localparam ONE_HOT_WIDTH = 16;
    localparam LOG_WIDTH = log2(ONE_HOT_WIDTH-1);

    // convert chip_select to one-hot signal
    always @(chip_select) begin
        ncs_active_wire = 0;
        ncs_active_wire[chip_select] = 1'b1;
    end
    
    assign ncs_active_state = (current_state == STATE_OPCODE || current_state == STATE_FIRST_DATA 
                                    || current_state == STATE_LOAD_DATA || current_state == STATE_PRE_COMPLETE 
                                    || current_state == STATE_WDATA || current_state == STATE_DUMMY_CLK 
                                    || current_state == STATE_SWITCH_OE || current_state == STATE_RDATA 
                                    || current_state == STATE_LOAD_RDATA);

    genvar i;
    generate
        for (i=0; i<NCS_LENGTH; i++) begin : ncs_active_inst
            assign ncs_wire[i] = ~ncs_active_wire[i] || ~ncs_active_state;
        end
    endgenerate
    
    always_ff @(negedge clk or posedge reset) begin
        if (reset)
            ncs_reg <= {NCS_LENGTH{1'b1}};
        else
            ncs_reg <= ncs_wire;
    end

    
// ********************************************************************************* 
//      dataoe, 1=output, 0=input, not timing critical
// *********************************************************************************
    generate
        if (DATA_LENGTH == 4)  
            assign dataoe_wire  = {1'b1, 1'b1, '0, 1'b1};
        else
            assign dataoe_wire  = {'0, 1'b1};
    endgenerate
    


// *********************************************************************************
//      dataout(launch at negedge), 
//      using free running clock, so previous component must send data continuously
// ********************************************************************************* 

    generate
        if (DATA_LENGTH == 4)  
            assign dataout_wire = {1'b1, 1'b1, '0, outgoing_data};
        else
            assign dataout_wire = {'0, outgoing_data};
    endgenerate
    
    always_ff @(negedge clk or posedge reset) begin
        if (reset)
            dataout_reg <= '0;
        else if ((current_state == STATE_IDLE || current_state == STATE_FIRST_DATA || current_state == STATE_LOAD_DATA) 
                    && in_cmd_valid && in_cmd_ready)
            dataout_reg <= in_cmd_data;
        else if (current_state == STATE_OPCODE || current_state == STATE_WDATA || current_state == STATE_PRE_COMPLETE  || current_state == STATE_DUMMY_CLK)
            dataout_reg <= {dataout_reg[6:0], '0};
    end
    
    always_ff @(negedge clk or posedge reset) begin
        if (reset)
            outgoing_data <= '0;
        else
            outgoing_data <= dataout_reg[7];
    end
    


// *********************************************************************************
//      write/wait counter to transfer data to flash
// *********************************************************************************
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            write_cnt_q <= '0;
        else begin
            if (current_state == STATE_IDLE)
                write_cnt_q <= BYTE_CLK - 4'h2;
            else if (current_state == STATE_FIRST_DATA || current_state == STATE_LOAD_DATA)
                write_cnt_q <= write_cnt_val;
            else 
                write_cnt_q <= write_cnt_next;
        end
    end
    
    always_comb begin
        write_cnt_next = write_cnt_q;
        if (current_state == STATE_OPCODE || current_state == STATE_WDATA) begin
            write_cnt_next = write_cnt_q - 4'h1;
            if (write_cnt_done)
                write_cnt_next = write_cnt_val;
        end
    end
    
    assign write_cnt_done   = (write_cnt_q == '0 && 
                                (current_state == STATE_OPCODE || current_state == STATE_WDATA)); 
    assign write_cnt_val    = xip_fast_rw ? (DATA_CLK - 4'h2) : (BYTE_CLK - 4'h2);   
    
    
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            wait_cnt_q <= '0;
        else begin
            if (current_state == STATE_WDATA)
                wait_cnt_q <= wait_cnt_val;
            else 
                wait_cnt_q <= wait_cnt_next;
        end
    end
    
    always_comb begin
        wait_cnt_next = wait_cnt_q;
        if (current_state == STATE_DUMMY_CLK) begin
            wait_cnt_next = wait_cnt_q - 5'h1;
            if (wait_cnt_done)
                wait_cnt_next = wait_cnt_val;
        end
    end
    
    assign wait_cnt_done    = (wait_cnt_q == '0 && current_state == STATE_DUMMY_CLK); 
    assign wait_cnt_val     = dummy_cycles - 5'h1;
    
    
// *********************************************************************************
//      datain(read at posedge) 
// ********************************************************************************* 
    always_ff @(negedge clk or posedge reset) begin
        if (reset)
            incoming_data <= '0;
        else
            incoming_data <= datain_wire[1];
    end
    
    always_ff @(negedge clk or posedge reset) begin
        if (reset)
            datain_reg <= '0;
        else
            datain_reg <= {datain_reg[6:0], incoming_data};
    end
    

// *********************************************************************************
//      read counter to flag response to previous component
// *********************************************************************************
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            read_cnt_q <= '0;
        else begin
            if (current_state == STATE_OPCODE || current_state == STATE_WDATA)
                read_cnt_q <= BYTE_CLK + 4'h1;
            else if (current_state == STATE_DUMMY_CLK)
                read_cnt_q <= DATA_CLK;
            else if (current_state == STATE_LOAD_RDATA)
                read_cnt_q <= read_cnt_val;
            else 
                read_cnt_q <= read_cnt_next;
        end
    end
    
    always_comb begin
        read_cnt_next = read_cnt_q;
        if (current_state == STATE_RDATA) begin
            read_cnt_next = read_cnt_q - 4'h1;
            if (read_cnt_done)
                read_cnt_next = read_cnt_val;
        end
    end
    
    assign read_cnt_done    = (read_cnt_q == '0 && current_state == STATE_RDATA);
    assign read_cnt_val     = xip_fast_rw ? (DATA_CLK - 4'h2) : (BYTE_CLK - 4'h2); 
    
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            out_rsp_data    <= '0;
            out_rsp_valid   <= '0;
        end
        else if (current_state == STATE_LOAD_RDATA) begin
            out_rsp_data    <= datain_reg;
            out_rsp_valid   <= 1'b1;
        end
        else begin
            out_rsp_data    <= out_rsp_data;
            out_rsp_valid   <= '0;            
        end
    end

   
// ********************************************************************************* 
//      QSPI interfaces 
// *********************************************************************************   
// feed to asmiblock
    altera_asmi2_qspi_interface_asmiblock #(
        .DEVICE_FAMILY(DEV_FAMILY),
        .NCS_LENGTH(NCS_LENGTH),
        .DATA_LENGTH(DATA_LENGTH),
        .ENABLE_SIM_MODEL(ENABLE_SIM_MODEL)
    ) dedicated_interface (
        .atom_ports_dclk(clk),
        .atom_ports_ncs(ncs_reg),
        .atom_ports_oe(oe_wire),
        .atom_ports_dataout(dataout_wire),
        .atom_ports_dataoe(dataoe_wire),
        .atom_ports_datain(datain_wire));
        
endmodule 


