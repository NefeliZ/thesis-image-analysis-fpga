`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// line buffer for 3x3 window 
//////


module line_buffer_3x3 #(
    parameter int DATA_WIDTH = 8,
    parameter int IMG_WIDTH = 368, //change img size
    parameter int IMG_HEIGHT = 487 

)

(
    input  logic clk,
    input  logic reset,
    input  logic [DATA_WIDTH-1:0] pixel_in, //new pixel
    output logic [DATA_WIDTH-1:0] p00, p01, p02, //9 vars for 3x3 window
    output logic [DATA_WIDTH-1:0] p10, p11, p12,
    output logic [DATA_WIDTH-1:0] p20, p21, p22,
    input  logic valid_in, //check input
    output logic valid_out //check output
);

    // circular buffer lines 
    // arrays sized based on img width
    logic [DATA_WIDTH-1:0] line0 [0:IMG_WIDTH-1];
    logic [DATA_WIDTH-1:0] line1 [0:IMG_WIDTH-1];
    
    int curr_pix_pos; //shows current pixel position
    
    //line buffer logic
    always_ff @(posedge clk or negedge reset) begin
    
        if (!reset) begin //start case
            curr_pix_pos <= 0;
            
            //clean/zero lines - x val problem
            for (int i = 0; i < IMG_WIDTH; i++) begin
                line0[i] <= 8'd0;
                line1[i] <= 8'd0;
            end
        end 
        else if (valid_in) begin
        
            //previous line goes forward
            line0[curr_pix_pos] <= line1[curr_pix_pos]; //in line0 at curr-pos write line1
            line1[curr_pix_pos] <= pixel_in; //in line1 at curr-pos write new pixel
            
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
            p00 <= 0; p01 <= 0; p02 <= 0;
            p10 <= 0; p11 <= 0; p12 <= 0;
            p20 <= 0; p21 <= 0; p22 <= 0;
        end 
        else if (valid_in) begin
            //row0 - oldest - line0
            // push p01,p02 to 00,01 - add line0[curr_pix_pos] to 02
            p00 <= p01;
            p01 <= p02;
            p02 <= line0[curr_pix_pos];
            
            //row1 - intermediate - line1
            // push p11,p12 to 10,11 - add line1[curr_pix_pos] to 12
            p10 <= p11;
            p11 <= p12;
            p12 <= line1[curr_pix_pos];
            
            //row2 - current/new line
            // push p21,p22 to 20,21 - add newpixel to 22
            p20 <= p21;
            p21 <= p22;
            p22 <= pixel_in; //_delay
        end
    end

    //border check vars
    // counters/pointers - what row/col im at
    int in_col;
    int in_row;
    int pixel_count; //how many pixels in window currently
    
    //after how many pixels the window is filled - img_width*2+2 (2 lines + 2 pixels)
    localparam int FULL_LATENCY = (IMG_WIDTH*2) + 2;

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
                if ((in_col >= 2) && (in_col <= IMG_WIDTH - 1) && (in_row >= 2) && (in_row <= IMG_HEIGHT - 1)) begin
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