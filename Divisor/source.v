`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/05/2026 09:38:54 PM
// Design Name: 
// Module Name: source
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
module PIPO (
    output reg [15:0] dout,
    input  [15:0] din,
    input  ld, clr, clk
);
always @(posedge clk) begin
    if (clr)
        dout <= 16'b0;
    else if (ld)
        dout <= din;
end
endmodule

module add (
    output [15:0] out,
    input  [15:0] in1, [15:0] in2
);
assign out = in1 + in2;
endmodule

module compare (
  input  [15:0] in1, in2,
    output reg lt, gt, eq
);
always @(*) begin
    if (in1 > in2) begin
        gt = 1'b1; lt = 1'b0; eq = 1'b0;
    end
    else if (in1 < in2) begin
        gt = 1'b0; lt = 1'b1; eq = 1'b0;
    end
    else begin
        gt = 1'b0; lt = 1'b0; eq = 1'b1;
    end
end
endmodule

module mux (
  input  [15:0] in1, in2,
    input  sel,
    output [15:0] out
);
assign out = sel ? in2 : in1;
endmodule

module sub (
    input  [15:0] in1, in2,
    output [15:0] out
);
assign out = in1 - in2;
endmodule

module cntrup (
    output reg [15:0] dout,
    input  [15:0] din,
    input  ldc,  clk,  inc
);
always @(posedge clk) begin
    if (ldc)
        dout <= din;
    else if (inc)
        dout <= dout + 1;
end
endmodule

module division (
    input  ldp, lda, ldb, ldc, inc, sel, clk, 
    input  [15:0] data_in,
    output lt, gt, eq,
    output [15:0] w, bout
);

wire [15:0] dividend, divisor, acc, sub_out;

assign w = sel ? acc : dividend;

PIPO reg_divisor (divisor, data_in, ldb, 1'b0, clk);
PIPO reg_dividend(dividend, data_in, ldp, 1'b0, clk);
PIPO reg_acc     (acc, sub_out, lda, 1'b0, clk);

compare cmp (w, divisor, lt, gt, eq);
sub s1 (w, divisor, sub_out);
cntrup quotient (bout, 16'b0, ldc, clk, inc);

endmodule

module controlpathD1 (
    output reg ldb,  lda, ldp, ldc inc, sel, done,
    input  lt,  gt,  eq,  start,  clk
);

reg [2:0] state;

parameter s0 = 3'd0,
          s1 = 3'd1,
          s2 = 3'd2,
          s3 = 3'd3,
          s4 = 3'd4,
          s5 = 3'd5,
          s6 = 3'd6,
          s7 = 3'd7;

always @(posedge clk) begin
    case (state)
        s0: if (start) state <= s1;
        s1: state <= s2;
        s2: state <= s3;
        s3: state <= s4;
        s4: state <= s5;
        s5: state <= s6;
        s6: state <= gt ? s4 : s7;
        s7: state <= s7;
        default: state <= s0;
    endcase
end

always @(*) begin
    {ldb, lda, ldp, ldc, inc, sel, done} = 7'b0;

    case (state)
        s0: ldc = 1;
        s1: ldb = 1;
        s2: ldp = 1;
        s3: lda = 1;
        s4: begin lda = 1; sel = 1; inc = 1; end
        s7: done = 1;
    endcase
end

endmodule
