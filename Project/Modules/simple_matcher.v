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
module simple_matcher(input clk,
					  input [63:0] in_data,
                      input [63:0] pattern,
                      output reg match,
					  output reg [63:0]matched_data);

reg [63:0]in_data_p;
wire [119:0]packet;

assign packet = {in_data[55:0], in_data_p[63:0]};

always @(*)
begin
	match = 0;
	matched_data = 0;
	
    if (packet[63:0] == pattern)
	begin
		match = 1;
		matched_data = packet[63:0];
    end
	
	if(packet[71:8] == pattern) 
	begin
		match = 1;
		matched_data = packet[71:8];
    end
	
	if(packet[79:16] == pattern)
	begin
		match = 1;
		matched_data = packet[79:16];
    end
	
	if(packet[87:24] == pattern)
	begin
		match = 1;
		matched_data = packet[87:24];
    end
	
	if(packet[95:32] == pattern)
	begin
		match = 1;
		matched_data = packet[95:32];
    end
	
	if(packet[103:40] == pattern)
	begin
		match = 1;
		matched_data = packet[103:40];
    end
	
	if(packet[111:48] == pattern)
	begin
		match = 1;
		matched_data = packet[111:48];
    end
	
	if(packet[119:56] == pattern)
    begin
		match = 1;
		matched_data = packet[119:56];
    end

end

always@(posedge clk)
begin
	in_data_p <= in_data;
end




endmodule
