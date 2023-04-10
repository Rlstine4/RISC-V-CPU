// Revision to original mod hash

module XOR_hash 
                (input [15:0] data_in_0, data_in_1,
                output [15:0] hashed_value);

    
    assign hashed_value = data_in_0 ^ data_in_1;


endmodule