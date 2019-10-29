//--------------------------------------------------------------------------------------------
//
//
//      Input file      : 
//      Component name  : i2c_master_bit_ctrl
//      Author          : 
//      Company         : 
//
//      Description     : 
//
//
//--------------------------------------------------------------------------------------------


module i2c_master_bit_ctrl(clk, rst, nReset, ena, clk_cnt, cmd, cmd_ack, busy, din, dout, scl_i, scl_o, scl_oen, sda_i, sda_o, sda_oen);
   parameter        Tcq = 1;
   input            clk;
   input            rst;
   input            nReset;
   input            ena;
   
   input [15:0]      clk_cnt;
   
   input [3:0]      cmd;
   output           cmd_ack;
   reg              cmd_ack;
   output           busy;
   
   input            din;
   output           dout;
   reg              dout;
   
   input            scl_i;
   output           scl_o;
   output           scl_oen;
   input            sda_i;
   output           sda_o;
   output           sda_oen;
   
   parameter [3:0]  I2C_CMD_NOP = 4'b0000;
   parameter [3:0]  I2C_CMD_START = 4'b0001;
   parameter [3:0]  I2C_CMD_STOP = 4'b0010;
   parameter [3:0]  I2C_CMD_READ = 4'b0100;
   parameter [3:0]  I2C_CMD_WRITE = 4'b1000;
   
   parameter [4:0]  states_idle = 0,
                    states_start_a = 1,
                    states_start_b = 2,
                    states_start_c = 3,
                    states_start_d = 4,
                    states_start_e = 5,
                    states_stop_a = 6,
                    states_stop_b = 7,
                    states_stop_c = 8,
                    states_stop_d = 9,
                    states_rd_a = 10,
                    states_rd_b = 11,
                    states_rd_c = 12,
                    states_rd_d = 13,
                    states_wr_a = 14,
                    states_wr_b = 15,
                    states_wr_c = 16,
                    states_wr_d = 17;
   reg [4:0]        c_state;
   
   reg              iscl_oen;
   reg              isda_oen;
   reg              sSCL;
   reg              sSDA;
   reg              dscl_oen;
   
   reg              clk_en;
   wire             slave_wait;
   reg [15:0]        cnt;
   
   
   always @(posedge clk)
   begin: synch_scl_sda
      
      begin
         sSCL <= #Tcq scl_i;
         sSDA <= #Tcq sda_i;
      end
   end
   
   
   always @(posedge clk)
      
         dscl_oen <= #Tcq iscl_oen;
   
   assign slave_wait = dscl_oen & (~sSCL);
   
   
   always @(posedge clk or negedge nReset)
   begin: gen_clken
      if (nReset == 1'b0)
      begin
         cnt <= #Tcq {16{1'b0}};
         clk_en <= #Tcq 1'b1;
      end
      else 
      begin
         if (rst == 1'b1)
         begin
            cnt <= #Tcq {16{1'b0}};
            clk_en <= #Tcq 1'b1;
         end
         else
            if ((cnt == 0) | (ena == 1'b0))
            begin
               clk_en <= #Tcq 1'b1;
               cnt <= #Tcq clk_cnt;
            end
            else
            begin
               if (slave_wait == 1'b0)
                  cnt <= #Tcq cnt - 1'b1;
               clk_en <= #Tcq 1'b0;
            end
      end
   end
   
   // <bus_status_ctrl : block unsupported>
   reg              dSDA;
   reg              sta_condition;
   reg              sto_condition;
   
   reg              ibusy;
   
   always @(posedge clk)
   begin: detect_sta_sto
      
      begin
         dSDA <= sSDA;
         
         sta_condition <= ((~sSDA) & dSDA) & sSCL;
         sto_condition <= (sSDA & (~dSDA)) & sSCL;
      end
   end
   
   
   always @(posedge clk or negedge nReset)
   begin: gen_busy
      if (nReset == 1'b0)
         ibusy <= #Tcq 1'b0;
      else 
      begin
         if (rst == 1'b1)
            ibusy <= #Tcq 1'b0;
         else
            ibusy <= #Tcq (sta_condition | ibusy) & (~sto_condition);
      end
   end
   
   assign busy = ibusy;   
   
   always @(posedge clk or negedge nReset)
   begin: nxt_state_decoder
      reg [4:0]        nxt_state;
      reg              icmd_ack;
      reg              store_sda;
      nxt_state = c_state;
      
      icmd_ack = 1'b0;
      
      store_sda = 1'b0;
      
      case (c_state)
         states_idle :
            case (cmd)
               I2C_CMD_START :
                  nxt_state = states_start_a;
               
               I2C_CMD_STOP :
                  nxt_state = states_stop_a;
               
               I2C_CMD_WRITE :
                  nxt_state = states_wr_a;
               
               I2C_CMD_READ :
                  nxt_state = states_rd_a;
               
               default :
                  nxt_state = states_idle;
            endcase
         
         states_start_a :
            nxt_state = states_start_b;
         
         states_start_b :
            nxt_state = states_start_c;
         
         states_start_c :
            nxt_state = states_start_d;
         
         states_start_d :
            nxt_state = states_start_e;
         
         states_start_e :
            begin
               nxt_state = states_idle;
               icmd_ack = 1'b1;
            end
         
         states_stop_a :
            nxt_state = states_stop_b;
         
         states_stop_b :
            nxt_state = states_stop_c;
         
         states_stop_c :
            nxt_state = states_stop_d;
         
         states_stop_d :
            begin
               nxt_state = states_idle;
               icmd_ack = 1'b1;
            end
         
         states_rd_a :
            nxt_state = states_rd_b;
         
         states_rd_b :
            nxt_state = states_rd_c;
         
         states_rd_c :
            begin
               nxt_state = states_rd_d;
               store_sda = 1'b1;
            end
         
         states_rd_d :
            begin
               nxt_state = states_idle;
               icmd_ack = 1'b1;
            end
         
         states_wr_a :
            nxt_state = states_wr_b;
         
         states_wr_b :
            nxt_state = states_wr_c;
         
         states_wr_c :
            nxt_state = states_wr_d;
         
         states_wr_d :
            begin
               nxt_state = states_idle;
               icmd_ack = 1'b1;
            end
      endcase
      
      if (nReset == 1'b0)
      begin
         c_state <= #Tcq states_idle;
         cmd_ack <= #Tcq 1'b0;
         dout <= #Tcq 1'b0;
      end
      else 
      begin
         if (rst == 1'b1)
         begin
            c_state <= #Tcq states_idle;
            cmd_ack <= #Tcq 1'b0;
            dout <= #Tcq 1'b0;
         end
         else if (clk_en == 1'b1)
         begin
            c_state <= #Tcq nxt_state;
            
            if (store_sda == 1'b1)
               dout <= #Tcq sSDA;
         end
         
         cmd_ack <= icmd_ack & clk_en;
      end
   end
   
   
   always @(posedge clk or negedge nReset)
   begin: output_decoder
      reg              iscl;
      reg              isda;
      case (c_state)
         states_idle :
            begin
               iscl = iscl_oen;
               isda = isda_oen;
            end
         
         states_start_a :
            begin
               iscl = iscl_oen;
               isda = 1'b1;
            end
         
         states_start_b :
            begin
               iscl = 1'b1;
               isda = 1'b1;
            end
         
         states_start_c :
            begin
               iscl = 1'b1;
               isda = 1'b0;
            end
         
         states_start_d :
            begin
               iscl = 1'b1;
               isda = 1'b0;
            end
         
         states_start_e :
            begin
               iscl = 1'b0;
               isda = 1'b0;
            end
         
         states_stop_a :
            begin
               iscl = 1'b0;
               isda = 1'b0;
            end
         
         states_stop_b :
            begin
               iscl = 1'b1;
               isda = 1'b0;
            end
         
         states_stop_c :
            begin
               iscl = 1'b1;
               isda = 1'b0;
            end
         
         states_stop_d :
            begin
               iscl = 1'b1;
               isda = 1'b1;
            end
         
         states_wr_a :
            begin
               iscl = 1'b0;
               isda = din;
            end
         
         states_wr_b :
            begin
               iscl = 1'b1;
               isda = din;
            end
         
         states_wr_c :
            begin
               iscl = 1'b1;
               isda = din;
            end
         
         states_wr_d :
            begin
               iscl = 1'b0;
               isda = din;
            end
         
         states_rd_a :
            begin
               iscl = 1'b0;
               isda = 1'b1;
            end
         
         states_rd_b :
            begin
               iscl = 1'b1;
               isda = 1'b1;
            end
         
         states_rd_c :
            begin
               iscl = 1'b1;
               isda = 1'b1;
            end
         
         states_rd_d :
            begin
               iscl = 1'b0;
               isda = 1'b1;
            end
      endcase
      
      if (nReset == 1'b0)
      begin
         iscl_oen <= #Tcq 1'b1;
         isda_oen <= #Tcq 1'b1;
      end
      else 
      begin
         if (rst == 1'b1)
         begin
            iscl_oen <= #Tcq 1'b1;
            isda_oen <= #Tcq 1'b1;
         end
         else if (clk_en == 1'b1)
         begin
            iscl_oen <= #Tcq iscl;
            isda_oen <= #Tcq isda;
         end
      end
   end
   
   assign scl_o = 1'b0;
   assign scl_oen = iscl_oen;
   assign sda_o = 1'b0;
   assign sda_oen = isda_oen;
   
endmodule
