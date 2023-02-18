timescale 1ns/100ps
// TODO: Will probably write a text file that emulates machine code that is read in. As it's read in, the control unit
//       must decode the fields and output the proper signals

module tb;

reg input [6:0] opcode, [7:0] funct7, [2:0] funct3;
wire [3:0] alu_op, alu_src, branch, jump, mem_read, mem_write, reg_write, mem_to_reg;

control_unit control_unit_DUT(.opcode(opcode), .funct7(funct7), .func3(func3), .alu_op(alu_op), .alu_src(alu_src),
                              .branch(branch), .jump(jump), .mem_read(mem_read), .mem_write(mem_write), .reg_write(reg_write),
                              .mem_to_reg(mem_to_reg));


endmodule