// nios_core_epcq_controller_0_asmi_parallel_instance_name.v

// Generated using ACDS version 18.1 625

`timescale 1 ps / 1 ps
module nios_core_epcq_controller_0_asmi_parallel_instance_name (
		input  wire        clkin,          //          clkin.clk
		input  wire        fast_read,      //      fast_read.fast_read
		input  wire        rden,           //           rden.rden
		input  wire [23:0] addr,           //           addr.addr
		input  wire        read_status,    //    read_status.read_status
		input  wire        write,          //          write.write
		input  wire [7:0]  datain,         //         datain.datain
		input  wire        shift_bytes,    //    shift_bytes.shift_bytes
		input  wire        sector_protect, // sector_protect.sector_protect
		input  wire        sector_erase,   //   sector_erase.sector_erase
		input  wire        bulk_erase,     //     bulk_erase.bulk_erase
		input  wire        wren,           //           wren.wren
		input  wire        read_rdid,      //      read_rdid.read_rdid
		input  wire        reset,          //          reset.reset
		input  wire        read_dummyclk,  //  read_dummyclk.read_dummyclk
		output wire [7:0]  dataout,        //        dataout.dataout
		output wire        busy,           //           busy.busy
		output wire        data_valid,     //     data_valid.data_valid
		output wire [7:0]  status_out,     //     status_out.status_out
		output wire        illegal_write,  //  illegal_write.illegal_write
		output wire        illegal_erase,  //  illegal_erase.illegal_erase
		output wire [7:0]  rdid_out        //       rdid_out.rdid_out
	);

	nios_core_epcq_controller_0_asmi_parallel_instance_name_asmi_parallel_instance_name asmi_parallel_instance_name (
		.clkin          (clkin),          //          clkin.clk
		.fast_read      (fast_read),      //      fast_read.fast_read
		.rden           (rden),           //           rden.rden
		.addr           (addr),           //           addr.addr
		.read_status    (read_status),    //    read_status.read_status
		.write          (write),          //          write.write
		.datain         (datain),         //         datain.datain
		.shift_bytes    (shift_bytes),    //    shift_bytes.shift_bytes
		.sector_protect (sector_protect), // sector_protect.sector_protect
		.sector_erase   (sector_erase),   //   sector_erase.sector_erase
		.bulk_erase     (bulk_erase),     //     bulk_erase.bulk_erase
		.wren           (wren),           //           wren.wren
		.read_rdid      (read_rdid),      //      read_rdid.read_rdid
		.reset          (reset),          //          reset.reset
		.read_dummyclk  (read_dummyclk),  //  read_dummyclk.read_dummyclk
		.dataout        (dataout),        //        dataout.dataout
		.busy           (busy),           //           busy.busy
		.data_valid     (data_valid),     //     data_valid.data_valid
		.status_out     (status_out),     //     status_out.status_out
		.illegal_write  (illegal_write),  //  illegal_write.illegal_write
		.illegal_erase  (illegal_erase),  //  illegal_erase.illegal_erase
		.rdid_out       (rdid_out)        //       rdid_out.rdid_out
	);

endmodule