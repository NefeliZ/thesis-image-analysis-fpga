`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// sobel filter with 5x5 window - integers - shifts
//////

module sobel5x5_int_shift #(

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
    
    // assing pixel vals to window
    logic [DATA_WIDTH-1:0] window [0:4][0:4];
    
    assign window[0][0] = p00;  assign window[0][1] = p01;  assign window[0][2] = p02; 
    assign window[0][3] = p03;  assign window[0][4] = p04;  
    assign window[1][0] = p10;  assign window[1][1] = p11;  assign window[1][2] = p12;
    assign window[1][3] = p13;  assign window[1][4] = p14;
    assign window[2][0] = p20;  assign window[2][1] = p21;  assign window[2][2] = p22;
    assign window[2][3] = p23;  assign window[2][4] = p24;
    assign window[3][0] = p30;  assign window[3][1] = p31;  assign window[3][2] = p32;
    assign window[3][3] = p33;  assign window[3][4] = p34;
    assign window[4][0] = p40;  assign window[4][1] = p41;  assign window[4][2] = p42;
    assign window[4][3] = p43;  assign window[4][4] = p44;
    
    //middle vars used to calc - 11-bit
    logic signed [15:0] gx_pos, gx_neg;
    logic signed [15:0] gy_pos, gy_neg;
    logic signed [15:0] gx, gy;
    logic [15:0] abs_gx, abs_gy;
    logic [15:0] g_sum;

    //sobel filter calculations
    always_comb begin
        // Kx: [-1 -2 0 2 1 | -4 -8 0 8 4 | -6 -12 0 12 6 |-4 -8 0 8 4 | -1 -2 0 2 1]
        //Gx = (-P00 - 2P01 + 2P03 + P04) + (-4P10 -8P11 + 8P13 +4P14) + (-6P20 - 12P21 + 12P23 + 6P24) + (-4P30 - 8P31 + 8P33 + 4P34) + (-P40 - 2P41 + 2P43 + P44)
        //
        // pos = 2P03 + P04 + 8P13 +4P14 + 12P23 + 6P24 + 8P33 + 4P34 + 2P43 + P44
        //extra 'paddign'(0s at the sign) to avoid error when shifting
        gx_pos = ($signed({8'b0, window[0][3]}) << 1) + $signed({8'b0, window[0][4]}) +
                 ($signed({8'b0, window[1][3]}) << 3) + ($signed({8'b0, window[1][4]}) << 2) +
                 ($signed({8'd0, window[2][3]}) << 3) + ($signed({8'd0, window[2][3]}) << 2) + // *12 = <<3 + <<2)
                 ($signed({8'b0, window[2][4]}) << 2) + ($signed({8'd0, window[2][4]}) << 1) + // *6 = <<2 + <<1
                 ($signed({8'b0, window[3][3]}) << 3) + ($signed({8'b0, window[3][4]}) << 2) +
                 ($signed({8'b0, window[4][3]}) << 1) + $signed({8'b0, window[4][4]});
                 
        // neg = -P00 - 2P01 -4P10 -8P11 -6P20 - 12P21 -4P30 - 8P31 -P40 - 2P41 
        gx_neg =  $signed({8'b0, window[0][0]})       + ($signed({8'b0, window[0][1]}) << 1) +
                 ($signed({8'b0, window[1][0]}) << 2) + ($signed({8'b0, window[1][1]}) << 3) +
                 ($signed({8'd0, window[2][0]}) << 2) + ($signed({8'd0, window[2][0]}) << 1) + // *6 = <<2 + <<1
                 ($signed({8'b0, window[2][1]}) << 3) + ($signed({8'd0, window[2][1]}) << 2) + // *12 = <<3 + <<2)
                 ($signed({8'b0, window[3][0]}) << 2) + ($signed({8'b0, window[3][1]}) << 3) +
                 $signed({8'b0, window[4][0]})        + ($signed({8'b0, window[4][1]}) << 1);
        
        gx = gx_pos - gx_neg;

        
        // Ky: [1 4 6 4 1 | 2 8 12 8 2| 0 0 0 0 0 | -2 -8 -12 -8 -2 | -1 -4 -6 -4 -1]
        //Gy =(P00 + 4P01 + 6P02 + 4P03 + P04) + (2P10 +8P11 + 12P12 + 8P13 +2P14) 
        // + (-2P30 - 8P31 -12P32 - 8P33 - 2P34) + (-P40 - 4P41 - 6P42 -4P43 - P44)
       //
       //pos =  (P00 + 4P01 + 6P02 + 4P03 + P04) + (2P10 +8P11 + 12P12 + 8P13 +2P14)
        gy_pos =  $signed({8'b0, window[0][0]})       + ($signed({8'b0, window[0][1]}) << 2) + 
                 ($signed({8'b0, window[0][2]}) << 2) + ($signed({8'b0, window[0][2]}) << 1) + // *6 = <<2 + <<1
                 ($signed({8'b0, window[0][3]}) << 2) + $signed({8'b0, window[0][4]}) +
                 ($signed({8'b0, window[1][0]}) << 1) + ($signed({8'b0, window[1][1]}) << 3) +
                 ($signed({8'b0, window[1][2]}) << 3) + ($signed({8'b0, window[1][2]}) << 2) + // *12 = <<3 + <<2)
                 ($signed({8'b0, window[1][3]}) << 3) + ($signed({8'b0, window[1][4]}) << 1);
       
       //neg = -2P30 - 8P31 -12P32 - 8P33 - 2P34 -P40 - 4P41 - 6P42 -4P43 - P44
        gy_neg = ($signed({8'b0, window[3][0]}) << 1) + ($signed({8'b0, window[3][1]}) << 3) + 
                 ($signed({8'b0, window[3][2]}) << 3) + ($signed({8'b0, window[3][2]}) << 2) + // *12 = <<3 + <<2)
                 ($signed({8'b0, window[3][3]}) << 3) + ($signed({8'b0, window[3][4]}) << 1) +
                  $signed({8'b0, window[4][0]})       + ($signed({8'b0, window[4][1]}) << 2) +
                 ($signed({8'b0, window[4][2]}) << 2) + ($signed({8'b0, window[4][2]}) << 1) + // *6 = <<2 + <<1
                 ($signed({8'b0, window[4][3]}) << 2) +  $signed({8'b0, window[4][4]});
                 
         gy = gy_pos - gy_neg;
         
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
        else begin
            //fix alignment problem - in and out in synch to wait for pixelout
            valid_out <= valid_in;
            if (valid_in) begin //if it took val
                if (g_sum > 16'd255) // if 11-bit and >255 => keep 255 8bit (white-max val)
                    pixel_out <= 8'd255;
                else
                    pixel_out <= g_sum[7:0]; //else keep 8bit val 
                //
            end 
            else begin //else it didnt make val
                valid_out <= 1'b0; 
            end
       end
    end

endmodule