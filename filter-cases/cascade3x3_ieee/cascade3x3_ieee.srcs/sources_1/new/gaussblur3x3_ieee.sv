`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// gaussin blur filter with 3x3 window - ieee
//////

module gaussblur3x3_ieee #(

 parameter DATA_WIDTH = 8
)(
    input logic clk,
    input logic reset,
    input logic valid_in,
    
    //pixel inputs  
    input  logic [DATA_WIDTH-1:0] p00, p01, p02,
    input  logic [DATA_WIDTH-1:0] p10, p11, p12,
    input  logic [DATA_WIDTH-1:0] p20, p21, p22,
    
    output logic valid_out,
    output logic [DATA_WIDTH-1:0] pixel_out // center pixel val - G
);
    
    //valid_out vars for all stages - keep flow
    //valid_out only in 1 instance per stage - avoid error
    logic vo_1, vo_2, vo_3, vo_4, vo_5;
    
    //gaussian blur constants in ieee format
    // K: 1/16 * [1 2 1 | 2 4 2 | 1 2 1]
    localparam logic [31:0] const_1 = 32'h3f800000; //1
    localparam logic [31:0] const_2 = 32'h40000000; //2
    localparam logic [31:0] const_4 = 32'h40800000; //4
    localparam logic [31:0] const_16 = 32'h3d800000; //1/16
    
    
    //--------------------------------------------------------------
    // stage 0 - 0 delay
    // change input integers to ieee floats
    logic [31:0] fp00, fp01, fp02, fp10, fp11, fp12, fp20, fp21, fp22;
    
    int_to_float u_itf_00 (.input_bin(p00), .output_float(fp00));
    int_to_float u_itf_01 (.input_bin(p01), .output_float(fp01));
    int_to_float u_itf_02 (.input_bin(p02), .output_float(fp02));
    
    int_to_float u_itf_10 (.input_bin(p10), .output_float(fp10));
    int_to_float u_itf_11 (.input_bin(p11), .output_float(fp11));
    int_to_float u_itf_12 (.input_bin(p12), .output_float(fp12));

    int_to_float u_itf_20 (.input_bin(p20), .output_float(fp20));
    int_to_float u_itf_21 (.input_bin(p21), .output_float(fp21));
    int_to_float u_itf_22 (.input_bin(p22), .output_float(fp22));

    //--------------------------------------------------------------
    // stage 1 - 1 cyc delay 
    //multiply pixel vals with constants
    logic [31:0] g0, g1, g2, g3, g4, g5, g6, g7, g8;
    
    //-> 1*img00, 2*img01, 1*img02 , 2*img10, 4*img11, 2*img12 , 1*img20, 2*img21, 1*img22
    //float_multiplier u_mult_g0 (.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp00), .b(const_1), .result(g0), .valid_out(vo_1)); 
    float_multiplier u_mult_g1 (.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp01), .b(const_2), .result(g1), .valid_out(vo_1)); 
    //float_multiplier u_mult_g2 (.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp02), .b(const_1), .result(g2), .valid_out()); 
    float_multiplier u_mult_g3 (.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp10), .b(const_2), .result(g3), .valid_out());
    float_multiplier u_mult_g4 (.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp11), .b(const_4), .result(g4), .valid_out()); 
    float_multiplier u_mult_g5 (.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp12), .b(const_2), .result(g5), .valid_out()); 
    //float_multiplier u_mult_g6 (.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp20), .b(const_1), .result(g6), .valid_out()); 
    float_multiplier u_mult_g7 (.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp21), .b(const_2), .result(g7), .valid_out()); 
    //float_multiplier u_mult_g8 (.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp22), .b(const_1), .result(g8), .valid_out()); 
    
    //instead f val*1 (cost) - just delay them for a cycle
    // keep val for next cycle
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            g0 <= 32'd0;
            g2 <= 32'd0;
            g6 <= 32'd0;
            g8 <= 32'd0;
        end 
        else if (valid_in) begin
            g0 <= fp00;
            g2 <= fp02;
            g6 <= fp20;
            g8 <= fp22;
        end
    end
    
    //--------------------------------------------------------------
    // stage 2 - 1 cycle delay
    // add factors in pairs-doubles
    logic [31:0] g_d1, g_d2, g_d3, g_d4; // 9 vals -> 4 pairs and keep 1
    logic [31:0] g_d5; 
    
    float_adder u_add_g_d1 (.clk(clk), .reset(reset), .valid_in(vo_1), .a(g0), .b(g1), .result(g_d1), .valid_out(vo_2));
    float_adder u_add_g_d2 (.clk(clk), .reset(reset), .valid_in(vo_1), .a(g2), .b(g3), .result(g_d2), .valid_out());
    float_adder u_add_g_d3 (.clk(clk), .reset(reset), .valid_in(vo_1), .a(g4), .b(g5), .result(g_d3), .valid_out());
    float_adder u_add_g_d4 (.clk(clk), .reset(reset), .valid_in(vo_1), .a(g6), .b(g7), .result(g_d4), .valid_out());
    
    // keep val for next cycle
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            g_d5 <= 32'd0;
        end 
        else if (vo_1) begin
            g_d5 <= g8;
        end
    end
    
    //--------------------------------------------------------------
    // stage 3 - 1 cycle delay
    //second level addition
    logic [31:0] g_2d1, g_2d2; // 5 vals -> 2 pairs and keep 1
    logic [31:0] g_2d3;
    
    float_adder u_add_g_2d1 (.clk(clk), .reset(reset), .valid_in(vo_2), .a(g_d1), .b(g_d2), .result(g_2d1), .valid_out(vo_3));
    float_adder u_add_g_2d2 (.clk(clk), .reset(reset), .valid_in(vo_2), .a(g_d3), .b(g_d4), .result(g_2d2), .valid_out());
    
    // keep val for next cycle
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            g_2d3 <= 32'd0;
        end 
        else if (vo_2) begin
            g_2d3 <= g_d5;
        end
    end
    
    //--------------------------------------------------------------
    // stage 4 - 1 cycle delay
    // third level addition
    logic [31:0] g_3d1; // 3 vals -> 1 pairs and keep 1
    logic [31:0] g_3d2;
    
    float_adder u_add_g_3d1 (.clk(clk), .reset(reset), .valid_in(vo_3), .a(g_2d1), .b(g_2d2), .result(g_3d1), .valid_out(vo_4));

    // keep val for next cycle
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            g_3d2 <= 32'd0;
        end 
        else if (vo_3) begin
            g_3d2 <= g_2d3;
        end
    end
    
    //--------------------------------------------------------------
    // stage 5 - 1 cycle delay
    // final addition
    logic [31:0] g_sum;

    float_adder u_add_g_sum (.clk(clk), .reset(reset), .valid_in(vo_4), .a(g_3d1), .b(g_3d2), .result(g_sum), .valid_out(vo_5));

    //--------------------------------------------------------------
    // stage 6 - 1 cycle delay
    // calc G - multiply sum with 1/16 
    logic [31:0] g_float;
    
    float_multiplier u_mult_g (.clk(clk), .reset(reset), .valid_in(vo_5), .a(g_sum), .b(const_16), .result(g_float), .valid_out(valid_out)); 

    //--------------------------------------------------------------
    // stage 7 - 0 delay
    // turn float to int
    float_to_int u_fti (.input_float(g_float), .output_int(pixel_out));
    

endmodule