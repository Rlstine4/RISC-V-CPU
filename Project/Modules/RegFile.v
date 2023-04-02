`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.02.2023 20:17:23
// Design Name: Register File 32x64
// Module Name: RegFile
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module RegFile(
    input clk, rst,
    input [6:0]raddr1, raddr2, waddr,
    input wen,
    input [63:0]wdata,
    output [63:0]rdata1, rdata2
    );
    
    reg [63:0]registerFile[0:127];
    integer i=0;
    
	assign rdata1 = registerFile[raddr1];
    assign rdata2 = registerFile[raddr2];
    
    always@(negedge clk)
    begin
        if(rst == 1'b1)
        begin
            for(i = 0; i<128; i= i+1)
            begin
                registerFile[i] <= 64'h00000000;
            end
        end
        else
        begin
            if(wen == 1'b1)
            begin
                registerFile[waddr] <= wdata;
            end
        end
    end
    
endmodule
