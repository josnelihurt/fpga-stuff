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


// altera_asmi2_csr_controller.v

`timescale 1 ps / 1 ps
module nios_core_epcq_controller2_0_asmi2_inst_epcq_ctrl_csr_controller #(
		parameter WR_ID_LIST          = "1",
		parameter WR_OPERATION_LIST   = "1",
		parameter WR_OPCODE_LIST      = "1",
		parameter RD_ID_LIST          = "1",
		parameter RD_OPERATION_LIST   = "1",
		parameter RD_OPCODE_LIST      = "1",
		parameter COM_ID              = "1",
		parameter COM_OPERATION       = "01",
		parameter COM_OPCODE          = "0",
		parameter COM_ADDR_BYTES      = "0",
		parameter COM_DATA_IN_BYTES   = "0",
		parameter COM_DATA_OUT_BYTES  = "0",
		parameter COM_DUMMY_BYTES     = "0",
		parameter MISC_ID             = "1",
		parameter MISC_OPERATION      = "01",
		parameter MISC_OPCODE         = "0",
		parameter MISC_ADDR_BYTES     = "0",
		parameter MISC_DATA_IN_BYTES  = "0",
		parameter MISC_DATA_OUT_BYTES = "0",
		parameter MISC_DUMMY_BYTES    = "0",
		parameter WR_ID               = "1",
		parameter WR_OPERATION        = "01",
		parameter WR_OPCODE           = "0",
		parameter WR_ENABLE           = "0",
		parameter WR_DUMMY_BYTES      = "0",
		parameter WR_ADDR_BYTES       = "0",
		parameter RD_ID               = "1",
		parameter RD_OPERATION        = "01",
		parameter RD_OPCODE           = "0",
		parameter RD_ADDR_BYTES       = "0",
		parameter RD_DUMMY_BYTES      = "0",
		parameter RD_ENABLE           = "0",
		parameter ADD_W               = 6
	) (
		input        [ADD_W-1:0]  	csr_addr,        
		input               		csr_rd,          
		output logic [31:0] 		csr_rddata,      
		input               		csr_wr,          
		input        [31:0] 		csr_wrdata,      
		output logic        		csr_waitrequest, 
		output logic        		csr_rddatavalid, 
		input               		clk,             
		input               		reset,           
		output logic  [1:0] 		cmd_channel,     
		output logic        		cmd_eop,         
		input               		cmd_ready,       
		output logic        		cmd_sop,         
		output logic [31:0] 		cmd_data,        
		output logic        		cmd_valid,       
		input         [1:0] 		rsp_channel,     
		input        [31:0] 		rsp_data,        
		input               		rsp_eop,         
		output logic        		rsp_ready,       
		input               		rsp_sop,         
		input               		rsp_valid,
		output logic [31:0] 		addr_bytes_csr,
		output logic 				qspi_interface_en

	);

	// +-------------------------------------------------------------------------------------------
	// | Local params
	// +-------------------------------------------------------------------------------------------
	// localparam  CSR_COM_EN_XX   = Y; To indicate this CSR is enable or not-depend on flash type
	// 									a csr register does something NA
	// localparam  CSR_MISC_RD_ONLY_XX = Y; To indicate this CSR is RD only (mostly for read operation)
	// 										of write only (can write address or data).

	localparam  CSR_COM_EN_10   = 0;
	localparam  CSR_COM_EN_11   = 0;
	localparam  CSR_COM_EN_12   = 0;
	localparam  CSR_MISC_EN_13  = 1;
	localparam  CSR_MISC_WR_ONLY_13 = 1;
	localparam  CSR_MISC_EN_14  = 1;
	localparam  CSR_MISC_WR_ONLY_14 = 0;
	localparam  CSR_MISC_EN_15  = 1;
	localparam  CSR_MISC_WR_ONLY_15 = 0;
	localparam  CSR_MISC_EN_16  = 1;
	localparam  CSR_MISC_WR_ONLY_16 = 1;
	localparam  CSR_MISC_EN_17  = 1;
	localparam  CSR_MISC_WR_ONLY_17 = 1;
	localparam  CSR_MISC_EN_18  = 0;
	localparam  CSR_MISC_WR_ONLY_18 = 1;
	localparam  CSR_MISC_EN_19  = 0;
	localparam  CSR_MISC_WR_ONLY_19 = 1;
	localparam  CSR_MISC_EN_20  = 0;
	localparam  CSR_MISC_WR_ONLY_20 = 1;
	localparam  CSR_MISC_EN_21  = 1;
	localparam  CSR_MISC_WR_ONLY_21 = 1;
	localparam  CSR_MISC_EN_22  = 1;
	localparam  CSR_MISC_WR_ONLY_22 = 0;
	localparam  IS_READ_MEMORY_CAPACITY  = 1;

	localparam  CSR_EXTRA_EN_23 = 0;
	localparam  CSR_EXTRA_RD_ONLY_23 = 1;	
	localparam  CSR_EXTRA_EN_24 = 0;
	localparam  CSR_EXTRA_RD_ONLY_24 = 1;	
	localparam  CSR_EXTRA_EN_25 = 0;
	localparam  CSR_EXTRA_RD_ONLY_25 = 1;	
	localparam  CSR_EXTRA_EN_26 = 0;
	localparam  CSR_EXTRA_RD_ONLY_26 = 1;	
	localparam  CSR_EXTRA_EN_27 = 0;
	localparam  CSR_EXTRA_RD_ONLY_27 = 1;	

	// +-------------------------------------------------------------------------------------------
	// | Internal signals
	// +-------------------------------------------------------------------------------------------
	logic csr_wr_enable;
	logic csr_wr_disable;
	logic csr_wr_status;
	logic csr_rd_status;
	logic csr_sector_erase;
	logic csr_subsector_erase;
	logic csr_isr;
	logic csr_ier;
	logic csr_control;
	logic csr_status;
	logic csr_com_10;
	logic csr_com_11;
	logic csr_com_12;
	logic csr_misc_13;
	logic csr_misc_14;
	logic csr_misc_15;
	logic csr_misc_16;
	logic csr_misc_17;
	logic csr_misc_18;
	logic csr_4bytes_addr_en;
	logic csr_4bytes_addr_ex;
	logic csr_sector_protect;
	logic csr_rd_device_id;
	logic csr_device_id_data_0;
	logic csr_device_id_data_1;
	logic csr_device_id_data_2;
	logic csr_device_id_data_3;
	logic csr_device_id_data_4;

	logic write_csr_wr_enable;
	logic write_csr_wr_disable;
	logic write_csr_wr_status;
	logic write_csr_rd_status;
	logic write_csr_sector_erase;
	logic write_csr_subsector_erase;
	logic write_csr_isr;
	logic write_csr_ier;
	logic write_csr_control;
	logic write_csr_status;
	logic write_csr_com_10;
	logic write_csr_com_11;
	logic write_csr_com_12;
	logic write_csr_misc_13;
	logic write_csr_misc_14;
	logic write_csr_misc_15;
	logic write_csr_misc_16;
	logic write_csr_misc_17;
	logic write_csr_misc_18;
	logic write_csr_4bytes_addr_en;
	logic write_csr_4bytes_addr_ex;
	logic write_csr_sector_protect;
	logic write_csr_rd_device_id;
	logic write_csr_device_id_data_0;
	logic write_csr_device_id_data_1;
	logic write_csr_device_id_data_2;
	logic write_csr_device_id_data_3;
	logic write_csr_device_id_data_4;

	logic read_csr_wr_enable;
	logic read_csr_wr_disable;
	logic read_csr_wr_status;
	logic read_csr_rd_status;
	logic read_csr_sector_erase;
	logic read_csr_subsector_erase;
	logic read_csr_isr;
	logic read_csr_ier;
	logic read_csr_control;
	logic read_csr_status;
	logic read_csr_com_10;
	logic read_csr_com_11;
	logic read_csr_com_12;
	logic read_csr_misc_13;
	logic read_csr_misc_14;
	logic read_csr_misc_15;
	logic read_csr_misc_16;
	logic read_csr_misc_17;
	logic read_csr_misc_18;
	logic read_csr_4bytes_addr_en;
	logic read_csr_4bytes_addr_ex;
	logic read_csr_sector_protect;
	logic read_csr_rd_device_id;
	logic read_csr_rd_device_id_reg;
	logic is_rd_device_id;
	logic read_csr_device_id_data_0;
	logic read_csr_device_id_data_1;
	logic read_csr_device_id_data_2;
	logic read_csr_device_id_data_3;
	logic read_csr_device_id_data_4;

	logic csr_waitrequest_local;

	logic [ADD_W-1:0]  	avl_addr;
	logic        		avl_rd;        
	logic 		 		avl_wr;          
	logic [31:0] 		avl_wrdata;
	logic [31:0] 		avl_rddata;
	logic [31:0] 		avl_rddata_local;
	logic 		 		avl_waitrequest;
	logic 		 		avl_rddatavalid;
	logic 		 		avl_rddatavalid_local;

	// State machine
    typedef enum bit [3:0]
    {
        ST_IDLE         = 4'b0001,
        ST_SEND_HEADER  = 4'b0010,
        ST_SEND_DATA 	= 4'b0100,
        ST_WAIT_RSP     = 4'b1000
     } t_state;
    t_state state, next_state;

	// Just to make it easy to read
	assign avl_addr 		= csr_addr;
	assign avl_wr 			= csr_wr;
	assign avl_rd 			= csr_rd;
	assign avl_wrdata 		= csr_wrdata;
	assign csr_waitrequest  = avl_waitrequest;
	assign csr_rddatavalid 	= avl_rddatavalid;
	assign csr_rddata       = avl_rddata;

    // +-------------------------------------------------------------------------------------------
    // | Build the array of predefined data for all commands - header 
    // | 32'b[reserved_bits][data_bytes_bin][dummy_bytes_bin][has_dummy][has_data_out][has_data_in][4bytes_addr][has_addr][opcode_bin]
    // +-------------------------------------------------------------------------------------------
    logic [31:0]   header_mem [0: 27];
	//logic [31:0]   header_mem [0: 22];
	assign header_mem[0]	= 32'b00000000000000000000000000000110;
	assign header_mem[1]	= 32'b00000000000000000000000000000100;
	assign header_mem[2]	= 32'b00000000000001000000010000000001;
	assign header_mem[3]	= 32'b00000000000001000000100000000101;
	assign header_mem[4]	= 32'b00000000000000000000000111011000;
	assign header_mem[5]	= 32'b00000000000000000000000100100000;
	assign header_mem[6]	= 32'b00000000000000000000000000000000;
	assign header_mem[7]	= 32'b00000000000000000000000000000000;
	assign header_mem[8]	= 32'b00000000000000000000000000000000;
	assign header_mem[9]	= 32'b00000000000000000000000000000000;
	assign header_mem[10]	= 32'b00000000000000000000000000000000;
	assign header_mem[11]	= 32'b00000000000000000000000000000000;
	assign header_mem[12]	= 32'b00000000000000000000000000000000;
	assign header_mem[13]	= 32'b00000000000010000000010010110001;
	assign header_mem[14]	= 32'b00000000000010000000100010110101;
	assign header_mem[15]	= 32'b00000000000001000000100001110000;
	assign header_mem[16]	= 32'b00000000000000000000000001010000;
	assign header_mem[17]	= 32'b00000000000000000000000011000111;
	assign header_mem[18]	= 32'b00000000000000000000000000000000;
	assign header_mem[19]	= 32'b00000000000000000000000000000000;
	assign header_mem[20]	= 32'b00000000000000000000000000000000;
	assign header_mem[21]	= 32'b00000000000001000000010000000001;
	assign header_mem[22]	= 32'b00000000000011000000100010011111;
	assign header_mem[23]	= 32'b00000000000000000000000000000000;
	assign header_mem[24]	= 32'b00000000000000000000000000000000;
	assign header_mem[25]	= 32'b00000000000000000000000000000000;
	assign header_mem[26]	= 32'b00000000000000000000000000000000;
	assign header_mem[27]	= 32'b00000000000000000000000000000000;
	// +-------------------------------------------------------------------------------------------
	// | Access CSR decoding logic
	// +-------------------------------------------------------------------------------------------
	
	assign csr_wr_enable				= (csr_addr == 6'd0);
	assign csr_wr_disable				= (csr_addr == 6'd1);
	assign csr_wr_status				= (csr_addr == 6'd2);
	assign csr_rd_status				= (csr_addr == 6'd3);
	assign csr_sector_erase				= (csr_addr == 6'd4);
	assign csr_subsector_erase			= (csr_addr == 6'd5);
	assign csr_isr						= (csr_addr == 6'd6);
	assign csr_ier						= (csr_addr == 6'd7);
	assign csr_control					= (csr_addr == 6'd8);
	// These CSRs are reserved or not avaiable in some configuration, 
	// User write to these, nothing. Read will be return dummy values
	// This avoids system hang
	assign csr_status					= (csr_addr == 6'd9);
	assign csr_com_10   				= (csr_addr == 6'd10);
	assign csr_com_11   				= (csr_addr == 6'd11);
	assign csr_com_12   				= (csr_addr == 6'd12);
	// These register can be double meanings. So cannot use specific name.
	// Fro some devices, they do some specific operation, but from some, 
	// they are unavaiablein RTL, development, check on those localparam to decide if this 
	// register enable or disable. 
	// The mapping here shown each csr_misc_xx meaning, when generate the IP.
	// csr_misc_13    : wr_NVCR
	// csr_misc_14    : rd_NVCR
	// csr_misc_15    : rd_flag_status
	// csr_misc_16    : clr_flag_status
	// csr_misc_17    : bulk_erase/chip_erase
	// csr_misc_18    : NA
	// csr_misc_19    : NA
	// csr_misc_20    : NA
	// csr_misc_21    : sector_protect
	// csr_misc_22    : rd_memory_capacity_id
	assign csr_misc_13					= (csr_addr == 6'd13);
	assign csr_misc_14					= (csr_addr == 6'd14);
	assign csr_misc_15					= (csr_addr == 6'd15);
	assign csr_misc_16					= (csr_addr == 6'd16);
	assign csr_misc_17					= (csr_addr == 6'd17);
	assign csr_misc_18					= (csr_addr == 6'd18);
	assign csr_4bytes_addr_en			= (csr_addr == 6'd19);
	assign csr_4bytes_addr_ex			= (csr_addr == 6'd20);
	assign csr_sector_protect			= (csr_addr == 6'd21);
	// For EPCQ, this is read memory capacity
	assign csr_rd_device_id				= (csr_addr == 6'd22);
	// If EPCQ, these CSRs are not avaiable, read return 0
	// These CSRs are turn on/off deopend the local parame CSR_EXTRA_EN
	assign csr_device_id_data_0			= (csr_addr == 6'd23);
	assign csr_device_id_data_1			= (csr_addr == 6'd24);
	assign csr_device_id_data_2			= (csr_addr == 6'd25);
	assign csr_device_id_data_3			= (csr_addr == 6'd26);
	assign csr_device_id_data_4			= (csr_addr == 6'd27);

	// +-------------------------------------------------------------------------------------------
	// | Write/Read transaction combi
	// | Make sure that, if a CSR is write only, read to this register returns dummy data
	// | 	             if a CSR is read only, write to this register does nothing.
	// +-------------------------------------------------------------------------------------------
	always_comb begin 
		// The csr_wr_enable/disable only can on when user write bit [0] of write data to 1.
		write_csr_wr_enable				= csr_wr_enable && avl_wr && (avl_wrdata == 32'h1) && !avl_waitrequest;
		read_csr_wr_enable 				= csr_wr_enable && avl_rd && !avl_waitrequest;
	
		write_csr_wr_disable 			= csr_wr_disable && avl_wr && (avl_wrdata == 32'h1) && !avl_waitrequest;
		read_csr_wr_disable				= csr_wr_disable && avl_rd && !avl_waitrequest;
		
		write_csr_wr_status				= csr_wr_status && avl_wr && !avl_waitrequest;
		read_csr_wr_status				= csr_wr_status && avl_rd && !avl_waitrequest;
		
		write_csr_rd_status				= csr_rd_status && avl_wr && !avl_waitrequest;
		read_csr_rd_status				= csr_rd_status && avl_rd && !avl_waitrequest;
		
		write_csr_sector_erase			= csr_sector_erase && avl_wr && !avl_waitrequest;
		read_csr_sector_erase			= csr_sector_erase && avl_rd && !avl_waitrequest;
		
		write_csr_subsector_erase		= csr_subsector_erase && avl_wr && !avl_waitrequest;
		read_csr_subsector_erase		= csr_subsector_erase && avl_rd && !avl_waitrequest;
		
		write_csr_isr					= csr_isr && avl_wr && !avl_waitrequest;
		read_csr_isr					= csr_isr && avl_rd && !avl_waitrequest;
		
		write_csr_ier					= csr_ier && avl_wr && !avl_waitrequest;
		read_csr_ier					= csr_ier && avl_rd && !avl_waitrequest;
		
		write_csr_control				= csr_control && avl_wr && !avl_waitrequest;
		read_csr_control				= csr_control && avl_rd && !avl_waitrequest;
		
		write_csr_status				= csr_status && avl_wr && !avl_waitrequest;
		read_csr_status					= csr_status && avl_rd && !avl_waitrequest;
		
		write_csr_com_10				= csr_com_10 && avl_wr && !avl_waitrequest;
		read_csr_com_10					= csr_com_10 && avl_rd && !avl_waitrequest;
		
		write_csr_com_11				= csr_com_11 && avl_wr && !avl_waitrequest;
		read_csr_com_11					= csr_com_11 && avl_rd && !avl_waitrequest;
		
		write_csr_com_12				= csr_com_12 && avl_wr && !avl_waitrequest;
		read_csr_com_12					= csr_com_12 && avl_rd && !avl_waitrequest;
		
		write_csr_misc_13				= csr_misc_13 && avl_wr && !avl_waitrequest;
		read_csr_misc_13				= csr_misc_13 && avl_rd && !avl_waitrequest;

		write_csr_misc_14				= csr_misc_14 && avl_wr && !avl_waitrequest;
		read_csr_misc_14				= csr_misc_14 && avl_rd && !avl_waitrequest;
		
		write_csr_misc_15				= csr_misc_15 && avl_wr && !avl_waitrequest;
		read_csr_misc_15				= csr_misc_15 && avl_rd && !avl_waitrequest;
		
		write_csr_misc_16				= csr_misc_16 && avl_wr && !avl_waitrequest;
		read_csr_misc_16				= csr_misc_16 && avl_rd && !avl_waitrequest;
		
		write_csr_misc_17				= csr_misc_17 && avl_wr && !avl_waitrequest;
		read_csr_misc_17				= csr_misc_17 && avl_rd && !avl_waitrequest;
		
		write_csr_misc_18				= csr_misc_18 && avl_wr && !avl_waitrequest;
		read_csr_misc_18				= csr_misc_18 && avl_rd && !avl_waitrequest;

		write_csr_4bytes_addr_en		= csr_4bytes_addr_en && avl_wr && !avl_waitrequest;
		read_csr_4bytes_addr_en			= csr_4bytes_addr_en && avl_rd && !avl_waitrequest;
		
		write_csr_4bytes_addr_ex		= csr_4bytes_addr_ex && avl_wr && !avl_waitrequest;
		read_csr_4bytes_addr_ex			= csr_4bytes_addr_ex && avl_rd && !avl_waitrequest;
		
		write_csr_sector_protect		= csr_sector_protect && avl_wr && !avl_waitrequest;
		read_csr_sector_protect			= csr_sector_protect && avl_rd && !avl_waitrequest;
		
		write_csr_rd_device_id			= csr_rd_device_id && avl_wr && !avl_waitrequest;
		read_csr_rd_device_id			= csr_rd_device_id && avl_rd && !avl_waitrequest;
		
		write_csr_device_id_data_0		= csr_device_id_data_0 && avl_wr && !avl_waitrequest;
		read_csr_device_id_data_0		= csr_device_id_data_0 && avl_rd && !avl_waitrequest;
		
		write_csr_device_id_data_1		= csr_device_id_data_1 && avl_wr && !avl_waitrequest;
		read_csr_device_id_data_1		= csr_device_id_data_1 && avl_rd && !avl_waitrequest;
		
		write_csr_device_id_data_2		= csr_device_id_data_2 && avl_wr && !avl_waitrequest;
		read_csr_device_id_data_2		= csr_device_id_data_2 && avl_rd && !avl_waitrequest;
		
		write_csr_device_id_data_3		= csr_device_id_data_3 && avl_wr && !avl_waitrequest;
		read_csr_device_id_data_3		= csr_device_id_data_3 && avl_rd && !avl_waitrequest;

		write_csr_device_id_data_4		= csr_device_id_data_4 && avl_wr && !avl_waitrequest;
		read_csr_device_id_data_4		= csr_device_id_data_0 && avl_rd && !avl_waitrequest;
	end

	// +-------------------------------------------------------------------------------------------
	// | Operation selection: There are many CSR access, some talk to the device, some do not.
	// +-------------------------------------------------------------------------------------------
	logic 				flash_operation;
	logic 				flash_operation_reg;
	// These are operation that need to interact with device - send command to flash
	// Other CSR opeartions have different behavior
	assign flash_operation = write_csr_wr_enable | write_csr_wr_disable | write_csr_wr_status | read_csr_rd_status | write_csr_sector_erase | write_csr_subsector_erase | write_csr_status | read_csr_status | (write_csr_misc_13 & CSR_MISC_EN_13) | (read_csr_misc_14 & CSR_MISC_EN_14) | (read_csr_misc_15 & CSR_MISC_EN_15) | (write_csr_misc_16 & CSR_MISC_EN_16) | (write_csr_misc_17 & CSR_MISC_EN_17) | (write_csr_misc_18 & CSR_MISC_EN_18) | write_csr_4bytes_addr_en | write_csr_4bytes_addr_ex | write_csr_sector_protect | read_csr_rd_device_id;
	always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            flash_operation_reg			<= '0;
            read_csr_rd_device_id_reg 	<= '0; // sync with flash operation when channging state
        end
        else begin
        	flash_operation_reg 		<= flash_operation;
        	read_csr_rd_device_id_reg 	<= read_csr_rd_device_id;
        end
    end

	// +-------------------------------------------------------------------------------------------
	// | Decode command from predefined header
	// | Need to know if this operation has address input or data input, if address then send over
	// | address interface, if data then send after the header.
	logic [ADD_W-1:0] 	addr_reg;
	logic [31:0] 		wrdata_reg;

	logic has_addr;
	logic has_data_in;
	logic has_data_out;
	logic [31:0] header_information;

	assign header_information 	= header_mem[addr_reg];
	assign has_addr 			= header_information[8];
	assign has_data_in 			= header_information[10];
	assign has_data_out 		= header_information[11];
	// | most cases, the operation either needs to send address or data in. Any cases, it does both?
	// | 
	// +-------------------------------------------------------------------------------------------

	// +-------------------------------------------------------------------------------------------
	// | Register input value
	// +-------------------------------------------------------------------------------------------
	always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            addr_reg    <= '0;
            wrdata_reg 	<= '0;
        end
        else begin
            if ((avl_rd | avl_wr) && !avl_waitrequest) begin
                addr_reg    <= avl_addr;
            end
            if (avl_wr && !avl_waitrequest)
            	wrdata_reg	<= avl_wrdata;
        end
    end
    // | For those registers which are write only, if user does a read to that address, it will return
    // | the last value that they write to, so store those informaion here
    // | If user write to read only register, nothing happens.
    logic [31:0] csr_wr_enable_data_reg;
    logic [31:0] csr_wr_disable_data_reg;
    logic [31:0] csr_wr_status_data_reg;
	logic [31:0] csr_sector_erase_data_reg;
	logic [31:0] csr_subsector_erase_data_reg;
	logic [31:0] csr_isr_data_reg;
	logic [31:0] csr_ier_data_reg;
	logic [31:0] csr_control_data_reg;
	logic [31:0] csr_status_data_reg;
	logic [31:0] csr_misc_13_data_reg;
	logic [31:0] csr_misc_14_data_reg;
	logic [31:0] csr_misc_15_data_reg;
	logic [31:0] csr_misc_16_data_reg;
	logic [31:0] csr_misc_17_data_reg;
	logic [31:0] csr_misc_18_data_reg;
	logic [31:0] csr_extra_23_data_reg;
	logic [31:0] csr_extra_24_data_reg;
	logic [31:0] csr_extra_25_data_reg;
	logic [31:0] csr_extra_26_data_reg;
	logic [31:0] csr_extra_27_data_reg;
	logic [31:0] csr_4bytes_addr_en_data_reg;
	logic [31:0] csr_4bytes_addr_ex_data_reg;
	logic [31:0] csr_sector_protect_data_reg;
	logic [31:0] csr_rd_device_id_data_reg;
	logic [31:0] csr_device_id_data_0_data_reg;
	logic [31:0] csr_device_id_data_1_data_reg;
	logic [31:0] csr_device_id_data_2_data_reg;
	logic [31:0] csr_device_id_data_3_data_reg;
	logic [31:0] csr_device_id_data_4_data_reg;
	// Store value some of csr register, return value if user does a read to write only
	// wr_enable
	always_ff @(posedge clk or posedge reset) begin
		if (reset) begin 
			csr_wr_enable_data_reg <= '0;
		end
		else begin
			if (write_csr_wr_enable)
				csr_wr_enable_data_reg <= avl_wrdata;
		end
	end
	// wr_disable
	always_ff @(posedge clk or posedge reset) begin
		if (reset) begin 
			csr_wr_disable_data_reg <= '0;
		end
		else begin
			if (write_csr_wr_disable)
				csr_wr_disable_data_reg <= avl_wrdata;
		end
	end
	// wr_status
	always_ff @(posedge clk or posedge reset) begin
		if (reset) begin 
			csr_wr_status_data_reg <= '0;
		end
		else begin
			if (write_csr_wr_status)
				csr_wr_status_data_reg <= avl_wrdata;
		end
	end
	// sector_erase
	always_ff @(posedge clk or posedge reset) begin
		if (reset) begin 
			csr_sector_erase_data_reg <= '0;
		end
		else begin
			if (write_csr_sector_erase)
				csr_sector_erase_data_reg <= avl_wrdata;
		end
	end
	// sector_erase
	always_ff @(posedge clk or posedge reset) begin
		if (reset) begin 
			csr_subsector_erase_data_reg <= '0;
		end
		else begin
			if (write_csr_subsector_erase)
				csr_subsector_erase_data_reg <= avl_wrdata;
		end
	end
	// control register
	always_ff @(posedge clk or posedge reset) begin
		if (reset) begin 
			csr_control_data_reg <= '0;
		end
		else begin
			// if bit 0 is 1, means disable qspi output then do not record the chip select
			// if bit 0 is 0, recored the chip select value
			if (write_csr_control) begin
				if (avl_wrdata[0] == 1)
					csr_control_data_reg[0] <= avl_wrdata[0];
				else
					csr_control_data_reg[7:4] <= avl_wrdata[7:4];
			end
		end
	end

	generate
		if (CSR_MISC_EN_13 == 1) begin 
			if (CSR_MISC_WR_ONLY_13 == 1) begin 
				// if write only, mean when read to same address, return last value
				always_ff @(posedge clk or posedge reset) begin
					if (reset)
						csr_misc_13_data_reg <= '0;
					else begin
						if (write_csr_misc_13)
							csr_misc_13_data_reg <= avl_wrdata;
					end
				end				
			end
			// if read only, mean when read to something from real falsh, write just ignore
		end
		// if this CSR is disable, read return zeoro
		// Maybe just ignore this
	endgenerate
	
	generate
		if (CSR_MISC_EN_14 == 1) begin 
			if (CSR_MISC_WR_ONLY_14 == 1) begin 
				// if write only, mean when read to same address, return last value
				always_ff @(posedge clk or posedge reset) begin
					if (reset)
						csr_misc_14_data_reg <= '0;
					else begin
						if (write_csr_misc_14)
							csr_misc_14_data_reg <= avl_wrdata;
					end
				end				
			end
			// if read only, mean when read to something from real falsh, write just ignore
		end
		// if this CSR is disable, read return zeoro
		// Maybe just ignore this
	endgenerate

	generate
		if (CSR_MISC_EN_15 == 1) begin 
			if (CSR_MISC_WR_ONLY_15 == 1) begin 
				// if write only, mean when read to same address, return last value
				always_ff @(posedge clk or posedge reset) begin
					if (reset)
						csr_misc_15_data_reg <= '0;
					else begin
						if (write_csr_misc_15)
							csr_misc_15_data_reg <= avl_wrdata;
					end
				end				
			end
			// if read only, mean when read to something from real falsh, write just ignore
		end
		// if this CSR is disable, read return zeoro
		// Maybe just ignore this
	endgenerate

	generate
		if (CSR_MISC_EN_16 == 1) begin 
			if (CSR_MISC_WR_ONLY_16 == 1) begin 
				// if write only, mean when read to same address, return last value
				always_ff @(posedge clk or posedge reset) begin
					if (reset)
						csr_misc_16_data_reg <= '0;
					else begin
						if (write_csr_misc_16)
							csr_misc_16_data_reg <= avl_wrdata;
					end
				end				
			end
			// if read only, mean when read to something from real falsh, write just ignore
		end
		// if this CSR is disable, read return zeoro
		// Maybe just ignore this
	endgenerate

	generate
		if (CSR_MISC_EN_17 == 1) begin 
			if (CSR_MISC_WR_ONLY_17 == 1) begin 
				// if write only, mean when read to same address, return last value
				always_ff @(posedge clk or posedge reset) begin
					if (reset)
						csr_misc_17_data_reg <= '0;
					else begin
						if (write_csr_misc_17)
							csr_misc_17_data_reg <= avl_wrdata;
					end
				end				
			end
			// if read only, mean when read to something from real falsh, write just ignore
		end
		// if this CSR is disable, read return zeoro
		// Maybe just ignore this
	endgenerate

	generate
		if (CSR_MISC_EN_18 == 1) begin 
			if (CSR_MISC_WR_ONLY_18 == 1) begin 
				// if write only, mean when read to same address, return last value
				always_ff @(posedge clk or posedge reset) begin
					if (reset)
						csr_misc_18_data_reg <= '0;
					else begin
						if (write_csr_misc_18)
							csr_misc_18_data_reg <= avl_wrdata;
					end
				end				
			end
			// if read only, mean when read to something from real falsh, write just ignore
		end
		// if this CSR is disable, read return zeoro
		// Maybe just ignore this
	endgenerate

	// 4bytes_addr_en
	always_ff @(posedge clk or posedge reset) begin
		if (reset) begin 
			csr_4bytes_addr_en_data_reg <= '0;
		end
		else begin
			if (write_csr_4bytes_addr_en)
				csr_4bytes_addr_en_data_reg <= avl_wrdata;
		end
	end

	// 4bytes_addr_ex
	always_ff @(posedge clk or posedge reset) begin
		if (reset) begin 
			csr_4bytes_addr_ex_data_reg <= '0;
		end
		else begin
			if (write_csr_4bytes_addr_ex)
				csr_4bytes_addr_ex_data_reg <= avl_wrdata;
		end
	end

	// csr_sector_protect
	always_ff @(posedge clk or posedge reset) begin
		if (reset) begin 
			csr_sector_protect_data_reg <= '0;
		end
		else begin
			if (write_csr_sector_protect)
				csr_sector_protect_data_reg <= avl_wrdata;
		end
	end

	// csr_rd_device_id_
	always_ff @(posedge clk or posedge reset) begin
		if (reset) begin 
			csr_rd_device_id_data_reg <= '0;
		end
		else begin
			if (write_csr_rd_device_id)
				csr_rd_device_id_data_reg <= avl_wrdata;
		end
	end
	// for read memory capacity and read device ID: there is different in handling two cases
	always_ff @(posedge clk or posedge reset) begin
		if (reset) begin 
			is_rd_device_id <= '0;
		end
		else begin
			if (state == ST_IDLE) begin
				if (read_csr_rd_device_id_reg)
					is_rd_device_id <= 1'b1;
				else
					is_rd_device_id <= '0;
			end
		end
	end

	// For normal flash read device ID, 20 bytes will be store in 5 different registers
    logic [2:0] device_id_counter;
	always_ff @(posedge clk or posedge reset) begin
   		if (reset) 
   			device_id_counter <= '0; 
   		else begin
   			if (state == ST_IDLE)
   				device_id_counter <= '0; 
   			else begin
   				if (is_rd_device_id & rsp_valid)
   					device_id_counter <= device_id_counter + 3'h1;
   			end
   		end
   	end

	generate
		if (CSR_EXTRA_EN_23 == 1) begin 
			always_ff @(posedge clk or posedge reset) begin
				if (reset)
					csr_device_id_data_0_data_reg <= '0;
				else begin
                    // Make sure the ID data is saved
					if (is_rd_device_id && (device_id_counter == 3'h0) && (state == ST_WAIT_RSP))
						csr_device_id_data_0_data_reg <= rsp_data;
				end
			end
		end
	endgenerate
	generate
		if (CSR_EXTRA_EN_24 == 1) begin 
			always_ff @(posedge clk or posedge reset) begin
				if (reset)
					csr_device_id_data_1_data_reg <= '0;
				else begin
					if ((device_id_counter == 3'h1) & (state == ST_WAIT_RSP))
						csr_device_id_data_1_data_reg <= rsp_data;
				end
			end
		end
	endgenerate
	generate
		if (CSR_EXTRA_EN_25 == 1) begin 
			always_ff @(posedge clk or posedge reset) begin
				if (reset)
					csr_device_id_data_2_data_reg <= '0;
				else begin
					if ((device_id_counter == 3'h2) & (state == ST_WAIT_RSP))
						csr_device_id_data_2_data_reg <= rsp_data;
				end
			end
		end
	endgenerate
	generate
		if (CSR_EXTRA_EN_26 == 1) begin 
			always_ff @(posedge clk or posedge reset) begin
				if (reset)
					csr_device_id_data_3_data_reg <= '0;
				else begin
					if ((device_id_counter == 3'h3) & (state == ST_WAIT_RSP))
						csr_device_id_data_3_data_reg <= rsp_data;
				end
			end
		end
	endgenerate
	generate
		if (CSR_EXTRA_EN_27 == 1) begin 
			always_ff @(posedge clk or posedge reset) begin
				if (reset)
					csr_device_id_data_4_data_reg <= '0;
				else begin
					if ((device_id_counter == 3'h4) & (state == ST_WAIT_RSP))
						csr_device_id_data_4_data_reg <= rsp_data;
				end
			end
		end
	endgenerate

	// | 
	// +-------------------------------------------------------------------------------------------

    // +-------------------------------------------------------------------------------------------
	// | Output 
	// +-------------------------------------------------------------------------------------------
	// | If the operation need address, then set value from write data to the address byte interface
	assign addr_bytes_csr = has_addr ? wrdata_reg : 32'h0;

	// | Fix channel from csr controller is 2'b01 - 2'b10 for xip controller
	//assign cmd_channel	= 2'b01;
	assign cmd_channel	= 2'b10;
	// | Alwasy take in response, avalon master has no backpressure on data so it is safe
    // assign rsp_ready 	= 1;
    // | Wait request 
    // assert waitrequest when in reset
    logic hold_waitrequest;
    always_ff @(posedge clk or posedge reset) begin
   		if (reset) 
   			hold_waitrequest <= 1'h1; 
   		else 
   			hold_waitrequest <= 1'h0; 
   	end
    assign avl_waitrequest  = !(state == ST_IDLE) || flash_operation_reg || hold_waitrequest;
    
    
    //assign avl_rddatavalid 	= has_data_out ? rsp_valid : avl_rddatavalid_local;
    assign avl_rddatavalid 	= has_data_out ? (rsp_valid & rsp_eop) : avl_rddatavalid_local;
    //assign avl_rddata 		= has_data_out ? rsp_data : avl_rddata_local;
    // Special case on read device ID, in case ECPQ return memory capacity, normal flash return all
    // other flash, return zeor, user need read other csr to get all information
    generate
    	if (IS_READ_MEMORY_CAPACITY)
    		assign avl_rddata 		= has_data_out ? (is_rd_device_id ? {24'h0,rsp_data[23:16]} : rsp_data) : avl_rddata_local;
    	else
            // For QSPI controller, when read ID, it will return full 20 bytes, user has to dedicated address to retrieve the data
            // To make it easy, make first 4 bytes are return to the read ID transaction, all 20 bytes are still stored inside
            // dedicated register actually, user can access to them anytime
    		assign avl_rddata 		= has_data_out ? (is_rd_device_id ? csr_device_id_data_0_data_reg : rsp_data) : avl_rddata_local;
    endgenerate

    // enable signal
    assign qspi_interface_en = !csr_control_data_reg[0];

    // combinatorial read data signal declaration
	logic [31:0] rdata_comb;

	always_ff @(posedge clk or posedge reset) begin
   		if (reset) 
   			avl_rddata_local[31:0] <= 32'h0; 
   		else 
   			avl_rddata_local[31:0] <= rdata_comb[31:0];
   	end

	// read data is always returned on the next cycle
	always_ff @(posedge clk or posedge reset) begin
   		if (reset) 
   			avl_rddatavalid_local <= 1'b0; 
   		else 
   			avl_rddatavalid_local <= avl_rd;
   	end

   	// Avalon readdata logic
   	always_comb begin
   		rdata_comb = '0;
   		if (avl_rd) begin 
			case (avl_addr)
				6'd0: begin // wr enable
					rdata_comb = csr_wr_enable_data_reg;
				end
				6'd1: begin // wr disable
					rdata_comb = csr_wr_disable_data_reg;
				end
				6'd2: begin // wr status
					rdata_comb = csr_wr_status_data_reg;
				end
				6'd3: begin // rd status. This is read only, assign any value
					rdata_comb = '0;
				end
				6'd4: begin // sector erase
					rdata_comb = csr_sector_erase_data_reg;
				end
				6'd5: begin // sub sector erase
					rdata_comb = csr_subsector_erase_data_reg;
				end
				6'd6: begin // isr
					rdata_comb = 32'hdeadbeef;
				end
				6'd7: begin // ier
					rdata_comb = 32'hdeadbeef;
				end
				6'd8: begin // chip select
					rdata_comb = csr_control_data_reg;
				end
				6'd9: begin // csr status
					rdata_comb = 32'hdeadbeef;
				end
				6'd10: begin // unused
					rdata_comb = '0;
				end
				6'd11: begin // unused
					rdata_comb = '0;
				end
				6'd12: begin // unused
					rdata_comb = '0;
				end
				6'd13: begin // multi-purpose csr, if wr only , then return what written, else 0
					rdata_comb = (CSR_MISC_EN_13 & CSR_MISC_WR_ONLY_13) ? csr_misc_13_data_reg : '0;
				end
				6'd14: begin 
					rdata_comb = (CSR_MISC_EN_14 & CSR_MISC_WR_ONLY_14) ? csr_misc_14_data_reg : '0;
				end
				6'd15: begin 
					rdata_comb = (CSR_MISC_EN_15 & CSR_MISC_WR_ONLY_15) ? csr_misc_15_data_reg : '0;
				end
				6'd16: begin 
					rdata_comb = (CSR_MISC_EN_16 & CSR_MISC_WR_ONLY_16) ? csr_misc_16_data_reg : '0;
				end
				6'd17: begin 
					rdata_comb = (CSR_MISC_EN_17 & CSR_MISC_WR_ONLY_17) ? csr_misc_17_data_reg : '0;
				end
				6'd18: begin 
					rdata_comb = (CSR_MISC_EN_18 & CSR_MISC_WR_ONLY_18) ? csr_misc_18_data_reg : '0;
				end
				6'd19: begin // 4 bytes addr en
					rdata_comb = csr_4bytes_addr_en_data_reg;
				end
				6'd20: begin // 4 bytes addr ex
					rdata_comb = csr_4bytes_addr_ex_data_reg;
				end
				6'd21: begin // sector protect
					rdata_comb = csr_sector_protect_data_reg;
				end
				6'd22: begin // read device ID/ or memory ID
					rdata_comb = '0;
				end
				6'd23: begin // device ID data 0
					rdata_comb = CSR_EXTRA_EN_23 ? csr_device_id_data_0_data_reg :'0;
				end
				6'd24: begin  // device ID data 1
					rdata_comb = CSR_EXTRA_EN_24 ? csr_device_id_data_1_data_reg :'0;
				end
				6'd25: begin  // device ID data 2
					rdata_comb = CSR_EXTRA_EN_25 ? csr_device_id_data_2_data_reg :'0;
				end
				6'd26: begin  // device ID data 3
					rdata_comb = CSR_EXTRA_EN_26 ? csr_device_id_data_3_data_reg :'0;
				end
				6'd27: begin  // device ID data 4
					rdata_comb = CSR_EXTRA_EN_27 ? csr_device_id_data_4_data_reg :'0;
				end
				default: begin 
					rdata_comb = '0;
				end
			endcase
   		end
   	end
	// | 
	// +-------------------------------------------------------------------------------------------
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
                if (flash_operation_reg)
                    next_state = ST_SEND_HEADER;
            end
            ST_SEND_HEADER: begin 
                next_state = ST_SEND_HEADER;
                if (cmd_ready) begin
                	if (has_data_in)
                    	next_state = ST_SEND_DATA;
                    else
                    	next_state = ST_WAIT_RSP;
                end
            end
            ST_SEND_DATA: begin
                next_state  = ST_SEND_DATA;
                if (cmd_ready)
                    next_state  = ST_WAIT_RSP;
            end
            ST_WAIT_RSP : begin
                next_state  = ST_WAIT_RSP;
                if (rsp_valid && rsp_ready && rsp_eop)
                    next_state  = ST_IDLE;
            end
        endcase // case (state)
    end // always_comb
    
    // +--------------------------------------------------
    // | State Machine: state outputs
    // +--------------------------------------------------
    always_comb begin
        cmd_valid     	= '0;
        cmd_data        = '0;
        cmd_sop 		= '0;
        cmd_eop 		= '0;
        rsp_ready 		= '0;
        case (state)
            ST_IDLE: begin
                cmd_valid 		= '0;
                cmd_data    	= '0;
                cmd_sop 		= '0;
        		cmd_eop 		= '0;
        		rsp_ready 		= '0;
            end
            ST_SEND_HEADER: begin 
                cmd_valid       = 1'b1;
                rsp_ready 		= '0;
                // overwrite the chip select value
                cmd_data    	= {1'b0, csr_control_data_reg[7:4], header_information[26:0]};
                cmd_sop 		= 1'b1;
                if (has_data_in)
        			cmd_eop 		= '0;
        		else
        			cmd_eop 		= 1'b1;
            end
            ST_SEND_DATA: begin 
                cmd_valid 		= 1'b1;
                cmd_data    	= wrdata_reg;
                cmd_eop 		= '0;
                cmd_eop 		= 1'b1;
                rsp_ready 		= '0;
            end
            ST_WAIT_RSP : begin 
            	cmd_valid 		= '0;
            	cmd_data   	 	= '0;
            	cmd_sop 		= '0;
        		cmd_eop 		= '0;
        		rsp_ready 		= 1'b1;
            end
        endcase // case (state)
    end

endmodule


// -------------------------------------------
// Generation parameters
// output_name 					: nios_core_epcq_controller2_0_asmi2_inst_epcq_ctrl_csr_controller
// op_info 			    		: wr_enable:32'b00000000000000000000000000000110,wr_disable:32'b00000000000000000000000000000100,wr_status:32'b00000000000001000000010000000001,rd_status:32'b00000000000001000000100000000101,sector_erase:32'b00000000000000000000000111011000,subsector_erase:32'b00000000000000000000000100100000,isr:32'b00000000000000000000000000000000,ier:32'b00000000000000000000000000000000,chip_select:32'b00000000000000000000000000000000,status:32'b00000000000000000000000000000000,NA:32'b00000000000000000000000000000000,NA:32'b00000000000000000000000000000000,NA:32'b00000000000000000000000000000000,wr_NVCR:32'b00000000000010000000010010110001,rd_NVCR:32'b00000000000010000000100010110101,rd_flag_status:32'b00000000000001000000100001110000,clr_flag_status:32'b00000000000000000000000001010000,bulk_erase/chip_erase:32'b00000000000000000000000011000111,NA:32'b00000000000000000000000000000000,NA:32'b00000000000000000000000000000000,NA:32'b00000000000000000000000000000000,sector_protect:32'b00000000000001000000010000000001,rd_memory_capacity_id:32'b00000000000011000000100010011111
// numb_common_op 				: 5
// common_op_offset 			: 0 1 2 3 4 5
// common_op_name   			: wr_enable wr_disable wr_status rd_status sector_erase subsector_erase
// common_op_opcode 			: 06 04 01 05 D8 20
// common_op_addr_bytes    		: 0 0 0 0 3 3
// common_op_data_in_bytes 		: 0 0 1 0 0 0
// common_op_data_out_bytes 	: 0 0 0 1 0 0
// common_op_dummy_bytes    	: 0 0 0 0 0 0
// misc_op_offset 				: 13 14 15 16 17 18 19 20 21 22
// misc_op_name   				: wr_NVCR rd_NVCR rd_flag_status clr_flag_status bulk_erase/chip_erase NA NA NA sector_protect rd_memory_capacity_id
// misc_op_opcode 				: B1 B5 70 50 C7 00 00 00 01 9F
// misc_op_addr_bytes    		: 0 0 0 0 0 0 0 0 0 0
// misc_op_data_in_bytes 		: 2 0 0 0 0 0 0 0 1 0
// misc_op_data_out_bytes 		: 0 2 1 0 0 0 0 0 0 3
// misc_op_dummy_bytes    		: 0 0 0 0 0 0 0 0 0 0
// ctrl_registers               : isr ier chip_select status
// ctrl_registers_offset 		: 6 7 8 9 
// extra_op_name                : NA NA NA NA NA
// extra_op_offset              : 23 24 25 26 27
// extra_op_en                  : 0
// ------------------------------------------


