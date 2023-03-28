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

module special_fifo #(parameter FIFO_WIDTH      = 72,						  
                      parameter DEPTH           = 512,
                      parameter PROCESSOR_WIDTH = 64,
                      parameter CTRL_WIDTH      = 8)
                     (
                        input clk, 
                        input rst,
                        input [CTRL_WIDTH-1:0] in_ctrl,
                        input [PROCESSOR_WIDTH-1:0] in_data,
                        input in_wr, fifo_rd,
                        output FIFO_FULL,
						output FIFO_NEARLY_FULL,
                        output FIFO_EMPTY,
						output reg [8:0] counter,
                        output reg FIFO_ready,						
                        output [CTRL_WIDTH-1:0] out_ctrl,
                        output [PROCESSOR_WIDTH-1:0] out_data
                    );     
                    

reg [1:0] state;
reg [2:0] header_counter;
// reg [8:0] counter; // 9-bit counter allows us to distinguish whether we are full or empty (Read pointer = Write Pointer)
reg [7:0] write_ptr, read_ptr; // Keep track of where we are writing, reading, and the head of the packet being buffered
// reg  fifo_wr;

assign FIFO_FULL   = ((write_ptr - read_ptr == 256) || (read_ptr - write_ptr == 256)) ? 1 : 0; // Set FIFO_FULL to 1 if counter reaches maximum depth
assign FIFO_EMPTY  = (write_ptr == read_ptr)       ? 1 : 0; // Set FIFO_EMPTY to 1 if counter is 0
assign FIFO_NEARLY_FULL   = ((write_ptr >  read_ptr)? ((write_ptr - read_ptr > 250)) : (read_ptr - write_ptr > 250));
// assign busy = (fifo_rd || fifo_wr)           ? 1 : 0;
// assign count = counter;

// assign read_en    = (~FIFO_EMPTY && fifo_rd) ? 1 : 0; // Read only if FIFO not empty and fifo_rd signal
// assign write_en   = (~FIFO_FULL  && fifo_wr) ? 1 : 0; // Write only if FIFO not full and fifo_wr signal


// 4 possible states

localparam IDLE           = 2'b00,
          HEADER         = 2'b01,
          PAYLOAD        = 2'b10,
          PROCESSOR_MODE = 2'b11;

always@(posedge clk)
begin
    if(rst)
    begin
        write_ptr       <=  0;
        read_ptr        <=  0;
        header_counter  <=  0;
        state           <=  IDLE;
        FIFO_ready      <=  0;
    end
    else
    begin
        case(state)

            IDLE:
            begin
                FIFO_ready  <=  0;
                if(in_ctrl != 0)
                begin
                    state <= HEADER;
                end
            end

            HEADER:
            begin
                if(in_ctrl == 0)
                begin
                    header_counter  <= header_counter + 1;
                    FIFO_ready      <=  0;
                    if (header_counter == 3) 
                    begin
                        state <= PAYLOAD;
                    end
                end
            end

            PAYLOAD:
            begin
                header_counter  <= 0;
                write_ptr       <=  write_ptr + 1; 
                FIFO_ready      <=  0;
                if(in_ctrl != 0)
                begin
                    state       <= PROCESSOR_MODE;
                    FIFO_ready  <=  1;
                end
            end

            PROCESSOR_MODE:
            begin
                if(fifo_rd)
                begin
                    read_ptr    <=  read_ptr + 1;
                end
                if(FIFO_EMPTY)
                begin
                    state       <= IDLE;
                    FIFO_ready  <=  0;
                end
            end
        endcase
    end
end

Convertible_FIFO fifo_memory(.clka(clk), .dina({in_ctrl, in_data}), .addra(write_ptr), .wea(in_wr && state==PAYLOAD), .clkb(clk), .addrb(read_ptr), .enb(fifo_rd),
                                .doutb({out_ctrl,out_data}) );


//Control Logic

// always @(posedge clk)
// begin

//     if (rst)
//     begin
//         state  	<= IDLE;
//         //fifo_rd	<= 0;
//         fifo_wr 	<= 0;
// 		FIFO_ready  <= 0;
//     end

//     else
//     begin

//         case(state)

//             IDLE:
//             begin
//                 //fifo_rd   <= 0;
//                 fifo_wr   <= 0;

//                 if (in_ctrl != 0)
//                 begin  
//                     state  <= HEADER;
//                 end
//             end

//             HEADER:
//             begin
//                 fifo_wr <= 1'b1;
//                 if (in_ctrl == 0)
//                 begin
//                     state <= PAYLOAD;
//                 end

//             end

//             PAYLOAD:
//             begin

//                 if ((in_ctrl != 0) || FIFO_FULL) // Done buffering so allow processor to consume data
//                 begin
//                     state <= PROCESSOR_MODE;
//                     FIFO_ready <= 1'b1;
//                 end


//             end

//             PROCESSOR_MODE:
//             begin

//                 fifo_wr <= 0;
//                 //fifo_rd <= 1'b1;
//                 //prev_ctrl = in_ctrl;

//                 if (counter == 0 ) // READ ALL of the FIFO
//                 begin
//                     state <= IDLE;
// 					FIFO_ready <= 1'b0;
//                 end

//                 // SHOULD NEVER JUST WRITE DATA WITHOUT HEADER

//             end

//         endcase


//     end

// end


// // FIFO Logic

// always @(posedge clk)
// begin

//     //prev_ctrl <= in_ctrl;

//     if (rst)
//     begin
//         counter         <= 0;
//         read_ptr        <= 0;
//         write_ptr       <= 0;
//         packet_head_ptr <= 0;
		  
//     end

//     else if (write_en && ~FIFO_FULL && state == PAYLOAD) // We are assuming that read_req cannot be HIGH at the same time as dictated by control unit
//     begin
//         write_ptr <= write_ptr + 1;
//         counter   <= counter   + 1;
//     end

//     else if (read_en) // FIFO is being requested as READ and it is NOT EMPTY. 
//     begin
//         read_ptr <= read_ptr + 1;
//         counter  <= counter  - 1;
//     end

    
// end



endmodule