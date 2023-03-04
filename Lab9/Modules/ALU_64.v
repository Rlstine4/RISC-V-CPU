module ALU_64(input signed [63:0] A,
              input signed [63:0] B,
              input [3:0] aluctrl,
              output reg signed [63:0] Z,
              output reg overflow,
              //output reg equal,
              //output reg not_equal,
              output reg less_than,
              output reg greater_than_equal);


parameter IDLE                          = 4'b0000,
          ADD                           = 4'b0001,
          SUB                           = 4'b0010,
          //bitwise_AND                   = 4'b0011,
          //bitwise_OR                    = 4'b0100,
          //bitwise_XNOR                  = 4'b0101,
//          compare_equal                 = 4'b0110,
//          compare_not_equal             = 4'b0111,
          compare_less_than             = 4'b1000,
          compare_greater_than_equal    = 4'b1001,
          log_shift_left                = 4'b1010;
//          xlog_shift_right               = 4'b1011;
          

always @(*) 

    begin

    case (aluctrl)

        IDLE:
            Z = 64'b0;

        ADD:
        begin
            Z = A + B;

//            if (A[63] && B[63] && ~Z[63])
//                overflow = 1;
//            else if (~A[63] && ~B[63] && Z[63])
//                overflow = 1;
//            else
//                overflow = 0;
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

//        bitwise_AND:
//            Z = A & B;
//        
//        bitwise_OR:
//            Z = A | B;
//        
//        bitwise_XNOR:
//            Z = A ~^ B;

//        compare_equal:
//        begin
//            Z = A == B;
//
//            if (Z)
//                equal = 1;
//            else
//                equal = 0;
//        end
//
//        compare_not_equal:
//            Z = ~(A== B);

        
        compare_greater_than_equal: // NEEDS TESTING
        begin
            Z = A >= B;
 
            if (Z == 1'b1)
                greater_than_equal = 1'b1;
            else
                greater_than_equal = 1'b0;
        end
        
        compare_less_than:
        begin
            Z = A < B;
			less_than = Z[0];
            if (Z == 1'b1)
                less_than = 1'b1;
            else
                less_than = 1'b0;
        end      
                            
        log_shift_left:
            Z = A << B; 

//        log_shift_right:
//            Z = A >> B;
        
        default: 
                 Z = 64'b0;

    endcase

    end


endmodule
