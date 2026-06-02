`timescale 1ns / 1ps
module filter_top (
    input sys_clk,
    input reset,
    input [2:0] sw,
    input rx,
    output tx,
    output reg [3:0] an,
    output [6:0] seg
);

// Clock
wire clk;
wire locked;

clk_wiz_0 clkdiv (
    .clk_in1(sys_clk),
    .clk_out1(clk),
    .reset(reset),
    .locked(locked)
);

// Input
reg signed [15:0] sine;

always @(posedge clk) begin
  if (sample_valid)
    sine <= sample;
  end


// Filter
wire signed [15:0] y_out;

filter_coeff filter (
    .clk(clk),
    .valid(sample_valid),
    .sw(sw),
    .x_in(sine),
    .y_out(y_out)
);

// BAUD
wire tick;

baud_rate_generator #(
    .M(10),
    .N(4)
) baud_gen (
    .clk_100MHz(clk),
    .reset(reset),
    .tick(tick)
);

//fifo
fifo fifo_rx_inst (
    .clk(clk),
    .reset(reset),
    .write_to_fifo(rx_done),
    .read_from_fifo(read_uart),
    .write_data_in(rx_data),
    .read_data_out(read_data),
    .empty(rx_empty),
    .full(rx_full)
);

wire [7:0] read_data;
wire rx_empty;
wire rx_full;
reg read_uart;
reg rx_empty_d;

reg [7:0] fifo_data_reg;
reg fifo_data_valid;
reg fifo_read_pulse;

always @(posedge clk or posedge reset) begin
    if(reset) begin
        read_uart <= 0;
        rx_empty_d <= 1;
    end else begin
        rx_empty_d <= rx_empty;
        read_uart <= rx_empty_d & ~rx_empty;
    end
end

//rx
uart_receiver uart_rx (
    .clk_100MHz(clk),
    .reset(reset),
    .rx(rx),
    .sample_tick(tick),
    .data_ready(rx_done),
    .data_out(rx_data)
);

wire [7:0] rx_data;
wire rx_done;
reg [15:0] sample;
reg [1:0] byte_sel;
reg sample_valid;

reg [15:0] sample_buf;
reg new_sample;

always @(posedge clk or posedge reset) begin
    if(reset) begin
        byte_sel <= 0;
        sample_valid <= 0;
    end else begin
        sample_valid <= 0;

        if(rx_done) begin
            if(!byte_sel) begin
                sample[7:0] <= rx_data;   // LSB
                byte_sel <= 1;
            end else begin
                sample[15:8] <= rx_data;  // MSB
                byte_sel <= 0;
                sample_valid <= 1;
            end
        end
    end
end

//tx
uart_transmitter uart_tx (
    .clk_100MHz(clk),
    .reset(reset),
    .tx_start(tx_start_reg),
    .sample_tick(tick),
    .data_in(tx_data_reg),
    .tx_done(tx_done_tick),
    .tx(tx)
); 

reg [1:0] tx_state;
reg [7:0] tx_data_reg;
reg tx_start_reg;
wire tx_done_tick;
reg [15:0] y_buf;
reg tx_busy;

always @(posedge clk or posedge reset) begin
    if(reset) begin
        tx_state <= 0;
        tx_data_reg <= 0;
        tx_start_reg <= 0;
    end else begin
        tx_start_reg <= 0;

        case(tx_state)
            0: begin
                if(sample_valid && !tx_busy) begin
                    y_buf <= y_out;
                    tx_data_reg <= y_out[7:0];
                    tx_start_reg <= 1;
                    tx_busy <= 1;
                    tx_state <= 1;
                end
            end

            1: begin
                if(tx_done_tick) begin
                    tx_data_reg <= y_buf[15:8];
                    tx_start_reg <= 1;
                    tx_state <= 2;
                end
            end
            2: begin
                if(tx_done_tick) begin
                    tx_busy <= 0;
                    tx_state <= 0;
                end
            end
        endcase
    end
end

//Filter Indicator
reg [31:0] sec_cnt;
reg show_text;
reg [1:0] disp_state;

always @(posedge clk or posedge reset) begin
  if (reset) begin
    sec_cnt    <= 0;
    disp_state <= 0;
  end else begin
    sec_cnt <= sec_cnt + 1;

    if (sec_cnt == 76_500_000) begin
      sec_cnt <= 0;

      if (sw == 3'd6 || sw == 3'd7) begin
        // BPF
        if (disp_state == 2)
          disp_state <= 0;
        else
          disp_state <= disp_state + 1;
      end else begin
        // LPF/HPF
        if (disp_state == 0)
          disp_state <= 1;
        else
          disp_state <= 0;
      end
    end
  end
end

reg [3:0] d0, d1, d2, d3;

always @(*) begin

  // default
  d3 = 4'hF;
  d2 = 4'hF;
  d1 = 4'hF;
  d0 = 4'hF;

  case(sw)
    // LPF
    3'd0,3'd1,3'd2: begin
      if (disp_state == 0) begin
        // LPF
        d3=4'hA; d2=4'hB; d1=4'hC; d0=4'hF;
      end else begin
        case(sw)
          3'd0: begin d3=0; d2=5; d1=0; d0=0; end
          3'd1: begin d3=0; d2=8; d1=0; d0=0; end
          3'd2: begin d3=1; d2=0; d1=0; d0=0; end
        endcase
      end
    end

    // HPF
    3'd3,3'd4,3'd5: begin
      if (disp_state == 0) begin
        // HPF
        d3=4'hD; d2=4'hB; d1=4'hC; d0=4'hF;
      end else begin
        case(sw)
          3'd3: begin d3=0; d2=5; d1=0; d0=0; end
          3'd4: begin d3=0; d2=8; d1=0; d0=0; end
          3'd5: begin d3=1; d2=0; d1=0; d0=0; end
        endcase
      end
    end

    // BPF
    3'd6: begin // 500–1000
      case(disp_state)
        2'd0: begin // BPF
          d3=4'hE; d2=4'hB; d1=4'hC; d0=4'hF;
        end
        2'd1: begin // fL
          d3=0; d2=5; d1=0; d0=0;
        end
        2'd2: begin // fH
          d3=1; d2=0; d1=0; d0=0;
        end
      endcase
    end
    
    //BSF
    3'd7: begin // 500–1000
      case(disp_state)
        2'd0: begin
          d3=4'hE; d2=4'h5; d1=4'hC; d0=4'hF;
        end
        2'd1: begin // fL
          d3=0; d2=5; d1=0; d0=0;
        end
        2'd2: begin // fH
          d3=1; d2=0; d1=0; d0=0;
        end
      endcase
    end

  endcase
end

reg [15:0] refresh_cnt;

always @(posedge clk or posedge reset) begin
  if (reset)
    refresh_cnt <= 0;
  else
    refresh_cnt <= refresh_cnt + 1;
end

wire [1:0] sel = refresh_cnt[15:14];

reg [3:0] bcd;

always @(*) begin
  case(sel)
    2'b00: begin an = 4'b1110; bcd = d0; end
    2'b01: begin an = 4'b1101; bcd = d1; end
    2'b10: begin an = 4'b1011; bcd = d2; end
    2'b11: begin an = 4'b0111; bcd = d3; end
  endcase
end

sevseg sevseg (
  .iBCD(bcd),
  .oHEX({seg[0], seg[1], seg[2], seg[3], seg[4], seg[5], seg[6]})
);

endmodule
