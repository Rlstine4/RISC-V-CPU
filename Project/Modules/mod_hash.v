module mod_hash(
                input [63:0] data_in ,
                output [63:0] hashed_value);

    parameter NUM_OF_ADDRESSES = 2001;

    assign hashed_value = data_in % NUM_OF_ADDRESSES;


endmodule