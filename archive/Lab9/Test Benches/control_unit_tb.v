`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:11:49 02/23/2023
// Design Name:   control_unit
// Module Name:   C:/Documents and Settings/Mehul/My Documents/EE533/Lab9/control_unit_tb.v
// Project Name:  Lab9
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: control_unit
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module control_unit_tb;

	// Inputs
	reg [6:0] opcode;
	reg [7:0] funct7;
	reg [2:0] funct3;

	// Outputs
	wire [3:0] alu_op;
	wire alu_src;
	wire branch;
	wire jump;
	wire mem_read;
	wire mem_write;
	wire reg_write;
	wire mem_to_reg;

	// Instantiate the Unit Under Test (UUT)
	control_unit uut (
		.opcode(opcode), 
		.funct7(funct7), 
		.funct3(funct3), 
		.alu_op(alu_op), 
		.alu_src(alu_src), 
		.branch(branch), 
		.jump(jump), 
		.mem_read(mem_read), 
		.mem_write(mem_write), 
		.reg_write(reg_write), 
		.mem_to_reg(mem_to_reg)
	);

	initial begin
		// Initialize Inputs
		opcode = 0;
		funct7 = 0;
		funct3 = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		opcode = 7'b0000000;
		
		#100
		
		opcode = 7'b0110011;
		funct7 = 7'b0000000;
		funct3 = 3'b000;
		
		#100
		
		opcode = 7'b0110011;
		funct7 = 7'b0100000;
		funct3 = 3'b000;
		
		#100
		
		opcode = 7'b0110011;
		funct7 = 7'b0000000;
		funct3 = 3'b111;
		
		
		

	end
      
endmodule

