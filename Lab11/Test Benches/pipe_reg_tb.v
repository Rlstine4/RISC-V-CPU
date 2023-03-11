`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.02.2023 16:56:23
// Design Name: 
// Module Name: pipe_reg_tb
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


module pipe_reg_tb();

    reg clk;
    reg WMemEnIn, WRegEnIn;       
    reg [4:0]rs1In, rs2In, rdIn;      
    reg [14:0]futureUseIn;
    wire WMemEnOut, WRegEnOut;          
    wire [4:0]rs1Out, rs2Out, rdOut;     
    wire [14:0]futureUseOut;
    
    wire WMemEnDummy, WRegEnDummy;          
    wire [4:0]rs1Dummy, rs2Dummy, rdDummy;     
    wire [14:0]futureUseDummy;
    
    pipe_reg dut1(clk, WMemEnIn, WRegEnIn, rs1In, rs2In, rdIn, futureUseIn, WMemEnDummy, 
        WRegEnDummy, rs1Dummy, rs2Dummy, rdDummy, futureUseDummy);
        
    pipe_reg dut2(clk, WMemEnDummy, WRegEnDummy, rs1Dummy, rs2Dummy, rdDummy, futureUseDummy, WMemEnOut, 
        WRegEnOut, rs1Out, rs2Out, rdOut, futureUseOut);    
        
    initial begin
        clk         = 1'b0;
        WMemEnIn    = 1'b0;
        WRegEnIn    = 1'b0;
        rs1In       = 5'b00000;
        rs2In       = 5'b00000;
        rdIn        = 5'b00000;
        futureUseIn = 15'd0;        
    end
    
    always #50 clk = ~clk;
    
    initial begin
        #225;
        WMemEnIn    <= 1'b1;
        WRegEnIn    <= 1'b1;
        rs1In       <= 5'b01000;
        rs2In       <= 5'b00100;
        rdIn        <= 5'b00010;
        futureUseIn <= 15'd1;
        #25;
        WMemEnIn    <= 1'b0;
        WRegEnIn    <= 1'b1;
        rs1In       <= 5'b0001;
        rs2In       <= 5'b01100;
        rdIn        <= 5'b00110;
        futureUseIn <= 15'd343;      
    end

endmodule
