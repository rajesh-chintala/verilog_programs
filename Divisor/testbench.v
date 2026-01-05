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
wire [15:0] cout;
wire lt, gt, eq;
wire [15:0] mux_out;

division DP (
    .ldp(ldp), .ldb(ldb), .lda(lda), .ldc(ldc),
    .inc(inc), .sel(sel), .clk(clk),
    .data_in(data_in),
    .lt(lt), .gt(gt), .eq(eq),
    .mux_out(mux_out), .cout(cout)
);

controlpathD1 CP (
    .lt(lt), .gt(gt), .eq(eq),
    .start(start), .clk(clk),
    .ldp(ldp), .ldb(ldb), .lda(lda), .ldc(ldc),
    .inc(inc), .sel(sel), .done(done)
);

initial begin
clk = 0;
#6 start = 1'b1;
#500
$finish;
end

always #5 clk = ~clk;

initial begin
    #10 data_in = 16'd3;   // divisor
    #20 data_in = 16'd4;  // dividend
end

initial begin
    $monitor($time,
        " Remainder=%d Quotient=%d",
        mux_out, cout);
end

endmodule

