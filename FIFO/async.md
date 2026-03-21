# code:
```


// Code your design here
// Code your design here

module gray_sync
  #(parameter WIDTH = 4)
  (
    input clk, rst,
    input [WIDTH : 0]gray_in,
    output [WIDTH :0]gray_out
  );
  
  reg [WIDTH : 0] sync1, sync2;
  always@(posedge clk or posedge rst) begin
    if(rst) begin
      sync1 <= 0;
      sync2 <= 0;
    end
    else begin
      sync2 <= sync1;
      sync1 <= gray_in;
    end 
  end 
  
  assign gray_out = sync2;
  
endmodule

module fifo_mem #(
parameter DATA_WIDTH = 8,
parameter  ADDRESS_WIDTH = 4
)(

  input wr_clk, wr_en,
  input [ADDRESS_WIDTH-1 : 0] wr_addr,
  input [DATA_WIDTH -1 : 0] wr_data,
  
  input rd_clk, rd_en,
  input [ADDRESS_WIDTH-1 : 0] rd_addr,
  output reg [DATA_WIDTH -1 : 0] rd_data
);
  
  localparam DEPTH = (1<<ADDRESS_WIDTH);
  
  reg [DATA_WIDTH-1: 0] mem [ 0: DEPTH -1];
  
  always@(posedge wr_clk) begin
    if(wr_en) begin
  	    mem[wr_addr] <= wr_data;
  end
  end
    
    always@(posedge rd_clk)
      if(rd_en) 
        rd_data <= mem[rd_addr];
endmodule
    
module write_pointer
      #( parameter ADDR_WIDTH  = 4)
      (
        input wr_clk, rst, wr_en,
        input [ADDR_WIDTH :0] rd_ptr_gray_sync,
        
        output reg [ADDR_WIDTH: 0] wr_ptr_bin, 
        output [ADDR_WIDTH:0] wr_ptr_gray,
        output full
      );
      
  wire [ADDR_WIDTH:0] wr_ptr_bin_nxt;
  wire [ADDR_WIDTH : 0] wr_ptr_gray_nxt;
  
  assign wr_ptr_bin_nxt = wr_ptr_bin + (wr_en && !full);
      assign wr_ptr_gray = wr_ptr_bin ^ (wr_ptr_bin>>1);
      assign wr_ptr_gray_nxt = wr_ptr_bin_nxt ^ wr_ptr_bin_nxt>>1;
      
      always@(posedge wr_clk or posedge rst) begin
        if(rst)  
          wr_ptr_bin <= 0;
      else 
        	wr_ptr_bin <= wr_ptr_bin_nxt;
        end
      
      assign full = (wr_ptr_gray_nxt == {
        ~rd_ptr_gray_sync[ADDR_WIDTH: ADDR_WIDTH - 1], 						   		rd_ptr_gray_sync[ADDR_WIDTH - 2: 0]});
endmodule
    
module read_pointer
  #(parameter ADDR_WIDTH  = 4)
  (
    input rd_clk, rst, rd_en,
    input [ADDR_WIDTH:0] wr_ptr_gray_sync,
    
    output [ADDR_WIDTH: 0 ] rd_ptr_gray,
    output reg [ADDR_WIDTH : 0] rd_ptr_bin,
    output empty
  );
  
  wire [ADDR_WIDTH : 0] rd_ptr_bin_nxt;
  
  assign rd_ptr_bin_nxt = rd_ptr_bin + (rd_en && ~empty);
  
  assign rd_ptr_gray = (rd_ptr_bin >>1 ) ^ rd_ptr_bin;
  
  always@(posedge rd_clk or posedge rst) begin
    if( rst) rd_ptr_bin <= 0;
    else 	rd_ptr_bin <= rd_ptr_bin_nxt;
  end
  
  assign empty = (rd_ptr_gray == wr_ptr_gray_sync);
  
endmodule
    
module async_fifo
  #(parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
   )
  (
    input wr_clk, rd_clk,
    input rst,
    input wr_en, rd_en,
    input [DATA_WIDTH - 1: 0]  wr_data,
    
    output [DATA_WIDTH -1: 0] rd_data,
    output full, empty
  );
  
  wire [ADDR_WIDTH: 0] wr_ptr_bin, rd_ptr_bin;
  wire [ADDR_WIDTH: 0] wr_ptr_gray_sync, rd_ptr_gray_sync;
  wire [ADDR_WIDTH:0] wr_ptr_gray, rd_ptr_gray;
  
  fifo_mem mem(
    .wr_clk(wr_clk), 
    .wr_en(wr_en & ~full),
    .wr_addr(wr_ptr_bin[ADDR_WIDTH - 1:0]),
    .wr_data(wr_data),
    
    .rd_clk(rd_clk),
    .rd_en(rd_en && ~empty),
    .rd_addr(rd_ptr_bin[ADDR_WIDTH - 1:0]),
    .rd_data(rd_data)
  );
  
  write_pointer wr_ptr(
    .wr_clk(wr_clk),
    .rst( rst),
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
```

# Testbench

```

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




//Write clock generation 

always #5 wr_clk = ~wr_clk;   // 10ns period




// Read clock generation 

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



// Write Data into FIFO 

$display("Writing data into FIFO");

for(i = 0; i < 17; i = i + 1)
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


// Start Reading 

$display("Reading data from FIFO");

for(i = 0; i < 17; i = i + 1)
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

end




// Waveform dump 

initial
begin
$dumpfile("fifo.vcd");
$dumpvars(0,tb_async_fifo);
end

endmodule
```

# Simulation stuck at
<img width="1645" height="922" alt="image" src="https://github.com/user-attachments/assets/6a9baf82-d9bf-4a2f-9f42-41cc1757b1b2" />
