module invert_hash(input [16:0] data_in ,
                output [16:0] hashed_value);

    
    assign hashed_value = ~data_in;


endmodule