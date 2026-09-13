`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// sobel filter with 3x3 window - ieee
//////

module sobel3x3_ieee #(

 parameter DATA_WIDTH = 8
)(
    input logic clk,
    input logic reset,
    input logic valid_in,
       
    //pixel inputs 
    input logic [DATA_WIDTH-1:0] p00, p01, p02,
    input logic [DATA_WIDTH-1:0] p10, p11, p12,
    input logic [DATA_WIDTH-1:0] p20, p21, p22,
    
    output logic valid_out,
    output logic [DATA_WIDTH-1:0] pixel_out // center pixel val - G
);
    
    //valid_out vars for all stages - keep flow
    //valid_out only in 1 instance per stage - avoid error
    logic vo_1, vo_2, vo_3, vo_4;
    
    //sobel filter constants in ieee format
    localparam logic [31:0] const_1 = 32'h3f800000; //1
    localparam logic [31:0] const_m1 = 32'hbf800000;//-1
    localparam logic [31:0] const_0 = 32'h00000000;//0
    localparam logic [31:0] const_2 = 32'h40000000;//2
    localparam logic [31:0] const_m2 = 32'hc0000000;//-2
    
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
    //multiply pixel vals with Sobel constants
    logic [31:0] gx0, gx2, gx3, gx5, gx6, gx8;
    logic [31:0] gy0, gy1, gy2, gy6, gy7, gy8;
    
    
    // Gx
    // Kx: [1 0 -1 | 2 0 -2 | 1 0 -1]
    // gx = 1*img00 + 0* img01 + -1*img02 + 2*img10 + 0*img11 + -2*img12 + 1*img20 +0*img21 + -1*img22
    //-> 1*img00,  -1*img02 , 2*img10 , -2*img12 , 1*img20 , -1*img22
    float_multiplier u_mult_gx0 (.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp00), .b(const_1), .result(gx0), .valid_out(vo_1)); 
    //float_multiplier u_mult_gx1 (.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp01), .b(const_0), .result(gx1), .valid_out());//
    float_multiplier u_mult_gx2 (.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp02), .b(const_m1), .result(gx2), .valid_out());

    float_multiplier u_mult_gx3 (.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp10), .b(const_2), .result(gx3), .valid_out());
    //float_multiplier u_mult_gx4 (.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp11), .b(const_0), .result(gx4), .valid_out());//
    float_multiplier u_mult_gx5 (.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp12), .b(const_m2), .result(gx5), .valid_out());

    float_multiplier u_mult_gx6 (.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp20), .b(const_1), .result(gx6), .valid_out());
    //float_multiplier u_mult_gx7 (.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp21), .b(const_0), .result(gx7), .valid_out());//
    float_multiplier u_mult_gx8 (.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp22), .b(const_m1), .result(gx8), .valid_out());

    // Gy
    // Ky: [1 2 1 | 0 0 0 | -1 -2 -1]
    // gy = 1*img00 + 2* img01 + 1*img02 + 0*img10 + 0*img11 + 0*img12 + -1*img20 + -2*img21 + -1*img22
    //-> 1*img00 , 2* img01 , 1*img02 , -1*img20 , -2*img21 , -1*img22
    float_multiplier u_mult_gy0 (.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp00), .b(const_1), .result(gy0), .valid_out());
    float_multiplier u_mult_gy1 (.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp01), .b(const_2), .result(gy1), .valid_out());
    float_multiplier u_mult_gy2 (.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp02), .b(const_1), .result(gy2), .valid_out());

    //float_multiplier u_mult_gy3 (.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp10), .b(const_0), .result(gy3), .valid_out());//
    //float_multiplier u_mult_gy4 (.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp11), .b(const_0), .result(gy4), .valid_out());//
    //float_multiplier u_mult_gy5 (.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp12), .b(const_0), .result(gy5), .valid_out());//

    float_multiplier u_mult_gy6 (.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp20), .b(const_m1), .result(gy6), .valid_out());
    float_multiplier u_mult_gy7 (.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp21), .b(const_m2), .result(gy7), .valid_out());
    float_multiplier u_mult_gy8 (.clk(clk), .reset(reset), .valid_in(valid_in), .a(fp22), .b(const_m1), .result(gy8), .valid_out());
    
    
    //--------------------------------------------------------------
    // stage 2 - 1 cycle delay
    // add factors in pairs-doubles
    logic [31:0] gx_d1, gx_d2, gx_d3, gy_d1, gy_d2, gy_d3; //6 and 6 vals -> 3 gx_d 3 gy_d

    float_adder u_add_gx_d1 (.clk(clk), .reset(reset), .valid_in(vo_1), .a(gx0), .b(gx2), .result(gx_d1), .valid_out(vo_2));
    float_adder u_add_gx_d2 (.clk(clk), .reset(reset), .valid_in(vo_1), .a(gx3), .b(gx5), .result(gx_d2), .valid_out());
    float_adder u_add_gx_d3 (.clk(clk), .reset(reset), .valid_in(vo_1), .a(gx6), .b(gx8), .result(gx_d3), .valid_out());

    float_adder u_add_gy_d1 (.clk(clk), .reset(reset), .valid_in(vo_1), .a(gy0), .b(gy1), .result(gy_d1), .valid_out());
    float_adder u_add_gy_d2 (.clk(clk), .reset(reset), .valid_in(vo_1), .a(gy2), .b(gy6), .result(gy_d2), .valid_out());
    float_adder u_add_gy_d3 (.clk(clk), .reset(reset), .valid_in(vo_1), .a(gy7), .b(gy8), .result(gy_d3), .valid_out());
    
    //--------------------------------------------------------------
    // stage 3 - 1 cycle delay
    logic [31:0] gx_2d1, gy_2d1; //second level addition 
    
    float_adder u_add_gx_2d1 (.clk(clk), .reset(reset), .valid_in(vo_2), .a(gx_d1), .b(gx_d2), .result(gx_2d1), .valid_out(vo_3));
    float_adder u_add_gy_2d1 (.clk(clk), .reset(reset), .valid_in(vo_2), .a(gy_d1), .b(gy_d2), .result(gy_2d1), .valid_out());
    
    // delay values gx_d3 gy_d3 for 1 cycle to add later
    logic [31:0] gx_2d2, gy_2d2;
    
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            gx_2d2 <= 32'd0;
            gy_2d2 <= 32'd0;
        end 
        else if (vo_2) begin
            gx_2d2 <= gx_d3;
            gy_2d2 <= gy_d3;
        end
    end
    
    //--------------------------------------------------------------
    // stage 4 - 1 cycle delay
    logic [31:0] gx_sum, gy_sum; //third level addition - final vals

    float_adder u_add_gx_sum (.clk(clk), .reset(reset), .valid_in(vo_3), .a(gx_2d2), .b(gx_2d1), .result(gx_sum), .valid_out(vo_4));
    float_adder u_add_gy_sum (.clk(clk), .reset(reset), .valid_in(vo_3), .a(gy_2d2), .b(gy_2d1), .result(gy_sum), .valid_out());


    //--------------------------------------------------------------
    // stage 5 - 1 cycle delay
    // calc magnitude G
    logic [31:0] gx_abs, gy_abs;
    logic [31:0] g_sum_float;
    
    //make gx, gy absolute - change sign bit
    assign gx_abs = {1'b0, gx_sum[30:0]};
    assign gy_abs = {1'b0, gy_sum[30:0]};
    
    float_adder u_add_g (.clk(clk), .reset(reset), .valid_in(vo_4), .a(gx_abs), .b(gy_abs), .result(g_sum_float), .valid_out(valid_out));
    
    //--------------------------------------------------------------
    // stage 6 - 0 delay
    // turn float to int
    float_to_int u_fti (.input_float(g_sum_float), .output_int(pixel_out));

    
endmodule