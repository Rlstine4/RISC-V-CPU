`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:33:58 03/29/2023 
// Design Name: 
// Module Name:    simple_matcher 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module simple_matcher(input [63:0] in_data,
                      input [63:0] pattern,
                      output reg match);

always @(*)
begin

    if (in_data == pattern)
    begin
    match = 1;
    end

    else
    begin
    match = 0;
    end

end




endmodule
