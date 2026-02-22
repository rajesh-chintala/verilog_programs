## Mealy 2 Blocks
<img width="512" height="138" alt="image" src="https://github.com/user-attachments/assets/dc6b8e1b-060d-4ea2-a3df-2faa16ad5236" />
<img width="400" height="140" alt="image" src="https://github.com/user-attachments/assets/f10708b2-4a5a-45c7-a336-c7b86cd7e824" />

Code:
```
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2026 05:24:10 PM
// Design Name: 
// Module Name: mealy_2_blcoks
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

module mealy_2blocks(input clk, input reset, input x, output reg parity);

reg state, nextstate;
parameter S0=0, S1=1;

always @(posedge clk or posedge reset) // always block to update state
if (reset)
state <= S0;
else
state <= nextstate;

always @(state or x) // always block to compute both output & nextstate
begin
parity = 1'b0;
case(state)
S0: if(x)
begin
parity = 1; nextstate = S1;
end
else
nextstate = S0;
S1: if(x)
nextstate = S0;
else
begin
parity = 1; nextstate = S1;
end
default:
nextstate = S0;
endcase
end
endmodule
```

Testbench:
```

module mealy_2blocks_tb();

reg clock, reset, x;
wire parity;

mealy_2blocks m1(clock, reset, x, parity);

initial begin
clock = 0;
reset = 1; 
#10
reset = 0;
#5 x = 1; 
#5 x = 0; 
#5 x = 0;
#5 x = 1; 
#5 x = 1;
end


always #1 clock = ~clock;

endmodule

```

Simulation Result:
<img width="1075" height="698" alt="image" src="https://github.com/user-attachments/assets/874878cb-7dab-4b5a-98ec-ccee558364d4" />

Note Points:
1. Output changes based on state and input, doesn't waits for the clock as input is always an asynchronous one. Thus it is mealy fsm

## Mealy 3 block
<img width="543" height="179" alt="image" src="https://github.com/user-attachments/assets/94f00992-6ee7-421f-9d71-11c3326a80f4" />

Code:
```
module mealy_3processes(input clk, input reset, input x, output reg parity);
reg state, nextstate;
parameter S0=0, S1=1;
always @(posedge clk or posedge reset) // always block to update state
if (reset)
state <= S0;
else
state <= nextstate;
always @(state or x) // always block to compute output
begin
parity = 1'b0;
case(state)
S0: if(x)
parity = 1;
S1: if(!x)
parity = 1;
endcase
end
always @(state or x) // always block to compute nextstate
begin
nextstate = S0;
case(state)
S0: if(x)
nextstate = S1;
S1: if(!x)
nextstate = S1;
endcase
end
endmodule
```

Testbench:
```
`timescale 1ns/1ps

module mealy_3processes_tb;

reg clk;
reg reset;
reg x;
wire parity;

// Instantiate DUT
mealy_3processes dut (
    .clk(clk),
    .reset(reset),
    .x(x),
    .parity(parity)
);

//////////////// CLOCK //////////////////
always #5 clk = ~clk;   // 10ns clock


//////////////// TASK ////////////////////
task apply_input;
input x_in;
begin
    @(negedge clk);   // change input safely
    x = x_in;
end
endtask


//////////////// SIMULATION //////////////////
initial begin

    $dumpfile("dump.vcd");
    $dumpvars(0, mealy_3processes_tb);

    $display("\n===== Mealy 3-Process FSM Simulation =====\n");
    $monitor("TIME=%0t | reset=%b | x=%b | parity=%b",
              $time, reset, x, parity);

    // Initialize
    clk = 0;
    reset = 1;
    x = 0;

    // Apply reset
    #12 reset = 0;

    //-------------------------
    // Test Pattern
    //-------------------------

    apply_input(0);
    apply_input(1);
    apply_input(1);
    apply_input(0);
    apply_input(1);
    apply_input(0);
    apply_input(0);
    apply_input(1);
    apply_input(1);
    apply_input(0);

    //-------------------------
    // Finish
    //-------------------------
    #20;
    $display("\n===== Simulation Finished =====\n");
    $finish;

end

endmodule
```

Simulation Results:

Note Points:

## Moorie FSM
<img width="710" height="386" alt="image" src="https://github.com/user-attachments/assets/822644b9-589c-4ace-93a9-d08330d0566e" />

Code: 
```
module moore_3processes(input clk, input reset, input x, output reg parity);
reg state, nextstate;
parameter S0=0, S1=1;
always @(posedge clk or posedge reset) // always block to update state
if (reset)
state <= S0;
else
state <= nextstate;
always @(state) // always block to compute output
begin
case(state)
S0: parity = 0;
S1: parity = 1;
endcase
end
always @(state or x) // always block to compute nextstate
begin
nextstate = S0;
case(state)
S0: if(x)
nextstate = S1;
S1: if(!x)
nextstate = S1;
endcase
end
endmodule
```

Testbench:

```
`timescale 1ns/1ps

module moore_3processes_tb;

reg clk;
reg reset;
reg x;
wire parity;

// Instantiate DUT
moore_3processes dut (
    .clk(clk),
    .reset(reset),
    .x(x),
    .parity(parity)
);

//////////////// CLOCK //////////////////
always #5 clk = ~clk;   // 10ns clock


//////////////// TASK ////////////////////
task apply_input;
input x_in;
begin
    @(negedge clk);   // change input away from active clock edge
    x = x_in;
end
endtask


//////////////// SIMULATION //////////////////
initial begin

    $dumpfile("dump.vcd");
    $dumpvars(0, moore_3processes_tb);

    $display("\n===== Moore 3-Process FSM Simulation =====\n");
    $monitor("TIME=%0t | reset=%b | x=%b | parity=%b",
              $time, reset, x, parity);

    // Initialize
    clk = 0;
    reset = 1;
    x = 0;

    // Apply reset
    #12 reset = 0;

    //-------------------------
    // Apply input pattern
    //-------------------------
    apply_input(0);
    apply_input(1);
    apply_input(1);
    apply_input(0);
    apply_input(1);
    apply_input(0);
    apply_input(0);
    apply_input(1);
    apply_input(0);
    apply_input(1);

    //-------------------------
    // Finish simulation
    //-------------------------
    #20;
    $display("\n===== Simulation Finished =====\n");
    $finish;

end

endmodule
```
