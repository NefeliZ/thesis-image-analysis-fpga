`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// sobel filter with 5x5 window - ieee
//////

module sobel5x5_ieee #(

 parameter DATA_WIDTH = 8
)(
    input logic clk,
    input logic reset,
    input logic valid_in,
       
    //pixel inputs 
    input  logic [DATA_WIDTH-1:0] p00, p01, p02, p03, p04,
    input  logic [DATA_WIDTH-1:0] p10, p11, p12, p13, p14,
    input  logic [DATA_WIDTH-1:0] p20, p21, p22, p23, p24,
    input  logic [DATA_WIDTH-1:0] p30, p31, p32, p33, p34,
    input  logic [DATA_WIDTH-1:0] p40, p41, p42, p43, p44,
    
    output logic valid_out,
    output logic [DATA_WIDTH-1:0] pixel_out // center pixel val - G
);
    
    //valid_out vars for all stages - keep flow
    //valid_out only in 1 instance per stage - avoid error
    logic vo_1, vo_2, vo_3, vo_4, vo_5, vo_6;
    
    //sobel filter constants in ieee format
    localparam logic [31:0] const_1 = 32'h3f800000; //1
    localparam logic [31:0] const_m1 = 32'hbf800000;//-1
    localparam logic [31:0] const_2 = 32'h40000000;//2
    localparam logic [31:0] const_m2 = 32'hc0000000;//-2
    
    localparam logic [31:0] const_4 = 32'h40800000;//4
    localparam logic [31:0] const_m4 = 32'hc0800000;//-4
    localparam logic [31:0] const_8 = 32'h41000000;//8
    localparam logic [31:0] const_m8 = 32'hc1000000;//-8
    
    localparam logic [31:0] const_6 = 32'h40c00000;//6
    localparam logic [31:0] const_m6 = 32'hc0c00000;//-6
    localparam logic [31:0] const_12 = 32'h41400000;//12
    localparam logic [31:0] const_m12 = 32'hc1400000;//-12    
    
    //--------------------------------------------------------------
    // stage 0 - 0 delay
    // change input integers to ieee floats
    logic [31:0] fp00, fp01, fp02, fp03, fp04;
    logic [31:0] fp10, fp11, fp12, fp13, fp14;
    logic [31:0] fp20, fp21, fp22, fp23, fp24;
    logic [31:0] fp30, fp31, fp32, fp33, fp34;
    logic [31:0] fp40, fp41, fp42, fp43, fp44;

    int_to_float u_itf_00 (.input_bin(p00), .output_float(fp00));
    int_to_float u_itf_01 (.input_bin(p01), .output_float(fp01));
    int_to_float u_itf_02 (.input_bin(p02), .output_float(fp02));
    int_to_float u_itf_03 (.input_bin(p03), .output_float(fp03));
    int_to_float u_itf_04 (.input_bin(p04), .output_float(fp04));

    int_to_float u_itf_10 (.input_bin(p10), .output_float(fp10));
    int_to_float u_itf_11 (.input_bin(p11), .output_float(fp11));
    int_to_float u_itf_12 (.input_bin(p12), .output_float(fp12));
    int_to_float u_itf_13 (.input_bin(p13), .output_float(fp13));
    int_to_float u_itf_14 (.input_bin(p14), .output_float(fp14));

    int_to_float u_itf_20 (.input_bin(p20), .output_float(fp20));
    int_to_float u_itf_21 (.input_bin(p21), .output_float(fp21));
    int_to_float u_itf_22 (.input_bin(p22), .output_float(fp22));
    int_to_float u_itf_23 (.input_bin(p23), .output_float(fp23));
    int_to_float u_itf_24 (.input_bin(p24), .output_float(fp24));

    int_to_float u_itf_30 (.input_bin(p30), .output_float(fp30));
    int_to_float u_itf_31 (.input_bin(p31), .output_float(fp31));
    int_to_float u_itf_32 (.input_bin(p32), .output_float(fp32));
    int_to_float u_itf_33 (.input_bin(p33), .output_float(fp33));
    int_to_float u_itf_34 (.input_bin(p34), .output_float(fp34));

    int_to_float u_itf_40 (.input_bin(p40), .output_float(fp40));
    int_to_float u_itf_41 (.input_bin(p41), .output_float(fp41));
    int_to_float u_itf_42 (.input_bin(p42), .output_float(fp42));
    int_to_float u_itf_43 (.input_bin(p43), .output_float(fp43));
    int_to_float u_itf_44 (.input_bin(p44), .output_float(fp44));
    
    
    //--------------------------------------------------------------
    // stage 1 - 1 cyc delay 
    //multiply pixel vals with Sobel constants
    logic [31:0] gx0, gx1, gx2, gx3, gx4, gx5, gx6, gx7, gx8, gx9, gx10, gx11, gx12;
    logic [31:0] gx13, gx14, gx15, gx16, gx17, gx18, gx19, gx20, gx21, gx22, gx23, gx24;
    
    logic [31:0] gy0, gy1, gy2, gy3, gy4, gy5, gy6, gy7, gy8, gy9, gy10, gy11, gy12; 
    logic [31:0] gy13, gy14, gy15, gy16, gy17, gy18, gy19, gy20, gy21, gy22, gy23, gy24;
    
    // Gx
    // Kx: [-1 -2 0 2 1 | -4 -8 0 8 4 | -6 -12 0 12 6 |-4 -8 0 8 4 | -1 -2 0 2 1]
    //Gx = (-P00 - 2P01 + 2P03 + P04) + (-4P10 -8P11 + 8P13 +4P14) + (-6P20 - 12P21 + 12P23 + 6P24) + (-4P30 - 8P31 + 8P33 + 4P34) + (-P40 - 2P41 + 2P43 + P44)
    //
    float_multiplier u_mult_gx0(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp00), .b(const_m1), .result(gx0), .valid_out(vo_1));
    float_multiplier u_mult_gx1(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp01), .b(const_m2), .result(gx1), .valid_out());
    //float_multiplier u_mult_gx2(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp02), .b(const_0), .result(gx2), .valid_out());
    float_multiplier u_mult_gx3(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp03), .b(const_2), .result(gx3), .valid_out());
    float_multiplier u_mult_gx4(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp04), .b(const_1), .result(gx4), .valid_out());
    
    float_multiplier u_mult_gx5(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp10), .b(const_m4), .result(gx5), .valid_out());
    float_multiplier u_mult_gx6(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp11), .b(const_m8), .result(gx6), .valid_out());
    //float_multiplier u_mult_gx7(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp12), .b(const_0), .result(gx7), .valid_out());
    float_multiplier u_mult_gx8(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp13), .b(const_8), .result(gx8), .valid_out());
    float_multiplier u_mult_gx9(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp14), .b(const_4), .result(gx9), .valid_out());
    
    float_multiplier u_mult_gx10(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp20), .b(const_m6), .result(gx10), .valid_out());
    float_multiplier u_mult_gx11(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp21), .b(const_m12), .result(gx11), .valid_out());
    //float_multiplier u_mult_gx12(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp22), .b(const_0), .result(gx12), .valid_out());
    float_multiplier u_mult_gx13(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp23), .b(const_12), .result(gx13), .valid_out());
    float_multiplier u_mult_gx14(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp24), .b(const_6), .result(gx14), .valid_out());
    
    float_multiplier u_mult_gx15(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp30), .b(const_m4), .result(gx15), .valid_out());
    float_multiplier u_mult_gx16(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp31), .b(const_m8), .result(gx16), .valid_out());
    //float_multiplier u_mult_gx17(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp32), .b(const_0), .result(gx17), .valid_out());
    float_multiplier u_mult_gx18(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp33), .b(const_8), .result(gx18), .valid_out());
    float_multiplier u_mult_gx19(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp34), .b(const_4), .result(gx19), .valid_out());
    
    float_multiplier u_mult_gx20(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp40), .b(const_m1), .result(gx20), .valid_out());
    float_multiplier u_mult_gx21(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp41), .b(const_m2), .result(gx21), .valid_out());
    //float_multiplier u_mult_gx22(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp42), .b(const_0), .result(gx22), .valid_out());
    float_multiplier u_mult_gx23(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp43), .b(const_2), .result(gx23), .valid_out());
    float_multiplier u_mult_gx24(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp44), .b(const_1), .result(gx24), .valid_out());
    
    
    // Ky: [1 4 6 4 1 | 2 8 12 8 2| 0 0 0 0 0 | -2 -8 -12 -8 -2 | -1 -4 -6 -4 -1]
    //Gy =(P00 + 4P01 + 6P02 + 4P03 + P04) + (2P10 +8P11 + 12P12 + 8P13 +2P14) 
    // + (-2P30 - 8P31 -12P32 - 8P33 - 2P34) + (-P40 - 4P41 - 6P42 -4P43 - P44)
    //
    float_multiplier u_mult_gy0(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp00), .b(const_1), .result(gy0), .valid_out());
    float_multiplier u_mult_gy1(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp01), .b(const_4), .result(gy1), .valid_out());
    float_multiplier u_mult_gy2(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp02), .b(const_6), .result(gy2), .valid_out());
    float_multiplier u_mult_gy3(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp03), .b(const_4), .result(gy3), .valid_out());
    float_multiplier u_mult_gy4(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp04), .b(const_1), .result(gy4), .valid_out());
    
    float_multiplier u_mult_gy5(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp10), .b(const_2), .result(gy5), .valid_out());
    float_multiplier u_mult_gy6(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp11), .b(const_8), .result(gy6), .valid_out());
    float_multiplier u_mult_gy7(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp12), .b(const_12), .result(gy7), .valid_out());
    float_multiplier u_mult_gy8(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp13), .b(const_8), .result(gy8), .valid_out());
    float_multiplier u_mult_gy9(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp14), .b(const_2), .result(gy9), .valid_out());
    
    //float_multiplier u_mult_gy10(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp20), .b(const_0), .result(gy10), .valid_out());
    //float_multiplier u_mult_gy11(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp21), .b(const_0), .result(gy11), .valid_out());
    //float_multiplier u_mult_gy12(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp22), .b(const_0), .result(gy12), .valid_out());
    //float_multiplier u_mult_gy13(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp23), .b(const_0), .result(gy13), .valid_out());
    //float_multiplier u_mult_gy14(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp24), .b(const_0), .result(gy14), .valid_out());
    
    float_multiplier u_mult_gy15(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp30), .b(const_m2), .result(gy15), .valid_out());
    float_multiplier u_mult_gy16(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp31), .b(const_m8), .result(gy16), .valid_out());
    float_multiplier u_mult_gy17(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp32), .b(const_m12), .result(gy17), .valid_out());
    float_multiplier u_mult_gy18(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp33), .b(const_m8), .result(gy18), .valid_out());
    float_multiplier u_mult_gy19(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp34), .b(const_m2), .result(gy19), .valid_out());
    
    float_multiplier u_mult_gy20(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp40), .b(const_m1), .result(gy20), .valid_out());
    float_multiplier u_mult_gy21(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp41), .b(const_m4), .result(gy21), .valid_out());
    float_multiplier u_mult_gy22(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp42), .b(const_m6), .result(gy22), .valid_out());
    float_multiplier u_mult_gy23(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp43), .b(const_m4), .result(gy23), .valid_out());
    float_multiplier u_mult_gy24(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp44), .b(const_m1), .result(gy24), .valid_out());
    
    
    //--------------------------------------------------------------
    // stage 2 - 1 cycle delay
    // add factors in pairs-doubles
    // 25 vals -5 zeroed -> 20 vals -> 10 pairs
    logic [31:0] gx_d0, gx_d1, gx_d2, gx_d3, gx_d4, gx_d5, gx_d6, gx_d7, gx_d8, gx_d9; 
    logic [31:0] gy_d0, gy_d1, gy_d2, gy_d3, gy_d4, gy_d5, gy_d6, gy_d7, gy_d8, gy_d9;
    
    // Gx_d
    float_adder u_add_gx_d0(.clk(clk), .reset(reset), .valid_in(vo_1), .a(gx0), .b(gx1), .result(gx_d0), .valid_out(vo_2));
    float_adder u_add_gx_d1(.clk(clk), .reset(reset), .valid_in(vo_1), .a(gx3), .b(gx4), .result(gx_d1), .valid_out());
    float_adder u_add_gx_d2(.clk(clk), .reset(reset), .valid_in(vo_1), .a(gx5), .b(gx6), .result(gx_d2), .valid_out());
    float_adder u_add_gx_d3(.clk(clk), .reset(reset), .valid_in(vo_1), .a(gx8), .b(gx9), .result(gx_d3), .valid_out());
    float_adder u_add_gx_d4(.clk(clk), .reset(reset), .valid_in(vo_1), .a(gx10), .b(gx11), .result(gx_d4), .valid_out());
    float_adder u_add_gx_d5(.clk(clk), .reset(reset), .valid_in(vo_1), .a(gx13), .b(gx14), .result(gx_d5), .valid_out());
    float_adder u_add_gx_d6(.clk(clk), .reset(reset), .valid_in(vo_1), .a(gx15), .b(gx16), .result(gx_d6), .valid_out());
    float_adder u_add_gx_d7(.clk(clk), .reset(reset), .valid_in(vo_1), .a(gx18), .b(gx19), .result(gx_d7), .valid_out());
    float_adder u_add_gx_d8(.clk(clk), .reset(reset), .valid_in(vo_1), .a(gx20), .b(gx21), .result(gx_d8), .valid_out());
    float_adder u_add_gx_d9(.clk(clk), .reset(reset), .valid_in(vo_1), .a(gx23), .b(gx24), .result(gx_d9), .valid_out());

    // Gy_d
    float_adder u_add_gy_d0(.clk(clk), .reset(reset), .valid_in(vo_1), .a(gy0), .b(gy1), .result(gy_d0), .valid_out());
    float_adder u_add_gy_d1(.clk(clk), .reset(reset), .valid_in(vo_1), .a(gy2), .b(gy3), .result(gy_d1), .valid_out());
    float_adder u_add_gy_d2(.clk(clk), .reset(reset), .valid_in(vo_1), .a(gy4), .b(gy5), .result(gy_d2), .valid_out());
    float_adder u_add_gy_d3(.clk(clk), .reset(reset), .valid_in(vo_1), .a(gy6), .b(gy7), .result(gy_d3), .valid_out());
    float_adder u_add_gy_d4(.clk(clk), .reset(reset), .valid_in(vo_1), .a(gy8), .b(gy9), .result(gy_d4), .valid_out());
    float_adder u_add_gy_d5(.clk(clk), .reset(reset), .valid_in(vo_1), .a(gy15), .b(gy16), .result(gy_d5), .valid_out());
    float_adder u_add_gy_d6(.clk(clk), .reset(reset), .valid_in(vo_1), .a(gy17), .b(gy18), .result(gy_d6), .valid_out());
    float_adder u_add_gy_d7(.clk(clk), .reset(reset), .valid_in(vo_1), .a(gy19), .b(gy20), .result(gy_d7), .valid_out());
    float_adder u_add_gy_d8(.clk(clk), .reset(reset), .valid_in(vo_1), .a(gy21), .b(gy22), .result(gy_d8), .valid_out());
    float_adder u_add_gy_d9(.clk(clk), .reset(reset), .valid_in(vo_1), .a(gy23), .b(gy24), .result(gy_d9), .valid_out());
    
    
    //--------------------------------------------------------------
    // stage 3 - 1 cycle delay
    //second level addition
    logic [31:0] gx_2d1, gx_2d2, gx_2d3, gx_2d4, gx_2d5;  
    logic [31:0] gy_2d1, gy_2d2, gy_2d3, gy_2d4, gy_2d5;
    
    //Gx_2d
    float_adder u_add_gx_2d1(.clk(clk), .reset(reset), .valid_in(vo_2), .a(gx_d0), .b(gx_d1), .result(gx_2d1), .valid_out(vo_3));
    float_adder u_add_gx_2d2(.clk(clk), .reset(reset), .valid_in(vo_2), .a(gx_d2), .b(gx_d3), .result(gx_2d2), .valid_out());
    float_adder u_add_gx_2d3(.clk(clk), .reset(reset), .valid_in(vo_2), .a(gx_d4), .b(gx_d5), .result(gx_2d3), .valid_out());
    float_adder u_add_gx_2d4(.clk(clk), .reset(reset), .valid_in(vo_2), .a(gx_d6), .b(gx_d7), .result(gx_2d4), .valid_out());
    float_adder u_add_gx_2d5(.clk(clk), .reset(reset), .valid_in(vo_2), .a(gx_d8), .b(gx_d9), .result(gx_2d5), .valid_out());

    //Gy_2d
    float_adder u_add_gy_2d1(.clk(clk), .reset(reset), .valid_in(vo_2), .a(gy_d0), .b(gy_d1), .result(gy_2d1), .valid_out());
    float_adder u_add_gy_2d2(.clk(clk), .reset(reset), .valid_in(vo_2), .a(gy_d2), .b(gy_d3), .result(gy_2d2), .valid_out());
    float_adder u_add_gy_2d3(.clk(clk), .reset(reset), .valid_in(vo_2), .a(gy_d4), .b(gy_d5), .result(gy_2d3), .valid_out());
    float_adder u_add_gy_2d4(.clk(clk), .reset(reset), .valid_in(vo_2), .a(gy_d6), .b(gy_d7), .result(gy_2d4), .valid_out());
    float_adder u_add_gy_2d5(.clk(clk), .reset(reset), .valid_in(vo_2), .a(gy_d8), .b(gy_d9), .result(gy_2d5), .valid_out());
    
    
    //--------------------------------------------------------------
    // stage 4 - 1 cycle delay
    // third level addition
    logic [31:0] gx_3d1, gx_3d2, gx_3d3; 
    logic [31:0] gy_3d1, gy_3d2, gy_3d3; 

    float_adder u_add_gx_3d1 (.clk(clk), .reset(reset), .valid_in(vo_3), .a(gx_2d1), .b(gx_2d2), .result(gx_3d1), .valid_out(vo_4));
    float_adder u_add_gx_3d2 (.clk(clk), .reset(reset), .valid_in(vo_3), .a(gx_2d3), .b(gx_2d4), .result(gx_3d2), .valid_out());

    float_adder u_add_gy_3d1 (.clk(clk), .reset(reset), .valid_in(vo_3), .a(gy_2d1), .b(gy_2d2), .result(gy_3d1), .valid_out());
    float_adder u_add_gy_3d2 (.clk(clk), .reset(reset), .valid_in(vo_3), .a(gy_2d3), .b(gy_2d4), .result(gy_3d2), .valid_out());

    // delay values gx_2d gy_2d5 for 1 cycle to add later
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            gx_3d3 <= 32'd0;
            gy_3d3 <= 32'd0;
        end 
        else if (vo_3) begin
            gx_3d3 <= gx_2d5;
            gy_3d3 <= gy_2d5;
        end
    end
    
    //--------------------------------------------------------------
    // stage 5 - 1 cycle delay
    // fourth level addition
    logic [31:0] gx_4d1, gx_4d2; 
    logic [31:0] gy_4d1, gy_4d2; 

    float_adder u_add_gx_4d1 (.clk(clk), .reset(reset), .valid_in(vo_4), .a(gx_3d1), .b(gx_3d2), .result(gx_4d1), .valid_out(vo_5));
    float_adder u_add_gy_4d1 (.clk(clk), .reset(reset), .valid_in(vo_4), .a(gy_3d1), .b(gy_3d2), .result(gy_4d1), .valid_out());

    // delay values gx_3d3 gy_3d3 for 1 cycle to add later
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            gx_4d2 <= 32'd0;
            gy_4d2 <= 32'd0;
        end 
        else if (vo_4) begin
            gx_4d2 <= gx_3d3;
            gy_4d2 <= gy_3d3;
        end
    end
    
    //--------------------------------------------------------------
    // stage 6 - 1 cycle delay
    // final addition
    logic [31:0] gx_sum, gy_sum; 

    float_adder u_add_gx_sum (.clk(clk), .reset(reset), .valid_in(vo_5), .a(gx_4d1), .b(gx_4d2), .result(gx_sum), .valid_out(vo_6));
    float_adder u_add_gy_sum (.clk(clk), .reset(reset), .valid_in(vo_5), .a(gy_4d1), .b(gy_4d2), .result(gy_sum), .valid_out());

    
    //--------------------------------------------------------------
    // stage 7 - 1 cycle delay
    // calc magnitude G
    logic [31:0] gx_abs, gy_abs;
    logic [31:0] g_sum_float;
    
    //make gx, gy absolute - change sign bit
    assign gx_abs = {1'b0, gx_sum[30:0]};
    assign gy_abs = {1'b0, gy_sum[30:0]};
    
    float_adder u_add_g (.clk(clk), .reset(reset), .valid_in(vo_6), .a(gx_abs), .b(gy_abs), .result(g_sum_float), .valid_out(valid_out));
    
    //--------------------------------------------------------------
    // stage 8 - 0 delay
    // turn float to int
    float_to_int u_fti (.input_float(g_sum_float), .output_int(pixel_out));

    
endmodule