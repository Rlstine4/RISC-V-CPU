`timescale 1ns/100ps
module tb;

reg [63:0] A, B;
reg [3:0] aluctrl;
wire [63:0] Z;
wire overflow;

ALU_64 alu_DUT(.A(A), .B(B), .aluctrl(aluctrl), .Z(Z), .overflow(overflow));


initial 

    begin

        //$dumpfile("test.vcd");
        //$dumpvars(0,tb);
        
        A = 0;
        B = 0;
        aluctrl = 0;

        #5
            A = 8'hF;
            B = 8'h0;
            aluctrl = 4'b0001;
        
        #5
            A = 8'hF;
            B = 8'hF;
            aluctrl = 4'b0010;

        #10 $finish;
    end


endmodule