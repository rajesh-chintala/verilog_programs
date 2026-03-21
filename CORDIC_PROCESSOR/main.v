`timescale 1ns / 1ps

module cordic_math_processor(

input clk,
input reset,
input start,

input [2:0] opcode,       // function select
input [31:0] data_in,

output reg [31:0] result1,
output reg [31:0] result2,
output reg done

);


//--------------------------------------------------
// Internal wires
//--------------------------------------------------

wire [31:0] sqrt_out;
wire sqrt_done;

wire signed [31:0] ln_out;
wire ln_done;

wire signed [31:0] exp_out;
wire exp_done;

wire signed [31:0] sinh_out;
wire signed [31:0] cosh_out;
wire hyp_done;


//--------------------------------------------------
// Module Instantiations
//--------------------------------------------------

// SQRT
cordic_sqrt U1(

.clk(clk),
.reset(reset),
.start(start & (opcode==3'b000)),
.n_in(data_in),

.sqrt_out(sqrt_out),
.done(sqrt_done)

);


// LN
cordic_ln U2(

.clk(clk),
.reset(reset),
.start(start & (opcode==3'b001)),
.n_in(data_in),

.ln_out(ln_out),
.done(ln_done)

);


// EXP
cordic_exp U3(

.clk(clk),
.reset(reset),
.start(start & (opcode==3'b010)),
.angle_in(data_in),

.exp_out(exp_out),
.done(exp_done)

);


// HYPERBOLIC
cordic_hyperbolic U4(

.clk(clk),
.reset(reset),
.start(start & (opcode==3'b011)),
.angle_in(data_in),

.sinh(sinh_out),
.cosh(cosh_out),

.done(hyp_done)

);


//--------------------------------------------------
// Result Selection Logic
//--------------------------------------------------

always @(posedge clk or negedge reset)
begin

if(!reset)
begin
result1 <= 0;
result2 <= 0;
done <= 0;
end

else begin

case(opcode)

3'b000:
begin
result1 <= sqrt_out;
result2 <= 0;
done <= sqrt_done;
end

3'b001:
begin
result1 <= ln_out;
result2 <= 0;
done <= ln_done;
end

3'b010:
begin
result1 <= exp_out;
result2 <= 0;
done <= exp_done;
end

3'b011:
begin
result1 <= sinh_out;
result2 <= cosh_out;
done <= hyp_done;
end

default:
begin
result1 <= 0;
result2 <= 0;
done <= 0;
end

endcase

end

end

endmodule


`timescale 1ns / 1ps

module cordic_math_processor_tb;

reg clk;
reg reset;
reg start;

reg [2:0] opcode;
reg [31:0] data_in;

wire [31:0] result1;
wire [31:0] result2;
wire done;


// Instantiate DUT

cordic_math_processor DUT(

.clk(clk),
.reset(reset),
.start(start),

.opcode(opcode),
.data_in(data_in),

.result1(result1),
.result2(result2),
.done(done)

);


// Clock generation

initial clk = 0;
always #5 clk = ~clk;


// Test sequence

initial begin

reset = 0;
start = 0;
opcode = 0;
data_in = 0;

#20
reset = 1;


// ------------------------------------------------
// Test 1 : SQRT
// sqrt(9) = 3
// ------------------------------------------------

opcode = 3'b000;
data_in = 32'd589824;   // 9 in Q16

#10 start = 1;
#10 start = 0;

@(posedge done);

$display("------ SQRT TEST ------");
$display("result = %d", result1);
$display("sqrt_real = %f", result1/65536.0);

#20;


// ------------------------------------------------
// Test 2 : LN
// ln(2) = 0.693
// ------------------------------------------------

opcode = 3'b001;
data_in = 32'd131072;   // 2 in Q16

#10 start = 1;
#10 start = 0;

@(posedge done);

$display("------ LN TEST ------");
$display("result = %d", result1);
$display("ln_real = %f", result1/65536.0);

#20;


// ------------------------------------------------
// Test 3 : EXP
// exp(0.5) ≈ 1.648
// ------------------------------------------------

opcode = 3'b010;
data_in = 32'd32768;    // 0.5 in Q16

#10 start = 1;
#10 start = 0;

@(posedge done);

$display("------ EXP TEST ------");
$display("result = %d", result1);
$display("exp_real = %f", result1/65536.0);

#20;


// ------------------------------------------------
// Test 4 : HYPERBOLIC
// sinh(0.5), cosh(0.5)
// ------------------------------------------------

opcode = 3'b011;
data_in = 32'd32768;   // 0.5

#10 start = 1;
#10 start = 0;

@(posedge done);

$display("------ HYPERBOLIC TEST ------");
$display("sinh = %d", result1);
$display("cosh = %d", result2);

$display("sinh_real = %f", result1/65536.0);
$display("cosh_real = %f", result2/65536.0);


