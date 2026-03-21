# Verilog code:
```
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/21/2026 09:17:11 PM
// Design Name: 
// Module Name: main
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

module axi_master (
    input  wire        ACLK,
    input  wire        ARESETn,

    // Write Address Channel (AW) [5]
    output reg  [31:0] AWADDR,
    output reg  [7:0]  AWLEN,   // AXI4 uses 8-bit length [6]
    output reg         AWVALID,
    input  wire        AWREADY,

    // Write Data Channel (W) [7]
    output reg  [31:0] WDATA,
    output reg         WVALID,
    output reg         WLAST,
    input  wire        WREADY,

    // Write Response Channel (B) [8]
    input  wire [1:0]  BRESP,
    input  wire        BVALID,
    output reg         BREADY,

    // Read Address Channel (AR) [9]
    output reg  [31:0] ARADDR,
    output reg  [7:0]  ARLEN,
    output reg         ARVALID,
    input  wire        ARREADY,

    // Read Data Channel (R) [10]
    input  wire [31:0] RDATA,
    input  wire [1:0]  RRESP,
    input  wire        RVALID,
    input  wire        RLAST,
    output reg         RREADY
);

    // Simple FSM to sequence a write then a read
    reg [2:0] state;
    localparam IDLE=0, W_ADDR=1, W_DATA=2, W_RESP=3, R_ADDR=4, R_DATA=5;

    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            state <= IDLE;
            AWVALID <= 0; WVALID <= 0; BREADY <= 0;
            ARVALID <= 0; RREADY <= 0;
        end else begin
            case (state)
                IDLE: begin
                    state <= W_ADDR;
                    AWADDR <= 32'h000; AWLEN <= 8'd0; AWVALID <= 1; // Start Write Address [11]
                end
                W_ADDR: if (AWREADY) begin
                    AWVALID <= 0;
                    WVALID <= 1; WDATA <= 32'hDEADBEEF; WLAST <= 1;
                    state <= W_DATA; // Move to Write Data [12]
                end
                W_DATA: if (WREADY) begin
                    WVALID <= 0; WLAST <= 0;
                    BREADY <= 1;
                    state <= W_RESP; // Wait for Response [13]
                end
                W_RESP: if (BVALID) begin
                    BREADY <= 0;
                    ARADDR <= 32'h000; ARLEN <= 8'd0; ARVALID <= 1;
                    state <= R_ADDR; // Start Read Address [14]
                end
                R_ADDR: if (ARREADY) begin
                    ARVALID <= 0;
                    RREADY <= 1;
                    state <= R_DATA; // Wait for Read Data [15]
                end
                R_DATA: if (RVALID) begin
                    RREADY <= 0;
                    state <= IDLE; // Transaction Complete
                end
            endcase
        end
    end
endmodule

module axi_slave (
    input  wire        ACLK,
    input  wire        ARESETn,

    // AW Channel
    input  wire [31:0] AWADDR,
    input  wire        AWVALID,
    output reg         AWREADY,

    // W Channel
    input  wire [31:0] WDATA,
    input  wire        WVALID,
    output reg         WREADY,

    // B Channel
    output reg  [1:0]  BRESP,
    output reg         BVALID,
    input  wire        BREADY,

    // AR Channel
    input  wire [31:0] ARADDR,
    input  wire        ARVALID,
    output reg         ARREADY,

    // R Channel
    output reg  [31:0] RDATA,
    output reg  [1:0]  RRESP,
    output reg         RVALID,
    output reg         RLAST,
    input  wire        RREADY
);

    reg [31:0] mem [0:255];
    reg [31:0] write_addr;

    // Handshake logic: Slave can wait for VALID before asserting READY [4]
    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            AWREADY <= 0; WREADY <= 0; BVALID <= 0;
            ARREADY <= 0; RVALID <= 0;
        end else begin
            // Write Path [1]
            if (AWVALID && !AWREADY) begin
                AWREADY <= 1;
                write_addr <= AWADDR;
            end else AWREADY <= 0;

            if (WVALID && !WREADY) begin
                WREADY <= 1;
                mem[write_addr[7:0]] <= WDATA;
            end else WREADY <= 0;

            if (WVALID && WREADY && !BVALID) begin
                BVALID <= 1;
                BRESP <= 2'b00; // OKAY [17]
            end else if (BREADY) BVALID <= 0;

            // Read Path [16]
            if (ARVALID && !ARREADY) begin
                ARREADY <= 1;
            end else ARREADY <= 0;

            if (ARVALID && ARREADY && !RVALID) begin
                RVALID <= 1;
                RDATA <= mem[ARADDR[7:0]];
                RRESP <= 2'b00; // OKAY
                RLAST <= 1;
            end else if (RREADY) RVALID <= 0;
        end
    end
endmodule

```

