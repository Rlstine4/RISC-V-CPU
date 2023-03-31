`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:52:40 03/30/2023 
// Design Name: 
// Module Name:    core_manager 
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
module core_manager(
		input clk, rst, match, core_busy,
		output reg core_enable
    );
	
	parameter 	IDLE = 1'b0,
				BUSY = 1'b1;
				
	reg state;
	always @(posedge clk)
	begin
		if(rst)
		begin
			state <= IDLE;
			core_enable <= 1'b0;
		end
		else
		begin
			case(state)
				IDLE:
				begin
					if(match == 1'b1)
					begin
						state <= BUSY;
						core_enable <= 1'b1;
					end
					else
					begin
						state <= IDLE;
						core_enable <= 1'b0;
					end
				end
				
				BUSY:
				begin
					if(core_busy == 1'b1)
					begin
						state <= BUSY;
						core_enable <= 1'b1;
					end
					else
					begin
						state <= IDLE;
						core_enable <= 1'b0;
					end
				end
			endcase
		end
	end
	


endmodule
