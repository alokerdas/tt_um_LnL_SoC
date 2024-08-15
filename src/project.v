/*
 * Copyright (c) 2024 Lab and Lectures
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_LnL_SoC (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  supply0 minus;
  supply1 plus;
  reg rst_n_i;
  reg [15:0] boot_to_cpu;
  wire [15:0] data_to_dev, data_to_cpu;
  wire [11:0] addr_to_memio;
  wire [7:0] spi_to_cpu;
  wire rw_to_mem, load_spi, unload_spi, en_to_spi, en_to_dev, en_to_boot;

  assign uio_oe = 8'hF0; // Lower nibble all input, Upper all output
  assign uio_out[3:0] = 4'h0; // uio_out unused bits

  always @(posedge clk or negedge rst_n)
    if (~rst_n) rst_n_i <= 1'b0;
    else rst_n_i <= 1'b1;

  assign en_to_spi = |addr_to_memio[11:4] & en_to_dev;
  assign en_to_boot = ~(|addr_to_memio[11:4]) & en_to_dev;
  assign load_spi = rw_to_mem & en_to_spi;
  assign unload_spi = ~rw_to_mem & en_to_spi;
  assign data_to_cpu[7:0] = en_to_spi ? spi_to_cpu : boot_to_cpu[7:0];
  assign data_to_cpu[15:8] = en_to_spi ? 8'h00 : boot_to_cpu[15:8];

  cpu cpu0 (
`ifdef USE_POWER_PINS
    .vccd1(plus),
    .vssd1(minus),
`endif
    .clkin(clk),
    .rst(~rst_n_i),
    .addr(addr_to_memio),
    .datain(data_to_cpu),
    .dataout(data_to_dev),
    .keyboard(ui_in),
    .display(uo_out),
    .en_inp(uio_in[0]),
    .en_out(uio_out[7]),
    .rdwr(rw_to_mem),
    .en(en_to_dev)
  );
    /*
  bootrom mem0 (
`ifdef USE_POWER_PINS
    .vccd1(plus),
    .vssd1(minus),
`endif
    .clk(clk),
    .rst(~rst_n_i),
    .addr(addr_to_memio[3:0]),
    .din(data_to_dev),
    .dout(boot_to_cpu),
    .cs(en_to_boot),
    .we(rw_to_mem)
  );
  */
  spi spi0 (
`ifdef USE_POWER_PINS
    .vccd1(plus),
    .vssd1(minus),
`endif
    .reset(~rst_n_i),
    .clock_in(clk),
    .load(load_spi),
    .unload(unload_spi),
    .datain(data_to_dev[7:0]),
    .dataout(spi_to_cpu),
    .sclk(uio_out[6]),
    .miso(uio_in[1]),
    .mosi(uio_out[5]),
    .ssn_in(uio_in[2]),
    .ssn_out(uio_out[4])
  );

  wire [3:0] addr;
  reg [15:0] outbuf0, outbuf1, outbuf2, outbuf3, outbuf4, outbuf5, outbuf6, outbuf7;
  reg [15:0] outbuf8, outbuf9, outbufA, outbufB, outbufC, outbufD, outbufE, outbufF, dout;
  wire romclk, rst;
  wire clk_gated, clk7th; //clk8th, clk9th, clkAth, clkBth, clkCth, clkDth, clkEth, clkFth;

  assign addr = addr_to_memio[3:0];
  assign rst = ~rst_n_i;
  assign clk_gated = en_to_boot & rw_to_mem & clk;
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
      outbuf5 <= 16'h3007;
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
  
  assign clk7th = ~addr[3] & addr[2] & addr[1] & addr[0] & clk_gated;
  always @ (posedge clk7th or posedge rst) begin
    if (rst) begin
      outbuf7 <= 16'h0000;
    end else begin
      outbuf7 <= data_to_dev;
    end
  end
//  assign clk8th = addr[3] & ~addr[2] & ~addr[1] & ~addr[0] & clk_gated;
  always @ (posedge romclk or posedge rst) begin
    if (rst) begin
      outbuf8 <= 16'h0000;
    end else begin
      outbuf8 <= data_to_dev;
    end
  end
//  assign clk9th = addr[3] & ~addr[2] & ~addr[1] & addr[0] & clk_gated;
  always @ (posedge romclk or posedge rst) begin
    if (rst) begin
      outbuf9 <= 16'h0000;
    end else begin
      outbuf9 <= data_to_dev;
    end
  end
//  assign clkAth = addr[3] & ~addr[2] & addr[1] & ~addr[0] & clk_gated;
  always @ (posedge romclk or posedge rst) begin
    if (rst) begin
      outbufA <= 16'h0000;
    end else begin
      outbufA <= data_to_dev;
    end
  end
//  assign clkBth = addr[3] & ~addr[2] & addr[1] & addr[0] & clk_gated;
  always @ (posedge romclk or posedge rst) begin
    if (rst) begin
      outbufB <= 16'h0000;
    end else begin
      outbufB <= data_to_dev;
    end
  end
//  assign clkCth = addr[3] & addr[2] & ~addr[1] & ~addr[0] & clk_gated;
  always @ (posedge romclk or posedge rst) begin
    if (rst) begin
      outbufC <= 16'h0000;
    end else begin
      outbufC <= data_to_dev;
    end
  end
//  assign clkDth = addr[3] & addr[2] & ~addr[1] & addr[0] & clk_gated;
  always @ (posedge romclk or posedge rst) begin
    if (rst) begin
      outbufD <= 16'h0000;
    end else begin
      outbufD <= data_to_dev;
    end
  end
//  assign clkEth = addr[3] & addr[2] & addr[1] & ~addr[0] & clk_gated;
  always @ (posedge romclk or posedge rst) begin
    if (rst) begin
      outbufE <= 16'h0000;
    end else begin
      outbufE <= data_to_dev;
    end
  end
//  assign clkFth = addr[3] & addr[2] & addr[1] & addr[0] & clk_gated;
  always @ (posedge romclk or posedge rst) begin
    if (rst) begin
      outbufF <= 16'h0000;
    end else begin
      outbufF <= data_to_dev;
    end
  end

  always @* begin
    case (addr)
      'h0: dout = outbuf0;
      'h1: dout = outbuf1;
      'h2: dout = outbuf2;
      'h3: dout = outbuf3;
      'h4: dout = outbuf4;
      'h5: dout = outbuf5;
      'h6: dout = outbuf6;
      'h7: dout = outbuf7;
      'h8: dout = outbuf8;
      'h9: dout = outbuf9;
      'hA: dout = outbufA;
      'hB: dout = outbufB;
      'hC: dout = outbufC;
      'hD: dout = outbufD;
      'hE: dout = outbufE;
      'hF: dout = outbufF;
    endcase
  end

  always_latch begin
    if (~rw_to_mem & en_to_boot) begin
      boot_to_cpu = dout;
    end
  end
    
  // avoid linter warning about unused pins:
  wire _unused_pin = ena;
  wire [4:0] _unused_pins = uio_in[7:3];

endmodule // tt_um_LnL_SoC
