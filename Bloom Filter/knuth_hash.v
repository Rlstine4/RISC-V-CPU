// Revision to original mod hash

module knuth_hash(input [16:0] data_in ,
                output [16:0] hashed_value);

    
    localparam  NUM_OF_ADDRESSES = 131_072;

    assign hashed_value = (data_in * (data_in + 3)) % NUM_OF_ADDRESSES;


endmodule