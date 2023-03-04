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

        #10 // Subtract the largest possible negative number from the largest positive number. OVERFLOW = 1
            // Result will be positive.. But subtract a negative number from a positive number should never result in a positive number...
            A = 64'h8000_0000_0000_0000;
            B = 64'h0FFF_FFFF_FFFF_FFFF;

            // SUB A = -10, B = -5, Result = -5
        #10
            A = -10;
            B = -5;
        


        #10 // AND A = FFFF_FFFF_FFFF_FFFF with B = FFFF_FFFF_FFFF_FFFF and result = FFFF_FFFF_FFFF_FFFF
            A = 64'hFFFF_FFFF_FFFF_FFFF;
            B = 64'hFFFF_FFFF_FFFF_FFFF;
            aluctrl = 4'b0011;
        
        #10 // AND A = 0000_0000_0000_0000 with B = FFFF_FFFF_FFFF_FFFF and result = 0000_0000_0000_0000
            A = 64'h0000_0000_0000_0000;
            B = 64'hFFFF_FFFF_FFFF_FFFF;
            aluctrl = 4'b0011;
        
        #10 // OR A = 0000_0000_0000_0000 with B = FFFF_FFFF_FFFF_FFFF and result = FFFF_FFFF_FFFF_FFFF
            aluctrl = 4'b0100;
        
        #10 // XNOR A = 0000_0000_0000_0000 with B = FFFF_FFFF_FFFF_FFFF and result = 0000_0000_0000_0000
            aluctrl = 4'b0101;

        #10 // XNOR A = 0001_0000_0001_0001 with B = 0000_0000_0000_0000 and result = FFFF_FFFF_FFFF_FFFF
            A = 64'h1111_1111_1111_1111;
            B = 64'h1111_1111_1111_1111;

        #10 // Compare equal A = 1010_1010_1010_1010, B = 0000_0000_0000_0000, RESULT = 0
            A = 64'h1010_1010_1010_1010;
            B = 64'h0000_0000_0000_0000;
            aluctrl = 4'b0110;
            
        #10 // Compare equal A = 1010_1010_1010_1010, B = 1010_1010_1010_1010, RESULT = 1
            B = 64'h1010_1010_1010_1010;
        
        #10 //Compare greater than A = 0111_1111_1111_1111, B = 0000_0000_0000_0000, RESULT = 1
            A = 64'h0111_1111_1111_1111;
            B = 64'h0000_0000_0000_0000;
            aluctrl = 4'b0111;

        #10 //Compare greater than A = F000_0000_0000_0000, B = 0000_0000_0000_0000, RESULT = 0
            A = 64'hF000_0000_0000_0000;
        
        #10 // Compare less than A = F000_0000_0000_0000, B = 0000_0000_0000_0000, RESULT = 1
            aluctrl = 4'b1000;
        
        #10 // Shift left (logical) A = 0000_0000_0000_0001 (1), B = 0000_0000_0000_0002 (Shift left twice), Result = 4 (decimal)
            A = 64'h0000_0000_0000_0001;
            B = 64'd2;
            aluctrl = 4'b1001;

        #10 // Shift left (logical) A = 0000_0000_0000_0004 (decimal 4), B = 0000_0000_0000_0002 (Shift left twice), Result = 16 (decimal)
            A = 64'h0000_0000_0000_0004;
            B = 64'd2;
        
        #10 // Shift right (logical) A = 0000_0000_0000_0010 (decimal 16), B = 0000_0000_0000_0003 (Shift right 3X), Result = 2 (decimal)
            A = 64'h0000_0000_0000_0010;
            B = 64'd3;
            aluctrl = 4'b1010;
        
        #10 // Shift right (logical) A = 0000_0000_0000_0001, B = 0000_0000_0000_FFFF (Shift right 256X), Result = 0
            A = 64'h0000_0000_0000_0001;
            B = 64'h0000_0000_0000_FFFF;
        
        #10
            aluctrl = 4'b0000;
        
        #10 $finish;
    end


endmodule