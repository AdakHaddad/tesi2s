`timescale 1ns / 1ps

module filter_auto (
    input clk,
    input valid,
    input [2:0] sw,
    input signed [15:0] x_in,
    output signed [15:0] y_out
);

// COEFFICIENT REGISTERS
reg signed [15:0] b0_1, b1_1, b2_1, a1_1, a2_1;
reg signed [15:0] b0_2, b1_2, b2_2, a1_2, a2_2;

// INTER-STAGE WIRES
wire signed [15:0] stage1_out;

// COEFFICIENT SELECTOR
always @(posedge clk) begin
  if(valid) begin
    case(sw)
      3'd0: begin
        // fc = 500 Hz LP
        b0_1 <= 16'sd7;
        b1_1 <= 16'sd14;
        b2_1 <= 16'sd7;
        a1_1 <= -16'sd24243;
        a2_1 <= 16'sd9107;

        b0_2 <= 16'sd16384;
        b1_2 <= 16'sd32768;
        b2_2 <= 16'sd16384;
        a1_2 <= -16'sd27869;
        a2_2 <= 16'sd12919;
      end

      3'd1: begin
        // fc = 800 Hz LP
        b0_1 <= 16'sd37;
        b1_1 <= 16'sd73;
        b2_1 <= 16'sd37;
        a1_1 <= -16'sd19871;
        a2_1 <= 16'sd6292;

        b0_2 <= 16'sd16384;
        b1_2 <= 16'sd32768;
        b2_2 <= 16'sd16384;
        a1_2 <= -16'sd24245;
        a2_2 <= 16'sd11283;
      end

      3'd2: begin
        // fc = 1000 Hz LP
        b0_1 <= 16'sd79;
        b1_1 <= 16'sd158;
        b2_1 <= 16'sd79;
        a1_1 <= -16'sd17180;
        a2_1 <= 16'sd4852;

        b0_2 <= 16'sd16384;
        b1_2 <= 16'sd32768;
        b2_2 <= 16'sd16384;
        a1_2 <= -16'sd21642;
        a2_2 <= 16'sd10367;
      end

      3'd3: begin
        // fc = 500 Hz HP
        b0_1 <= 16'sd10846;
        b1_1 <= -16'sd21693;
        b2_1 <= 16'sd10846;
        a1_1 <= -16'sd24243;
        a2_1 <= 16'sd9107;

        b0_2 <= 16'sd16384;
        b1_2 <= -16'sd32768;
        b2_2 <= 16'sd16384;
        a1_2 <= -16'sd27869;
        a2_2 <= 16'sd12919;
      end

      3'd4: begin
        // fc = 800 Hz HP
        b0_1 <= 16'sd8425;
        b1_1 <= -16'sd16851;
        b2_1 <= 16'sd8425;
        a1_1 <= -16'sd19871;
        a2_1 <= 16'sd6292;

        b0_2 <= 16'sd16384;
        b1_2 <= -16'sd32768;
        b2_2 <= 16'sd16384;
        a1_2 <= -16'sd24245;
        a2_2 <= 16'sd11283;
      end

      3'd5: begin
        // fc = 1000 Hz HP
        b0_1 <= 16'sd7092;
        b1_1 <= -16'sd14184;
        b2_1 <= 16'sd7092;
        a1_1 <= -16'sd17180;
        a2_1 <= 16'sd4852;

        b0_2 <= 16'sd16384;
        b1_2 <= -16'sd32768;
        b2_2 <= 16'sd16384;
        a1_2 <= -16'sd21642;
        a2_2 <= 16'sd10367;
      end

      3'd6: begin
        // fc = 500-1000 Hz BP
        b0_1 <= 16'sd329;
        b1_1 <= 16'sd658;
        b2_1 <= 16'sd329;
        a1_1 <= -16'sd24200;
        a2_1 <= 16'sd12453;

        b0_2 <= 16'sd16384;
        b1_2 <= -16'sd32768;
        b2_2 <= 16'sd16384;
        a1_2 <= -16'sd28433;
        a2_2 <= 16'sd13825;
      end

      3'd7: begin
        // fc = 500-1000 Hz BS
        b0_1 <= 16'sd13117;
        b1_1 <= -16'sd23666;
        b2_1 <= 16'sd13117;
        a1_1 <= -16'sd24200;
        a2_1 <= 16'sd12453;

        b0_2 <= 16'sd16384;
        b1_2 <= -16'sd29560;
        b2_2 <= 16'sd16384;
        a1_2 <= -16'sd28433;
        a2_2 <= 16'sd13825;
      end

      default: begin
        b0_1 <= 16'sd16384;
        b1_1 <= 16'sd0;
        b2_1 <= 16'sd0;
        a1_1 <= 16'sd0;
        a2_1 <= 16'sd0;

        b0_2 <= 16'sd16384;
        b1_2 <= 16'sd0;
        b2_2 <= 16'sd0;
        a1_2 <= 16'sd0;
        a2_2 <= 16'sd0;
      end
    endcase
  end
end

// BIQUAD CASCADE
filter_biquad stage1(
    .b0(b0_1),
    .b1(b1_1),
    .b2(b2_1),
    .a1(a1_1),
    .a2(a2_1),

    .clk(clk),
    .valid(valid),
    .x_in(x_in),
    .y_out(stage1_out)
);

filter_biquad stage2(
    .b0(b0_2),
    .b1(b1_2),
    .b2(b2_2),
    .a1(a1_2),
    .a2(a2_2),

    .clk(clk),
    .valid(valid),
    .x_in(stage1_out),
    .y_out(y_out)
);

endmodule