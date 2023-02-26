module special_fifo_datapath(input [8:0] SRAM_addr,
                             input [63:0] FIFO_input,
                             input [63:0] SRAM_data_in);

reg [8:0] head, tail; // Addresses of head and tail of the FIFO
reg fifo_addr;
wire addr_sel;

always @(*)
begin
    if (addr_sel)
    begin
        fifo_addr = SRAM_addr;
    end
    else
    begin
        fifo_addr = tail;
    end

end


Convertible_FIFO special_fifo(.clka(clk), .dina(), .addra(fifo_addr), .wea(). .douta(), .clkb(clk), .dinb(), .addrb(head), .web(), .doutb())
	


endmodule;