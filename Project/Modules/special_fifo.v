/*

    Description: This special FIFO will be placed in the MEM stage of our 5-stage pipeline. It can acts as both a FIFO or block RAM.
                 Essentially, this FIFO can buffer a single packet AND be read by the processor. A control unit (embedded in this module)
                 decides when the FIFO is being read and when it is being written

    Ouput ports: 64-bit output to MEM/WB stage FF (Data portion of the packet)

    How do we detect when a packet starts and ends?

    The CTRL bus is used for two purposes. The first is to distinguish module headers from each other (see next paragraph), and to determine the end of the packet. 
    The CTRL bus is non-zero for module headers and distinguishes module headers from each other when there are multiple module headers. When the actual packet received 
    starts after the module headers, the CTRL bus is reset to 0, and then at the last word of the packet, the CTRL lines will indicate which byte is the last byte in the 
    last word. This is done by setting a 1 in the position of the last byte. Note that the first byte of the packet is stored in the most significant byte position (byte 
    7, i.e. bits 63-56) of the first word of the packet, and so on. For example, if the last word has only 1 byte, then the last word will have the last byte in byte 7, 
    and the CTRL word associated with that DATA word is 0b10000000. On the other hand, if the last word has six valid bytes (i.e. packet length in bytes mod 8 = 6) then 
    the CTRL word that signifies the end-of-packet will be 0b00000100.

    The Rx Queues create a module header when they receive a packet and prepend it to the beginning of the packet. 
    The Rx queues store the length of the packet in bytes at the lowest 16 bits of the module header, the source port as a 
    binary-encoded number (port 0 is MAC port 0 and port 1 is CPU port 0, ...) in bits 16?31, and the packet length in 64-bit 
    words in bits 32?47. We call this module header the IOQ module header.


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

module special_fifo(
					input clk,
					input drop_pkt,
					input fiforead,
					//input firstword,
					input in_fifo_empty,
					input [7:0] in_fifo_ctrl,
					input [63:0] in_fifo_data,
					//input out_rdy,
					//input lastword,
					input rst,
					output [71:0] out_fifo,
					output reg valid_data,
					output reg in_fifo_rd_en,
					output [1:0]fifo_state
                    ); 
					
	parameter	START = 2'b00;
	parameter   HEADER = 2'b01;
	parameter   PAYLOAD = 2'b10;
	parameter   PROCESSOR = 2'b11;

	reg [1:0] state;
	reg [31:0] matches;
	reg begin_pkt, end_of_pkt;
	reg [2:0] header_counter;
	reg out_wr_int;
	
	reg [7:0] read_ptr, write_ptr, write_ptr_end_of_pkt;
	
	assign fifo_state = state;
	
	always@(*)
	begin
		if (!in_fifo_empty && fiforead)
		begin
			out_wr_int 		= 1'b1;
			in_fifo_rd_en 	= 1'b1;
		end
		else
		begin
			out_wr_int 		= 1'b0;
			in_fifo_rd_en 	= 1'b0;
		end
	end
	
	always@(posedge clk)
	begin
		if(rst)
		begin
			state 			<= 	START;
			begin_pkt 		<=	1'b0;
			end_of_pkt		<=	1'b0;
			header_counter 	<= 	1'b0;
			read_ptr		<=	1'b0;
			write_ptr		<=	1'b0;
			
		end
		else
		begin
			if(out_wr_int == 1'b1)
			begin
				write_ptr <= write_ptr + 1'b1;
			end
			
			if(end_of_pkt == 1'b1)
			begin
				write_ptr_end_of_pkt <= write_ptr;
			end
			
			if((fiforead == 1'b1) && (read_ptr != write_ptr) && (read_ptr != (write_ptr_end_of_pkt)))
			begin
				read_ptr <= read_ptr + 1'b1;
				valid_data	<= 1;
			end
			else
			begin
				read_ptr <= read_ptr;
				valid_data	<= 0;
			end
			
			case(state)
			
				START:
				begin
					if(in_fifo_ctrl != 0)
					begin
						state 		<= 	HEADER;
						begin_pkt 	<= 	1'b1;
						end_of_pkt 	<= 	1'b0;
					end
				end
				
				HEADER:
				begin
					begin_pkt	<=	1'b0;
					end_of_pkt 	<= 	1'b0;
					if (in_fifo_ctrl == 0) 
					begin
						header_counter <= header_counter + 1'b1;
						if (header_counter == 3) 
						begin
							state <= PAYLOAD;
						end
					end
				end
				
				PAYLOAD:
				begin
					if (in_fifo_ctrl != 0) 
					begin
						state 			<= 	START;
						header_counter	<= 	0;
						begin_pkt 		<= 	1'b0;
						end_of_pkt 		<= 	1'b1;
					end
				end
				
				PROCESSOR:
				begin
				end
				
			endcase
		end
	end
	
	
	
	Convertible_FIFO fifo_memory(.clka(clk), .dina({in_fifo_ctrl, in_fifo_data}), .addra(write_ptr), .wea(out_wr_int), .clkb(clk), .addrb(read_ptr), .doutb(out_fifo));

endmodule