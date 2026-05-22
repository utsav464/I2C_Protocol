module I2C_master_tb;

reg clk;
reg reset;
reg write_en;
reg [6:0] addr;
reg [7:0] data;
reg start;
wire [7:0] read_data;

top  dut(
             .clk(clk),
             .reset(reset),
             .write_en(write_en),
             .addr(addr),
             .data(data),
             .start(start),
             .read_data(read_data)
             
             );

pullup(dut.SDA_out);
pullup(dut.SCL_out);


initial begin
    clk = 0;
    forever #5 clk = ~clk;
end



initial begin
#40;
    reset = 0;
    start = 0;
    write_en = 0;   // 0 = Write
    addr = 7'b1010101;
    data = 8'hA5;
    #20;
    reset = 1;

    #20;
    start = 1;
    write_en = 0;
    #10;
    start = 0;
    #10;
    write_en = 0;
    
    
    
    
    #400;
    start = 1;
    write_en = 1;
   #10 start=0;


#400; 
    start = 1;
    write_en = 0;   // 0 = Write
    addr = 7'd10;
    data = 8'hb8;
    #10 start = 0;
    #10 write_en = 0;
    
    
//#40000; 
//    start = 1;
//    write_en = 0;   // 0 = Write
//    addr = 7'd10;
//    data = 8'h36;
//    #10 start = 0;
//    #10 write_en = 0;
    
    
    
//#40000; 
//    start = 1;
//    write_en = 1;   // 1 = Read
//    addr = 7'd10;
//    data = 8'hf3;
//    #10 start = 0;
    
    
//    #40000; 
//    start = 1;
//    write_en = 0;   // 0 = Write
//    addr = 7'd13;
//    data = 8'h55;
//    #10 start = 0;
//    #10 write_en = 0;            
    
    
    
    #1000;
    $finish;
end
  
endmodule
