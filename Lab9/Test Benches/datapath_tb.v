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
	
	//instruction decode wires
    wire [31:0]id_inst;
    wire [6:0]opcode;
    wire [6:0]funct7;
    wire [2:0]funct3;
    wire [3:0]id_alu_op;
	wire id_alu_src, id_branch, id_jump, id_mem_read, id_mem_write, id_reg_write, id_mem_to_reg;
	wire id_WMemEn, id_WRegEn;
	wire [4:0]id_rs1, id_rs2, id_rd;
	wire [63:0]id_rsData1, id_rsData2;
    wire [11:0]intermediate_12; // I-Type, B-Type, S-Type instructions use 12 bit intermediate
    wire [20:0]intermediate_21; // JAL

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
	assign id_inst = uut.id_inst;
	assign opcode = uut.opcode;
	assign funct7 = uut.funct7;
	assign funct3 = uut.funct3;
	assign id_alu_op = uut.id_alu_op;
	assign id_alu_src = uut.id_alu_src;
	assign id_branch = uut.id_branch;
	assign id_jump = uut.id_jump;
	assign id_mem_read = uut.id_mem_read;
	assign id_mem_write = uut.id_mem_write;
	assign id_reg_write = uut.id_reg_write;
	assign id_mem_to_reg = uut.id_mem_to_reg;
	assign id_WMemEn = uut.id_WMemEn;
	assign id_WRegEn = uut.id_WRegEn;
	assign id_rs1 = uut.id_rs1;
	assign id_rs2 = uut.id_rs2;
	assign id_rd = uut.id_rd;
	assign id_rsData1 = uut.id_rsData1;
	assign id_rsData2 = uut.id_rsData2;
	assign intermediate_12 = uut.intermediate_12;
	assign intermediate_21 = uut.intermediate_21;
	
	


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
		
//		#700;
//		force uut.branchAddr = 100;
//		force uut.PCSrc = 1;
//		#50;
//		force uut.branchAddr = 100;
//		force uut.PCSrc = 0;

	end
	
	always #50 clk = ~clk;
      
endmodule

