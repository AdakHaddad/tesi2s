`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.05.2026 17:49:22
// Design Name: 
// Module Name: sevseg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sevseg(
    input  [3:0] iBCD,
    output reg [6:0] oHEX
    );
  
  always @* begin
    case (iBCD)
      4'b0000 : oHEX = 7'b0000001; // 0
      4'b0001 : oHEX = 7'b1001111; // 1
      4'b0010 : oHEX = 7'b0010010; // 2
      4'b0011 : oHEX = 7'b0000110; // 3
      4'b0100 : oHEX = 7'b1001100; // 4
      4'b0101 : oHEX = 7'b0100100; // 5
      4'b0110 : oHEX = 7'b0100000; // 6
      4'b0111 : oHEX = 7'b0001111; // 7
      4'b1000 : oHEX = 7'b0000000; // 8
      4'b1001 : oHEX = 7'b0000100; // 9
      4'hA: oHEX = 7'b1110001; // L
      4'hB: oHEX = 7'b0011000; // P
      4'hC: oHEX = 7'b0111000; // F
      4'hD: oHEX = 7'b1001000; // H
      4'hE: oHEX = 7'b0000000; // B
      default : oHEX = 7'b1111111;
    endcase
  end 
         
endmodule
