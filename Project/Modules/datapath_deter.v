`timescale 1ns/1ps

module datapath_deter 
   #(
      parameter DATA_WIDTH = 64,
      parameter CTRL_WIDTH = DATA_WIDTH/8,
      parameter UDP_REG_SRC_WIDTH = 2
   )
   (
      input  [DATA_WIDTH-1:0]             in_data,
      input  [CTRL_WIDTH-1:0]             in_ctrl,
      input                               in_wr,
      output                              in_rdy,

      output [DATA_WIDTH-1:0]             out_data,
      output [CTRL_WIDTH-1:0]             out_ctrl,
      output                              out_wr,
      input                               out_rdy,
      
      // --- Register interface
      input                               reg_req_in,
      input                               reg_ack_in,
      input                               reg_rd_wr_L_in,
      input  [`UDP_REG_ADDR_WIDTH-1:0]    reg_addr_in,
      input  [`CPCI_NF2_DATA_WIDTH-1:0]   reg_data_in,
      input  [UDP_REG_SRC_WIDTH-1:0]      reg_src_in,

      output                              reg_req_out,
      output                              reg_ack_out,
      output                              reg_rd_wr_L_out,
      output  [`UDP_REG_ADDR_WIDTH-1:0]   reg_addr_out,
      output  [`CPCI_NF2_DATA_WIDTH-1:0]  reg_data_out,
      output  [UDP_REG_SRC_WIDTH-1:0]     reg_src_out,

      // misc
      input                                reset,
      input                                clk
   );
   
   // Define the log2 function
   // `LOG2_FUNC

   //------------------------- Signals-------------------------------
   
   wire [DATA_WIDTH-1:0]         in_fifo_data;
   wire [CTRL_WIDTH-1:0]         in_fifo_ctrl;

   wire                          in_fifo_nearly_full;
   wire                          in_fifo_empty;

   wire                           in_fifo_rd_en;
   reg                           out_wr_int;

   // software registers 
   wire [31:0]                   pattern_high;
   wire [31:0]                   pattern_low;
   wire [31:0]                   ids_cmd;
   wire [31:0]                   dmem_index_c1;
   wire [31:0]                   dmem_data_high_c1;
   wire [31:0]                   dmem_data_low_c1;
   wire [31:0]                   dmem_index_c2;
   wire [31:0]                   dmem_data_high_c2;
   wire [31:0]                   dmem_data_low_c2;

   // hardware registers
   reg [31:0]                    matches;
   reg [31:0]                    dmem_value_high_c1;
   reg [31:0]                    dmem_value_low_c1;
   reg [31:0]                    dmem_value_high_c2;
   reg [31:0]                    dmem_value_low_c2;

   wire [63:0]dmem_out_c1, dmem_out_c2;

   // internal state
   wire [1:0]                     state, state_next;
   reg [31:0]                    matches_next;
   reg                           in_pkt_body, in_pkt_body_next;
   reg                           end_of_pkt, end_of_pkt_next;
   reg                           begin_pkt, begin_pkt_next;
   reg [2:0]                     header_counter, header_counter_next;
   reg                           counter;

   wire  core1_busy, core2_busy, core1_enable, core2_enable, core1_ready, core2_ready, core1_match, core2_match;
   wire matcher_match;
   wire match_0, match_1, match_2, match_3, match_4, match_5, match_6, match_7;
   //wire [63:0] matched_data 
   wire [63:0] core1_data, core2_data;
   reg [63:0] matched_data, matched_data_0, matched_data_1, matched_data_2, matched_data_3, matched_data_4, matched_data_5, matched_data_6, matched_data_7;

   // local parameter
   parameter                     START = 2'b00;
   parameter                     HEADER = 2'b01;
   parameter                     PAYLOAD = 2'b10;

 
   //------------------------- Local assignments -------------------------------

   assign in_rdy     = !in_fifo_nearly_full;
   assign matcher_en = in_pkt_body;
   assign matcher_ce = (!in_fifo_empty && out_rdy);
   assign matcher_reset = (reset || ids_cmd[0] || end_of_pkt);

   assign matcher_match = match_0 | match_1 | match_2 | match_3 | match_4 | match_5 | match_6 | match_7; // Bitwise OR all the match signals

   //------------------------- Modules-------------------------------

   fallthrough_small_fifo #(
      .WIDTH(CTRL_WIDTH+DATA_WIDTH),
      .MAX_DEPTH_BITS(2)
   ) input_fifo (
      .din           ({in_ctrl, in_data}),   // Data in
      .wr_en         (in_wr),                // Write enable
      .rd_en         (in_fifo_rd_en),        // Read the next word 
      .dout          ({in_fifo_ctrl, in_fifo_data}),
      .full          (),
      .nearly_full   (in_fifo_nearly_full),
      .empty         (in_fifo_empty),
      .reset         (reset),
      .clk           (clk)
   );

// Logic for byte alignment

reg  [63:0]in_data_p;
wire [119:0]packet;

assign packet = {in_data[55:0], in_data_p[63:0]};

always @(posedge clk)
begin
    in_data_p <= in_data;
