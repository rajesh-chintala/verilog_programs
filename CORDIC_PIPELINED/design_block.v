//design_1_wrapper
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
//Date        : Thu Dec  4 16:24:51 2025
//Host        : DESKTOP-PHFDVIO running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (clk);
  input clk;

  wire clk;

  design_1 design_1_i
       (.clk(clk));
endmodule

//design_1.v
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
//Date        : Thu Dec  4 16:24:51 2025
//Host        : DESKTOP-PHFDVIO running 64-bit major release  (build 9200)
//Command     : generate_target design_1.bd
//Design      : design_1
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "design_1,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=design_1,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=2,numReposBlks=2,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=1,numPkgbdBlks=0,bdsource=USER,synth_mode=Hierarchical}" *) (* HW_HANDOFF = "design_1.hwdef" *) 
module design_1
   (clk);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK, CLK_DOMAIN design_1_clk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input clk;

  wire clk_0_1;
  wire [25:0]main_0_z_deg;
  wire [19:0]main_0_z_out;
  wire [0:0]vio_0_probe_out0;
  wire [19:0]vio_0_probe_out1;

  assign clk_0_1 = clk;
  design_1_main_0_0 main_0
       (.clk(clk_0_1),
        .g(vio_0_probe_out1),
        .reset(vio_0_probe_out0),
        .z_deg(main_0_z_deg),
        .z_out(main_0_z_out));
  design_1_vio_0_0 vio_0
       (.clk(clk_0_1),
        .probe_in0(main_0_z_out),
        .probe_in1(main_0_z_deg),
        .probe_out0(vio_0_probe_out0),
        .probe_out1(vio_0_probe_out1));
endmodule
