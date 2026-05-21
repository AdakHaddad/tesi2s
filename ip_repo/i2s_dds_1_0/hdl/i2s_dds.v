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
    input  wire                            S_AXI_ACLK,
    input  wire                            S_AXI_ARESETN,
    input  wire [C_S00_AXI_ADDR_WIDTH-1:0]  S_AXI_AWADDR,
    input  wire [2:0]                      S_AXI_AWPROT,
    input  wire                            S_AXI_AWVALID,
    output wire                            S_AXI_AWREADY,
    input  wire [C_S00_AXI_DATA_WIDTH-1:0]  S_AXI_WDATA,
    input  wire [(C_S00_AXI_DATA_WIDTH/8)-1:0] S_AXI_WSTRB,
    input  wire                            S_AXI_WVALID,
    output wire                            S_AXI_WREADY,
    output wire [1:0]                      S_AXI_BRESP,
    output wire                            S_AXI_BVALID,
    input  wire                            S_AXI_BREADY,
    input  wire [C_S00_AXI_ADDR_WIDTH-1:0]  S_AXI_ARADDR,
    input  wire [2:0]                      S_AXI_ARPROT,
    input  wire                            S_AXI_ARVALID,
    output wire                            S_AXI_ARREADY,
    output wire [C_S00_AXI_DATA_WIDTH-1:0]  S_AXI_RDATA,
    output wire [1:0]                      S_AXI_RRESP,
    output wire                            S_AXI_RVALID,
    input  wire                            S_AXI_RREADY
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
        .S_AXI_ACLK        (S_AXI_ACLK),
        .S_AXI_ARESETN     (S_AXI_ARESETN),
        .S_AXI_AWADDR      (S_AXI_AWADDR),
        .S_AXI_AWPROT      (S_AXI_AWPROT),
        .S_AXI_AWVALID     (S_AXI_AWVALID),
        .S_AXI_AWREADY     (S_AXI_AWREADY),
        .S_AXI_WDATA       (S_AXI_WDATA),
        .S_AXI_WSTRB       (S_AXI_WSTRB),
        .S_AXI_WVALID      (S_AXI_WVALID),
        .S_AXI_WREADY      (S_AXI_WREADY),
        .S_AXI_BRESP       (S_AXI_BRESP),
        .S_AXI_BVALID      (S_AXI_BVALID),
        .S_AXI_BREADY      (S_AXI_BREADY),
        .S_AXI_ARADDR      (S_AXI_ARADDR),
        .S_AXI_ARPROT      (S_AXI_ARPROT),
        .S_AXI_ARVALID     (S_AXI_ARVALID),
        .S_AXI_ARREADY     (S_AXI_ARREADY),
        .S_AXI_RDATA       (S_AXI_RDATA),
        .S_AXI_RRESP       (S_AXI_RRESP),
        .S_AXI_RVALID      (S_AXI_RVALID),
        .S_AXI_RREADY      (S_AXI_RREADY)
    );

endmodule
