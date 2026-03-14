`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2026 07:25:52 PM
// Design Name: 
// Module Name: tb
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

`timescale 1ns/1ps

module tb_toggle_flip_flop_fsm;

reg clk;
reg reset_n;
wire y_out;

toggle_flip_flop_fsm dut(
    .clk(clk),
    .reset_n(reset_n),
    .y_out(y_out)
);

// clock
always #5 clk = ~clk;

initial begin
    clk = 0;
    reset_n = 0;

    #12 reset_n = 1;

    #100;

    #7 reset_n = 0;
    #10 reset_n = 1;

    #60 $finish;
end

initial begin
    $monitor("Time=%0t reset_n=%b y_out=%b", $time, reset_n, y_out);
end

endmodule

`timescale 1ns/1ps

module tb_module_2bit_counter;

reg clk;
reg reset_n;

module_2bit_counter dut(
    .clk(clk),
    .reset_n(reset_n)
);

initial clk = 0;
always #5 clk = ~clk;

initial begin
    reset_n = 0;
    #100 reset_n = 1;

    repeat(5) @(posedge clk);

    $finish;
end

initial begin
    $monitor("Time=%0t reset_n=%b state=%02b",
             $time, reset_n, dut.current_state);
end

endmodule


`timescale 1ns/1ps

module tb_module_seq_det_101;

    reg clk;
    reg reset_n;
    reg data_in;
    wire y_out;

    // Instantiate DUT
    seq_det_101 dut (
        .clk(clk),
        .reset_n(reset_n),
        .data_in(data_in),
        .y_out(y_out)
    );

    // Clock generation (10ns period)
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        reset_n = 0;
        data_in = 0;

        // Apply reset
        #12;
        reset_n = 1;

        // Apply input sequence: 1 0 1 0 1 1 0 1

        @(posedge clk); data_in = 1;
        @(posedge clk); data_in = 0;
        @(posedge clk); data_in = 1;  // detect 101
        @(posedge clk); data_in = 0;
        @(posedge clk); data_in = 1;  // detect overlapping 101
        @(posedge clk); data_in = 1;
        @(posedge clk); data_in = 0;
        @(posedge clk); data_in = 1;  // detect again

        #20;
        $finish;
    end

    // Monitor values
    initial begin
        $display("Time\treset_n\tdata_in\ty_out");
        $monitor("%0t\t%b\t%b\t%b",
                 $time, reset_n, data_in, y_out);
    end


endmodule


module tb_module_seq_det_101_moore;

    reg clk;
    reg reset_n;
    reg data_in;
    wire y_out;

    // Instantiate DUT
    module_seq_det_101_moore dut (
        .clk(clk),
        .reset_n(reset_n),
        .data_in(data_in),
        .y_out(y_out)
    );

    // Clock generation (10ns period)
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset_n = 0;
        data_in = 0;

        // Apply reset
        #12;
        reset_n = 1;

        // Apply input sequence: 1 0 1 0 1 1 0 1
        @(posedge clk); data_in = 1;
        @(posedge clk); data_in = 0;
        @(posedge clk); data_in = 1;  // detect (after 1 clock delay)
        @(posedge clk); data_in = 0;
        @(posedge clk); data_in = 1;  // detect overlapping
        @(posedge clk); data_in = 1;
        @(posedge clk); data_in = 0;
        @(posedge clk); data_in = 1;  // detect again

        #20;
        $finish;
    end

    initial begin
        $display("Time\treset_n\tdata_in\ty_out");
        $monitor("%0t\t%b\t%b\t%b",
                 $time, reset_n, data_in, y_out);
    end

endmodule

module tb_serial_adder_mealy;

    reg clk;
    reg reset_n;
    reg a_in;
    reg b_in;
    wire sum_out;
    wire carry_out;

    // Instantiate DUT
    serial_adder_mealy dut (
        .clk(clk),
        .reset_n(reset_n),
        .a_in(a_in),
        .b_in(b_in),
        .sum_out(sum_out),
        .carry_out(carry_out)
    );

    // Clock generation (10ns period)
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset_n = 0;
        a_in = 0;
        b_in = 0;

        // Apply reset
        #12;
        reset_n = 1;

        // Example: 1011 + 1101 (LSB first)

        #3  a_in = 1; b_in = 1;  // Bit 0
        #10 a_in = 1; b_in = 0;  // Bit 1
        #10 a_in = 0; b_in = 1;  // Bit 2
        #10 a_in = 1; b_in = 1;  // Bit 3

        #20;


        $finish;
    end

    initial begin
        $display("Time\treset\ta\tb\tsum\tcarry");
        $monitor("%0t\t%b\t%b\t%b\t%b\t%b",
                 $time, reset_n,
                 a_in, b_in,
                 sum_out, carry_out);
    end


