// Revision to original mod hash

module knuth_hash #(parameter NUM_OF_ADDRESSES = 1024)
                (input [15:0] data_in ,
                output [15:0] hashed_value);

    assign hashed_value = (data_in * (data_in + 3)) % NUM_OF_ADDRESSES;


endmodule