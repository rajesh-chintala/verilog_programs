`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/05/2026 10:31:39 PM
// Design Name: 
// Module Name: tb_divisor
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module div_tb;

reg  [15:0] data_in;
reg  clk, start;
wire done;
wire [15:0] bout;
wire lt, gt, eq;
wire [15:0] w;

division DP (
    .ldp(ldp), .lda(lda), .ldb(ldb), .ldc(ldc),
    .inc(inc), .sel(sel), .clk(clk),
    .data_in(data_in),
    .lt(lt), .gt(gt), .eq(eq),
    .w(w), .bout(bout)
);

controlpathD1 CP (
    .ldb(ldb), .lda(lda), .ldp(ldp), .ldc(ldc),
    .inc(inc), .sel(sel), .done(done),
    .lt(lt), .gt(gt), .eq(eq),
    .start(start), .clk(clk)
);

initial clk = 0;
always #5 clk = ~clk;

initial begin
    start = 0;
    data_in = 0;
    #10 data_in = 16'd4;   // divisor
    #10 data_in = 16'd25;  // dividend
    #10 start = 1;
    #200 $finish;
end

initial begin
    $monitor($time,
        " Remainder=%d Quotient=%d",
        w, bout);
end

endmodule

