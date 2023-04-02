`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:49:03 02/15/2023 
// Design Name: 
// Module Name:    datapath 
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
module datapath(
	input clk, rst, memWE, iMemWE, logicEn, logicWe, core_enable,
	input [7:0]memAddr,
	input [8:0]iMemAddr,
	input [63:0]memInData,
	input [31:0]iMemInData,
	input [13:0]logicAddr,
	output core_ready,
	output [63:0]memOutData,
	output [217:0]logicData
	);
	
	//instruction Fetch wires
    wire [1:0]threadSelect_current;
	wire [8:0]pc_reg;

    
	//instruction decode wires
	wire [8:0]id_pc;
	wire [1:0]id_threadId;
    wire [31:0] id_inst;
    wire [6:0] opcode;
    wire [6:0] funct7;
    wire [2:0] funct3;
    wire [3:0]id_alu_op;
	wire id_alu_src, id_branch, id_jump, id_mem_read, id_mem_write, id_reg_write, id_mem_to_reg;
    wire id_fifo_select;
	wire [4:0]id_rs1, id_rs2, id_rd;
	wire [63:0]id_rsData1[0:3], id_rsData2[0:3];
	wire [63:0]id_rsData1_reg, id_rsData2_reg;	
    wire [11:0]intermediate_12; // I-Type, B-Type, S-Type instructions use 12 bit intermediate
	reg [11:0]intermediate_12_reg;
    wire [12:0] id_branch_offset;
	reg [12:0] id_branch_offset_reg;
	wire [8:0]jumpAddr_reg;
	wire [1:0]jumpThread;
	
	//Execution stage wires
	wire [8:0]ex_pc;
	wire [1:0]ex_threadId;
	wire [4:0]ex_rd;
	wire [63:0]ex_rsData1, ex_rsData2, alu_B, ex_alu_out;
	reg [63:0]alu_B_reg;
    wire [3:0]ex_alu_op;
	wire ex_alu_src;
	//wire ex_branch = 0, ex_mem_read = 0, ex_mem_write = 0, ex_reg_write = 0, ex_mem_to_reg = 0, ex_overflow = 0;
	wire ex_branch, ex_mem_read, ex_mem_write, ex_reg_write, ex_mem_to_reg, ex_overflow;
    wire ex_less_than, ex_greater_than_equal;
    wire [11:0] ex_intermediate_12;
    wire [63:0] signed_intermediate;
	wire [12:0] ex_branch_offset;
    wire ex_fifo_select;
	
	//Memory stage wires
	wire [8:0]mem_pc;
	wire [1:0]mem_threadId;
	wire [4:0]mem_rd;
	wire [63:0]mem_rsData2, mem_mem_out;
    //wire mem_overflow = 0, mem_branch = 0, mem_read = 0, mem_reg_write = 0, mem_mem_to_reg = 0
    wire mem_overflow, mem_branch, mem_read, mem_reg_write, mem_mem_to_reg, mem_write;
	wire mem_less_than, mem_greater_than_equal;
    wire [63:0] mem_alu_out;
	wire [12:0] mem_branch_offset;
	wire [3:0]mem_alu_op;
    wire mem_fifo_select;
	wire [8:0]branchAddr_reg;
	wire [1:0]branchThread;
	wire branch_flag;
	
	//WriteBack stage wires
	wire [1:0]wb_threadId;
	wire wb_RegWrite, wb_mem_to_reg;
	wire [4:0]wb_rd;
	wire [63:0]wb_mem_out, wb_alu_out;
	wire [63:0]wb_rdData;
	reg [63:0]wb_rdData_reg;
	
	wire reset;
	assign reset = rst || ~core_enable;// || ~fifo_rdy;
	
	//misc
//	reg [31:0]cycle_count_reg= 0, ex_inst_check_reg, mem_inst_check_reg, wb_inst_check_reg;
//	wire [31:0]cycle_count, ex_inst_check, mem_inst_check, wb_inst_check;
//	always@(posedge clk) 
//	begin
//		ex_inst_check_reg <= id_inst;
//		mem_inst_check_reg <= ex_inst_check_reg;
//		wb_inst_check_reg <= mem_inst_check_reg;
//	end
//	assign ex_inst_check = ex_inst_check_reg;
//	assign mem_inst_check = mem_inst_check_reg;
//	assign wb_inst_check = wb_inst_check_reg;

	
	//Instruction Fetch stage datapath	--------------------------------------------------------------------------------------------------------------------
	wire pc_reset;
	pcCounter pcc(.en(1'b1), 										.clk(clk), 						.rst(reset), 					.pcOut(pc_reg), 			
					.threadSelect_current(threadSelect_current), 	.jumpFlag(id_jump), 			.jumpThread(jumpThread), 		.jumpAddr(jumpAddr_reg),	
					.branchFlag(branch_flag), 						.branchThread(branchThread), 	.branchAddr(branchAddr_reg),	.pc_reset(pc_reset),
					.core_ready(core_ready),						.core_enable(core_enable)
					);
	
	inst_mem iMem(.ena(~reset), .sinita(pc_reset), .addra(pc_reg), .clka(clk), .douta(id_inst), .web(iMemWE), .addrb(iMemAddr), 
					.dinb(iMemInData), .clkb(clk));
    
    pipe_reg_if_id if_id_pipe_reg(.en(~reset), 							.clk(clk), 					.clr(1'b0), 	.if_pc(pc_reg), 	.id_pc(id_pc), 
									.if_threadId(threadSelect_current), .id_threadId(id_threadId)
									);

    //Instruction Decode stage datapath------------------------------------------------------------------------------------------------------------------------
	
	assign id_rs1 = id_inst[19:15]; // rs1 must tap into bits 19-15 of the instruction
    assign id_rs2 = id_inst[24:20]; // rs2 must tap into bits 24-20 of the instruction
    assign id_rd  = id_inst[11:7];   // rd  must tap into bits 11-7 of the instruction

    assign opcode	= id_inst[6:0];    // opcode is lower 7 bits of the instruction
    assign funct7 	= id_inst[31:25];  // when applicable
    assign funct3  	= id_inst[14:12];  // when applicable

	always@(*)
	begin
		intermediate_12_reg = 12'b0;
		if (opcode == 7'b0010011 || opcode == 7'b0000011) // i-type or load
		begin
			intermediate_12_reg = id_inst[31:20];
		end
		if (opcode == 7'b0100011) // s-type
		begin
			intermediate_12_reg = {id_inst[31:25], id_inst[11:7]};
		end
//        if (opcode == 7'b1100011) // branch
//        begin
//            id_branch_offset_reg = ({id_inst[31], id_inst[31], id_inst[31], id_inst[7], id_inst[30:25], id_inst[11:9]});
//        end
	end
	
	assign id_branch_offset = ({id_inst[31], id_inst[31], id_inst[31], id_inst[7], id_inst[30:25], id_inst[11:9]});
	
	assign jumpAddr_reg 	= 	id_pc + (({id_inst[31], id_inst[19:12], id_inst[20], id_inst[30:21]}) >>> 1);
	assign jumpThread		=	id_threadId;
	
    control_unit control(.opcode(opcode), 					.rd(id_rd), 				.funct7(funct7), 				.funct3(funct3), 			.alu_op(id_alu_op), 		
							.alu_src(id_alu_src), 			.branch(id_branch), 		.jump(id_jump),					.mem_read(id_mem_read), 	.mem_write(id_mem_write), 	
							.reg_write(id_reg_write), 		.mem_to_reg(id_mem_to_reg), .fifo_select(id_fifo_select)
							);
							
	registerFile rf0(.addra({id_threadId,id_rs1}),		.addrb({wb_threadId,wb_rd}), 	.clka(clk),		.clkb(clk),		.dinb(wb_rdData),		.douta(ex_rsData1),
						.sinita(reset),					.web(wb_RegWrite)
						);	
	
	registerFile rf1(.addra({id_threadId,id_rs2}),		.addrb({wb_threadId,wb_rd}), 	.clka(clk),		.clkb(clk),		.dinb(wb_rdData),		.douta(ex_rsData2),
						.sinita(reset),					.web(wb_RegWrite)
						);
		
//	RegFile register0(.clk(clk), 						.rst(reset), 			.raddr1({id_threadId,id_rs1}), 		.raddr2({id_threadId,id_rs2}), 	
//						.waddr({wb_threadId,wb_rd}), 	.wen(wb_RegWrite), 		.wdata(wb_rdData), 					.rdata1(id_rsData1_reg), 
//						.rdata2(id_rsData2_reg)
//						);
						
//	RegFile register1(.clk(clk), 			.rst(reset), 			.raddr1(id_rs1), 		.raddr2(id_rs2), 	.waddr(wb_rd), 	.wen(wb_RegWrite && (wb_threadId == 2'b01)), 
//						.wdata(wb_rdData), 	.rdata1(id_rsData1[1]), .rdata2(id_rsData2[1])
//						);
//						
//	RegFile register2(.clk(clk), 			.rst(reset), 			.raddr1(id_rs1), 		.raddr2(id_rs2), 	.waddr(wb_rd), 	.wen(wb_RegWrite && (wb_threadId == 2'b10)), 
//						.wdata(wb_rdData), 	.rdata1(id_rsData1[2]), .rdata2(id_rsData2[2])
//						);
//						
//	RegFile register3(.clk(clk), 			.rst(reset), 			.raddr1(id_rs1), 		.raddr2(id_rs2), 	.waddr(wb_rd), 	.wen(wb_RegWrite && (wb_threadId == 2'b11)), 
//						.wdata(wb_rdData), 	.rdata1(id_rsData1[3]), .rdata2(id_rsData2[3])
//						);
	
//	assign id_rsData1_reg	= 	id_rsData1[id_threadId];
//	assign id_rsData2_reg 	=	id_rsData2[id_threadId];

	
	pipe_reg_id_ex id_ex_pipe_reg(.en(~reset),									.clk(clk),								.clr(1'b0),								
									.id_fifo_select(id_fifo_select),			.rsData1In(id_rsData1_reg),				.rsData2In(id_rsData2_reg), 	
									.rdAddrIn(id_rd), 							.alu_op_in(id_alu_op),					.alu_src_in(id_alu_src), 					
									.branch_in(id_branch), 						.mem_read_in(id_mem_read), 				.mem_write_in(id_mem_write), 
									.reg_write_in(id_reg_write),				.mem_to_reg_in(id_mem_to_reg), 			.intermediate_in(intermediate_12_reg), 
									.branch_offset_in(id_branch_offset), 		.id_pc(id_pc),							.id_threadId(id_threadId),
									.alu_op_out(ex_alu_op), 					.alu_src_out(ex_alu_src), 				.branch_out(ex_branch), 					
									.mem_read_out(ex_mem_read), 				.mem_write_out(ex_mem_write), 			.reg_write_out(ex_reg_write), 				
									.mem_to_reg_out(ex_mem_to_reg),				.rsData1Out(), 							.rsData2Out(), 					
									.rdAddrOut(ex_rd), 							.intermediate_out(ex_intermediate_12), 	.branch_offset_out(ex_branch_offset), 		
									.ex_fifo_select(ex_fifo_select),			.ex_pc(ex_pc),							.ex_threadId(ex_threadId)
                                    );
	
	//Execution stage stage datapath--------------------------------------------------------------------------------------------------------------------------

   // if ALU SRC is 1 select the intermediate, else pass source register 2's value
   
	assign signed_intermediate = {  {52 {ex_intermediate_12[11]}}, ex_intermediate_12 }; // Sign extend 12-bit intermediate to 64 bit signed

	always@(*)
	begin
		if (ex_alu_src == 1'b1) 
		begin
			alu_B_reg = signed_intermediate;
		end
		else
		begin
			alu_B_reg = ex_rsData2;
		end
	end
	
	assign alu_B = alu_B_reg;       

	ALU_64 alu(.A(ex_rsData1), .B(alu_B), .aluctrl(ex_alu_op), .Z(ex_alu_out), .overflow(ex_overflow), .less_than(ex_less_than), .greater_than_equal(ex_greater_than_equal));
	
	pipe_reg_ex_mem ex_mem_pipe_reg(.en(~(reset)), 										.clr(1'b0), 							.clk(clk), 						
									.rdAddrIn(ex_rd), 									.rsData2In(ex_rsData2), 				.ex_alu_output(ex_alu_out), 			
									.ex_overflow(ex_overflow),							.ex_mem_read(ex_mem_read), 				.ex_mem_write(ex_mem_write), 		
									.ex_reg_write(ex_reg_write), 						.ex_mem_to_reg(ex_mem_to_reg), 			.ex_branch(ex_branch),
									.ex_fifo_select(ex_fifo_select),					.ex_less_than(ex_less_than), 			.ex_greater_than_equal(ex_greater_than_equal), 
									.ex_alu_op(ex_alu_op), 								.branch_offset_in(ex_branch_offset), 	.ex_threadId(ex_threadId),
									.ex_pc(ex_pc),										.rdAddrOut(mem_rd), 					.mem_overflow(mem_overflow), 						
									.mem_read(mem_read), 								.mem_write(mem_write), 					.mem_reg_write(mem_reg_write), 						
									.mem_to_reg(mem_mem_to_reg), 						.mem_alu_output(mem_alu_out), 			.rsData2Out(mem_rsData2), 							
									.mem_branch(mem_branch), 							.mem_less_than(mem_less_than), 			.mem_greater_than_equal(mem_greater_than_equal), 	
									.mem_alu_op(mem_alu_op), 							.branch_offset_out(mem_branch_offset),	.mem_fifo_select(mem_fifo_select),
									.mem_threadId(mem_threadId),						.mem_pc(mem_pc)
									);
		
	//Memory stage datapath------------------------------------------------------------------------------------------------------------------------------------------------
	
	assign branchAddr_reg 	= mem_pc + mem_branch_offset;
	assign branchThread		= mem_threadId;
	assign branch_flag 		= (mem_branch && ((mem_less_than && (mem_alu_op == 4'b1000)) || (mem_greater_than_equal && (mem_alu_op == 4'b1001))));
	
//	always@(*)
//	begin
//		branch_flag 	=	0;
//		if (mem_branch && ((mem_less_than && (mem_alu_op == 4'b1000)) || (mem_greater_than_equal && (mem_alu_op == 4'b1001))))
//		begin
//			branch_flag 	=	1;
//		end
//	end
				
	data_mem dMem(.addra(memAddr), 		.addrb({mem_threadId, mem_alu_out[7:2]}), 	.clka(clk), 	.clkb(clk), 	.dina(memInData), 	.dinb(mem_rsData2), 
					.douta(memOutData), .doutb(wb_mem_out), 						.wea(memWE), 	.web(mem_write)
					);
	
	
	pipe_reg_mem_wb mem_wb_pipe_reg(.en(~reset), 						.mem_fifo_select(mem_fifo_select), 	.clk(clk), 						.mem_reg_write_in(mem_reg_write), 	
									.mem_to_reg_in(mem_mem_to_reg), 	.rdAddrIn(mem_rd), 					.mem_mem_out(mem_mem_out), 		.wb_fifo_select(wb_fifo_select),	
									.mem_alu_out(mem_alu_out), 			.mem_threadId(mem_threadId),		.wb_reg_write(wb_RegWrite), 	.wb_mem_to_reg(wb_mem_to_reg), 	
									.rdAddrOut(wb_rd), 					.wb_alu_out(wb_alu_out),			.wb_threadId(wb_threadId)
									);

	
    
	
	//Write back Stage Datapath
	
	assign wb_rdData = wb_mem_to_reg == 1'b1 ? wb_mem_out : wb_alu_out;
//	always@(*)
//	begin
//		if (wb_mem_to_reg == 1'b1) 
//		begin
//			wb_rdData_reg = wb_mem_out;
//		end
//		else
//		begin
//			wb_rdData_reg = wb_alu_out;
//		end
//	end	
//	assign wb_rdData = wb_rdData_reg;

	
	
	//logic Analyser
	// LogicAnalyser la(.en(logicEn), .clk(clk), .we(logicWe), 
	// 					.data({pc, id_inst, id_stall, id_jump, branch_flag, id_rd,						//40
	// 						id_alu_op, id_alu_src, id_branch, id_mem_read, id_mem_write, 					//8
	// 						id_reg_write, id_mem_to_reg, ex_alu_op, ex_alu_src,	ex_branch,					//8
	// 						ex_mem_read, ex_mem_write, ex_reg_write, ex_mem_to_reg, ex_rd, 					//9
	// 						ex_alu_out, mem_rd, mem_read, mem_write, mem_reg_write, 						//72					
	// 						mem_mem_to_reg, wb_regwrite, wb_mem_to_reg, wb_rd, wb_mem_out, 38'd0					//72
	// 					}), 
	// 					.logicAddr(logicAddr), .logicOut(logicData));
	
	

	


endmodule
