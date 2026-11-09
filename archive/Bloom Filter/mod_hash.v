// Assume bloom buffer is 16KB large, so 131,072 bits

module mod_hash 
                (
                input [31:0] data_in ,
                output [31:0] hashed_value);

    assign hashed_value = data_in % 65536;


endmodule

