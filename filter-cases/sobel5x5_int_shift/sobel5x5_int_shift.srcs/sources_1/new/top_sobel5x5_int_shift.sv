`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// top module to connect linebuffer and filter
// sobel filter with 5x5 window - integers - shifts 
//////

module top_sobel5x5_int_shift #(
    parameter int DATA_WIDTH = 8,
    parameter int IMG_WIDTH = 368,
    parameter int IMG_HEIGHT = 487

)(
    input  logic clk,
    input  logic reset,
    input  logic valid_in, // 1 when input pixel is valid
    input  logic [DATA_WIDTH-1:0] pixel_in, // 1 pixel per clock cycle
    output logic [DATA_WIDTH-1:0] pixel_out, // 1 filtered pixel per clock cycle
    output logic valid_out // 1 when output pixel is valid
);

    // connect line buffer to filter with window wires
    logic [DATA_WIDTH-1:0] w00, w01, w02, w03, w04;
    logic [DATA_WIDTH-1:0] w10, w11, w12, w13, w14;
    logic [DATA_WIDTH-1:0] w20, w21, w22, w23, w24;
    logic [DATA_WIDTH-1:0] w30, w31, w32, w33, w34;
    logic [DATA_WIDTH-1:0] w40, w41, w42, w43, w44;
    logic window_valid;

    // line buffer instance - creates sliding 3x3 win
    line_buffer_5x5 #(
        .DATA_WIDTH(DATA_WIDTH),
        .IMG_WIDTH(IMG_WIDTH),
        .IMG_HEIGHT(IMG_HEIGHT)
    ) 
    u_line_buffer_int_shift (
        .clk (clk),
        .reset (reset),
        .valid_in (valid_in),
        .pixel_in (pixel_in),
        .p00(w00), .p01(w01), .p02(w02), .p03(w03), .p04(w04),
        .p10(w10), .p11(w11), .p12(w12), .p13(w13), .p14(w14),
        .p20(w20), .p21(w21), .p22(w22), .p23(w23), .p24(w24),
        .p30(w30), .p31(w31), .p32(w32), .p33(w33), .p34(w34),
        .p40(w40), .p41(w41), .p42(w42), .p43(w43), .p44(w44),
        .valid_out (window_valid)
    );

    //filter instance
    sobel5x5_int_shift #(
        .DATA_WIDTH(DATA_WIDTH)
    ) 
    u_sobel_int_shift (
        .clk (clk),
        .reset (reset),
        .valid_in (window_valid),
        .p00(w00), .p01(w01), .p02(w02), .p03(w03), .p04(w04),
        .p10(w10), .p11(w11), .p12(w12), .p13(w13), .p14(w14),
        .p20(w20), .p21(w21), .p22(w22), .p23(w23), .p24(w24),
        .p30(w30), .p31(w31), .p32(w32), .p33(w33), .p34(w34),
        .p40(w40), .p41(w41), .p42(w42), .p43(w43), .p44(w44),
        .valid_out (valid_out),
        .pixel_out (pixel_out)
    );
    

endmodule