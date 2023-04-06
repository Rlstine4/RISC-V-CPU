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
		input clk, rst, match, core1_busy, core2_busy,
		output reg core1_enable, core2_enable
    );
	
	parameter 	IDLE 		= 2'b00,
				BUSY_CORE1 	= 2'b01,
				BUSY_CORE2 	= 2'b10,
				BUSY_ALL	= 2'b11;
				
	reg [1:0]state;
	always @(posedge clk)
	begin
		if(rst)
		begin
			state <= IDLE;
			core1_enable <= 1'b0;
			core2_enable <= 1'b0;
		end
		else
		begin
			case(state)
				IDLE:
				begin
					if(match == 1'b1)
					begin
						state <= BUSY_CORE1;
						core1_enable <= 1'b1;
						core2_enable <= 1'b0;
					end
					else
					begin
						state <= IDLE;
						core1_enable <= 1'b0;
						core2_enable <= 1'b0;
					end
				end
				
				BUSY_CORE1:
				begin
					if(core1_busy == 1'b1 && match == 1'b1)
					begin
						state <= BUSY_ALL;
						core1_enable <= 1'b1;
						core2_enable <= 1'b1;
					end
					else if(core1_busy == 1'b1 && match == 1'b0)
					begin
						state <= BUSY_CORE1;
						core1_enable <= 1'b1;
						core2_enable <= 1'b0;
					end
					else if(core1_busy == 1'b0 && match == 1'b1)
					begin
						state <= BUSY_CORE2;
						core1_enable <= 1'b0;
						core2_enable <= 1'b1;
					end
					else
					begin
						state <= IDLE;
						core1_enable <= 1'b0;
						core2_enable <= 1'b0;
					end
				end

				BUSY_CORE2:
				begin
					if(core2_busy == 1'b1 && match == 1'b1)
					begin
						state <= BUSY_ALL;
						core1_enable <= 1'b1;
						core2_enable <= 1'b1;
					end
					else if(core2_busy == 1'b1 && match == 1'b0)
					begin
						state <= BUSY_CORE2;
						core1_enable <= 1'b0;
						core2_enable <= 1'b1;
					end
					else if(core2_busy == 1'b0 && match == 1'b1)
					begin
						state <= BUSY_CORE1;
						core1_enable <= 1'b1;
						core2_enable <= 1'b0;
					end
					else
					begin
						state <= IDLE;
						core1_enable <= 1'b0;
						core2_enable <= 1'b0;
					end
				end

				BUSY_ALL:
				begin
					if(core1_busy == 1'b1 && core2_busy == 1'b1)
					begin
						state <= BUSY_ALL;
						core1_enable <= 1'b1;
						core2_enable <= 1'b1;
					end		
					else if(core1_busy == 1'b1 && core2_busy == 1'b0)
					begin
						state <= BUSY_CORE1;
						core1_enable <= 1'b1;
						core2_enable <= 1'b0;
					end	
					else if(core1_busy == 1'b0 && core2_busy == 1'b1)
					begin
						state <= BUSY_CORE2;
						core1_enable <= 1'b0;
						core2_enable <= 1'b1;
					end		
					else
					begin
						state <= IDLE;
						core1_enable <= 1'b0;
						core2_enable <= 1'b0;
					end			
				end
			endcase
		end
	end
	


endmodule
