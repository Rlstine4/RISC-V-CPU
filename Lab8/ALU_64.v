module ALU_64(input signed [63:0] A,
              input signed [63:0] B,
              input [3:0] aluctrl,
              output reg signed [63:0] Z,
              output reg overflow);


parameter IDLE                    = 4'b0000,
          ADD                     = 4'b0001,
          SUB                     = 4'b0010,
          bitwise_AND             = 4'b0011,
          bitwise_OR              = 4'b0100,
          bitwise_XNOR            = 4'b0101,
          compare_equal           = 4'b0110,
          compare_greater_than    = 4'b0111,
          compare_less_than       = 4'b1000,
          log_shift_left          = 4'b1001,
          log_shift_right         = 4'b1010;
          

always @(*) 

    begin

    case (aluctrl)

        IDLE:
            Z = 64'bX;

        ADD:
        begin
            Z = A + B;        // Concatenate bit 64 with bits 63-0

            if (A[63] && B[63] && ~Z[63])
                overflow = 1;
            else if (~A[63] && ~B[63] && Z[63])
                overflow = 1;
            else
                overflow = 0;
        end
       
        SUB:
        begin
            Z = A - B;

            if (~A[63] && B[63] && Z[63])
                overflow = 1;
            else if (A[63] && ~B[63] && ~Z[63])
                overflow = 1;
            else
                overflow = 0;
        end

        bitwise_AND:
            Z = A & B;
        
        bitwise_OR:
            Z = A | B;
        
        bitwise_XNOR:
            Z = A ~^ B;

        compare_equal:
            Z = A == B;
        
        compare_greater_than:
            Z = A > B;
        
        compare_less_than:  // Daniel :Added compare_greater_than and compare_less_than to address 
            Z = A < B;      
                            
        log_shift_left:
            Z = A << B; 

        log_shift_right:
            Z = A >> B;
        
        default: 
                 Z = 64'bX;

    endcase

    end


endmodule
