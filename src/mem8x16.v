module mem8x16 (
`ifdef USE_POWER_PINS
  inout vccd1,
  inout vssd1,
`endif
  input clk,
  input rst,
  input cs,
  input we,
  input [2:0] addr,
  input [15:0] din,
  output reg [15:0] dout
);

  wire [7:0] rowclk;
  wire [15:0] rowout[0:7];
  reg [7:0] adrDcod;
  reg [15:0] outbuf;

  always_latch begin
    if (~we & cs) begin
      dout = outbuf;
    end
  end

  always @* begin
    case (addr)
      'd0: adrDcod = 8'b00000001;
      'd1: adrDcod = 8'b00000010;
      'd2: adrDcod = 8'b00000100;
      'd3: adrDcod = 8'b00001000;
      'd4: adrDcod = 8'b00010000;
      'd5: adrDcod = 8'b00100000;
      'd6: adrDcod = 8'b01000000;
      'd7: adrDcod = 8'b10000000;
      default: adrDcod = 8'b00000000;
    endcase
  end

  assign rowclk = adrDcod & {8{we}} & {8{cs}} & {8{clk}};
  memrow row0 (.clkp(rowclk[0]), .rstp(rst), .D16(din), .Q16(rowout[0]));
  memrow row1 (.clkp(rowclk[1]), .rstp(rst), .D16(din), .Q16(rowout[1]));
  memrow row2 (.clkp(rowclk[2]), .rstp(rst), .D16(din), .Q16(rowout[2]));
  memrow row3 (.clkp(rowclk[3]), .rstp(rst), .D16(din), .Q16(rowout[3]));
  memrow row4 (.clkp(rowclk[4]), .rstp(rst), .D16(din), .Q16(rowout[4]));
  memrow row5 (.clkp(rowclk[5]), .rstp(rst), .D16(din), .Q16(rowout[5]));
  memrow row6 (.clkp(rowclk[6]), .rstp(rst), .D16(din), .Q16(rowout[6]));
  memrow row7 (.clkp(rowclk[7]), .rstp(rst), .D16(din), .Q16(rowout[7]));

  always @* begin
    case (addr)
      'd0: outbuf = rowout[0];
      'd1: outbuf = rowout[1];
      'd2: outbuf = rowout[2];
      'd3: outbuf = rowout[3];
      'd4: outbuf = rowout[4];
      'd5: outbuf = rowout[5];
      'd6: outbuf = rowout[6];
      'd7: outbuf = rowout[7];
    endcase
  end

endmodule

module memrow (
    input clkp,
    input rstp,
    input [15:0] D16,
    output reg [15:0] Q16
  );

  always @ (posedge clkp or posedge rstp) begin
    if (rstp) begin
      Q16 <= 16'h0000;
    end else begin
      Q16 <= D16;
    end
  end

endmodule
