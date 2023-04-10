/*
    TODO:

        https://hur.st/bloomfilter/?n=1000&p=1.0E-7&m=&k=2 (To determine paramters)

        OPTION 1:

        For 1 in 1,000,000 chance of false detection, we need ~250KB of BRAM
        FOr 1 in 100,000 chance of false detection, we need ~80KB of BRAM

        This assumes 2 Hash functions and 1,000 patterns 

        OPTION 2:

        For 1 in 1,000,000 chance of false detection, we need ~16KB of BRAM
        FOr 1 in 100,000 chance of false detection, we need ~9KB of BRAM

        This assumes 4 Hash functions and 1,000 patterns


*/

module bloom_filter(input clk, rst,
                    input [63:0] packet_data,
                    output match );

wire [15:0] bloom_index_0, bloom_index_1, bloom_index_2, bloom_index_3;

wire bloom_value_0, bloom_value_1, bloom_value_2, bloom_value_3;

// Instantiate our Hash functions

mod_hash hash_0(.data_in(packet_data[15:0]), .hashed_value(bloom_index_0));

knuth_hash hash_1 (.data_in(packet_data[31:16]), .hashed_value(bloom_index_1));

invert_hash hash_2 (.data_in(packet_data[47:32]), .hashed_value(bloom_index_2));

XOR_hash hash_3 (.data_in_0(packet_data[63:48]), .data_in_1(packet_data[15:0]), .hashed_value(bloom_index_3));

// NEED TO ADD RST ?

bloom_buffer bloom_buffer_0(
	.clka(clk),
	.addra(bloom_index_0),
	.douta(bloom_value_0),
	.clkb(clk),
	.addrb(bloom_index_1),
	.doutb(bloom_value_1));

bloom_buffer_1 bloom_buffer_1(
	.clka(clk),
	.addra(bloom_index_2),
	.douta(bloom_value_2),
	.clkb(clk),
	.addrb(bloom_value_3),
	.doutb(bloom_index_3));


assign match = (bloom_value_0 && bloom_value_1 && bloom_value_2 && bloom_value_3); // Might want to clock this to avoid glitches



endmodule