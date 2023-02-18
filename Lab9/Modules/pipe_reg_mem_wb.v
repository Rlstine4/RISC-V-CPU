`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:57:07 02/15/2023 
// Design Name: 
// Module Name:    pipe_reg_mem_wb 
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
module pipe_reg_mem_wb(
	input clk,
    input WRegEnIn,
    input [4:0]rdAddrIn,
	input [63:0]rdDataIn,
    output reg WRegEnOut,	
    output reg [4:0]rdAddrOut,
	output reg [63:0]rdDataOut
    );

	always@(posedge clk)
		begin
			WRegEnOut   <= WRegEnIn;
			rdAddrOut   <= rdAddrIn;
			rdDataOut	<= rdDataIn;
		end

endmodule
