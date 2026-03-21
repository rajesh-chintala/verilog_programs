
main module  
```

module sync_fifo
#(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)
(
    input clk,
    input rst,

    input wr_en,
    input rd_en,

    input [DATA_WIDTH-1:0] wr_data,

    output reg [DATA_WIDTH-1:0] rd_data,
    output full,
    output empty
);

localparam DEPTH = 1 << ADDR_WIDTH;

reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

reg [ADDR_WIDTH:0] wr_ptr;
reg [ADDR_WIDTH:0] rd_ptr;


always @(posedge clk or posedge rst)
begin
    if(rst)
        wr_ptr <= 0;

    else if(wr_en && !full)
    begin
        mem[wr_ptr[ADDR_WIDTH-1:0]] <= wr_data;
        wr_ptr <= wr_ptr + 1;
    end
end


always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        rd_ptr <= 0;
        rd_data <= 0;
    end

    else if(rd_en && !empty)
    begin
        rd_data <= mem[rd_ptr[ADDR_WIDTH-1:0]];
        rd_ptr <= rd_ptr + 1;
    end
end


assign empty = (wr_ptr == rd_ptr);

assign full =
    (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]) &&
    (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]);

endmodule


```

# Testbench
```
module sync_fifo_tb;

  parameter DATA_WIDTH = 8;
  parameter ADDR_WIDTH = 4;
  
  reg clk, rst, wr_en, rd_en;
  reg [DATA_WIDTH -1: 0] wr_data;
  
  wire [DATA_WIDTH-1:0] rd_data;
  wire full;
  wire empty;
  
  integer i;
  
  sync_fifo dut(
    .clk(clk),
    .rst(rst),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .wr_data(wr_data),
    .rd_data(rd_data),
    .full(full),
    .empty(empty)
  );
  
  always #5 clk = ~clk;
  
  initial begin
  	clk = 0;
    rst = 0;
    wr_en =0 ;
    rd_en = 0;
    
    #10;
    rst = 1;
    
    #10;
    rst  = 0;
    
    $display("Writing into the FIFO");
    
    for(i = 0; i<17; i =i+1)
      begin
        @(posedge clk)
        if(!full) begin
        wr_en = 1;
        wr_data = i;
          $display("Time=%0t wrote data = %0d is full = %0b", $time, wr_data, full);
        end
      end
    
    #50;
    
    $display("Reading the data");
    
    for(i = 0; i<=17; i= i+1)
      begin
        @(posedge clk)
        rd_en = 1;
        $display("Time=%0t read data = %0d", $time, rd_data);
      end
  
  
  #100;
  $finish;
  
  end
  
  initial begin
    $dumpfile("sync_tb.vcd");
    $dumpvars(0, sync_fifo_tb);
  end
endmodule

```

# Simulation Results

<img width="1639" height="875" alt="image" src="https://github.com/user-attachments/assets/cfafcc6c-f2a8-4bdf-9818-4ff0bb83cbf1" />
<img width="1644" height="879" alt="image" src="https://github.com/user-attachments/assets/7271e77f-950e-495a-9758-8155bdf19a1d" />  
write operation  
<img width="1637" height="879" alt="image" src="https://github.com/user-attachments/assets/65d3835a-ff2a-4cb8-9f8b-f122dd05c047" />  
read_operation  
<img width="1645" height="880" alt="image" src="https://github.com/user-attachments/assets/db7ab591-33ba-4eaf-9dae-ca8f5726ba56" />
both read_write
<img width="1636" height="882" alt="image" src="https://github.com/user-attachments/assets/507c35fb-8a8d-4138-8183-925e63d05cff" />
<img width="1647" height="878" alt="image" src="https://github.com/user-attachments/assets/52333a25-d682-43bf-9dd0-48ad3200cc89" />
<img width="1639" height="885" alt="image" src="https://github.com/user-attachments/assets/43c74664-b404-4c9c-ae00-e382c73e425a" />
<img width="1643" height="883" alt="image" src="https://github.com/user-attachments/assets/0f3e320d-440d-49eb-9171-22e7cb56eebd" />
<img width="1641" height="878" alt="image" src="https://github.com/user-attachments/assets/29cfc9c8-cf21-4168-b990-94a26a177fce" />
<img width="1644" height="887" alt="image" src="https://github.com/user-attachments/assets/5767e800-2d4f-448d-a9dd-a19b8001d9c2" />