#50
$stop;

end

endmodule

`timescale 1ns / 1ps

module cordic_sqrt(

input clk,
input reset,
input start,

input [31:0] n_in,

output reg [31:0] sqrt_out,
output reg done

);

parameter ITER = 16;
parameter Q16 = 32'd65536;
parameter Q16_DIV4 = 32'd16384;
parameter INV_KH = 32'd79141;

reg signed [47:0] x;
reg signed [47:0] y;
reg signed [47:0] z;

reg signed [47:0] x_next;
reg signed [47:0] y_next;
reg signed [47:0] z_next;

reg [5:0] i;
reg repeat4;

reg [4:0] k;
reg [47:0] sqrt_norm;

reg signed [31:0] atanh_table [0:16];

initial begin
atanh_table[0]=0;
atanh_table[1]=35999;
atanh_table[2]=16739;
atanh_table[3]=8235;
atanh_table[4]=4101;
atanh_table[5]=2049;
atanh_table[6]=1024;
atanh_table[7]=512;
atanh_table[8]=256;
atanh_table[9]=128;
atanh_table[10]=64;
atanh_table[11]=32;
atanh_table[12]=16;
atanh_table[13]=8;
atanh_table[14]=4;
atanh_table[15]=2;
atanh_table[16]=1;
end


reg [31:0] norm_in;
reg [4:0] k_comb;

integer j;

always @(*) begin

norm_in = n_in;
k_comb = 0;

for(j=0;j<16;j=j+1)
if(norm_in >= Q16)
begin
norm_in = norm_in >> 2;
k_comb = k_comb + 1;
end

for(j=0;j<16;j=j+1)
if(norm_in < Q16_DIV4)
begin
norm_in = norm_in << 2;
k_comb = k_comb - 1;
end

end


always @(posedge clk or negedge reset)
begin

if(!reset)
begin

x <= 0;
y <= 0;
z <= 0;

i <= 0;
repeat4 <= 0;

k <= 0;

sqrt_out <= 0;
sqrt_norm <= 0;

done <= 0;

end

else begin

if(start)
begin

// initialize vector
x <= $signed({16'd0,norm_in}) + Q16_DIV4;
y <= $signed({16'd0,norm_in}) - Q16_DIV4;
z <= 0;

i <= 1;
repeat4 <= 0;

k <= k_comb;

done <= 0;

end


else if(i <= ITER)
begin

if(y[47] == 0)
begin

x_next = x - (y >>> i);
y_next = y - (x >>> i);
z_next = z + {{16{atanh_table[i][31]}},atanh_table[i]};

end

else
begin

x_next = x + (y >>> i);
y_next = y + (x >>> i);
z_next = z - {{16{atanh_table[i][31]}},atanh_table[i]};

end

x <= x_next;
y <= y_next;
z <= z_next;

if(i==4 && repeat4==0)
begin
repeat4 <= 1;
i <= 4;
end
else
i <= i + 1;

end


else
begin

sqrt_norm <= (x * INV_KH) >> 16;
sqrt_out <= sqrt_norm << k;

done <= 1;

end

end

end

endmodule


TESTBENCH 



`timescale 1ns / 1ps

module cordic_sqrt_tb;

reg clk;
reg reset;
reg start;

reg [31:0] n_in;

wire [31:0] sqrt_out;
wire done;

cordic_sqrt DUT(

.clk(clk),
.reset(reset),
.start(start),

.n_in(n_in),

.sqrt_out(sqrt_out),
.done(done)

);

// clock
initial clk = 0;
always #5 clk = ~clk;


initial begin

reset = 0;
start = 0;
n_in = 0;

#20
reset = 1;

// Test: sqrt(4)
n_in = 32'd589824;

#10
start = 1;

#10
start = 0;

@(posedge done);

$display("sqrt_out = %d", sqrt_out);
$display("sqrt_real = %f", sqrt_out/65536.0);

#50
$stop;

end

endmodule

