`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:48:26 02/15/2023 
// Design Name: 
// Module Name:    pipe_reg 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module pipe_reg_id_ex(
	input clk,
    //input WMemEnIn, WRegEnIn,           			//Memory Write Enable and Regiser Write Enable
	input [63:0]rsData1In, rsData2In,
    input [4:0]rdAddrIn,
    //output reg WMemEnOut, WRegEnOut,
    output reg alu_op, alu_src, branch, jump, mem_read, mem_write, reg_write, mem_to_reg
	output reg [63:0]rsData1Out, rsData2Out,	
    output reg [4:0]rdAddrOut
    );
    
    always@(posedge clk)
    begin
        WMemEnOut       <= WMemEnIn;
        WRegEnOut       <= WRegEnIn;
        rsData1Out      <= rsData1In;
        rsData2Out      <= rsData2In;
        rdAddrOut       <= rdAddrIn;
    end


endmodule
