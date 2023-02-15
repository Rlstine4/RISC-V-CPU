`timescale 1ns/100ps
module tb;

reg [63:0] A, B;
reg [3:0] aluctrl;
wire [63:0] Z;
wire overflow;

ALU_64 alu_DUT(.A(A), .B(B), .aluctrl(aluctrl), .Z(Z), .overflow(overflow));


initial 

    begin

        $dumpfile("test.vcd");
        $dumpvars(0,tb);
        
        A = 0;
        B = 0;

            // ADD A = 10, B = 0, RESULT = 10
        #10 
            A = 64'd10;
            B = 64'h0;
            aluctrl = 4'b0001;

            // ADD A = -10, B = -100, RESULT = -110
        #10
            A = -10;
            B = -100;

            // This combination of large positive numbers should result in OVERFLOW = 1 (2 complement addition)

        #10
            A = 64'h7FFF_FFFF_FFFF_FFFF;
            B = 64'h7FFF_FFFF_FFFF_FFFF;

          // This combination of large negative numbers should result in OVERFLOW = 1 (2 complement addition)   

        #10
            A = 64'h8000_0000_0000_0000;
            B = 64'h8000_0000_0000_0000;

            // SUB A = 10, B = 5, RESULT = 10
        
        #10
            A = 64'd10;
            B = 64'd5;
            aluctrl = 4'b0010;

            // SUB A = -10, B = -5, Result = -5
        #10
            A = -10;
            B = -5;

        #10 // AND A = FFFF_FFFF_FFFF_FFFF with B = FFFF_FFFF_FFFF_FFFF and result = FFFF_FFFF_FFFF_FFFF
            A = 64'hFFFF_FFFF_FFFF_FFFF;
            B = 64'hFFFF_FFFF_FFFF_FFFF;
            aluctrl = 4'b0011;
        
        #10 // AND A = 0000_0000_0000_0000 with B = FFFF_FFFF_FFFF_FFFF and result = FFFF_FFFF_FFFF_FFFF
            A = 64'h0000_0000_0000_0000;
            B = 64'hFFFF_FFFF_FFFF_FFFF;
            aluctrl = 4'b0011;


        #10 $finish;
    end


endmodule