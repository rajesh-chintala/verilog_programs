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
 Ry = 2'b00;
 Rx = 2'b01;
 #10 Reset = 0;
 #10 w = 1;
 #10 w =0;
 
 #10 Reset = 1;
 F = 2'b10;
 #10 Reset = 0;
 #10 w = 1;
 #10 w =0;
 
 #100
 
 #10 Reset = 1;
 F = 2'b11;
 #10 Reset = 0;
 #10 w = 1;
 #10 w =0;
 
 #100
 $finish;
 end
endmodule
```

Wave configuration files:
```
<?xml version="1.0" encoding="UTF-8"?>
<wave_config>
   <wave_state>
   </wave_state>
   <db_ref_list>
      <db_ref path="tb_proc_behav.wdb" id="1">
         <top_modules>
            <top_module name="glbl" />
            <top_module name="tb_proc" />
         </top_modules>
      </db_ref>
   </db_ref_list>
   <zoom_setting>
      <ZoomStartTime time="208.666 ns"></ZoomStartTime>
      <ZoomEndTime time="319.667 ns"></ZoomEndTime>
      <Cursor1Time time="350.000 ns"></Cursor1Time>
   </zoom_setting>
   <column_width_setting>
      <NameColumnWidth column_width="121"></NameColumnWidth>
      <ValueColumnWidth column_width="59"></ValueColumnWidth>
   </column_width_setting>
   <WVObjectSize size="33" />
   <wvobject fp_name="/tb_proc/dut/Clock" type="logic">
      <obj_property name="ElementShortName">Clock</obj_property>
      <obj_property name="ObjectShortName">Clock</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/Reset" type="logic">
      <obj_property name="ElementShortName">Reset</obj_property>
      <obj_property name="ObjectShortName">Reset</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/Done" type="logic">
      <obj_property name="ElementShortName">Done</obj_property>
      <obj_property name="ObjectShortName">Done</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/w" type="logic">
      <obj_property name="ElementShortName">w</obj_property>
      <obj_property name="ObjectShortName">w</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/T" type="array">
      <obj_property name="ElementShortName">T[0:3]</obj_property>
      <obj_property name="ObjectShortName">T[0:3]</obj_property>
      <obj_property name="Radix">BINARYRADIX</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/Clear" type="logic">
      <obj_property name="ElementShortName">Clear</obj_property>
      <obj_property name="ObjectShortName">Clear</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/Count" type="array">
      <obj_property name="ElementShortName">Count[1:0]</obj_property>
      <obj_property name="ObjectShortName">Count[1:0]</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/FRin" type="logic">
      <obj_property name="ElementShortName">FRin</obj_property>
      <obj_property name="ObjectShortName">FRin</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/Data" type="array">
      <obj_property name="ElementShortName">Data[7:0]</obj_property>
      <obj_property name="ObjectShortName">Data[7:0]</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/F" type="array">
      <obj_property name="ElementShortName">F[1:0]</obj_property>
      <obj_property name="ObjectShortName">F[1:0]</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/Rx" type="array">
      <obj_property name="ElementShortName">Rx[1:0]</obj_property>
      <obj_property name="ObjectShortName">Rx[1:0]</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/Ry" type="array">
      <obj_property name="ElementShortName">Ry[1:0]</obj_property>
      <obj_property name="ObjectShortName">Ry[1:0]</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/Func" type="array">
      <obj_property name="ElementShortName">Func[1:6]</obj_property>
      <obj_property name="ObjectShortName">Func[1:6]</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/FuncReg" type="array">
      <obj_property name="ElementShortName">FuncReg[1:6]</obj_property>
      <obj_property name="ObjectShortName">FuncReg[1:6]</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/I" type="array">
      <obj_property name="ElementShortName">I[0:3]</obj_property>
      <obj_property name="ObjectShortName">I[0:3]</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/Xreg" type="array">
      <obj_property name="ElementShortName">Xreg[0:3]</obj_property>
      <obj_property name="ObjectShortName">Xreg[0:3]</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/Y" type="array">
      <obj_property name="ElementShortName">Y[0:3]</obj_property>
      <obj_property name="ObjectShortName">Y[0:3]</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/Rin" type="array">
      <obj_property name="ElementShortName">Rin[0:3]</obj_property>
      <obj_property name="ObjectShortName">Rin[0:3]</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/Rout" type="array">
      <obj_property name="ElementShortName">Rout[0:3]</obj_property>
      <obj_property name="ObjectShortName">Rout[0:3]</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/Extern" type="logic">
      <obj_property name="ElementShortName">Extern</obj_property>
      <obj_property name="ObjectShortName">Extern</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/Ain" type="logic">
      <obj_property name="ElementShortName">Ain</obj_property>
      <obj_property name="ObjectShortName">Ain</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/Gin" type="logic">
      <obj_property name="ElementShortName">Gin</obj_property>
      <obj_property name="ObjectShortName">Gin</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/Gout" type="logic">
      <obj_property name="ElementShortName">Gout</obj_property>
      <obj_property name="ObjectShortName">Gout</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/AddSub" type="logic">
      <obj_property name="ElementShortName">AddSub</obj_property>
      <obj_property name="ObjectShortName">AddSub</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/BusWires" type="array">
      <obj_property name="ElementShortName">BusWires[7:0]</obj_property>
      <obj_property name="ObjectShortName">BusWires[7:0]</obj_property>
      <obj_property name="Radix">UNSIGNEDDECRADIX</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/Sum" type="array">
      <obj_property name="ElementShortName">Sum[7:0]</obj_property>
      <obj_property name="ObjectShortName">Sum[7:0]</obj_property>
      <obj_property name="Radix">UNSIGNEDDECRADIX</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/R0" type="array">
      <obj_property name="ElementShortName">R0[7:0]</obj_property>
      <obj_property name="ObjectShortName">R0[7:0]</obj_property>
      <obj_property name="Radix">UNSIGNEDDECRADIX</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/R1" type="array">
      <obj_property name="ElementShortName">R1[7:0]</obj_property>
      <obj_property name="ObjectShortName">R1[7:0]</obj_property>
      <obj_property name="Radix">UNSIGNEDDECRADIX</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/R2" type="array">
      <obj_property name="ElementShortName">R2[7:0]</obj_property>
      <obj_property name="ObjectShortName">R2[7:0]</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/R3" type="array">
      <obj_property name="ElementShortName">R3[7:0]</obj_property>
      <obj_property name="ObjectShortName">R3[7:0]</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/A" type="array">
      <obj_property name="ElementShortName">A[7:0]</obj_property>
      <obj_property name="ObjectShortName">A[7:0]</obj_property>
      <obj_property name="Radix">UNSIGNEDDECRADIX</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/G" type="array">
      <obj_property name="ElementShortName">G[7:0]</obj_property>
      <obj_property name="ObjectShortName">G[7:0]</obj_property>
      <obj_property name="Radix">UNSIGNEDDECRADIX</obj_property>
   </wvobject>
   <wvobject fp_name="/tb_proc/dut/k" type="array">
      <obj_property name="ElementShortName">k[31:0]</obj_property>
      <obj_property name="ObjectShortName">k[31:0]</obj_property>
      <obj_property name="Radix">UNSIGNEDDECRADIX</obj_property>
   </wvobject>
</wave_config>
```

<img width="1918" height="1036" alt="image" src="https://github.com/user-attachments/assets/723340a4-e084-4d2e-92a0-0b9e47ac8f0e" />

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
