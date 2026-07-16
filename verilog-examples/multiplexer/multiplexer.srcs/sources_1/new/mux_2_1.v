`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// multiplexer 2 to 1: 
// 2 input 1 output 1 selection line
//////

module mux_2_1(
    input a,
    input b,
    input s,
    output y
    );
    
    assign y = (s) ? b : a;
    // ?: conditional (ternary) operator
    // if s is 1 -> y = b else (if s einai 0) -> y=a
    
endmodule
