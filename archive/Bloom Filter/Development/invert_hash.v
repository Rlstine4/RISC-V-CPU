module invert_hash
                (input [15:0] data_in ,
                output [15:0] hashed_value);

    
    assign hashed_value = ~data_in;


endmodule