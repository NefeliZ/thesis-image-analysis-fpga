`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// top module to connect linebuffer and filter
// sobel filter with 3x3 window - integers - shifts 
//////

module top_sobel3x3_int_shift #(
    parameter int DATA_WIDTH = 8,
    parameter int IMG_WIDTH = 52,
    parameter int IMG_HEIGHT = 52

)(
    input  logic clk,
    input  logic reset,
    input  logic valid_in, // 1 when input pixel is valid
    input  logic [DATA_WIDTH-1:0] pixel_in, // 1 pixel per clock cycle
    output logic [DATA_WIDTH-1:0] pixel_out, // 1 filtered pixel per clock cycle
    output logic valid_out // 1 when output pixel is valid
);

    // connect line buffer to filter with window wires
    logic [DATA_WIDTH-1:0] w00, w01, w02;
    logic [DATA_WIDTH-1:0] w10, w11, w12;
    logic [DATA_WIDTH-1:0] w20, w21, w22;
    logic window_valid;

    // line buffer instance - creates sliding 3x3 win
    line_buffer_3x3 #(
        .DATA_WIDTH(DATA_WIDTH),
        .IMG_WIDTH(IMG_WIDTH),
        .IMG_HEIGHT(IMG_HEIGHT)
    ) 
    u_line_buffer (
        .clk (clk),
        .reset (reset),
        .valid_in (valid_in),
        .pixel_in (pixel_in),
        .p00(w00), .p01(w01), .p02(w02),
        .p10(w10), .p11(w11), .p12(w12),
        .p20(w20), .p21(w21), .p22(w22),
        .valid_out (window_valid)
    );

    //filter instance
    sobel3x3_int_shift #(
        .DATA_WIDTH(DATA_WIDTH)
    ) 
    u_sobel_filter (
        .clk (clk),
        .reset (reset),
        .valid_in (window_valid),
        .p00(w00), .p01(w01), .p02(w02),
        .p10(w10), .p11(w11), .p12(w12),
        .p20(w20), .p21(w21), .p22(w22),
        .valid_out (valid_out),
        .pixel_out (pixel_out)
    );

endmodule