module crc_tb;

reg clk, rst, crc_en;
reg [63:0] data_in;
wire [31:0] crc_out;

crc crc_dut(.clk(clk), .rst(rst), .crc_en(crc_en), .data_in(data_in), .crc_out(crc_out) );

parameter PERIOD = 20;


always 
    #(PERIOD/2) clk = ~clk;
initial
    clk = 0;

initial
begin

    $dumpfile("test.vcd");
    $dumpvars(0,crc_tb);

    rst = 1;
    crc_en = 1;
    data_in = 64'h0;

    #100
    rst = 0;

    #100

    rst = 1;

    #100

    rst = 0;
    data_in = 64'h0;

    #100

    data_in = 64'd20;
    
    #100

    $finish;

end


endmodule