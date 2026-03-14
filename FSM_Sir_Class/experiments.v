`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2026 07:24:28 PM
// Design Name: 
// Module Name: fsms
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

module toggle_flip_flop_fsm(
    input clk,
    input reset_n,
    output reg y_out
);

parameter s0 = 1'b0;
parameter s1 = 1'b1;

reg current_state;
reg next_state;

// State register
always @(posedge clk or negedge reset_n) begin
    if (!reset_n)
        current_state <= s0;
    else
        current_state <= next_state;
end

// Next state logic
always @(*) begin
    case (current_state)
        s0: next_state = s1;
        s1: next_state = s0;
        default: next_state = s0;
    endcase
end

// Output logic
always @(*) begin
    case (current_state)
        s0: y_out = 1'b0;
        s1: y_out = 1'b1;
        default: y_out = 1'b0;
    endcase
end

endmodule

module module_2bit_counter(
    input clk,
    input reset_n
);

parameter s0 = 2'b00,
          s1 = 2'b01,
          s2 = 2'b10,
          s3 = 2'b11;

reg [1:0] current_state;
reg [1:0] next_state;

// State register
always @(posedge clk or negedge reset_n) begin
    if (!reset_n)
        current_state <= s0;
    else
        current_state <= next_state;
end

// Next state
always @(*) begin
    case (current_state)
        s0: next_state = s1;
        s1: next_state = s2;
        s2: next_state = s3;
        s3: next_state = s0;
        default: next_state = s0;
    endcase
end

endmodule
module seq_det_101 (
    input clk,
    input reset_n,
    input data_in,
    output reg y_out
);

parameter s0 = 2'b00,  // No match
          s1 = 2'b01,  // Detected '1'
          s2 = 2'b10;  // Detected '10'

reg [1:0] current_state, next_state;

// State register logic
always @(posedge clk or negedge reset_n)
begin
    if (!reset_n)
        current_state <= s0;
    else
        current_state <= next_state;
end

// Next state logic
always @(*)
begin
    case (current_state)
        s0: begin
            if (data_in)
                next_state = s1;
            else
                next_state = s0;
        end

        s1: begin
            if (!data_in)
                next_state = s2;
            else
                next_state = s1;
        end

        s2: begin
            if (data_in)
                next_state = s1;  // overlapping allowed
            else
                next_state = s0;
        end

        default: next_state = s0;
    endcase
end

// Output logic (Moore FSM)
always @(*)
begin
    if (current_state == s2 && data_in == 1'b1)
        y_out = 1'b1;
    else
        y_out = 1'b0;
end

endmodule


module module_seq_det_101_moore (
    input clk,
    input reset_n,
    input data_in,
    output reg y_out
);

parameter s0 = 2'b00,  // No match
          s1 = 2'b01,  // Got '1'
          s2 = 2'b10,  // Got '10'
          s3 = 2'b11;  // Got '101' (output state)

reg [1:0] current_state, next_state;

// State register logic
always @(posedge clk or negedge reset_n)
begin
    if (!reset_n)
        current_state <= s0;
    else
        current_state <= next_state;
end

// Next state logic
always @(*)
begin
    case (current_state)

        s0: begin
            if (data_in)
                next_state = s1;
            else
                next_state = s0;
        end

        s1: begin
            if (!data_in)
                next_state = s2;
            else
                next_state = s1;
        end

        s2: begin
            if (data_in)
                next_state = s3;
            else
                next_state = s0;
        end

        s3: begin
            if (data_in)
                next_state = s1;   // overlapping allowed
            else
                next_state = s2;
        end

        default: next_state = s0;

    endcase
end

// Moore output logic (depends only on state)
always @(*)
begin
    case (current_state)
        s3: y_out = 1'b1;
        default: y_out = 1'b0;
    endcase
end

endmodule


module serial_adder_mealy (
    input clk,
    input reset_n,
    input a_in,
    input b_in,
    output reg sum_out,
    output carry_out
);

parameter s0 = 1'b0,   // Carry = 0
          s1 = 1'b1;   // Carry = 1

reg current_state, next_state;

// State register logic (stores carry)
always @(posedge clk or negedge reset_n)
begin
    if (!reset_n)
        current_state <= s0;
    else
        current_state <= next_state;
end

// Next state logic (carry for next cycle)
always @(*)
begin
    case (current_state)

        s0: begin
            if (a_in & b_in)
                next_state = s1;
            else
                next_state = s0;
        end

        s1: begin
            if (a_in & b_in || a_in & ~b_in || ~a_in & b_in)
                next_state = s1;
            else
                next_state = s0;
        end

        default: next_state = s0;

    endcase
end

// Mealy sum output
always @(*)
begin
    case (current_state)

        s0: sum_out = a_in ^ b_in;

        s1: sum_out = a_in ^ b_in ^ 1'b1;

        default: sum_out = 1'b0;

    endcase
end

// Immediate carry output (same cycle carry)
assign carry_out = (a_in & b_in) |
                   (current_state & (a_in ^ b_in));

endmodule


module serial_adder_moore (
    input clk,
    input reset_n,
    input a_in,
    input b_in,
    output reg sum_out,
    output reg carry_out
);

parameter s0 = 1'b0,   // carry = 0
          s1 = 1'b1;   // carry = 1

reg current_state, next_state;
reg sum_next;

// State register logic
always @(posedge clk or negedge reset_n)
begin
    if (!reset_n) begin
        current_state <= s0;
        sum_out <= 1'b0;
    end
    else begin
        current_state <= next_state;
        sum_out <= sum_next;   // Moore output registered
    end
end

// Next state logic
always @(*)
begin
    next_state = (a_in & b_in) |
                 (current_state & (a_in ^ b_in));
end

// Next sum calculation
always @(*)
begin
    sum_next = a_in ^ b_in ^ current_state;
end

// Carry output (depends only on state)
always @(*)
begin
    carry_out = current_state;
end

endmodule


module seq_det_1111_mealy (
    input clk,
    input reset_n,
    input data_in,
    output reg y_out
);

parameter s0 = 2'b00,
          s1 = 2'b01,
          s2 = 2'b10,
          s3 = 2'b11;

reg [1:0] current_state, next_state;

// State register logic
always @(posedge clk or negedge reset_n)
begin
    if (!reset_n)
        current_state <= s0;
    else
        current_state <= next_state;
end

// Next state logic
always @(*)
begin
    case (current_state)
        s0: next_state = data_in ? s1 : s0;
        s1: next_state = data_in ? s2 : s0;
        s2: next_state = data_in ? s3 : s0;
        s3: next_state = data_in ? s3 : s0;  // overlap allowed

        default: next_state = s0;

    endcase
end

// Mealy output logic
always @(*)
begin
    if (current_state == s3 && data_in == 1'b1)
        y_out = 1'b1;
    else
        y_out = 1'b0;
end

endmodule


module seq_det_1111_moore (
    input clk,
    input reset_n,
    input data_in,
    output reg y_out
);

parameter s0 = 3'b000,
          s1 = 3'b001,
          s2 = 3'b010,
          s3 = 3'b011,
          s4 = 3'b100;   // detection state

reg [2:0] current_state, next_state;

// State register logic
always @(posedge clk or negedge reset_n)
begin
    if (!reset_n)
        current_state <= s0;
    else
        current_state <= next_state;
end

// Next state logic
always @(*)
begin
    case (current_state)

        s0: next_state = data_in ? s1 : s0;

        s1: next_state = data_in ? s2 : s0;

        s2: next_state = data_in ? s3 : s0;

        s3: next_state = data_in ? s4 : s0;

        s4: next_state = data_in ? s4 : s0;  // overlap allowed

        default: next_state = s0;

    endcase
end

// Moore output logic (depends only on state)
always @(*)
begin
    case (current_state)

        s4: y_out = 1'b1;

        default: y_out = 1'b0;

    endcase
end

endmodule


module seq_det_1111_0000_mealy (
    input clk,
    input reset_n,
    input data_in,
    output reg y_out
);

parameter s0 = 3'b000,  // start
          s1 = 3'b001,  // 1
          s2 = 3'b010,  // 11
          s3 = 3'b011,  // 111
          s4 = 3'b100,  // 0
          s5 = 3'b101,  // 00
          s6 = 3'b110;  // 000

reg [2:0] current_state, next_state;

// State register
always @(posedge clk or negedge reset_n)
begin
    if (!reset_n)
        current_state <= s0;
    else
        current_state <= next_state;
end

// Next state logic
always @(*)
begin
    case (current_state)
        s0: next_state = data_in ? s1 : s4;
        s1: next_state = data_in ? s2 : s4;

        s2: next_state = data_in ? s3 : s4;
        s3: next_state = data_in ? s3 : s4;  // overlap for 1's
        s4: next_state = data_in ? s1 : s5;
        s5: next_state = data_in ? s1 : s6;
        s6: next_state = data_in ? s1 : s6;  // overlap for 0's
        default: next_state = s0;
    endcase
end






// Mealy output logic
always @(*)
begin
    if ((current_state == s3 && data_in == 1'b1) ||
        (current_state == s6 && data_in == 1'b0))
        y_out = 1'b1;
    else
        y_out = 1'b0;
end

endmodule

module parity_3bit_odd_mealy (
    input clk,
    input reset_n,
    input x,          // serial data input
    output reg y      // parity output
);

parameter A = 3'b000,
          B = 3'b001,
          C = 3'b010,
          D = 3'b011,
          E = 3'b100,
          F = 3'b101,
          G = 3'b110;

reg [2:0] current_state, next_state;

// State register
always @(posedge clk or negedge reset_n)
begin
    if (!reset_n)
        current_state <= A;
    else
        current_state <= next_state;
end

// Next state logic
always @(*)
begin
    case (current_state)

        A: next_state = (x == 0) ? B : C;

        B: next_state = (x == 0) ? D : E;

        C: next_state = (x == 0) ? E : D;

        D: next_state = (x == 0) ? F : G;

        E: next_state = (x == 0) ? G : F;

        F: next_state = A;   // blank cycle

        G: next_state = A;   // blank cycle

        default: next_state = A;

    endcase
end

// Output logic (Mealy)
always @(*)
begin
    case (current_state)

        F: y = 1'b1;   // even count -> need 1 for odd parity
        G: y = 1'b0;   // odd count -> need 0

        default: y = 1'b0;

    endcase
end

endmodule


module seq_3bit_2or3ones_mealy (
    input clk,
    input reset_n,
    input x,
    output reg y
);

parameter A = 3'b000,
          B = 3'b001,
          C = 3'b010,
          D = 3'b011,
          E = 3'b100,
          F = 3'b101;

reg [2:0] current_state, next_state;

// State register
always @(posedge clk or negedge reset_n)
begin
    if (!reset_n)
        current_state <= A;
    else
        current_state <= next_state;
end

// Next-state logic
always @(*)
begin
    case (current_state)

        A: next_state = (x == 0) ? B : C;

        B: next_state = (x == 0) ? D : E;

        C: next_state = (x == 0) ? E : F;

        D: next_state = A;   // 3rd bit complete

        E: next_state = A;

        F: next_state = A;

        default: next_state = A;

    endcase
end

// Mealy output logic
always @(*)
begin
    case (current_state)

        D: y = 1'b0;                 // 0 ones
        E: y = (x == 1) ? 1'b1 : 1'b0; // 2 ones only if x=1
        F: y = 1'b1;                 // already 2 ones → 3rd always gives ≥2

        default: y = 1'b0;

    endcase
end

endmodule


module seq_det_1100_1010_1001_nonoverlap (
    input clk,
    input reset_n,
    input x,
    output reg y
);

parameter S0   = 3'b000,
          S1   = 3'b001,
          S10  = 3'b010,
          S11  = 3'b011,
          S100 = 3'b100,
          S101 = 3'b101,
          S110 = 3'b110;

reg [2:0] current_state, next_state;

// State register
always @(posedge clk or negedge reset_n)
begin
    if (!reset_n)
        current_state <= S0;
    else
        current_state <= next_state;
end

// Next-state logic
always @(*)
begin
    case (current_state)

        S0:  next_state = (x) ? S1 : S0;

        S1:  next_state = (x) ? S11 : S10;

        S10: next_state = (x) ? S101 : S100;

        S11: next_state = (x) ? S11 : S110;

        // NON-OVERLAP: go to S0 after detection

        S100: next_state = (x) ? S0 : S0;   // detection if x=1

        S101: next_state = (x) ? S1 : S0;   // detection if x=0

        S110: next_state = (x) ? S1 : S0;   // detection if x=0

        default: next_state = S0;

    endcase
end

// Mealy output logic
always @(*)
begin
    if ((current_state == S110 && x == 0) ||  // 1100
        (current_state == S101 && x == 0) ||  // 1010
        (current_state == S100 && x == 1))    // 1001
        y = 1'b1;
    else
        y = 1'b0;
end

endmodule


