// TODO: implement state machine. USE IDS.v AS REFERENCE

module fifo_control(input FIFO_EMPTY,
                    input FIFO_FULL,
                    input packet_wr_req,
                    input processor_req, // If packet is READY, then direct reads 
                    input in_ctrl,
                    output reg FIFO_read,
                    output reg FIFO_write);


reg [3:0] state;

parameter IDLE   =  2'b00,
          HEADER =  2'b01,
          DATA   =  2'b10;
         

              

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

    if (packet_wr_req && ~FIFO_FULL)
    begin

        case (state)

        IDLE: 
        begin

            if (in_ctrl == 1)
            begin
                state <= HEADER;
            end

        end
       

        HEADER:
        begin
            if (in_ctrl == 0)
            begin
                state <= DATA;
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

// Output Function Logic (Fill in control singals needed in MEM stage (muxes and FIFO write, etc))

// Need a MUX ctrl to select between FIFO and D-MEM. Also need MUX ctrl to select between output queues and MEM/WB Pipeline reg

// IF we select output queues, we should try not to send incomplete/bad data.. It's possible for this lab we omit this 

always @(*)
begin

    if (packet_wr_req && ~FIFO_FULL)
    begin

        case (state)
        
            IDLE:
                //do something

            HEADER:
                //allow writes ? Maybe queues them in this control unit ?

            DATA:
                // allow writes ?

        

        endcase

    end


end

endmodule