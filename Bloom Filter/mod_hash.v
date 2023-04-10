// Assume bloom buffer is 16KB large, so 131,072 bits

module mod_hash(
                input [16:0] data_in ,
                output [16:0] hashed_value);

    localparam  NUM_OF_ADDRESSES = 131_072;

    assign hashed_value = data_in % NUM_OF_ADDRESSES;


endmodule