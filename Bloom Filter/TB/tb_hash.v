module tb_hash;

reg [63:0] data_in;
wire [31:0] mod_output, shift_output, murmur_low_output, murmur_high_output;

wire [9:0] bloom_index_0, bloom_index_1, bloom_index_2, bloom_index_3;


mod_hash mod_hash_DUT(.data_in(data_in[31:0]), .hashed_value(mod_output));
shift_hash shift_hash_DUT(.data_in(data_in[31:0]), .hashed_value(shift_output));

murmur_hash murmur_low_DUT(.data_in(data_in[31:0]), .hashed_value(murmur_low_output));
murmur_hash murmur_high_DUT(.data_in(data_in[63:32]), .hashed_value(murmur_high_output));

assign bloom_index_0 = mod_output[9:0];
assign bloom_index_1 = shift_output[9:0];
assign bloom_index_2 = murmur_low_output[9:0];
assign bloom_index_3 = murmur_high_output[9:0];


initial begin
        $dumpfile("test.vcd");
        $dumpvars(0,tb_hash);
end

initial
begin

    data_in = 64'h0;

    #20

    data_in = 64'h574F524D484F4C45; // WORMHOLE

    #20 
    data_in = 64'h4445414442454546; // DEADBEEF

    #20
    data_in = 64'h464C41504A41434B; // FLAPJACK

    #20
    $finish;


end


endmodule