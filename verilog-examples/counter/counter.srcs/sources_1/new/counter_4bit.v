`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// 4bit counter with reset
//////


module counter_4bit(
    input wire clk, // clock
    input wire reset, // reset
    output reg [3:0] out  // 4bit out
    );
    
    //wake up when clock posedge or reset negedge
    // <= instead of = because non-blocking &clock
    always @(posedge clk or negedge reset) begin
        if (reset == 1'b0) begin
            out <= 4'b0000; // if enable reset -> out =0
        end 
        else begin
            out <= out + 1'b1; //else when posedge out +=1
        end
    end
endmodule