endmodule

`timescale 1ns/1ps

module tb_serial_adder_moore;

    reg clk;
    reg reset_n;
    reg a_in;
    reg b_in;
    wire sum_out;
    wire carry_out;

    // Instantiate DUT
    serial_adder_moore dut (
        .clk(clk),
        .reset_n(reset_n),
        .a_in(a_in),
        .b_in(b_in),
        .sum_out(sum_out),
        .carry_out(carry_out)
    );

    // Clock generation (10ns period)
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset_n = 0;
        a_in = 0;
        b_in = 0;

        // Apply reset
        #12;
        reset_n = 1;

        // Example: 1011 + 1101 (LSB first)

        @(negedge clk); a_in = 1; b_in = 1;  // Bit 0
        @(negedge clk); a_in = 1; b_in = 0;  // Bit 1
        @(negedge clk); a_in = 0; b_in = 1;  // Bit 2
        @(negedge clk); a_in = 1; b_in = 1;  // Bit 3

        #20;
        $finish;
    end

    initial begin
        $display("Time\treset\ta\tb\tsum\tcarry");
        $monitor("%0t\t%b\t%b\t%b\t%b\t%b",
                 $time,
                 reset_n,
                 a_in,
                 b_in,
                 sum_out,
                 carry_out);
    end

    initial begin
        $dumpfile("serial_adder_moore.vcd");
        $dumpvars(0, tb_serial_adder_moore);
    end

endmodule


module tb_seq_det_1111_mealy;

    reg clk;
    reg reset_n;
    reg data_in;
    wire y_out;

    // Instantiate DUT
    seq_det_1111_mealy dut (
        .clk(clk),
        .reset_n(reset_n),
        .data_in(data_in),
        .y_out(y_out)
    );

    // Clock generation (10ns period)
    initial clk = 0;
    always #5 clk = ~clk;
  
  

    initial begin
        reset_n = 0;
        data_in = 0;

        // Apply reset
        #10;
        reset_n = 1;

        // Apply input sequence:
        // 1 1 1 1 1 0 1 1 1 1

        @(negedge clk); data_in = 1;
        @(negedge clk); data_in = 1;
        @(negedge clk); data_in = 1;
        @(negedge clk); data_in = 1;  // detect
        @(negedge clk); data_in = 1;  // detect (overlap)
      @(negedge clk); data_in = 1;
        @(negedge clk); data_in = 1;
        @(negedge clk); data_in = 1;
        @(negedge clk); data_in = 1;
        @(negedge clk); data_in = 1;  // detect

        #100;
        $finish;
    end

  initial
    $display("Time\treset\tdata\ty_out");

always @(posedge clk)
begin
    $display("%0t\t%b\t%b\t%b",
             $time,
             reset_n,
             data_in,
             y_out);
end

    


endmodule



module tb_seq_det_1111_moore;

    reg clk;
    reg reset_n;
    reg data_in;
    wire y_out;

    seq_det_1111_moore dut (
        .clk(clk),
        .reset_n(reset_n),
        .data_in(data_in),
        .y_out(y_out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset_n = 0;
        data_in = 0;

        #10;
        reset_n = 1;

        // Apply sequence:
        // 1 1 1 1 1 1 1

        @(negedge clk); data_in = 1;
        @(negedge clk); data_in = 1;
        @(negedge clk); data_in = 1;
        @(negedge clk); data_in = 1;
        @(negedge clk); data_in = 1;
        @(negedge clk); data_in = 1;
        @(negedge clk); data_in = 1;

        #100;
        $finish;
    end

    initial
        $display("Time\treset\tdata\ty_out");

    always @(posedge clk)
        $display("%0t\t%b\t%b\t%b",
                 $time,
                 reset_n,
                 data_in,
                 y_out);

endmodule

module tb_seq_det_1111_0000_mealy;

    reg clk;
    reg reset_n;
    reg data_in;
    wire y_out;

    // Instantiate DUT
    seq_det_1111_0000_mealy dut (
        .clk(clk),
        .reset_n(reset_n),
        .data_in(data_in),
        .y_out(y_out)
    );

    // Clock generation (10ns period)
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset_n = 0;
        data_in = 0;

        #10;
        reset_n = 1;

        // Apply sequence:
        // 1 1 1 1 1 0 0 0 0 0 1 1 1 1

        @(negedge clk); data_in = 1;
        @(negedge clk); data_in = 1;
        @(negedge clk); data_in = 1;
        @(negedge clk); data_in = 1;  // detect 1111
        @(negedge clk); data_in = 1;  // overlap detect

        @(negedge clk); data_in = 0;
        @(negedge clk); data_in = 0;
        @(negedge clk); data_in = 0;
        @(negedge clk); data_in = 0;  // detect 0000
        @(negedge clk); data_in = 0;  // overlap detect

        @(negedge clk); data_in = 1;
        @(negedge clk); data_in = 1;
        @(negedge clk); data_in = 1;
        @(negedge clk); data_in = 1;  // detect again

        #50;
        $finish;
    end

    initial
        $display("Time\treset\tdata\ty_out");

    always @(posedge clk)
        $display("%0t\t%b\t%b\t%b",
                 $time,
                 reset_n,
                 data_in,
                 y_out);

    initial begin
        $dumpfile("seq_det_1111_0000_mealy.vcd");
        $dumpvars(0, tb_seq_det_1111_0000_mealy);
    end

endmodule



module tb_parity_3bit_odd_mealy;

    reg clk;
    reg reset_n;
    reg x;
    wire y;

    parity_3bit_odd_mealy dut (
        .clk(clk),
        .reset_n(reset_n),
        .x(x),
        .y(y)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset_n = 0;
        x = 0;

        #10;
        reset_n = 1;

        // Send 3-bit data: 1 0 1  (two 1's → even → parity=1)

        @(negedge clk); x = 1;
        @(negedge clk); x = 0;
        @(negedge clk); x = 1;

        // blank cycle
        @(negedge clk); x = 0;

        // Next data: 1 1 1 (three 1's → odd → parity=0)

        @(negedge clk); x = 1;
        @(negedge clk); x = 1;
        @(negedge clk); x = 1;

        // blank cycle
        @(negedge clk); x = 0;

        #50;
        $finish;
    end

    initial
        $display("Time\treset\tx\ty");

    always @(posedge clk)
        $display("%0t\t%b\t%b\t%b",
                 $time, reset_n, x, y);

endmodule



module tb_seq_3bit_2or3ones_mealy;

    reg clk;
    reg reset_n;
    reg x;
    wire y;

    seq_3bit_2or3ones_mealy dut (
        .clk(clk),
        .reset_n(reset_n),
        .x(x),
        .y(y)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset_n = 0;
        x = 0;

        #10;
        reset_n = 1;

        // Apply input sequence: 010101110

        @(negedge clk); x = 0;
        @(negedge clk); x = 1;
        @(negedge clk); x = 0;

        @(negedge clk); x = 1;
        @(negedge clk); x = 0;
        @(negedge clk); x = 1;

        @(negedge clk); x = 1;
        @(negedge clk); x = 1;
        @(negedge clk); x = 0;

        #50;
        $finish;
    end

    initial
        $display("Time\treset\tx\ty");

    always @(posedge clk)
        $display("%0t\t%b\t%b\t%b",
                 $time, reset_n, x, y);

    initial begin
        $dumpfile("seq_3bit_2or3ones_mealy.vcd");
        $dumpvars(0, tb_seq_3bit_2or3ones_mealy);
    end

endmodule


module tb_seq_det_1100_1010_1001_nonoverlap;

    reg clk;
    reg reset_n;
    reg x;
    wire y;

    seq_det_1100_1010_1001_nonoverlap dut (
        .clk(clk),
        .reset_n(reset_n),
        .x(x),
        .y(y)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset_n = 0;
        x = 0;

        #10;
        reset_n = 1;

        // Test sequence containing patterns back-to-back
        // 1100 1010 1001

        @(negedge clk); x = 1;
        @(negedge clk); x = 1;
        @(negedge clk); x = 0;
        @(negedge clk); x = 0;  // detect 1100

        @(negedge clk); x = 1;
        @(negedge clk); x = 0;
        @(negedge clk); x = 1;
        @(negedge clk); x = 0;  // detect 1010

        @(negedge clk); x = 1;
        @(negedge clk); x = 0;
        @(negedge clk); x = 0;
        @(negedge clk); x = 1;  // detect 1001

        #50;
        $finish;
    end

    initial
        $display("Time\treset\tx\ty");

    always @(posedge clk)
        $display("%0t\t%b\t%b\t%b",
                 $time, reset_n, x, y);

endmodule


