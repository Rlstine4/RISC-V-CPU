module mod_hash_tb;

reg [63:0] data_in;
wire [63:0] hashed_value;

mod_hash mod_hash_dut(.data_in(data_in), .hashed_value(hashed_value));

initial begin
    
    data_in = 64'd0;
    $dumpfile("test.vcd");
    $dumpvars(0,mod_hash_tb);

    #10

    data_in = 64'd1;

    #10

    data_in = 64'd100;

    #10

    data_in = 64'd1;

    #10

    $finish;

end


endmodule