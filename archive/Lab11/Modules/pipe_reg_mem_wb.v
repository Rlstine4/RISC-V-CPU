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
	input en, clk, mem_reg_write_in, mem_to_reg_in,
	input mem_fifo_select,
    input [4:0] rdAddrIn,
	input [63:0]mem_mem_out, mem_alu_out,
	input [1:0]mem_threadId,
	output reg wb_fifo_select,
    output reg wb_reg_write, wb_mem_to_reg,
    output reg [4:0]rdAddrOut,
	output reg [63:0]wb_mem_out, wb_alu_out,
	output reg [1:0]wb_threadId
    );

	always@(posedge clk)
	if (en == 1'b0)
    begin
		wb_reg_write  	<= 0;
		wb_mem_to_reg 	<= 0;
		rdAddrOut     	<= 0;
		wb_mem_out		<= 0;
		wb_alu_out		<= 0;
		wb_fifo_select  <= 0;
		wb_threadId  <= 0;
	end
	else
	begin
		wb_reg_write  	<= mem_reg_write_in;
		wb_mem_to_reg 	<= mem_to_reg_in;
		rdAddrOut     	<= rdAddrIn;
		//wb_mem_out	<= mem_mem_out;
		wb_alu_out		<= mem_alu_out;
		wb_fifo_select  <= mem_fifo_select;
		wb_threadId  	<= mem_threadId;
	end

endmodule
