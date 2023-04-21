module shift_hash(input [31:0] data_in, output [31:0] hashed_value );

assign hashed_value = data_in << 1;

endmodule