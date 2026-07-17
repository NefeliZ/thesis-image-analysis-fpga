`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// arithm & logic unit: +, -, &, | and clock-reset
//////

module alu(
    input  logic clk, // clock
    input  logic reset, //reset
    input  logic [3:0] a, //input a
    input  logic [3:0] b, //input b
    input  logic [1:0] sel, //selection of operation
    output logic [3:0] q //output reg
    );
    
    //result of operation
    logic [3:0] alu_out;

    // combinationallogic
    always_comb begin
        case (sel)
            2'b00:   alu_out = a + b; //add+
            2'b01:   alu_out = a - b; // subtract-
            2'b10:   alu_out = a & b; // AND
            2'b11:   alu_out = a | b; // OR
            default: alu_out = 4'b0000;
        endcase
    end

    //sequetial logic
    always_ff @(posedge clk or negedge reset) begin
        if (reset == 1'b0) begin
            q <= 4'b0000; // if enable reset -> out =0
        end else begin
            q <= alu_out; //else get res of operation 
        end
    end
    
endmodule
