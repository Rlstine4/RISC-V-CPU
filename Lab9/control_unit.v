module control_unit (input [6:0] opcode, [7:0] funct7, [2:0] funct3
                     output reg [3:0] alu_op, 
                     alu_src, branch, jump, mem_read, mem_write, reg_write, mem_to_reg);

  // Opcodes for different types of instructions

  parameter R_TYPE      = 7'b0110011,
            I_TYPE      = 7'b0010011,
            U_TYPE      = 7'b0110111,
            LOAD        = 7'b0000011,
            STORE       = 7'b0100011,
            JAL         = 7'b1101111,
            JALR        = 7'b1100111,
            BRANCH      = 7'b1100011;

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

            LOAD:

                {alu_src, branch, jump, mem_read, mem_write, reg_write, mem_to_reg} = 7'b1001011;

                alu_op      = 4'b0001; // ADD
            
            STORE:
                {alu_src, branch, jump, mem_read, mem_write, reg_write, mem_to_reg} = 7'b1000100;

                alu_op      = 4'b0001; // ADD

            I_TYPE:
                {alu_src, branch, jump, mem_read, mem_write, reg_write, mem_to_reg} = 0; // TODO

                alu_op      = 0; // TODO
            
            U_TYPE:
                {alu_src, branch, jump, mem_read, mem_write, reg_write, mem_to_reg} = 0; // TODO

                alu_op      = 0; // TODO
            
            JAL:
                {alu_src, branch, jump, mem_read, mem_write, reg_write, mem_to_reg} = 0; // TODO

                alu_op      = 0; // TODO
            
            JALR:
                {alu_src, branch, jump, mem_read, mem_write, reg_write, mem_to_reg} = 0; // TODO

                alu_op      = 0; // TODO
            
            BRANCH:
                {alu_src, branch, jump, mem_read, mem_write, reg_write, mem_to_reg} = 0; // TODO

                alu_op      = 0; // TODO

    




        endcase


    end



endmodule