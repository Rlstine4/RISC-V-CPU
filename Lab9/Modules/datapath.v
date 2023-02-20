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
    wire branchAddr;
    
	//instruction decode wires
    wire [31:0] id_inst;
    wire [6:0] opcode;
    wire [6:0] funct7;
    wire [2:0] funct3;
    wire id_alu_op, id_alu_src, id_branch, id_jump, id_mem_read, id_mem_write, id_reg_write, id_mem_to_reg;
	wire id_WMemEn, id_WRegEn;
	wire [4:0]id_rs1, id_rs2, id_rd;
	wire [63:0]id_rsData1, id_rsData2;

    assign id_rs1 = [19:15] id_inst; // rs1 must tap into bits 19-15 of the instruction
    assign id_rs2 = [24:20] id_inst; // rs2 must tap into bits 24-20 of the instruction
    assign id_rd  = [11:7]  id_rd;   // rd  must tap into bits 11-7 of the instruction

    assign opcode = id_inst[6:0];    // Opcode is lower 7 bits of the instruction
    assign funct7 = id_inst[31:25];  // When applicable
    assign func3  = id_inst[14:12];  // When applicable
	
	//Execution stage wires
	wire [4:0]ex_rd;
	wire [63:0]ex_rsData1, ex_rsData2, alu_out;
    wire ex_alu_op ex_alu_src, ex_branch, ex_jump, ex_mem_read, ex_mem_write, ex_reg_write, ex_mem_to_reg, ex_overflow;
    wire branch_flag; // Replaces the "ZERO" output in the tradidtional 5-stage pipeline
    wire ex_equal, ex_not_equal, ex_less_than, ex_greater_than_equal;
	
	//Memory stage wires
	wire mem_WMemEn, mem_WRegEn;
	wire [4:0]mem_rd;
	wire [63:0]mem_rsData1, mem_rsData2, mem_rdData;
	
	//WriteBack stage wires
	wire wb_WRegWrite;
	wire [4:0]wb_rd;
	wire [63:0]wb_rdData;
	
	
	//Instruction Fetch stage datapath
	pcCounter pcc(.clk(clk), .rst(rst), .pc(pc), .PCSrc(PCSrc), .branchAddr(branchAddr));
	inst_mem iMem(.addr(pc), .clk(clk), .dout(if_inst));
    
    pipe_reg_if_id if_id_pipe_reg(.clk(clk), .instruction_in(if_inst), .instruction_out(id_inst));

    //Instruction Decode stage datapath
    
    control_unit control(.opcode(opcode), .funct7(funct7), .func3(func3), .alu_op(id_alu_op), .alu_src(id_alu_src), .branch(id_branch), 
        .jump(id_jump), .mem_read(id_mem_read), .mem_write(id_mem_write), .reg_write(id_reg_write), .mem_to_reg(id_mem_to_reg));
		
	RegFile register(.clk(clk), .rst(rst), .raddr1(id_rs1), .raddr2(id_rs2), .waddr(wb_rd), .wen(wb_WRegWrite), .wdata(wb_rdData), 
                    .rdata1(id_rsData1), .rdata2(id_rsData2));
	
	pipe_reg_id_ex id_ex_pipe_reg(.clk(clk), .rsData1In(id_rsData1), .rsData2In(id_rsData2), .rdAddrIn(id_rd), .alu_op_in(id_alu_op),
                                    .alu_src_in(id_alu_src), .branch_in(id_branch), .jump_in(id_jump), .mem_read_in(id_mem_read), 
                                    .mem_write_in(id_mem_write), .reg_write_in(id_reg_write), .mem_to_reg_in(id_mem_to_reg), 
                                    .alu_op_out(ex_alu_op), .alu_src_out(ex_alu_src), .branch_out(ex_branch), .jump_out(ex_jump),
                                    .mem_read_out(ex_mem_read), .mem_write_out(ex_mem_write), .reg_write_out(ex_reg_write), .mem_to_reg_out(ex_mem_read),
                                    .rsData1Out(ex_rsData1), .rsData2Out(ex_rsData2), .rdAddrOut(ex_rd)
                                    );
	
	//Execution stage stage datapath

    if (~ex_alu_src)
        //Put something here 


    ALU_64(.A(ex_rsData1), .B(ex_rsData2), .aluctrl(ex_alu_op), .Z(alu_out), .overflow(ex_overflow), .equal(ex_equal), .not_equal(ex_not_equal), 
    .less_than(ex_less_than), .greater_than_equal(ex_greater_than_equal) );
    
    if (ex_branch) // NOTE: These conditional statement could be moved to a module called "Branch_Evaluator"
    begin

        if (ex_equal && (ex_alu_op == 4'b0110))
            branch_flag = 1;
        
        else if (ex_not_equal && (ex_alu_op == 4'b0111 ))
            branch_flag = 1;
        
       else if (ex_less_than && (ex_alu_op == 4'b1000))
            branch_flag = 1;
        
        else if (ex_greater_than_equal && (ex_alu_op == 4'b1001))
            branch flag = 1;
        
        else
            branch_flag = 0;

    end

    // NEEDS MODIFICATION
	pipe_reg_ex_mem ex_mem_pipe_reg(.clk(clk), .WMemEnIn(ex_WMemEn), .WRegEnIn(ex_WRegEn), .rsData1In(ex_rsData1), .rsData2In(ex_rsData2), .rdAddrIn(ex_rd), 
		.WMemEnOut(mem_WMemEn), .WRegEnOut(mem_WRegEn), .rsData1Out(mem_rsData1), .rsData2Out(mem_rsData2), .rdAddrOut(mem_rd));
		
	//Memory stage datapath
	data_mem dMem(.addra(mem_rsData1), .addrb(memAddr), .clka(clk), .clkb(clk), .dina(mem_rsData2), .dinb(memInData), .douta(mem_rdData), .doutb(memOutData), .wea(mem_WMemEn), .web(memWE));
	
	pipe_reg_mem_wb mem_wb_pipe_reg(.clk(clk), .WRegEnIn(mem_WRegEn), .rdAddrIn(mem_rd), .rdDataIn(mem_rdData), .WRegEnOut(wb_WRegEn), .rdAddrOut(wb_rd), .rdDataOut(wb_rdData));
	


endmodule
