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
input clk,reset,
input signed [29:0]g,
output reg signed [29:0]z_out,
output wire [7:0]an,
output [7:0]c
);
wire signed [29:0]t0;   //absolute value of g, initial value of t
reg signed [29:0]a,x,y,z,t;   // a for change in angle for each iteration i.e., tan'(2^-i)
integer i=1;
wire signed [29:0]xn,yn,zn,tn;
wire dn;
reg d;
reg clk1=0;

integer j =1;

wire [35:0]z_deg;
wire [11:0]zdd;

assign t0[29:0] = (g[29]==0) ? g : (~g)+1;
assign dn = (y<t) ? 1'b1 : 1'b0;
assign xn = (dn) ? (x -( y>>i)) : (x +( y>>i));
assign yn = (dn) ? (y + (x>>i)) : (y - (x>>i));
assign zn = (dn) ? (z + a) : (z - a) ;
assign tn = t + (t>>(2*i + 1));

always@(*)
begin
    case(i)
1 : a = 30 'd 124459458 ;
2 : a = 30 'd 65760960 ;
3 : a = 30 'd 33381290 ;
4 : a = 30 'd 16755422 ;
5 : a = 30 'd 8385879 ;
6 : a = 30 'd 4193963 ;
7 : a = 30 'd 2097110 ;
8 : a = 30 'd 1048571 ;
9 : a = 30 'd 524288 ;
10 : a = 30 'd 262144 ;
11 : a = 30 'd 131072 ;
12 : a = 30 'd 65536 ;
    default: a = 30'd0;
    endcase
end

always@(posedge clk or negedge reset)
begin
    if(!reset)
    begin 
        z <= 30'd210828715;
        t <= t0;
        x <= 30'd191089058;
        y <= 30'd191089058;
        d <= dn;
        i <= 1;
    end
    else begin
    x <= xn;
    y <= yn;
    z <= zn;
    t <= tn;
     d <= dn;
    i <= i + 1;
    end
end

always@(z)
begin
    if(g[29]==1) begin
        z_out <= (~z) + 1;
    end
    else z_out <= z;
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
input signed [29:0] rad_in, //SIFFFF...[18].
output reg signed [35:0] deg_out);//I[8]F[18]

localparam signed [25:0] SCALE=26'd15019745; //(180/pi)*2^8
reg signed [55:0] temp; //i[10]f[26]
always@(*)
begin
temp<=rad_in*SCALE;  //1831000
deg_out<=temp>>>18;    //temp[33:8] i[8]f[18]
end 
endmodule


module bintobcd(x1,y1);
input signed [35:0] x1; //I[8]F[18]
output [11:0]  y1;

wire [7:0]x;
wire [35:0]temp;
reg [7:0]  y;

assign temp = (x1[35]==1) ? (~x1)+1: x1;
assign x = temp[35:28]; //I[8]
assign y1 = {y,1'b0,temp[27:25]}; //INT_BCD[8] FRAC_BCD[4]

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


/*
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
input clk,reset,
input signed [19:0]g,
output reg signed [19:0]z_out,
output wire [7:0]an,
output [7:0]c
);
wire signed [19:0]t0;   //absolute value of g, initial value of t
reg signed [19:0]a,x,y,z,t;   // a for change in angle for each iteration i.e., tan'(2^-i)
integer i=1;
wire signed [19:0]xn,yn,zn,tn;
wire dn;
reg d;
reg clk1=0;

integer j =1;

wire [25:0]z_deg;
wire [11:0]zdd;

assign t0[19:0] = (g[19]==0) ? g : (~g)+1;
assign dn = (y<t) ? 1'b1 : 1'b0;
assign xn = (dn) ? (x -( y>>i)) : (x +( y>>i));
assign yn = (dn) ? (y + (x>>i)) : (y - (x>>i));
assign zn = (dn) ? (z + a) : (z - a) ;
assign tn = t + (t>>(2*i + 1));

always@(*)
begin
    case(i)
    1: a = 20'd121543;
    2: a = 20'd64220;
    3: a = 20'd32599;
    4: a = 20'd16363;
    5: a = 20'd8190;
    6: a = 20'd4096;
    7: a = 20'd2048;
    8: a = 20'd1024;
    9: a = 20'd512;
    10: a = 20'd256;
    11: a = 20'd128;
    12: a = 20'd64;
    default: a = 10'd0;
    endcase
end

always@(posedge clk1 or negedge reset)
begin
    if(!reset)
    begin 
        z <= 20'd205888;
        t <= t0;
        x <= 20'd186611;
        y <= 20'd186611;
        d <= dn;
        i <= 1;
    end
    else begin
    x <= xn;
    y <= yn;
    z <= zn;
    t <= tn;
     d <= dn;
    i <= i + 1;
    end
end

always@(z)
begin
    if(g[19]==1) begin
        z_out <= (~z) + 1;
    end
    else z_out <= z;
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
display d2(clk,reset,{z_out[19],zdd},an,c);
endmodule

module rad_to_deg(
input signed [19:0] rad_in, //SIFFFF...[18].
output reg signed [25:0] deg_out);//I[8]F[18]

localparam signed [15:0] SCALE=16'd14648; //(180/pi)*2^8
reg signed [35:0] temp; //i[10]f[26]
always@(*)
begin
temp<=rad_in*SCALE;  //1831000
deg_out<=temp>>>8;    //temp[33:8] i[8]f[18]
end 
endmodule


module bintobcd(x1,y1);
input signed [25:0] x1; //I[8]F[18]
output [11:0]  y1;

wire [7:0]x;
wire [25:0]temp;
reg [7:0]  y;

assign temp = (x1[25]==1) ? (~x1)+1: x1;
assign x = temp[25:18]; //I[8]
assign y1 = {y,1'b0,temp[17:15]}; //INT_BCD[8] FRAC_BCD[4]

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
*/
