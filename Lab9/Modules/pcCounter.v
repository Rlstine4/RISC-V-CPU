`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:01:22 02/15/2023 
// Design Name: 
// Module Name:    pcCounter 
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
module pcCounter(
	input clk, rst, PCSrc, 
	input [8:0]branchAddr,
	output reg [8:0]pc	
    );
	
	always@(posedge clk)
	begin
		if(rst == 1'b1)
		begin
			pc <= 9'd0;
		end
		else 
		begin
			if (PCSrc)
			begin
				pc <= branchAddr;
			end
			else
			begin
				pc <= pc + 1;
			end
		end
	end

endmodule
