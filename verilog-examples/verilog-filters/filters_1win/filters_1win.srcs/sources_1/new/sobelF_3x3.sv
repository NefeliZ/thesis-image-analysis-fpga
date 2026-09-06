`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// sobel filter with 3x3 window
//////

module sobelF_3x3 #(

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

    //middle vars used to calc - 11-bit
    logic signed [10:0] gx;
    logic signed [10:0] gy;
    logic [10:0] abs_gx;
    logic [10:0] abs_gy;
    logic [10:0] g_sum;

    //sobel filter calculations
    always_comb begin
        // Kx: [-1 0 1 | -2 0 2 | -1 0 1]
        //Gx = (Kx02 + 2Kx12 + Kx22) - (Kx00 +2Kx10 +Kx20)
        //extra 'paddign'(0s at the sign) to avoid error when shifting
        gx = $signed({3'b000, window[0][2]}) + ($signed({3'b000, window[1][2]}) << 1) + $signed({3'b000, window[2][2]})
           - $signed({3'b000, window[0][0]}) - ($signed({3'b000, window[1][0]}) << 1) - $signed({3'b000, window[2][0]});

        // Ky: [1 2 1 | 0 0 0 | -1 -2 -1]
        //Gy = (Ky00 + 2Ky01 + Ky02) - (Ky20 +2Ky21 +Ky22)
        gy = $signed({3'b000, window[0][0]}) + ($signed({3'b000, window[0][1]}) << 1) + $signed({3'b000, window[0][2]})
           - $signed({3'b000, window[2][0]}) - ($signed({3'b000, window[2][1]}) << 1) - $signed({3'b000, window[2][2]});

        // absolute vals
        abs_gx = (gx < 0) ? -gx : gx;
        abs_gy = (gy < 0) ? -gy : gy;

        //sum G = |Gx| + |Gy|
        g_sum = abs_gx + abs_gy;
    end

    //make output logic
    always_ff @(posedge clk or negedge reset) begin //activate at posedge or at reset
        if (!reset) begin //if reset=1 -> output=0 (reset)
            pixel_out <= '0;
            valid_out <= 1'b0;
        end 
        else if (valid_in) begin //if it took val
        //[
            if (g_sum > 11'd255) // if 11-bit and >255 => keep 255 8bit (white-max val)
                pixel_out <= 8'd255;
            else
                pixel_out <= g_sum[7:0]; //else keep 8bit val 
            //
            valid_out <= 1'b1; // it made val
        // ]
        end 
        else begin
            valid_out <= 1'b0; //else it didnt make val
        end
    end

endmodule