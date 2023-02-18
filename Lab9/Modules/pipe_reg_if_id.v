`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.02.2023 16:47:08
// Design Name: 
// Module Name: pipe_reg
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


module pipe_reg_if_id(
    input clk,
    input WMemEnIn, WRegEnIn,           //Memory Write Enable and Regiser Write Enable
    input [4:0]rsAddr1In, rsAddr2In, rdAddrIn,      //Source and destination registers
    output reg WMemEnOut, WRegEnOut,           
    output reg [4:0]rsAddr1Out, rsAddr2Out, rdAddrOut
    );
    
    always@(posedge clk)
    begin
        WMemEnOut       <= WMemEnIn;
        WRegEnOut       <= WRegEnIn;
        rsAddr1Out      <= rsAddr1In;
        rsAddr2Out      <= rsAddr2In;
        rdAddrOut       <= rdAddrIn;
    end
    
endmodule
