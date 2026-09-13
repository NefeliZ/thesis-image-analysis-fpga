`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// line buffer for 5x5 window 
//////


module line_buffer_5x5 #(
    parameter int DATA_WIDTH = 8,
    parameter int IMG_WIDTH = 368, //change img size
    parameter int IMG_HEIGHT = 487 

)
(
    input  logic clk,
    input  logic reset,
    input  logic [DATA_WIDTH-1:0] pixel_in, //new pixel
    output logic [DATA_WIDTH-1:0] p00, p01, p02, p03, p04, //25 vars for 5x5 window
    output logic [DATA_WIDTH-1:0] p10, p11, p12, p13, p14,
    output logic [DATA_WIDTH-1:0] p20, p21, p22, p23, p24,
    output logic [DATA_WIDTH-1:0] p30, p31, p32, p33, p34,
    output logic [DATA_WIDTH-1:0] p40, p41, p42, p43, p44,

    input  logic valid_in, //check input
    output logic valid_out //check output
);

    // circular buffer lines 
    // arrays sized based on img width
    logic [DATA_WIDTH-1:0] line0 [0:IMG_WIDTH-1];
    logic [DATA_WIDTH-1:0] line1 [0:IMG_WIDTH-1];
    logic [DATA_WIDTH-1:0] line2 [0:IMG_WIDTH-1];
    logic [DATA_WIDTH-1:0] line3 [0:IMG_WIDTH-1];
    
    int curr_pix_pos; //shows current pixel position
    
    //line buffer logic
    always_ff @(posedge clk or negedge reset) begin
    
        if (!reset) begin //start case
            curr_pix_pos <= 0;
            
            //clean/zero lines - x val problem
            for (int i = 0; i < IMG_WIDTH; i++) begin
                line0[i] <= 8'd0;
                line1[i] <= 8'd0;
                line2[i] <= 8'd0;
                line3[i] <= 8'd0;

            end
        end 
        else if (valid_in) begin
        
            //previous line goes forward
            line0[curr_pix_pos] <= line1[curr_pix_pos]; 
            line1[curr_pix_pos] <= line2[curr_pix_pos]; 
            line2[curr_pix_pos] <= line3[curr_pix_pos]; 
            line3[curr_pix_pos] <= pixel_in; 
            
            //increase pixel pointer if not at the border
            if (curr_pix_pos == IMG_WIDTH - 1) begin
                curr_pix_pos <= 0;
            end 
            else begin
                curr_pix_pos <= curr_pix_pos + 1; //increase current pixel position
            end
        end
    end
    
    //shift register
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin //all zero
            p00 <= 0; p01 <= 0; p02 <= 0; p03 <= 0; p04 <= 0;
            p10 <= 0; p11 <= 0; p12 <= 0; p13 <= 0; p14 <= 0;
            p20 <= 0; p21 <= 0; p22 <= 0; p23 <= 0; p24 <= 0;
            p30 <= 0; p31 <= 0; p32 <= 0; p33 <= 0; p34 <= 0;
            p40 <= 0; p41 <= 0; p42 <= 0; p43 <= 0; p44 <= 0;
        end 
        else if (valid_in) begin
            //row y-4
            p00 <= p01; p01 <= p02; 
            p02 <= p03; p03 <= p04;
            p04 <= line0[curr_pix_pos];

            // row y-3
            p10 <= p11; p11 <= p12; 
            p12 <= p13; p13 <= p14;
            p14 <= line1[curr_pix_pos];

            // Row y-2 - p22
            p20 <= p21; p21 <= p22; 
            p22 <= p23; p23 <= p24;
            p24 <= line2[curr_pix_pos];

            // row y-1
            p30 <= p31; p31 <= p32; 
            p32 <= p33; p33 <= p34;
            p34 <= line3[curr_pix_pos];

            // row y
            p40 <= p41; p41 <= p42; 
            p42 <= p43; p43 <= p44;
            p44 <= pixel_in;
        end
    end

    //border check vars
    // counters/pointers - what row/col im at
    int in_col;
    int in_row;
    int pixel_count; //how many pixels in window currently
    
    //after how many pixels the window is filled - img_width*4+4 (4 lines + 4 pixels)
    localparam int FULL_LATENCY = (IMG_WIDTH*4) + 4;

    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            in_col <= 0;
            in_row <= 0;
            pixel_count <= 0;
            valid_out <= 1'b0;
        end 
        else if (valid_in) begin
            pixel_count <= pixel_count + 1;
        
            // check if im at borders/end
            if (in_col == IMG_WIDTH - 1) begin //if reached the end (right)
                in_col <= 0;
                in_row <= in_row + 1;
            end 
            else begin
                in_col <= in_col + 1;
            end

            // after latency/window is filled 
            if (pixel_count >= FULL_LATENCY) begin
                
                //check if window is NOT at the edge/borders - 1pixel padding
                if ((in_col >= 4) && (in_col <= IMG_WIDTH - 1) && (in_row >= 4) && (in_row <= IMG_HEIGHT - 1)) begin
                    valid_out <= 1'b1;
                end 
                else begin
                    valid_out <= 1'b0;
                end
            end 
            else begin
                valid_out <= 1'b0;
            end
        end 
        else begin
            valid_out <= 1'b0;
        end
    end

endmodule