`timescale 1ns / 1ps

module filter_coeff (
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
        b0_1 <= 16'sd0;
        b1_1 <= 16'sd0;
        b2_1 <= 16'sd0;
        a1_1 <= -16'sd30835;
        a2_1 <= 16'sd14517;

        b0_2 <= 16'sd16384;
        b1_2 <= 16'sd32767;
        b2_2 <= 16'sd16384;
        a1_2 <= -16'sd31899;
        a2_2 <= 16'sd15584;
      end

      3'd1: begin
        // fc = 800 Hz LP
        b0_1 <= 16'sd0;
        b1_1 <= 16'sd0;
        b2_1 <= 16'sd0;
        a1_1 <= -16'sd29719;
        a2_1 <= 16'sd13498;

        b0_2 <= 16'sd16384;
        b1_2 <= 16'sd32767;
        b2_2 <= 16'sd16384;
        a1_2 <= -16'sd31335;
        a2_2 <= 16'sd15124;
      end

      3'd2: begin
        // fc = 1000 Hz LP
        b0_1 <= 16'sd0;
        b1_1 <= 16'sd1;
        b2_1 <= 16'sd0;
        a1_1 <= -16'sd28992;
        a2_1 <= 16'sd12858;

        b0_2 <= 16'sd16384;
        b1_2 <= 16'sd32767;
        b2_2 <= 16'sd16384;
        a1_2 <= -16'sd30942;
        a2_2 <= 16'sd14825;
      end

      3'd3: begin
        // fc = 500 Hz HP
        b0_1 <= 16'sd15041;
        b1_1 <= -16'sd30082;
        b2_1 <= 16'sd15041;
        a1_1 <= -16'sd30835;
        a2_1 <= 16'sd14517;

        b0_2 <= 16'sd16384;
        b1_2 <= -16'sd32768;
        b2_2 <= 16'sd16384;
        a1_2 <= -16'sd31899;
        a2_2 <= 16'sd15584;
      end

      3'd4: begin
        // fc = 800 Hz HP
        b0_1 <= 16'sd14288;
        b1_1 <= -16'sd28576;
        b2_1 <= 16'sd14288;
        a1_1 <= -16'sd29719;
        a2_1 <= 16'sd13498;

        b0_2 <= 16'sd16384;
        b1_2 <= -16'sd32768;
        b2_2 <= 16'sd16384;
        a1_2 <= -16'sd31335;
        a2_2 <= 16'sd15124;
      end

      3'd5: begin
        // fc = 1000 Hz HP
        b0_1 <= 16'sd13806;
        b1_1 <= -16'sd27613;
        b2_1 <= 16'sd13806;
        a1_1 <= -16'sd28992;
        a2_1 <= 16'sd12858;

        b0_2 <= 16'sd16384;
        b1_2 <= -16'sd32768;
        b2_2 <= 16'sd16384;
        a1_2 <= -16'sd30942;
        a2_2 <= 16'sd14825;
      end

      3'd6: begin
        // fc = 500-1000 Hz BP
        b0_1 <= 16'sd17;
        b1_1 <= 16'sd34;
        b2_1 <= 16'sd17;
        a1_1 <= -16'sd31621;
        a2_1 <= 16'sd15464;

        b0_2 <= 16'sd16384;
        b1_2 <= -16'sd32768;
        b2_2 <= 16'sd16384;
        a1_2 <= -16'sd32125;
        a2_2 <= 16'sd15824;
      end

      3'd7: begin
        // fc = 500-1000 Hz BS
        b0_1 <= 16'sd15643;
        b1_1 <= -16'sd31152;
        b2_1 <= 16'sd15643;
        a1_1 <= -16'sd31621;
        a2_1 <= 16'sd15464;

        b0_2 <= 16'sd16384;
        b1_2 <= -16'sd32628;
        b2_2 <= 16'sd16384;
        a1_2 <= -16'sd32125;
        a2_2 <= 16'sd15824;
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