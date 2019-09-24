module rom_init_cmd(
	input clk,
    input wire [7:0] addr,
    output reg [31:0] data
	);
/* 6.1 Command set = Taken from datasheet */
localparam 
CMD_Product_ID								=	8'h00,
CMD_Display_mode							=	8'h01,
CMD_Column_Address_Start_1				=	8'h02,
CMD_Column_Address_Start_2				=	8'h03,
CMD_Column_Address_End_1				=	8'h04,
CMD_Column_Address_End_2				=	8'h05,
CMD_Row_Address_Start_1					=	8'h06,
CMD_Row_Address_Start_2					=	8'h07,
CMD_Row_Address_End_1					=	8'h08,
CMD_Row_Address_End_2					=	8'h09,
CMD_Partial_Area_Start_Row_1			=	8'h0a,
CMD_Partial_Area_Start_Row_2			=	8'h0b,
CMD_Partial_Area_End_Row_1				=	8'h0c,
CMD_Partial_Area_End_Row_2				=	8'h0d,
CMD_Vertical_Scroll_Top_Fixed_Area_1=	8'h0e,
CMD_Vertical_Scroll_Top_Fixed_Area_2=	8'h0f,
CMD_Vertical_Scroll_Height_Area_1	=	8'h10,
CMD_Vertical_Scroll_Height_Area_2	=	8'h11,
CMD_Vertical_Scroll_Button_Fixed_1	=	8'h12,
CMD_Vertical_Scroll_Button_Fixed_2	=	8'h13,
CMD_Vertical_Scroll_Start_Address_1	=	8'h14,
CMD_Vertical_Scroll_Start_Address_2	=	8'h15,
CMD_Memory_Access_Control				=	8'h16,
CMD_OSC_Control_1							=	8'h17,
CMD_OSC_Control_2							=	8'h18,
CMD_Power_Control_1						=	8'h19,
CMD_Power_Control_2						=	8'h1a,
CMD_Power_Control_3						=	8'h1b,
CMD_Power_Control_4						=	8'h1c,
CMD_Power_Control_5						=	8'h1d,
CMD_Power_Control_6						=	8'h1e,
CMD_VCOM_Control							=	8'h1f,
CMD_Data_read_write						=	8'h22,
CMD_Display_Control_1					=	8'h23,
CMD_Display_Control_2					=	8'h24,
CMD_Display_Control_3					=	8'h25,
CMD_Display_Control_4					=	8'h26,
CMD_Display_Control_5					=	8'h27,
CMD_Display_Control_6					=	8'h28,
CMD_Display_Control_7					=	8'h29,
CMD_Display_Control_8					=	8'h2a,
CMD_Cycle_Control_1						=	8'h2b,
CMD_Cycle_Control_2						=	8'h2c,
CMD_Cycle_Control_3						=	8'h2d,
CMD_Cycle_Control_4						=	8'h2e,
CMD_Cycle_Control_5						=	8'h2f,
CMD_Cycle_Control_6						=	8'h30,
CMD_Cycle_Control_7						=	8'h31,
CMD_Cycle_Control_8						=	8'h32,
CMD_Cycle_Control_10						=	8'h34,
CMD_Cycle_Control_11						=	8'h35,
CMD_Cycle_Control_12						=	8'h36,
CMD_Cycle_Control_13						=	8'h37,
CMD_Cycle_Control_14						=	8'h38,
CMD_Cycle_Control_15						=	8'h39,
CMD_Interface_Control_1					=	8'h3a,
CMD_Source_Control_1						=	8'h3c,
CMD_Source_Control_2						=	8'h3d,
CMD_Gamma_Control_1						=	8'h3e,
CMD_Gamma_Control_2						=	8'h3f,
CMD_Gamma_Control_3						=	8'h40,
CMD_Gamma_Control_4						=	8'h41,
CMD_Gamma_Control_5						=	8'h42,
CMD_Gamma_Control_6						=	8'h43,
CMD_Gamma_Control_7						=	8'h44,
CMD_Gamma_Control_8						=	8'h45,
CMD_Gamma_Control_9						=	8'h46,
CMD_Gamma_Control_10						=	8'h47,
CMD_Gamma_Control_11						=	8'h48,
CMD_Gamma_Control_12						=	8'h49,
CMD_PANEL_Control							=	8'h55,
CMD_OTP_1									=	8'h56,
CMD_OTP_2									=	8'h57,
CMD_OTP_3									=	8'h58,
CMD_OTP_4									=	8'h59,
CMD_IP_Control								=	8'h5a,
CMD_DGC_LUT_WRITE							=	8'h5c,
CMD_DATA_Control							=	8'h5d,
CMD_Test_Mode								=	8'h83,
CMD_VDDD_control							=	8'h85,
CMD_Powr_driving_Control				=	8'h8A,
CMD_VGS_RES_control_1					=	8'h8B,
CMD_VGS_RES_control_2					=	8'h8C,
CMD_PWM_Control_0							=	8'h91,
CMD_PWM_Control_1							=	8'h95,
CMD_PWM_Control_2							=	8'h96,
CMD_PWM_Control_3							=	8'h97,
CMD_CABC_Period_Control_1				=	8'h6B,
CMD_CABC_Period_Control_2				=	8'h6C,
CMD_CABC_Gain1								=	8'h6F,
CMD_CABC_Gain2								=	8'h70,
CMD_CABC_Gain3								=	8'h71,
CMD_CABC_Gain4								=	8'h72,
CMD_CABC_Gain5								=	8'h73,
CMD_CABC_Gain6								=	8'h74,
CMD_CABC_Gain7								=	8'h75,
CMD_CABC_Gain8								=	8'h76,
CMD_CABC_Gain9								=	8'h77,
CMD_Custom_Delay							=	8'hFE,
CMD_Custom_Done								=	8'hFF;

