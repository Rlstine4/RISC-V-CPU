`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.02.2023 20:42:25
// Design Name: 
// Module Name: RegFile_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module RegFile_tb();

reg clk, rst;
reg [4:0]raddr1, raddr2, waddr;
reg wen;
reg [63:0]wdata;
wire [63:0]rdata1, rdata2;
integer i=0;

RegFile dut(clk, rst, raddr1, raddr2, waddr, wen, wdata, rdata1, rdata2);

initial begin
    clk = 1'b0;
    rst = 1'b0;
    raddr1 = 5'b00000;
    raddr2 = 5'b00000;
    waddr = 5'b00000;
    wen = 1'b0;
    wdata = 64'h00000000;    
end

always #50 clk = ~clk;

initial begin
    #225;
    rst = 1'b1;
    #100;
    rst = 1'b0;
    
    //Writing randomly to all locations
    #200;
    wen = 1'b1;
    for(i=0; i<32; i= i+1)
    begin
        wdata[31:0] = $random;
        wdata[63:32] = $random;
        waddr = i;
        #100;        
    end
    wen = 1'b0;
    
    #200
    //reading from all locations
    for(i=0; i<32; i= i+1)
    begin
        raddr1 = i;
        raddr2 = 31 - i;
        #100;        
    end
    
end

endmodule
