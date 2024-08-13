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

  reg [15:0] outbuf0;
  reg [15:0] outbuf1;
  reg [15:0] outbuf2;
  reg [15:0] outbuf3;
  reg [15:0] outbuf4;
  reg [15:0] outbuf5;
  reg [15:0] outbuf6;
  reg [15:0] outbuf7;
  reg [15:0] outbufE;
  reg [15:0] outbufF;
  reg [15:0] dout_internal;
  wire romclk, clk7th, clkEth, clkFth;

  assign romclk = clk & 1'b0;
  assign clk7th = clk & we & cs & (~addr[3] & addr[2] & addr[1] & addr[0]);
  assign clkEth = clk & we & cs & (~addr[0] & addr[1] & addr[2] & addr[3]);
  assign clkFth = clk & we & cs & (&addr);
  always @ (posedge clkEth or posedge rst) begin
    if (rst) begin
      outbufE <= 16'h0000;
    end else begin
      outbufE <= din;
    end
  end
  always @ (posedge clkFth or posedge rst) begin
    if (rst) begin
      outbufF <= 16'h0000;
    end else begin
      outbufF <= din;
    end
  end
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
      outbuf3 <= 16'hF400;
    end else begin
      outbuf3 <= 16'h0000;
    end
  end
  always @ (posedge romclk or posedge rst) begin
    if (rst) begin
      outbuf4 <= 16'hB007;
    end else begin
      outbuf4 <= 16'h0000;
    end
  end
  always @ (posedge romclk or posedge rst) begin
    if (rst) begin
      outbuf5 <= 16'h6007;
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
  always @ (posedge clk7th or posedge rst) begin
    if (rst) begin
      outbuf7 <= 16'h000F; // this is tricky, it tests bootrom, mem and spi
    end else begin
      outbuf7 <= din;
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
