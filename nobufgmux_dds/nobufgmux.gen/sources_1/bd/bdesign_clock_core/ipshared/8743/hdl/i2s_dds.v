`timescale 1 ns / 1 ps

// ============================================================================
// Module      : i2s
// Description : I2S slave AXI4-Lite peripheral wrapper.
//               Passes all ports through to the i2s_slave_lite_v1_0_S00_AXI core.
//
// Dual clock input design:
//   - audio_48_clk : 24.576 MHz for 48/96 kHz sample rate family
//   - audio_44_clk : 22.579 MHz for 44.1/88.2 kHz sample rate family
//   - Clock selection via FS_FAMILY bit in CONTROL register
//   - No vendor-specific primitives (portable to ASIC)
// ============================================================================

module i2s_dds #
(
    parameter integer C_S00_AXI_DATA_WIDTH = 32,
    parameter integer C_S00_AXI_ADDR_WIDTH = 4
)
(
    // Audio clock inputs — both must be running before ENABLE is asserted.
    // Provided by the MMCM/PLL Clock Wizard in the top-level block design.
    input  wire audio_48_clk,   // 24.576 MHz — 48/96 kHz Fs family
    input  wire audio_44_clk,   // 22.579 MHz — 44.1/88.2 kHz Fs family

    // I2S serial outputs — connect directly to PCM5102A PMOD pins.
    // MCLK is driven but the PCM5102A can operate without it (SCK mode).
    output wire i2s_mclk,
    output wire i2s_bclk,
    output wire i2s_ws,
    output wire i2s_data,

    // AXI4-Lite slave interface
    input  wire                            s00_axi_aclk,
    input  wire                            s00_axi_aresetn,
    input  wire [C_S00_AXI_ADDR_WIDTH-1:0] s00_axi_awaddr,
    input  wire [2:0]                      s00_axi_awprot,
    input  wire                            s00_axi_awvalid,
    output wire                            s00_axi_awready,
    input  wire [C_S00_AXI_DATA_WIDTH-1:0] s00_axi_wdata,
    input  wire [(C_S00_AXI_DATA_WIDTH/8)-1:0] s00_axi_wstrb,
    input  wire                            s00_axi_wvalid,
    output wire                            s00_axi_wready,
    output wire [1:0]                      s00_axi_bresp,
    output wire                            s00_axi_bvalid,
    input  wire                            s00_axi_bready,
    input  wire [C_S00_AXI_ADDR_WIDTH-1:0] s00_axi_araddr,
    input  wire [2:0]                      s00_axi_arprot,
    input  wire                            s00_axi_arvalid,
    output wire                            s00_axi_arready,
    output wire [C_S00_AXI_DATA_WIDTH-1:0] s00_axi_rdata,
    output wire [1:0]                      s00_axi_rresp,
    output wire                            s00_axi_rvalid,
    input  wire                            s00_axi_rready
);

    // Instantiate the I2S core
    i2s_dds_slave_lite_v1_0_S00_AXI #(
        .C_S00_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
        .C_S00_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
    ) i2s_dds_slave_lite_v1_0_S00_AXI_inst (
        .audio_48_clk      (audio_48_clk),
        .audio_44_clk      (audio_44_clk),
        .i2s_mclk          (i2s_mclk),
        .i2s_bclk          (i2s_bclk),
        .i2s_ws            (i2s_ws),
        .i2s_data          (i2s_data),
        .S_AXI_ACLK        (s00_axi_aclk),
        .S_AXI_ARESETN     (s00_axi_aresetn),
        .S_AXI_AWADDR      (s00_axi_awaddr),
        .S_AXI_AWPROT      (s00_axi_awprot),
        .S_AXI_AWVALID     (s00_axi_awvalid),
        .S_AXI_AWREADY     (s00_axi_awready),
        .S_AXI_WDATA       (s00_axi_wdata),
        .S_AXI_WSTRB       (s00_axi_wstrb),
        .S_AXI_WVALID      (s00_axi_wvalid),
        .S_AXI_WREADY      (s00_axi_wready),
        .S_AXI_BRESP       (s00_axi_bresp),
        .S_AXI_BVALID      (s00_axi_bvalid),
        .S_AXI_BREADY      (s00_axi_bready),
        .S_AXI_ARADDR      (s00_axi_araddr),
        .S_AXI_ARPROT      (s00_axi_arprot),
        .S_AXI_ARVALID     (s00_axi_arvalid),
        .S_AXI_ARREADY     (s00_axi_arready),
        .S_AXI_RDATA       (s00_axi_rdata),
        .S_AXI_RRESP       (s00_axi_rresp),
        .S_AXI_RVALID      (s00_axi_rvalid),
        .S_AXI_RREADY      (s00_axi_rready)
    );

endmodule
