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
	input clk, rst, memWE,
	input [7:0]memAddr,
	input [63:0]memInData,
	output [63:0]memOutData
	);
	
	//instruction Fetch wires
	wire [8:0]pc;
	wire [31:0]if_inst;
    wire PCSrc;
    wire [8:0]branchAddr;
    
	//instruction decode wires
    wire [31:0] id_inst;
    wire [6:0] opcode;
    wire [6:0] funct7;
    wire [2:0] funct3;
    wire [3:0]id_alu_op;
	wire id_alu_src, id_branch, id_jump, id_mem_read, id_mem_write, id_reg_write, id_mem_to_reg;
	wire id_WMemEn, id_WRegEn;
	wire [4:0]id_rs1, id_rs2, id_rd;
	wire [63:0]id_rsData1, id_rsData2;
    wire [11:0]intermediate_12; // I-Type, B-Type, S-Type instructions use 12 bit intermediate
	reg [11:0]intermediate_12_reg;
    wire [20:0]intermediate_21; // JAL
	reg [20:0]intermediate_21_reg;
	
	//Execution stage wires
	wire [4:0]ex_rd;
	wire [63:0]ex_rsData1, ex_rsData2, alu_B, alu_out;
    wire ex_alu_op, ex_alu_src, ex_branch, ex_mem_read, ex_mem_write, ex_reg_write, ex_mem_to_reg, ex_overflow;
    wire branch_flag; // Replaces the "ZERO" output in the tradidtional 5-stage pipeline
    wire ex_equal, ex_not_equal, ex_less_than, ex_greater_than_equal;
    wire [11:0] ex_intermediate_12;
    wire [63:0] signed_intermediate;
	wire [8:0]ex_btaAddr;

    assign signed_intermediate = {  {52 {ex_intermediate_12[11]}}, ex_intermediate_12 }; // Sign extend 12-bit intermediate to 64 bit signed
	
	//Memory stage wires
	wire mem_WMemEn, mem_WRegEn;
	wire [4:0]mem_rd;
	wire [63:0]mem_rsData1, mem_rsData2, mem_rdData;
    wire mem_overflow, mem_branch, mem_read, mem_write, mem_reg_write, mem_to_reg;
    wire [63:0] mem_ALU_out;

    assign PCSrc = mem_branch; //If branch existed in EX stage and the condition was evaluated to TRUE, change the PC to point to branch address produced by ALU
	
	//WriteBack stage wires
	wire wb_WRegWrite;
	wire [4:0]wb_rd;
	wire [63:0]wb_rdData;
	
	
	//Instruction Fetch stage datapath
	pcCounter pcc(.clk(clk), .rst(rst), .pc(pc), .PCSrc(PCSrc), .branchAddr(branchAddr));
	inst_mem iMem(.addr(pc), .clk(clk), .dout(if_inst));
    
    pipe_reg_if_id if_id_pipe_reg(.clk(clk), .instruction_in(if_inst), .instruction_out(id_inst));

    //Instruction Decode stage datapath
	assign id_rs1 = id_inst[19:15]; // rs1 must tap into bits 19-15 of the instruction
    assign id_rs2 = id_inst[24:20]; // rs2 must tap into bits 24-20 of the instruction
    assign id_rd  = id_inst[11:7];   // rd  must tap into bits 11-7 of the instruction

    assign opcode = id_inst[6:0];    // opcode is lower 7 bits of the instruction
    assign funct7 = id_inst[31:25];  // when applicable
    assign funct3  = id_inst[14:12];  // when applicable

	always@(*)
	begin
		if (opcode == 7'b0010011 || opcode == 7'b0000011) // i-type or load
		begin
			intermediate_12_reg = id_inst[31:20];
		end
		else if (opcode == 7'b0100011) // s-type
		begin
			intermediate_12_reg = {id_inst[31:25], id_inst[11:7]};
		end	
		else
		begin
			intermediate_12_reg = 12'b0;
		end
	end
	assign intermediate_12 = intermediate_12_reg;
    
    control_unit control(.opcode(opcode), .funct7(funct7), .funct3(funct3), .alu_op(id_alu_op), .alu_src(id_alu_src), .branch(id_branch), 
        .jump(id_jump), .mem_read(id_mem_read), .mem_write(id_mem_write), .reg_write(id_reg_write), .mem_to_reg(id_mem_to_reg));
		
	RegFile register(.clk(clk), .rst(rst), .raddr1(id_rs1), .raddr2(id_rs2), .waddr(wb_rd), .wen(wb_wregwrite), .wdata(wb_rddata), 
                    .rdata1(id_rsData1), .rdata2(id_rsData2));
	
	pipe_reg_id_ex id_ex_pipe_reg(.clk(clk), .rsData1In(id_rsdata1), .rsData2In(id_rsdata2), .rdAddrIn(id_rd), .alu_op_in(id_alu_op),
                                    .alu_src_in(id_alu_src), .branch_in(id_branch), .mem_read_in(id_mem_read), 
                                    .mem_write_in(id_mem_write), .reg_write_in(id_reg_write), .mem_to_reg_in(id_mem_to_reg), .intermediate_in(intermediate_12),
                                    .alu_op_out(ex_alu_op), .alu_src_out(ex_alu_src), .branch_out(ex_branch),
                                    .mem_read_out(ex_mem_read), .mem_write_out(ex_mem_write), .reg_write_out(ex_reg_write), .mem_to_reg_out(ex_mem_read),
                                    .rsData1Out(ex_rsdata1), .rsData2Out(ex_rsdata2), .rdAddrOut(ex_rd), .intermediate_out(ex_intermediate)
                                    );
	
	//Execution stage stage datapath

   // if ALU SRC is 1 select the intermerdiate, else pass source register 2's value

	always@(*)
	begin
		if (ex_alu_src) 
		begin
			alu_B = signed_intermediate;
		end
		else
		begin
			alu_B = ex_rsData2;
		end
	end
       

   ALU_64 alu(.A(ex_rsData1), .B(alu_B), .aluctrl(ex_alu_op), .Z(alu_out), .overflow(ex_overflow), .equal(ex_equal), .not_equal(ex_not_equal), 
   .less_than(ex_less_than), .greater_than_equal(ex_greater_than_equal) );
   always@(*)
	begin
		if (ex_branch)
		begin
			if (ex_equal && (ex_alu_op == 4'b0110))
			begin
				branch_flag = 1;
			end        
			else if (ex_not_equal && (ex_alu_op == 4'b0111 ))
			begin
				branch_flag = 1;
			end   
			else if (ex_less_than && (ex_alu_op == 4'b1000))
			begin
				branch_flag = 1;
			end        
			else if (ex_greater_than_equal && (ex_alu_op == 4'b1001))
			begin
				branch_flag = 1;
			end        
			else
			begin
				branch_flag = 0;
			end
		end
	end

	
	pipe_reg_ex_mem ex_mem_pipe_reg(.clk(clk), .rdAddrIn(ex_rd) .ex_alu_output(alu_out), .ex_overflow(ex_overflow), .ex_branch(branch_flag), .ex_mem_read(ex_mem_read), .ex_mem_write(ex_mem_write), 
                                    .ex_reg_write(ex_reg_write), .ex_mem_to_reg(ex_mem_to_reg), .rdAddrOut(mem_rd), .mem_overflow(mem_overflow), .mem_branch(mem_branch), .mem_read(mem_read), .mem_write(mem_write), 
                                    .mem_reg_write(mem_reg_write), .mem_to_reg(mem_to_reg), .mem_alu_output(mem_alu_out));
		
	//Memory stage datapath
	data_mem dMem(.addra(mem_rsData1), .addrb(memAddr), .clka(clk), .clkb(clk), .dina(mem_rsData2), .dinb(memInData), 
				.douta(mem_rdData), .doutb(memOutData), .wea(mem_WMemEn), .web(memWE));
	
	pipe_reg_mem_wb mem_wb_pipe_reg(.clk(clk), .mem_reg_write_in(mem_reg_write), .mem_to_reg_in(mem_to_reg), .rdAddrIn(mem_rd), rdAddrOut(wb_rd) );
	


endmodule
