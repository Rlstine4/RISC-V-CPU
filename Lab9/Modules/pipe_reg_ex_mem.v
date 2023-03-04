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
	input en, clk, clr,
    input [63:0]ex_alu_output, rsData2In,
    input [4:0]rdAddrIn,
    input ex_overflow, ex_mem_read, ex_mem_write, ex_reg_write, ex_mem_to_reg, ex_branch, ex_equal, ex_not_equal, ex_less_than, ex_greater_than_equal, 
	input [3:0]ex_alu_op,
	input [12:0]branch_offset_in,
    output reg mem_overflow, mem_read, mem_write, mem_reg_write, mem_to_reg, mem_branch, mem_equal, mem_not_equal, mem_less_than, mem_greater_than_equal, 
	output reg [3:0]mem_alu_op,
    output reg [4:0]rdAddrOut,
    output reg [63:0]rsData2Out, mem_alu_output,
	output reg [12:0]branch_offset_out
    );

	always@(posedge clk)
	if (en == 1'b0 || clr == 1'b1)
    begin
        mem_alu_output 				<= 0;
		mem_overflow   				<= 0;
		mem_read       				<= 0;
		mem_write      				<= 0;
		mem_reg_write  				<= 0;
		mem_to_reg     				<= 0;
		rdAddrOut      				<= 0;
		rsData2Out					<= 0;
		mem_branch					<= 0;
		mem_equal					<= 0;
		mem_not_equal				<= 0;
		mem_less_than				<= 0;
		mem_greater_than_equal		<= 0;
		mem_alu_op					<= 0;
		branch_offset_out			<= 0;
    end
    else
	begin
		mem_alu_output 				<= 	ex_alu_output;
		mem_overflow   				<= 	ex_overflow;
		mem_read       				<= 	ex_mem_read;
		mem_write      				<= 	ex_mem_write;
		mem_reg_write  				<= 	ex_reg_write;
		mem_to_reg     				<= 	ex_mem_to_reg;
		rdAddrOut      				<= 	rdAddrIn;
		rsData2Out					<= 	rsData2In;
		mem_branch 					<= 	ex_branch;
		mem_equal					<=	ex_equal;
		mem_not_equal				<=	ex_not_equal;
		mem_less_than				<=	ex_less_than;
		mem_greater_than_equal		<= 	ex_greater_than_equal;
		mem_alu_op					<= 	ex_alu_op;
		branch_offset_out			<= 	branch_offset_in;
	end

endmodule
