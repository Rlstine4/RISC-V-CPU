module simple_matcher(input [63:0] data_in,
                      input [63:0] pattern,
                      output reg match);


if (data_in == pattern)
begin
    match = 1;
end

else
begin
    match = 0;
end


endmodule