// Code your design here
module bin2gray #(parameter WIDTH = 4)
(
input  [WIDTH:0] bin,
output [WIDTH:0] gray
);

assign gray = (bin >> 1) ^ bin;

endmodule

module gray_sync #(parameter WIDTH = 4)
(
input clk,
input rst,
input [WIDTH:0] gray_in,
output reg [WIDTH:0] gray_out
);

reg [WIDTH:0] sync_ff;

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        sync_ff  <= 0;
        gray_out <= 0;
    end
    else
    begin
        sync_ff  <= gray_in;
        gray_out <= sync_ff;
    end
end

endmodule

module fifo_mem
#(
parameter DATA_WIDTH = 8,
parameter ADDR_WIDTH = 4
)
(
input wr_clk,
input wr_en,
input [ADDR_WIDTH-1:0] wr_addr,
input [DATA_WIDTH-1:0] wr_data,

input rd_clk,
input rd_en,
input [ADDR_WIDTH-1:0] rd_addr,
output reg [DATA_WIDTH-1:0] rd_data
);

localparam DEPTH = (1<<ADDR_WIDTH);

reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

always @(posedge wr_clk)
begin
    if(wr_en)
        mem[wr_addr] <= wr_data;
end

always @(posedge rd_clk)
begin
    if(rd_en)
        rd_data <= mem[rd_addr];
end

endmodule

module write_pointer
#(
parameter ADDR_WIDTH = 4
)
(
input wr_clk,
input rst,
input wr_en,

input [ADDR_WIDTH:0] rd_ptr_gray_sync,

output reg [ADDR_WIDTH:0] wr_ptr_bin,
output [ADDR_WIDTH:0] wr_ptr_gray,
output full
);

wire [ADDR_WIDTH:0] wr_ptr_bin_next;
wire [ADDR_WIDTH:0] wr_ptr_gray_next;

assign wr_ptr_bin_next = wr_ptr_bin + (wr_en & ~full);

assign wr_ptr_gray = (wr_ptr_bin >> 1) ^ wr_ptr_bin;

assign wr_ptr_gray_next = (wr_ptr_bin_next >> 1) ^ wr_ptr_bin_next;

assign full = (wr_ptr_gray_next ==
              {~rd_ptr_gray_sync[ADDR_WIDTH:ADDR_WIDTH-1],
                rd_ptr_gray_sync[ADDR_WIDTH-2:0]});

always @(posedge wr_clk or posedge rst)
begin
    if(rst)
        wr_ptr_bin <= 0;
    else
        wr_ptr_bin <= wr_ptr_bin_next;
end

endmodule

module read_pointer
#(
parameter ADDR_WIDTH = 4
)
(
input rd_clk,
input rst,
input rd_en,

input [ADDR_WIDTH:0] wr_ptr_gray_sync,

output reg [ADDR_WIDTH:0] rd_ptr_bin,
output [ADDR_WIDTH:0] rd_ptr_gray,
output empty
);

wire [ADDR_WIDTH:0] rd_ptr_bin_next;

assign rd_ptr_bin_next = rd_ptr_bin + (rd_en & ~empty);

assign rd_ptr_gray = (rd_ptr_bin >> 1) ^ rd_ptr_bin;

assign empty = (rd_ptr_gray == wr_ptr_gray_sync);

always @(posedge rd_clk or posedge rst)
begin
    if(rst)
        rd_ptr_bin <= 0;
    else
        rd_ptr_bin <= rd_ptr_bin_next;
end

endmodule


module async_fifo
#(
parameter DATA_WIDTH = 8,
parameter ADDR_WIDTH = 4
)
(
input wr_clk,
input rd_clk,
input rst,

input wr_en,
input rd_en,

input [DATA_WIDTH-1:0] wr_data,
output [DATA_WIDTH-1:0] rd_data,

output full,
output empty
);

wire [ADDR_WIDTH:0] wr_ptr_bin;
wire [ADDR_WIDTH:0] wr_ptr_gray;

