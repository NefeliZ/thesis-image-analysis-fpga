`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// top module to connect linebuffer and filters
// cascaded filters 3x3 window - integers - shifts 
//////

module top_cascade3x3_int #(
    parameter int DATA_WIDTH = 8,
    parameter int IMG_WIDTH = 368,
    parameter int IMG_HEIGHT = 487

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
    logic [DATA_WIDTH-1:0] lb1_w00, lb1_w01, lb1_w02;
    logic [DATA_WIDTH-1:0] lb1_w10, lb1_w11, lb1_w12;
    logic [DATA_WIDTH-1:0] lb1_w20, lb1_w21, lb1_w22;
    logic lb1_valid_out;

    // line buffer instance 1 - creates sliding 3x3 win
    line_buffer_3x3 #(
        .DATA_WIDTH(DATA_WIDTH),
        .IMG_WIDTH(IMG_WIDTH),
        .IMG_HEIGHT(IMG_HEIGHT)
    ) 
    u_lb_1 (
        .clk (clk),
        .reset (reset),
        .valid_in (valid_in),
        .pixel_in (pixel_in),
        .p00(lb1_w00), .p01(lb1_w01), .p02(lb1_w02),
        .p10(lb1_w10), .p11(lb1_w11), .p12(lb1_w12),
        .p20(lb1_w20), .p21(lb1_w21), .p22(lb1_w22),
        .valid_out (lb1_valid_out)
    );
    
    //--------------------------------------------------------------
    // stage 2: filter 1 - gaussian blur
    logic gauss_valid_out;
    logic [DATA_WIDTH-1:0] gauss_pixel_out;
    
    gaussblur3x3_int_shift #(
        .DATA_WIDTH(DATA_WIDTH)
    ) 
    u_gaussblur_int_1 (
        .clk (clk),
        .reset (reset),
        .valid_in (lb1_valid_out),
        .p00(lb1_w00), .p01(lb1_w01), .p02(lb1_w02),
        .p10(lb1_w10), .p11(lb1_w11), .p12(lb1_w12),
        .p20(lb1_w20), .p21(lb1_w21), .p22(lb1_w22),
        .valid_out (gauss_valid_out),
        .pixel_out (gauss_pixel_out)
    );

    //--------------------------------------------------------------
    // stage 3: line buffer 2
    logic [DATA_WIDTH-1:0] lb2_w00, lb2_w01, lb2_w02;
    logic [DATA_WIDTH-1:0] lb2_w10, lb2_w11, lb2_w12;
    logic [DATA_WIDTH-1:0] lb2_w20, lb2_w21, lb2_w22;
    logic lb2_valid_out;
     
    // line buffer instance 1 - creates sliding 3x3 win
    line_buffer_3x3 #(
        .DATA_WIDTH(DATA_WIDTH),
        .IMG_WIDTH(IMG_WIDTH-2), //1st stage shrinks image by 2
        .IMG_HEIGHT(IMG_HEIGHT-2)
    ) 
    u_lb_2 (
        .clk (clk),
        .reset (reset),
        .valid_in (gauss_valid_out),
        .pixel_in (gauss_pixel_out),
        .p00(lb2_w00), .p01(lb2_w01), .p02(lb2_w02),
        .p10(lb2_w10), .p11(lb2_w11), .p12(lb2_w12),
        .p20(lb2_w20), .p21(lb2_w21), .p22(lb2_w22),
        .valid_out (lb2_valid_out)
    );
    
    //--------------------------------------------------------------
    // stage 4: filter 2 - sobel
    
    sobel3x3_int_shift #(
        .DATA_WIDTH(DATA_WIDTH)
    ) 
    u_sobel_int_2 (
        .clk (clk),
        .reset (reset),
        .valid_in (lb2_valid_out),
        .p00(lb2_w00), .p01(lb2_w01), .p02(lb2_w02),
        .p10(lb2_w10), .p11(lb2_w11), .p12(lb2_w12),
        .p20(lb2_w20), .p21(lb2_w21), .p22(lb2_w22),
        .valid_out (valid_out),
        .pixel_out (pixel_out)
    );
    

endmodule