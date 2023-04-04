module bloom_filter (input clk, rst, 
                     input  [63:0] data_in,
                     output reg match);


reg bloom_buffer [2000:0]; // Convert this to BLOCK RAM LATER

wire[63:0] hashed_value;

mod_hash hash_function(.data_in(data_in), .hashed_value(hashed_value));

integer idx;

always @(posedge clk)
begin

    if (rst)
    begin
        match = 0;

        for (idx = 0; idx < 2001; idx = idx + 1)
        begin
            bloom_buffer[idx] = 0;
        end

        bloom_buffer [1]  = 1;
        bloom_buffer [100] = 1;
    end

    else if (bloom_buffer [hashed_value] == 1)
    begin
        match = 1;
    end

    else
    begin
        match = 0;
    end


end


endmodule