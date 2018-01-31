`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:09:27 08/21/2008 
// Design Name: 
// Module Name:    grid_graph_st 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module grid_graph_dot_an
	(
	 input wire clk,
	 input wire video_on,
    input wire [9:0] pix_x, pix_y,
    output reg [2:0] graph_rgb
	);
	
	// constant and signal declaration
   // x, y coordinates (0,0) to (639,479)
   localparam MAX_X = 640;
   localparam MAX_Y = 480;
	
	localparam MAX_X_10 = 64;
	localparam MAX_Y_10 = 48;
	//
	wire grid_on;
   wire [2:0] grid_rgb;
	wire A_on;
	wire [2:0]A_rgb;
	
	reg [9:0]memory_A[MAX_X:0];
	reg [MAX_X:0]i;
	initial
			for(i=0; i<=MAX_X; i=i+1) 
			memory_A[i]<=i;
	assign A_on=(memory_A[pix_x]==pix_y);
	assign A_rgb=3'b011;
   //--------------------------------------------
   // grid 10*10 lines
   //--------------------------------------------
   // pixel within grid
   assign grid_on = (
		//vertical lines
		(pix_x==0*MAX_X_10) || (pix_x==1*MAX_X_10) ||
		(pix_x==2*MAX_X_10) || (pix_x==3*MAX_X_10) ||
		(pix_x==4*MAX_X_10) || 
	((pix_x==5*MAX_X_10)&&(pix_y[2]||(pix_y<=1)))||
		(pix_x==6*MAX_X_10) || (pix_x==7*MAX_X_10) ||
		(pix_x==8*MAX_X_10) || (pix_x==9*MAX_X_10) ||
		(pix_x==10*MAX_X_10-1) ||
		//horizontal lines
		(pix_y==0*MAX_Y_10) || (pix_y==1*MAX_Y_10) ||
		(pix_y==2*MAX_Y_10) || (pix_y==3*MAX_Y_10) ||
		(pix_y==4*MAX_Y_10) || 
	((pix_y==5*MAX_Y_10)&&(pix_x[2]||(pix_x<=1)))||
		(pix_y==6*MAX_Y_10) || (pix_y==7*MAX_Y_10) ||
		(pix_y==8*MAX_Y_10) || (pix_y==9*MAX_Y_10) ||
		(pix_y==10*MAX_Y_10-1)
		);
   // grid rgb output
   assign grid_rgb = 3'b111; // 
   //--------------------------------------------
   // rgb multiplexing circuit
   //--------------------------------------------
   always @*
      if (~video_on)
         graph_rgb = 3'b000; // blank
      else
         if(A_on)
				 graph_rgb = A_rgb;
			else if (grid_on)
            graph_rgb = grid_rgb;
         else
            graph_rgb = 3'b000; // background
endmodule
