`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// blur filter with 2 windows 3x3
//////


module blur_3x3#(
    parameter DATA_WIDTH = 8
)(
    input  logic clk,
    input  logic reset,
    input  logic valid_in,
    
    //2 windows => 3rows & 4cols => 12 pixels -> 3x4
    input  logic [DATA_WIDTH-1:0] grid [0:2][0:3], 
    
    output logic valid_out,
    output logic [DATA_WIDTH-1:0] pixel_out_0, // 1st window
    output logic [DATA_WIDTH-1:0] pixel_out_1  //2nd win
);

    //create 2 windows
    logic [DATA_WIDTH-1:0] win0 [0:2][0:2];
    logic [DATA_WIDTH-1:0] win1 [0:2][0:2];

    always_comb begin
        for (int r = 0; r < 3; r++) begin
            for (int c = 0; c < 3; c++) begin
                win0[r][c] = grid[r][c]; // win0: cols 0 1 2 | rows 0 1 2
                win1[r][c] = grid[r][c+1]; //win1: cols 1 2 3 | rows 0 1 2
            end
        end
    end

    //create 2 instances of filter for the 2 windows
    // called from other file
    box_blur_3x3 #(
        .DATA_WIDTH(DATA_WIDTH)
    ) core_0 ( 
        .clk (clk),
        .reset (reset),
        .valid_in (valid_in),
        .window (win0), //1st
        .valid_out(),
        .pixel_out(pixel_out_0)
    );

    box_blur_3x3 #(
        .DATA_WIDTH(DATA_WIDTH)
    ) core_1 ( 
        .clk (clk),
        .reset (reset),
        .valid_in (valid_in),
        .window (win1), //2nd
        .valid_out(valid_out),
        .pixel_out(pixel_out_1)
    );

endmodule
