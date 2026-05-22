module top(clk,reset,write_en,addr,data,start,read_data);
input        clk,reset;
input        write_en;
input [6:0]  addr;
input [7:0]  data;
input        start;
output [7:0] read_data;

wire SDA_out,SCL_out;

I2C_master master(
                  .clk_divide(clk),
                  .reset(reset),
                  .write_en(write_en),
                  .addr(addr),
                  .data(data),
                  .start(start),
                  .SDA_out(SDA_out),
                  .SCL_out(SCL_out),
                  .read_data(read_data)
                   
                   );
                   
                   
//clock_divider dut (
//                      .clk(clk),
//                      .enable(enable),
//                      .clk_divide(clk_divide)
                      
//                   );
//I2C_master2 master2(

//                    .clk(clk),
//                    .reset(reset),
//                    .write_en(write_en2),
//                    .addr(addr2),
//                    .data(data2),
//                    .start(start2),
//                    .SDA_out(SDA_out),
//                    .SCL_out(SCL_out),
//                    .read_data(read_data2)
                  
//                   );

I2C_slave1 slave1  (
                         .clk(clk),
                         .SDA_out(SDA_out),
                         .SCL_out(SCL_out)
                   );
                 
I2C_slave slave  ( 
                         .clk(clk),
                         .SDA_out(SDA_out),
                         .SCL_out(SCL_out)
                 );
                 
//I2C_slave2 slave2  ( 
//                         .clk(clk2),
//                         .SDA_out(SDA_out),
//                         .SCL_out(SCL_out)
//                 );
                 
                 
                 
                                  
endmodule
