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
    input clk, en, clr,
	input [8:0]if_pc,
	input [1:0]if_threadId,
	output reg [8:0]id_pc,
	output reg [1:0]id_threadId
    );
    
    always@(posedge clk)
	if (en == 1'b0 || clr == 1'b1)
	begin
		id_pc		<=	0;
		id_threadId	<=	0;
	end
	else
    begin
        id_pc       <= 	if_pc;
		id_threadId	<=	if_threadId;
    end
    
endmodule
