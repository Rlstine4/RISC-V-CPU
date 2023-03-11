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
	input clk, rst, memWE, iMemWE, logicEn, logicWe,
	input [7:0]memAddr,
	input [8:0]iMemAddr,
	input [63:0]memInData,
	input [31:0]iMemInData,
	input [13:0]logicAddr,
    input [7:0] in_ctrl,
    input [63:0] packet_data_in,
    output packet_accept,
	output [63:0]memOutData,
	output [217:0]logicData
	);
	
	//instruction Fetch wires
	wire [8:0]pc;
	wire [31:0]if_inst;
    wire [1:0]PCSrc;
    reg [1:0]PCSrc_reg;
    wire [8:0]branchAddr, jumpAddr;    
	reg [8:0]branchAddr_reg, jumpAddr_reg;

    
	//instruction decode wires
    wire [31:0] id_inst;
    wire [6:0] opcode;
    wire [6:0] funct7;
    wire [2:0] funct3;
    wire [3:0]id_alu_op;
	wire id_alu_src, id_branch, id_jump, id_mem_read, id_mem_write, id_reg_write, id_mem_to_reg, id_process_end;
    wire id_fifo_select;
	wire id_WMemEn, id_WRegEn;
	wire [4:0]id_rs1, id_rs2, id_rd;
	wire [63:0]id_rsData1, id_rsData2;
    wire [11:0]intermediate_12; // I-Type, B-Type, S-Type instructions use 12 bit intermediate
	reg [11:0]intermediate_12_reg;
    wire [20:0]intermediate_21; // JAL
	reg [20:0]intermediate_21_reg;
    wire [12:0] id_branch_offset;
	reg [12:0] id_branch_offset_reg;
    wire [19:0] jump_offset;
	reg [19:0] jump_offset_reg;
	reg id_stall;
	reg id_stall_reg;
	
	//Execution stage wires
	wire [4:0]ex_rd;
	wire [63:0]ex_rsData1, ex_rsData2, alu_B, ex_alu_out;
	reg [63:0]alu_B_reg;
    wire [3:0]ex_alu_op;
	wire ex_alu_src;
	//wire ex_branch = 0, ex_mem_read = 0, ex_mem_write = 0, ex_reg_write = 0, ex_mem_to_reg = 0, ex_overflow = 0;
	wire ex_branch, ex_mem_read, ex_mem_write, ex_reg_write, ex_mem_to_reg, ex_overflow;
    wire branch_flag; // Replaces the "ZERO" output in the tradidtional 5-stage pipeline
	reg branch_flag_reg;
    wire ex_equal, ex_not_equal, ex_less_than, ex_greater_than_equal;
    wire [11:0] ex_intermediate_12;
    wire [63:0] signed_intermediate;
	wire [12:0] ex_branch_offset;
    wire ex_fifo_select, ex_process_end;
	
	//Memory stage wires
	wire mem_WMemEn;
	wire [4:0]mem_rd;
	wire [63:0]mem_rsData2, mem_mem_out;
    //wire mem_overflow = 0, mem_branch = 0, mem_read = 0, mem_reg_write = 0, mem_mem_to_reg = 0
    wire mem_overflow, mem_branch, mem_read, mem_reg_write, mem_mem_to_reg, mem_write;
	wire mem_equal, mem_not_equal, mem_less_than, mem_greater_than_equal;
    wire [63:0] mem_alu_out;
	wire [12:0] mem_branch_offset;
	wire [3:0]mem_alu_op;
    wire mem_fifo_select, mem_process_end;
    wire fifo_full, fifo_empty, fifo_busy, fifo_rdy_rd;
    wire [63:0] fifo_out;
	 wire [8:0] fifo_count;

    assign packet_accept = ~fifo_rdy_rd; // When FIFO is NOT being read, signal will go HIGH telling the Output Queues to send new packet
	
	//WriteBack stage wires
	wire wb_RegWrite, wb_mem_to_reg;
	wire [4:0]wb_rd;
	wire [63:0]wb_mem_out, wb_alu_out;
	wire [63:0]wb_rdData;
	reg [63:0]wb_rdData_reg;
	wire wb_fifo_select;

    reg rst_reg;

    always @(*)
    begin

       if (rst || mem_process_end)
        begin
            rst_reg = 1;
        end

        else if(fifo_rdy_rd)
        begin
            rst_reg = 0;
        end

    end

    
	wire reset;
	assign reset = rst || rst_reg;
	
	//misc
	reg [31:0]cycle_count_reg= 0, ex_inst_check_reg, mem_inst_check_reg, wb_inst_check_reg;
	wire [31:0]cycle_count, ex_inst_check, mem_inst_check, wb_inst_check;
	always@(posedge clk) 
	begin
		ex_inst_check_reg <= id_inst;
		mem_inst_check_reg <= ex_inst_check_reg;
		wb_inst_check_reg <= mem_inst_check_reg;
	end
	assign ex_inst_check = ex_inst_check_reg;
	assign mem_inst_check = mem_inst_check_reg;
	assign wb_inst_check = wb_inst_check_reg;
	
	//Instruction Fetch stage datapath
	pcCounter pcc(.en(~(id_stall)), .clk(clk), .rst(reset), .pc(pc), .PCSrc(PCSrc), .jumpAddr(jumpAddr_reg), .branchAddr(branchAddr));
	inst_mem iMem(.ena(~(id_stall || reset)), .sinita(id_jump || branch_flag), .addra(pc), .clka(clk), .douta(id_inst), 
					.web(iMemWE), .addrb(iMemAddr), .dinb(iMemInData), .clkb(clk));
    
    //pipe_reg_if_id if_id_pipe_reg(.en(~(id_stall || rst)), .clk(clk), .clr(id_jump || branch_flag), .instruction_in(if_inst), .instruction_out(id_inst));

    //Instruction Decode stage datapath
	assign id_rs1 = id_inst[19:15]; // rs1 must tap into bits 19-15 of the instruction
    assign id_rs2 = id_inst[24:20]; // rs2 must tap into bits 24-20 of the instruction
    assign id_rd  = id_inst[11:7];   // rd  must tap into bits 11-7 of the instruction

    assign opcode	= id_inst[6:0];    // opcode is lower 7 bits of the instruction
    assign funct7 	= id_inst[31:25];  // when applicable
    assign funct3  	= id_inst[14:12];  // when applicable
	
	//HDU
	reg ex_valid, mem_valid;
	always@(*)
	begin
		ex_valid = ex_alu_src || ex_mem_read || ex_mem_write || ex_reg_write || ex_mem_to_reg || ex_branch ;
		mem_valid =  mem_read || mem_write || mem_reg_write || mem_mem_to_reg;
		id_stall =  (ex_valid || mem_valid);
	end

	always@(*)
	begin
		intermediate_12_reg = 12'b0;
		if (opcode == 7'b0010011 || opcode == 7'b0000011) // i-type or load
		begin
			intermediate_12_reg = id_inst[31:20];
			//PCSrc_reg = 2'b00;
		end
		if (opcode == 7'b0100011) // s-type
		begin
			intermediate_12_reg = {id_inst[31:25], id_inst[11:7]};
			//PCSrc_reg = 2'b00;
		end
        if (opcode == 7'b1100011) // branch
        begin
            id_branch_offset_reg = ({id_inst[31], id_inst[31], id_inst[31], id_inst[7], id_inst[30:25], id_inst[11:9]});
			//PCSrc_reg = 2'b00;
			//branchAddr_reg = pc + id_branch_offset_reg - 1;
        end
        if (opcode == 7'b1101111)	//jump
        begin
            //jump_offset_reg = ({id_inst[31], id_inst[19:12], id_inst[20], id_inst[30:21]}) >>> 1;
			jumpAddr_reg = pc + (({id_inst[31], id_inst[19:12], id_inst[20], id_inst[30:21]}) >>> 1) - 1;
			//PCSrc_reg = 2'b10;
        end
	end
//	assign intermediate_12 = intermediate_12_reg;
//	assign id_branch_offset = id_branch_offset_reg;
//	assign jump_offset = jump_offset_reg;
//	assign jumpAddr = jumpAddr_reg;
	//assign PCSrc = PCSrc_reg;
    
    control_unit control(.opcode(opcode), .rd(id_rd), .funct7(funct7), .funct3(funct3), .alu_op(id_alu_op), .alu_src(id_alu_src), .branch(id_branch), 
        .jump(id_jump), .mem_read(id_mem_read), .mem_write(id_mem_write), .reg_write(id_reg_write), .mem_to_reg(id_mem_to_reg), .fifo_select(id_fifo_select), .process_end(id_process_end));
		
	RegFile register(.clk(clk), .rst(reset), .raddr1(id_rs1), .raddr2(id_rs2), .waddr(wb_rd), .wen(wb_RegWrite), .wdata(wb_rdData), 
                    .rdata1(id_rsData1), .rdata2(id_rsData2));
	
	pipe_reg_id_ex id_ex_pipe_reg(.en(~(id_stall || reset)), .clk(clk), .clr(branch_flag), .id_fifo_select(id_fifo_select), .rsData1In(id_rsData1), .rsData2In(id_rsData2), 
                                    .rdAddrIn(id_rd), .alu_op_in(id_alu_op), .id_process_end(id_process_end),
                                    .alu_src_in(id_alu_src), .branch_in(id_branch), .mem_read_in(id_mem_read), .mem_write_in(id_mem_write), .reg_write_in(id_reg_write), 
									.mem_to_reg_in(id_mem_to_reg), .intermediate_in(intermediate_12_reg), .branch_offset_in(id_branch_offset_reg), .alu_op_out(ex_alu_op), 
									.alu_src_out(ex_alu_src), .branch_out(ex_branch), .mem_read_out(ex_mem_read), .mem_write_out(ex_mem_write), .reg_write_out(ex_reg_write), 
									.mem_to_reg_out(ex_mem_to_reg), .rsData1Out(ex_rsData1), .rsData2Out(ex_rsData2), .rdAddrOut(ex_rd), .intermediate_out(ex_intermediate_12), 
									.branch_offset_out(ex_branch_offset), .ex_fifo_select(ex_fifo_select), .ex_process_end(ex_process_end)
                                    );
	
	//Execution stage stage datapath

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

	ALU_64 alu(.A(ex_rsData1), .B(alu_B), .aluctrl(ex_alu_op), .Z(ex_alu_out), .overflow(ex_overflow), //.equal(ex_equal), .not_equal(ex_not_equal), 
				.less_than(ex_less_than), .greater_than_equal(ex_greater_than_equal));
	
	pipe_reg_ex_mem ex_mem_pipe_reg(.en(~(reset)), .clr(branch_flag), .clk(clk), .rdAddrIn(ex_rd), .rsData2In(ex_rsData2), .ex_alu_output(ex_alu_out), .ex_overflow(ex_overflow),
									.ex_mem_read(ex_mem_read), .ex_mem_write(ex_mem_write), .ex_reg_write(ex_reg_write), .ex_mem_to_reg(ex_mem_to_reg), .ex_branch(ex_branch),
                                    .ex_fifo_select(ex_fifo_select), .ex_process_end(ex_process_end),
									//.ex_equal(ex_equal), .ex_not_equal(ex_not_equal), 
									.ex_less_than(ex_less_than), .ex_greater_than_equal(ex_greater_than_equal), 
									.ex_alu_op(ex_alu_op), .branch_offset_in(ex_branch_offset), .rdAddrOut(mem_rd), .mem_overflow(mem_overflow), .mem_read(mem_read), 
									.mem_write(mem_write), .mem_reg_write(mem_reg_write), .mem_to_reg(mem_mem_to_reg), .mem_alu_output(mem_alu_out), .rsData2Out(mem_rsData2), 
									.mem_branch(mem_branch), //.mem_equal(mem_equal), .mem_not_equal(mem_not_equal), 
									.mem_less_than(mem_less_than), .mem_greater_than_equal(mem_greater_than_equal), .mem_alu_op(mem_alu_op), .branch_offset_out(mem_branch_offset),
                                    .mem_fifo_select(mem_fifo_select), .mem_process_end(mem_process_end)
									);
		
	//Memory stage datapath

// Swapping SW/HW ports and processor port. Unable to make port A negetive edge triggered
//	data_mem dMem(.addra(mem_alu_out), .addrb(memAddr), .clka(clk), .clkb(clk), .dina(mem_rsData2), .dinb(memInData), 
//				.douta(mem_rdData), .doutb(memOutData), .wea(mem_write), .web(memWE));


	always@(*)
	begin
		if (mem_branch)
		begin
//			if (mem_equal && (mem_alu_op == 4'b0110))
//			begin
//				branch_flag_reg = 1;
//				branchAddr_reg = pc + mem_branch_offset - 2;
//				PCSrc_reg = 2'b01;
//			end        
//			else if (mem_not_equal && (mem_alu_op == 4'b0111))
//			begin
//				branch_flag_reg = 1;
//				branchAddr_reg = pc + mem_branch_offset - 2;
//				PCSrc_reg = 2'b01;
//			end   
//			else 
			branchAddr_reg = pc + mem_branch_offset - 2;
			if (mem_less_than && (mem_alu_op == 4'b1000))
			begin
				branch_flag_reg = 1;
				PCSrc_reg = 2'b01;
			end        
			else if (mem_greater_than_equal && (mem_alu_op == 4'b1001))
			begin
				branch_flag_reg = 1;
				PCSrc_reg = 2'b01;
			end        
			else
			begin
				branch_flag_reg = 0;
				branchAddr_reg = 0;
				PCSrc_reg = 2'b00;
				if(id_jump && ~ex_branch)
					PCSrc_reg = 2'b10;
			end
		end
		else
		begin
			branch_flag_reg = 0;
			branchAddr_reg = 0;
			PCSrc_reg = 2'b00;
			if(id_jump && ~ex_branch)
					PCSrc_reg = 2'b10;
		end
	end
	assign PCSrc = PCSrc_reg;
	assign branch_flag = branch_flag_reg;
	assign branchAddr = branchAddr_reg;
				
	data_mem dMem(.addra(memAddr), .addrb(mem_alu_out[7:0]), .clka(clk), .clkb(clk), .dina(memInData), .dinb(mem_rsData2), .douta(memOutData), .doutb(wb_mem_out), .wea(memWE), 
					.web(mem_write));
	
	
	pipe_reg_mem_wb mem_wb_pipe_reg(.en(~reset), .mem_fifo_select(mem_fifo_select), .clk(clk), .mem_reg_write_in(mem_reg_write), .mem_to_reg_in(mem_mem_to_reg), .rdAddrIn(mem_rd), .mem_mem_out(mem_mem_out), .wb_fifo_select(wb_fifo_select),
									.mem_alu_out(mem_alu_out), .wb_reg_write(wb_RegWrite), .wb_mem_to_reg(wb_mem_to_reg), .rdAddrOut(wb_rd), .wb_alu_out(wb_alu_out));
    
    special_fifo FIFO(.clk(clk), .rst(rst), .fifo_rd(mem_fifo_select), .count(fifo_count), .in_ctrl(in_ctrl), .data_in(packet_data_in), .processor_done(mem_process_end), .FIFO_FULL(fifo_full), .FIFO_EMPTY(fifo_empty), .busy(fifo_busy), .fifo_rdy_rd(fifo_rdy_rd), .data_out(fifo_out));
	
    
	
	//Write back Stage Datapath
	
	always@(*)
	begin
		if (wb_mem_to_reg == 1'b1) 
		begin
			
			
			if(wb_fifo_select == 1'b1)
			begin
				wb_rdData_reg = fifo_out;
			end
			
			else
			begin
				wb_rdData_reg = wb_mem_out;
			end
			
		end
		else
		begin
			wb_rdData_reg = wb_alu_out;
		end
	end	
	assign wb_rdData = wb_rdData_reg;

	
	
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
