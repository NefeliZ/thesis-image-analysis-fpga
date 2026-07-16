`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// multiplexer 4 to 1: 
// 4 input 1 output 1 selection line
//////

module mux_4_1(
    input wire a, b, c, d,
    input wire [1:0] s, //selection line is 2bit to choose from 4 options: 00, 01, ...
    output reg out
    );
    
      always @(*) begin
        case(s)
            2'b00: out = a;
            2'b01: out = b;
            2'b10: out = c;
            2'b11: out = d;
            default: out = 1'b0; //default option to avoid probs
        endcase
    end
    
endmodule
