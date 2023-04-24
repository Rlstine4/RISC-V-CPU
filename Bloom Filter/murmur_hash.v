/*

ALGORITHM: 

data ^= data >> 16;
data *= 0x85ebca6b;
data ^= data >> 13;
data *= 0xc2b2ae35;
data ^= data >> 16;

*/

module murmur_hash
                (input [31:0] data_in ,
                output [15:0] hashed_value);

    assign hashed_value = (data_in & 32'h0000ffff) ^  ((data_in & 32'hffff0000) >> 16);


    

endmodule


