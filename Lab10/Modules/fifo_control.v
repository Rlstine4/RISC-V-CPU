// TODO: implement state machine. USE IDS.v AS REFERENCE

module fifo_control(input FIFO_EMPTY,
                    input FIFO_FULL,
                    input FIFO_ready,
                    input packet_wr_req,
                    input processor_req, // If packet is READY, then direct reads 
                    input in_ctrl,
                    output FIFO_read,
                    output FIFO_write);


reg [1:0]                     state, state_next;
reg                           in_pkt_body, in_pkt_body_next;
reg                           end_of_pkt, end_of_pkt_next;
reg                           begin_pkt, begin_pkt_next;
reg [2:0]                     header_counter, header_counter_next;
reg                           counter;


parameter IDLE      =  2'b00,
          HEADER    =  2'b01,
          DATA      =  2'b10;
          CPU_MODE  =  2'b11;


// FIFO_read.. should we read 

assign FIFO_write = (packet_wr_req && ~FIFO_FULL && FIFO_ready)  ? 1 : 0;
assign FIFO_read  = (processor_req && ~FIFO_EMPTY && FIFO_ready) ? 1 : 0;


// State memory and Next-state logic

/*
    NOTES: needs to keep track of first and last word ? (maybe reg variables)

    in_ctrl starts as 0
    as soon as in_ctrl = 1, then packet header has started
    as soon as in_ctrl 1 -> 0, then data has started
    as soon as in_ctrl 0 -> 1, then data is done

    ^^^^ This is all SYNCHRONOUS/CLOCKED

*/

always @(*)
begin

state_next = state;
FIFO_read  = 0;
FIFO_write = 0;
end_of_pkt_next = end_of_pkt;
in_pkt_body_next = in_pkt_body;
begin_pkt_next = begin_pkt;

    if (reset)
    begin 
         state <= START;
         begin_pkt <= 0;
         end_of_pkt <= 0;
         in_pkt_body <= 0;
    end

    if (packet_wr_req && ~FIFO_FULL)
    begin

        FIFO_write = 1;

        case (state)

        IDLE: 
        begin

            if (in_ctrl == 1)
            begin
                fifo_wr = 1;
                state = HEADER;
                begin_pkt_next = 1;
                end_of_pkt_next = 0;
            end

        end

        HEADER:
        begin
            begin_pkt_next = 0;
            if (in_ctrl == 0)
            begin
                state <= DATA;
                end_of_pkt_next = 1;   
                in_pkt_body_next = 0;
            end
            else
            begin
                in_pkt_body_next = 1;
            end
        end
        DATA:
        begin
            if (in_ctrl == 1)
            begin
                state <= IDLE;
            end
        end

        endcase

    end

end