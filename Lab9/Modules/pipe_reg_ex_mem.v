`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:57:07 02/15/2023 
// Design Name: 
// Module Name:    pipe_reg_ex_mem
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
module pipe_reg_ex_mem(
	input clk, clr,
    input [63:0]ex_alu_output, rsData2In,
    input [4:0]rdAddrIn,
    input ex_overflow, ex_mem_read, ex_mem_write, ex_reg_write, ex_mem_to_reg,
    output reg mem_overflow, mem_read, mem_write, mem_reg_write, mem_to_reg,
    output reg [4:0]rdAddrOut,
    output reg [63:0]rsData2Out, mem_alu_output
    );

	always@(posedge clk)
	if (clr == 1'b1)
    begin
        mem_alu_output 	<= 0;
		mem_overflow   	<= 0;
		mem_read       	<= 0;
		mem_write      	<= 0;
		mem_reg_write  	<= 0;
		mem_to_reg     	<= 0;
		rdAddrOut      	<= 0;
		rsData2Out		<= 0;
    end
    else
	begin
		mem_alu_output 	<= ex_alu_output;
		mem_overflow   	<= ex_overflow;
		mem_read       	<= ex_mem_read;
		mem_write      	<= ex_mem_write;
		mem_reg_write  	<= ex_reg_write;
		mem_to_reg     	<= ex_mem_to_reg;
		rdAddrOut      	<= rdAddrIn;
		rsData2Out		<= rsData2In;
	end

endmodule