# TestBench
```
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/21/2026 09:17:11 PM
// Design Name: 
// Module Name: main
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

module axi_master (
    input  wire        ACLK,
    input  wire        ARESETn,

    // Write Address Channel (AW) [5]
    output reg  [31:0] AWADDR,
    output reg  [7:0]  AWLEN,   // AXI4 uses 8-bit length [6]
    output reg         AWVALID,
    input  wire        AWREADY,

    // Write Data Channel (W) [7]
    output reg  [31:0] WDATA,
    output reg         WVALID,
    output reg         WLAST,
    input  wire        WREADY,

    // Write Response Channel (B) [8]
    input  wire [1:0]  BRESP,
    input  wire        BVALID,
    output reg         BREADY,

    // Read Address Channel (AR) [9]
    output reg  [31:0] ARADDR,
    output reg  [7:0]  ARLEN,
    output reg         ARVALID,
    input  wire        ARREADY,

    // Read Data Channel (R) [10]
    input  wire [31:0] RDATA,
    input  wire [1:0]  RRESP,
    input  wire        RVALID,
    input  wire        RLAST,
    output reg         RREADY
);

    // Simple FSM to sequence a write then a read
    reg [2:0] state;
    localparam IDLE=0, W_ADDR=1, W_DATA=2, W_RESP=3, R_ADDR=4, R_DATA=5;

    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            state <= IDLE;
            AWVALID <= 0; WVALID <= 0; BREADY <= 0;
            ARVALID <= 0; RREADY <= 0;
        end else begin
            case (state)
                IDLE: begin
                    state <= W_ADDR;
                    AWADDR <= 32'h000; AWLEN <= 8'd0; AWVALID <= 1; // Start Write Address [11]
                end
                W_ADDR: if (AWREADY) begin
                    AWVALID <= 0;
                    WVALID <= 1; WDATA <= 32'hDEADBEEF; WLAST <= 1;
                    state <= W_DATA; // Move to Write Data [12]
                end
                W_DATA: if (WREADY) begin
                    WVALID <= 0; WLAST <= 0;
                    BREADY <= 1;
                    state <= W_RESP; // Wait for Response [13]
                end
                W_RESP: if (BVALID) begin
                    BREADY <= 0;
                    ARADDR <= 32'h000; ARLEN <= 8'd0; ARVALID <= 1;
                    state <= R_ADDR; // Start Read Address [14]
                end
                R_ADDR: if (ARREADY) begin
                    ARVALID <= 0;
                    RREADY <= 1;
                    state <= R_DATA; // Wait for Read Data [15]
                end
                R_DATA: if (RVALID) begin
                    RREADY <= 0;
                    state <= IDLE; // Transaction Complete
                end
            endcase
        end
    end
endmodule

module axi_slave (
    input  wire        ACLK,
    input  wire        ARESETn,

    // AW Channel
    input  wire [31:0] AWADDR,
    input  wire        AWVALID,
    output reg         AWREADY,

    // W Channel
    input  wire [31:0] WDATA,
    input  wire        WVALID,
    output reg         WREADY,

    // B Channel
    output reg  [1:0]  BRESP,
    output reg         BVALID,
    input  wire        BREADY,

    // AR Channel
    input  wire [31:0] ARADDR,
    input  wire        ARVALID,
    output reg         ARREADY,

    // R Channel
    output reg  [31:0] RDATA,
    output reg  [1:0]  RRESP,
    output reg         RVALID,
    output reg         RLAST,
    input  wire        RREADY
);

    reg [31:0] mem [0:255];
    reg [31:0] write_addr;

    // Handshake logic: Slave can wait for VALID before asserting READY [4]
    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            AWREADY <= 0; WREADY <= 0; BVALID <= 0;
            ARREADY <= 0; RVALID <= 0;
        end else begin
            // Write Path [1]
            if (AWVALID && !AWREADY) begin
                AWREADY <= 1;
                write_addr <= AWADDR;
            end else AWREADY <= 0;

            if (WVALID && !WREADY) begin
                WREADY <= 1;
                mem[write_addr[7:0]] <= WDATA;
            end else WREADY <= 0;

            if (WVALID && WREADY && !BVALID) begin
                BVALID <= 1;
                BRESP <= 2'b00; // OKAY [17]
            end else if (BREADY) BVALID <= 0;

            // Read Path [16]
            if (ARVALID && !ARREADY) begin
                ARREADY <= 1;
            end else ARREADY <= 0;

            if (ARVALID && ARREADY && !RVALID) begin
                RVALID <= 1;
                RDATA <= mem[ARADDR[7:0]];
                RRESP <= 2'b00; // OKAY
                RLAST <= 1;
            end else if (RREADY) RVALID <= 0;
        end
    end
endmodule

```

# Simulation
<img width="1627" height="881" alt="image" src="https://github.com/user-attachments/assets/f7a84f0e-ba5c-41e3-8cf5-f33f978d9896" />
