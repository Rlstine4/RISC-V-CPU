`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:05:37 02/15/2023
// Design Name:   datapath
// Module Name:   C:/Documents and Settings/Mehul/My Documents/EE533/lab8_new/datapath_tb.v
// Project Name:  lab8_new
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
	reg [7:0]memAddr;
	reg [63:0]memInData;
	wire [63:0]memOutData;
	
	//instruction Fetch wires
	wire [8:0]pc;
	wire [31:0]if_inst;
	
	//instruction decode wires
	wire id_WMemEn, id_WRegEn;
	wire [4:0]id_rs1, id_rs2, id_rd;
	wire [63:0]id_rsData1, id_rsData2;
	
	//Execution stage wires
	wire ex_WMemEn, ex_WRegEn;
	wire [4:0]ex_rd;
	wire [63:0]ex_rsData1, ex_rsData2;
	
	//Memory stage wires
	wire mem_WMemEn, mem_WRegEn;
	wire [4:0]mem_rd;
	wire [63:0]mem_rsData1, mem_rsData2, mem_rdData;
	
	//WriteBack stage wires
	wire wb_WRegEn;
	wire [4:0]wb_rd;
	wire [63:0]wb_rdData;

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
	assign id_WMemEn = uut.id_WMemEn;
	assign id_WRegEn = uut.id_WRegEn;
	assign id_rs1 = uut.id_rs1;
	assign id_rs2 = uut.id_rs2;
	assign id_rd = uut.id_rd;
	assign id_rsData1 = uut.id_rsData1;
	assign id_rsData2 = uut.id_rsData2;
	assign ex_WMemEn = uut.ex_WMemEn;
	assign ex_WRegEn = uut.ex_WRegEn;
	assign ex_rd = uut.ex_rd;
	assign ex_rsData1 = uut.ex_rsData1;
	assign ex_rsData2 = uut.ex_rsData2;
	assign mem_WMemEn = uut.mem_WMemEn;
	assign mem_WRegEn = uut.mem_WRegEn;
	assign mem_rd = uut.mem_rd;
	assign mem_rsData1 = uut.mem_rsData1;
	assign mem_rsData2 = uut.mem_rsData2;
	assign mem_rdData = uut.mem_rdData;
	assign wb_WRegEn = uut.wb_WRegEn;
	assign wb_rd = uut.wb_rd;
	assign wb_rdData = uut.wb_rdData;
	
	

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		memWE = 0;
		memAddr = 10;
		memInData = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		rst=1;
		#125;
		rst=0;

	end
	
	always #50 clk =~clk;
      
endmodule

