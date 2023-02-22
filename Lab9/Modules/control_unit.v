/*

    Description: TODO

    Signals:
        1. alu_src: When this is 0, the 2nd operand (rs2) comes from the register file. When this is a 1, the 2nd operand
                    is derived from the instruction itself
        2. branch
        3. jump
        4. mem_read
        5. mem_write
        6. reg_write
        7. mem_to_reg. When this is 0, the data bypass D-MEM. When this is a 1, value must be pulled from data memory

*/


module control_unit (
	input [6:0] opcode, 
	input [7:0] funct7, 
	input [2:0] funct3,
	output reg [3:0] alu_op,
	output reg alu_src, branch, jump, mem_read, mem_write, reg_write, mem_to_reg
	);

  // Opcodes for different types of instructions

  parameter NOOP        = 7'b0000000,
            R_TYPE      = 7'b0110011, // ADD, AND, OR, SLL, SLT, SLTU, SRA, SRL, SUB, XOR
            I_TYPE      = 7'b0010011, // ADDI, SLTI, SLTIU, XORI, ANDI, ORI
            LOAD        = 7'b0000011, // (Special I-TYPE) LB, LH, LW, LHU, LBU
            U_TYPE      = 7'b0110111, // LUI, AUIPC
            STORE       = 7'b0100011, // SB, SH, SW
            BRANCH      = 7'b1100011, // BEQ, BNE, BLT, BGE, BLTU, BGEU
            JAL         = 7'b1101111, // (J-Type)
            JALR        = 7'b1100111; // (Special I-Type) 

    always @(*)
    begin
        case (opcode)
		
            NOOP:
			begin
                 {alu_src, branch, jump, mem_read, mem_write, reg_write, mem_to_reg} = 7'b0000000;
                 alu_op = 4'b0000; // IDLE
			end

            R_TYPE:
			begin
              {alu_src, branch, jump, mem_read, mem_write, reg_write, mem_to_reg} = 7'b0000010;

                if ( (funct7 == 7'b0000000) && (funct3 == 3'b000)) // ADD   
				begin
					alu_op     = 4'b0001; 
				end
   
                else if ( (funct7 == 7'b0100000) && (funct3 == 3'b000)) // SUB
				begin
					alu_op     = 4'b0010;						
				end
                
                else if ( (funct7 == 7'b0000000) && (funct3 == 3'b111)); // AND
				begin
					alu_op     = 4'b0011;
				end
			end

            I_TYPE:
			begin
                {alu_src, branch, jump, mem_read, mem_write, reg_write, mem_to_reg} = 7'b1000010;

                if ( funct3 == 3'b000 ) // ADDI
				begin
                    alu_op = 4'b0001;
				end
                
                else if ( funct3 == 3'b110 ) // ORI
				begin
                    alu_op = 4'b0100;
				end
                
                else if ( funct3 == 3'b111 ) //ANDI
				begin
                    alu_op = 4'b0011;
				end
                
                else if ( funct3 == 3'b001)  // SLLI
				begin
                    alu_op = 4'b1001;
				end
			end
           
            LOAD:
			begin
                {alu_src, branch, jump, mem_read, mem_write, reg_write, mem_to_reg} = 7'b1001011;
                alu_op = 4'b0001; // ADD
			end
            
            STORE:
			begin
                {alu_src, branch, jump, mem_read, mem_write, reg_write, mem_to_reg} = 7'b1000100;
                alu_op = 4'b0001;
			end
            
            BRANCH:
			begin
                {alu_src, branch, jump, mem_read, mem_write, reg_write, mem_to_reg} = 7'b0100000;

                if ( funct3 == 3'b000) // BEQ
				begin
                    alu_op = 4'b0110;
				end
                
                if ( funct3 == 3'b001) // BNEQ
				begin
                    alu_op = 4'b0111;
				end

                if ( funct3 == 3'b100) // BLT
				begin
                    alu_op = 4'b1000;
				end
                
                if ( funct3 == 3'b101) // BGE
				begin
                    alu_op = 4'b1001;
				end
			end
            
            JAL: // REVIEW
			begin
                {alu_src, branch, jump, mem_read, mem_write, reg_write, mem_to_reg} = 7'b1010000;
                alu_op = 4'b0001; // ADD
			end


        endcase


    end



endmodule