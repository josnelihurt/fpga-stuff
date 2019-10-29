//--------------------------------------------------------------------------------------------
//
//
//      Input file      : 
//      Component name  : i2c_master_top
//      Author          : 
//      Company         : 
//
//      Description     : 
//
//
//--------------------------------------------------------------------------------------------


module i2c_master_top(
	wb_clk_i, 
	wb_rst_i, 
	arst_i, 
	wb_adr_i, 
	wb_dat_i, 
	wb_dat_o, 
	wb_we_i, 
	wb_stb_i, 
	wb_cyc_i, 
	wb_ack_o, 
	wb_inta_o, 
	scl_pad_i, 
	scl_pad_o, 
	scl_padoen_o, 
	sda_pad_i, 
	sda_pad_o, 
	sda_padoen_o
);
   parameter    ARST_LVL = 1'b0;
   
   parameter    Tcq = 1;
	
   input        wb_clk_i;
   input        wb_rst_i;
   input        arst_i;
   input [2:0]  wb_adr_i;
   input [7:0]  wb_dat_i;
   output [7:0] wb_dat_o;
   reg [7:0]    wb_dat_o;
   input        wb_we_i;
   input        wb_stb_i;
   input        wb_cyc_i;
   output       wb_ack_o;
   output       wb_inta_o;
   reg          wb_inta_o;
   
   input        scl_pad_i;
   output       scl_pad_o;//
   output       scl_padoen_o;
   input        sda_pad_i;
   output       sda_pad_o;//
   output       sda_padoen_o;
   
   
   reg [15:0]    prer;
   reg [7:0]    ctr;
   reg [7:0]    txr;
   wire [7:0]   rxr;
   reg [7:0]    cr;
   wire [7:0]   sr;
   
   wire         rst_i;
   
   wire         done;
   
   wire         sta;
   wire         sto;
   wire         rd;
   wire         wr;
   wire         ack;
   wire         iack;
   
   wire         core_en;
   wire         ien;
   
   wire         irxack;
   reg          rxack;
   reg          tip;
   reg          irq_flag;
   wire         i2c_busy;
   
   assign rst_i = arst_i ^ ARST_LVL;
   
   assign wb_ack_o = wb_cyc_i & wb_stb_i;
   
   
   always @(wb_adr_i or prer or ctr or txr or cr or rxr or sr)
   begin: assign_dato
      case (wb_adr_i)
         3'b000 :
            wb_dat_o <= (prer[7:0]);
         
         3'b001 :
            wb_dat_o <= (prer[15:8]);
         
         3'b010 :
            wb_dat_o <= ctr;
         
         3'b011 :
            wb_dat_o <= rxr;
         
         3'b100 :
            wb_dat_o <= sr;
         
         3'b101 :
            wb_dat_o <= txr;
         
         3'b110 :
            wb_dat_o <= cr;
         
         3'b111 :
            wb_dat_o <= {8{1'b0}};
         
         default :
            wb_dat_o <= {8{1'bX}};
      endcase
   end
   
   
   always @(negedge rst_i or posedge wb_clk_i)
   begin: regs_block
      if (rst_i == 1'b0)
      begin
         prer <= #Tcq {16{1'b1}};
         ctr <= #Tcq {8{1'b0}};
         txr <= #Tcq {8{1'b0}};
         cr <= #Tcq {8{1'b0}};
      end
      else 
      begin
         if (wb_rst_i == 1'b1)
         begin
            prer <= #Tcq {16{1'b1}};
            ctr <= #Tcq {8{1'b0}};
            txr <= #Tcq {8{1'b0}};
            cr <= #Tcq {8{1'b0}};
         end
         else
            if (wb_cyc_i == 1'b1 & wb_stb_i == 1'b1 & wb_we_i == 1'b1)
            begin
               if (wb_adr_i[2] == 1'b0)
                  case (wb_adr_i[1:0])
                     2'b00 :
                        prer[7:0] <= #Tcq wb_dat_i;
                     2'b01 :
                        prer[15:8] <= #Tcq wb_dat_i;
                     2'b10 :
                        ctr <= #Tcq wb_dat_i;
                     2'b11 :
                        txr <= #Tcq wb_dat_i;
                     
                     default :
                        begin
                           $display("Illegal write address, setting all registers to unknown.");
                           prer <= {16{1'bX}};
                           ctr <= {8{1'bX}};
                           txr <= {8{1'bX}};
                        end
                  endcase
               else if ((core_en == 1'b1) & (wb_adr_i[1:0] == 0))
                  cr <= #Tcq wb_dat_i;
            end
            else
            begin
               if (done == 1'b1)
                  cr[7:4] <= #Tcq {4{1'b0}};
               
               cr[2:1] <= #Tcq {2{1'b0}};
               
               cr[0] <= cr[0] & irq_flag;
            end
      end
   end
   
   assign sta = cr[7];
   assign sto = cr[6];
   assign rd = cr[5];
   assign wr = cr[4];
   assign ack = cr[3];
   assign iack = cr[0];
   
   assign core_en = ctr[7];
   assign ien = ctr[6];
   
   
   i2c_master_byte_ctrl u1(.clk(wb_clk_i), .rst(wb_rst_i), .nReset(rst_i), .ena(core_en), .clk_cnt(prer), .start(sta), .stop(sto), .read(rd), .write(wr), .ack_in(ack), .i2c_busy(i2c_busy), .din(txr), .cmd_ack(done), .ack_out(irxack), .dout(rxr), .scl_i(scl_pad_i), .scl_o(scl_pad_o), .scl_oen(scl_padoen_o), .sda_i(sda_pad_i), .sda_o(sda_pad_o), .sda_oen(sda_padoen_o));
   
   // <st_irq_block : block unsupported>
   
   always @(posedge wb_clk_i or negedge rst_i)
   begin: gen_sr_bits
      if (rst_i == 1'b0)
      begin
         rxack <= #Tcq 1'b0;
         tip <= #Tcq 1'b0;
         irq_flag <= #Tcq 1'b0;
      end
      else 
      begin
         if (wb_rst_i == 1'b1)
         begin
            rxack <= #Tcq 1'b0;
            tip <= #Tcq 1'b0;
            irq_flag <= #Tcq 1'b0;
         end
         else
         begin
            rxack <= #Tcq irxack;
            tip <= #Tcq (rd | wr);
            
            irq_flag <= #Tcq (done | irq_flag) & (~iack);
         end
      end
   end
   
   
   always @(posedge wb_clk_i or negedge rst_i)
   begin: gen_irq
      if (rst_i == 1'b0)
         wb_inta_o <= #Tcq 1'b0;
      else 
      begin
         if (wb_rst_i == 1'b1)
            wb_inta_o <= #Tcq 1'b0;
         else
            wb_inta_o <= #Tcq irq_flag & ien;
      end
   end
   
   assign sr[7] = rxack;
   assign sr[6] = i2c_busy;
   assign sr[5:2] = {4{1'b0}};
   assign sr[1] = tip;
   assign sr[0] = irq_flag;
   
endmodule