end

// What if multiple patterns in packet.. What if 1 pattern is false positive, other is true positive.. 

always @(*)
begin

    if(match_0)
    begin 
    matched_data = matched_data_0;
    end

    else if (match_1)
    begin
        matched_data = matched_data_1;
    end

    else if (match_2)
    begin
        matched_data = matched_data_2;
    end

    else if (match_3)
    begin
        matched_data = matched_data_3;
    end

    else if (match_4)
    begin
        matched_data = matched_data_4;
    end

    else if (match_5)
    begin
        matched_data = matched_data_5;
    end

    else if (match_6)
    begin
        matched_data = matched_data_6;
    end

    else if (match_7)
    begin
        matched_data = matched_data_7;
    end


end

   
   // detect7B matcher (
   //    .ce            (matcher_ce),           // data enable
   //    .match_en      (matcher_en),           // match enable
   //    .clk           (clk),
   //    .pipe1         ({in_ctrl, in_data}),   // Data in
   //    .hwregA        ({pattern_high, pattern_low}),   // pattern in
   //    .match         (matcher_match),        // match out
   //    .mrst          (matcher_reset)         // reset in
   // );

   //simple_matcher matcher(.clk(clk), .in_data(in_fifo_data), .pattern({pattern_high, pattern_low}), .match(matcher_match), .matched_data(matched_data));

   /****************************************************** BLOOM FILTERS ****************************************************************/

   bloom_filter filter_0 (.clk(clk), .rst(rst), .in_data(packet[63:0]), .match(match_0), .matched_data());

   bloom_filter filter_1 (.clk(clk), .rst(rst), .in_data(packet[71:8]), .match(match_1), .matched_data());

   bloom_filter filter_2 (.clk(clk), .rst(rst), .in_data(packet[79:16]), .match(match_2), .matched_data());

   bloom_filter filter_3 (.clk(clk), .rst(rst), .in_data(packet[87:24]), .match(match_3), .matched_data());

   bloom_filter filter_4 (.clk(clk), .rst(rst), .in_data(packet[95:32]), .match(match_4), .matched_data());

   bloom_filter filter_5 (.clk(clk), .rst(rst), .in_data(packet[103:40]), .match(match_5), .matched_data());

   bloom_filter filter_6 (.clk(clk), .rst(rst), .in_data(packet[111:48]), .match(match_6), .matched_data());

   bloom_filter filter_7 (.clk(clk), .rst(rst), .in_data(packet[119:56]), .match(match_7), .matched_data());

   core_manager cm(.clk(clk),                      .rst(reset),                  .match(matcher_match && state == (PAYLOAD)), 	
                     .matched_data(matched_data),	.core1_busy(~core1_ready),   	.core2_busy(~core2_ready),    
                     .core1_enable(core1_enable),	.core2_enable(core2_enable),	.core1_data(core1_data),		
                     .core2_data(core2_data)
                     );
        
   datapath data_path_1(.clk(clk),                                         .rst(reset),              
                        .logicEn(1'b0),                                    .logicWe(1'b0),                      
                        .iMemWE(1'b0),                                     .memWE(ids_cmd[1]),      
                        .memAddr(dmem_index_c1),                           .logicAddr(14'd0),
                        .memInData({dmem_data_high_c1,dmem_data_low_c1}),  .memOutData(dmem_out_c1),
                        .logicData(),                                      .iMemAddr(9'd0),
                        .iMemInData(32'd0),                                .core_ready(core1_ready),
                        .core_enable(core1_enable),                        .in_data(core1_data),
						      .match(core1_match)
                        );

   datapath data_path_2(.clk(clk),                                         .rst(reset),              
                        .logicEn(1'b0),                                    .logicWe(1'b0),                      
                        .iMemWE(1'b0),                                     .memWE(ids_cmd[2]),      
                        .memAddr(dmem_index_c2),                           .logicAddr(14'd0),
                        .memInData({dmem_data_high_c2,dmem_data_low_c2}),  .memOutData(dmem_out_c2),
                        .logicData(),                                      .iMemAddr(9'd0),
                        .iMemInData(32'd0),                                .core_ready(core2_ready),
                        .core_enable(core2_enable),                        .in_data(core2_data),
						      .match(core2_match)
                        );

   // dropfifo drop_fifo (
   //    .clk           (clk), 
   //    .drop_pkt      (1'b0 && end_of_pkt), 
   //    .fiforead      (out_rdy), 
   //    .fifowrite     (out_wr_int), 
   //    .firstword     (begin_pkt), 
   //    .in_fifo       ({in_fifo_ctrl,in_fifo_data}), 
   //    .lastword      (end_of_pkt), 
   //    .rst           (reset), 
   //    .out_fifo      ({out_ctrl,out_data}), 
   //    .valid_data    (out_wr)
   // );

   special_fifo sp_fifo(
		.clk(clk),
		.drop_pkt(1'b0 && end_of_pkt),
		.fiforead(out_rdy),
		.in_fifo_empty(in_fifo_empty),
		.in_fifo_ctrl(in_fifo_ctrl),
		.in_fifo_data(in_fifo_data),
		.rst(reset),
		.out_fifo({out_ctrl,out_data}),
		.valid_data(out_wr),
		.in_fifo_rd_en(in_fifo_rd_en),      
		.fifo_state(state)
	);
   
   always@(posedge clk)
   begin
      if(core1_match || core2_match)
      begin
         matches <= matches + 1;
      end
   end
   always@(*)
   begin
      dmem_value_high_c1         <= dmem_out_c1[63:32];
      dmem_value_low_c1          <= dmem_out_c1[31:0];
      dmem_value_high_c2         <= dmem_out_c2[63:32];
      dmem_value_low_c2          <= dmem_out_c2[31:0];
   end

   generic_regs
   #( 
      .UDP_REG_SRC_WIDTH   (UDP_REG_SRC_WIDTH),
      .TAG                 (`DATAPATH_BLOCK_ADDR),          // Tag -- eg. MODULE_TAG
      .REG_ADDR_WIDTH      (`DATAPATH_REG_ADDR_WIDTH),     // Width of block addresses -- eg. MODULE_REG_ADDR_WIDTH
      .NUM_COUNTERS        (0),                 // Number of counters
      .NUM_SOFTWARE_REGS   (9),                 // Number of sw regs
      .NUM_HARDWARE_REGS   (5)                  // Number of hw regs
   ) module_regs (
      .reg_req_in       (reg_req_in),
      .reg_ack_in       (reg_ack_in),
      .reg_rd_wr_L_in   (reg_rd_wr_L_in),
      .reg_addr_in      (reg_addr_in),
      .reg_data_in      (reg_data_in),
      .reg_src_in       (reg_src_in),

      .reg_req_out      (reg_req_out),
      .reg_ack_out      (reg_ack_out),
      .reg_rd_wr_L_out  (reg_rd_wr_L_out),
      .reg_addr_out     (reg_addr_out),
      .reg_data_out     (reg_data_out),
      .reg_src_out      (reg_src_out),

      // --- counters interface
      .counter_updates  (),
      .counter_decrement(),

      // --- SW regs interface
      .software_regs    ({dmem_data_low_c2,dmem_data_high_c2,dmem_index_c2,dmem_data_low_c1,dmem_data_high_c1,dmem_index_c1,
                           ids_cmd,pattern_low,pattern_high}),

      // --- HW regs interface
      .hardware_regs    ({dmem_value_low_c2,dmem_value_high_c2,dmem_value_low_c1,dmem_value_high_c1,matches}),

      .clk              (clk),
      .reset            (reset)
    );

   //------------------------- Logic-------------------------------
   
   // always @(*) begin
   //    state_next = state;
   //    matches_next = matches;
   //    header_counter_next = header_counter;
   //    in_fifo_rd_en = 0;
   //    out_wr_int = 0;
   //    //out_data = 0;
   //    end_of_pkt_next = end_of_pkt;
   //    in_pkt_body_next = in_pkt_body;
   //    begin_pkt_next = begin_pkt;
      
   //    if (!in_fifo_empty && out_rdy) begin
   //       out_wr_int = 1;
   //       in_fifo_rd_en = 1;
   //       //out_data = in_fifo_data;
         
   //       case(state)
   //          START: begin
   //             if (in_fifo_ctrl != 0) begin
   //                state_next = HEADER;
   //                begin_pkt_next = 1;
   //                end_of_pkt_next = 0;   // takes matcher out of reset
   //             end
   //          end
   //          HEADER: begin
   //             begin_pkt_next = 0;
   //             if (in_fifo_ctrl == 0) begin
   //                header_counter_next = header_counter + 1'b1;
   //                if (header_counter_next == 3) begin
   //                  state_next = PAYLOAD;
   //                end
   //             end
   //          end
   //          PAYLOAD: begin
   //             if (in_fifo_ctrl != 0) begin
   //                state_next = START;
   //                header_counter_next = 0;
   //                if (matcher_match) begin
   //                   matches_next = matches + 1;
   //                end
   //                end_of_pkt_next = 1;   // will reset matcher
   //                in_pkt_body_next = 0;
   //             end
   //             else begin
   //                in_pkt_body_next = 1;
   //             end
   //          end
   //       endcase // case(state)
   //    end
   // end // always @ (*)
   
   // always @(posedge clk) begin
   //    if(reset) begin
   //       matches <= 0;
   //       header_counter <= 0;
   //       state <= START;
   //       begin_pkt <= 0;
   //       end_of_pkt <= 0;
   //       in_pkt_body <= 0;
   //    end
   //    else begin
   //       if (ids_cmd[0]) matches <= 0;
   //       else matches <= matches_next;
   //       header_counter <= header_counter_next;
   //       state <= state_next;
   //       begin_pkt <= begin_pkt_next;
   //       end_of_pkt <= end_of_pkt_next;
   //       in_pkt_body <= in_pkt_body_next;
   //       counter <= 0;
   //    end // else: !if(reset)
   // end // always @ (posedge clk)   


endmodule 