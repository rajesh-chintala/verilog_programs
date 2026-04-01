module tb_fifo_sync();

reg clk, rstn;
reg wr_en;
reg rd_en;
integer i, j;
reg [7:0] wr_data;
wire [7:0] rd_data;
wire full, empty;

fifo_sync dut(
    .clk(clk),
    .rstn(rstn),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .wr_data(wr_data),
    .rd_data(rd_data),
    .full(full),
    .empty(empty)
);

initial begin
    clk = 1;
    forever #5 clk = ~clk;
end

initial begin
    rstn = 1;
    wr_en = 0;
    rd_en = 0;
    i = 0;
    j = 0;

    #10;
    rstn = 0;
    #10;
    rstn = 1;

    //writing data into fifo
    for(i=0; i<20; i=i+1) begin
        @(posedge clk);
        wr_en=1;
        wr_data=i;
        $display("Writing %d at %d pointer",i,i);
    end

    @(posedge clk) wr_en = 0;

    //reading data from the fifo
    for(i=0; i< 20; i= i+1) begin
        @(posedge clk);
        rd_en = 1;
        $display("Read data at %d is %b",i,rd_data);
    end

    @(posedge clk) rd_en = 0;

    //Doing read and write at same time
    fork
        for(i = 0; i < 8; i = i+ 1) begin
            @(posedge clk)
            wr_en = 1;
            wr_data  = 15 -i;
        end

        for(j=0; j < 8; j = j + 1) begin
            @(posedge clk)
            rd_en = 1;
            $display("Read data %d, at %d",rd_data,i);
        end
    join

    #100;
     $finish;

end

endmodule
