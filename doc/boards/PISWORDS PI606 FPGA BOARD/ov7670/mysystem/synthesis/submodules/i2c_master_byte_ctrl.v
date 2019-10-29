//--------------------------------------------------------------------------------------------
//
//
//      Input file      : 
//      Component name  : i2c_master_byte_ctrl
//      Author          : 
//      Company         : 
//
//      Description     : 
//
//
//--------------------------------------------------------------------------------------------


module i2c_master_byte_ctrl(clk, rst, nReset, ena, clk_cnt, start, stop, read, write, ack_in, din, cmd_ack, ack_out, i2c_busy, dout, scl_i, scl_o, scl_oen, sda_i, sda_o, sda_oen);
   parameter        Tcq = 1;
   input            clk;
   input            rst;
   input            nReset;
   input            ena;
   
   input [15:0]      clk_cnt;
   
   input            start;
   input            stop;
   input            read;
   input            write;
   input            ack_in;
   input [7:0]      din;
   
   output           cmd_ack;
   output           ack_out;
   reg              ack_out;
   output           i2c_busy;
   output [7:0]     dout;
   
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
   
   reg [3:0]        core_cmd;
   wire             core_ack;
   reg              core_txd;
   wire             core_rxd;
   
   reg [7:0]        sr;
   reg              shift;
   reg              ld;
   
   wire             go;
   reg              host_ack;
   reg [1:0]        dcnt;
   wire             cnt_done;
   
   
   i2c_master_bit_ctrl u1(
	   .clk(clk), 
	   .rst(rst), 
	   .nReset(nReset), 
	   .ena(ena), 
	   .clk_cnt(clk_cnt), 
	   .cmd(core_cmd), 
	   .cmd_ack(core_ack), 
	   .busy(i2c_busy), 
	   .din(core_txd), 
	   .dout(core_rxd), 
	   .scl_i(scl_i), 
	   .scl_o(scl_o), 
	   .scl_oen(scl_oen), 
	   .sda_i(sda_i), 
	   .sda_o(sda_o), 
	   .sda_oen(sda_oen)
   );
   
   assign cmd_ack = host_ack;
   
   assign go = (read | write | stop) & (~host_ack);
   
   assign dout = sr;
   
   
   always @(posedge clk or negedge nReset)
   begin: shift_register
      if (nReset == 1'b0)
         sr <= #Tcq {8{1'b0}};
      else 
      begin
         if (rst == 1'b1)
            sr <= #Tcq {8{1'b0}};
         else if (ld == 1'b1)
            sr <= #Tcq din;
         else if (shift == 1'b1)
            sr <= #Tcq ({sr[6:0], core_rxd});
      end
   end
   
   
   always @(posedge clk or negedge nReset)
   begin: data_cnt
      if (nReset == 1'b0)
         dcnt <= #Tcq {2{1'b0}};
      else 
      begin
         if (rst == 1'b1)
            dcnt <= #Tcq {2{1'b0}};
         else if (ld == 1'b1)
            dcnt <= #Tcq {2{1'b1}};
         else if (shift == 1'b1)
            dcnt <= #Tcq dcnt - 1'b1;
      end
   end
   
   assign cnt_done = ((dcnt == 0)) ? 1'b1 : 
                     1'b0;
   
   // <statemachine : block unsupported>
   parameter [2:0]  states_st_idle = 0,
                    states_st_start = 1,
                    states_st_read = 2,
                    states_st_write = 3,
                    states_st_ack = 4,
                    states_st_stop = 5;
   reg [2:0]        c_state;
   
   always @(posedge clk or negedge nReset)
   begin: nxt_state_decoder
      if (nReset == 1'b0)
      begin
         core_cmd <= #Tcq I2C_CMD_NOP;
         core_txd <= #Tcq 1'b0;
         
         shift <= #Tcq 1'b0;
         ld <= #Tcq 1'b0;
         
         host_ack <= #Tcq 1'b0;
         c_state <= #Tcq states_st_idle;
         
         ack_out <= #Tcq 1'b0;
      end
      else 
      begin
         if (rst == 1'b1)
         begin
            core_cmd <= #Tcq I2C_CMD_NOP;
            core_txd <= #Tcq 1'b0;
            
            shift <= #Tcq 1'b0;
            ld <= #Tcq 1'b0;
            
            host_ack <= #Tcq 1'b0;
            c_state <= #Tcq states_st_idle;
            
            ack_out <= #Tcq 1'b0;
         end
         else
         begin
            core_txd <= #Tcq sr[7];
            
            shift <= #Tcq 1'b0;
            ld <= #Tcq 1'b0;
            
            host_ack <= #Tcq 1'b0;
            
            case (c_state)
               states_st_idle :
                  if (go == 1'b1)
                  begin
                     if (start == 1'b1)
                     begin
                        c_state <= #Tcq states_st_start;
                        core_cmd <= #Tcq I2C_CMD_START;
                     end
                     else if (read == 1'b1)
                     begin
                        c_state <= #Tcq states_st_read;
                        core_cmd <= #Tcq I2C_CMD_READ;
                     end
                     else if (write == 1'b1)
                     begin
                        c_state <= #Tcq states_st_write;
                        core_cmd <= #Tcq I2C_CMD_WRITE;
                     end
                     else
                     begin
                        c_state <= #Tcq states_st_stop;
                        core_cmd <= #Tcq I2C_CMD_STOP;
                        
                        host_ack <= #Tcq 1'b1;
                     end
                     
                     ld <= #Tcq 1'b1;
                  end
               
               states_st_start :
                  if (core_ack == 1'b1)
                  begin
                     if (read == 1'b1)
                     begin
                        c_state <= #Tcq states_st_read;
                        core_cmd <= #Tcq I2C_CMD_READ;
                     end
                     else
                     begin
                        c_state <= #Tcq states_st_write;
                        core_cmd <= #Tcq I2C_CMD_WRITE;
                     end
                     
                     ld <= #Tcq 1'b1;
                  end
               
               states_st_write :
                  if (core_ack == 1'b1)
                  begin
                     if (cnt_done == 1'b1)
                     begin
                        c_state <= #Tcq states_st_ack;
                        core_cmd <= #Tcq I2C_CMD_READ;
                     end
                     else
                     begin
                        c_state <= #Tcq states_st_write;
                        core_cmd <= #Tcq I2C_CMD_WRITE;
                        
                        shift <= #Tcq 1'b1;
                     end
                  end
               
               states_st_read :
                  if (core_ack == 1'b1)
                  begin
                     if (cnt_done == 1'b1)
                     begin
                        c_state <= #Tcq states_st_ack;
                        core_cmd <= #Tcq I2C_CMD_WRITE;
                     end
                     else
                     begin
                        c_state <= #Tcq states_st_read;
                        core_cmd <= #Tcq I2C_CMD_READ;
                     end
                     
                     shift <= #Tcq 1'b1;
                     core_txd <= #Tcq ack_in;
                  end
               
               states_st_ack :
                  if (core_ack == 1'b1)
                  begin
                     if (stop == 1'b1)
                     begin
                        c_state <= #Tcq states_st_stop;
                        core_cmd <= #Tcq I2C_CMD_STOP;
                     end
                     else
                     begin
                        c_state <= #Tcq states_st_idle;
                        core_cmd <= #Tcq I2C_CMD_NOP;
                     end
                     
                     ack_out <= #Tcq core_rxd;
                     
                     host_ack <= #Tcq 1'b1;
                     
                     core_txd <= #Tcq 1'b1;
                  end
                  else
                     core_txd <= #Tcq ack_in;
               
               states_st_stop :
                  if (core_ack == 1'b1)
                  begin
                     c_state <= #Tcq states_st_idle;
                     core_cmd <= #Tcq I2C_CMD_NOP;
                  end
               
               default :
                  begin
                     c_state <= #Tcq states_st_idle;
                     core_cmd <= #Tcq I2C_CMD_NOP;
                     $display("Byte controller entered illegal state.");
                  end
            endcase
         end
      end
   end
   
endmodule
