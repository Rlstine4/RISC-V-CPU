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
	input en, clk, rst, jumpFlag, branchFlag,
	input [1:0]jumpThread, branchThread,
	input [8:0]jumpAddr, branchAddr,
	output reg [8:0]pcOut,
	output reg [1:0]threadSelect_current,
	output reg pc_reset
    );
	
	reg [8:0]pc[0:3];
	reg [1:0]threadSelect;
	
	always@(posedge clk)
	begin
		if(en == 1'b0)
		begin
			pcOut 					<= pc[threadSelect];
			threadSelect 			<= threadSelect;
			threadSelect_current	<= threadSelect;
		end
		else
		begin
			pc_reset					<=	rst;
			if(rst == 1'b1)
			begin
				pc[0]					<=	9'd0;
				pc[1]					<=	9'd0;
				pc[2]					<=	9'd0;
				pc[3]					<=	9'd0;
				pcOut	 				<= 	9'd0;
				threadSelect 			<= 	2'd0;
				threadSelect_current	<= 	threadSelect;
			end 
			else if(pc[threadSelect] == 9'h1FF)
			begin
				pcOut 					<= pc[threadSelect];
				threadSelect 			<= threadSelect + 1;
				threadSelect_current	<= threadSelect;
			end
			else
			begin
				pcOut 					<= pc[threadSelect];
				pc[threadSelect]		<= pc[threadSelect] + 1;
				threadSelect 			<= threadSelect + 1;
				threadSelect_current	<= threadSelect;
				if(jumpFlag == 1'b1)
				begin
					pc[jumpThread] <= jumpAddr;
				end
				if(branchFlag == 1'b1)
				begin
					pc[branchThread] 	<=	branchAddr;
					pcOut				<= 	branchAddr;
				end
			end
		end
	end

endmodule
