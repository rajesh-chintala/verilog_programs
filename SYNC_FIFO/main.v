module fifo_sync #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
) (
    input clk, rstn,

    input [DATA_WIDTH-1:0] wr_data,
    input wr_en,
    input rd_en,

    output reg [DATA_WIDTH-1:0] rd_data,
    output full, empty
);

localparam DEPTH = 1 << ADDR_WIDTH;

reg [DATA_WIDTH:0] fifo_mem [0:DEPTH-1];

reg [ADDR_WIDTH: 0] wr_ptr, rd_ptr;

always@(posedge clk or negedge rstn) begin
        if(!rstn) begin
            wr_ptr <= 0;
        end
        else if(wr_en && !full) begin
                fifo_mem[wr_ptr[ADDR_WIDTH-1:0]] <= wr_data;
                wr_ptr <= wr_ptr + 1;
            end
            else begin
                wr_ptr <= wr_ptr;
            end
        
end

always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
        rd_ptr <= 0;
        rd_data <= 0;
    end
    else if (rd_en && !empty) begin
        rd_data <= fifo_mem[rd_ptr[ADDR_WIDTH-1:0]];
        rd_ptr <= rd_ptr + 1;
    end
    else begin
        rd_ptr <= rd_ptr;
        rd_data <= rd_data;
    end
end

assign full = ({~wr_ptr[ADDR_WIDTH], wr_ptr[ADDR_WIDTH-1:0]} == rd_ptr);

assign empty = rd_ptr == wr_ptr;

endmodule
