`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   03:02:16 02/22/2023
// Design Name:   pcCounter
// Module Name:   C:/Documents and Settings/Mehul/My Documents/EE533/Lab9/pcCounter_tb.v
// Project Name:  Lab9
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: pcCounter
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module pcCounter_tb;

	// Inputs
	reg en;
	reg clk;
	reg rst;
	reg [1:0]PCSrc;
	reg [8:0] branchAddr, jumpAddr;
	
	wire [8:0]pc;

	// Instantiate the Unit Under Test (UUT)
	pcCounter uut (
		.en(en),
		.clk(clk), 
		.rst(rst), 
		.PCSrc(PCSrc), 
		.branchAddr(branchAddr),
		.jumpAddr(jumpAddr),
		.pc(pc)
	);

	initial begin
		// Initialize Inputs
		en=1;
		clk = 0;
		rst = 0;
		PCSrc = 0;
		branchAddr = 100;
		jumpAddr = 50;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		rst = 1;
		#225;
		rst = 0;
		
		#500;
		PCSrc = 1;
		#50;
		PCSrc = 0;
		
		#500;
		PCSrc = 2;

	end
	
	always #50 clk = ~clk;
      
endmodule

