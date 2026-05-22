module I2C_slave(clk,SDA_out,SCL_out);

input clk;
inout SDA_out;
inout SCL_out;


reg       SDA;
reg       start_detect;
reg       stop_detect;
reg       cnt_enable;
reg [7:0] data_mem;
reg [7:0] addr_mem;
reg [2:0] clk_cnt=7;


localparam ADDRESS =7'b1010101;

localparam IGNORE     = 0, 
           START      = 1,
           ADDR       = 2,
           ACK        = 3, 
           WRITE      = 4,
           WRITE_ACK  = 5,
           READ       = 6,
           READ_ACK   = 7,
           STOP       = 8;



reg [3:0]  state = START;
reg [15:0] SCL_period_cnt;
reg        SCL_prev;
reg [15:0] measured_period;


always@(posedge clk)
    begin
        SCL_prev <= SCL_out;
        if(SCL_out != SCL_prev)
            begin
                measured_period <= SCL_period_cnt;
                SCL_period_cnt <= 0;
            end
        else    
            begin
                 if(state != START)
                SCL_period_cnt <= SCL_period_cnt + 1;
            end
    end
                
                        
                
            


always@(negedge SDA_out)
    begin
        if(SCL_out)
            start_detect <= 1;
        else
            start_detect <= 0;    
    end 

always@(posedge SDA_out)
    begin
        if(SCL_out)
            stop_detect <= 1;
        else
            stop_detect <= 0;    
    end 

always@(*)
    begin
        if(start_detect)
            state = ADDR;
    end
 
 
 
always@(posedge SCL_out)
    begin
        
       if(state == ADDR || state == READ || state == WRITE)
            begin
                clk_cnt <= clk_cnt -1;   
            end
        else if(clk_cnt == 0)
            clk_cnt <= 7;  
    end
    
     
  
    
 always@(posedge SCL_out)
    begin   
        case(state)
            START      : begin
                                    SDA  <= 1;
                                    state <= ADDR;
                                    clk_cnt <= 7;
                                    
                         end
                       
            ADDR       : begin
                              SDA <= 1;
                              addr_mem[clk_cnt] <= SDA_out;
                                begin
                               if(clk_cnt == 0 && addr_mem[7:1]== ADDRESS)
                                   state <= ACK;
                               else if(clk_cnt == 0 && addr_mem[7:1] != ADDRESS) 
                                   state <= IGNORE;   
                               else
                                    state <= ADDR;   
                           end
                        end
            ACK        :  begin
                                begin
                                    if(addr_mem[0] == 0)
                                          state <= WRITE;
                                    else if(addr_mem[0]== 1) 
                                          state <= READ ;
                                end    
                                    
                          end
                              
             WRITE     : begin
                           data_mem[clk_cnt] <= SDA_out;
                           SDA <= 1;
                           if(clk_cnt == 0)
                              state <= WRITE_ACK;
                           else
                              state <= WRITE;
                           end
       
             WRITE_ACK :    begin
                                 state <= STOP;
                            end            
        
              READ     :     begin
                                   if(clk_cnt == 0)
                                        state <= READ_ACK;
                                   else
                                        state <= READ; 
                             end
                                          
              READ_ACK :   begin
                                  state <= STOP;                                
                           end
                                 
              STOP     :  begin 
                            state <= START; 
                          end  
              
              IGNORE     : begin
                            if(stop_detect)
                                state <= START;
                             else 
                                state <= IGNORE;                         
                          end
                                   
                  default : state <= START;                                                           
       endcase
   end

always@(negedge clk)
    begin
        if(~SCL_out)
        case(state)
            START       :   begin
                                SDA        <=  1;
                            end        
            ADDR        :  begin
                              
                           end                      
                            
            ACK         :   begin
                                SDA <= 0;
                            end 
            
            WRITE       :  begin
                              SDA <= 1;  
                            end   
                                           
            WRITE_ACK   : begin
                                SDA <= 0;
                            end    
                            
                                    
            READ        : begin
                                if(~SCL_out)
                                    SDA  <= data_mem[clk_cnt];
                          end      
                                
            READ_ACK    : begin
                                SDA <= 1;
                          end
                          
            STOP      : begin
                           SDA <= 1;
                        end              
        endcase
     end
  
               
  
 assign SDA_out = (SDA==0)? 1'b0:1'bz;
 
 
 endmodule            

