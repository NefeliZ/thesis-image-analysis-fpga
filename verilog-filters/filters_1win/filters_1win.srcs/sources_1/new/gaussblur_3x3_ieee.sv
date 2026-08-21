`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// gaussian blur (decimal)  with 3x3 window
// implement IEEE 754  
// single precisison floating point format
//////

module gaussblur_3x3_ieee #(

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
    //gaussblur filter constants in ieee format - weight matrix *1/16
    localparam logic [31:0] const_1 = 32'h3d800000; //1 -> 1/16 = 3d800000
    localparam logic [31:0] const_2 = 32'h3e000000;//2 -> 2/16 =0.125
    localparam logic [31:0] const_4 = 32'h3e800000;//4 -> 4/16 = 0.25
    localparam logic [31:0] const_0 = 32'h00000000;// 0
    
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
        
    
    //turn input to float & calculation with image and gaussblur matrix   
    logic [31:0] ix0, ix1, ix2, ix3, ix4, ix5, ix6, ix7, ix8;
    logic v1; //for validation
        
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            v1 <= 1'b0;
            //init vals to 0 
            ix0 <= const_0;
            ix1 <= const_0;
            ix2 <= const_0;
            ix3 <= const_0;
            ix4 <= const_0;
            ix5 <= const_0;
            ix6 <= const_0;
            ix7 <= const_0;
            ix8 <= const_0;
            
        end 
        else begin
            v1 <= valid_in; //take valid_in val (=1)
            if (valid_in) begin
                // calc factors for g
                // K: 1/16 * [1 2 1 | 2 4 2 | 1 2 1]
                //-> 1*img00, 2*img01, 1*img02 , 2*img10, 4*img11, 2*img12 , 1*img20, 2*img21, 1*img22
                // multiply floats ( float(img-window val) , number)
                ix0 <= mult_float(to_float(window[0][0]), const_1);
                ix1 <= mult_float(to_float(window[0][1]), const_2);
                ix2 <= mult_float(to_float(window[0][2]), const_1);
                ix3 <= mult_float(to_float(window[1][0]), const_2);
                ix4 <= mult_float(to_float(window[1][1]), const_4);
                ix5 <= mult_float(to_float(window[1][2]), const_2);
                ix6 <= mult_float(to_float(window[2][0]), const_1);
                ix7 <= mult_float(to_float(window[2][1]), const_2);
                ix8 <= mult_float(to_float(window[2][2]), const_1);
            end
        end
    end
    
    // add factors to calculate g
    logic [31:0] g_float;
    logic v2; //for validation

    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            v2 <= 1'b0;
            g_float <= const_0; //init as 0
        end 
        else begin
            v2 <= v1; //take v1 val (=1)
            if (v1) begin
                // add in pairs
               g_float <= add_float( add_float(   add_float( add_float(ix0, ix1), add_float(ix2, ix3)  ), add_float(  add_float(ix4, ix5), add_float(ix6, ix7)  )   ), ix8);
               //       final-add[[[         [[           {{        (ix0+ix1)   +   (ix2+ix3)         }}     +    {{          (ix4+ix5)   +   (ix6+ix7)        }}  ]] + ix8 ]]]
            end
        end
    end 
    
    
    //final calc -  turn to int
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            valid_out <= 1'b0;
            pixel_out <= 8'd0;
        end 
        else begin
            valid_out <= v2; //=1
            if (v2) begin
                
                shortreal r_val;
                int int_gval;

                //turn back to int
                r_val = $bitstoshortreal(g_float);
                int_gval = int'(r_val);

                //cutoff -saturation (0-255)
                if (int_gval > 255)
                    pixel_out <= 8'd255;
                else if (int_gval < 0)
                    pixel_out <= 8'd0;
                else
                    pixel_out <= int_gval[7:0];
            end
        end
    end

endmodule