`timescale 1ns / 1ps

module cordic_ln(

input clk,
input reset,
input start,

input [31:0] n_in,

output reg signed [31:0] ln_out,
output reg done

);

parameter ITER = 16;
parameter Q16  = 32'd65536;
parameter LN2  = 32'd45426;

reg signed [47:0] x;
reg signed [47:0] y;
reg signed [47:0] z;

reg signed [47:0] x_next;
reg signed [47:0] y_next;
reg signed [47:0] z_next;

reg [5:0] i;
reg repeat4;

reg signed [31:0] shift_corr;

// lookup table
reg signed [31:0] atanh_table [0:16];

initial begin
atanh_table[0]  = 0;
atanh_table[1]  = 35999;
atanh_table[2]  = 16739;
atanh_table[3]  = 8235;
atanh_table[4]  = 4101;
atanh_table[5]  = 2049;
atanh_table[6]  = 1024;
atanh_table[7]  = 512;
atanh_table[8]  = 256;
atanh_table[9]  = 128;
atanh_table[10] = 64;
atanh_table[11] = 32;
atanh_table[12] = 16;
atanh_table[13] = 8;
atanh_table[14] = 4;
atanh_table[15] = 2;
atanh_table[16] = 1;
end


// --------------------------------------------------
// Argument reduction
// --------------------------------------------------

reg [31:0] norm_in;
reg signed [31:0] k;

integer j;

always @(*) begin

norm_in = n_in;
k = 0;

// reduce >2
for(j=0;j<32;j=j+1)
if(norm_in > (2*Q16)) begin
norm_in = norm_in >> 1;
k = k + 1;
end

// increase <0.5
for(j=0;j<32;j=j+1)
if(norm_in < (Q16>>1)) begin
norm_in = norm_in << 1;
k = k - 1;
end

end


// --------------------------------------------------
// CORDIC core
// --------------------------------------------------

always @(posedge clk or negedge reset)
begin

if(!reset)
begin

x <= 0;
y <= 0;
z <= 0;
i <= 0;

repeat4 <= 0;
shift_corr <= 0;

done <= 0;
ln_out <= 0;

end

else begin

if(start)
begin

// sign extension
x <= {{16{norm_in[31]}}, norm_in} + Q16;
y <= {{16{norm_in[31]}}, norm_in} - Q16;
z <= 0;

i <= 1;
repeat4 <= 0;

shift_corr <= $signed(k) * $signed(LN2);

done <= 0;

end


else if(i <= ITER)
begin

// vectoring mode

if(y[47] == 0)
begin
x_next = x - (y >>> i);
y_next = y - (x >>> i);
z_next = z + atanh_table[i];
end

else
begin
x_next = x + (y >>> i);
y_next = y + (x >>> i);
z_next = z - atanh_table[i];
end

x <= x_next;
y <= y_next;
z <= z_next;

// repeat iteration 4
if(i == 4 && repeat4 == 0)
begin
repeat4 <= 1;
i <= 4;
end
else
i <= i + 1;

end

else
begin

ln_out <= (z[31:0] <<< 1) + shift_corr;
done <= 1;

end

end

end

endmodule




TESTBENCH 



`timescale 1ns / 1ps

module cordic_ln_tb;

reg clk;
reg reset;
reg start;

reg [31:0] n_in;

wire signed [31:0] ln_out;
wire done;

cordic_ln DUT(

.clk(clk),
.reset(reset),
.start(start),

.n_in(n_in),

.ln_out(ln_out),
.done(done)

);


// clock
initial clk = 0;
always #5 clk = ~clk;


initial begin

reset = 0;
start = 0;
n_in = 0;

#20
reset = 1;

// test ln(2)
n_in = 32'd131072;

#10
start = 1;

#10
start = 0;

@(posedge done);

$display("ln_out = %d", ln_out);
$display("ln_real = %f", ln_out/65536.0);

#50
$stop;

end

endmodule

`timescale 1ns / 1ps

module cordic_exp(

input clk,
input reset,
input start,

input signed [31:0] angle_in,

output reg signed [31:0] exp_out,
output reg done

);

// exp(x) = sinh(x) + cosh(x)
// Q16.16 fixed point

parameter ITER = 16;

reg signed [47:0] x;
reg signed [47:0] y;
reg signed [47:0] z;

reg signed [47:0] x_next;
reg signed [47:0] y_next;
reg signed [47:0] z_next;

reg [5:0] i;
reg repeat4;

// Lookup table
reg signed [31:0] atanh_table [0:16];

initial begin
atanh_table[0]  = 0;
atanh_table[1]  = 35999;
atanh_table[2]  = 16739;
atanh_table[3]  = 8235;
atanh_table[4]  = 4101;
atanh_table[5]  = 2049;
atanh_table[6]  = 1024;
atanh_table[7]  = 512;
atanh_table[8]  = 256;
atanh_table[9]  = 128;
atanh_table[10] = 64;
atanh_table[11] = 32;
atanh_table[12] = 16;
atanh_table[13] = 8;
atanh_table[14] = 4;
atanh_table[15] = 2;
atanh_table[16] = 1;
end


always @(posedge clk or negedge reset)
begin

if(!reset)
begin
x <= 0;
y <= 0;
z <= 0;
i <= 0;
repeat4 <= 0;
done <= 0;
exp_out <= 0;
end

else begin

if(start)
begin

// Gain compensation
x <= 48'd79141;
y <= 0;

// sign extension of angle
z <= {{16{angle_in[31]}}, angle_in};

i <= 1;
repeat4 <= 0;
done <= 0;

end

else if(i <= ITER)
begin

if(z[47] == 0)
begin
x_next = x + (y >>> i);
y_next = y + (x >>> i);
z_next = z - atanh_table[i];
end

else
begin
x_next = x - (y >>> i);
y_next = y - (x >>> i);
z_next = z + atanh_table[i];
end

x <= x_next;
y <= y_next;
z <= z_next;

// repeat iteration 4
if(i == 4 && repeat4 == 0)
begin
repeat4 <= 1;
i <= 4;
end
else
i <= i + 1;

end

else
begin
// exp(x) = sinh + cosh
exp_out <= (x + y);
done <= 1;
end

end

end

endmodule




TESTBENCH 


`timescale 1ns / 1ps

