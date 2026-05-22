module I2C_master (clk,clk_divide,reset,start,write_en,count,addr,data,SDA_out,SCL_out,read_data);

input        clk;
input        clk_divide;
input        reset;
input        start;
input        write_en;
input [9:0]  count;
input [6:0]  addr;
input [7:0]  data;
inout        SDA_out;
output       SCL_out;
output [7:0] read_data;





reg        clk_enable;
reg        SDA;
wire       SCL;
reg        cnt_enable;  
reg [2:0]  clk_cnt;
reg [7:0]  addr_mem;
reg [7:0]  data_mem;
reg [7:0]  read_mem;


localparam IDLE             = 0, 
           START            = 1,
           ADDR             = 2,
           ACK              = 3, 
           WRITE            = 4,
           WRITE_ACK        = 5,
           READ             = 6,
           READ_ACK         = 7,
           STOP             = 8,
           DUMMY            = 9;
         
     
           
reg [3:0]  state;
reg scl_d;


wire negedge_SCL;
wire SDA_input;


assign negedge_SCL = ~SCL_out && scl_d;
assign posedge_SCL = SCL_out  && ~scl_d;


always@(posedge clk,negedge reset)
    begin
        if(~reset)
            begin
                scl_d <= 0;
             end
        else
            begin
                scl_d <= SCL_out;
            end
    end

                            
 
//always@(posedge clk_divide,negedge reset)
//    begin
//        if(~reset)
//            begin
//                SCL     <= 1;
//            end
//        else if(clk_enable || state == ADDR || state == STOP || state == START)
//            begin
//                    SCL <= ~SCL;
//            end
//        else 
//            SCL <= 1;    
//  end


assign SCL = (clk_enable || state == ADDR || state == STOP || state == START)? clk_divide ^ 1 : 1'b1;

                 
    
always@(posedge clk or negedge reset)
    begin
         if(~reset)
            begin
                clk_cnt <= 3'd7;
            end
                
         else if(state == ADDR || state == READ || state == WRITE)
                begin
                        if(SCL && count == 249)
                            clk_cnt <= clk_cnt -1;   
                end
         else 
               begin 
                    clk_cnt <= 7;
               end      
    end   
     

  

always@(posedge clk,negedge reset)
    begin
        if(~reset)
            begin
                read_mem <= 8'd0;
                addr_mem <= 8'd0;
                data_mem <= 8'd0;
                state    <= IDLE;
            end
       else if(start && state == IDLE)
            begin
                state <= START;
                addr_mem <= {addr,write_en};
                data_mem <= data;
            end
       else                  
                      begin
                              case(state)
                                   START           : begin
                                                         if(negedge_SCL)
                                                            state <= ADDR;
                                                     end       
                                       
                                   ADDR            :  begin
                                                         if(SCL && count == 249 )
                                                            begin
                                                               if(clk_cnt == 0)
                                                                  state <= ACK;
                                                               else
                                                                  state <= ADDR;
                                                            end            
                                                      end
                                                   
                                                      
                                   ACK             :  begin
                                                             if(SCL && count == 249)
                                                                begin
                                                                        if(SDA_input)
                                                                            state <= ADDR;
                                                                        else
                                                                            begin
                                                                                if(~SDA_input && ~addr_mem[0])
                                                                                    state <= WRITE;
                                                                                else if(~SDA_input && addr_mem[0])
                                                                                    state <= READ;
                                                                            end
                                                                end             
                                                      end 
                                                          
                                   WRITE           :  begin
                                                         if(SCL && count == 249)
                                                            begin
                                                                 if(clk_cnt == 0)
                                                                    state <= WRITE_ACK;
                                                                 else
                                                                    state <= WRITE;   
                                                           end
                                                      end       
              
                                   WRITE_ACK       :  begin
                                                          if(SCL && count == 249)
                                                            begin
                                                                 if(SDA_input)
                                                                     state <= WRITE;
                                                                 else if(~SDA_input && start)
                                                                     state <= WRITE;
                                                                 else if(~SDA_input)
                                                                     state <= STOP ;
                                                            end         
                                                        end         
                                                           
                                   READ            :  begin
                                                            if(SCL && count == 249)
                                                                begin
                                                                    read_mem[clk_cnt] <= SDA_input;
                                                                    if(clk_cnt == 0)
                                                                         state <= READ_ACK;
                                                                    else
                                                                         state <= READ;
                                                                end
                                                      end
                                                                      
                                   READ_ACK        :  begin
                                                                begin
                                                                    if(SCL && count == 249)
                                                                    state <= STOP;  
                                                                end                                  
                                                      end
                                                              
                                   STOP            :  begin
                                                          if(SCL && count == 249)
                                                              state <= DUMMY; 
                                                      end 
                                  DUMMY            : begin
                                                         if(count == 499)
                                                            state <=IDLE;
                                                     end                           
                                    
                              endcase
                       end
     end                  
                         
  always@(posedge clk,negedge reset)
    begin
        if(~reset)
            begin
               SDA        <= 1;
               clk_enable <= 0;
            end   
        else if(state == START)
            begin
                SDA  <= 0;
            end     
        else if(~SCL_out && count == 249)   
            begin
                case(state)
                    IDLE                :   begin
                                                SDA <= 1;
                                                clk_enable <= 0;
                                            end
                                            
                                            
                    START               :   begin
                                                 clk_enable <= 1;
                                            end        
                                              
                    ADDR                :   begin
                                                clk_enable <= 1;
                                                SDA <= addr_mem[clk_cnt];
                                            end                          

                    ACK                 :   begin
                                                SDA <= 1;
                                                clk_enable <= 1;
                                                
                                            end 

                    WRITE               :  begin
                                                clk_enable <= 1;
                                                SDA <= data_mem[clk_cnt];
                                                
                                            end   
                                                           
                    WRITE_ACK           : begin
                                                clk_enable <= 1;
                                                SDA <= 1;
                                            end    
                                            
                                                    
                    READ                : begin
                                                clk_enable <= 1;
                                          end      
                                                
                    READ_ACK            : begin
                                                clk_enable <= 1;
                                                SDA <= 0;
                                          end
                                          
                    STOP                : begin
                                                SDA <= 0;
                                                clk_enable <= 0;
                                          end
                    
                endcase
              end  
          else
                begin
                     case(state)
                          IDLE  : begin
                                      SDA <= 1;
                                  end
                                  
                          DUMMY : begin
                                     SDA <= 0;
                                  end             
                     endcase
               end       
                              
     end
       
                     

                     
assign read_data = read_mem;            
assign SCL_out   = SCL ;


  IOBUF iobuf_sda (
                       .I(1'b0),               
                       .IO(SDA_out),           
                       .O(SDA_input),             
                       .T(SDA)      
                    );  


endmodule