wire [ADDR_WIDTH:0] rd_ptr_bin;
wire [ADDR_WIDTH:0] rd_ptr_gray;

wire [ADDR_WIDTH:0] wr_ptr_gray_sync;
wire [ADDR_WIDTH:0] rd_ptr_gray_sync;

fifo_mem #(DATA_WIDTH,ADDR_WIDTH) mem_inst(
.wr_clk(wr_clk),
.wr_en(wr_en & ~full),
.wr_addr(wr_ptr_bin[ADDR_WIDTH-1:0]),
.wr_data(wr_data),

.rd_clk(rd_clk),
.rd_en(rd_en & ~empty),
.rd_addr(rd_ptr_bin[ADDR_WIDTH-1:0]),
.rd_data(rd_data)
);

write_pointer #(ADDR_WIDTH) wr_ptr(
.wr_clk(wr_clk),
.rst(rst),
.wr_en(wr_en),
.rd_ptr_gray_sync(rd_ptr_gray_sync),
.wr_ptr_bin(wr_ptr_bin),
.wr_ptr_gray(wr_ptr_gray),
.full(full)
);

read_pointer #(ADDR_WIDTH) rd_ptr(
.rd_clk(rd_clk),
.rst(rst),
.rd_en(rd_en),
.wr_ptr_gray_sync(wr_ptr_gray_sync),
.rd_ptr_bin(rd_ptr_bin),
.rd_ptr_gray(rd_ptr_gray),
.empty(empty)
);

gray_sync #(ADDR_WIDTH) sync_r2w(
.clk(wr_clk),
.rst(rst),
.gray_in(rd_ptr_gray),
.gray_out(rd_ptr_gray_sync)
);

gray_sync #(ADDR_WIDTH) sync_w2r(
.clk(rd_clk),
.rst(rst),
.gray_in(wr_ptr_gray),
.gray_out(wr_ptr_gray_sync)
);

endmodule


// Code your testbench here
// or browse Examples
`timescale 1ns/1ps

module tb_async_fifo;

parameter DATA_WIDTH = 8;
parameter ADDR_WIDTH = 4;

reg wr_clk;
reg rd_clk;
reg rst;

reg wr_en;
reg rd_en;

reg [DATA_WIDTH-1:0] wr_data;

wire [DATA_WIDTH-1:0] rd_data;

wire full;
wire empty;


async_fifo #(DATA_WIDTH, ADDR_WIDTH) dut
(
    .wr_clk(wr_clk),
    .rd_clk(rd_clk),
    .rst(rst),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .wr_data(wr_data),
    .rd_data(rd_data),
    .full(full),
    .empty(empty)
);




/* Write clock generation */

always #5 wr_clk = ~wr_clk;   // 10ns period




/* Read clock generation */

always #8 rd_clk = ~rd_clk;   // 16ns period




integer i;

initial
begin

wr_clk = 0;
rd_clk = 0;
rst = 1;

wr_en = 0;
rd_en = 0;
wr_data = 0;



#20;
rst = 0;



/* Write Data into FIFO */

$display("Writing data into FIFO");

for(i = 0; i < 10; i = i + 1)
begin
    @(posedge wr_clk);

    if(!full)
    begin
        wr_en = 1;
        wr_data = i;
        $display("Time=%0t WRITE DATA=%0d", $time, wr_data);
    end
end

@(posedge wr_clk);
wr_en = 0;



#50;


/* Start Reading */

$display("Reading data from FIFO");

for(i = 0; i < 10; i = i + 1)
begin
    @(posedge rd_clk);

    if(!empty)
    begin
        rd_en = 1;
        $display("Time=%0t READ DATA=%0d", $time, rd_data);
    end
end

@(posedge rd_clk);
rd_en = 0;



#100;

$finish;

end




/* Waveform dump */

initial
begin
$dumpfile("fifo.vcd");
$dumpvars(0,tb_async_fifo);
end

endmodule