module cordic_exp_tb;

reg clk;
reg reset;
reg start;
reg signed [31:0] angle;

wire signed [31:0] exp_out;
wire done;

cordic_exp DUT(

.clk(clk),
.reset(reset),
.start(start),
.angle_in(angle),

.exp_out(exp_out),
.done(done)

);

// clock
initial clk = 0;
always #5 clk = ~clk;


initial begin

reset = 0;
start = 0;
angle = 0;

#20
reset = 1;

// test exp(0.5)
angle = 32'd32768;

#10
start = 1;

#10
start = 0;

// wait for result
@(posedge done);

$display("exp_out = %d", exp_out);
$display("exp_real = %f", exp_out/65536.0);

#50
$stop;

end

endmodule

`timescale 1ns / 1ps

module cordic_hyperbolic(

input clk,
input reset,
input start,

input signed [31:0] angle_in,

output reg signed [31:0] sinh,
output reg signed [31:0] cosh,
output reg done

);

parameter ITER = 16;

reg signed [47:0] x;
reg signed [47:0] y;
reg signed [47:0] z;

reg signed [47:0] x_next;
reg signed [47:0] y_next;
reg signed [47:0] z_next;

reg [5:0] i;
reg repeat4;

reg signed [31:0] atanh_table [0:16];

initial begin
atanh_table[0]  = 0;
atanh_table[1]  = 35999;
atanh_table[2]  = 16739;
atanh_table[3]  = 8235;
atanh_table[4]  = 4101;
atanh_table[5]  = 2049;
atanh_table[6]  = 1024;
atanh_table[7]  = 512;
atanh_table[8]  = 256;
atanh_table[9]  = 128;
atanh_table[10] = 64;
atanh_table[11] = 32;
atanh_table[12] = 16;
atanh_table[13] = 8;
atanh_table[14] = 4;
atanh_table[15] = 2;
atanh_table[16] = 1;
end


always @(posedge clk or negedge reset)
begin

if(!reset)
begin

x <= 0;
y <= 0;
z <= 0;

i <= 0;
repeat4 <= 0;
done <= 0;

sinh <= 0;
cosh <= 0;

end

else begin

if(start)
begin

// Gain compensation initialization
x <= 48'd79141;
y <= 0;

// sign extension of input
z <= {{16{angle_in[31]}}, angle_in};

i <= 1;
repeat4 <= 0;
done <= 0;

end


else if(i <= ITER)
begin

if(z[47] == 0)
begin

x_next = x + (y >>> i);
y_next = y + (x >>> i);
z_next = z - {{16{atanh_table[i][31]}}, atanh_table[i]};

end

else
begin

x_next = x - (y >>> i);
y_next = y - (x >>> i);
z_next = z + {{16{atanh_table[i][31]}}, atanh_table[i]};

end

x <= x_next;
y <= y_next;
z <= z_next;

// Hyperbolic convergence repeat
if(i == 4 && repeat4 == 0)
begin
repeat4 <= 1;
i <= 4;
end
else
i <= i + 1;

end


else
begin

cosh <= x[31:0];
sinh <= y[31:0];

done <= 1;

end

end

end

endmodule       


TestBench




`timescale 1ns / 1ps

module cordic_hyperbolic_tb;

reg clk;
reg reset;
reg start;

reg signed [31:0] angle_in;

wire signed [31:0] sinh;
wire signed [31:0] cosh;
wire done;

cordic_hyperbolic DUT(

.clk(clk),
.reset(reset),
.start(start),

.angle_in(angle_in),

.sinh(sinh),
.cosh(cosh),

.done(done)

);

// Clock generation
initial clk = 0;
always #5 clk = ~clk;


initial begin

reset = 0;
start = 0;
angle_in = 0;

#20
reset = 1;

// Test angle = 0.5
angle_in = 32'd32768;

#10
start = 1;

#10
start = 0;

@(posedge done);

$display("sinh = %d", sinh);
$display("cosh = %d", cosh);

$display("sinh_real = %f", sinh/65536.0);
$display("cosh_real = %f", cosh/65536.0);

#50
$stop;

end

endmodule
