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
	wire [8:0]if_pc0, if_pc1, if_pc2, if_pc3;
    wire [1:0]threadSelect_current;
	wire [8:0]pc_reg;   
	
	//instruction decode wires
	wire [8:0]id_pc;
	wire [1:0]id_threadId;
    wire [31:0]id_inst;
    wire [6:0]opcode;
    wire [6:0]funct7;
    wire [2:0]funct3;
    wire [3:0]id_alu_op;
	wire id_alu_src, id_branch, id_jump, id_mem_read, id_mem_write, id_reg_write, id_mem_to_reg;
	wire [4:0]id_rs1, id_rs2, id_rd;
	wire [63:0]id_rsData1_t0, id_rsData2_t0,id_rsData1_t1, id_rsData2_t1,id_rsData1_t2, id_rsData2_t2,id_rsData1_t3, id_rsData2_t3, id_rsData1_reg, id_rsData2_reg;
    wire [11:0]intermediate_12_reg; // I-Type, B-Type, S-Type instructions use 12 bit intermediate
	wire [12:0] id_branch_offset_reg;
	wire [8:0]jumpAddr_reg;
	wire [1:0]jumpThread;
	
	//Execution stage wires
	wire [8:0]ex_pc;
	wire [1:0]ex_threadId;
	wire [4:0]ex_rd;
	wire [63:0]ex_rsData1, ex_rsData2, alu_B, ex_alu_out;
    wire [3:0]ex_alu_op;
	wire ex_alu_src, ex_branch, ex_mem_read, ex_mem_write, ex_reg_write, ex_mem_to_reg, ex_overflow;
    wire ex_less_than, ex_greater_than_equal;
    wire [11:0] ex_intermediate_12;
    wire [63:0] signed_intermediate;
	wire [12:0] ex_branch_offset;
	
	//Memory stage wires
	wire [8:0]mem_pc;
	wire [1:0]mem_threadId;
	wire [4:0]mem_rd;
	wire [63:0]mem_rsData2, mem_mem_out;
    wire mem_overflow, mem_branch, mem_read, mem_write, mem_reg_write, mem_mem_to_reg;
    wire [63:0] mem_alu_out;	
	wire [12:0] mem_branch_offset;
	wire [3:0]mem_alu_op;
	wire [8:0]branchAddr_reg;
	wire [1:0]branchThread;
	wire branch_flag;
	
	//WriteBack stage wires
	wire [1:0]wb_threadId;
	wire wb_RegWrite, wb_mem_to_reg;
	wire [4:0]wb_rd;
	wire [63:0]wb_mem_out, wb_alu_out;
	wire [63:0]wb_rdData;
	
	//misc
	wire [63:0]register0[0:31];	
	wire [63:0]register1[0:31];
	wire [63:0]register2[0:31];
	wire [63:0]register3[0:31];

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

	
	//fetch-----------------------------------------------------------------------
	assign if_pc0 				= 	uut.pcc.pc[0];
	assign if_pc1 				= 	uut.pcc.pc[1];
	assign if_pc2 				= 	uut.pcc.pc[2];
	assign if_pc3 				= 	uut.pcc.pc[3];	
	assign threadSelect_current	=	uut.threadSelect_current;
	assign pc_reg				=	uut.pc_reg;
	
	//decode------------------------------------------------------------------------
	
	assign id_pc 				= uut.id_pc;
	assign id_threadId			= uut.id_threadId;
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
	assign id_rs1 				= uut.id_rs1;
	assign id_rs2 				= uut.id_rs2;
	assign id_rd 				= uut.id_rd;
	
	assign id_rsData1_t0 		= uut.id_rsData1[0];
	assign id_rsData2_t0 		= uut.id_rsData2[0];
	assign id_rsData1_t1 		= uut.id_rsData1[1];
	assign id_rsData2_t1 		= uut.id_rsData2[1];
	assign id_rsData1_t2 		= uut.id_rsData1[2];
	assign id_rsData2_t2 		= uut.id_rsData2[2];
	assign id_rsData1_t3 		= uut.id_rsData1[3];
	assign id_rsData2_t3 		= uut.id_rsData2[3];
	assign id_rsData1_reg 		= uut.id_rsData1_reg;
	assign id_rsData2_reg 		= uut.id_rsData1_reg;
	
	assign intermediate_12_reg 	= uut.intermediate_12_reg;
	assign id_branch_offset_reg = uut.id_branch_offset_reg;
	assign jumpAddr_reg			= uut.jumpAddr_reg;
	assign jumpThread 			= uut.jumpThread;
	
	//execute
	assign ex_pc 					= uut.ex_pc;
	assign ex_threadId				= uut.ex_threadId;
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
	assign ex_less_than 			= uut.ex_less_than;
	assign ex_greater_than_equal 	= uut.ex_greater_than_equal;
	assign ex_intermediate_12 		= uut.ex_intermediate_12;
	assign signed_intermediate 		= uut.signed_intermediate;
	assign ex_branch_offset			= uut.ex_branch_offset;
	
	//memory
	assign mem_pc 				= uut.mem_pc;
	assign mem_threadId			= uut.mem_threadId;
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
	assign mem_branch_offset 	= uut.mem_branch_offset;
	assign mem_alu_op 			= uut.mem_alu_op;
	assign branchAddr_reg 		= uut.branchAddr_reg;
	assign branchThread 		= uut.branchThread;
	assign branch_flag 			= uut.branch_flag;	
	
	//write back
	assign wb_threadId		= uut.wb_threadId;
	assign wb_RegWrite 		= uut.wb_RegWrite;
	assign wb_mem_to_reg 	= uut.wb_mem_to_reg;
	assign wb_rd 			= uut.wb_rd;
	assign wb_mem_out 		= uut.wb_mem_out;
	assign wb_alu_out 		= uut.wb_alu_out;
	assign wb_rdData 		= uut.wb_rdData;
	
	
	//misc
	assign register0[0]	 	= 	uut.register0.registerFile[0];
	assign register0[1]	 	= 	uut.register0.registerFile[1];
	assign register0[2]	 	= 	uut.register0.registerFile[2];
	assign register0[3]	 	= 	uut.register0.registerFile[3];
	assign register0[4]	 	= 	uut.register0.registerFile[4];
	assign register0[5]	 	= 	uut.register0.registerFile[5];
	assign register0[6]	 	= 	uut.register0.registerFile[6];
	assign register0[7]	 	= 	uut.register0.registerFile[7];
	assign register0[8]	 	= 	uut.register0.registerFile[8];
	assign register0[9]	 	= 	uut.register0.registerFile[9];
	assign register0[10]	= 	uut.register0.registerFile[10];
	assign register0[11]	= 	uut.register0.registerFile[11];
	assign register0[12]	= 	uut.register0.registerFile[12];
	assign register0[13]	= 	uut.register0.registerFile[13];
	assign register0[14]	= 	uut.register0.registerFile[14];
	assign register0[15]	= 	uut.register0.registerFile[15];
	assign register0[16]	= 	uut.register0.registerFile[16];
	assign register0[17]	= 	uut.register0.registerFile[17];
	assign register0[18]	= 	uut.register0.registerFile[18];
	assign register0[19]	= 	uut.register0.registerFile[19];
	assign register0[20]	= 	uut.register0.registerFile[20];
	assign register0[21]	= 	uut.register0.registerFile[21];
	assign register0[22]	= 	uut.register0.registerFile[22];
	assign register0[23]	= 	uut.register0.registerFile[23];
	assign register0[24]	= 	uut.register0.registerFile[24];
	assign register0[25]	= 	uut.register0.registerFile[25];
	assign register0[26]	= 	uut.register0.registerFile[26];
	assign register0[27]	= 	uut.register0.registerFile[27];
	assign register0[28]	= 	uut.register0.registerFile[28];
	assign register0[29]	= 	uut.register0.registerFile[29];
	assign register0[30]	= 	uut.register0.registerFile[30];
	assign register0[31]	= 	uut.register0.registerFile[31];
	
	assign register1[0]	 	= 	uut.register1.registerFile[0];
	assign register1[1]	 	= 	uut.register1.registerFile[1];
	assign register1[2]	 	= 	uut.register1.registerFile[2];
	assign register1[3]	 	= 	uut.register1.registerFile[3];
	assign register1[4]	 	= 	uut.register1.registerFile[4];
	assign register1[5]	 	= 	uut.register1.registerFile[5];
	assign register1[6]	 	= 	uut.register1.registerFile[6];
	assign register1[7]	 	= 	uut.register1.registerFile[7];
	assign register1[8]	 	= 	uut.register1.registerFile[8];
	assign register1[9]	 	= 	uut.register1.registerFile[9];
	assign register1[10]	= 	uut.register1.registerFile[10];
	assign register1[11]	= 	uut.register1.registerFile[11];
	assign register1[12]	= 	uut.register1.registerFile[12];
	assign register1[13]	= 	uut.register1.registerFile[13];
	assign register1[14]	= 	uut.register1.registerFile[14];
	assign register1[15]	= 	uut.register1.registerFile[15];
	assign register1[16]	= 	uut.register1.registerFile[16];
	assign register1[17]	= 	uut.register1.registerFile[17];
	assign register1[18]	= 	uut.register1.registerFile[18];
	assign register1[19]	= 	uut.register1.registerFile[19];
	assign register1[20]	= 	uut.register1.registerFile[20];
	assign register1[21]	= 	uut.register1.registerFile[21];
	assign register1[22]	= 	uut.register1.registerFile[22];
	assign register1[23]	= 	uut.register1.registerFile[23];
	assign register1[24]	= 	uut.register1.registerFile[24];
	assign register1[25]	= 	uut.register1.registerFile[25];
	assign register1[26]	= 	uut.register1.registerFile[26];
	assign register1[27]	= 	uut.register1.registerFile[27];
	assign register1[28]	= 	uut.register1.registerFile[28];
	assign register1[29]	= 	uut.register1.registerFile[29];
	assign register1[30]	= 	uut.register1.registerFile[30];
	assign register1[31]	= 	uut.register1.registerFile[31];
	
	assign register2[0]	 	= 	uut.register2.registerFile[0];
	assign register2[1]	 	= 	uut.register2.registerFile[1];
	assign register2[2]	 	= 	uut.register2.registerFile[2];
	assign register2[3]	 	= 	uut.register2.registerFile[3];
	assign register2[4]	 	= 	uut.register2.registerFile[4];
	assign register2[5]	 	= 	uut.register2.registerFile[5];
	assign register2[6]	 	= 	uut.register2.registerFile[6];
	assign register2[7]	 	= 	uut.register2.registerFile[7];
	assign register2[8]	 	= 	uut.register2.registerFile[8];
	assign register2[9]	 	= 	uut.register2.registerFile[9];
	assign register2[10]	= 	uut.register2.registerFile[10];
	assign register2[11]	= 	uut.register2.registerFile[11];
	assign register2[12]	= 	uut.register2.registerFile[12];
	assign register2[13]	= 	uut.register2.registerFile[13];
	assign register2[14]	= 	uut.register2.registerFile[14];
	assign register2[15]	= 	uut.register2.registerFile[15];
	assign register2[16]	= 	uut.register2.registerFile[16];
	assign register2[17]	= 	uut.register2.registerFile[17];
	assign register2[18]	= 	uut.register2.registerFile[18];
	assign register2[19]	= 	uut.register2.registerFile[19];
	assign register2[20]	= 	uut.register2.registerFile[20];
	assign register2[21]	= 	uut.register2.registerFile[21];
	assign register2[22]	= 	uut.register2.registerFile[22];
	assign register2[23]	= 	uut.register2.registerFile[23];
	assign register2[24]	= 	uut.register2.registerFile[24];
	assign register2[25]	= 	uut.register2.registerFile[25];
	assign register2[26]	= 	uut.register2.registerFile[26];
	assign register2[27]	= 	uut.register2.registerFile[27];
	assign register2[28]	= 	uut.register2.registerFile[28];
	assign register2[29]	= 	uut.register2.registerFile[29];
	assign register2[30]	= 	uut.register2.registerFile[30];
	assign register2[31]	= 	uut.register2.registerFile[31];
	
	assign register3[0]	 	= 	uut.register3.registerFile[0];
	assign register3[1]	 	= 	uut.register3.registerFile[1];
	assign register3[2]	 	= 	uut.register3.registerFile[2];
	assign register3[3]	 	= 	uut.register3.registerFile[3];
	assign register3[4]	 	= 	uut.register3.registerFile[4];
	assign register3[5]	 	= 	uut.register3.registerFile[5];
	assign register3[6]	 	= 	uut.register3.registerFile[6];
	assign register3[7]	 	= 	uut.register3.registerFile[7];
	assign register3[8]	 	= 	uut.register3.registerFile[8];
	assign register3[9]	 	= 	uut.register3.registerFile[9];
	assign register3[10]	= 	uut.register3.registerFile[10];
	assign register3[11]	= 	uut.register3.registerFile[11];
	assign register3[12]	= 	uut.register3.registerFile[12];
	assign register3[13]	= 	uut.register3.registerFile[13];
	assign register3[14]	= 	uut.register3.registerFile[14];
	assign register3[15]	= 	uut.register3.registerFile[15];
	assign register3[16]	= 	uut.register3.registerFile[16];
	assign register3[17]	= 	uut.register3.registerFile[17];
	assign register3[18]	= 	uut.register3.registerFile[18];
	assign register3[19]	= 	uut.register3.registerFile[19];
	assign register3[20]	= 	uut.register3.registerFile[20];
	assign register3[21]	= 	uut.register3.registerFile[21];
	assign register3[22]	= 	uut.register3.registerFile[22];
	assign register3[23]	= 	uut.register3.registerFile[23];
	assign register3[24]	= 	uut.register3.registerFile[24];
	assign register3[25]	= 	uut.register3.registerFile[25];
	assign register3[26]	= 	uut.register3.registerFile[26];
	assign register3[27]	= 	uut.register3.registerFile[27];
	assign register3[28]	= 	uut.register3.registerFile[28];
	assign register3[29]	= 	uut.register3.registerFile[29];
	assign register3[30]	= 	uut.register3.registerFile[30];
	assign register3[31]	= 	uut.register3.registerFile[31];
//	assign cycle_count	 = uut.cycle_count;
//	assign ex_inst_check	 = uut.ex_inst_check;
//	assign mem_inst_check	 = uut.mem_inst_check;
//	assign wb_inst_check	 = uut.wb_inst_check;


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
		
//		#5000
//		memAddr = -12;
//		#200
//		memAddr = -16;
//		#200
//		memAddr = -20;
//		#200
//		memAddr = -24;
//		#200
//		memAddr = -28;
//		#200
//		memAddr = 0;
		
		
//		#320000
//		memAddr = -4;
//		#200
//		memAddr = -8;
//		#200
//		memAddr = -12;
//		#200
//		memAddr = -16;
//		#200
//		memAddr = -20;
//		#200
//		memAddr = 0;
		
		
		
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
	
	always #100
	begin
		if(in_ctrl == 1'b0)
		begin
			packet_data = packet_data+1;
		end
		
	end
	
	integer i =0;
	always #5000
	begin
		memAddr = 0;
		for(i = 0; i<256; i= i+1)
		begin
			memAddr = memAddr +1;
			#200;			
		end
	end
      
endmodule

