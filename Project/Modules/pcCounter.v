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
	input en, clk, rst, jumpFlag, branchFlag, core_enable,
	input [1:0]jumpThread, branchThread,
	input [8:0]jumpAddr, branchAddr,
	output reg [8:0]pcOut,
	output reg [1:0]threadSelect_current,
	output reg pc_reset,
	output core_ready
    );
	
	reg [8:0]pc[0:3];
	reg [1:0]threadSelect;
	reg thread_ready[0:3];
	
	assign core_ready = thread_ready[0] && thread_ready[1] && thread_ready[2] && thread_ready[3];
	
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
				if(core_enable == 1'b1)
				begin
					thread_ready[0]			<=	1'b1;
					thread_ready[1]			<=	1'b1;
					thread_ready[2]			<=	1'b1;
					thread_ready[3]			<=	1'b1;
				end
				else
				begin
					thread_ready[0]			<=	1'b0;
					thread_ready[1]			<=	1'b0;
					thread_ready[2]			<=	1'b0;
					thread_ready[3]			<=	1'b0;
				end
			end 
			else if(pc[threadSelect] == 9'h1FF)
			begin
				pcOut 						<= 	pc[threadSelect];
				threadSelect 				<= 	threadSelect + 1;
				threadSelect_current		<= 	threadSelect;
				thread_ready[threadSelect]	<=	1'b1;
			end
			else
			begin
				pcOut 						<= pc[threadSelect];
				pc[threadSelect]			<= pc[threadSelect] + 1;
				threadSelect 				<= threadSelect + 1;
				threadSelect_current		<= threadSelect;
				
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
