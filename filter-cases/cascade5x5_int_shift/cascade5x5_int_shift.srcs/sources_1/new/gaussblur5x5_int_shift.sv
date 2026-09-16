`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// gaussin blur filter with 5x5 window - integers - shifts
//////

module gaussblur5x5_int_shift #(

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
    
    //gaussian blur calculations
    logic [15:0] g_sum;

    always_comb begin
        // K: 1/256 * [1,  4,  6,  4, 1],[4, 16, 24, 16, 4],[6, 24, 36, 24, 6],[4, 16, 24, 16, 4],[1,  4,  6,  4, 1]]
        //-> 1*P00, 4*P01, 6P02 , 4*P03, P04| 4P10, 16P11, 2*img12 , 1*img20, 2*img21, 1*img22
        //extra 'paddign'(0s at the sign) to avoid error when shifting
        g_sum = {8'b0, window[0][0]}       +  ({8'b0, window[0][1]} << 2) + 
                ({8'b0, window[0][2]} << 2) + ({8'b0, window[0][2]} << 1) + // x6 = x4 + x2
                ({8'b0, window[0][3]} << 2) + {8'b0, window[0][4]} + //row 0
                ({8'b0, window[1][0]} << 2)  + ({8'b0, window[1][1]} << 4) +
                ({8'b0, window[1][2]} << 4) + ({8'b0, window[1][2]} << 3) + // x24 = x16 + x8
                ({8'b0, window[1][3]} << 4) + ({8'b0, window[1][4]} << 2)+ //row1
                ({8'b0, window[2][0]} << 2) + ({8'b0, window[2][0]} << 1)+ // x6 = x4 + x2
                ({8'b0, window[2][1]} << 4) + ({8'b0, window[2][1]} << 3)+ // x24 = x16 + x8
                ({8'b0, window[2][2]} << 5) + ({8'b0, window[2][2]} << 2) +// x36 = x32 + x4
                ({8'b0, window[2][3]} << 4) + ({8'b0, window[2][3]} << 3) +// x24 = x16 + x8
                ({8'b0, window[2][4]} << 2) + ({8'b0, window[2][4]} << 1) +// x6 = x4 + x2 //row2
                ({8'b0, window[3][0]} << 2) + ({8'b0, window[3][1]} << 4) +
                ({8'b0, window[3][2]} << 4) + ({8'b0, window[3][2]} << 3) + // x24 = x16 + x8
                ({8'b0, window[3][3]} << 4) + ({8'b0, window[3][4]} << 2) +
                {8'b0, window[4][0]} + ({8'b0, window[4][1]} << 2) +
                ({8'b0, window[4][2]} << 2) + ({8'b0, window[4][2]} << 1) +// x6 = x4 + x2
                ({8'b0, window[4][3]} << 2) + {8'b0, window[4][4]};
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
                // keep bits [11:4] = g_sum >> 8 = 1/256
                pixel_out <= g_sum[15:8];
                //no saturation case needed
                // factors sum up to 1
                // for vals <=255 it wont saturate
            end 
            else begin //else it didnt make val
                valid_out <= 1'b0; 
            end
       end
    end

endmodule