// Don't think you can use Z in verilog since it's a keyword for high impedance, therefore I'll use C for output

module ALU_64(A, B, aluctrl, overflow, C);

input [63:0] A;
input [63:0] B;
input aluctrl [3:0]; //ALU CTRL signal can be a nibble, allowing up to 16 commands.. This can be changed later
output reg C[63:0];
output reg overflow;

parameter ADD          = 4'b0001;
parameter SUB          = 4'b0010;
parameter bitwise_AND  = 4'b0011;
parameter bitwise_OR   = 4'b0100;
parameter bitwise_XNOR = 4'b0101;
parameter compare      = 4'b0110;
parameter log_shift    = 4'b0111;


    case (aluctrl)

        ADD:
            C <= A + B;

        SUB:
            C <= A - B;
        
        bitwise_AND:
            C <= A & B;
        
        bitwise_OR:
            C <= A | B;
        
        bitwise_XNOR:
            C <= A ~^ B;

        compare:
            C <= A == B; // Review this
        
        log_shift:
            C <= A << B; // Shift A according to B.. review this

    endcase






endmodule