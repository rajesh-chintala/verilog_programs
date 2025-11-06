`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/05/2025 08:02:03 PM
// Design Name: 
// Module Name: stage_tb
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
reg [31:0]g;
wire [31:0]z_out;
wire [7:0]an;
wire [7:0]c;

main dut(.clk(clk),.reset(reset),.g(g),.z_out(z_out),.an(an), .c(c));

initial begin
    clk = 1'b0;
    forever #5 clk =~clk;
end

initial begin
 	g = 32'd3221225472;
	#10 g = 32'd3257812338;
	#10 g = 32'd3365079600;
	#10 g = 32'd3535717172;
	#10 g = 32'd3758096385;
	#10 g = 32'd4017062463;
	#10 g = 32'd0;
	#10 g = 32'd277904834;
	#10 g = 32'd536870912;
	#10 g = 32'd759250125;
	#10 g = 32'd929887697;
	#10 g = 32'd1037154959;
	#10 g = 32'd1073741824;
	#10 g = 32'd1;
	end
endmodule
