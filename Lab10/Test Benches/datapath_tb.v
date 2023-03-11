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
    wire [1:0]PCSrc;
    wire [8:0]branchAddr, jumpAddr;
	
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
	wire [12:0] id_branch_offset;
    wire [19:0] jump_offset;
	wire id_stall;
	
	//Execution stage wires
	wire [4:0]ex_rd;
	wire [63:0]ex_rsData1, ex_rsData2, alu_B, ex_alu_out;
    wire [3:0]ex_alu_op;
	wire ex_alu_src, ex_branch, ex_mem_read, ex_mem_write, ex_reg_write, ex_mem_to_reg, ex_overflow;
    wire branch_flag; // Replaces the "ZERO" output in the tradidtional 5-stage pipeline
    wire ex_equal, ex_not_equal, ex_less_than, ex_greater_than_equal;
    wire [11:0] ex_intermediate_12;
    wire [63:0] signed_intermediate;
	wire [12:0] ex_branch_offset;
	
	//Memory stage wires
	wire mem_WMemEn;
	wire [4:0]mem_rd;
	wire [63:0]mem_rsData2, mem_mem_out;
    wire mem_overflow, mem_branch, mem_read, mem_write, mem_reg_write, mem_mem_to_reg;
    wire [63:0] mem_alu_out;
	
	//WriteBack stage wires
	wire wb_RegWrite, wb_mem_to_reg;
	wire [4:0]wb_rd;
	wire [63:0]wb_mem_out, wb_alu_out;
	wire [63:0]wb_rdData;
	
	//misc
	wire [63:0]register[0:31];
	wire [31:0]cycle_count, ex_inst_check, mem_inst_check, wb_inst_check;
	
	//FIFO
	wire FIFO_full;
	wire FIFO_empty;
	wire FIFO_ready;
	wire FIFO_data_out;
	wire FIFO_busy;
	wire [1:0] FIFO_state;
	wire [8:0] FIFO_count;
   reg [7:0] in_ctrl;
   reg [63:0] packet_data;
	wire fifo_write;
	wire fifo_read;
	wire fifo_mem_select;
	 

	// Instantiate the Unit Under Test (UUT)
	datapath uut (
		.clk(clk), 
		.rst(rst), 
		.memWE(memWE), 
		.memAddr(memAddr), 
		.memInData(memInData), 
		.memOutData(memOutData),
        .in_ctrl(in_ctrl),
        .packet_data_in(packet_data)
	);
	
	assign FIFO_full = uut.fifo_full;
	assign FIFO_empty = uut.fifo_empty;
	assign FIFO_ready = uut.fifo_rdy;
	assign FIFO_data_out = uut.fifo_out;
	assign FIFO_busy		= uut.fifo_busy;
	assign FIFO_count		= uut.fifo_count;
	assign FIFO_state    = uut.FIFO.state;
	assign fifo_write		= uut.FIFO.fifo_wr;
	assign fifo_mem_select = uut.mem_fifo_select;

	
	//fetch
	assign pc 			= uut.pc;
	assign if_inst 		= uut.if_inst;	
	assign PCSrc 		= uut.PCSrc;
	assign branchAddr 	= uut.branchAddr;
	assign jumpAddr 	= uut.jumpAddr;
	
	//decode
	
	
	assign id_inst 				= uut.id_inst;
	assign opcode 				= uut.opcode;
	assign funct7 				= uut.funct7;
	assign funct3 				= uut.funct3;
	assign id_alu_op 			= uut.id_alu_op;
	assign id_alu_src 			= uut.id_alu_src;
	assign id_branch 			= uut.id_branch;
	assign id_jump 				= uut.id_jump;
	assign id_mem_read 			= uut.id_mem_read;
	assign id_mem_write 		= uut.id_mem_write;
	assign id_reg_write 		= uut.id_reg_write;
	assign id_mem_to_reg 		= uut.id_mem_to_reg;
	assign id_WMemEn 			= uut.id_WMemEn;
	assign id_WRegEn 			= uut.id_WRegEn;
	assign id_rs1 				= uut.id_rs1;
	assign id_rs2 				= uut.id_rs2;
	assign id_rd 				= uut.id_rd;
   assign id_rsData1 			= uut.id_rsData1;
	assign id_rsData2 			= uut.id_rsData2;
	assign intermediate_12 		= uut.intermediate_12;
	assign intermediate_21 		= uut.intermediate_21;
	assign id_branch_offset 	= uut.id_branch_offset;
	assign jump_offset 			= uut.jump_offset;
	assign id_stall 			= uut.id_stall;
	
	//execute
	assign ex_rd 					= uut.ex_rd;
	assign ex_rsData1 				= uut.ex_rsData1;
	assign ex_rsData2 				= uut.ex_rsData2;
	assign alu_B 					= uut.alu_B;
	assign ex_alu_out 				= uut.ex_alu_out;
	assign ex_alu_op 				= uut.ex_alu_op;
	assign ex_alu_src 				= uut.ex_alu_src;
	assign ex_branch 				= uut.ex_branch;
	assign ex_mem_read 				= uut.ex_mem_read;
	assign ex_mem_write 			= uut.ex_mem_write;
	assign ex_reg_write 			= uut.ex_reg_write;
	assign ex_mem_to_reg 			= uut.ex_mem_to_reg;
	assign ex_overflow 				= uut.ex_overflow;
	assign branch_flag 				= uut.branch_flag;
	assign ex_equal 				= uut.ex_equal;
	assign ex_not_equal 			= uut.ex_not_equal;
	assign ex_less_than 			= uut.ex_less_than;
	assign ex_greater_than_equal 	= uut.ex_greater_than_equal;
	assign ex_intermediate_12 		= uut.ex_intermediate_12;
	assign signed_intermediate 		= uut.signed_intermediate;
	assign ex_branch_offset			= uut.ex_branch_offset;
	
	//memory
	assign mem_WMemEn 			= uut.mem_WMemEn;
	assign mem_rd 				= uut.mem_rd;
	assign mem_rsData2 			= uut.mem_rsData2;
	assign mem_mem_out 			= uut.mem_mem_out;
	assign mem_overflow 		= uut.mem_overflow;
	assign mem_branch 			= uut.mem_branch;
	assign mem_read 			= uut.mem_read;
	assign mem_write 			= uut.mem_write;
	assign mem_reg_write 		= uut.mem_reg_write;
	assign mem_mem_to_reg 		= uut.mem_mem_to_reg;
	assign mem_alu_out 			= uut.mem_alu_out;
	
	
	//write back
	assign wb_RegWrite 		= uut.wb_RegWrite;
	assign wb_mem_to_reg 	= uut.wb_mem_to_reg;
	assign wb_rd 			= uut.wb_rd;
	assign wb_mem_out 		= uut.wb_mem_out;
	assign wb_alu_out 		= uut.wb_alu_out;
	assign wb_rdData 		= uut.wb_rdData;
	
	
	//misc
	assign register[0]	 = uut.register.registerFile[0];
	assign register[1]	 = uut.register.registerFile[1];
	assign register[2]	 = uut.register.registerFile[2];
	assign register[3]	 = uut.register.registerFile[3];
	assign register[4]	 = uut.register.registerFile[4];
	assign register[5]	 = uut.register.registerFile[5];
	assign register[6]	 = uut.register.registerFile[6];
	assign register[7]	 = uut.register.registerFile[7];
	assign register[8]	 = uut.register.registerFile[8];
	assign register[9]	 = uut.register.registerFile[9];
	assign register[10]	 = uut.register.registerFile[10];
	assign register[11]	 = uut.register.registerFile[11];
	assign register[12]	 = uut.register.registerFile[12];
	assign register[13]	 = uut.register.registerFile[13];
	assign register[14]	 = uut.register.registerFile[14];
	assign register[15]	 = uut.register.registerFile[15];
	assign register[16]	 = uut.register.registerFile[16];
	assign register[17]	 = uut.register.registerFile[17];
	assign register[18]	 = uut.register.registerFile[18];
	assign register[19]	 = uut.register.registerFile[19];
	assign register[20]	 = uut.register.registerFile[20];
	assign register[21]	 = uut.register.registerFile[21];
	assign register[22]	 = uut.register.registerFile[22];
	assign register[23]	 = uut.register.registerFile[23];
	assign register[24]	 = uut.register.registerFile[24];
	assign register[25]	 = uut.register.registerFile[25];
	assign register[26]	 = uut.register.registerFile[26];
	assign register[27]	 = uut.register.registerFile[27];
	assign register[28]	 = uut.register.registerFile[28];
	assign register[29]	 = uut.register.registerFile[29];
	assign register[30]	 = uut.register.registerFile[30];
	assign register[31]	 = uut.register.registerFile[31];
	assign cycle_count	 = uut.cycle_count;
	assign ex_inst_check	 = uut.ex_inst_check;
	assign mem_inst_check	 = uut.mem_inst_check;
	assign wb_inst_check	 = uut.wb_inst_check;


	initial begin
		// Initialize Inputs
		clk         = 0;
		rst         = 0;
		memWE       = 0;
		memAddr     = 0;
		memInData   = 0;
      in_ctrl     = 0;
      packet_data = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		rst = 1;
		#125;
        in_ctrl     = 1;
        packet_data = 64'h1;
			rst = 0;

        #125
        in_ctrl     = 0;

        #1200

        in_ctrl     = 1;
		
		#5000
		memAddr = -12;
		#200
		memAddr = -16;
		#200
		memAddr = -20;
		#200
		memAddr = -24;
		#200
		memAddr = -28;
		#200
		memAddr = 0;
		
		
		#165000
		memAddr = -4;
		#200
		memAddr = -8;
		#200
		memAddr = -12;
		#200
		memAddr = -16;
		#200
		memAddr = -20;
		#200
		memAddr = 0;
		
		
		
//		force uut.register.registerFile[1] = 15;
//		force uut.register.registerFile[2] = 11;
		
//		#700;
//		force uut.branchAddr = 100;
//		force uut.PCSrc = 1;
//		#50;
//		force uut.branchAddr = 100;
//		force uut.PCSrc = 0;

	end
	
	always #50 clk = ~clk;
      
endmodule

