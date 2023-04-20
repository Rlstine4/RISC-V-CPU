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

        SAMPLE PATTERNS:

        PATTERN 1: 0 (decimal)

        IDX: 0, 0, 1023, 0

        PATTERN 2: 100 (decimal)

        IDX: 100, 0, 1023, 100

        PATTERN 3: 500

        IDX: 500, 500, 0, 1023

        PATTERN 4: 8096
        IDX: 928, 0, 1023, 928


*/

module bloom_filter(input clk, rst,
                    input [63:0] in_data,
                    output match,
                    output [63:0] matched_data
                    );

localparam NUM_OF_ADDRESSES = 1024;
localparam INDEX_BITS       = 10;

reg [63:0] prev_data;

//wire bloom_index_1;
wire [15:0] bloom_index_0, bloom_index_2, bloom_index_3;

wire bloom_value_0, bloom_value_1, bloom_value_2, bloom_value_3;

// NEEDS TESTING

always @(posedge clk)
begin

    if (rst)
    begin
        prev_data <= 64'b0;
    end

    prev_data <= in_data;
end



// Instantiate our Hash functions

mod_hash hash_0 (.data_in(in_data[15:0]), .hashed_value(bloom_index_0));


//knuth_hash  hash_1 (.data_in(in_data[31:16]), .hashed_value(bloom_index_1));


invert_hash hash_2 (.data_in(in_data[47:32]), .hashed_value(bloom_index_2));


XOR_hash hash_3 (.data_in_0(in_data[63:48]), .data_in_1(in_data[15:0]), .hashed_value(bloom_index_3));

// bloom_buffer_0 handles mod_hash and knuth_hash

bloom_buffer bloom_buffer_0(
	.clka(clk),
	.addra(bloom_index_0[INDEX_BITS-1:0]),
	.douta(bloom_value_0),
	.clkb(clk),
	.addrb(321),
	.doutb(bloom_value_1));

// bloom_buffer_1 handles invert hash and XOR hash

bloom_buffer bloom_buffer_1(
	.clka(clk),
	.addra(bloom_index_2[INDEX_BITS-1:0]),
	.douta(bloom_value_2),
	.clkb(clk),
	.addrb(bloom_index_3[INDEX_BITS-1:0]),
	.doutb(bloom_value_3)   );


assign match = (bloom_value_0  & bloom_value_1 & bloom_value_2 & bloom_value_3);

assign matched_data = (match) ? prev_data : 64'b0;


endmodule