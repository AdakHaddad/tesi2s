`timescale 1 ns / 1 ps

// ============================================================================
// Module      : i2s_axi_lite
// Description : AXI4-Lite controlled I2S transmitter peripheral.
//
//   This module integrates two sections:
//     1. AXI4-Lite slave interface — generated from the standard Xilinx
//        IP-packager template (aw_en handshake style).
//     2. I2S audio serializer — driven by a DDS (Direct Digital Synthesis)
//        phase accumulator that generates BCLK and MCLK from the AXI system
//        clock, avoiding any external audio clock dependency.
//
//   The firmware programming model is simple:
//     - Write PCM samples to DATA_LEFT and DATA_RIGHT.
//     - Write CONTROL with ENABLE=1, desired sample rate, and sample width.
//     - Poll STATUS[0] to detect each new stereo-frame latch.
//
// ----------------------------------------------------------------------------
// Register Map
// ----------------------------------------------------------------------------
//   Offset   Name         Dir   Description
//   0x00     DATA_LEFT    R/W   Left-channel  PCM sample  (right-justified)
//   0x04     DATA_RIGHT   R/W   Right-channel PCM sample  (right-justified)
//   0x08     CONTROL      R/W   Bitfield — see below
//   0x0C     STATUS       R/W   Bit 0: toggles on every stereo-frame latch
//
// ----------------------------------------------------------------------------
// CONTROL Bitfield  (offset 0x08)
// ----------------------------------------------------------------------------
//   Bit(s)   Field            Default    Description
//   0        ENABLE           0          1 = transmit I2S; 0 = hold outputs low
//   1        MUTE             0          1 = send zeros while clocks keep running
//   6:2      SAMPLE_WIDTH     0 (=32b)   Payload bits per channel.
//                                        Values 1-31 are literal bit-widths.
//                                        Value 0 encodes 32 bits (field is 5 b).
//   26:7     SAMPLE_RATE_HZ   48000      Target sample rate in Hz.
//                                        Encoded range is 0..1,048,575 Hz.
//                                        Value 0 defaults to 48000 Hz.
//                                        Capped at MAX_SAFE_FS_HZ (195312 Hz).
//   31:27    RESERVED         0          Ignored on write; read as zero.
//
// ----------------------------------------------------------------------------
// I2S Protocol Notes
// ----------------------------------------------------------------------------
//   - Standard I2S (Philips): WS low = left, WS high = right.
//   - WS transitions one BCLK *before* the MSB of each channel.
//   - BCLK = 64 × Fs  (32 bits per channel × 2 channels).
//   - MCLK = 256 × Fs (optional; provided for DACs that need it).
//
// ----------------------------------------------------------------------------
// Clocking
// ----------------------------------------------------------------------------
//   All logic runs on S_AXI_ACLK (typically 100 MHz from the PS/PL).
//   BCLK and MCLK are synthesised via DDS phase accumulators so no external
//   audio PLL is required. The audio_48_clk and audio_44_clk ports are
//   accepted but deliberately left unused (tied to a dummy XOR to suppress
//   undriven-input lint warnings) for block-design back-compatibility.
//
// ============================================================================

module i2s_dds_slave_lite_v1_0_S00_AXI #
(
    // Width of AXI data bus — keep at 32 for a 32-bit address map.
    parameter integer C_S_AXI_DATA_WIDTH = 32,

    // Width of AXI address bus — 4 bits covers 16 bytes = four 32-bit regs.
    parameter integer C_S_AXI_ADDR_WIDTH = 4
)
(
    // ------------------------------------------------------------------
    // I2S output pins
    // ------------------------------------------------------------------
    output wire i2s_mclk,       // Master clock  (256 × Fs)
    output wire i2s_bclk,       // Bit clock     ( 64 × Fs)
    output wire i2s_ws,         // Word select / LR clock (Fs)
    output wire i2s_data,       // Serial data   (MSB-first, left-justified)

    // ------------------------------------------------------------------
    // AXI4-Lite slave interface
    // ------------------------------------------------------------------

    // Global clock and active-low reset
    input  wire                                     S_AXI_ACLK,
    input  wire                                     S_AXI_ARESETN,

    // Write address channel
    input  wire [C_S_AXI_ADDR_WIDTH-1:0]            S_AXI_AWADDR,
    input  wire [2:0]                               S_AXI_AWPROT,
    input  wire                                     S_AXI_AWVALID,
    output wire                                     S_AXI_AWREADY,

    // Write data channel
    input  wire [C_S_AXI_DATA_WIDTH-1:0]            S_AXI_WDATA,
    input  wire [(C_S_AXI_DATA_WIDTH/8)-1:0]        S_AXI_WSTRB,
    input  wire                                     S_AXI_WVALID,
    output wire                                     S_AXI_WREADY,

    // Write response channel
    output wire [1:0]                               S_AXI_BRESP,
    output wire                                     S_AXI_BVALID,
    input  wire                                     S_AXI_BREADY,

    // Read address channel
    input  wire [C_S_AXI_ADDR_WIDTH-1:0]            S_AXI_ARADDR,
    input  wire [2:0]                               S_AXI_ARPROT,
    input  wire                                     S_AXI_ARVALID,
    output wire                                     S_AXI_ARREADY,

    // Read data channel
    output wire [C_S_AXI_DATA_WIDTH-1:0]            S_AXI_RDATA,
    output wire [1:0]                               S_AXI_RRESP,
    output wire                                     S_AXI_RVALID,
    input  wire                                     S_AXI_RREADY
);

// ============================================================================
// Section 1 — Local Parameters
// ============================================================================

    // ADDR_LSB: number of byte-address LSBs to strip when indexing word regs.
    //   For a 32-bit data bus: ADDR_LSB = (32/32)+1 = 2  → byte offsets 0,4,8,C
    //   For a 64-bit data bus: ADDR_LSB = (64/32)+1 = 3
    localparam integer ADDR_LSB          = (C_S_AXI_DATA_WIDTH/32) + 1;

    // OPT_MEM_ADDR_BITS: number of register-index bits above ADDR_LSB.
    //   With 4 regs (2-bit index) and ADDR_LSB=2 → bits [3:2] select the reg.
    localparam integer OPT_MEM_ADDR_BITS = 1;

    // Register address indices (2-bit, selects one of four 32-bit registers)
    localparam [1:0] REG_DATA_LEFT  = 2'h0;  // 0x00
    localparam [1:0] REG_DATA_RIGHT = 2'h1;  // 0x04
    localparam [1:0] REG_CONTROL    = 2'h2;  // 0x08
    localparam [1:0] REG_STATUS     = 2'h3;  // 0x0C

    // CONTROL register bitfield map (offset 0x08)
    localparam integer CTRL_ENABLE_BIT         = 0;
    localparam integer CTRL_MUTE_BIT           = 1;
    localparam integer CTRL_SAMPLE_WIDTH_LSB   = 2;
    localparam integer CTRL_SAMPLE_WIDTH_MSB   = 6;
    localparam integer CTRL_SAMPLE_RATE_HZ_LSB = 7;
    localparam integer CTRL_SAMPLE_RATE_HZ_MSB = 26;
    localparam integer CTRL_RESERVED_MSB       = 31;
    localparam integer CTRL_RESERVED_LSB       = 27;

    // Read mask for CONTROL: zero-out RESERVED bits [31:27] on readback
    localparam [31:0] CONTROL_MASK    = 32'h07FF_FFFF;

    // Default CONTROL value after reset: ENABLE=0, MUTE=0, WIDTH=0(→32),
    // SAMPLE_RATE_HZ=48000 encoded in bits [26:7]
    localparam [31:0] DEFAULT_CONTROL = (32'd48000 << 7);

    // AXI system clock frequency — must match actual PL clock for DDS math.
    localparam [31:0] AXI_CLK_HZ = 32'd100_000_000;

    // DDS constants derived from Fs:
    //   bclk_toggle_rate = Fs × 64  (BCLK = 2 edges × 32 bits × 2 ch)
    //   mclk_toggle_rate = Fs × 256 (MCLK = 4× BCLK, standard 256×Fs)
    // These are computed combinatorially from sample_rate_sync below.

    // Safety cap: at AXI_CLK_HZ = 100 MHz, BCLK max toggle = 50 MHz
    //   → max Fs = 50e6 / 64 ≈ 781 kHz, but we cap conservatively at ~195 kHz
    //   to keep BCLK well inside the 50 MHz Nyquist limit.
    localparam [19:0] DEFAULT_SAMPLE_RATE_HZ = 20'd48000;
    localparam [19:0] MAX_SAFE_FS_HZ         = 20'd195312;

// ============================================================================
// Section 2 — AXI4-Lite Internal Signals  (standard Xilinx template signals)
// ============================================================================

    // --- Write channel handshake registers ---
    reg [C_S_AXI_ADDR_WIDTH-1:0] axi_awaddr;   // latched write address
    reg                           axi_awready;  // AWREADY output register
    reg                           axi_wready;   // WREADY  output register
    reg [1:0]                     axi_bresp;    // write response (always OKAY)
    reg                           axi_bvalid;   // BVALID output register
    reg                           aw_en;        // write-address "enable" token
                                                // (prevents double-latching)

    // --- Read channel handshake registers ---
    reg [C_S_AXI_ADDR_WIDTH-1:0]  axi_araddr;  // latched read address
    reg                            axi_arready; // ARREADY output register
    reg [1:0]                      axi_rresp;   // read response
    reg                            axi_rvalid;  // RVALID output register
    reg [C_S_AXI_DATA_WIDTH-1:0]   axi_rdata;  // RDATA output register

    // --- Slave register file (four 32-bit registers) ---
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg0;  // DATA_LEFT
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg1;  // DATA_RIGHT
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg2;  // CONTROL
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg3;  // STATUS

    integer byte_index; // loop variable for byte-strobe write logic

    // Combined write/read enable strobes (single-cycle pulses)
    wire slv_reg_wren;
    wire slv_reg_rden;

    // Decoded register indices from latched addresses
    wire [1:0] write_addr = axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS : ADDR_LSB];
    wire [1:0] read_addr  = axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS : ADDR_LSB];

    // Combinatorial read-data mux output (registered into axi_rdata on rden)
    reg [C_S_AXI_DATA_WIDTH-1:0] reg_data_out;

// ============================================================================
// Section 3 — AXI4-Lite Output Assignments  (wire outputs from regs)
// ============================================================================

    assign S_AXI_AWREADY = axi_awready;
    assign S_AXI_WREADY  = axi_wready;
    assign S_AXI_BRESP   = axi_bresp;
    assign S_AXI_BVALID  = axi_bvalid;
    assign S_AXI_ARREADY = axi_arready;
    assign S_AXI_RDATA   = axi_rdata;
    assign S_AXI_RRESP   = axi_rresp;
    assign S_AXI_RVALID  = axi_rvalid;

// ============================================================================
// Section 4 — Write Enable Strobe
//
//   slv_reg_wren pulses HIGH for exactly one cycle when all four write-channel
//   handshake signals are simultaneously asserted (template standard).
// ============================================================================

    assign slv_reg_wren = axi_wready && S_AXI_WVALID &&
                          axi_awready && S_AXI_AWVALID;

// ============================================================================
// Section 5 — Read Enable Strobe
//
//   slv_reg_rden pulses HIGH for exactly one cycle when the read address is
//   valid and the slave has not yet asserted RVALID for that transaction.
// ============================================================================

    assign slv_reg_rden = axi_arready && S_AXI_ARVALID && !axi_rvalid;

// ============================================================================
// Section 6 — AWREADY / WREADY Generation  (standard Xilinx aw_en pattern)
//
//   aw_en acts as a one-shot token: it is released (set to 0) as soon as the
//   write address is accepted and is not re-armed until the master accepts the
//   BRESP.  This prevents AWADDR being overwritten mid-transaction and avoids
//   outstanding write ambiguity in a single-outstanding-transaction slave.
// ============================================================================

    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            // On reset: no handshake active, aw_en re-armed to accept first txn
            axi_awready <= 1'b0;
            aw_en       <= 1'b1;
        end else begin
            if (!axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en) begin
                // Both AWVALID and WVALID present simultaneously → latch address
                // and assert AWREADY for one cycle.
                axi_awready <= 1'b1;
                axi_awaddr  <= S_AXI_AWADDR;
                aw_en       <= 1'b0;    // consume the token
            end else if (S_AXI_BREADY && axi_bvalid) begin
                // Master accepted BRESP → re-arm for next transaction
                aw_en       <= 1'b1;
                axi_awready <= 1'b0;
            end else begin
                // AWREADY is a one-cycle pulse; deassert next cycle
                axi_awready <= 1'b0;
            end
        end
    end

    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            axi_wready <= 1'b0;
        end else begin
            if (!axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en)
                // Assert WREADY for one cycle alongside AWREADY
                axi_wready <= 1'b1;
            else
                axi_wready <= 1'b0;
        end
    end

// ============================================================================
// Section 7 — Register Write Logic  (byte-strobe aware)
//
//   When slv_reg_wren pulses, the addressed register is updated one byte at a
//   time according to S_AXI_WSTRB.  This allows firmware to do partial-word
//   writes (e.g., updating only the high byte of CONTROL).
//
//   CONTROL[31:27] is always forced to zero after any write to enforce the
//   RESERVED-bits contract.
// ============================================================================

    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            // Reset to safe defaults: no audio output, 48 kHz, 32-bit width
            slv_reg0 <= 32'd0;            // DATA_LEFT  = 0
            slv_reg1 <= 32'd0;            // DATA_RIGHT = 0
            slv_reg2 <= DEFAULT_CONTROL;  // CONTROL    = 48000 Hz, disabled
            slv_reg3 <= 32'd0;            // STATUS     = 0
        end else if (slv_reg_wren) begin
            case (write_addr)

                REG_DATA_LEFT: begin
                    // Update left-channel sample, byte-by-byte per WSTRB
                    for (byte_index = 0;
                         byte_index <= (C_S_AXI_DATA_WIDTH/8)-1;
                         byte_index = byte_index + 1)
                        if (S_AXI_WSTRB[byte_index])
                            slv_reg0[(byte_index*8) +: 8] <=
                                S_AXI_WDATA[(byte_index*8) +: 8];
                end

                REG_DATA_RIGHT: begin
                    // Update right-channel sample, byte-by-byte per WSTRB
                    for (byte_index = 0;
                         byte_index <= (C_S_AXI_DATA_WIDTH/8)-1;
                         byte_index = byte_index + 1)
                        if (S_AXI_WSTRB[byte_index])
                            slv_reg1[(byte_index*8) +: 8] <=
                                S_AXI_WDATA[(byte_index*8) +: 8];
                end

                REG_CONTROL: begin
                    // Update control register, then zero RESERVED bits [31:27]
                    for (byte_index = 0;
                         byte_index <= (C_S_AXI_DATA_WIDTH/8)-1;
                         byte_index = byte_index + 1)
                        if (S_AXI_WSTRB[byte_index])
                            slv_reg2[(byte_index*8) +: 8] <=
                                S_AXI_WDATA[(byte_index*8) +: 8];
                    slv_reg2[CTRL_RESERVED_MSB:CTRL_RESERVED_LSB] <= 5'd0;  // enforce RESERVED = 0
                end

                REG_STATUS: begin
                    // STATUS is mostly hardware-driven; firmware may write bits
                    // it owns (none currently) — full byte-strobe update here
                    for (byte_index = 0;
                         byte_index <= (C_S_AXI_DATA_WIDTH/8)-1;
                         byte_index = byte_index + 1)
                        if (S_AXI_WSTRB[byte_index])
                            slv_reg3[(byte_index*8) +: 8] <=
                                S_AXI_WDATA[(byte_index*8) +: 8];
                end

            endcase
        end
    end

// ============================================================================
// Section 8 — Write Response (BRESP) Generation
//
//   Assert BVALID one cycle after the write completes (slv_reg_wren).
//   BRESP is always 2'b00 (OKAY) — this slave has no error detection.
//   Deassert BVALID once master accepts via BREADY.
// ============================================================================

    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            axi_bvalid <= 1'b0;
            axi_bresp  <= 2'b00;
        end else begin
            if (slv_reg_wren && !axi_bvalid) begin
                axi_bvalid <= 1'b1;
                axi_bresp  <= 2'b00;  // OKAY
            end else if (S_AXI_BREADY && axi_bvalid) begin
                axi_bvalid <= 1'b0;
            end
        end
    end

// ============================================================================
// Section 9 — ARREADY Generation  (read address channel)
//
//   Assert ARREADY for one cycle when ARVALID arrives; latch the address.
// ============================================================================

    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            axi_arready <= 1'b0;
            axi_araddr  <= {C_S_AXI_ADDR_WIDTH{1'b0}};
        end else begin
            if (!axi_arready && S_AXI_ARVALID) begin
                // Accept address; ARREADY is a one-cycle pulse
                axi_arready <= 1'b1;
                axi_araddr  <= S_AXI_ARADDR;
            end else begin
                axi_arready <= 1'b0;
            end
        end
    end

// ============================================================================
// Section 10 — Read Data Mux  (combinatorial)
//
//   Selects the appropriate register for the latched read address.
//   CONTROL is masked to zero RESERVED bits on readback.
//   STATUS[0] reflects the hardware-driven latch-toggle bit.
// ============================================================================

    always @(*) begin
        case (read_addr)
            REG_DATA_LEFT:  reg_data_out = slv_reg0;
            REG_DATA_RIGHT: reg_data_out = slv_reg1;
            REG_CONTROL:    reg_data_out = slv_reg2 & CONTROL_MASK;
            REG_STATUS:     reg_data_out = {slv_reg3[31:1],
                                            current_latch_status_q};
            default:        reg_data_out = 32'd0;
        endcase
    end

// ============================================================================
// Section 11 — RVALID / RDATA Generation  (read data channel)
//
//   Register the mux output into axi_rdata on slv_reg_rden.
//   Deassert RVALID once master accepts via RREADY.
// ============================================================================

    always @(posedge S_AXI_ACLK) begin
        if (!S_AXI_ARESETN) begin
            axi_rvalid <= 1'b0;
            axi_rresp  <= 2'b00;
            axi_rdata  <= 32'd0;
        end else begin
            if (slv_reg_rden) begin
                axi_rvalid <= 1'b1;
                axi_rresp  <= 2'b00;         // OKAY
                axi_rdata  <= reg_data_out;  // capture the mux output
            end else if (axi_rvalid && S_AXI_RREADY) begin
                axi_rvalid <= 1'b0;
            end
        end
    end

// ============================================================================
// Section 12 — Control Register Decode
//
//   Extract and sanitise individual fields from the CONTROL register.
//   All of these are directly sourced from slv_reg2 (same clock domain).
// ============================================================================

    // Bit 0: transmit enable
    wire        enable_sync = slv_reg2[CTRL_ENABLE_BIT];

    // Bit 1: mute — keeps clocks running but sends zeros
    wire        mute_sync   = slv_reg2[CTRL_MUTE_BIT];

    // Bits [6:2]: sample width in bits per channel.
    //   A raw value of 0 encodes 32 bits (field is only 5 bits wide).
    wire [4:0]  sample_width_raw  = slv_reg2[CTRL_SAMPLE_WIDTH_MSB:CTRL_SAMPLE_WIDTH_LSB];
    wire [5:0]  sample_width_sync = (sample_width_raw == 5'd0) ? 6'd32
                                                                : {1'b0, sample_width_raw};

    // Bits [26:7]: target sample rate in Hz.
    //   0 → default to 48000 Hz.  Values above MAX_SAFE_FS_HZ are capped.
    wire [19:0] sample_rate_raw     = slv_reg2[CTRL_SAMPLE_RATE_HZ_MSB:CTRL_SAMPLE_RATE_HZ_LSB];
    wire [19:0] sample_rate_nonzero = (sample_rate_raw == 20'd0)
                                      ? DEFAULT_SAMPLE_RATE_HZ
                                      : sample_rate_raw;
    wire [19:0] sample_rate_sync    = (sample_rate_nonzero > MAX_SAFE_FS_HZ)
                                      ? MAX_SAFE_FS_HZ
                                      : sample_rate_nonzero;

// ============================================================================
// Section 13 — DDS Phase Accumulator Setup
//
//   DDS principle: each cycle add a "frequency word" to a 32-bit accumulator.
//   When the accumulator wraps past AXI_CLK_HZ, one toggle of the output
//   clock has elapsed.  This gives a fractional-divider effect without a PLL.
//
//   BCLK frequency = Fs × 64  (64 BCLKs per stereo frame: 2 ch × 32 bits)
//   MCLK frequency = Fs × 256 (256× oversampling, common for I2S DACs)
//
//   The frequency words are computed by shifting sample_rate_sync:
//     bclk_toggle_rate = sample_rate_sync << 6   (× 64)
//     mclk_toggle_rate = sample_rate_sync << 8   (× 256)
//   These are the per-cycle increment values for their accumulators.
//
//   Note: "toggle" because each accumulator wrap causes one clock edge, so
//   the actual output frequency is toggle_rate_hz / 2 for a 50% duty cycle.
//   We compensate by doubling the multiplier:
//     BCLK toggles at 2 × Fs × 64  → BCLK period = Fs × 64
// ============================================================================

    // Frequency words (increments per AXI clock cycle)
    wire [31:0] bclk_toggle_rate_hz = {sample_rate_sync, 7'b0};   // Fs × 128
    wire [31:0] mclk_toggle_rate_hz = {sample_rate_sync, 9'b0};   // Fs × 512

    // Next-cycle accumulator values (pre-compute to check for wrap)
    wire [31:0] bclk_phase_sum = bclk_phase_acc_q + bclk_toggle_rate_hz;
    wire [31:0] mclk_phase_sum = mclk_phase_acc_q + mclk_toggle_rate_hz;

    // Wrap detects: did the sum pass the AXI clock period?
    wire bclk_phase_wrap = (bclk_phase_sum >= AXI_CLK_HZ);
    wire mclk_phase_wrap = (mclk_phase_sum >= AXI_CLK_HZ);

// ============================================================================
// Section 14 — I2S Internal State Registers
// ============================================================================

    reg [31:0] bclk_phase_acc_q;   // BCLK DDS accumulator
    reg [31:0] mclk_phase_acc_q;   // MCLK DDS accumulator

    // Bit counter: counts 0..63 across one full stereo I2S frame.
    //   0..31  = left  channel (WS low)
    //   32..63 = right channel (WS high)
    reg [5:0]  bit_count_q;

    // Latched PCM samples — loaded at the start of each frame (bit_count==0,
    // bclk rising edge) so both channels are phase-coherent.
    reg [31:0] sample_left_q;
    reg [31:0] sample_right_q;

    // Clock and data output registers
    reg        mclk_q;
    reg        bclk_q;
    reg        ws_q;
    reg        data_q;

    // STATUS register bit 0: toggles on every sample latch event.
    // Firmware can poll this (or detect toggle) to know a new frame started.
    reg        current_latch_status_q;

// ============================================================================
// Section 15 — Mute Mux
//
//   When MUTE=1, substitute zero for both channels so the I2S stream
//   continues (clocks stay active) but no audio is output.  This is
//   useful for smooth transitions without click noise on abrupt enable/disable.
// ============================================================================

    wire [31:0] sample_for_i2s_left  = mute_sync ? 32'd0 : sample_left_q;
    wire [31:0] sample_for_i2s_right = mute_sync ? 32'd0 : sample_right_q;

// ============================================================================
// Section 16 — I2S Next-Bit Serializer Function
//
//   Pure combinatorial: given the current bit_count and sample data, returns
//   the data bit to place on i2s_data for the *next* BCLK falling edge.
//
//   I2S timing (Philips standard):
//     bit_count = 0  → WS transition + padding bit (always 0)
//     bit_count = 1..width   → MSB-first payload bits
//     bit_count = width+1..31 → padding zeros (if width < 32)
//     bit_count = 32 → WS transition + padding (right channel)
//     bit_count = 33..(32+width) → right-channel MSB-first payload
//     bit_count = (32+width+1)..63 → padding zeros
//
//   Function parameters:
//     left_samp  — latched left sample
//     right_samp — latched right sample
//     bc         — current bit_count value (6-bit, 0..63)
//     width      — active sample bit-width (1..32)
// ============================================================================

    function i2s_next_serial_bit;
        input [31:0] left_samp;
        input [31:0] right_samp;
        input [5:0]  bc;
        input [5:0]  width;
        reg          in_left;   // 1 = left channel, 0 = right channel
        reg [4:0]    pos;       // position within the 32-slot channel window
        reg [5:0]    bit_idx;   // index into sample register
        begin
            in_left = (bc < 6'd32);     // left half of frame
            pos     = bc[4:0];          // position within current channel

            if (pos == 5'd0) begin
                // Slot 0 is the WS-transition gap bit — always 0 (I2S delay)
                i2s_next_serial_bit = 1'b0;
            end else if (pos <= width) begin
                // Active payload bit — MSB first.
                // pos=1 → MSB = sample[width-1]
                // pos=width → LSB = sample[0]
                bit_idx = width - {1'b0, pos};
                i2s_next_serial_bit = in_left ? left_samp[bit_idx[4:0]]
                                              : right_samp[bit_idx[4:0]];
            end else begin
                // Beyond payload width — zero padding
                i2s_next_serial_bit = 1'b0;
            end
        end
    endfunction

// ============================================================================
// Section 17 — Main I2S Sequencer  (DDS-clocked, runs on S_AXI_ACLK)
//
//   All I2S outputs (BCLK, WS, DATA) are generated here by toggling registers
//   only when the corresponding DDS accumulator wraps.  This ensures accurate
//   frequency synthesis across a wide range of Fs values.
//
//   On each AXI clock edge where bclk_phase_wrap is true, the BCLK output
//   toggles.  We use the previous bclk_q state to determine which half-cycle:
//     bclk_q == 1 → falling edge: advance bit_count, update DATA and WS
//     bclk_q == 0 → rising edge:  latch new samples at start of frame
// ============================================================================

    always @(posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
        if (!S_AXI_ARESETN) begin
            // Synchronous active-low reset — clear all state
            bclk_phase_acc_q       <= 32'd0;
            mclk_phase_acc_q       <= 32'd0;
            bit_count_q            <= 6'd0;
            sample_left_q          <= 32'd0;
            sample_right_q         <= 32'd0;
            mclk_q                 <= 1'b0;
            bclk_q                 <= 1'b0;
            ws_q                   <= 1'b0;
            data_q                 <= 1'b0;
            current_latch_status_q <= 1'b0;

        end else if (!enable_sync) begin
            // ENABLE=0: hold all I2S outputs low and reset DDS accumulators.
            // Accumulators reset so clocks start cleanly when re-enabled.
            bclk_phase_acc_q <= 32'd0;
            mclk_phase_acc_q <= 32'd0;
            bit_count_q      <= 6'd0;
            mclk_q           <= 1'b0;
            bclk_q           <= 1'b0;
            ws_q             <= 1'b0;
            data_q           <= 1'b0;

        end else begin
            // ---------------------------------------------------------------
            // MCLK DDS — independent from BCLK
            // ---------------------------------------------------------------
            if (mclk_phase_wrap) begin
                // Accumulator overflowed → toggle MCLK, subtract one period
                mclk_phase_acc_q <= mclk_phase_sum - AXI_CLK_HZ;
                mclk_q           <= !mclk_q;
            end else begin
                mclk_phase_acc_q <= mclk_phase_sum;
                // mclk_q unchanged
            end

            // ---------------------------------------------------------------
            // BCLK DDS + I2S serializer
            // ---------------------------------------------------------------
            if (bclk_phase_wrap) begin
                // Accumulator overflowed → one BCLK edge event
                bclk_phase_acc_q <= bclk_phase_sum - AXI_CLK_HZ;

                if (bclk_q) begin
                    // ---- BCLK FALLING EDGE --------------------------------
                    // I2S data is clocked by the receiver on BCLK rising edge,
                    // so we set up data on the preceding falling edge.

                    bclk_q      <= 1'b0;

                    // Advance bit counter (wraps 63 → 0 automatically)
                    bit_count_q <= bit_count_q + 6'd1;

                    // WS: low for left channel (bit_count 0..31),
                    //      high for right channel (bit_count 32..63).
                    //   We derive WS from the MSB of the *new* bit_count so
                    //   WS transitions one BCLK before the first data bit,
                    //   which is exactly the Philips I2S timing requirement.
                    ws_q        <= bit_count_q[5];

                    // Place next serial bit on DATA line
                    data_q      <= i2s_next_serial_bit(
                                       sample_for_i2s_left,
                                       sample_for_i2s_right,
                                       bit_count_q,
                                       sample_width_sync);

                end else begin
                    // ---- BCLK RISING EDGE ---------------------------------
                    // Receiver latches data here — do NOT change DATA or WS.

                    bclk_q <= 1'b1;

                    // At the start of a new stereo frame (bit_count == 0,
                    // rising edge), latch the register-file samples into
                    // shadow registers.  This ensures left and right channels
                    // are always from the same firmware write pair.
                    if (bit_count_q == 6'd0) begin
                        sample_left_q          <= slv_reg0;
                        sample_right_q         <= slv_reg1;
                        // Toggle STATUS[0] so firmware can detect frame rate
                        current_latch_status_q <= !current_latch_status_q;
                    end
                end

            end else begin
                // No wrap this cycle — just advance the accumulator
                bclk_phase_acc_q <= bclk_phase_sum;
            end
        end
    end

// ============================================================================
// Section 18 — Output Assignments
// ============================================================================

    assign i2s_mclk = mclk_q;  // 256 × Fs (optional; for DACs that need MCLK)
    assign i2s_ws   = ws_q;    // Word select — low=left, high=right
    assign i2s_bclk = bclk_q;  // Bit clock — 64 × Fs
    assign i2s_data = data_q;  // Serial PCM data — MSB first

// ============================================================================
// Section 19 — Unused Input Suppression
//
//   The PROT signals are accepted for block-design pin-compatibility but carry
//   no functional meaning. The XOR expression prevents synthesis from issuing
//   undriven-input warnings while generating zero logic.
// ============================================================================

    wire _unused_ok = S_AXI_AWPROT[0] ^ S_AXI_AWPROT[1] ^ S_AXI_AWPROT[2] ^
                      S_AXI_ARPROT[0] ^ S_AXI_ARPROT[1] ^ S_AXI_ARPROT[2];

endmodule