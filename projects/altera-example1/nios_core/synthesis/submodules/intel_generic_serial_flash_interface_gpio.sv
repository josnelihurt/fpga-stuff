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
module intel_generic_serial_flash_interface_gpio #(
    parameter NCS_LENGTH    = 3,
    parameter DATA_LENGTH   = 4
) (
    input                           atom_ports_dclk,
    input [NCS_LENGTH-1:0]          atom_ports_ncs,
    input                           atom_ports_oe,
    input [DATA_LENGTH-1:0]         atom_ports_dataout,
    input [DATA_LENGTH-1:0]         atom_ports_dataoe,
        
    output logic [DATA_LENGTH-1:0]  atom_ports_datain,
    
    output logic                    qspi_pins_dclk,
    output logic [NCS_LENGTH-1:0]   qspi_pins_ncs,
    
    inout [DATA_LENGTH-1:0]         qspi_pins_data
);

    logic [DATA_LENGTH-1:0]  data_buf;

    genvar i;
    generate
        for (i=0; i<DATA_LENGTH; i++) begin : data_bidir_inst
            assign qspi_pins_data[i] = (atom_ports_oe === '0) ?  data_buf[i] : 1'bz;
            assign data_buf[i] = (atom_ports_dataoe[i] === 1'b1) ? atom_ports_dataout[i] : 1'bz;
            assign atom_ports_datain[i] = qspi_pins_data[i];
        end
    endgenerate
    
    assign qspi_pins_dclk = (atom_ports_oe === '0) ? atom_ports_dclk : 1'bz;
    assign qspi_pins_ncs = (atom_ports_oe === '0) ? atom_ports_ncs : 1'bz;   
   
endmodule