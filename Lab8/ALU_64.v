module ALU_64(A, B, aluctrl, overflow, Z);

input [63:0] A;
input [63:0] B;
input [3:0] aluctrl; //ALU CTRL signal can be a nibble, allowing up to 16 commands.. This can be changed later
output reg [63:0] Z;
output reg overflow;

parameter IDLE         = 4'b0000,
          ADD          = 4'b0001,
          SUB          = 4'b0010,
          bitwise_AND  = 4'b0011,
          bitwise_OR   = 4'b0100,
          bitwise_XNOR = 4'b0101,
          compare      = 4'b0110,
          log_shift    = 4'b0111;


always @(*)
    begin

    case (aluctrl)

        IDLE:
            Z = 64'bX;

        ADD:
            Z = A + B;

        SUB:
            Z = A - B;
        
        bitwise_AND:
            Z = A & B;
        
        bitwise_OR:
            Z = A | B;
        
        bitwise_XNOR:
            Z = A ~^ B;

        compare:
            Z = A == B; // Review this
        
        log_shift:
            Z = A << B; // Shift A according to B.. review this

    endcase

    end


endmodule