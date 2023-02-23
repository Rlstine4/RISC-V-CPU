`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:45:42 02/22/2023
// Design Name:   datapath
// Module Name:   C:/Documents and Settings/Mehul/My Documents/EE533/Lab9/datapath_tb.v
// Project Name:  Lab9
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: datapath
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module datapath_tb;

	// Inputs
	reg clk;
	reg rst;
	reg memWE;
	reg [7:0] memAddr;
	reg [63:0] memInData;

	// Outputs
	wire [63:0] memOutData;
	
	//instruction Fetch wires
	wire [8:0]pc;
	wire [31:0]if_inst;
    wire PCSrc;
    wire [8:0]branchAddr;

	// Instantiate the Unit Under Test (UUT)
	datapath uut (
		.clk(clk), 
		.rst(rst), 
		.memWE(memWE), 
		.memAddr(memAddr), 
		.memInData(memInData), 
		.memOutData(memOutData)
	);
	
	assign pc = uut.pc;
	assign if_inst = uut.if_inst;	
	assign PCSrc = uut.PCSrc;
	assign branchAddr = uut.branchAddr;


	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		memWE = 0;
		memAddr = 0;
		memInData = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		rst = 1;
		#225;
		rst = 0;
		
		#300;
		force uut.branchAddr = 100;
		force uut.PCSrc = 1;
		#50;
		force uut.branchAddr = 100;
		force uut.PCSrc = 0;

	end
	
	always #50 clk = ~clk;
      
endmodule

