`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// simple NOT gate - testbench
//////

module not_gate_tb;

    // input as reg - output as wire
    reg a, b;
    wire x, y;

    //circuit to check 
    not_gate uut //"Unit Under Test"
    (
        .a(a),
        .b(b),
        .not_a(x),
        .not_b(y)
);
    
    // put all possible val-pairs of input vals
    initial begin
        // monitor- to see output vals
        $monitor("a=%b, b=%b, not_a=%b, not_b=%b", a, b, x, y);

        a = 0; b = 0; #10; //wait 10
        a = 0; b = 1; #10;
        a = 1; b = 0; #10;
        a = 1; b = 1; #10;

        $finish;
    end
endmodule

