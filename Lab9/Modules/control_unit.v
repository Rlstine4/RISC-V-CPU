module control_unit (input [6:0] opcode, [7:0] funct7, [2:0] funct3
                     output reg [3:0] alu_op, 
                     alu_src, branch, jump, mem_read, mem_write, reg_write, mem_to_reg);

  // Opcodes for different types of instructions

  parameter R_TYPE      = 7'b0110011, // ADD, AND, OR, SLL, SLT, SLTU, SRA, SRL, SUB, XOR
            I_TYPE      = 7'b0010011, // ADDI, SLTI, SLTIU, XORI, ANDI, ORI
            LOAD        = 7'b0000011, // (Special I-TYPE) LB, LH, LW, LHU, LBU
            U_TYPE      = 7'b0110111, // LUI, AUIPC
            S_TYPE      = 7'b0100011, // 
            B_TYPE      = 7'b1100011, // 
            JAL         = 7'b1101111;
            JALR        = 7'b1100111;

    always @(*)

    begin

        case (opcode)

            R_TYPE:

              {alu_src, branch, jump, mem_read, mem_write, reg_write, mem_to_reg} = 7'b0000010;

                if ( (funct7 == 7'b0000000) && (func3 == 3'b000)) // ADD   
                        alu_op     = 4'b0001; 
   
                else if ( (funct7 == 7'b0100000) && (func3 == 3'b000)) // SUB
                        alu_op     = 4'b0010;
                
                else if ( (funct7 == 7'b0000000) && (func3 == 3'b111)); // AND
                        alu_op     = 4'b0011;

            I_TYPE:
                {alu_src, branch, jump, mem_read, mem_write, reg_write, mem_to_reg} = 0; //TODO

                alu_op      = 0; // TODO
            
            LOAD:
                {alu_src, branch, jump, mem_read, mem_write, reg_write, mem_to_reg} = 0;




        endcase


    end



endmodule