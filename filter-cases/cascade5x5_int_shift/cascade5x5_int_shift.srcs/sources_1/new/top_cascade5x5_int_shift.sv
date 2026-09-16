`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// top module to connect linebuffer and filters
// cascaded filters 5x5 window - integers - shifts 
//////

module top_cascade5x5_int_shift #(
    parameter int DATA_WIDTH = 8,
    parameter int IMG_WIDTH = 372,
    parameter int IMG_HEIGHT = 491

)(
    input logic clk,
    input logic reset,
    input logic valid_in, // 1 when input pixel is valid
    input logic [DATA_WIDTH-1:0] pixel_in, // 1 pixel per clock cycle
    output logic [DATA_WIDTH-1:0] pixel_out, // 1 filtered pixel per clock cycle
    output logic valid_out // 1 when output pixel is valid
);
    
    //--------------------------------------------------------------
    // stage 1
    // connect line buffer1 to filter1 
    logic [DATA_WIDTH-1:0] lb1_w00, lb1_w01, lb1_w02, lb1_w03, lb1_w04;
    logic [DATA_WIDTH-1:0] lb1_w10, lb1_w11, lb1_w12, lb1_w13, lb1_w14;
    logic [DATA_WIDTH-1:0] lb1_w20, lb1_w21, lb1_w22, lb1_w23, lb1_w24;
    logic [DATA_WIDTH-1:0] lb1_w30, lb1_w31, lb1_w32, lb1_w33, lb1_w34;
    logic [DATA_WIDTH-1:0] lb1_w40, lb1_w41, lb1_w42, lb1_w43, lb1_w44;
    logic lb1_valid_out;

    // line buffer instance 1 - creates sliding 3x3 win
    line_buffer_5x5 #(
        .DATA_WIDTH(DATA_WIDTH),
        .IMG_WIDTH(IMG_WIDTH),
        .IMG_HEIGHT(IMG_HEIGHT)
    ) 
    u_lb_1 (
        .clk (clk),
        .reset (reset),
        .valid_in (valid_in),
        .pixel_in (pixel_in),
        .p00(lb1_w00), .p01(lb1_w01), .p02(lb1_w02), .p03(lb1_w03), .p04(lb1_w04),
        .p10(lb1_w10), .p11(lb1_w11), .p12(lb1_w12), .p13(lb1_w13), .p14(lb1_w14),
        .p20(lb1_w20), .p21(lb1_w21), .p22(lb1_w22), .p23(lb1_w23), .p24(lb1_w24),
        .p30(lb1_w30), .p31(lb1_w31), .p32(lb1_w32), .p33(lb1_w33), .p34(lb1_w34),
        .p40(lb1_w40), .p41(lb1_w41), .p42(lb1_w42), .p43(lb1_w43), .p44(lb1_w44),
        .valid_out (lb1_valid_out)
    );
    
    //--------------------------------------------------------------
    // stage 2: filter 1 - gaussian blur
    logic gauss_valid_out;
    logic [DATA_WIDTH-1:0] gauss_pixel_out;
    
    gaussblur5x5_int_shift #(
        .DATA_WIDTH(DATA_WIDTH)
    ) 
    u_gaussblur_int_1 (
        .clk (clk),
        .reset (reset),
        .valid_in (lb1_valid_out),
        .p00(lb1_w00), .p01(lb1_w01), .p02(lb1_w02), .p03(lb1_w03), .p04(lb1_w04),
        .p10(lb1_w10), .p11(lb1_w11), .p12(lb1_w12), .p13(lb1_w13), .p14(lb1_w14),
        .p20(lb1_w20), .p21(lb1_w21), .p22(lb1_w22), .p23(lb1_w23), .p24(lb1_w24),
        .p30(lb1_w30), .p31(lb1_w31), .p32(lb1_w32), .p33(lb1_w33), .p34(lb1_w34),
        .p40(lb1_w40), .p41(lb1_w41), .p42(lb1_w42), .p43(lb1_w43), .p44(lb1_w44),
        
        .valid_out (gauss_valid_out),
        .pixel_out (gauss_pixel_out)
    );

    //--------------------------------------------------------------
    // stage 3: line buffer 2
    logic [DATA_WIDTH-1:0] lb2_w00, lb2_w01, lb2_w02, lb2_w03, lb2_w04;
    logic [DATA_WIDTH-1:0] lb2_w10, lb2_w11, lb2_w12, lb2_w13, lb2_w14;
    logic [DATA_WIDTH-1:0] lb2_w20, lb2_w21, lb2_w22, lb2_w23, lb2_w24;
    logic [DATA_WIDTH-1:0] lb2_w30, lb2_w31, lb2_w32, lb2_w33, lb2_w34;
    logic [DATA_WIDTH-1:0] lb2_w40, lb2_w41, lb2_w42, lb2_w43, lb2_w44;

    logic lb2_valid_out;

    // line buffer instance 1 - creates sliding 3x3 win
    line_buffer_5x5 #(
        .DATA_WIDTH(DATA_WIDTH),
        .IMG_WIDTH(IMG_WIDTH-2), //1st stage shrinks image by 2
        .IMG_HEIGHT(IMG_HEIGHT-2)
    ) 
    u_lb_2 (
        .clk (clk),
        .reset (reset),
        .valid_in (gauss_valid_out),
        .pixel_in (gauss_pixel_out),
        .p00(lb2_w00), .p01(lb2_w01), .p02(lb2_w02), .p03(lb2_w03), .p04(lb2_w04),
        .p10(lb2_w10), .p11(lb2_w11), .p12(lb2_w12), .p13(lb2_w13), .p14(lb2_w14),
        .p20(lb2_w20), .p21(lb2_w21), .p22(lb2_w22), .p23(lb2_w23), .p24(lb2_w24),
        .p30(lb2_w30), .p31(lb2_w31), .p32(lb2_w32), .p33(lb2_w33), .p34(lb2_w34),
        .p40(lb2_w40), .p41(lb2_w41), .p42(lb2_w42), .p43(lb2_w43), .p44(lb2_w44),
        .valid_out (lb2_valid_out)
    );
    
    //--------------------------------------------------------------
    // stage 4: filter 2 - sobel
    
    sobel5x5_int_shift #(
        .DATA_WIDTH(DATA_WIDTH)
    ) 
    u_sobel_int_2 (
        .clk (clk),
        .reset (reset),
        .valid_in (lb2_valid_out),
        .p00(lb2_w00), .p01(lb2_w01), .p02(lb2_w02), .p03(lb2_w03), .p04(lb2_w04),
        .p10(lb2_w10), .p11(lb2_w11), .p12(lb2_w12), .p13(lb2_w13), .p14(lb2_w14),
        .p20(lb2_w20), .p21(lb2_w21), .p22(lb2_w22), .p23(lb2_w23), .p24(lb2_w24),
        .p30(lb2_w30), .p31(lb2_w31), .p32(lb2_w32), .p33(lb2_w33), .p34(lb2_w34),
        .p40(lb2_w40), .p41(lb2_w41), .p42(lb2_w42), .p43(lb2_w43), .p44(lb2_w44),
        .valid_out (valid_out),
        .pixel_out (pixel_out)
    );
    

endmodule