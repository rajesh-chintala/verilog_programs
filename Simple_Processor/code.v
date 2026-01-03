`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/03/2026 04:15:45 PM
// Design Name: 
// Module Name: registers
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

module upcount (Clear, Clock, Q);
    input        Clear, Clock;
    output reg [1:0] Q;

    always @(posedge Clock)
        if (Clear)
            Q <= 2'b00;
        else
            Q <= Q + 1'b1;

endmodule


module regn (R, L, Clock, Q);
    parameter n = 8;

    input  [n-1:0] R;
    input          L, Clock;
    output reg [n-1:0] Q;

    always @(posedge Clock)
        if (L)
            Q <= R;

endmodule

module trin (Y, E, F);
    parameter n = 8;

    input  [n-1:0] Y;
    input          E;
    output wire [n-1:0] F;

    assign F = E ? Y : 'bz;

endmodule

module dec2to4 (W, En, Y);
    input  [1:0] W;
    input        En;
    output reg [0:3] Y;

    always @(W, En)
        case ({En, W})
            3'b100: Y = 4'b1000;
            3'b101: Y = 4'b0100;
            3'b110: Y = 4'b0010;
            3'b111: Y = 4'b0001;
            default: Y = 4'b0000;
        endcase

endmodule

module proc (Data, Reset, w, Clock, F, Rx, Ry, Done, BusWires);

    input  [7:0] Data;
    input        Reset, w, Clock;
    input  [1:0] F, Rx, Ry;
    output wire [7:0] BusWires;
    output       Done;

    reg  [0:3] Rin, Rout;
    reg  [7:0] Sum;

    wire Clear, AddSub, Extern, Ain, Gin, Gout, FRin;
    wire [1:0] Count;
    wire [0:3] T, I, Xreg, Y;
    wire [7:0] R0, R1, R2, R3, A, G;
    wire [1:6] Func, FuncReg;

    integer k;

    /*---------------- Timing Control ----------------*/
    upcount counter (Clear, Clock, Count);
    dec2to4 decT (Count, 1'b1, T);

    assign Clear = Reset | Done | (~w & T[0]);
    assign Func  = {F, Rx, Ry};
    assign FRin  = w & T[0];

    regn functionreg (Func, FRin, Clock, FuncReg);
        defparam functionreg.n = 6;

    dec2to4 decI (FuncReg[1:2], 1'b1, I);
    dec2to4 decX (FuncReg[3:4], 1'b1, Xreg);
    dec2to4 decY (FuncReg[5:6], 1'b1, Y);

    /*---------------- Control Signals ----------------*/
    assign Extern = I[0] & T[1];
    assign Done   = ((I[0] | I[1]) & T[1]) | ((I[2] | I[3]) & T[3]);
    assign Ain    = (I[2] | I[3]) & T[1];
    assign Gin    = (I[2] | I[3]) & T[2];
    assign Gout   = (I[2] | I[3]) & T[3];
    assign AddSub = I[3];

    /*---------------- Register Control ----------------*/
    always @(I, T, Xreg, Y)
        for (k = 0; k < 4; k = k + 1)
        begin
            Rin[k]  = ((I[0] | I[1]) & T[1] & Xreg[k]) |
                      ((I[2] | I[3]) & T[3] & Xreg[k]);

            Rout[k] = (I[1] & T[1] & Y[k]) |
                      ((I[2] | I[3]) & ((T[1] & Xreg[k]) |
                                        (T[2] & Y[k])));
        end

    /*---------------- Datapath ----------------*/
    trin tri_ext (Data, Extern, BusWires);

    regn reg_0 (BusWires, Rin[0], Clock, R0);
    regn reg_1 (BusWires, Rin[1], Clock, R1);
    regn reg_2 (BusWires, Rin[2], Clock, R2);
    regn reg_3 (BusWires, Rin[3], Clock, R3);

    trin tri_0 (R0, Rout[0], BusWires);
    trin tri_1 (R1, Rout[1], BusWires);
    trin tri_2 (R2, Rout[2], BusWires);
    trin tri_3 (R3, Rout[3], BusWires);

    regn reg_A (BusWires, Ain, Clock, A);

    /*---------------- ALU ----------------*/
    always @(AddSub, A, BusWires)
        if (!AddSub)
            Sum = A + BusWires;
        else
            Sum = A - BusWires;

    regn reg_G (Sum, Gin, Clock, G);
    trin tri_G (G, Gout, BusWires);

endmodule

