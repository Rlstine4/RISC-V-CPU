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
	input en, clk, clr,
	input [63:0]rsData1In, rsData2In,
    input [4:0]rdAddrIn,
    input [11:0] intermediate_in,
    input [3:0]alu_op_in, 
	input alu_src_in, branch_in, mem_read_in, mem_write_in, reg_write_in, mem_to_reg_in, id_fifo_select, id_process_end;
	input [12:0] branch_offset_in,
    output reg [3:0]alu_op_out, 
	output reg alu_src_out, branch_out, mem_read_out, mem_write_out, reg_write_out, mem_to_reg_out;
    output reg ex_fifo_select, ex_process_end;
    output reg [11:0] intermediate_out,
	output reg [63:0]rsData1Out, rsData2Out,	
    output reg [4:0]rdAddrOut,
	output reg [12:0] branch_offset_out
    );
    
    always@(posedge clk)

    if (en == 1'b0 || clr == 1'b1)
    begin
        rsData1Out       	<= 0;
        rsData2Out       	<= 0;
        rdAddrOut        	<= 0;
        alu_op_out       	<= 0;
        alu_src_out      	<= 0;
        branch_out       	<= 0;
        mem_read_out     	<= 0;
        mem_write_out    	<= 0;
        reg_write_out    	<= 0;
        mem_to_reg_out   	<= 0;
        intermediate_out 	<= 0;
		branch_offset_out 	<= 0;
        ex_fifo_select      <= 0;
        ex_process_end      <= 0;
    end
    else
    begin
        rsData1Out       	<= rsData1In;
        rsData2Out       	<= rsData2In;
        rdAddrOut        	<= rdAddrIn;
        alu_op_out       	<= alu_op_in;
        alu_src_out      	<= alu_src_in;
        branch_out       	<= branch_in;
        mem_read_out     	<= mem_read_in;
        mem_write_out    	<= mem_write_in;
        reg_write_out    	<= reg_write_in;
        mem_to_reg_out   	<= mem_to_reg_in; 
        intermediate_out 	<= intermediate_in;
		branch_offset_out 	<= branch_offset_in;
        ex_fifo_select      <= id_fifo_select;
        ex_process_end      <= id_process_end;
    end

endmodule
