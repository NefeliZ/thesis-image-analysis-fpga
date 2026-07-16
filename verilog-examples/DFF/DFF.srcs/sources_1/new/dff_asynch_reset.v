`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// DFF asynchronous me reset
//////

module dff_asynch_reset(
    input wire clk, //clock
    input wire reset, // asynchr reset - active low => midenisma otan einai 0
    input wire in,  // input data
    output reg out    // output 
    );
    
    //wake up when clock posedge or reset negedge
    // <= instead of = because non-blocking &clock
    always @(posedge clk or negedge reset) begin
        if (reset == 1'b0) begin
            out <= 1'b0; // if enable reset -> out =0
        end 
        else begin //else when posedge out = in
            out <= in; 
        end
    end
    
endmodule
