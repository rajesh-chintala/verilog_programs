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


module main(
input clk,reset,
input signed [31:0]g,
output reg signed [31:0]z_out,
output wire [7:0]an,
output [7:0]c
);
wire signed [31:0]t0;   //absolute value of g, initial value of t
reg signed [31:0]x[11:0],y[11:0],z[11:0], t[11:0];   // a for change in angle for each iteration i.e., tan'(2^-i)
wire signed [31:0]xn[11:0],yn[11:0],zn[11:0],tn[11:0];
reg clk1=0;
integer j =1;

wire [37:0]z_deg;
wire [11:0]zdd;

assign t0[31:0] = (g[31]==0) ? g : (~g)+1;

stage s0( 4'd1, 32'd497837830 , x[0], y[0], z[0], t[0], xn[0], yn[0], zn[0], tn[0]);
stage s1( 4'd2, 32'd263043837 , x[1], y[1], z[1], t[1], xn[1], yn[1], zn[1], tn[1]);
stage s2( 4'd3, 32'd133525159 , x[2], y[2], z[2], t[2], xn[2], yn[2], zn[2], tn[2]);
stage s3( 4'd4, 32'd67021687 , x[3], y[3], z[3], t[3], xn[3], yn[3], zn[3], tn[3]);
stage s4( 4'd5, 32'd33543516 , x[4], y[4], z[4], t[4], xn[4], yn[4], zn[4], tn[4]);
stage s5( 4'd6, 32'd16775851 , x[5], y[5], z[5], t[5], xn[5], yn[5], zn[5], tn[5]);
stage s6( 4'd7, 32'd8388438 , x[6], y[6], z[6], t[6], xn[6], yn[6], zn[6], tn[6]);
stage s7( 4'd8, 32'd4194283 , x[7], y[7], z[7], t[7], xn[7], yn[7], zn[7], tn[7]);
stage s8( 4'd9, 32'd2097150 , x[8], y[8], z[8], t[8], xn[8], yn[8], zn[8], tn[8]);
stage s9( 4'd10, 32'd1048576 , x[9], y[9], z[9], t[9], xn[9], yn[9], zn[9], tn[9]);
stage s10( 4'd11, 32'd524288 , x[10], y[10], z[10], t[10], xn[10], yn[10], zn[10], tn[10]);
stage s11( 4'd12, 32'd262144 , x[11], y[11], z[11], t[11], xn[11], yn[11], zn[11], tn[11]);

always@(posedge clk or negedge reset) begin
t[0]<=t0;
t[1] <= tn[0];
t[2] <= tn[1];
t[3] <= tn[2];
t[4] <= tn[3];
t[5] <= tn[4];
t[6] <= tn[5];
t[7] <= tn[6];
t[8] <= tn[7];
t[9] <= tn[8];
t[10] <= tn[9];
t[11] <= tn[10];

x[0]<=32'd764356231;
x[1] <= xn[0];
x[2] <= xn[1];
x[3] <= xn[2];
x[4] <= xn[3];
x[5] <= xn[4];
x[6] <= xn[5];
x[7] <= xn[6];
x[8] <= xn[7];
x[9] <= xn[8];
x[10] <= xn[9];
x[11] <= xn[10];

y[0]<=32'd764356231;
y[1] <= yn[0];
y[2] <= yn[1];
y[3] <= yn[2];
y[4] <= yn[3];
y[5] <= yn[4];
y[6] <= yn[5];
y[7] <= yn[6];
y[8] <= yn[7];
y[9] <= yn[8];
y[10] <= yn[9];
y[11] <= yn[10];

z[0]<=32'd843314857;
z[1] <= zn[0];
z[2] <= zn[1];
z[3] <= zn[2];
z[4] <= zn[3];
z[5] <= zn[4];
z[6] <= zn[5];
z[7] <= zn[6];
z[8] <= zn[7];
z[9] <= zn[8];
z[10] <= zn[9];
z[11] <= zn[10];

end

always@(z[11])
begin
    if(g[31]==1) begin
        z_out <= (~z[11]) + 1;
    end
    else z_out <= z[11];
end

always@(posedge clk)
begin
    if(j==50000000 || !reset)
    begin
        j <= 1;
        clk1 <= ~clk1;
    end
    else j <= j + 1;
