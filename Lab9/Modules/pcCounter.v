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
	input en, clk, rst, 
	input [1:0]PCSrc, 
	input [8:0]branchAddr, jumpAddr,
	output reg [8:0]pc	
    );
	
	always@(posedge clk)
	begin
		if(en == 1'b0)
		begin
			pc <= pc;
		end
		else
		begin
			if(rst == 1'b1)
			begin
				pc <= 9'd0;
			end
			else 
			begin
				if(pc == 9'b111111111)
				begin
					pc <= pc;
				end
				else if (PCSrc == 2'b01)
				begin
					pc <= branchAddr;
				end
				else if (PCSrc == 2'b10)
				begin
					pc <= jumpAddr;
				end
				else
				begin
					pc <= pc + 1;
				end
			end
		end
	end

endmodule
