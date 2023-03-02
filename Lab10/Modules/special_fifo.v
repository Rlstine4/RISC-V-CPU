/*

    Description: This special FIFO will be placed in the MEM stage of our 5-stage pipeline. It can acts as both a FIFO or block RAM.
                 Essentially, this FIFO can buffer incoming packets AND be read at any point (if it's not being written to ) A control unit
                 decide when the FIFO is being read and when it is being written

    Ouput ports: 64-bit output to MEM/WB stage FF

    INPUTS:
            clk = synchronous negative-edge triggered FIFO
            rst = synchronous negative-edge triggered reset
            rd_req = Processor would like to read FIFO
            wr_req = Reference pipeline would like to write packets to FIFO
            data_in = 72 bit data in. 8 bits for control signals and 64 bits for data
            first_word = let fifo know where to set head
            last_word  = let fifo know that packet is fully buffered

    OUTPUTS:
            FIFO_FULL  = FIFO is full and cannot accept additional packets
            FIFO_EMPTY = FIFO is empty, meaning it cannot receive packets but cannot be read from
            ready_rd      = signal to processor that FIFO is ready to be read. Also, block additional requests from reference pipeline
            ready_wr      = signal to reference pipeline that packets can be buffered and block requests from processor
            data_out      = Grab 64 bits of data to feed into processor
            ctrl_out      = 8 bits of control signal (This may be necesary if packet needs to be sent back into output queue) ???
            //counter       = 8 bit counter to keep track of how many packets are in the FIFO. Useful for logic analyzer (prevent rollover)

*/


/* TODO

    1. Regenerate the IP Core. Depth = 256, data_width = 72 bits (our processor will grab 64-bits of data)



*/

module special_fifo(input clk 
                    input rst,
                    input fifo_rd,
                    input fifo_wr,
                    input [71:0] data_in,
                    input first_word,
                    input last_word,
                    output FIFO_FULL,
                    output FIFO_EMPTY,
                    output in_progress,
                    output [63:0] data_out
                    output  [7:0] control_out
                    );     
                    


reg [8:0] counter;
reg [7:0] write_ptr, read_ptr, packet_head_ptr; // Keep track of where we are writing, reading, and the head of the packet being buffered


assign FIFO_FULL   = (counter = 9'b011111111) ? 1 : 0; // Set FIFO_FULL to 1 if counter reaches maximum depth
assign FIFO_EMPTY  = (counter = 9'b0)         ? 1 : 0; // Set FIFO_EMPTY to 1 if counter is 0
assign in_progress = (fifo_rd || fifo_wr);

assign read_en    = (~FIFO_EMPTY && fifo_rd) ? 1 : 0; // Read only if FIFO not empty and fifo_rd signal
assign write_en   = (~FIFO_FULL  && fifo_wr) ? 1 : 0; // Write only if FIFO not full and fifo_wr signal


// TODO: Regenerate this IP Core to remove unnecessary function (2 input ports, 1 output port), then add write_en, read_en, data in and data out

Convertible_FIFO fifo_memory(.clka(clk), .dina(data_in), .addra(fifo_addr), .wea(write_en). .douta(), .clkb(clk), .dinb(), .addrb(head), .web(9'b0), .doutb());

always @(negedge clk)
begin

    if (rst)
    begin
        counter         <= 0;
        read_ptr        <= 0;
        write_ptr       <= 0;
        packet_head_ptr <= 0;
        ready_rd        <= 0;
        ready_wr        <= 1; // FIFO will be "empty", so write requests can be accepted
    end

    else if (first_word || last_word)
    begin
        packet_head_ptr <= write_ptr; // packet head can either be the beginning of the packet or the end of packet
    end

    else if (write_en && ~FIFO_FULL) // We are assuming that read_req cannot be HIGH at the same time as dictated by control unit
    begin
        write_ptr <= write_ptr + 1;
        counter   <= counter   + 1;
    end

    else if (read_en) // FIFO is being requested as READ and it is NOT EMPTY. 
    begin
        read_ptr <= read_ptr + 1;
        counter  <= counter  - 1;
    end



    
end


endmodule