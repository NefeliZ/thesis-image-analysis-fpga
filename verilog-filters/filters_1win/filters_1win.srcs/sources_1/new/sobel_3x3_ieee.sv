`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// sobel filter with 3x3 window
// implement IEEE 754  
// single precisison floating point format
//////

module sobel_3x3_ieee #(

 parameter DATA_WIDTH = 8
)(
    input logic clk,
    input logic reset,
    input logic valid_in,
    
    // 2D array 3x3 - filter window
    input  logic [DATA_WIDTH-1:0] window [0:2][0:2],
    
    output logic valid_out,
    output logic [DATA_WIDTH-1:0] pixel_out // center pixel val - G
);
    //sobel filter constants in ieee format
    localparam logic [31:0] const_1 = 32'h3f800000; //1
    localparam logic [31:0] const_m1 = 32'hbf800000;//-1
    localparam logic [31:0] const_0 = 32'h00000000;//0
    localparam logic [31:0] const_2 = 32'h40000000;//2
    localparam logic [31:0] const_m2 = 32'hc0000000;//-2
    
    //// helper functions
    // turn float to ieee float
    function automatic logic [31:0] to_float(input logic [7:0] val);
        shortreal r;
        r = shortreal'(val);
        
        return $shortrealtobits(r);
    endfunction
    
    // add 2 floats (and turn to ieee)
    function automatic logic[31:0] add_float(input logic[31:0] a, input logic[31:0] b);
        shortreal r_a, r_b;
        r_a = $bitstoshortreal(a);
        r_b = $bitstoshortreal(b);

        return $shortrealtobits(r_a + r_b); //add and turn to ieee
        endfunction
    
   // multiply 2 floats (and turn to ieee)
    function automatic logic[31:0] mult_float(input logic[31:0] a, input logic[31:0] b);
        shortreal r_a, r_b;
        r_a = $bitstoshortreal(a);
        r_b = $bitstoshortreal(b);
        
        return $shortrealtobits(r_a * r_b); //multiply and turn to ieee
        endfunction
        
    
    //turn input to float & calculation with image and sobel matrix   
    logic [31:0] ix0, ix2, ix3, ix5, ix6, ix8; //ix1, ix4, ix7 = 0
    logic [31:0] iy0, iy1, iy2, iy6, iy7, iy8; //iy3,4,5 =0
    logic v1; //for validation
        
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            v1 <= 1'b0;
            //init vals to 0 
            ix0 <= const_0;
            ix2 <= const_0;
            ix3 <= const_0;
            ix5 <= const_0;
            ix6 <= const_0;
            ix8 <= const_0;
            //
            iy0 <= const_0;
            iy1 <= const_0;
            iy2 <= const_0;
            iy6 <= const_0;
            iy7 <= const_0;
            iy8 <= const_0;
        end 
        else begin
            v1 <= valid_in; //take valid_in val (=1)
            if (valid_in) begin
                // calc factors for gx & gy
                // Kx: [1 0 -1 | 2 0 -2 | 1 0 -1]
                // gx = 1*img00 + 0* img01 + -1*img02 + 2*img10 + 0*img11 + -2*img12 + 1*img20 +0*img21 + -1*img22
                //-> 1*img00,  -1*img02 , 2*img10 , -2*img12 , 1*img20 , -1*img22
                ix0 <= mult_float(to_float(window[0][0]), const_1);
                ix2 <= mult_float(to_float(window[0][2]), const_m1);
                ix3 <= mult_float(to_float(window[1][0]), const_2);
                ix5 <= mult_float(to_float(window[1][2]), const_m2);
                ix6 <= mult_float(to_float(window[2][0]), const_1);
                ix8 <= mult_float(to_float(window[2][2]), const_m1);
                //ix1, ix4, ix7 = 0
    
                // Ky: [1 2 1 | 0 0 0 | -1 -2 -1]
                // gy = 1*img00 + 2* img01 + 1*img02 + 0*img10 + 0*img11 + 0*img12 + -1*img20 + -2*img21 + -1*img22
                //-> 1*img00 , 2* img01 , 1*img02 , -1*img20 , -2*img21 , -1*img22
                iy0 <= mult_float(to_float(window[0][0]), const_1);
                iy1 <= mult_float(to_float(window[0][1]), const_2);
                iy2 <= mult_float(to_float(window[0][2]), const_1);
                iy6 <= mult_float(to_float(window[2][0]), const_m1);
                iy7 <= mult_float(to_float(window[2][1]), const_m2);
                iy8 <= mult_float(to_float(window[2][2]), const_m1);
                //iy3,4,5 =0
            end
        end
    end
    
    // add factors to calculate gx gy
    logic [31:0] gx_float, gy_float;
    logic v2; //for validation

    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            v2 <= 1'b0;
            gx_float <= const_0; //init as 0
            gy_float <= const_0;
        end 
        else begin
            v2 <= v1; //take v1 val (=1)
            if (v1) begin
                // add in pairs
                gx_float <= add_float( add_float( add_float(ix0, ix2), add_float(ix3, ix5)), add_float(ix6, ix8));
                
                gy_float <= add_float( add_float( add_float(iy0, iy1), add_float(iy2, iy6)), add_float(iy7, iy8));
            end
        end
    end 
    
    
    //calc g (abs) & turn to int
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            valid_out <= 1'b0;
            pixel_out <= 8'd0;
        end 
        else begin
            valid_out <= v2; //=1
            if (v2) begin
            
                logic [31:0] abs_gx, abs_gy, g_sum;
                shortreal r_val;
                int int_val;

                // abs value-> make positive-> make 31stbit 0 (sign bit - ieee format)
                abs_gx = {1'b0, gx_float[30:0]}; //0 + the rest of the number
                abs_gy = {1'b0, gy_float[30:0]};

                //calc g gradient for sobel
                g_sum = add_float(abs_gx, abs_gy);

                //turn back to int
                r_val = $bitstoshortreal(g_sum);
                int_val = int'(r_val);

                //cutoff -saturation (0-255)
                if (int_val > 255)
                    pixel_out <= 8'd255;
                else if (int_val < 0)
                    pixel_out <= 8'd0;
                else
                    pixel_out <= int_val[7:0];
            end
        end
    end

endmodule