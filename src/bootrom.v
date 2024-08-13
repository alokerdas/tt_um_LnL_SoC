module bootrom (
`ifdef USE_POWER_PINS
  inout vccd1,
  inout vssd1,
`endif
  input clk,
  input rst,
  input cs,
  input we,
  input [3:0] addr,
  input [15:0] din,
  output reg [15:0] dout
);

  reg [15:0] outbuf0, outbuf1, outbuf2, outbuf3, outbuf4, outbuf5, outbuf6, outbuf7;
  reg [15:0] outbuf8, outbuf9, outbufA, outbufB, outbufC, outbufD, outbufE, outbufF;
  reg [15:0] dout_internal;
  wire romclk;
  wire clk_gated, clk8th, clk9th, clkAth, clkBth, clkCth, clkDth, clkEth, clkFth;
  
  assign romclk = clk & 1'b0;
  always @ (posedge romclk or posedge rst) begin
    if (rst) begin
      outbuf0 <= 16'hF200;
    end else begin
      outbuf0 <= 16'h0000;
    end
  end
  always @ (posedge romclk or posedge rst) begin
    if (rst) begin
      outbuf1 <= 16'h4000;
    end else begin
      outbuf1 <= 16'h0000;
    end
  end
  always @ (posedge romclk or posedge rst) begin
    if (rst) begin
      outbuf2 <= 16'hF800;
    end else begin
      outbuf2 <= 16'h0000;
    end
  end
  always @ (posedge romclk or posedge rst) begin
    if (rst) begin
      outbuf3 <= 16'h1007;
    end else begin
      outbuf3 <= 16'h0000;
    end
  end
  always @ (posedge romclk or posedge rst) begin
    if (rst) begin
      outbuf4 <= 16'hF400;
    end else begin
      outbuf4 <= 16'h0000;
    end
  end
  always @ (posedge romclk or posedge rst) begin
    if (rst) begin
      outbuf5 <= 16'h3008;
    end else begin
      outbuf5 <= 16'h0000;
    end
  end
  always @ (posedge romclk or posedge rst) begin
    if (rst) begin
      outbuf6 <= 16'h4000;
    end else begin
      outbuf6 <= 16'h0000;
    end
  end
  always @ (posedge romclk or posedge rst) begin
    if (rst) begin
      outbuf7 <= 16'h0000;
    end else begin
      outbuf7 <= 16'h0000;
    end
  end
  assign clk_gated = cs & we & clk;
  assign clk8th = addr[3] & ~addr[2] & ~addr[1] & ~addr[0] & clk_gated;
  always @ (posedge clk8th or posedge rst) begin
    if (rst) begin
      outbuf8 <= 16'h0000;
    end else begin
      outbuf8 <= din;
    end
  end
  assign clk9th = addr[3] & ~addr[2] & ~addr[1] & addr[0] & clk_gated;
  always @ (posedge clk9th or posedge rst) begin
    if (rst) begin
      outbuf9 <= 16'h0000;
    end else begin
      outbuf9 <= din;
    end
  end
  assign clkAth = addr[3] & ~addr[2] & addr[1] & ~addr[0] & clk_gated;
  always @ (posedge clkAth or posedge rst) begin
    if (rst) begin
      outbufA <= 16'h0000;
    end else begin
      outbufA <= din;
    end
  end
  assign clkBth = addr[3] & ~addr[2] & addr[1] & addr[0] & clk_gated;
  always @ (posedge clkBth or posedge rst) begin
    if (rst) begin
      outbufB <= 16'h0000;
    end else begin
      outbufB <= din;
    end
  end
  assign clkCth = addr[3] & addr[2] & ~addr[1] & ~addr[0] & clk_gated;
  always @ (posedge clkCth or posedge rst) begin
    if (rst) begin
      outbufC <= 16'h0000;
    end else begin
      outbufC <= din;
    end
  end
  assign clkDth = addr[3] & addr[2] & ~addr[1] & addr[0] & clk_gated;
  always @ (posedge clkDth or posedge rst) begin
    if (rst) begin
      outbufD <= 16'h0000;
    end else begin
      outbufD <= din;
    end
  end
  assign clkEth = addr[3] & addr[2] & addr[1] & ~addr[0] & clk_gated;
  always @ (posedge clkEth or posedge rst) begin
    if (rst) begin
      outbufE <= 16'h0000;
    end else begin
      outbufE <= din;
    end
  end
  assign clkFth = addr[3] & addr[2] & addr[1] & addr[0] & clk_gated;
  always @ (posedge clkFth or posedge rst) begin
    if (rst) begin
      outbufF <= 16'h0000;
    end else begin
      outbufF <= din;
    end
  end

  always @* begin
    case (addr)
      'h0: dout_internal = outbuf0;
      'h1: dout_internal = outbuf1;
      'h2: dout_internal = outbuf2;
      'h3: dout_internal = outbuf3;
      'h4: dout_internal = outbuf4;
      'h5: dout_internal = outbuf5;
      'h6: dout_internal = outbuf6;
      'h7: dout_internal = outbuf7;
      'h8: dout_internal = outbuf8;
      'h9: dout_internal = outbuf9;
      'hA: dout_internal = outbufA;
      'hB: dout_internal = outbufB;
      'hC: dout_internal = outbufC;
      'hD: dout_internal = outbufD;
      'hE: dout_internal = outbufE;
      'hF: dout_internal = outbufF;
    endcase
  end

  always_latch begin
    if (~we & cs) begin
      dout = dout_internal;
    end
  end

endmodule
