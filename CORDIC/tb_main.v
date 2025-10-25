`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.09.2025 17:33:08
// Design Name: 
// Module Name: TB
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

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.09.2025 17:33:08
// Design Name: 
// Module Name: TB
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

module tb_stage();
reg clk,reset;
reg [29:0]g;
wire [29:0]z_out;
wire [7:0]an;
wire [7:0]c;

stage dut(.clk(clk),.reset(reset),.g(g),.z_out(z_out),.an(an), .c(c));

initial begin
    clk = 1'b0;
    forever #5 clk =~clk;
end

initial begin
    reset = 1'b1;

    g = 30'd0;//0 -> 0 deg
    reset = 1'b0;
    #10 reset = 1'b1;

    #190;
    g = 30'h8_000000;//0.5 -> 30 deg
    reset = 1'b0;
    #10 reset = 1'b1;

    #190
    g = 30'hb_504f34;//0.707 -> 45 degrees
    reset = 1'b0;
    #10 reset = 1'b1;
    
    #190;
    g = 30'hd_db3d75;//0.8660 -> 60 degrees
    reset = 1'b0;
    #10 reset = 1'b1;

     #190;
    g = 30'h1_0000000;//1 -> 90 degrees
    reset = 1'b0;
    #10 reset = 1'b1;
    
     #190;
    g = 30'h3_0000000;//-1 -> -90 degrees
    reset = 1'b0;
    #10 reset = 1'b1;
 
      #190;
    g = 30'h3_4afb0cd;//-0.707 -> -45 degrees
    reset = 1'b0;
    #10 reset = 1'b1;   

    #300 $finish;
    
    #10 reset = 1'b0;
    #10 reset =1'b1;
end

endmodule
/*
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.09.2025 17:33:08
// Design Name: 
// Module Name: TB
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

module tb_stage();
reg clk,reset;
reg [19:0]g;
wire [19:0]z_out;
wire [7:0]an;
wire [7:0]c;

stage dut(.clk(clk),.reset(reset),.g(g),.z_out(z_out),.an(an), .c(c));

initial begin
    clk = 1'b0;
    forever #5 clk =~clk;
end

initial begin
    reset = 1'b1;

    g = 20'd0;//0 -> 0 deg
    reset = 1'b0;
    #10 reset = 1'b1;

    #190;
    g = 20'h2_0000;//0.5 -> 30 deg
    reset = 1'b0;
    #10 reset = 1'b1;

    #190
    g = 20'h2_D414;//0.707 -> 45 degrees
    reset = 1'b0;
    #10 reset = 1'b1;
    
    #190;
    g = 20'h3_76d0;//0.8660 -> 60 degrees
    reset = 1'b0;
    #10 reset = 1'b1;

     #190;
    g = 20'h4_0000;//1 -> 90 degrees
    reset = 1'b0;
    #10 reset = 1'b1;
    
     #190;
    g = 20'hC_0000;//-1 -> -90 degrees
    reset = 1'b0;
    #10 reset = 1'b1;
 
      #190;
    g = 20'hd_2bed;//-0.707 -> -45 degrees
    reset = 1'b0;
    #10 reset = 1'b1;   

    #300 $finish;
    
    #10 reset = 1'b0;
    #10 reset =1'b1;
end

endmodule

  */

