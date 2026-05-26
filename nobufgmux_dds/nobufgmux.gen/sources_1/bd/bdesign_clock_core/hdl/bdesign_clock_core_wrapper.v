//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.2 (win64) Build 6299465 Fri Nov 14 19:35:11 GMT 2025
//Date        : Thu May 21 20:43:07 2026
//Host        : DESKTOP-HTVV1N1 running 64-bit major release  (build 9200)
//Command     : generate_target bdesign_clock_core_wrapper.bd
//Design      : bdesign_clock_core_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module bdesign_clock_core_wrapper
   (i2s_bclk_0,
    i2s_data_0,
    i2s_mclk_0,
    i2s_ws_0,
    reset,
    sys_clock,
    usb_uart_rxd,
    usb_uart_txd);
  output i2s_bclk_0;
  output i2s_data_0;
  output i2s_mclk_0;
  output i2s_ws_0;
  input reset;
  input sys_clock;
  input usb_uart_rxd;
  output usb_uart_txd;

  wire i2s_bclk_0;
  wire i2s_data_0;
  wire i2s_mclk_0;
  wire i2s_ws_0;
  wire reset;
  wire sys_clock;
  wire usb_uart_rxd;
  wire usb_uart_txd;

  bdesign_clock_core bdesign_clock_core_i
       (.i2s_bclk_0(i2s_bclk_0),
        .i2s_data_0(i2s_data_0),
        .i2s_mclk_0(i2s_mclk_0),
        .i2s_ws_0(i2s_ws_0),
        .reset(reset),
        .sys_clock(sys_clock),
        .usb_uart_rxd(usb_uart_rxd),
        .usb_uart_txd(usb_uart_txd));
endmodule
