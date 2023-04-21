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
                output [31:0] hashed_value);

    wire [31:0] step_1, step_2, step_3, step_4;

    assign step_1 = data_in ^ (data_in >> 16);

    assign step_2 = step_1 * 32'h85ebca6b;

    assign step_3 = step_2 ^ (step_2 >> 13);

    assign step_4 = step_3 * 32'hc2b2ae35;

    assign hashed_value = step_4 ^ (step_4 >> 16);
    

endmodule


