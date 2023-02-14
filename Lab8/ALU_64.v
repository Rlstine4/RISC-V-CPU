module ALU_64(A, B, aluctrl, overflow, Z); // add clk here?

// input wire clk; for synchronous?
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


always @(*) // @(posedge clk) for synchronous?
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
                        // Brendan: seems right, should we also add A <= B and A >= B or will == suffice?
        
        log_shift:
            Z = A << B; // Shift A according to B.. review this
                        // Brendan: A << 1 for logical shift (left)? Should we also add logical shift (right) A >> 1?

        //default: Z = A or something? Necessary?
    endcase

    end


endmodule