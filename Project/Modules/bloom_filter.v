/*
    Description: Bloom Filter v3 

        64'h574F524D484F4C45; // WORMHOLE
        64'h4445414442454546; // DEADBEEF
        64'h464C41504A41434B; // FLAPJACK


*/

module bloom_filter(input clk, rst,
                    input [63:0] in_data,
                    output match,
                    output [63:0] matched_data
                    );

localparam NUM_OF_ADDRESSES = 65536;
localparam INDEX_BITS       = 16;

reg [63:0] prev_data;

//wire bloom_index_1;
wire [31:0] bloom_index_0, bloom_index_2, bloom_index_3;

wire bloom_value_0, bloom_value_1, bloom_value_2, bloom_value_3;


always @(posedge clk)
begin

    if (rst)
    begin
        prev_data <= 64'b0;
    end

    prev_data <= in_data;
end



// Instantiate our Hash functions

mod_hash hash_0 (.data_in(in_data[31:0]), .hashed_value(bloom_index_0));

shift_hash hash_1(.data_in(in_data[31:0]), .hashed_value(bloom_index_1));

murmur_hash hash_2(.data_in(in_data[31:0]), .hashed_value(bloom_index_2));

murmur_hash hash_3(.data_in(in_data[63:32]), .hashed_value(bloom_index_3));


// bloom_buffer_0 handles mod_hash and knuth_hash

bloom_buffer bloom_buffer_0(
	.clka(clk),
	.addra(bloom_index_0[INDEX_BITS-1:0]),
	.douta(bloom_value_0),
	.clkb(clk),
	.addrb(bloom_index_1[INDEX_BITS-1:0]),
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