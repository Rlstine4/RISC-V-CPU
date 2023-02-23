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
	input clk,
    input [63:0]ex_alu_output,
    input ex_overflow, ex_branch, ex_mem_read, ex_mem_write, ex_reg_write, ex_mem_to_reg,
    output reg mem_overflow, mem_branch, mem_read, mem_write, mem_reg_write, mem_to_reg, 
    output reg [63:0]mem_alu_output
    );

	always@(posedge clk)
		begin
            mem_alu_output <= ex_alu_output;
            mem_overflow   <= ex_overflow;
            mem_branch     <= ex_branch;
            mem_read       <= ex_mem_read;
            mem_write      <= ex_mem_write;
            mem_reg_write  <= ex_reg_write;
            mem_to_reg     <= ex_mem_to_reg;
		end

endmodule
