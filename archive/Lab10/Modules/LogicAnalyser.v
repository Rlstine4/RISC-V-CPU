`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:30:28 02/28/2023 
// Design Name: 
// Module Name:    LogicAnalyser 
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
module LogicAnalyser(
	input en, clk, we,
	input [255:0]data,
	input [13:0]logicAddr, 
	output [217:0]logicOut
    );
	
	wire [255:0]dout_la; 
	reg [13:0]writeloc;
	
	always@(posedge clk)
	begin 
		if(en == 1'b0)
		begin
			writeloc <= 0;
		end
		else
		begin
			if(we == 1'b0 || writeloc == 14'h7FFF)
			begin
				writeloc <= writeloc;
			end
			else
			begin
				writeloc <= writeloc + 1'b1;
			end
		end
	end
	
	logicAnalyzerBRAM la1(.addra(writeloc), .addrb(logicAddr), .clka(clk), .clkb(clk), .dina(data), .doutb(dout_la), .ena(en), .wea(we));
	
	assign logicOut = {dout_la[255:38]};


endmodule
