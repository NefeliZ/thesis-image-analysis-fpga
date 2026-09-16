`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// gaussin blur filter with 5x5 window - ieee
//////

module gaussblur5x5_ieee #(

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
    logic vo_1, vo_2, vo_3, vo_4, vo_5;
    
    //gaussian blur constants in ieee format
    //localparam logic [31:0] const_1 = 32'h3f800000; //1
    localparam logic [31:0] const_2 = 32'h40000000; //2
    localparam logic [31:0] const_4 = 32'h40800000; //4
    localparam logic [31:0] const_6 = 32'h40c00000; //6
    localparam logic [31:0] const_16 = 32'h41800000; //16
    localparam logic [31:0] const_24 = 32'h41c00000; // 24
    localparam logic [31:0] const_36 = 32'h42100000; // 36
    localparam logic [31:0] const_256 = 32'h3b800000; // 1/256

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
    //multiply pixel vals with constants
    logic [31:0] g0, g1, g2, g3, g4, g5, g6, g7, g8, g9, g10, g11, g12;
    logic [31:0] g13, g14, g15, g16, g17, g18, g19, g20, g21, g22, g23, g24;
    
    // (1P00 + 4P01 + 6P02 + 4P03 + 1P04) + 
    // (4P10 + 16P11 + 24P12 + 16P13 + 4P14) + 
    // (6P20 + 24P21 + 36P22 + 24P23 + 6P24) + 
    // (4P30 + 16P31 + 24P32 + 16P33 + 4P34) + 
    // (1P40 +  4P41 + 6P42  + 4P43 + 1P44)
    //float_multiplier u_mult_g0 (.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp00), .b(const_1), .result(g0), .valid_out(vo_1));
    float_multiplier u_mult_g1 (.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp01), .b(const_4), .result(g1), .valid_out(vo_1));
    float_multiplier u_mult_g2 (.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp02), .b(const_6), .result(g2), .valid_out());
    float_multiplier u_mult_g3(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp03), .b(const_4), .result(g3), .valid_out());
    //float_multiplier u_mult_g4(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp04), .b(const_1), .result(g4), .valid_out());
    
    float_multiplier u_mult_g5(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp10), .b(const_4), .result(g5), .valid_out());
    float_multiplier u_mult_g6(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp11), .b(const_16), .result(g6), .valid_out());
    float_multiplier u_mult_g7(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp12), .b(const_24), .result(g7), .valid_out());
    float_multiplier u_mult_g8(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp13), .b(const_16), .result(g8), .valid_out());
    float_multiplier u_mult_g9(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp14), .b(const_4), .result(g9), .valid_out());
    
    float_multiplier u_mult_g10(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp20), .b(const_6), .result(g10), .valid_out());
    float_multiplier u_mult_g11(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp21), .b(const_24), .result(g11), .valid_out());
    float_multiplier u_mult_g12(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp22), .b(const_36), .result(g12), .valid_out());
    float_multiplier u_mult_g13(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp23), .b(const_24), .result(g13), .valid_out());
    float_multiplier u_mult_g14(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp24), .b(const_6), .result(g14), .valid_out());
    
    float_multiplier u_mult_g15(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp30), .b(const_4), .result(g15), .valid_out());
    float_multiplier u_mult_g16(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp31), .b(const_16), .result(g16), .valid_out());
    float_multiplier u_mult_g17(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp32), .b(const_24), .result(g17), .valid_out());
    float_multiplier u_mult_g18(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp33), .b(const_16), .result(g18), .valid_out());
    float_multiplier u_mult_g19(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp34), .b(const_4), .result(g19), .valid_out());
    
    //float_multiplier u_mult_g20(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp40), .b(const_1), .result(g20), .valid_out());
    float_multiplier u_mult_g21(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp41), .b(const_4), .result(g21), .valid_out());
    float_multiplier u_mult_g22(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp42), .b(const_6), .result(g22), .valid_out());
    float_multiplier u_mult_g23(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp43), .b(const_4), .result(g23), .valid_out());
    //float_multiplier u_mult_g24(.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp44), .b(const_1), .result(g24), .valid_out());
    
    //instead f val*1 (cost) - just delay them for a cycle
    // keep val for next cycle
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            g0 <= 32'd0;
            g4 <= 32'd0;
            g20 <= 32'd0;
            g24 <= 32'd0;
        end 
        else if (valid_in) begin
            g0 <= fp00;
            g4 <= fp04;
            g20 <= fp40;
            g24 <= fp44;
        end
    end
    
    //--------------------------------------------------------------
    // stage 2 - 1 cycle delay
    // 1st level addition
    // 25 vals -> 12 pairs and keep 1
    logic [31:0] g_d1, g_d2, g_d3, g_d4, g_d5, g_d6, g_d7;
    logic [31:0] g_d8, g_d9, g_d10, g_d11, g_d12, g_d13;
    
    float_adder u_add_g_d1(.clk(clk), .reset(reset), .valid_in(vo_1), .a(g0), .b(g1), .result(g_d1), .valid_out(vo_2));
    float_adder u_add_g_d2(.clk(clk), .reset(reset), .valid_in(vo_1), .a(g2), .b(g3), .result(g_d2), .valid_out());
    float_adder u_add_g_d3(.clk(clk), .reset(reset), .valid_in(vo_1), .a(g4), .b(g5), .result(g_d3), .valid_out());
    float_adder u_add_g_d4(.clk(clk), .reset(reset), .valid_in(vo_1), .a(g6), .b(g7), .result(g_d4), .valid_out());
    float_adder u_add_g_d5(.clk(clk), .reset(reset), .valid_in(vo_1), .a(g8), .b(g9), .result(g_d5), .valid_out());
    float_adder u_add_g_d6(.clk(clk), .reset(reset), .valid_in(vo_1), .a(g10), .b(g11), .result(g_d6), .valid_out());
    float_adder u_add_g_d7(.clk(clk), .reset(reset), .valid_in(vo_1), .a(g12), .b(g13), .result(g_d7), .valid_out());
    float_adder u_add_g_d8(.clk(clk), .reset(reset), .valid_in(vo_1), .a(g14), .b(g15), .result(g_d8), .valid_out());
    float_adder u_add_g_d9(.clk(clk), .reset(reset), .valid_in(vo_1), .a(g16), .b(g17), .result(g_d9), .valid_out());
    float_adder u_add_g_d10(.clk(clk), .reset(reset), .valid_in(vo_1), .a(g18), .b(g19), .result(g_d10), .valid_out());
    float_adder u_add_g_d11(.clk(clk), .reset(reset), .valid_in(vo_1), .a(g20), .b(g21), .result(g_d11), .valid_out());
    float_adder u_add_g_d12(.clk(clk), .reset(reset), .valid_in(vo_1), .a(g22), .b(g23), .result(g_d12), .valid_out());
    
    // keep val for next cycle
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            g_d13 <= 32'd0;
        end 
        else if (vo_1) begin
            g_d13 <= g24;
        end
    end
    
    //--------------------------------------------------------------
    // stage 3 - 1 cycle delay
    //second level addition
    logic [31:0] g_2d1, g_2d2, g_2d3, g_2d4, g_2d5, g_2d6, g_2d7; // 13 vals -> 6 pairs and keep 1
    
    float_adder u_add_g_2d1(.clk(clk), .reset(reset), .valid_in(vo_2), .a(g_d1), .b(g_d2), .result(g_2d1), .valid_out(vo_3));
    float_adder u_add_g_2d2(.clk(clk), .reset(reset), .valid_in(vo_2), .a(g_d3), .b(g_d4), .result(g_2d2), .valid_out());
    float_adder u_add_g_2d3(.clk(clk), .reset(reset), .valid_in(vo_2), .a(g_d5), .b(g_d6), .result(g_2d3), .valid_out());
    float_adder u_add_g_2d4(.clk(clk), .reset(reset), .valid_in(vo_2), .a(g_d7), .b(g_d8), .result(g_2d4), .valid_out());
    float_adder u_add_g_2d5(.clk(clk), .reset(reset), .valid_in(vo_2), .a(g_d9), .b(g_d10), .result(g_2d5), .valid_out());
    float_adder u_add_g_2d6(.clk(clk), .reset(reset), .valid_in(vo_2), .a(g_d11), .b(g_d12), .result(g_2d6), .valid_out());
    
    // keep val for next cycle
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            g_2d7 <= 32'd0;
        end 
        else if (vo_2) begin
            g_2d7 <= g_d13;
        end
    end
    
    
    //--------------------------------------------------------------
    // stage 4 - 1 cycle delay
    // third level addition
    logic [31:0] g_3d1, g_3d2, g_3d3, g_3d4; // 7 vals -> 3 pairs and keep 1
    
    float_adder u_add_g_3d1(.clk(clk), .reset(reset), .valid_in(vo_3), .a(g_2d1), .b(g_2d2), .result(g_3d1), .valid_out(vo_4));
    float_adder u_add_g_3d2(.clk(clk), .reset(reset), .valid_in(vo_3), .a(g_2d3), .b(g_2d4), .result(g_3d2), .valid_out());
    float_adder u_add_g_3d3(.clk(clk), .reset(reset), .valid_in(vo_3), .a(g_2d5), .b(g_2d6), .result(g_3d3), .valid_out());

    // keep val for next cycle
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            g_3d4 <= 32'd0;
        end 
        else if (vo_3) begin
            g_3d4 <= g_2d7;
        end
    end
    
    //--------------------------------------------------------------
    // stage 5 - 1 cycle delay
    // fourth level addition
    logic [31:0] g_4d1, g_4d2; // 4 vals -> 2 pairs
    
    float_adder u_add_g_4d1(.clk(clk), .reset(reset), .valid_in(vo_4), .a(g_3d1), .b(g_3d2), .result(g_4d1), .valid_out(vo_5));
    float_adder u_add_g_4d2(.clk(clk), .reset(reset), .valid_in(vo_4), .a(g_3d3), .b(g_3d4), .result(g_4d2), .valid_out());

    
    //--------------------------------------------------------------
    // stage 6 - 1 cycle delay
    // final addition
    logic [31:0] g_sum; 

    float_adder u_add_g_sum (.clk(clk), .reset(reset), .valid_in(vo_5), .a(g_4d1), .b(g_4d2), .result(g_sum), .valid_out(vo_6));

    //--------------------------------------------------------------
    // stage 7 - 1 cycle delay
    // calc G - multiply sum with 1/16 
    logic [31:0] g_float;
    
    float_multiplier u_mult_g (.clk(clk), .reset(reset), .valid_in(vo_6), .a(g_sum), .b(const_256), .result(g_float), .valid_out(valid_out)); 

    //--------------------------------------------------------------
    // stage 8 - 0 delay
    // turn float to int
    float_to_int u_fti (.input_float(g_float), .output_int(pixel_out));
    

endmodule