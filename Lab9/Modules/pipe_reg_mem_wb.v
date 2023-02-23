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
	input clk, mem_reg_write_in, mem_to_reg_in, 
    input [4:0] rdAddrIn,
    output reg wb_reg_write, wb_mem_to_reg
    output reg [4:0] rdAddrOut
    );

	always@(posedge clk)
		begin
			wb_reg_write  <= mem_reg_write_in;
            wb_mem_to_reg <= mem_to_reg_in;
            rdAddrOut     <= rdAddrIn;
		end

endmodule
