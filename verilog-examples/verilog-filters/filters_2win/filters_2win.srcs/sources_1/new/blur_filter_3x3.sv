`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// blur box filter with 3x3 window
// base of the filter - called by other file
//////

module blur_filter_3x3 #(

 parameter DATA_WIDTH = 8
)(
    input logic clk,
    input logic reset,
    input logic valid_in,
    
    // 2D array 3x3 - filter window
    input logic [DATA_WIDTH-1:0] window [0:2][0:2],
    
    output logic valid_out,
    output logic [DATA_WIDTH-1:0] pixel_out
);

    //middle vars used to calc - 11-bit
    logic [15:0] sum;
    logic [15:0] blur_res;
    logic valid_reg1, valid_reg2;

    //blur filter calculations
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            sum <= '0;
            valid_reg1 <= 1'b0;
        end 
        else begin //calc sum of pixels in window
            valid_reg1 <= valid_in;
            if (valid_in) begin
                sum <=  window[0][0] + window[0][1] + window[0][2] + window[0][3] + window[0][4] +
                        window[1][0] + window[1][1] + window[1][2] + window[1][3];
            end
        end
    end

    // divide to make average -> blur
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            blur_res <= '0;
            valid_reg2  <= 1'b0;
        end else begin
            valid_reg2 <= valid_reg1;
            if (valid_reg1) begin
                blur_res <= sum / 25;
            end
        end
    end

    // assign output
    assign valid_out = valid_reg2;
    assign pixel_out = blur_res[DATA_WIDTH-1:0];

endmodule