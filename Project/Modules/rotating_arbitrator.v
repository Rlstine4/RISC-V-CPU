module rotating_arbitrator(
                            input clk, rst, 
                            input [63:0] data_in,
                            input core_1_rdy,
                            input core_2_rdy,
                            output reg grant_1);


parameter IDLE      = 2'b00,
          CORE_1_RQ = 2'b01,
          CORE_2_RQ = 2'b10;

reg [1:0] state;

always @(posedge clk)
begin

    if(rst)
    begin
        state       <= CORE_1_RQ;
        grant_1     <= 1;
    end

end

always @(posedge clk)
begin

    case (state)


        CORE_1_RQ:
        begin
            state <= CORE_2_RQ;
        end

        CORE_2_RQ:
        begin
            state <= CORE_1_RQ;
        end
    endcase
end

always @(*)
begin

    case (state)

        CORE_1_RQ:
        begin
            if (~core_1_rdy && core_2_rdy)
            begin
                grant_1 = 0;
            end
            
            else
            begin
                grant_1 = 1;
            end
        end

        CORE_2_RQ:
        begin
            if (core_1_rdy && ~core_2_rdy)
            begin
                grant_1 = 1;
            end
            
            else
            begin
                grant_1 = 0;
            end
        end


    endcase

end


endmodule