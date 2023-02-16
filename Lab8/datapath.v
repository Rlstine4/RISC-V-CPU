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
	input clk, rst
	);
	
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
	
	
	//Instruction Fetch stage datapath
	pcCounter pcc(.clk(clk), .rst(rst), .pc(pc));
	inst_mem iMem(.addr(pc), .clk(clk), .dout(if_inst));
	
	pipe_reg_if_id if_id_pipe_reg(.clk(clk), .WMemEnIn(if_inst[31]), .WRegEnIn(if_inst[30]), .rsAddr1In(if_inst[29:25]), .rsAddr2In(if_inst[24:20]), .rdAddrIn(if_inst[19:15]), 
		.WMemEnOut(id_WMemEn), .WRegEnOut(id_WRegEn), .rsAddr1Out(id_rs1), .rsAddr2Out(id_rs2), .rdAddrOut(id_rd));
		
	RegFile register(.clk(clk), .rst(rst), .raddr1(id_rs1), .raddr2(id_rs2), .waddr(wb_rd), .wen(wb_WRegEn), .wdata(wb_rdData), .rdata1(id_rsData1), .rdata2(id_rsData2));
	//Instruction Decode stage datapath
	
	pipe_reg_id_ex id_ex_pipe_reg(.clk(clk), .WMemEnIn(id_WMemEn), .WRegEnIn(id_WRegEn), .rsData1In(id_rsData1), .rsData2In(id_rsData2), .rdAddrIn(id_rd), 
		.WMemEnOut(ex_WMemEn), .WRegEnOut(ex_WRegEn), .rsData1Out(ex_rsData1), .rsData2Out(ex_rsData2), .rdAddrOut(ex_rd));
	
	//Execution stage stage datapath
	pipe_reg_id_ex ex_mem_pipe_reg(.clk(clk), .WMemEnIn(ex_WMemEn), .WRegEnIn(ex_WRegEn), .rsData1In(ex_rsData1), .rsData2In(ex_rsData2), .rdAddrIn(ex_rd), 
		.WMemEnOut(mem_WMemEn), .WRegEnOut(mem_WRegEn), .rsData1Out(mem_rsData1), .rsData2Out(mem_rsData2), .rdAddrOut(mem_rd));
		
	//Memory stage datapath
	data_mem dMem(.addr(mem_rsData1), .clk(clk), .din(mem_rsData2), .dout(mem_rdData), .we(mem_WMemEn));
	
	pipe_reg_mem_wb mem_wb_pipe_reg(.clk(clk), .WRegEnIn(mem_WRegEn), .rdAddrIn(mem_rd), .rdDataIn(mem_rdData), .WRegEnOut(wb_WRegEn), .rdAddrOut(wb_rd), .rdDataOut(wb_rdData));
	


endmodule