// {CMD_TO_WRITE,DATA_TO_WRITE}
reg [31:0] rom [51:0];

always @(posedge clk)
	data <= rom[addr];


initial begin
	rom['h00] = {CMD_Test_Mode				,16'h02}; //TESTM=1 
	rom['h01] = {CMD_VDDD_control			,16'h03}; //VDC_SEL=011
	rom['h02] = {CMD_VGS_RES_control_1		,16'h01}; //STBA[7]=1,STBA[5:4]=01,STBA[1:0]=11
	rom['h03] = {CMD_VGS_RES_control_2		,16'h93};
	rom['h04] = {CMD_PWM_Control_0			,16'h01}; //DCDC_SYNC=1
	rom['h05] = {CMD_Test_Mode				,16'h00}; //TESTM=0
	rom['h06] = {CMD_Gamma_Control_1		,16'hB0}; //Gamma Setting
	rom['h07] = {CMD_Gamma_Control_2		,16'h03};
	rom['h08] = {CMD_Gamma_Control_3		,16'h10}; 
	rom['h09] = {CMD_Gamma_Control_5		,16'h13};
	rom['h0a] = {CMD_Gamma_Control_6		,16'h46};
	rom['h0b] = {CMD_Gamma_Control_7		,16'h23};
	rom['h0c] = {CMD_Gamma_Control_8		,16'h76}; 
	rom['h0d] = {CMD_Gamma_Control_9		,16'h00};
	rom['h0e] = {CMD_Gamma_Control_10		,16'h5E};
	rom['h0f] = {CMD_Gamma_Control_11		,16'h4F};
	rom['h10] = {CMD_Gamma_Control_12		,16'h40};
	rom['h11] = {CMD_OSC_Control_1			,16'h91};//**********Power On sequence************
	rom['h12] = {CMD_Cycle_Control_1		,16'hF9};
	rom['h13] = {CMD_Custom_Delay			,16'd10_000}; // 10ms delay
	rom['h14] = {CMD_Power_Control_3		,16'h14};
	rom['h15] = {CMD_Power_Control_2		,16'h11};
	rom['h16] = {CMD_Power_Control_4		,16'h06};// 0d
	rom['h17] = {CMD_VCOM_Control			,16'h42};
	rom['h18] = {CMD_Custom_Delay			,16'd20_000};//20ms delay
	rom['h19] = {CMD_Power_Control_1		,16'h0A};
	rom['h1a] = {CMD_Power_Control_1		,16'h1A};
	rom['h1b] = {CMD_Custom_Delay			,16'd60_000};//60ms delay
	rom['h1c] = {CMD_Power_Control_1		,16'h12};
	rom['h1d] = {CMD_Custom_Delay			,16'd40_000};//40ms delay
	rom['h1e] = {CMD_Power_Control_6		,16'h27};
	rom['h1f] = {CMD_Custom_Delay			,16'd60_000};//60ms delay
	rom['h20] = {CMD_Display_Control_2		,16'h60};//**********DISPLAY ON SETTING***********
	rom['h21] = {CMD_Source_Control_2		,16'h40};
	rom['h22] = {CMD_Cycle_Control_10		,16'h38};
	rom['h23] = {CMD_Cycle_Control_11		,16'h38};
	rom['h24] = {CMD_Display_Control_2		,16'h38};
	rom['h25] = {CMD_Custom_Delay			,16'd40_000};//40ms delay
	rom['h26] = {CMD_Display_Control_2		,16'h3C};
	rom['h27] = {CMD_Memory_Access_Control	,16'h1C};
	rom['h28] = {CMD_Display_mode			,16'h06};
	rom['h29] = {CMD_PANEL_Control			,16'h00};
	rom['h2a] = {CMD_Column_Address_Start_1	,16'h00};
	rom['h2b] = {CMD_Column_Address_Start_2	,16'h00};
	rom['h2c] = {CMD_Column_Address_End_1	,16'h00};
	rom['h2d] = {CMD_Column_Address_End_2	,16'hEF};
	rom['h2e] = {CMD_Row_Address_Start_1	,16'h00};
	rom['h2f] = {CMD_Row_Address_Start_2	,16'h00};
	rom['h30] = {CMD_Row_Address_End_1		,16'h01};
	rom['h31] = {CMD_Row_Address_End_2		,16'h8F};
	rom['h32] = {CMD_Custom_Done		,16'h00};
   end
endmodule 
