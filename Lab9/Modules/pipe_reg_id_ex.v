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
	input [63:0]rsData1In, rsData2In,
    input [4:0]rdAddrIn,
    input [11:0] intermediate_in,
    input alu_op_in, alu_src_in, branch_in, mem_read_in, mem_write_in, reg_write_in, mem_to_reg_in,              
    output reg alu_op_out, alu_src_out, branch_out, mem_read_out, mem_write_out, reg_write_out, mem_to_reg_out,
    output reg [11:0] intermediate_out,
	output reg [63:0]rsData1Out, rsData2Out,	
    output reg [4:0]rdAddrOut
    );
    
    always@(posedge clk)
    begin
        rsData1Out       <= rsData1In;
        rsData2Out       <= rsData2In;
        rdAddrOut        <= rdAddrIn;
        alu_op_out       <= alu_op_in;
        alu_src_out      <= alu_src_in;
        branch_out       <= branch_in;
        mem_read_out     <= mem_read_in;
        mem_write_out    <= mem_write_in;
        reg_write_out    <= reg_write_in;
        mem_to_reg_out   <= mem_to_reg_in; 
        intermediate_out <= intermediate_in;
    end


endmodule
