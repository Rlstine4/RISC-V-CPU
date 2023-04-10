// Assume bloom buffer is 16KB large, so 131,072 bits

module mod_hash #(parameter NUM_OF_ADDRESSES)
                (
                input [15:0] data_in ,
                output [15:0] hashed_value);

    assign hashed_value = data_in % NUM_OF_ADDRESSES;


endmodule

