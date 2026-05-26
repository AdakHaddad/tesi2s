`timescale 1 ns / 1 ps

// ============================================================================
// Module      : i2s_slave_lite_v1_0_S00_AXI
// Description : I2S transmitter peripheral with AXI4-Lite register interface.
//               Accepts stereo PCM samples and control parameters from a
//               MicroBlaze processor over AXI4-Lite, then serialises the
//               samples to a Philips I2S bitstream consumed by a PCM5102A DAC.
//
// Clock domains
// -------------
//   S_AXI_ACLK    : 100 MHz — AXI bus and register file
//   internal_mclk : 24.576 MHz (48 kHz family) or 22.579 MHz (44.1 kHz family)
//                   Selected at runtime by FS_FAMILY control bit via BUFGMUX
//
// Register Map
// ------------
//   Offset   Name         Direction   Description
//   0x00     DATA_LEFT    W           Left-channel PCM sample
//   0x04     DATA_RIGHT   W           Right-channel PCM sample
//   0x08     CONTROL      R/W         Enable, mute, Fs selection, sample width
//   0x0C     RESERVED     R/W         Future expansion
//
// DATA packing
// ------------
//   DATA_LEFT  : bits [SAMPLE_WIDTH-1:0] carry the left  sample, MSB-justified
//   DATA_RIGHT : bits [SAMPLE_WIDTH-1:0] carry the right sample, MSB-justified
//   Upper bits are ignored by the serialiser.
//
// CONTROL bitfield
// ----------------
//   Bit(s)   Field         Default   Description
//   0        ENABLE        0         1 = I2S output active; 0 = all outputs held low
//   1        MUTE          0         1 = force DATA line to zero; clocks continue
//   2        FS_FAMILY     0         0 = 48/96 kHz family; 1 = 44.1/88.2 kHz family
//   3        FS_MODE       0         0 = standard Fs; 1 = double Fs (x2)
//   7:4      RESERVED      0         Write ignored, reads as zero
//   12:8     SAMPLE_WIDTH  32        Payload bits per channel slot (1-32).
//                                    Writing 0 defaults to 32.
//   28:13    DDS_FREQ      0         DDS frequency in Hz (0-65535)
//   29       RESERVED      0         Write ignored, reads as zero
//   30       DDS_MODE      0         0 = Sine, 1 = Square
//   31       DDS_ENABLE    0         1 = Enable internal DDS; 0 = Use AXI DATA registers
//
// Fs truth table (FS_FAMILY x FS_MODE)
// -------------------------------------
//   FS_FAMILY   FS_MODE   Nominal Fs
//   0           0         48   kHz
//   1           0         44.1 kHz
//   0           1         96   kHz
//   1           1         88.2 kHz
//
// Philips I2S timing contract
// ---------------------------
//   WS LOW  = left  channel slot (bit_count 0–31)
//   WS HIGH = right channel slot (bit_count 32–63)
//   Bit 0 after every WS edge is a mandatory one-cycle delay (outputs 0).
//   Data bits follow MSB-first for SAMPLE_WIDTH cycles, then zero-padded.
//   DATA is updated on the falling edge of BCLK and sampled by the DAC
//   on the rising edge of BCLK, satisfying the Philips I2S setup requirement.
//
// Firmware usage example
// ----------------------
//   I2S_REG(0x00) = left_sample  & ((1u << SAMPLE_WIDTH) - 1);
//   I2S_REG(0x04) = right_sample & ((1u << SAMPLE_WIDTH) - 1);
//   I2S_REG(0x08) = (1u << 0) | (1u << 3) | (24u << 8);
//   // ENABLE=1, FS_MODE=1 (96 kHz), SAMPLE_WIDTH=24
//
// ============================================================================

module i2s_dds_slave_lite_v1_0_S00_AXI #
(
    parameter integer C_S00_AXI_DATA_WIDTH = 32,
    parameter integer C_S00_AXI_ADDR_WIDTH = 4
)
(
    // Audio clock inputs — both must be running before ENABLE is asserted.
    // Provided by the MMCM/PLL Clock Wizard in the top-level block design.
    input  wire audio_48_clk,   // 24.576 MHz  — 48/96 kHz Fs family
    input  wire audio_44_clk,   // 22.579 MHz  — 44.1/88.2 kHz Fs family

    // I2S serial outputs — connect directly to PCM5102A PMOD pins.
    // MCLK is driven but the PCM5102A can operate without it (SCK mode).
    output wire i2s_mclk,
    output wire i2s_bclk,
    output wire i2s_ws,
    output wire i2s_data,

    // AXI4-Lite slave interface — standard Vivado port names, do not rename.
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

// ----------------------------------------------------------------------------
// AXI4-Lite internal handshake registers.
// These implement the write and read state machines that comply with the
// AXI4-Lite single-transaction protocol (no outstanding transactions).
// ----------------------------------------------------------------------------
    reg [C_S00_AXI_ADDR_WIDTH-1:0] axi_awaddr;
    reg  axi_awready;
    reg  axi_wready;
    reg [1:0] axi_bresp;
    reg  axi_bvalid;
    reg [C_S00_AXI_ADDR_WIDTH-1:0] axi_araddr;
    reg  axi_arready;
    reg [1:0] axi_rresp;
    reg  axi_rvalid;

// ----------------------------------------------------------------------------
// Address decode constants.
// ADDR_LSB strips the byte-lane bits (2 for a 32-bit bus).
// OPT_MEM_ADDR_BITS sets the number of register index bits above ADDR_LSB,
// giving 2^(OPT_MEM_ADDR_BITS+1) = 4 addressable registers.
// ----------------------------------------------------------------------------
    localparam integer ADDR_LSB          = (C_S00_AXI_DATA_WIDTH/32) + 1;
    localparam integer OPT_MEM_ADDR_BITS = 1;

// ----------------------------------------------------------------------------
// Slave register file — four 32-bit read/write registers.
// Written by the AXI master and read back by the same master for verification.
// slv_reg2 is also read combinatorially for the BUFGMUX select (reg_fs_family)
// before CDC has settled, which is safe because only the clock-mux path uses
// the raw value; all audio logic uses the CDC-synchronised ctrl_cdc_w.
// ----------------------------------------------------------------------------
    reg [C_S00_AXI_DATA_WIDTH-1:0] slv_reg0;  // DATA_LEFT
    reg [C_S00_AXI_DATA_WIDTH-1:0] slv_reg1;  // DATA_RIGHT
    reg [C_S00_AXI_DATA_WIDTH-1:0] slv_reg2;  // CONTROL
    reg [C_S00_AXI_DATA_WIDTH-1:0] slv_reg3;  // RESERVED
    integer byte_index;

    localparam [1:0] REG_DATA_LEFT  = 2'h0;
    localparam [1:0] REG_DATA_RIGHT = 2'h1;
    localparam [1:0] REG_CONTROL    = 2'h2;
    localparam [1:0] REG_RESERVED   = 2'h3;

    assign S_AXI_AWREADY = axi_awready;
    assign S_AXI_WREADY  = axi_wready;
    assign S_AXI_BRESP   = axi_bresp;
    assign S_AXI_BVALID  = axi_bvalid;
    assign S_AXI_ARREADY = axi_arready;
    assign S_AXI_RRESP   = axi_rresp;
    assign S_AXI_RVALID  = axi_rvalid;

    reg [1:0] state_write;
    reg [1:0] state_read;

// ----------------------------------------------------------------------------
// State machine encoding.
// Write path : Idle → Waddr → Wdata → Waddr
// Read  path : Idle → Raddr → Rdata → Raddr
// Waddr and Raddr share the encoding 2'b10; Wdata and Rdata share 2'b11.
// This is safe because state_write and state_read are independent registers.
// ----------------------------------------------------------------------------
    localparam Idle  = 2'b00;
    localparam Waddr = 2'b10;
    localparam Wdata = 2'b11;
    localparam Raddr = 2'b10;
    localparam Rdata = 2'b11;

// ----------------------------------------------------------------------------
// AXI4-Lite write state machine.
// Handles address and data acceptance plus write-response generation.
// Outstanding transactions are not supported — the master must assert BREADY
// before issuing the next write.
// ----------------------------------------------------------------------------
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_awready <= 0;
            axi_wready  <= 0;
            axi_bvalid  <= 0;
            axi_bresp   <= 0;
            axi_awaddr  <= 0;
            state_write <= Idle;
        end else begin
            case (state_write)
                Idle: begin
                    if (S_AXI_ARESETN == 1'b1) begin
                        axi_awready <= 1'b1;
                        axi_wready  <= 1'b1;
                        state_write <= Waddr;
                    end else
                        state_write <= state_write;
                end
                Waddr: begin
                    if (S_AXI_AWVALID && S_AXI_AWREADY) begin
                        axi_awaddr <= S_AXI_AWADDR;
                        if (S_AXI_WVALID) begin
                            axi_awready <= 1'b1;
                            state_write <= Waddr;
                            axi_bvalid  <= 1'b1;
                        end else begin
                            axi_awready <= 1'b0;
                            state_write <= Wdata;
                            if (S_AXI_BREADY && axi_bvalid) axi_bvalid <= 1'b0;
                        end
                    end else begin
                        state_write <= state_write;
                        if (S_AXI_BREADY && axi_bvalid) axi_bvalid <= 1'b0;
                    end
                end
                Wdata: begin
                    if (S_AXI_WVALID) begin
                        state_write <= Waddr;
                        axi_bvalid  <= 1'b1;
                        axi_awready <= 1'b1;
                    end else begin
                        state_write <= state_write;
                        if (S_AXI_BREADY && axi_bvalid) axi_bvalid <= 1'b0;
                    end
                end
            endcase
        end
    end

// ----------------------------------------------------------------------------
// Register write logic.
// Byte-lane strobes (WSTRB) allow the master to update individual bytes
// within a 32-bit register without disturbing the remaining bytes.
// All four registers are writable; slv_reg3 is a scratch register with no
// effect on the audio datapath.
// ----------------------------------------------------------------------------
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            slv_reg0 <= 0;
            slv_reg1 <= 0;
            slv_reg2 <= 0;
            slv_reg3 <= 0;
        end else begin
            if (S_AXI_WVALID) begin
                case ((S_AXI_AWVALID) ?
                        S_AXI_AWADDR[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] :
                        axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB])
                    REG_DATA_LEFT:
                        for (byte_index = 0; byte_index <= (C_S00_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1)
                            if (S_AXI_WSTRB[byte_index])
                                slv_reg0[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                    REG_DATA_RIGHT:
                        for (byte_index = 0; byte_index <= (C_S00_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1)
                            if (S_AXI_WSTRB[byte_index])
                                slv_reg1[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                    REG_CONTROL:
                        for (byte_index = 0; byte_index <= (C_S00_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1)
                            if (S_AXI_WSTRB[byte_index])
                                slv_reg2[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                    REG_RESERVED:
                        for (byte_index = 0; byte_index <= (C_S00_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1)
                            if (S_AXI_WSTRB[byte_index]) begin
                                if (byte_index == 0)
                                    slv_reg3[7:1] <= S_AXI_WDATA[7:1];
                                else
                                    slv_reg3[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                            end
                    default: begin
                        slv_reg0 <= slv_reg0;
                        slv_reg1 <= slv_reg1;
                        slv_reg2 <= slv_reg2;
                        slv_reg3 <= slv_reg3;
                    end
                endcase
            end
        end
    end

// ----------------------------------------------------------------------------
// AXI4-Lite read state machine.
// Returns register contents in one cycle after address acceptance.
// RDATA is driven combinatorially from axi_araddr, so the correct value
// is available as soon as RVALID is asserted.
// ----------------------------------------------------------------------------
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            axi_arready <= 1'b0;
            axi_rvalid  <= 1'b0;
            axi_rresp   <= 1'b0;
            state_read  <= Idle;
        end else begin
            case (state_read)
                Idle: begin
                    if (S_AXI_ARESETN == 1'b1) begin
                        state_read  <= Raddr;
                        axi_arready <= 1'b1;
                    end else
                        state_read <= state_read;
                end
                Raddr: begin
                    if (S_AXI_ARVALID && S_AXI_ARREADY) begin
                        state_read  <= Rdata;
                        axi_araddr  <= S_AXI_ARADDR;
                        axi_rvalid  <= 1'b1;
                        axi_arready <= 1'b0;
                    end else
                        state_read <= state_read;
                end
                Rdata: begin
                    if (S_AXI_RVALID && S_AXI_RREADY) begin
                        axi_rvalid  <= 1'b0;
                        axi_arready <= 1'b1;
                        state_read  <= Raddr;
                    end else
                        state_read <= state_read;
                end
            endcase
        end
    end

    assign S_AXI_RDATA =
        (axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 2'h0) ? slv_reg0 :
        (axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 2'h1) ? slv_reg1 :
        (axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 2'h2) ? slv_reg2 :
        (axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 2'h3) ? {slv_reg3[31:1], current_latch_status} : 0;

// ============================================================================
// Audio datapath — everything below operates in the internal_mclk domain
// unless stated otherwise.
// ============================================================================

    reg [5:0]  bit_count_q;
    reg [31:0] sample_left_q;
    reg [31:0] sample_right_q;

// ----------------------------------------------------------------------------
// Section 1 : Master clock selection (BUFGMUX) with proper CDC
//
// FS_FAMILY (CONTROL bit 2) selects which MMCM output feeds the audio logic.
// The select line is synchronised to S_AXI_ACLK (100 MHz system clock) before
// driving BUFGMUX, eliminating metastability risk from AXI register writes.
//
//   fs_family_sync_q = 0 → audio_48_clk (24.576 MHz)
//   fs_family_sync_q = 1 → audio_44_clk (22.579 MHz)
// ----------------------------------------------------------------------------
    wire raw_fs_family = slv_reg2[2];
    
    (* ASYNC_REG = "TRUE" *) reg fs_family_stage1_q;
    (* ASYNC_REG = "TRUE" *) reg fs_family_sync_q;
    
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            fs_family_stage1_q <= 1'b0;
            fs_family_sync_q   <= 1'b0;
        end else begin
            fs_family_stage1_q <= raw_fs_family;
            fs_family_sync_q   <= fs_family_stage1_q;
        end
    end
    
    wire internal_mclk;

    BUFGMUX #(.CLK_SEL_TYPE("ASYNC")) mclk_mux (
        .O  (internal_mclk),
        .I0 (audio_48_clk),
        .I1 (audio_44_clk),
        .S  (fs_family_sync_q)
    );

// ----------------------------------------------------------------------------
// Section 2 : Robust Clock Domain Crossing (CDC) — AXI → audio
//
// Instead of a single toggle bit (which can be missed if two writes happen 
// too fast), we use a 4-bit write counter. The audio domain synchronises 
// this counter and detects any change, ensuring all writes are captured.
// ----------------------------------------------------------------------------
    reg [3:0] axi_wr_count_q = 4'd0;
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0)
            axi_wr_count_q <= 4'd0;
        else if (S_AXI_WVALID && S_AXI_WREADY)
            axi_wr_count_q <= axi_wr_count_q + 4'd1;
    end

    (* ASYNC_REG = "TRUE" *) reg [3:0] mclk_wr_sync_reg1;
    (* ASYNC_REG = "TRUE" *) reg [3:0] mclk_wr_sync_reg2;
    reg [3:0] mclk_wr_sync_prev_q;

    always @(posedge internal_mclk) begin
        mclk_wr_sync_reg1    <= axi_wr_count_q;
        mclk_wr_sync_reg2    <= mclk_wr_sync_reg1;
        mclk_wr_sync_prev_q  <= mclk_wr_sync_reg2;
    end

    wire mclk_wr_detected = (mclk_wr_sync_reg2 != mclk_wr_sync_prev_q);

    reg [31:0] ctrl_cdc_q;
    reg [31:0] sample_left_cdc_q;
    reg [31:0] sample_right_cdc_q;

    always @(posedge internal_mclk) begin
        if (mclk_wr_detected) begin
            ctrl_cdc_q         <= slv_reg2;
            sample_left_cdc_q  <= slv_reg0;
            sample_right_cdc_q <= slv_reg1;
        end
    end

    wire [31:0] ctrl_cdc_w         = ctrl_cdc_q;
    wire [31:0] sample_left_cdc_w  = sample_left_cdc_q;
    wire [31:0] sample_right_cdc_w = sample_right_cdc_q;

// ----------------------------------------------------------------------------
// Section 3 : Control field extraction
//
// All control signals are derived from the CDC-synchronised control word.
// sample_width_sync defaults to 32 when firmware writes zero.
// ----------------------------------------------------------------------------
    wire       enable_sync       = ctrl_cdc_w[0];
    wire       mute_sync         = ctrl_cdc_w[1];
    wire       fs_family_sync    = ctrl_cdc_w[2];
    wire       fs_mode_sync      = ctrl_cdc_w[3];
    wire [5:0] sample_width_sync = (ctrl_cdc_w[12:8] == 5'd0) ? 6'd32
                                                               : {1'b0, ctrl_cdc_w[12:8]};

// ----------------------------------------------------------------------------
// Section 3b : DDS Generator (Internal Signal Source)
//
// When DDS_ENABLE (CONTROL bit 31) is high, the I2S core ignores the DATA
// registers and instead generates a waveform internally.
//
//   DDS_FREQ (bits 28:13) : Frequency in Hz (0 - 65535)
//   DDS_MODE (bit 30)     : 0 = Sine, 1 = Square
//   DDS_ENABLE (bit 31)   : 1 = Enable internal DDS
//
// The phase increment is calculated based on the current Fs family and mode.
// ----------------------------------------------------------------------------
    wire        dds_en_sync       = ctrl_cdc_w[31];
    wire        dds_mode_sync     = ctrl_cdc_w[30];
    wire [15:0] dds_freq_sync     = ctrl_cdc_w[28:13];

    reg  [31:0] phase_acc_q;
    reg  [16:0] dds_phase_step_per_hz;

    // Rounded multiplier = round(2^32 / Fs). Phase advances once per stereo
    // frame, so phase_inc = requested_hz * 2^32 / Fs.
    always @(*) begin
        case ({fs_mode_sync, fs_family_sync})
            2'b00: dds_phase_step_per_hz = 17'd89478; // 48 kHz
            2'b01: dds_phase_step_per_hz = 17'd97392; // 44.1 kHz
            2'b10: dds_phase_step_per_hz = 17'd44739; // 96 kHz
            2'b11: dds_phase_step_per_hz = 17'd48696; // 88.2 kHz
        endcase
    end

    wire [32:0] phase_inc_full_w = {17'd0, dds_freq_sync} * {16'd0, dds_phase_step_per_hz};
    wire [31:0] phase_inc_w      = phase_inc_full_w[31:0];

    reg [15:0] sine_lut [0:255];
    integer idx;
    initial begin
        for (idx = 0; idx < 256; idx = idx + 1) begin
            sine_lut[idx] = $rtoi(32767.0 * $sin(2.0 * 3.1415926535 * idx / 256.0));
        end
    end

    wire signed [15:0] dds_sine_val   = sine_lut[phase_acc_q[31:24]];
    wire signed [15:0] dds_square_val = phase_acc_q[31] ? 16'sh7FFF : 16'sh8001;
    wire signed [15:0] dds_sample16_w = dds_mode_sync ? dds_square_val : dds_sine_val;
    wire signed [31:0] dds_sample32_w = {{16{dds_sample16_w[15]}}, dds_sample16_w};

    reg signed [31:0] dds_sample_scaled_q;
    always @(*) begin
        if (sample_width_sync >= 6'd32)
            dds_sample_scaled_q = dds_sample32_w <<< 16;
        else if (sample_width_sync > 6'd16)
            dds_sample_scaled_q = dds_sample32_w <<< (sample_width_sync - 6'd16);
        else if (sample_width_sync < 6'd16)
            dds_sample_scaled_q = dds_sample32_w >>> (6'd16 - sample_width_sync);
        else
            dds_sample_scaled_q = dds_sample32_w;
    end

    wire [31:0] dds_sample_w = dds_sample_scaled_q[31:0];

    reg mclk_q;
    reg bclk_q;
    reg ws_q;
    reg data_q;
    reg sample_req_q;

// ----------------------------------------------------------------------------
// Mute and enable gating.
// ENABLE=0 holds all outputs low and resets bit_count_q.
// MUTE=1 forces sample data to zero while clocks continue.
// ----------------------------------------------------------------------------
    wire [31:0] sample_for_i2s_left  = (enable_sync && !mute_sync) ? sample_left_q  : 32'd0;
    wire [31:0] sample_for_i2s_right = (enable_sync && !mute_sync) ? sample_right_q : 32'd0;

// ----------------------------------------------------------------------------
// Section 4 : Power-on reset for the audio clock domain
//
// A four-bit shift register initialised to 1111 releases audio_rst after
// four internal_mclk cycles.  Self-timed — no dependency on S_AXI_ARESETN.
// ----------------------------------------------------------------------------
    reg [3:0] audio_por_q = 4'b1111;
    always @(posedge internal_mclk)
        audio_por_q <= {audio_por_q[2:0], 1'b0};
    wire audio_rst = audio_por_q[3];

// ----------------------------------------------------------------------------
// Section 5 : Clock divider and BCLK enable
//
//   FS_MODE = 0 : bclk_en_w every 4 cycles -> BCLK = mclk/8 -> WS = 48/44.1 kHz
//   FS_MODE = 1 : bclk_en_w every 2 cycles -> BCLK = mclk/4 -> WS = 96/88.2 kHz
//
// mclk_q toggles every cycle producing MCLK = internal_mclk / 2.
// ----------------------------------------------------------------------------
    reg [2:0] clock_div_q;

    always @(posedge internal_mclk or posedge audio_rst) begin
        if (audio_rst) begin
            mclk_q      <= 1'b0;
            clock_div_q <= 3'b0;
        end else begin
            mclk_q      <= !mclk_q;
            clock_div_q <= clock_div_q + 3'd1;
        end
    end

    wire bclk_en_w = fs_mode_sync ? (clock_div_q[0]  == 1'b0)
                                  : (clock_div_q[1:0] == 2'd0);

// ----------------------------------------------------------------------------
// Section 6 : Sample latch
//
// New PCM values are captured at the start of each stereo frame
// (bit_count_q = 0, falling BCLK edge) to prevent mid-word corruption.
// mclk_latch_toggle_q toggles on every latch event and is synchronised
// back to the AXI domain so firmware can poll REG_RESERVED[0] for confirmation.
// ----------------------------------------------------------------------------
    reg mclk_latch_toggle_q = 1'b0;

    always @(posedge internal_mclk or posedge audio_rst) begin
        if (audio_rst) begin
            sample_left_q       <= 32'd0;
            sample_right_q      <= 32'd0;
            phase_acc_q         <= 32'd0;
            mclk_latch_toggle_q <= 1'b0;
        end else if (bclk_en_w && !bclk_q && (bit_count_q == 6'd0)) begin
            if (dds_en_sync) begin
                sample_left_q       <= dds_sample_w;
                sample_right_q      <= dds_sample_w;
                phase_acc_q         <= phase_acc_q + phase_inc_w;
            end else begin
                sample_left_q       <= sample_left_cdc_w;
                sample_right_q      <= sample_right_cdc_w;
            end
            mclk_latch_toggle_q <= !mclk_latch_toggle_q;
        end
    end

    // Synchronise the latch toggle back to the AXI domain for firmware sync.
    (* ASYNC_REG = "TRUE" *) reg [2:0] axi_latch_sync_q;
    always @(posedge S_AXI_ACLK) begin
        axi_latch_sync_q <= {axi_latch_sync_q[1:0], mclk_latch_toggle_q};
    end
    
    wire current_latch_status = axi_latch_sync_q[2];

// ----------------------------------------------------------------------------
// Section 7 : Philips I2S serialiser function
//
// Returns the single DATA bit to be placed on the I2S bus for a given
// bit_count value, following the Philips I2S specification:
//
//   bit_count 0–31  : left  channel slot
//   bit_count 32–63 : right channel slot
//
// Within each 32-bit slot:
//   pos 0          : delay bit — always 0 (one BCLK after WS edge)
//   pos 1          : MSB of sample (bit index = width - 1)
//   pos 2..width   : remaining bits down to LSB (bit index = width - pos)
//   pos > width    : zero padding to fill the 32-bit slot
//
// The function is purely combinatorial and has no state.
// ----------------------------------------------------------------------------
    function i2s_next_serial_bit;
        input [31:0] left_samp;
        input [31:0] right_samp;
        input [5:0]  bc;
        input [5:0]  width;
        reg          in_left;
        reg  [4:0]   pos;
        reg  [5:0]   bit_idx;
        begin
            in_left = (bc < 6'd32);
            pos     = bc[4:0];
            if (width == 6'd0)
                i2s_next_serial_bit = 1'b0;
            else if (pos == 5'd0)
                i2s_next_serial_bit = 1'b0;
            else if (pos <= width) begin
                bit_idx = width - {1'b0, pos};
                i2s_next_serial_bit = in_left ? left_samp[bit_idx[4:0]]
                                              : right_samp[bit_idx[4:0]];
            end else
                i2s_next_serial_bit = 1'b0;
        end
    endfunction

// ----------------------------------------------------------------------------
// Section 8 : I2S output generator
//
// Produces BCLK, WS, and DATA in the internal_mclk domain, gated by
// bclk_en_w so that the effective BCLK rate matches the selected Fs.
//
// On each bclk_en_w strobe:
//   Falling edge (bclk_q = 1 → 0) :
//     - DATA is updated with the next serial bit for the current bit_count
//     - WS reflects the current channel (bit_count[5]: 0=left, 1=right)
//     - bit_count_q increments, wrapping 63 → 0
//
//   Rising edge (bclk_q = 0 → 1) :
//     - BCLK goes high; DAC samples DATA on this edge
//     - sample_req_q pulses high at bit_count = 0 to signal a new frame
//
// When ENABLE is deasserted all outputs are held low and bit_count_q resets
// to 0, ensuring the next enable resumes at a clean left-channel frame start.
// ----------------------------------------------------------------------------
    always @(posedge internal_mclk or posedge audio_rst) begin
        if (audio_rst) begin
            bit_count_q  <= 6'd0;
            data_q       <= 1'b0;
            ws_q         <= 1'b0;
            bclk_q       <= 1'b0;
            sample_req_q <= 1'b0;
        end else if (bclk_en_w) begin
            if (!enable_sync) begin
                bit_count_q  <= 6'd0;
                data_q       <= 1'b0;
                ws_q         <= 1'b0;
                bclk_q       <= 1'b0;
                sample_req_q <= 1'b0;
            end else begin
                if (bclk_q) begin
                    bclk_q      <= 1'b0;
                    data_q      <= i2s_next_serial_bit(
                                       sample_for_i2s_left,
                                       sample_for_i2s_right,
                                       bit_count_q,
                                       sample_width_sync);
                    ws_q        <= bit_count_q[5];
                    bit_count_q <= bit_count_q + 6'd1;
                end else begin
                    bclk_q <= 1'b1;
                    if (bit_count_q == 6'd0)
                        sample_req_q <= 1'b1;
                end
            end
        end else
            sample_req_q <= 1'b0;
    end

// ----------------------------------------------------------------------------
// Section 9 : Output assignments
//
// All four I2S signals are driven from registered sources to ensure clean,
// glitch-free transitions at the PMOD pins and to allow ILA probing without
// IOB register conflicts.
// ----------------------------------------------------------------------------
    assign i2s_mclk = mclk_q;
    assign i2s_ws   = ws_q;
    assign i2s_bclk = bclk_q;
    assign i2s_data = data_q;

endmodule
