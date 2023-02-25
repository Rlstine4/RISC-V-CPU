`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.02.2023 16:47:08
// Design Name: 
// Module Name: pipe_reg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pipe_reg_if_id(
    input en, clk, clr,
    input [31:0]instruction_in,
    output reg [31:0]instruction_out
    );
    
    always@(posedge clk)
    begin
		if(en == 1'b0)
		begin
			instruction_out <= instruction_out;
		end
		else
		begin
			if(clr == 1'b1)
			begin
				instruction_out <= 0;
			end
			else
			begin
				instruction_out <= instruction_in;
			end
		end
    end
    
endmodule
