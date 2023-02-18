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

                if ( (funct7 == 7'b0000000) && (func3 == 3'b000)) // ADD
                    begin
                        alu_op     = 4'b0001; 
                        alu_src    = 1'b0;
                        branch     = 1'b0;
                        jump       = 1'b0;
                        mem_read   = 1'b0;
                        mem_write  = 1'b0;
                        reg_write  = 1'b1;
                        mem_to_reg = 1'b0;
                    end




        endcase


    end



endmodule