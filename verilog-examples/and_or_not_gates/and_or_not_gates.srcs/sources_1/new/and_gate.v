`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// simple and gate
//////
module and_gate
(
    input a,
    input b,
    output and_y
);
    assign and_y = a & b;
    
endmodule