end

rad_to_deg r1(z_out, z_deg);
bintobcd b1(z_deg,zdd);
display d2(clk,reset,{z_out[31],zdd},an,c);
endmodule

module rad_to_deg(
input signed [31:0] rad_in, //SIFFFF...[18].
output reg signed [37:0] deg_out);//I[8]F[18]

reg signed [25:0] SCALE=26'd15019745; //(180/pi)*2^8
reg signed [57:0] temp; //i[10]f[26]
always@(*)
begin
temp<=rad_in*SCALE;  //1831000
deg_out<=temp>>>18;    //temp[33:8] i[8]f[18]
end 
endmodule


module bintobcd(x1,y1);
input signed [37:0] x1; //I[8]F[18]
output [11:0]  y1;

wire [7:0]x;
wire [37:0]temp;
reg [7:0]  y;

assign temp = (x1[37]==1) ? (~x1)+1: x1;
assign x = temp[37:30]; //I[8]
assign y1 = {y,1'b0,temp[29:27]}; //INT_BCD[8] FRAC_BCD[4]

always @(*)
begin 
if (x<10)
    y<=x;
else if (x>=10 && x<20)
    y<=x+6;
else if(x>=20 && x<30)
    y<=x+12;
else if(x>=30 && x<40)
    y<=x+18;
else if(x>=40 && x<50)
    y<=x+24;
else if(x>=50 && x<60)
    y<=x+30;
else if(x>=60 && x<70)
    y<=x+36;
else if (x>=70 && x<80)
    y <= x+42;
else if (x>=80 && x<90)
    y <= x+48;
else if (x>=90 && x<100)
    y<=x+54;
else 
    y<=x+60;
end
endmodule



module bcdToSegment(clk,bcd,segment);

input clk;
input [4:0]bcd;//isRadixPointEnabled BCD[4]
output reg [7:0]segment;

always@(posedge clk)
begin
    case(bcd)
    5'b00000: segment = 8'b00000011;
    5'b00001: segment = 8'b10011111;
    5'b00010: segment = 8'b00100101;
    5'b00011: segment = 8'b00001101;
    5'b00100: segment = 8'b10011001;
    5'b00101: segment = 8'b01001001;
    5'b00110: segment = 8'b01000001;
    5'b00111: segment = 8'b00011111;
    5'b01000: segment = 8'b00000001;
    5'b01001: segment = 8'b00011001;
    5'b01111: segment = 8'b11111101;//for negative sign
    5'b10000: segment = 8'b00000010;//now onwards enables radix point
    5'b10001: segment = 8'b10011110;
    5'b10010: segment = 8'b00100100;
    5'b10011: segment = 8'b00001100;
    5'b10100: segment = 8'b10011000;
    5'b10101: segment = 8'b01001000;
    5'b10110: segment = 8'b01000000;
    5'b10111: segment = 8'b00011110;
    5'b11000: segment = 8'b00000000;
    5'b11001: segment = 8'b00011000;
    default: segment = 8'b11111111;
    endcase
end
endmodule

module display(clk,reset,angle,an,c);
input clk,reset;
input [12:0]angle;//S INT_BCD[8] FRAC_BCD[4]
output [7:0]an;
output [7:0]c;


reg [7:0]anb;
reg clk1 = 1'b1 ;
integer i=1;

always@(posedge clk) begin
    if(i==50_000) begin
    i<=1;
    clk1<=~clk1;
    end
    else i<=i+1;
end

always@(posedge clk1 or negedge reset) begin
    if(anb == 8'b0000_1000 || (~reset && (anb ==8'b0000_0010)))
    anb <= 8'b0000_0001;
    else
    anb <= anb<<1;
end

assign an = ~anb;

reg [4:0]bcd;

always@(posedge clk1 or negedge reset) begin
if(~reset) bcd <= 5'd0;
case(an)
    8'b11101111:  bcd <= {1'b0,angle[3:0]};
    8'b11111110:  bcd <= {1'b1,angle[7:4]};
    8'b11111101:  bcd <= {1'b0,angle[11:8]};
    8'b11111011:  bcd <= {1'b0,3'b111,angle[12]};    
    default: bcd <= 5'b0;
endcase
end

bcdToSegment b(clk,bcd,c);

endmodule

