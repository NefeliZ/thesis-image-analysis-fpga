`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////
// simple OR gate - testbench
//////

module or_gate_tb;

    // input as reg - output as wire
    reg a, b;
    wire y;

    //circuit to check 
    or_gate uut //"Unit Under Test"
    (
        .a(a),
        .b(b),
        .or_y(y)
    );
    
    // put all possible val-pairs of input vals
    initial begin
        // monitor- to see output vals
        $monitor("a=%b, b=%b, y=%b", a, b, y);

        a = 0; b = 0; #10; //wait 10
        a = 0; b = 1; #10;
        a = 1; b = 0; #10;
        a = 1; b = 1; #10;

        $finish;
    end
endmodule

