`timescale 1ns / 1ps
module filter_biquad (
  input signed [15:0] b0,
  input signed [15:0] b1,
  input signed [15:0] b2,
  input signed [15:0] a1,
  input signed [15:0] a2,

  input clk,
  input valid,
  input signed [15:0] x_in,
  output signed [15:0] y_out
);

  // Delay registers
  reg signed [18:0] x_curr = 0;
  reg signed [18:0] x_d1 = 0;
  reg signed [18:0] x_d2 = 0;

  reg signed [18:0] y_d1 = 0;
  reg signed [18:0] y_d2 = 0;
  
  // Multiply (combinational)
  wire signed [36:0] mul_b0 = x_curr * b0;
  wire signed [36:0] mul_b1 = x_d1 * b1;
  wire signed [36:0] mul_b2 = x_d2 * b2;

  wire signed [36:0] mul_a1 = y_d1 * -a1;
  wire signed [36:0] mul_a2 = y_d2 * -a2;

  wire signed [48:0] acc_sum;

  assign acc_sum = mul_b0 + mul_b1 + mul_b2 + mul_a1 + mul_a2;
  
  // Register update
  always @(posedge clk) begin
      if (valid) begin
        x_curr <= x_in;
        x_d1   <= x_curr;
        x_d2   <= x_d1;
        y_d1   <= acc_sum >>> 14;
        y_d2   <= y_d1;
    end
  end

    wire signed [18:0] y_tmp = y_d1;
    assign y_out = (y_tmp > 32767) ? 32767 :
               (y_tmp < -32767) ? -32767 :
               y_tmp[15:0];

endmodule