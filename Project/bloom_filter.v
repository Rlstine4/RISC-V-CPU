/*
    TODO:

        m = -n*ln(p) / (ln(2)^2) the number of bits need in bloom filter
        n: how many items you expect to have in your filter
        k =  m/n * ln(2) the number of hash functions

        Probablity of false positives: 0.7 * (m / n)

        1. Determine # of Bloom Filters
        2. Determine # of Hash Functions. What kind of HASH function.. SHA-256, MURMUR 3?
        3. Determine how to load filter_mem
        4. Determine timing (Pipeline ?)

*/

module bloom_filter(input clk, rst,
                    input [63:0] packet_data,
                    output match );


reg [63:0] filter_mem [999:0]; // TO BE REPLACED WITH BLOCK RAM


always @(posedge clk)
begin

    if (rst)
    begin
        filter_mem <= 0;
    end
    

    
end



endmodule