`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/01/2025 05:53:39 PM
// Design Name: 
// Module Name: stage
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


module stage(
//wire signed [31:0]t0;   //absolute value of g, initial value of t
input wire [3:0] i,
input wire signed [31:0]a,x,y,z,t,   // a for change in angle for each iteration i.e., tan'(2^-i)
output wire  signed [31:0]xn,yn,zn,tn
);
wire dn;
reg d;



//assign t0[31:0] = (g[31]==0) ? g : (~g)+1;
assign dn = (y<t) ? 1'b1 : 1'b0;
assign xn = (dn) ? (x -( y>>i)) : (x +( y>>i));
assign yn = (dn) ? (y + (x>>i)) : (y - (x>>i));
assign zn = (dn) ? (z + a) : (z - a) ;
assign tn = t + (t>>(2*i + 1));

endmodule
