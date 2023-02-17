///////////////////////////////////////////////////////////////////////////////
// vim:set shiftwidth=3 softtabstop=3 expandtab:
// $Id: module_template 2008-03-13 gac1 $
//
// Module: ids.v
// Project: NF2.1
// Description: Defines a simple ids module for the user data path.  The
// modules reads a 64-bit register that contains a pattern to match and
// counts how many packets match.  The register contents are 7 bytes of
// pattern and one byte of mask.  The mask bits are set to one for each
// byte of the pattern that should be included in the mask -- zero bits
// mean "don't care".
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module passthrough_ids 
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
   
   //software register
   wire[31:0] input_high;
   wire[31:0] input_low;
   
   
   //hardware register
   reg[31:0] input_reversed_high;
   reg[31:0] input_reversed_low;
   
   
   wire [DATA_WIDTH-1:0] in_data_wire;
   wire [CTRL_WIDTH-1:0] in_ctrl_wire;
   wire in_wr_wire;
   wire out_rdy_wire;
   
   
   assign in_data_wire = in_data;
   assign in_ctrl_wire = in_ctrl;
   assign in_wr_wire = in_wr;
   assign out_rdy_wire = out_rdy;
   
   assign out_data = in_data_wire;
   assign out_ctrl = in_ctrl_wire;
   assign out_wr = in_wr_wire;
   assign in_rdy = out_rdy_wire;
   
   generic_regs
   #( 
      .UDP_REG_SRC_WIDTH   (UDP_REG_SRC_WIDTH),
      .TAG                 (`IDS_BLOCK_ADDR),          // Tag -- eg. MODULE_TAG
      .REG_ADDR_WIDTH      (`IDS_REG_ADDR_WIDTH),     // Width of block addresses -- eg. MODULE_REG_ADDR_WIDTH
      .NUM_COUNTERS        (0),                 // Number of counters
      .NUM_SOFTWARE_REGS   (2),                 // Number of sw regs
      .NUM_HARDWARE_REGS   (2)                  // Number of hw regs
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

      // // --- counters interface
      .counter_updates  (),
      .counter_decrement(),

      // --- SW regs interface
      .software_regs    ({input_low,input_high}),

      // --- HW regs interface
      .hardware_regs    ({input_reversed_low,input_reversed_high}),

      .clk              (clk),
      .reset            (reset)
    );
	
	always@(*)
	begin
		input_reversed_high[31:24] = input_low[7:0];
		input_reversed_high[23:16] = input_low[15:8];
		input_reversed_high[15:8] = input_low[23:16];
		input_reversed_high[7:0] = input_low[31:24];
		input_reversed_low[31:24] = input_high[7:0];
		input_reversed_low[23:16] = input_high[15:8];
		input_reversed_low[15:8] = input_high[23:16];
		input_reversed_low[7:0] = input_high[31:24];
	end

endmodule 
