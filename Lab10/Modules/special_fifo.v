module special_fifo(input clk, rst, write_en,
                    input first_word,
                    input last_word,
                    input [63:0] fifo_in
                    output reg [63:0]fifo_out
                    output FIFO_FULL, empty);       
                    

reg [8:0] counter;
reg [8:0] write_ptr, read_ptr, packet_head; // Keep track of where we are writing, reading, and the head of the packet being buffered

// TODO: REMOVE write-enable by regenerating the IP Core. Need to allow processor to access FIFO

assign FIFO_FULL = (counter = 9'b111111111) ? 1 : 0;
assign empty     = (counter = 9'b0)         ? 1 : 0;





Convertible_FIFO fifo_memory(.clka(clk), .dina(fifo_data_in), .addra(fifo_addr), .wea(write_en). .douta(), .clkb(clk), .dinb(), .addrb(head), .web(9'b0), .doutb());

always @(posedge clk)
begin

    if (rst)
    begin
        counter     <= 0;
        write_ptr   <= 0;
        read_ptr    <= 0;
        packet_head <= 0;
    end

    else if (!FIFO_FULL && write_en)
    begin
        counter <= counter + 1;
    end
    

    
end


endmodule