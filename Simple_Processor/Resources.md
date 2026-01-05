Test bench waveform for load instruction:
```

module tb_proc();

 reg  [7:0] Data;
 reg Reset, w, Clock;
 reg [1:0] F, Rx, Ry;
 wire [7:0] BusWires;
 wire  Done;
 
 proc dut(Data, Reset, w, Clock, F, Rx, Ry, Done, BusWires);
 
 initial begin 
 Clock = 1'b0;
 forever #5 Clock = ~Clock;
 end
 
 initial begin
 Reset = 1;
 w=0;
 F = 2'b00;
 Data = 8'd100;
 Rx = 2'b00;
 #10 Reset = 0;
 #10 w = 1;
 #10 w =0;
 
 #10 Reset = 1;
 F=2'b01;
 Ry = 2'b01;
 #10 Reset = 0;
 #10 w = 1;
 #10 w =0;
 #100
 $finish;
 end
endmodule
```
<img width="1909" height="1038" alt="image" src="https://github.com/user-attachments/assets/a014ce6b-2f2f-4f98-af94-bbd65b6b42d1" />
