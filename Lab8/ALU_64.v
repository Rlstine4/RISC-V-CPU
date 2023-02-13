// Don't think you can use Z in verilog since it's a keyword for high impedance, therefore I'll use C for output

module ALU_64(A, B, aluctrl, overflow, C);

input [63:0] A;
input [63:0] B;
input aluctrl [3:0]; //ALU CTRL signal can be a nibble, allowing up to 16 commands.. This can be changed later
output reg C[63:0];
output reg overflow;


endmodule