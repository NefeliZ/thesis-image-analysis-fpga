`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// simple NOT gate
//////
module not_gate
(
    input a,
    input b,
    output not_a,
    output not_b

);

    assign not_a = ~a;
    assign not_b = ~b;
    
endmodule
